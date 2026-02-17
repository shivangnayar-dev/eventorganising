import { z } from 'zod';

// MongoDB ObjectId validation (24-character hexadecimal string)
const objectIdRegex = /^[0-9a-fA-F]{24}$/;
const objectId = z.string().regex(objectIdRegex, 'Invalid ObjectId format');

export const verifyServiceSchema = z.object({
  body: z.object({
    assignmentId: objectId,
    decision: z.enum(['APPROVED', 'REJECTED', 'INFO_REQUESTED']),
    notes: z.string().optional(),
  }),
});

