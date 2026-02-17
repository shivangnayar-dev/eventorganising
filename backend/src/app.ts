import express from 'express';
import compression from 'compression';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';

import { env } from './config/env.js';
import { logger } from './config/logger.js';
import { errorHandler } from './middleware/errorHandler.js';
import { apiLimiter, authLimiter } from './middleware/rateLimiter.js';
import authRoutes from './modules/auth/auth.routes.js';
import serviceRoutes from './modules/service/service.routes.js';
import verificationRoutes from './modules/verification/verification.routes.js';
import bookingRoutes from './modules/booking/booking.routes.js';
import adminRoutes from './modules/admin/admin.routes.js';

const app = express();

// Security middleware
app.use(helmet({
  contentSecurityPolicy: env.environment === 'production',
  crossOriginEmbedderPolicy: env.environment === 'production',
}));

// Compression middleware
app.use(compression());

// CORS configuration - more secure for production
app.use(
  cors({
    origin: (origin, callback) => {
      // Allow requests with no origin (mobile apps, Postman, etc.)
      if (!origin) return callback(null, true);

      // In development, allow all origins for convenience
      if (env.environment === 'development') {
        return callback(null, true);
      }

      // In production, only allow configured origins
      if (env.corsOrigin.includes(origin)) {
        callback(null, true);
      } else {
        logger.warn(`CORS blocked origin: ${origin}`);
        callback(new Error('Not allowed by CORS'));
      }
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  })
);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging middleware
if (env.environment === 'production') {
  app.use(morgan('combined', {
    stream: {
      write: (message: string) => logger.info(message.trim()),
    },
  }));
} else {
  app.use(morgan('dev'));
}

// Apply rate limiting to all routes
app.use(apiLimiter);

// Enhanced health check endpoint
app.get('/health', async (_req, res) => {
  try {
    const prisma = app.locals.prisma;
    
    if (!prisma) {
      return res.status(503).json({
        status: 'error',
        timestamp: new Date().toISOString(),
        database: 'not_initialized',
      });
    }
    
    // Check database connection (MongoDB compatible)
    await prisma.$runCommandRaw({ ping: 1 });
    
    res.json({
      status: 'ok',
      timestamp: new Date().toISOString(),
      environment: env.environment,
      database: 'connected',
    });
  } catch (error) {
    logger.error('Health check failed', error);
    res.status(503).json({
      status: 'error',
      timestamp: new Date().toISOString(),
      database: 'disconnected',
    });
  }
});

// Auth routes with stricter rate limiting
app.use('/auth', authLimiter, authRoutes);
app.use('/service', serviceRoutes);
app.use('/service', verificationRoutes);
app.use('/booking', bookingRoutes);
app.use('/admin', adminRoutes);

app.use(errorHandler);

export default app;

