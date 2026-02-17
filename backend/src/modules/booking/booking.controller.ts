import type { NextFunction, Response } from 'express';
import type { PrismaClient } from '@prisma/client';

import type { AuthenticatedRequest } from '../../middleware/authMiddleware.js';
import { HttpError } from '../../middleware/errorHandler.js';
import * as bookingService from './booking.service.js';

export async function createBooking(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) {
      throw new HttpError(401, 'Unauthorized');
    }

    const prisma = req.app.locals.prisma as PrismaClient;
    const booking = await bookingService.createBooking(prisma, req.user.id, req.body);
    res.status(201).json(booking);
  } catch (error) {
    next(error);
  }
}

