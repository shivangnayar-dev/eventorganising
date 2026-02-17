import { z } from 'zod';

// MongoDB ObjectId validation (24-character hexadecimal string)
const objectIdRegex = /^[0-9a-fA-F]{24}$/;
const objectId = z.string().regex(objectIdRegex, 'Invalid ObjectId format');

export const createServiceSchema = z.object({
  body: z.object({
    title: z.string().min(3),
    description: z.string().min(10),
    location: z.string().min(2),
    address: z.string().optional(),
    pincode: z.string().optional(),
    eventTypes: z.string().optional(),
    propertyType: z.string().optional(),
    capacity: z.number().int().positive().optional(),
    amenities: z.string().optional(),
    photos: z.array(z.string().url()).optional(),
    price: z.number().positive(),
  }),
});

export const assignSchema = z.object({
  body: z.object({
    serviceId: objectId,
    agentIds: z.array(objectId).length(3),
    nodalOfficerId: objectId.optional(), // Optional: if provided, assign this officer
  }),
});

export const assignNodalOfficerSchema = z.object({
  body: z.object({
    serviceId: objectId,
    nodalOfficerId: objectId, // Required: nodal officer to assign
  }),
});

export const onboardSchema = z.object({
  body: z.object({
    kycDocumentUrl: z.string().url(),
    pricingDetails: z.string().min(5),
    photoUrls: z.array(z.string().url()).optional(),
  }),
});

