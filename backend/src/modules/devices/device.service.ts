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

  public async recordHeartbeat(dto: HeartbeatDTO) {
    const timestamp = new Date().toISOString();

    // 1. Record raw heartbeat log
    await db.recordHeartbeat({
      device_id: dto.deviceId,
      current_event_id: dto.currentEventId || null,
      operational_state: dto.operationalState,
      battery_level: dto.batteryLevel || null,
      is_charging: dto.isCharging || false,
      storage_free_bytes: dto.storageFreeBytes || null,
      network_type: dto.networkType || 'WIFI',
      app_version: dto.appVersion,
      timestamp,
    });

    // 2. Update device status
    await db.upsertDevice({
      id: dto.deviceId,
      current_state: dto.operationalState,
      battery_level: dto.batteryLevel,
      is_charging: dto.isCharging,
      storage_free_bytes: dto.storageFreeBytes,
      storage_total_bytes: dto.storageTotalBytes,
      current_event_id: dto.currentEventId,
      last_heartbeat: timestamp,
      status: 'ONLINE',
    });

    return { acknowledged: true, timestamp };
  }

  public async getFleetStatus() {
    const devices = await db.listDevices();
    const now = Date.now();

    return devices.map((device: any) => {
      let isOnline = false;
      let secondsSinceHeartbeat = null;

      if (device.last_heartbeat) {
        const lastHb = new Date(device.last_heartbeat).getTime();
        secondsSinceHeartbeat = Math.floor((now - lastHb) / 1000);
        isOnline = secondsSinceHeartbeat <= this.OFFLINE_THRESHOLD_SECONDS;
      }

      return {
        ...device,
        calculatedStatus: isOnline ? 'ONLINE' : 'OFFLINE',
        secondsSinceHeartbeat,
        currentState: isOnline ? device.current_state : 'OFFLINE',
      };
    });
  }

  public async disconnectDevice(deviceId: string) {
    const timestamp = new Date().toISOString();
    await db.upsertDevice({
      id: deviceId,
      current_state: 'OFFLINE',
      status: 'OFFLINE',
      last_heartbeat: timestamp,
    });
    logger.info(`Device explicitly disconnected: ${deviceId}`);
    return { acknowledged: true, status: 'OFFLINE', timestamp };
  }
}

export const deviceService = new DeviceService();
