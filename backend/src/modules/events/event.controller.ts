import { Request, Response, NextFunction } from 'express';
import { eventService } from './event.service';
import { db } from '../database/db';

export class EventController {
  async listEvents(req: Request, res: Response, next: NextFunction) {
    try {
      const events = await eventService.listEvents();
      res.json({ success: true, data: events });
    } catch (err) {
      next(err);
    }
  }

  async getEvent(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id as string;
      const event = await eventService.getEventWithStats(id);
      if (!event) {
        return res.status(404).json({ success: false, error: 'Event not found' });
      }
      res.json({ success: true, data: event });
    } catch (err) {
      next(err);
    }
  }

  async getEventBySlug(req: Request, res: Response, next: NextFunction) {
    try {
      const slug = req.params.slug as string;
      const event = await db.getEventBySlug(slug);
      if (!event) {
        return res.status(404).json({ success: false, error: 'Event not found' });
      }
      const withStats = await eventService.getEventWithStats(event.id);
      res.json({ success: true, data: withStats });
    } catch (err) {
      next(err);
    }
  }

  async createEvent(req: Request, res: Response, next: NextFunction) {
    try {
      const created = await eventService.createEvent(req.body);
      res.status(201).json({ success: true, data: created });
    } catch (err) {
      next(err);
    }
  }

  async startEvent(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id as string;
      const updated = await eventService.startEvent(id);
      res.json({ success: true, data: updated });
    } catch (err) {
      next(err);
    }
  }

  async pauseEvent(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id as string;
      const updated = await eventService.pauseEvent(id);
      res.json({ success: true, data: updated });
    } catch (err) {
      next(err);
    }
  }

  async resumeEvent(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id as string;
      const updated = await eventService.resumeEvent(id);
      res.json({ success: true, data: updated });
    } catch (err) {
      next(err);
    }
  }

  async endEvent(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id as string;
      const updated = await eventService.endEvent(id);
      res.json({ success: true, data: updated });
    } catch (err) {
      next(err);
    }
  }

  async updateBoothSettings(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id as string;
      const updated = await eventService.updateBoothSettings(id, req.body);
      res.json({ success: true, data: updated });
    } catch (err) {
      next(err);
    }
  }
}

export const eventController = new EventController();
