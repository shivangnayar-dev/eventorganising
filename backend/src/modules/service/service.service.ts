import type { PrismaClient, ServiceStatus, VerificationStatus } from '@prisma/client';

import { HttpError } from '../../middleware/errorHandler.js';

export async function createService(
  prisma: PrismaClient,
  ownerId: string,
  data: {
    title: string;
    description: string;
    location: string;
    address?: string;
    pincode?: string;
    eventTypes?: string;
    propertyType?: string;
    capacity?: number;
    amenities?: string;
    photos?: string[];
    price: number;
  },
) {
  return prisma.serviceListing.create({
    data: {
      ownerId,
      title: data.title,
      description: data.description,
      location: data.location,
      address: data.address,
      pincode: data.pincode,
      eventTypes: data.eventTypes,
      propertyType: data.propertyType,
      capacity: data.capacity,
      amenities: data.amenities,
      photos: data.photos ? (data.photos as any) : null,
      price: data.price,
    },
  });
}

export function listUserServices(prisma: PrismaClient, ownerId: string) {
  return prisma.serviceListing.findMany({ 
    where: { ownerId },
    include: { owner: { include: { roles: true } } },
    orderBy: { submittedAt: 'desc' },
  });
}

// Fetch services assigned to a nodal officer
export function listNodalOfficerServices(prisma: PrismaClient, officerId: string) {
  return prisma.serviceListing.findMany({
    where: { assignedNodalOfficerId: officerId } as any,
    include: {
      owner: { include: { roles: true } },
      assignedManager: { include: { roles: true } },
      assignedNodalOfficer: { include: { roles: true } },
    } as any,
    orderBy: { submittedAt: 'desc' },
  });
}

export function listPending(prisma: PrismaClient) {
  return prisma.serviceListing.findMany({ where: { status: 'PENDING' } });
}

export function listPublished(prisma: PrismaClient) {
  return prisma.serviceListing.findMany({ where: { status: 'PUBLISHED' } });
}

export function listManagedServices(prisma: PrismaClient, managerId: string) {
  return prisma.serviceListing.findMany({
    where: { assignedManagerId: managerId },
    include: { 
      owner: { select: { id: true, fullName: true, email: true } },
      assignedManager: { include: { roles: true } },
      assignedNodalOfficer: { include: { roles: true } },
    } as any,
  });
}

// New function to assign nodal officer directly (without providers)
export async function assignNodalOfficer(
  prisma: PrismaClient,
  managerId: string,
  serviceId: string,
  nodalOfficerId: string,
) {
  const service = await prisma.serviceListing.findUnique({ where: { id: serviceId } });
  if (!service) {
    throw new HttpError(404, 'Service not found');
  }

  // Verify nodal officer exists and is active
  const officerAssignment = await prisma.nodalOfficerAssignment.findFirst({
    where: {
      officerId: nodalOfficerId,
      status: 'ACTIVE',
    },
    include: {
      officer: {
        include: { roles: true },
      },
    },
  });

  if (!officerAssignment) {
    throw new HttpError(404, 'Nodal officer not found or not active');
  }

  // Update service with nodal officer assignment
  await prisma.serviceListing.update({
    where: { id: serviceId },
    data: {
      status: 'ASSIGNED',
      assignedNodalOfficerId: nodalOfficerId,
    } as any,
  });

  // Send notification to nodal officer (email/SMS)
  await sendNodalOfficerAssignmentNotification(
    prisma,
    officerAssignment.officer,
    service,
  );

  return {
    service: await prisma.serviceListing.findUnique({
      where: { id: serviceId },
      include: {
        assignedManager: true,
        assignedNodalOfficer: {
          include: { roles: true },
        },
      } as any,
    }),
    nodalOfficer: officerAssignment.officer,
  };
}

// Helper function to send notification to nodal officer
async function sendNodalOfficerAssignmentNotification(
  prisma: PrismaClient,
  officer: { id: string; email: string; fullName: string; phone?: string | null },
  service: { id: string; title: string; location: string; address?: string | null },
) {
  // Generate activation token for password setup
  const jwt = await import('jsonwebtoken');
  const { env } = await import('../../config/env.js');
  const activationToken = jwt.sign(
    { userId: officer.id, type: 'password_setup' } as object,
    env.jwtSecret,
    { expiresIn: '7d' },
  );

  const { logger } = await import('../../config/logger.js');
  const { sendNodalOfficerAssignmentEmail } = await import('../../utils/email.js');

  const frontendUrl = env.frontendUrl || 'http://localhost';
  const activationLink = `${frontendUrl}/auth/setup-password?token=${activationToken}`;

  // Log notification details
  logger.info('Nodal Officer Assignment Notification', {
    officerEmail: officer.email,
    officerPhone: officer.phone,
    serviceTitle: service.title,
    serviceLocation: service.location,
    activationLink,
  });

  // Send email notification
  await sendNodalOfficerAssignmentEmail(
    officer.email,
    officer.fullName,
    service.title,
    service.location,
    activationLink,
  );

  // TODO: Integrate with SMS service (e.g., Twilio, AWS SNS) if phone is provided
  // if (officer.phone) {
  //   await sendSMS(officer.phone, `You've been assigned as Nodal Officer. Setup: ${activationLink}`);
  // }
}

export async function assignAgents(
  prisma: PrismaClient,
  managerId: string,
  serviceId: string,
  agentIds: string[],
  nodalOfficerId?: string,
) {
  const service = await prisma.serviceListing.findUnique({ where: { id: serviceId } });
  if (!service) {
    throw new HttpError(404, 'Service not found');
  }

  // Find nodal officers in the service's area
  const availableOfficers = await findNodalOfficersByServiceLocation(
    prisma,
    service.location,
    service.pincode,
  );

  let finalNodalOfficerId = nodalOfficerId;

  // If no officer provided but officers exist in area, auto-assign the first one
  if (!finalNodalOfficerId && availableOfficers.length > 0) {
    finalNodalOfficerId = availableOfficers[0].officerId;
  }

  // If nodal officer is provided, verify it exists and is in the area
  if (finalNodalOfficerId) {
    const officerExists = availableOfficers.some(
      (o) => o.officerId === finalNodalOfficerId,
    );
    if (!officerExists) {
      throw new HttpError(
        400,
        'Selected nodal officer is not assigned to this service area. Please recommend them first or select an officer from the available list.',
      );
    }
  }

  await prisma.$transaction([
    prisma.serviceListing.update({
      where: { id: serviceId },
      data: { status: 'ASSIGNED' },
    }),
    prisma.verificationAssignment.createMany({
      data: agentIds.map((providerId) => ({
        serviceId,
        providerId,
        assignedById: managerId,
      })),
    }),
  ]);

  return {
    service: await prisma.serviceListing.findUnique({
      where: { id: serviceId },
      include: { assignedManager: true },
    }),
    availableNodalOfficers: availableOfficers,
    assignedNodalOfficerId: finalNodalOfficerId || null,
    needsRecommendation: availableOfficers.length === 0,
  };
}

// Helper function to find nodal officers by service location
export async function findNodalOfficersByServiceLocation(
  prisma: PrismaClient,
  location: string,
  pincode?: string | null,
) {
  // For MongoDB, fetch all active officers and filter by location
  const whereClause: any = {
    status: 'ACTIVE',
  };

  if (pincode) {
    whereClause.pincode = pincode;
  }

  const officers = await prisma.nodalOfficerAssignment.findMany({
    where: whereClause,
    include: {
      officer: {
        include: { roles: true },
      },
    },
    orderBy: { assignedAt: 'desc' },
  });

  // Filter by location case-insensitively (MongoDB doesn't support mode: 'insensitive' directly)
  return officers.filter((o) =>
    o.location.toLowerCase().includes(location.toLowerCase()),
  );
}

export async function verifyService(
  prisma: PrismaClient,
  assignmentId: string,
  decision: VerificationStatus,
  notes?: string,
) {
  const assignment = await prisma.verificationAssignment.findUnique({
    where: { id: assignmentId },
  });

  if (!assignment) {
    throw new HttpError(404, 'Assignment not found');
  }

  await prisma.verificationAssignment.update({
    where: { id: assignmentId },
    data: { status: decision, notes },
  });

  if (decision === 'APPROVED') {
    const approvals = await prisma.verificationAssignment.count({
      where: { serviceId: assignment.serviceId, status: 'APPROVED' },
    });

    if (approvals >= 3) {
      await prisma.serviceListing.update({
        where: { id: assignment.serviceId },
        data: { status: 'PUBLISHED', publishedAt: new Date() },
      });
    }
  }
}

export function listAssignments(prisma: PrismaClient, providerId: string) {
  return prisma.verificationAssignment.findMany({
    where: { providerId },
    include: { service: true },
  });
}

export async function onboardProvider(
  prisma: PrismaClient,
  userId: string,
  data: { kycDocumentUrl: string; pricingDetails: string; photoUrls?: string[] },
) {
  return prisma.$transaction(async (tx) => {
    await tx.role.upsert({
      where: { userId_role: { userId, role: 'PROVIDER' } },
      update: {},
      create: { userId, role: 'PROVIDER' },
    });

    return tx.serviceProvider.upsert({
      where: { userId },
      update: {
        kycDocumentUrl: data.kycDocumentUrl,
        pricingDetails: data.pricingDetails,
        photos: data.photoUrls ?? [],
        status: 'PENDING',
      },
      create: {
        userId,
        kycDocumentUrl: data.kycDocumentUrl,
        pricingDetails: data.pricingDetails,
        photos: data.photoUrls ?? [],
      },
    });
  });
}

export function listProviders(prisma: PrismaClient) {
  return prisma.serviceProvider.findMany({
    include: { user: { include: { roles: true } } },
    where: { status: 'APPROVED' },
    orderBy: { createdAt: 'desc' },
  });
}

// Nodal Officer Functions for Managers
export async function listNodalOfficersByArea(
  prisma: PrismaClient,
  managerId: string,
  filters?: { location?: string; area?: string; pincode?: string },
) {
  // Get manager's assignment to filter officers by manager's location
  const managerAssignment = await prisma.managerAssignment.findUnique({
    where: { managerId },
    include: { manager: { include: { roles: true } } },
  });

  if (!managerAssignment) {
    throw new HttpError(404, 'Manager assignment not found. Please contact admin to assign you to a region.');
  }

  if (managerAssignment.status !== 'ACTIVE') {
    throw new HttpError(403, 'Manager assignment is not active');
  }

  // Build filter based on manager's location and optional filters
  // For MongoDB, we'll fetch all and filter in memory for case-insensitive matching
  const whereClause: any = {
    status: 'ACTIVE',
  };

  // If manager has a pincode, filter by it
  if (managerAssignment.pincode) {
    whereClause.pincode = managerAssignment.pincode;
  }

  // Fetch all active officers first
  let officers = await prisma.nodalOfficerAssignment.findMany({
    where: whereClause,
    include: {
      officer: {
        include: { roles: true },
      },
    },
    orderBy: { assignedAt: 'desc' },
  });

  // Filter by location case-insensitively
  const locationFilter = filters?.location || managerAssignment.location;
  if (locationFilter) {
    officers = officers.filter((o) =>
      o.location.toLowerCase().includes(locationFilter.toLowerCase()),
    );
  }

  // Filter by region if provided
  const regionFilter = managerAssignment.region;
  if (regionFilter) {
    officers = officers.filter((o) =>
      o.region?.toLowerCase().includes(regionFilter.toLowerCase()),
    );
  }

  // Filter by area if provided
  if (filters?.area) {
    officers = officers.filter((o) =>
      o.area.toLowerCase().includes(filters.area!.toLowerCase()),
    );
  }

  // Filter by pincode if provided
  if (filters?.pincode) {
    officers = officers.filter((o) => o.pincode === filters.pincode);
  }

  return officers;
}

export async function recommendNodalOfficer(
  prisma: PrismaClient,
  managerId: string,
  data: {
    officerId?: string; // Optional - for existing officers
    newUserEmail?: string; // For new user recommendations
    newUserFullName?: string;
    newUserPhone?: string;
    area: string;
    location: string;
    address?: string;
    pincode?: string;
    region?: string;
    reason?: string;
  },
) {
  // Either officerId OR new user details must be provided
  if (!data.officerId && (!data.newUserEmail || !data.newUserFullName)) {
    throw new HttpError(400, 'Either officerId or new user details (email, fullName) must be provided');
  }

  // If recommending existing officer, verify they exist and have NODAL_OFFICER role
  if (data.officerId) {
    const officer = await prisma.user.findUnique({
      where: { id: data.officerId },
      include: { roles: true },
    });

    if (!officer) {
      throw new HttpError(404, 'Officer not found');
    }

    const hasOfficerRole = officer.roles.some((role) => role.role === 'NODAL_OFFICER');
    if (!hasOfficerRole) {
      throw new HttpError(400, 'User does not have NODAL_OFFICER role');
    }

    // Check if recommendation already exists for existing officer
    const existing = await prisma.nodalOfficerRecommendation.findFirst({
      where: {
        managerId,
        officerId: data.officerId,
        area: data.area,
        location: data.location,
        status: 'PENDING',
      },
    });

    if (existing) {
      throw new HttpError(409, 'Recommendation already pending for this officer and area');
    }
  } else {
    // For new user recommendations, check if email already exists
    const existingUser = await prisma.user.findUnique({
      where: { email: data.newUserEmail! },
    });

    if (existingUser) {
      throw new HttpError(409, 'User with this email already exists');
    }

    // Check if recommendation already exists for this new user email and area
    // Note: MongoDB/Prisma doesn't support filtering by newUserEmail directly in where clause
    // We'll fetch all pending recommendations and filter in memory
    const allPending = await prisma.nodalOfficerRecommendation.findMany({
      where: {
        managerId,
        area: data.area,
        location: data.location,
        status: 'PENDING',
      },
    });
    
    const existing = allPending.find(
      (rec: any) => rec.newUserEmail === data.newUserEmail
    );

    if (existing) {
      throw new HttpError(409, 'Recommendation already pending for this user and area');
    }
  }

  const createData: any = {
    managerId,
    area: data.area,
    location: data.location,
    reason: data.reason,
  };

  if (data.officerId) {
    createData.officerId = data.officerId;
  } else {
    createData.newUserEmail = data.newUserEmail;
    createData.newUserFullName = data.newUserFullName;
    if (data.newUserPhone) {
      createData.newUserPhone = data.newUserPhone;
    }
  }

  if (data.address) createData.address = data.address;
  if (data.pincode) createData.pincode = data.pincode;
  if (data.region) createData.region = data.region;

  return prisma.nodalOfficerRecommendation.create({
    data: createData,
    include: {
      officer: { include: { roles: true } },
      manager: { include: { roles: true } },
    },
  });
}

export function listManagerRecommendations(
  prisma: PrismaClient,
  managerId: string,
) {
  return prisma.nodalOfficerRecommendation.findMany({
    where: { managerId },
    include: {
      officer: { include: { roles: true } },
    },
    orderBy: { createdAt: 'desc' },
  });
}

export function getManagerAssignment(
  prisma: PrismaClient,
  managerId: string,
) {
  return prisma.managerAssignment.findUnique({
    where: { managerId },
    include: {
      manager: { include: { roles: true } },
    },
  });
}

// Service Category Functions - Public endpoint for navbar
export function listNavbarServiceCategories(prisma: PrismaClient) {
  return prisma.serviceCategory.findMany({
    where: {
      showInNavbar: true,
      isActive: true,
    },
    orderBy: [{ displayOrder: 'asc' }, { name: 'asc' }],
    select: {
      id: true,
      name: true,
      description: true,
      displayOrder: true,
    },
  });
}

