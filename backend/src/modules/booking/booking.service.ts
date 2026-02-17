import type { PrismaClient } from '@prisma/client';

export function createBooking(
  prisma: PrismaClient,
  userId: string,
  data: { serviceId: string; scheduledDate: string },
) {
  return prisma.booking.create({
    data: {
      userId,
      serviceId: data.serviceId,
      scheduledDate: new Date(data.scheduledDate),
    },
  });
}

