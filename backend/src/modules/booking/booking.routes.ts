import { Router } from 'express';

import { authGuard } from '../../middleware/authMiddleware.js';
import { validate } from '../../middleware/validation.js';
import { createBooking } from './booking.controller.js';
import { bookingSchema } from './booking.validation.js';

const router = Router();

router.post('/create', authGuard, validate(bookingSchema), createBooking);

export default router;

