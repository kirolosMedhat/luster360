import crypto from 'crypto';
import { db } from '../database/db';
import { logger } from '../../config/logger';

export interface RegisterDeviceDTO {
  deviceIdentifier: string;
  deviceName: string;
  platform: string;
  osVersion?: string;
  appVersion: string;
}

export interface HeartbeatDTO {
  deviceId: string;
  currentEventId?: string;
  operationalState: 'IDLE' | 'READY' | 'COUNTDOWN' | 'RECORDING' | 'PROCESSING' | 'RENDERING' | 'UPLOADING' | 'ERROR' | 'OFFLINE';
  batteryLevel?: number;
  isCharging?: boolean;
  storageFreeBytes?: number;
  storageTotalBytes?: number;
  appVersion: string;
  networkType?: string;
}

export class DeviceService {
  private readonly OFFLINE_THRESHOLD_SECONDS = 35; // Dynamically considered offline after 35s without heartbeat

  public async registerDevice(dto: RegisterDeviceDTO) {
    // Generate secure random token
    const rawToken = crypto.randomBytes(32).toString('hex');
    const tokenHash = crypto.createHash('sha256').update(rawToken).digest('hex');

    const deviceRecord = {
      device_identifier: dto.deviceIdentifier,
      device_name: dto.deviceName,
      device_token_hash: tokenHash,
      platform: dto.platform,
      os_version: dto.osVersion || null,
      app_version: dto.appVersion,
      status: 'REGISTERED',
      current_state: 'IDLE',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    const device = await db.upsertDevice(deviceRecord);
    logger.info(`Device registered: ${dto.deviceIdentifier} (${dto.deviceName})`);

    return {
      deviceToken: rawToken,
      device,
    };
  }

  public async recordHeartbeat(dto: any) {
    if (!dto || !dto.deviceId || dto.deviceId === 'undefined') {
      return { acknowledged: false, message: 'Invalid deviceId' };
    }
    const timestamp = new Date().toISOString();
    const deviceId = dto.deviceId;
    const deviceName = dto.deviceName || 'Luster Mobile Unit';
    const platform = dto.model || dto.platform || 'Mobile';
    const appVersion = dto.appVersion || 'v1.4.0';
    const operationalState = dto.operationalState || dto.status || 'READY';
    const capturesRecorded = Number(dto.capturesRecorded || 0);
    const capturesUploaded = Number(dto.capturesUploaded || 0);
    const capturesPending = Math.max(0, capturesRecorded - capturesUploaded);

    // 1. Record raw heartbeat log
    await db.recordHeartbeat({
      device_id: deviceId,
      current_event_id: dto.currentEventId || null,
      operational_state: operationalState,
      battery_level: dto.batteryLevel || null,
      is_charging: dto.isCharging || false,
      storage_free_bytes: dto.storageFreeBytes || null,
      network_type: dto.networkType || 'WIFI',
      app_version: appVersion,
      timestamp,
    });

    // 2. Update device status with full metadata and capture counters
    await db.upsertDevice({
      id: deviceId,
      device_identifier: deviceId,
      device_name: deviceName,
      platform,
      app_version: appVersion,
      current_state: operationalState,
      battery_level: dto.batteryLevel,
      is_charging: dto.isCharging,
      storage_free_bytes: dto.storageFreeBytes,
      storage_total_bytes: dto.storageTotalBytes,
      current_event_id: dto.currentEventId,
      captures_recorded: capturesRecorded,
      captures_uploaded: capturesUploaded,
      captures_pending: capturesPending,
      last_heartbeat: timestamp,
      status: 'ONLINE',
    });

    return { acknowledged: true, timestamp, capturesRecorded, capturesUploaded, capturesPending };
  }

  public async getFleetStatus() {
    await db.cleanPhantomDevices();
    const devices = await db.listDevices();
    const now = Date.now();

    return devices
      .filter((device: any) => {
        const id = device.device_identifier || device.id || '';
        return id && !id.startsWith('dev-');
      })
      .map((device: any) => {
        let isOnline = false;
        let secondsSinceHeartbeat = null;

        if (device.last_heartbeat) {
          const lastHb = new Date(device.last_heartbeat).getTime();
          secondsSinceHeartbeat = Math.floor((now - lastHb) / 1000);
          isOnline = secondsSinceHeartbeat <= this.OFFLINE_THRESHOLD_SECONDS;
        }

        return {
          ...device,
          device_identifier: device.device_identifier || device.id,
          device_name: device.device_name || 'Luster Mobile Unit',
          calculatedStatus: isOnline ? 'ONLINE' : 'OFFLINE',
          secondsSinceHeartbeat,
          currentState: isOnline ? (device.current_state || 'ONLINE') : 'OFFLINE',
          capturesRecorded: device.captures_recorded || 0,
          capturesUploaded: device.captures_uploaded || 0,
          capturesPending: device.captures_pending || 0,
        };
      });
  }

  public async disconnectDevice(deviceId: string) {
    if (!deviceId || deviceId === 'undefined') {
      return { acknowledged: false, message: 'Invalid deviceId' };
    }
    const timestamp = new Date().toISOString();
    await db.upsertDevice({
      id: deviceId,
      device_identifier: deviceId,
      current_state: 'OFFLINE',
      status: 'OFFLINE',
      last_heartbeat: timestamp,
    });
    logger.info(`Device explicitly disconnected: ${deviceId}`);
    return { acknowledged: true, status: 'OFFLINE', timestamp };
  }
}

export const deviceService = new DeviceService();
