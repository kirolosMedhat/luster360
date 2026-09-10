import test from 'node:test';
import assert from 'node:assert/strict';
import { EventService } from '../src/modules/events/event.service';
import { UploadService } from '../src/modules/uploads/upload.service';
import { DeviceService } from '../src/modules/devices/device.service';
import { MockStorage } from '../src/modules/storage/mock-storage';
import { Readable } from 'stream';

test('EventService: Server-Independent Duration Calculation', () => {
  const eventService = new EventService();

  // Test 1: Exactly 4 hours and 42 minutes ago
  const now = Date.now();
  const startedAt = new Date(now - (4 * 3600 + 42 * 60) * 1000).toISOString();
  const result = eventService.calculateEventDuration(startedAt, null);

  assert.strictEqual(result.durationSeconds, 4 * 3600 + 42 * 60);
  assert.strictEqual(result.formatted, '04h 42m');

  // Test 2: Completed event with endedAt
  const endedAt = new Date(now - 1000).toISOString();
  const startedAt2 = new Date(now - 3600 * 1000).toISOString();
  const completedResult = eventService.calculateEventDuration(startedAt2, endedAt);
  assert.strictEqual(completedResult.durationSeconds, 3599);
  assert.strictEqual(completedResult.formatted, '59m 59s');
});

test('UploadService: Short Code Generation', () => {
  const uploadService = new UploadService();
  const code1 = uploadService.generateShortCode();
  const code2 = uploadService.generateShortCode();

  assert.strictEqual(code1.length, 6);
  assert.strictEqual(code2.length, 6);
  assert.notStrictEqual(code1, code2);
  // Ensure no ambiguous characters: 0, 1, I, O
  assert.strictEqual(/[01IO]/.test(code1), false);
  assert.strictEqual(/[01IO]/.test(code2), false);
});

test('MediaStorage: Mock Storage Folder Provisioning and Idempotent Upload', async () => {
  const storage = new MockStorage();
  await storage.initialize();

  // Test health check
  const health = await storage.healthCheck();
  assert.strictEqual(health.status, 'CONNECTED');

  // Test event folder hierarchy creation
  const folders = await storage.createEventFolders('Ahmed & Mariam Wedding');
  assert.ok(folders.rootFolderId);
  assert.ok(folders.videosFolderId);
  assert.ok(folders.thumbnailsFolderId);
  assert.ok(folders.brandingFolderId);

  // Test file upload
  const stream1 = Readable.from(Buffer.from('TEST_MP4_CONTENT'));
  const record1 = await storage.uploadFile({
    filename: 'video_101.mp4',
    mimeType: 'video/mp4',
    stream: stream1,
    parentFolderId: folders.videosFolderId,
    sizeBytes: 16,
  });

  assert.ok(record1.fileId);
  assert.strictEqual(record1.filename, 'video_101.mp4');

  // Test idempotency: uploading file with same name in same folder should return existing record
  const stream2 = Readable.from(Buffer.from('DIFFERENT_CONTENT'));
  const record2 = await storage.uploadFile({
    filename: 'video_101.mp4',
    mimeType: 'video/mp4',
    stream: stream2,
    parentFolderId: folders.videosFolderId,
    sizeBytes: 17,
  });

  assert.strictEqual(record2.fileId, record1.fileId);
  assert.strictEqual(record2.sizeBytes, 16);

  // Test verification
  const isVerified = await storage.verifyFile(record1.fileId, 16);
  assert.strictEqual(isVerified, true);
});

test('DeviceService: Telemetry and Dynamic Offline Calculation', async () => {
  const deviceService = new DeviceService();
  const registered = await deviceService.registerDevice({
    deviceIdentifier: 'LUSTER-360-TEST-01',
    deviceName: 'Test Booth',
    platform: 'android',
    appVersion: '1.0.0',
  });

  assert.ok(registered.deviceToken);
  assert.strictEqual(registered.device.device_identifier, 'LUSTER-360-TEST-01');

  // Send heartbeat
  await deviceService.recordHeartbeat({
    deviceId: registered.device.id,
    operationalState: 'RECORDING',
    batteryLevel: 95,
    storageFreeBytes: 50000000000,
    appVersion: '1.0.0',
  });

  const fleet = await deviceService.getFleetStatus();
  const testDev = fleet.find((d: any) => d.device_identifier === 'LUSTER-360-TEST-01');
  assert.ok(testDev);
  assert.strictEqual(testDev.calculatedStatus, 'ONLINE');
  assert.strictEqual(testDev.currentState, 'RECORDING');
  assert.strictEqual(testDev.battery_level, 95);
});
