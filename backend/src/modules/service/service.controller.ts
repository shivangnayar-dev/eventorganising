import type { NextFunction, Request, Response } from 'express';
import type { PrismaClient } from '@prisma/client';

import type { AuthenticatedRequest } from '../../middleware/authMiddleware.js';
import { HttpError } from '../../middleware/errorHandler.js';
import * as serviceService from './service.service.js';

export async function createService(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) {
      throw new HttpError(401, 'Unauthorized');
    }
    const prisma = req.app.locals.prisma as PrismaClient;
    const service = await serviceService.createService(prisma, req.user.id, req.body);
    res.status(201).json(service);
  } catch (error) {
    next(error);
  }
}

export async function listMyServices(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) {
      throw new HttpError(401, 'Unauthorized');
    }
    const prisma = req.app.locals.prisma as PrismaClient;
    
    // Check if user is a nodal officer (roles are strings in JWT payload)
    const isNodalOfficer = req.user.roles.includes('NODAL_OFFICER');
    
    if (isNodalOfficer) {
      // Return services assigned to this nodal officer
      const services = await serviceService.listNodalOfficerServices(prisma, req.user.id);
      res.json(services);
    } else {
      // Return services owned by this user
      const services = await serviceService.listUserServices(prisma, req.user.id);
      res.json(services);
    }
  } catch (error) {
    next(error);
  }
}

export async function listPending(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const services = await serviceService.listPending(prisma);
    res.json(services);
  } catch (error) {
    next(error);
  }
}

export async function listPublished(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const services = await serviceService.listPublished(prisma);
    res.json(services);
  } catch (error) {
    next(error);
  }
}

export async function listManagedServices(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) {
      throw new HttpError(401, 'Unauthorized');
    }
    const prisma = req.app.locals.prisma as PrismaClient;
    const services = await serviceService.listManagedServices(prisma, req.user.id);
    res.json(services);
  } catch (error) {
    next(error);
  }
}

export async function listPublishedPublic(_req: Request, res: Response, next: NextFunction) {
  try {
    const prisma = res.app.locals.prisma as PrismaClient;
    const services = await serviceService.listPublished(prisma);
    res.json(services);
  } catch (error) {
    next(error);
  }
}

export async function assignAgents(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) {
      throw new HttpError(401, 'Unauthorized');
    }
    const prisma = req.app.locals.prisma as PrismaClient;
    const { serviceId, agentIds, nodalOfficerId } = req.body as {
      serviceId: string;
      agentIds: string[];
      nodalOfficerId?: string;
    };
    const result = await serviceService.assignAgents(
      prisma,
      req.user.id,
      serviceId,
      agentIds,
      nodalOfficerId,
    );
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function getAvailableNodalOfficersForService(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction,
) {
  try {
    if (!req.user) {
      throw new HttpError(401, 'Unauthorized');
    }
    const prisma = req.app.locals.prisma as PrismaClient;
    const { serviceId } = req.params as { serviceId: string };

    const service = await prisma.serviceListing.findUnique({
      where: { id: serviceId },
    });

    if (!service) {
      throw new HttpError(404, 'Service not found');
    }

    const officers = await serviceService.findNodalOfficersByServiceLocation(
      prisma,
      service.location,
      service.pincode,
    );

    res.json({
      availableOfficers: officers,
      needsRecommendation: officers.length === 0,
      serviceLocation: service.location,
      servicePincode: service.pincode,
    });
  } catch (error) {
    next(error);
  }
}

export async function onboardProvider(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) {
      throw new HttpError(401, 'Unauthorized');
    }

    const prisma = req.app.locals.prisma as PrismaClient;
    const provider = await serviceService.onboardProvider(prisma, req.user.id, req.body);
    res.status(200).json(provider);
  } catch (error) {
    next(error);
  }
}

export async function listProviders(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const providers = await serviceService.listProviders(prisma);
    res.json(providers);
  } catch (error) {
    next(error);
  }
}

// Nodal Officer Controllers for Managers
export async function listNodalOfficersByArea(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) {
      throw new HttpError(401, 'Unauthorized');
    }
    const prisma = req.app.locals.prisma as PrismaClient;
    const filters = {
      location: req.query.location as string | undefined,
      area: req.query.area as string | undefined,
      pincode: req.query.pincode as string | undefined,
    };
    const officers = await serviceService.listNodalOfficersByArea(prisma, req.user.id, filters);
    res.json(officers);
  } catch (error) {
    next(error);
  }
}

export async function recommendNodalOfficer(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) {
      throw new HttpError(401, 'Unauthorized');
    }
    const prisma = req.app.locals.prisma as PrismaClient;
    const recommendation = await serviceService.recommendNodalOfficer(prisma, req.user.id, req.body);
    res.status(201).json(recommendation);
  } catch (error) {
    next(error);
  }
}

export async function listManagerRecommendations(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) {
      throw new HttpError(401, 'Unauthorized');
    }
    const prisma = req.app.locals.prisma as PrismaClient;
    const recommendations = await serviceService.listManagerRecommendations(prisma, req.user.id);
    res.json(recommendations);
  } catch (error) {
    next(error);
  }
}

export async function getManagerAssignment(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) {
      throw new HttpError(401, 'Unauthorized');
    }
    const prisma = req.app.locals.prisma as PrismaClient;
    const assignment = await serviceService.getManagerAssignment(prisma, req.user.id);
    if (!assignment) {
      return res.status(404).json({ error: 'Manager assignment not found' });
    }
    res.json(assignment);
  } catch (error) {
    next(error);
  }
}

// Public endpoint for navbar service categories
export async function listNavbarServiceCategories(req: Request, res: Response, next: NextFunction) {
  try {
    const prisma = req.app.locals.prisma as PrismaClient;
    const categories = await serviceService.listNavbarServiceCategories(prisma);
    res.json(categories);
  } catch (error) {
    next(error);
  }
}

// Assign nodal officer directly (without providers)
export async function assignNodalOfficer(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) {
      throw new HttpError(401, 'Unauthorized');
    }
    const prisma = req.app.locals.prisma as PrismaClient;
    const { serviceId, nodalOfficerId } = req.body as {
      serviceId: string;
      nodalOfficerId: string;
    };
    const result = await serviceService.assignNodalOfficer(
      prisma,
      req.user.id,
      serviceId,
      nodalOfficerId,
    );
    res.json(result);
  } catch (error) {
    next(error);
  }
}

