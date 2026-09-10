import { Request, Response, NextFunction } from 'express';
import { uploadService } from './upload.service';
import multer from 'multer';
import { Readable } from 'stream';

// In-memory buffer or temp disk stream for uploads
const storage = multer.memoryStorage();
export const uploadMiddleware = multer({
  storage,
  limits: {
    fileSize: 500 * 1024 * 1024, // 500 MB max for video
  },
});

export class UploadController {
  async initiate(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await uploadService.initiateUpload(req.body);
      res.json({ success: true, data: result });
    } catch (err) {
      next(err);
    }
  }

  async uploadVideo(req: Request, res: Response, next: NextFunction) {
    try {
      const videoId = req.params.videoId as string;
      const file = req.file;
      if (!file) {
        return res.status(400).json({ success: false, error: 'No video file provided' });
      }

      const stream = Readable.from(file.buffer);
      const record = await uploadService.uploadVideoFile(
        videoId,
        stream,
        file.originalname,
        file.size
      );

      res.json({ success: true, data: record });
    } catch (err) {
      next(err);
    }
  }

  async uploadThumbnail(req: Request, res: Response, next: NextFunction) {
    try {
      const videoId = req.params.videoId as string;
      const file = req.file;
      if (!file) {
        return res.status(400).json({ success: false, error: 'No thumbnail file provided' });
      }

      const stream = Readable.from(file.buffer);
      const record = await uploadService.uploadThumbnailFile(
        videoId,
        stream,
        file.originalname,
        file.size
      );

      res.json({ success: true, data: record });
    } catch (err) {
      next(err);
    }
  }

  async verify(req: Request, res: Response, next: NextFunction) {
    try {
      const videoId = req.params.videoId as string;
      const result = await uploadService.verifyAndPublish(videoId);
      res.json({ success: true, data: result });
    } catch (err) {
      next(err);
    }
  }
}

export const uploadController = new UploadController();
