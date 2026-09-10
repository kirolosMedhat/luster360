import { Router } from 'express';
import { eventController } from '../modules/events/event.controller';
import { uploadController, uploadMiddleware } from '../modules/uploads/upload.controller';
import { videoController } from '../modules/videos/video.controller';
import { deviceController } from '../modules/devices/device.controller';
import { galleryController } from '../modules/galleries/gallery.controller';
import { systemController } from '../modules/system/system.controller';
import { authController } from '../modules/auth/auth.controller';
import { authenticateDeviceOrAdmin } from '../middleware/auth.middleware';

export const apiRouter = Router();

// ==========================================
// SYSTEM & STORAGE HEALTH
// ==========================================
apiRouter.get('/system/health', (req, res, next) => systemController.health(req, res, next));

// ==========================================
// EVENTS & OPERATIONS
// ==========================================
apiRouter.get('/events', (req, res, next) => eventController.listEvents(req, res, next));
apiRouter.get('/events/:id', (req, res, next) => eventController.getEvent(req, res, next));
apiRouter.get('/events/by-slug/:slug', (req, res, next) => eventController.getEventBySlug(req, res, next));
apiRouter.post('/events', authenticateDeviceOrAdmin, (req, res, next) => eventController.createEvent(req, res, next));
apiRouter.post('/events/:id/start', authenticateDeviceOrAdmin, (req, res, next) => eventController.startEvent(req, res, next));
apiRouter.post('/events/:id/pause', authenticateDeviceOrAdmin, (req, res, next) => eventController.pauseEvent(req, res, next));
apiRouter.post('/events/:id/resume', authenticateDeviceOrAdmin, (req, res, next) => eventController.resumeEvent(req, res, next));
apiRouter.post('/events/:id/end', authenticateDeviceOrAdmin, (req, res, next) => eventController.endEvent(req, res, next));

// ==========================================
// UPLOADS & IDEMPOTENCY
// ==========================================
apiRouter.post('/uploads/initiate', authenticateDeviceOrAdmin, (req, res, next) => uploadController.initiate(req, res, next));
apiRouter.post('/uploads/:videoId/video', authenticateDeviceOrAdmin, uploadMiddleware.single('video'), (req, res, next) => uploadController.uploadVideo(req, res, next));
apiRouter.post('/uploads/:videoId/thumbnail', authenticateDeviceOrAdmin, uploadMiddleware.single('thumbnail'), (req, res, next) => uploadController.uploadThumbnail(req, res, next));
apiRouter.post('/uploads/:videoId/verify', authenticateDeviceOrAdmin, (req, res, next) => uploadController.verify(req, res, next));

// ==========================================
// MEDIA STREAMING & DOWNLOADS (CUSTOMER FACING)
// ==========================================
apiRouter.get('/media/stream/:shortCode', (req, res, next) => videoController.streamVideo(req, res, next));
apiRouter.get('/media/download/:shortCode', (req, res, next) => videoController.downloadVideo(req, res, next));
apiRouter.get('/media/thumbnail/:shortCode', (req, res, next) => videoController.thumbnail(req, res, next));
apiRouter.get('/videos/resolve/:shortCode', (req, res, next) => videoController.resolveByCode(req, res, next));

// ==========================================
// DEVICES & TELEMETRY
// ==========================================
apiRouter.post('/devices/register', (req, res, next) => deviceController.register(req, res, next));
apiRouter.post('/devices/heartbeat', (req, res, next) => deviceController.heartbeat(req, res, next));
apiRouter.post('/devices/disconnect', (req, res, next) => deviceController.disconnect(req, res, next));
apiRouter.get('/devices/fleet', (req, res, next) => deviceController.getFleet(req, res, next));

// ==========================================
// OPERATOR AUTHENTICATION & USER MANAGEMENT
// ==========================================
apiRouter.post('/auth/login', (req, res, next) => authController.login(req, res, next));
apiRouter.get('/auth/users', (req, res, next) => authController.listUsers(req, res, next));
apiRouter.post('/auth/users', (req, res, next) => authController.createUser(req, res, next));
apiRouter.delete('/auth/users/:id', (req, res, next) => authController.deleteUser(req, res, next));

// ==========================================
// PUBLIC GALLERIES (CUSTOMER FACING)
// ==========================================
apiRouter.get('/galleries/:slug', (req, res, next) => galleryController.getGallery(req, res, next));
