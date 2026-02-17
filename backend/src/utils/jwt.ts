import jwt from 'jsonwebtoken';

import { env } from '../config/env.js';
import type { RequestUser } from '../types/index.js';

export function signToken(payload: RequestUser): string {
  return jwt.sign(
    payload as object,
    env.jwtSecret,
    { expiresIn: env.jwtExpiresIn } as jwt.SignOptions
  );
}

