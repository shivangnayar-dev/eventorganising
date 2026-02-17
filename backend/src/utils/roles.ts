import type { NextFunction, Response } from 'express';

import type { AuthenticatedRequest } from '../middleware/authMiddleware.js';
import { HttpError } from '../middleware/errorHandler.js';
import { logger } from '../config/logger.js';

export function requireRoles(...roles: string[]) {
  return (req: AuthenticatedRequest, _res: Response, next: NextFunction) => {
    const user = req.user;
    if (!user) {
      return next(new HttpError(401, 'Unauthorized'));
    }

    // Normalize roles to uppercase for comparison (Prisma enum values are uppercase)
    const normalizedRequiredRoles = roles.map((r) => r.toUpperCase());
    const normalizedUserRoles = user.roles.map((r) => (typeof r === 'string' ? r : String(r)).toUpperCase());

    const hasRole = normalizedUserRoles.some((role) => normalizedRequiredRoles.includes(role));
    if (!hasRole) {
      // Log for debugging - this is expected behavior for role-based access control
      logger.debug('Role check failed', {
        userId: user.id,
        userRoles: user.roles,
        requiredRoles: roles,
      });
      return next(new HttpError(403, 'Forbidden'));
    }

    next();
  };
}

