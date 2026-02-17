import rateLimit from 'express-rate-limit';
import { env } from '../config/env.js';
import { logger } from '../config/logger.js';

// General API rate limiter
export const apiLimiter = rateLimit({
  windowMs: env.rateLimitWindowMs,
  max: env.rateLimitMax,
  message: {
    error: 'Too many requests from this IP, please try again later.',
  },
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    logger.warn(`Rate limit exceeded for IP: ${req.ip}`);
    res.status(429).json({
      error: 'Too many requests from this IP, please try again later.',
    });
  },
});

// Stricter rate limiter for authentication endpoints
export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 requests per window
  message: {
    error: 'Too many login attempts, please try again later.',
  },
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    logger.warn(`Auth rate limit exceeded for IP: ${req.ip}`);
    res.status(429).json({
      error: 'Too many login attempts, please try again later.',
    });
  },
  skipSuccessfulRequests: true, // Don't count successful requests
});

// More lenient limiter for admin endpoints (higher limit)
export const adminLimiter = rateLimit({
  windowMs: env.rateLimitWindowMs,
  max: env.rateLimitMax * 2, // Higher limit for admin
  standardHeaders: true,
  legacyHeaders: false,
});





