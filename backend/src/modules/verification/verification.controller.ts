import type { NextFunction, Response } from 'express';
import type { PrismaClient } from '@prisma/client';

import type { AuthenticatedRequest } from '../../middleware/authMiddleware.js';
import { HttpError } from '../../middleware/errorHandler.js';
import * as serviceService from '../service/service.service.js';

export async function getAssignments(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) {
      throw new HttpError(401, 'Unauthorized');
    }
    const prisma = req.app.locals.prisma as PrismaClient;
    const assignments = await serviceService.listAssignments(prisma, req.user.id);
    res.json(assignments);
  } catch (error) {
    next(error);
  }
}

export async function verify(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const { assignmentId, decision, notes } = req.body as {
      assignmentId: string;
      decision: 'APPROVED' | 'REJECTED' | 'INFO_REQUESTED';
      notes?: string;
    };
    await serviceService.verifyService(prisma, assignmentId, decision, notes);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
}

