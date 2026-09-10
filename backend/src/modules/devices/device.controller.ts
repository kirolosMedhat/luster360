import { Request, Response, NextFunction } from 'express';
import { deviceService } from './device.service';

export class DeviceController {
  async register(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await deviceService.registerDevice(req.body);
      res.status(201).json({ success: true, data: result });
    } catch (err) {
      next(err);
    }
  }

  async heartbeat(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await deviceService.recordHeartbeat(req.body);
      res.json({ success: true, data: result });
    } catch (err) {
      next(err);
    }
  }

  async getFleet(req: Request, res: Response, next: NextFunction) {
    try {
      const fleet = await deviceService.getFleetStatus();
      res.json({ success: true, data: fleet });
    } catch (err) {
      next(err);
    }
  }

  async disconnect(req: Request, res: Response, next: NextFunction) {
    try {
      const { deviceId } = req.body;
      const result = await deviceService.disconnectDevice(deviceId);
      res.json({ success: true, data: result });
    } catch (err) {
      next(err);
    }
  }
}

export const deviceController = new DeviceController();
