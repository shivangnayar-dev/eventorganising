import type { PrismaClient, User } from '@prisma/client';

import { env } from '../../config/env.js';
import { HttpError } from '../../middleware/errorHandler.js';
import {
  createRefreshToken,
  generateRefreshToken,
} from './refreshToken.service.js';
import { signToken } from '../../utils/jwt.js';
import { hashPassword, verifyPassword } from '../../utils/password.js';

export async function register(
  prisma: PrismaClient,
  data: {
    email: string;
    password: string;
    fullName: string;
    phone?: string;
    role?: 'USER' | 'PROVIDER';
    deviceId?: string;
    ipAddress?: string;
    userAgent?: string;
  }
) {
  const exists = await prisma.user.findUnique({ where: { email: data.email } });
  if (exists) {
    throw new HttpError(409, 'Email already registered');
  }

  const passwordHash = await hashPassword(data.password);
  const role = data.role || 'USER';

  const user = await prisma.user.create({
    data: {
      email: data.email,
      passwordHash,
      fullName: data.fullName,
      phone: data.phone,
      roles: {
        create: [{ role: role as 'USER' | 'PROVIDER' }],
      },
    },
    include: { roles: true },
  });

  // Generate refresh token
  const refreshToken = generateRefreshToken();
  await createRefreshToken(prisma, user.id, refreshToken, {
    deviceId: data.deviceId,
    ipAddress: data.ipAddress,
    userAgent: data.userAgent,
  });

  return buildAuthResponse(user, refreshToken);
}

export async function login(
  prisma: PrismaClient,
  data: {
    email: string;
    password: string;
    deviceId?: string;
    ipAddress?: string;
    userAgent?: string;
  }
) {
  const user = await prisma.user.findUnique({
    where: { email: data.email },
    include: { roles: true },
  });

  if (!user) {
    throw new HttpError(401, 'Invalid credentials');
  }

  const valid = await verifyPassword(user.passwordHash, data.password);
  if (!valid) {
    throw new HttpError(401, 'Invalid credentials');
  }

  // Generate refresh token
  const refreshToken = generateRefreshToken();
  await createRefreshToken(prisma, user.id, refreshToken, {
    deviceId: data.deviceId,
    ipAddress: data.ipAddress,
    userAgent: data.userAgent,
  });

  return buildAuthResponse(user, refreshToken);
}

function buildAuthResponse(
  user: User & { roles: { role: string }[] },
  refreshToken: string
) {
  const payload = {
    id: user.id,
    email: user.email,
    roles: user.roles.map((role) => role.role),
  };

  const accessToken = signToken(payload);

  return {
    accessToken,
    refreshToken,
    expiresIn: env.jwtExpiresIn,
    refreshTokenExpiresIn: '7d', // 7 days
    user: {
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      phone: user.phone,
      roles: user.roles.map((role) => ({ role: role.role })),
      createdAt: user.createdAt,
    },
  };
}

