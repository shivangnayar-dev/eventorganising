import type { PrismaClient } from '@prisma/client';

import { HttpError } from '../../middleware/errorHandler.js';
import { hashPassword } from '../../utils/password.js';

export async function dashboard(prisma: PrismaClient) {
  const [totalUsers, totalServices, totalBookings, verificationPending] = await Promise.all([
    prisma.user.count(),
    prisma.serviceListing.count(),
    prisma.booking.count(),
    prisma.serviceListing.count({ where: { status: 'PENDING' } }),
  ]);

  return { totalUsers, totalServices, totalBookings, verificationPending };
}

export function listUsers(prisma: PrismaClient) {
  return prisma.user.findMany({ include: { roles: true } });
}

export function listServices(prisma: PrismaClient) {
  return prisma.serviceListing.findMany({
    include: { assignedManager: { include: { roles: true } } },
  });
}

export function listVerifications(prisma: PrismaClient) {
  return prisma.verificationAssignment.findMany({ include: { service: true } });
}

export async function createManager(
  prisma: PrismaClient,
  data: {
    email: string;
    fullName: string;
    password: string;
    phone?: string;
    area: string;
    location: string;
    address?: string;
    pincode?: string;
    region?: string;
    notes?: string;
  },
  assignedBy?: string,
) {
  const exists = await prisma.user.findUnique({ where: { email: data.email } });
  if (exists) {
    throw new HttpError(409, 'Email already registered');
  }

  const passwordHash = await hashPassword(data.password);

  // Create user with MANAGER role
  const user = await prisma.user.create({
    data: {
      email: data.email,
      fullName: data.fullName,
      passwordHash,
      phone: data.phone,
      roles: {
        create: [{ role: 'MANAGER' }],
      },
    },
    include: { roles: true },
  });

  // Assign manager to area
  await prisma.managerAssignment.create({
    data: {
      managerId: user.id,
      area: data.area,
      location: data.location,
      address: data.address,
      pincode: data.pincode,
      region: data.region,
      notes: data.notes,
      assignedBy,
    },
  });

  return prisma.user.findUnique({
    where: { id: user.id },
    include: {
      roles: true,
      managerAssignment: true,
    },
  });
}

export async function assignManager(
  prisma: PrismaClient,
  serviceId: string,
  managerId: string,
) {
  const [service, manager] = await Promise.all([
    prisma.serviceListing.findUnique({ where: { id: serviceId } }),
    prisma.user.findUnique({
      where: { id: managerId },
      include: { roles: true },
    }),
  ]);

  if (!service) {
    throw new HttpError(404, 'Service not found');
  }

  if (!manager) {
    throw new HttpError(404, 'Manager not found');
  }

  const hasManagerRole = manager.roles.some((role) => role.role === 'MANAGER');
  if (!hasManagerRole) {
    throw new HttpError(400, 'User does not have MANAGER role');
  }

  return prisma.serviceListing.update({
    where: { id: serviceId },
    data: { assignedManagerId: managerId },
    include: { assignedManager: { include: { roles: true } } },
  });
}

// Nodal Officer Functions
export async function createNodalOfficer(
  prisma: PrismaClient,
  data: {
    email: string;
    fullName: string;
    password: string;
    phone?: string;
    area: string;
    location: string;
    address?: string;
    pincode?: string;
    region?: string;
    notes?: string;
  },
  assignedBy?: string,
) {
  const exists = await prisma.user.findUnique({ where: { email: data.email } });
  if (exists) {
    throw new HttpError(409, 'Email already registered');
  }

  const passwordHash = await hashPassword(data.password);

  // Create user with NODAL_OFFICER role
  const user = await prisma.user.create({
    data: {
      email: data.email,
      fullName: data.fullName,
      passwordHash,
      phone: data.phone,
      roles: {
        create: [{ role: 'NODAL_OFFICER' }],
      },
    },
    include: { roles: true },
  });

  // Assign officer to area
  await prisma.nodalOfficerAssignment.create({
    data: {
      officerId: user.id,
      area: data.area,
      location: data.location,
      address: data.address,
      pincode: data.pincode,
      region: data.region,
      notes: data.notes,
      assignedBy,
    },
  });

  return user;
}

export function listNodalOfficers(prisma: PrismaClient, filters?: { location?: string; area?: string; pincode?: string }) {
  return prisma.nodalOfficerAssignment.findMany({
    where: {
      ...(filters?.location && { location: { contains: filters.location, mode: 'insensitive' } }),
      ...(filters?.area && { area: { contains: filters.area, mode: 'insensitive' } }),
      ...(filters?.pincode && { pincode: filters.pincode }),
      status: 'ACTIVE',
    },
    include: {
      officer: {
        include: { roles: true },
      },
    },
    orderBy: { assignedAt: 'desc' },
  });
}

export async function assignOfficerToArea(
  prisma: PrismaClient,
  officerId: string,
  data: {
    area: string;
    location: string;
    address?: string;
    pincode?: string;
    region?: string;
    notes?: string;
  },
  assignedBy?: string,
) {
  const officer = await prisma.user.findUnique({
    where: { id: officerId },
    include: { roles: true },
  });

  if (!officer) {
    throw new HttpError(404, 'Officer not found');
  }

  const hasOfficerRole = officer.roles.some((role) => role.role === 'NODAL_OFFICER');
  if (!hasOfficerRole) {
    throw new HttpError(400, 'User does not have NODAL_OFFICER role');
  }

  return prisma.nodalOfficerAssignment.create({
    data: {
      officerId,
      area: data.area,
      location: data.location,
      address: data.address,
      pincode: data.pincode,
      region: data.region,
      notes: data.notes,
      assignedBy,
    },
    include: {
      officer: {
        include: { roles: true },
      },
    },
  });
}

export function listRecommendations(prisma: PrismaClient, status?: 'PENDING' | 'APPROVED' | 'REJECTED') {
  return prisma.nodalOfficerRecommendation.findMany({
    where: status ? { status } : undefined,
    include: {
      officer: {
        include: { roles: true },
      },
      manager: {
        include: { roles: true },
      },
    },
    orderBy: { createdAt: 'desc' },
  });
}

export async function approveRecommendation(
  prisma: PrismaClient,
  recommendationId: string,
  reviewedBy: string,
) {
  const recommendation = await prisma.nodalOfficerRecommendation.findUnique({
    where: { id: recommendationId },
  });

  if (!recommendation) {
    throw new HttpError(404, 'Recommendation not found');
  }

  if (recommendation.status !== 'PENDING') {
    throw new HttpError(400, 'Recommendation already processed');
  }

  let finalOfficerId = recommendation.officerId;

  // If this is a new user recommendation, create the user first
  if (!finalOfficerId && recommendation.newUserEmail && recommendation.newUserFullName) {
    // Check if user already exists (edge case)
    const existingUser = await prisma.user.findUnique({
      where: { email: recommendation.newUserEmail },
    });

    if (existingUser) {
      throw new HttpError(409, 'User with this email already exists');
    }

    // Generate a temporary password (admin should change it)
    const { hashPassword } = await import('../../utils/password.js');
    const tempPassword = `Temp${Date.now()}`;
    const passwordHash = await hashPassword(tempPassword);

    // Create user with NODAL_OFFICER role
    const newUser = await prisma.user.create({
      data: {
        email: recommendation.newUserEmail,
        fullName: recommendation.newUserFullName,
        phone: recommendation.newUserPhone || null,
        passwordHash,
        roles: {
          create: [{ role: 'NODAL_OFFICER' }],
        },
      },
      include: { roles: true },
    });

    finalOfficerId = newUser.id;

    // Update recommendation with the created officer ID
    await prisma.nodalOfficerRecommendation.update({
      where: { id: recommendationId },
      data: { officerId: finalOfficerId },
    });
  }

  if (!finalOfficerId) {
    throw new HttpError(400, 'Invalid recommendation: no officer ID or new user details');
  }

  // Update recommendation status
  await prisma.nodalOfficerRecommendation.update({
    where: { id: recommendationId },
    data: {
      status: 'APPROVED',
      reviewedBy,
      reviewedAt: new Date(),
    },
  });

  // Create assignment from approved recommendation
  // Check if assignment already exists
  const existingAssignment = await prisma.nodalOfficerAssignment.findFirst({
    where: {
      officerId: finalOfficerId,
      area: recommendation.area,
      location: recommendation.location,
      status: 'ACTIVE',
    },
  });

  if (!existingAssignment) {
    await prisma.nodalOfficerAssignment.create({
      data: {
        officerId: finalOfficerId,
        area: recommendation.area,
        location: recommendation.location,
        address: recommendation.address,
        pincode: recommendation.pincode,
        region: recommendation.region,
        notes: recommendation.reason || recommendation.notes,
        assignedBy: reviewedBy,
      },
    });
  }

  return prisma.nodalOfficerRecommendation.findUnique({
    where: { id: recommendationId },
    include: {
      officer: { include: { roles: true } },
      manager: { include: { roles: true } },
    },
  });
}

// Service Category Functions
export function listServiceCategories(prisma: PrismaClient) {
  return prisma.serviceCategory.findMany({
    orderBy: [{ displayOrder: 'asc' }, { name: 'asc' }],
  });
}

export async function createServiceCategory(
  prisma: PrismaClient,
  data: {
    name: string;
    description?: string;
    showInNavbar?: boolean;
    displayOrder?: number;
    isActive?: boolean;
  },
) {
  // Check if category with same name exists
  const exists = await prisma.serviceCategory.findUnique({
    where: { name: data.name },
  });
  if (exists) {
    throw new HttpError(409, 'Service category with this name already exists');
  }

  return prisma.serviceCategory.create({
    data: {
      name: data.name,
      description: data.description,
      showInNavbar: data.showInNavbar ?? false,
      displayOrder: data.displayOrder ?? 0,
      isActive: data.isActive ?? true,
    },
  });
}

export async function updateServiceCategory(
  prisma: PrismaClient,
  id: string,
  data: {
    name?: string;
    description?: string;
    showInNavbar?: boolean;
    displayOrder?: number;
    isActive?: boolean;
  },
) {
  // If updating name, check if another category with same name exists
  if (data.name) {
    const exists = await prisma.serviceCategory.findFirst({
      where: {
        name: data.name,
        NOT: { id },
      },
    });
    if (exists) {
      throw new HttpError(409, 'Service category with this name already exists');
    }
  }

  return prisma.serviceCategory.update({
    where: { id },
    data: {
      ...(data.name && { name: data.name }),
      ...(data.description !== undefined && { description: data.description }),
      ...(data.showInNavbar !== undefined && { showInNavbar: data.showInNavbar }),
      ...(data.displayOrder !== undefined && { displayOrder: data.displayOrder }),
      ...(data.isActive !== undefined && { isActive: data.isActive }),
    },
  });
}

export async function deleteServiceCategory(prisma: PrismaClient, id: string) {
  return prisma.serviceCategory.delete({
    where: { id },
  });
}

export async function rejectRecommendation(
  prisma: PrismaClient,
  recommendationId: string,
  reviewedBy: string,
  notes?: string,
) {
  const recommendation = await prisma.nodalOfficerRecommendation.findUnique({
    where: { id: recommendationId },
  });

  if (!recommendation) {
    throw new HttpError(404, 'Recommendation not found');
  }

  if (recommendation.status !== 'PENDING') {
    throw new HttpError(400, 'Recommendation already processed');
  }

  return prisma.nodalOfficerRecommendation.update({
    where: { id: recommendationId },
    data: {
      status: 'REJECTED',
      reviewedBy,
      reviewedAt: new Date(),
      notes: notes || recommendation.notes,
    },
    include: {
      officer: { include: { roles: true } },
      manager: { include: { roles: true } },
    },
  });
}

