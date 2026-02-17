import type { NextFunction, Request, Response } from 'express';
import jwt from 'jsonwebtoken';

import { env } from '../config/env.js';
import type { RequestUser } from '../types/index.js';
import { HttpError } from './errorHandler.js';

export interface AuthenticatedRequest extends Request {
  user?: RequestUser;
}

export function authGuard(req: AuthenticatedRequest, _res: Response, next: NextFunction) {
  const authorization = req.headers.authorization;

  if (!authorization?.startsWith('Bearer ')) {
    throw new HttpError(401, 'Unauthorized');
  }

  const token = authorization.slice(7);

  try {
    const payload = jwt.verify(token, env.jwtSecret) as RequestUser;
    req.user = payload;
    next();
  } catch (error) {
    throw new HttpError(401, 'Invalid token');
  }
}

