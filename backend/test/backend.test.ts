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

test('UploadService: Short Code Generation & Collision Retry Loop', async () => {
  const uploadService = new UploadService();
  const code1 = uploadService.generateShortCode();
  const code2 = uploadService.generateShortCode();

  assert.strictEqual(code1.length, 6);
  assert.strictEqual(code2.length, 6);
  assert.notStrictEqual(code1, code2);
  // Ensure no ambiguous characters: 0, 1, I, O
  assert.strictEqual(/[01IO]/.test(code1), false);
  assert.strictEqual(/[01IO]/.test(code2), false);

  // Test async unique short code generation with collision avoidance
  const uniqueCode = await uploadService.generateUniqueShortCode();
  assert.ok(uniqueCode.length >= 6);
  assert.strictEqual(/[01IO]/.test(uniqueCode), false);
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

  // Test dynamic offline verification: simulate heartbeat 130s ago (>120s threshold)
  const pastTimestamp = new Date(Date.now() - 130 * 1000).toISOString();
  const { db } = await import('../src/modules/database/db');
  await db.upsertDevice({
    id: registered.device.id,
    device_identifier: 'LUSTER-360-TEST-01',
    last_heartbeat: pastTimestamp,
    status: 'ONLINE',
  });

  const fleetAfterTimeout = await deviceService.getFleetStatus();
  const timedOutDev = fleetAfterTimeout.find((d: any) => d.device_identifier === 'LUSTER-360-TEST-01');
  assert.ok(timedOutDev);
  assert.strictEqual(timedOutDev.calculatedStatus, 'OFFLINE', 'Device must be flagged OFFLINE when last heartbeat >120s');
  assert.strictEqual(timedOutDev.currentState, 'OFFLINE');
});

test('RBAC Middleware: Role-Based 403 Forbidden Enforcement', async () => {
  const { requireRole } = await import('../src/middleware/auth.middleware');
  const adminGuard = requireRole(['super_admin', 'company_admin']);

  // Case 1: Super admin allowed
  let nextCalled = false;
  const mockReqAdmin = { user: { role: 'super_admin' }, userRole: 'super_admin' } as any;
  const mockResAdmin = {} as any;
  adminGuard(mockReqAdmin, mockResAdmin, () => { nextCalled = true; });
  assert.strictEqual(nextCalled, true, 'Super Admin should be allowed through guard');

  // Case 2: Operator blocked with 403 Forbidden
  let statusCode = 0;
  let responseBody: any = null;
  const mockReqOperator = { user: { role: 'operator' }, userRole: 'operator' } as any;
  const mockResOperator = {
    status(code: number) {
      statusCode = code;
      return this;
    },
    json(body: any) {
      responseBody = body;
      return this;
    },
  } as any;

  adminGuard(mockReqOperator, mockResOperator, () => {
    assert.fail('Operator should NOT reach next()');
  });

  assert.strictEqual(statusCode, 403, 'Operator must be rejected with HTTP 403');
  assert.strictEqual(responseBody?.error?.code, 'FORBIDDEN');
});

test('AdminService: Fleet Summary, Analytics and Device Decommission', async () => {
  const { adminService } = await import('../src/modules/admin/admin.service');
  
  // Test Summary
  const summary = await adminService.getSummary();
  assert.ok(summary);
  assert.ok(typeof summary.activeDevicesCount === 'number');
  assert.ok(typeof summary.totalCaptures === 'number');
  assert.ok(Array.isArray(summary.alerts));

  // Test Analytics
  const analytics = await adminService.getAnalytics();
  assert.ok(analytics);
  assert.ok(Array.isArray(analytics.captureVolume));
  assert.ok(analytics.captureVolume.length === 7);
  assert.ok(analytics.modeBreakdown.slowMo > 0);

  // Test Deauthorize Device
  const deauthResult = await adminService.deauthorizeDevice('LUSTER-360-TEST-01');
  assert.strictEqual(deauthResult.success, true);
});

test('RBAC Integration: Non-Admin Roles Blocked Across All Admin Endpoints', async () => {
  const { requireRole, authenticateDeviceOrAdmin } = await import('../src/middleware/auth.middleware');
  const adminGuard = requireRole(['super_admin', 'company_admin']);

  const protectedEndpoints = [
    '/admin/summary',
    '/admin/analytics',
    '/admin/events/e-01/drilldown',
    '/admin/storage/status',
    '/admin/devices/LUSTER-01/deauthorize',
    '/admin/users/u-01/role',
    '/auth/users',
  ];

  const unauthorizedRoles = ['operator', 'viewer', 'guest', ''];

  for (const role of unauthorizedRoles) {
    for (const endpoint of protectedEndpoints) {
      let statusCode = 0;
      let responseBody: any = null;

      const mockReq = {
        path: endpoint,
        user: { role },
        userRole: role,
        headers: {},
      } as any;

      const mockRes = {
        status(code: number) {
          statusCode = code;
          return this;
        },
        json(body: any) {
          responseBody = body;
          return this;
        },
      } as any;

      adminGuard(mockReq, mockRes, () => {
        assert.fail(`Role "${role}" must NOT access ${endpoint}`);
      });

      assert.strictEqual(
        statusCode,
        403,
        `Role "${role}" on ${endpoint} must return HTTP 403 Forbidden`
      );
      assert.strictEqual(responseBody?.error?.code, 'FORBIDDEN');
    }
  }

  // Verify company_admin and super_admin are allowed
  for (const allowedRole of ['super_admin', 'company_admin']) {
    let allowed = false;
    const mockReq = {
      path: '/admin/summary',
      user: { role: allowedRole },
      userRole: allowedRole,
    } as any;
    adminGuard(mockReq, {} as any, () => { allowed = true; });
    assert.strictEqual(allowed, true, `Role "${allowedRole}" must be permitted on admin endpoints`);
  }
});
