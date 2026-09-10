import { Request, Response, NextFunction } from 'express';
import { getStorageProvider } from '../storage/storage-factory';

export class SystemController {
  async health(req: Request, res: Response, next: NextFunction) {
    try {
      const storage = await getStorageProvider();
      const storageHealth = await storage.healthCheck();

      res.json({
        success: true,
        data: {
          status: 'HEALTHY',
          version: '1.0.0',
          uptimeSeconds: Math.floor(process.uptime()),
          timestamp: new Date().toISOString(),
          storage: storageHealth,
        },
      });
    } catch (err) {
      next(err);
    }
  }
}

export const systemController = new SystemController();
