import { Router } from 'express';

import { authGuard } from '../../middleware/authMiddleware.js';
import { requireRoles } from '../../utils/roles.js';
import { validate } from '../../middleware/validation.js';
import { getAssignments, verify } from './verification.controller.js';
import { verifyServiceSchema } from './verification.validation.js';

const router = Router();

router.get('/assigned', authGuard, requireRoles('PROVIDER'), getAssignments);
router.post('/verify', authGuard, requireRoles('PROVIDER'), validate(verifyServiceSchema), verify);

export default router;

