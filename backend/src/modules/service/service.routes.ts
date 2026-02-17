import { Router } from 'express';

import { authGuard } from '../../middleware/authMiddleware.js';
import { requireRoles } from '../../utils/roles.js';
import { validate } from '../../middleware/validation.js';
import {
  assignAgents,
  assignNodalOfficer,
  createService,
  listManagedServices,
  listMyServices,
  listPending,
  listPublished,
  listPublishedPublic,
  listProviders,
  onboardProvider,
  listNodalOfficersByArea,
  recommendNodalOfficer,
  listManagerRecommendations,
  getManagerAssignment,
  listNavbarServiceCategories,
  getAvailableNodalOfficersForService,
} from './service.controller.js';
import { assignSchema, assignNodalOfficerSchema, createServiceSchema, onboardSchema } from './service.validation.js';

const router = Router();

router.get('/public', listPublishedPublic);
router.get('/categories/navbar', listNavbarServiceCategories); // Public endpoint for navbar
router.post('/create', authGuard, validate(createServiceSchema), createService);
router.get('/my', authGuard, listMyServices);
router.get('/pending', authGuard, requireRoles('MANAGER'), listPending);
router.get('/list', authGuard, listPublished);
router.get('/managed', authGuard, requireRoles('MANAGER'), listManagedServices);
router.get('/providers', authGuard, requireRoles('MANAGER'), listProviders);
router.post('/assign', authGuard, requireRoles('MANAGER'), validate(assignSchema), assignAgents);
router.post('/assign-nodal-officer', authGuard, requireRoles('MANAGER'), validate(assignNodalOfficerSchema), assignNodalOfficer);
router.get(
  '/:serviceId/nodal-officers',
  authGuard,
  requireRoles('MANAGER'),
  getAvailableNodalOfficersForService,
);
router.post('/provider/onboard', authGuard, validate(onboardSchema), onboardProvider);

// Nodal Officer Routes for Managers
router.get('/manager/assignment', authGuard, requireRoles('MANAGER'), getManagerAssignment);
router.get('/nodal-officers', authGuard, requireRoles('MANAGER'), listNodalOfficersByArea);
router.post('/nodal-officers/recommend', authGuard, requireRoles('MANAGER'), recommendNodalOfficer);
router.get('/nodal-officers/my-recommendations', authGuard, requireRoles('MANAGER'), listManagerRecommendations);

export default router;

