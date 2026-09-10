import { MediaStorage } from './media-storage.interface';
import { GoogleDriveStorage } from './google-drive-storage';
import { MockStorage } from './mock-storage';
import { config } from '../../config/env';
import { logger } from '../../config/logger';

let storageInstance: MediaStorage | null = null;

export async function getStorageProvider(): Promise<MediaStorage> {
  if (storageInstance) {
    return storageInstance;
  }

  if (config.storageProvider === 'GOOGLE_DRIVE') {
    logger.info('Initializing Google Drive V1 Media Storage Provider');
    const driveStorage = new GoogleDriveStorage();
    await driveStorage.initialize();
    storageInstance = driveStorage;
  } else {
    logger.info('Initializing Mock Media Storage Provider (Dev Mode)');
    const mockStorage = new MockStorage();
    await mockStorage.initialize();
    storageInstance = mockStorage;
  }

  return storageInstance;
}
