import { Request, Response, NextFunction } from 'express';
import { galleryService } from './gallery.service';

export class GalleryController {
  async getGallery(req: Request, res: Response, next: NextFunction) {
    try {
      const slug = req.params.slug as string;
      const password = (req.query.password || req.headers['x-gallery-password']) as string | undefined;

      const result = await galleryService.getPublicGallery(slug, password);
      if (!result.found) {
        return res.status(404).json({ success: false, error: result.error });
      }

      if (result.requiresPassword) {
        return res.status(401).json({
          success: false,
          requiresPassword: true,
          error: result.error || 'Password required to view this gallery',
          event: result.event,
        });
      }

      if (result.isExpired) {
        return res.status(410).json({
          success: false,
          isExpired: true,
          error: result.error,
          event: result.event,
        });
      }

      res.json({ success: true, data: result });
    } catch (err) {
      next(err);
    }
  }
}

export const galleryController = new GalleryController();
