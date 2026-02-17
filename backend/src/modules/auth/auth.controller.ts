import type { NextFunction, Request, Response } from 'express';
import type { PrismaClient } from '@prisma/client';

import * as authService from './auth.service.js';
import {
  deleteRefreshToken,
  findRefreshToken,
  generateRefreshToken,
  createRefreshToken,
} from './refreshToken.service.js';
import { signToken } from '../../utils/jwt.js';
import { HttpError } from '../../middleware/errorHandler.js';

function getDeviceInfo(req: Request) {
  return {
    deviceId: req.headers['x-device-id'] as string | undefined,
    ipAddress: req.ip || req.socket.remoteAddress,
    userAgent: req.headers['user-agent'],
  };
}

export async function register(req: Request, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const deviceInfo = getDeviceInfo(req);
    const result = await authService.register(prisma, {
      ...req.body,
      ...deviceInfo,
    });
    res.status(201).json(result);
  } catch (error) {
    next(error);
  }
}

export async function login(req: Request, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const deviceInfo = getDeviceInfo(req);
    const result = await authService.login(prisma, {
      ...req.body,
      ...deviceInfo,
    });
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function refresh(req: Request, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const { refreshToken } = req.body;

    if (!refreshToken) {
      throw new HttpError(400, 'Refresh token is required');
    }

    // Find and validate refresh token
    const dbToken = await findRefreshToken(prisma, refreshToken);
    if (!dbToken) {
      throw new HttpError(401, 'Invalid or expired refresh token');
    }

    // Check if token is expired
    if (dbToken.expiresAt < new Date()) {
      throw new HttpError(401, 'Refresh token has expired');
    }

    // Generate new access token
    const payload = {
      id: dbToken.user.id,
      email: dbToken.user.email,
      roles: dbToken.user.roles.map((role) => role.role),
    };
    const accessToken = signToken(payload);

    // Optionally rotate refresh token (generate new one and delete old)
    // For now, we'll keep the same refresh token
    // In production, consider rotating for better security

    res.json({
      accessToken,
      expiresIn: process.env.JWT_EXPIRES_IN || '1d',
    });
  } catch (error) {
    next(error);
  }
}

export async function logout(req: Request, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const { refreshToken } = req.body;

    if (refreshToken) {
      await deleteRefreshToken(prisma, refreshToken);
    }

    res.json({ message: 'Logged out successfully' });
  } catch (error) {
    next(error);
  }
}

