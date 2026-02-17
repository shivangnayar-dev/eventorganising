import { z } from 'zod';

// MongoDB ObjectId validation (24-character hexadecimal string)
const objectIdRegex = /^[0-9a-fA-F]{24}$/;
const objectId = z.string().regex(objectIdRegex, 'Invalid ObjectId format');

export const createManagerSchema = z.object({
  body: z.object({
    email: z.string().email(),
    fullName: z.string().min(2),
    password: z.string().min(6),
    phone: z.string().optional(),
    area: z.string().min(1),
    location: z.string().min(1),
    address: z.string().optional(),
    pincode: z.string().optional(),
    region: z.string().optional(),
    notes: z.string().optional(),
  }),
});

export const recommendationIdSchema = z.object({
  params: z.object({
    id: objectId,
  }),
});

export const serviceCategoryIdSchema = z.object({
  params: z.object({
    id: objectId,
  }),
});

export const assignManagerSchema = z.object({
  body: z.object({
    serviceId: objectId,
    managerId: objectId,
  }),
});

