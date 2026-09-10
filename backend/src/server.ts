import { app } from './app';
import { config } from './config/env';
import { logger } from './config/logger';
import { getStorageProvider } from './modules/storage/storage-factory';

async function bootstrap() {
  try {
    // Initialize storage provider (Google Drive or Mock)
    const storage = await getStorageProvider();
    logger.info(`MediaStorage initialized: ${storage.providerName}`);

    const server = app.listen(config.port, () => {
      logger.info(`LUSTER Media API server listening on port ${config.port} (${config.nodeEnv})`);
      logger.info(`Public Gallery URL configured: ${config.publicGalleryUrl}`);
      logger.info(`API endpoints available at http://localhost:${config.port}${config.apiPrefix}`);
    });

    const shutdown = () => {
      logger.info('Shutting down server gracefully...');
      server.close(() => {
        logger.info('Server closed.');
        process.exit(0);
      });
    };

    process.on('SIGINT', shutdown);
    process.on('SIGTERM', shutdown);
  } catch (err: any) {
    logger.error('Failed to bootstrap Luster Media API server', { error: err.message, stack: err.stack });
    process.exit(1);
  }
}

bootstrap();
