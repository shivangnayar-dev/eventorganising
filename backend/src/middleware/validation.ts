import type { NextFunction, Request, Response } from 'express';
import type { ZodSchema } from 'zod';

import { HttpError } from './errorHandler.js';

export function validate(schema: ZodSchema) {
  return (req: Request, _res: Response, next: NextFunction) => {
    const result = schema.safeParse({
      body: req.body,
      query: req.query,
      params: req.params,
    });

    if (!result.success) {
      const message = result.error.errors.map((err) => err.message).join(', ');
      throw new HttpError(400, message);
    }

    next();
  };
}

