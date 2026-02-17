import { Router } from 'express';

import { validate } from '../../middleware/validation.js';
import { login, logout, refresh, register } from './auth.controller.js';
import { loginSchema, logoutSchema, refreshSchema, registerSchema } from './auth.validation.js';

const router = Router();

router.post('/register', validate(registerSchema), register);
router.post('/login', validate(loginSchema), login);
router.post('/refresh', validate(refreshSchema), refresh);
router.post('/logout', validate(logoutSchema), logout);

export default router;

