import type { PrismaClient } from '@prisma/client';
import crypto from 'crypto';

import { env } from '../../config/env.js';
import { HttpError } from '../../middleware/errorHandler.js';
import { hashPassword } from '../../utils/password.js';

const REFRESH_TOKEN_EXPIRY_DAYS = 7; // 7 days
const REFRESH_TOKEN_LENGTH = 64; // 64 bytes = 128 hex characters

/**
 * Generate a secure random refresh token
 */
export function generateRefreshToken(): string {
  return crypto.randomBytes(REFRESH_TOKEN_LENGTH).toString('hex');
}

/**
 * Hash a refresh token before storing in database
 */
async function hashRefreshToken(token: string): Promise<string> {
  // Use the same hashing function as passwords for consistency
  return hashPassword(token);
}

/**
 * Create a new refresh token for a user
 */
export async function createRefreshToken(
  prisma: PrismaClient,
  userId: string,
  token: string,
  options?: {
    deviceId?: string;
    ipAddress?: string;
    userAgent?: string;
  }
) {
  const hashedToken = await hashRefreshToken(token);
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + REFRESH_TOKEN_EXPIRY_DAYS);

  return prisma.refreshToken.create({
    data: {
      userId,
      token: hashedToken,
      deviceId: options?.deviceId,
      ipAddress: options?.ipAddress,
      userAgent: options?.userAgent,
      expiresAt,
    },
  });
}

/**
 * Find and validate a refresh token
 * Note: This implementation hashes the token for security
 * For better performance in production, consider using a lookup key
 */
export async function findRefreshToken(
  prisma: PrismaClient,
  token: string
) {
  // Hash the input token to compare with stored hashes
  const hashedInput = await hashRefreshToken(token);
  
  // Find the token by its hash
  const dbToken = await prisma.refreshToken.findUnique({
    where: { token: hashedInput },
    include: {
      user: {
        include: {
          roles: true,
        },
      },
    },
  });

  if (!dbToken) {
    return null;
  }

  // Check if token is expired
  if (dbToken.expiresAt < new Date()) {
    // Delete expired token
    await prisma.refreshToken.delete({
      where: { id: dbToken.id },
    });
    return null;
  }

  // Update lastUsedAt
  await prisma.refreshToken.update({
    where: { id: dbToken.id },
    data: { lastUsedAt: new Date() },
  });

  return dbToken;
}

/**
 * Delete a refresh token (logout)
 */
export async function deleteRefreshToken(
  prisma: PrismaClient,
  token: string
) {
  const hashedToken = await hashRefreshToken(token);
  try {
    await prisma.refreshToken.delete({
      where: { token: hashedToken },
    });
  } catch (error) {
    // Token not found - that's okay, just return
    return;
  }
}

/**
 * Delete all refresh tokens for a user (logout all devices)
 */
export async function deleteAllUserRefreshTokens(
  prisma: PrismaClient,
  userId: string
) {
  return prisma.refreshToken.deleteMany({
    where: { userId },
  });
}

/**
 * Clean up expired refresh tokens
 */
export async function cleanupExpiredTokens(prisma: PrismaClient) {
  const now = new Date();
  return prisma.refreshToken.deleteMany({
    where: {
      expiresAt: {
        lt: now,
      },
    },
  });
}

