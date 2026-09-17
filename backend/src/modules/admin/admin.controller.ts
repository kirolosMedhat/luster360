import { Request, Response, NextFunction } from 'express';
import { adminService } from './admin.service';

export class AdminController {
  async getSummary(req: Request, res: Response, next: NextFunction) {
    try {
      const data = await adminService.getSummary();
      res.json({ success: true, data });
    } catch (err) {
      next(err);
    }
  }

  async getAnalytics(req: Request, res: Response, next: NextFunction) {
    try {
      const data = await adminService.getAnalytics();
      res.json({ success: true, data });
    } catch (err) {
      next(err);
    }
  }

  async getEventDrilldown(req: Request, res: Response, next: NextFunction) {
    try {
      const eventId = String(req.params.id);
      const data = await adminService.getEventDrilldown(eventId);
      res.json({ success: true, data });
    } catch (err) {
      next(err);
    }
  }

  async getStorageStatus(req: Request, res: Response, next: NextFunction) {
    try {
      const data = await adminService.getStorageStatus();
      res.json({ success: true, data });
    } catch (err) {
      next(err);
    }
  }

  async deauthorizeDevice(req: Request, res: Response, next: NextFunction) {
    try {
      const deviceId = String(req.params.id);
      const data = await adminService.deauthorizeDevice(deviceId);
      res.json({ success: true, data });
    } catch (err) {
      next(err);
    }
  }
}

export const adminController = new AdminController();
