import { PrismaClient } from '@prisma/client';

import app from './app.js';
import { env } from './config/env.js';
import { logger } from './config/logger.js';

// Configure Prisma for production
// Prisma automatically handles connection pooling via DATABASE_URL parameters
// Recommended: Add ?connection_limit=20&pool_timeout=20 to DATABASE_URL for production
const prisma = new PrismaClient({
  log: env.environment === 'development' 
    ? ['query', 'info', 'warn', 'error']
    : ['error'],
  errorFormat: env.environment === 'production' ? 'minimal' : 'pretty',
  // Connection pooling is handled via DATABASE_URL query parameters
  // Example: postgresql://user:pass@host:5432/db?connection_limit=20&pool_timeout=20
});

// Graceful shutdown handler
const gracefulShutdown = async (signal: string) => {
  logger.info(`${signal} received. Starting graceful shutdown...`);
  
  try {
    await prisma.$disconnect();
    logger.info('Database connection closed');
    process.exit(0);
  } catch (error) {
    logger.error('Error during shutdown', error);
    process.exit(1);
  }
};

// Handle process signals
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// Handle uncaught errors
process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
  // Don't exit in production, just log
  if (env.environment === 'development') {
    process.exit(1);
  }
});

process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception:', error);
  process.exit(1);
});

async function start() {
  try {
    // Test database connection
    await prisma.$connect();
    logger.info('Database connected successfully');
    
    app.locals.prisma = prisma;

    const server = app.listen(env.port, '0.0.0.0', () => {
      logger.info(`🚀 Server running on port ${env.port} in ${env.environment} mode`);
      logger.info(`📡 Environment: ${env.environment}`);
      logger.info(`🔒 CORS origins: ${env.corsOrigin.join(', ')}`);
    });

    // Handle server errors
    server.on('error', (error: NodeJS.ErrnoException) => {
      if (error.syscall !== 'listen') {
        throw error;
      }

      const bind = typeof env.port === 'string' ? `Pipe ${env.port}` : `Port ${env.port}`;

      switch (error.code) {
        case 'EACCES':
          logger.error(`${bind} requires elevated privileges`);
          process.exit(1);
          break;
        case 'EADDRINUSE':
          logger.error(`${bind} is already in use`);
          process.exit(1);
          break;
        default:
          throw error;
      }
    });
  } catch (error) {
    logger.error('Failed to start server', error);
    process.exit(1);
  }
}

start();

