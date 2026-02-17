import 'dotenv/config';

const required = ['DATABASE_URL', 'JWT_SECRET'];

for (const key of required) {
  if (!process.env[key]) {
    throw new Error(`Missing environment variable ${key}`);
  }
}

const environment = (process.env.NODE_ENV ?? 'development') as 'development' | 'production' | 'test';

// Validate JWT_SECRET strength in production
if (environment === 'production' && process.env.JWT_SECRET!.length < 32) {
  throw new Error(
    'JWT_SECRET must be at least 32 characters long in production. Use a strong random string.'
  );
}

export const env = {
  environment,
  port: Number(process.env.PORT ?? 3000),
  databaseUrl: process.env.DATABASE_URL!,
  jwtSecret: process.env.JWT_SECRET!,
  jwtExpiresIn: process.env.JWT_EXPIRES_IN ?? '1d',
  // CORS configuration
  corsOrigin: process.env.CORS_ORIGIN?.split(',').map((origin) => origin.trim()) ?? ['http://localhost:3000'],
  // Rate limiting
  rateLimitWindowMs: Number(process.env.RATE_LIMIT_WINDOW_MS ?? 15 * 60 * 1000), // 15 minutes
  rateLimitMax: Number(process.env.RATE_LIMIT_MAX ?? 100), // 100 requests per window
  // Frontend URL
  frontendUrl: process.env.FRONTEND_URL ?? 'http://localhost',
};

