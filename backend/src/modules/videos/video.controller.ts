import { Request, Response, NextFunction } from 'express';
import { videoService } from './video.service';

export class VideoController {
  async resolveByCode(req: Request, res: Response, next: NextFunction) {
    try {
      const shortCode = req.params.shortCode as string;
      const video = await videoService.getVideoByShortCode(shortCode);
      if (!video) {
        return res.status(404).json({ success: false, error: 'Video not found' });
      }
      res.json({ success: true, data: video });
    } catch (err) {
      next(err);
    }
  }

  async streamVideo(req: Request, res: Response, next: NextFunction) {
    try {
      const shortCode = req.params.shortCode as string;
      const range = req.headers.range;

      const media = await videoService.getStreamForVideo(shortCode, range);

      res.setHeader('Content-Type', media.contentType);
      if (media.acceptRanges) {
        res.setHeader('Accept-Ranges', media.acceptRanges);
      }
      if (media.contentLength) {
        res.setHeader('Content-Length', media.contentLength.toString());
      }
      if (media.contentRange) {
        res.setHeader('Content-Range', media.contentRange);
        res.status(206); // Partial Content
      } else {
        res.status(200);
      }

      media.stream.pipe(res);
    } catch (err) {
      next(err);
    }
  }

  async downloadVideo(req: Request, res: Response, next: NextFunction) {
    try {
      const shortCode = req.params.shortCode as string;
      const media = await videoService.getDownloadForVideo(shortCode);

      res.setHeader('Content-Disposition', `attachment; filename="${media.filename}"`);
      res.setHeader('Content-Type', media.contentType || 'video/mp4');
      if (media.contentLength) {
        res.setHeader('Content-Length', media.contentLength.toString());
      }

      media.stream.pipe(res);
    } catch (err) {
      next(err);
    }
  }

  async thumbnail(req: Request, res: Response, next: NextFunction) {
    try {
      const shortCode = req.params.shortCode as string;
      const media = await videoService.getThumbnailForVideo(shortCode);

      res.setHeader('Content-Type', media.contentType || 'image/jpeg');
      if (media.contentLength) {
        res.setHeader('Content-Length', media.contentLength.toString());
      }

      media.stream.pipe(res);
    } catch (err) {
      next(err);
    }
  }
}

export const videoController = new VideoController();
