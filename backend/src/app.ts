import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import { apiRouter } from './routes/api.router';
import { errorHandler } from './middleware/error.middleware';
import { config } from './config/env';

export const app = express();

// Security and middleware
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'x-device-token', 'x-api-key', 'Range', 'x-gallery-password'],
  exposedHeaders: ['Content-Range', 'Accept-Ranges', 'Content-Length', 'Content-Disposition'],
}));

app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

if (config.nodeEnv !== 'test') {
  app.use(morgan('combined'));
}

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'luster-media-api', timestamp: new Date().toISOString() });
});

// API Routes
app.use(config.apiPrefix, apiRouter);

// Global Error Handler
app.use(errorHandler);
