import type { NextFunction, Response } from 'express';
import type { PrismaClient } from '@prisma/client';

import type { AuthenticatedRequest } from '../../middleware/authMiddleware.js';
import * as adminService from './admin.service.js';

export async function dashboard(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const data = await adminService.dashboard(prisma);
    res.json(data);
  } catch (error) {
    next(error);
  }
}

export async function users(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const data = await adminService.listUsers(prisma);
    res.json(data);
  } catch (error) {
    next(error);
  }
}

export async function services(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const data = await adminService.listServices(prisma);
    res.json(data);
  } catch (error) {
    next(error);
  }
}

export async function verifications(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const data = await adminService.listVerifications(prisma);
    res.json(data);
  } catch (error) {
    next(error);
  }
}

export async function createManager(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const manager = await adminService.createManager(prisma, req.body, req.user?.id);
    res.status(201).json(manager);
  } catch (error) {
    next(error);
  }
}

export async function assignManager(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const { serviceId, managerId } = req.body as { serviceId: string; managerId: string };
    const service = await adminService.assignManager(prisma, serviceId, managerId);
    res.json(service);
  } catch (error) {
    next(error);
  }
}

// Nodal Officer Controllers
export async function createNodalOfficer(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const officer = await adminService.createNodalOfficer(prisma, req.body, req.user?.id);
    res.status(201).json(officer);
  } catch (error) {
    next(error);
  }
}

export async function listNodalOfficers(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const filters = {
      location: req.query.location as string | undefined,
      area: req.query.area as string | undefined,
      pincode: req.query.pincode as string | undefined,
    };
    const officers = await adminService.listNodalOfficers(prisma, filters);
    res.json(officers);
  } catch (error) {
    next(error);
  }
}

export async function assignOfficerToArea(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const { officerId, ...areaData } = req.body as { officerId: string; area: string; location: string; address?: string; pincode?: string; region?: string; notes?: string };
    const assignment = await adminService.assignOfficerToArea(prisma, officerId, areaData, req.user?.id);
    res.json(assignment);
  } catch (error) {
    next(error);
  }
}

export async function listRecommendations(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const status = req.query.status as 'PENDING' | 'APPROVED' | 'REJECTED' | undefined;
    const recommendations = await adminService.listRecommendations(prisma, status);
    res.json(recommendations);
  } catch (error) {
    next(error);
  }
}

export async function approveRecommendation(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const { id } = req.params as { id: string };
    const recommendation = await adminService.approveRecommendation(prisma, id, req.user?.id || '');
    res.json(recommendation);
  } catch (error) {
    next(error);
  }
}

export async function rejectRecommendation(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const { id } = req.params as { id: string };
    const { notes } = req.body as { notes?: string };
    const recommendation = await adminService.rejectRecommendation(prisma, id, req.user?.id || '', notes);
    res.json(recommendation);
  } catch (error) {
    next(error);
  }
}

// Service Category Controllers
export async function listServiceCategories(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const categories = await adminService.listServiceCategories(prisma);
    res.json(categories);
  } catch (error) {
    next(error);
  }
}

export async function createServiceCategory(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const category = await adminService.createServiceCategory(prisma, req.body);
    res.status(201).json(category);
  } catch (error) {
    next(error);
  }
}

export async function updateServiceCategory(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const { id } = req.params as { id: string };
    const category = await adminService.updateServiceCategory(prisma, id, req.body);
    res.json(category);
  } catch (error) {
    next(error);
  }
}

export async function deleteServiceCategory(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const { id } = req.params as { id: string };
    await adminService.deleteServiceCategory(prisma, id);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
}

