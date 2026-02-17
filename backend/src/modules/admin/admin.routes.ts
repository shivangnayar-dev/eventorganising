import { Router } from 'express';

import { authGuard } from '../../middleware/authMiddleware.js';
import { requireRoles } from '../../utils/roles.js';
import { dashboard, services, users, verifications, createManager, assignManager, createNodalOfficer, listNodalOfficers, assignOfficerToArea, listRecommendations, approveRecommendation, rejectRecommendation, listServiceCategories, createServiceCategory, updateServiceCategory, deleteServiceCategory } from './admin.controller.js';
import { validate } from '../../middleware/validation.js';
import { createManagerSchema, recommendationIdSchema, serviceCategoryIdSchema, assignManagerSchema } from './admin.validation.js';

const router = Router();

router.use(authGuard, requireRoles('ADMIN'));

router.get('/dashboard', dashboard);
router.get('/services', services);
router.get('/users', users);
router.get('/verifications', verifications);
router.post('/managers', validate(createManagerSchema), createManager);
router.post('/assign-manager', validate(assignManagerSchema), assignManager);

// Nodal Officer Routes
router.post('/nodal-officers', createNodalOfficer);
router.get('/nodal-officers', listNodalOfficers);
router.post('/nodal-officers/assign', assignOfficerToArea);
router.get('/recommendations', listRecommendations);
router.post('/recommendations/:id/approve', validate(recommendationIdSchema), approveRecommendation);
router.post('/recommendations/:id/reject', validate(recommendationIdSchema), rejectRecommendation);

// Service Category Routes
router.get('/service-categories', listServiceCategories);
router.post('/service-categories', createServiceCategory);
router.put('/service-categories/:id', validate(serviceCategoryIdSchema), updateServiceCategory);
router.delete('/service-categories/:id', validate(serviceCategoryIdSchema), deleteServiceCategory);

export default router;

