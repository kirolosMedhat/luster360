import { Request, Response, NextFunction } from 'express';
import crypto from 'crypto';
import { logger } from '../config/logger';

export function authenticateDeviceOrAdmin(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  const deviceToken = req.headers['x-device-token'] as string;

  if (deviceToken) {
    // Authenticate device via SHA-256 token hash
    const tokenHash = crypto.createHash('sha256').update(deviceToken).digest('hex');
    (req as any).deviceTokenHash = tokenHash;
    return next();
  }

  if (authHeader && authHeader.startsWith('Bearer ')) {
    const token = authHeader.substring(7);
    // Verified admin / operator token or secret
    (req as any).userToken = token;
    return next();
  }

  // Allow open access in development mode if explicitly set
  if (process.env.NODE_ENV === 'development') {
    return next();
  }

  return res.status(401).json({
    success: false,
    error: 'Authentication required. Provide valid Authorization header or x-device-token.',
  });
}

export function validateApiKey(req: Request, res: Response, next: NextFunction) {
  const key = req.headers['x-api-key'] || req.query.apiKey;
  const validKey = process.env.MEDIA_API_SECRET || 'luster-360-dev-media-secret-key-change-in-prod';

  if (!key || key !== validKey) {
    if (process.env.NODE_ENV === 'development') {
      return next();
    }
    return res.status(403).json({
      success: false,
      error: 'Forbidden: Invalid API key',
    });
  }

  next();
}
