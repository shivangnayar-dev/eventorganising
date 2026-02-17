import type { NextFunction, Request, Response } from 'express';

import { logger } from '../config/logger.js';

export function errorHandler(
  error: unknown,
  _req: Request,
  res: Response,
  _next: NextFunction,
) {
  if (error instanceof HttpError) {
    // Don't log 403/401 errors as errors - they're expected for role-based access control
    if (error.statusCode === 403 || error.statusCode === 401) {
      logger.debug('Access denied', {
        statusCode: error.statusCode,
        message: error.message,
      });
    } else {
      logger.error('HTTP error', error);
    }
    return res.status(error.statusCode).json({ message: error.message });
  }

  logger.error('Unhandled error', error);
  return res.status(500).json({ message: 'Internal server error' });
}

export class HttpError extends Error {
  constructor(public statusCode: number, message: string) {
    super(message);
  }
}

