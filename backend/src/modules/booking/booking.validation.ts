import { z } from 'zod';

// MongoDB ObjectId validation (24-character hexadecimal string)
const objectIdRegex = /^[0-9a-fA-F]{24}$/;
const objectId = z.string().regex(objectIdRegex, 'Invalid ObjectId format');

export const bookingSchema = z.object({
  body: z.object({
    serviceId: objectId,
    scheduledDate: z.string().datetime(),
  }),
});

