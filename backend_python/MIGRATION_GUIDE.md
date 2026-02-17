# Migration Guide: Node.js/Express to FastAPI

This guide documents the conversion from Node.js/Express to Python FastAPI.

## Completed Components

### ✅ Core Infrastructure
- FastAPI application setup
- Environment configuration (Pydantic Settings)
- Logging (Loguru)
- Database connection (Motor + Beanie)
- Error handling middleware
- Rate limiting middleware
- CORS middleware

### ✅ Authentication System
- JWT token generation and verification
- Password hashing (bcrypt)
- Refresh token system
- Auth middleware with role-based access control
- Auth routes (register, login, refresh, logout, profile)

### ✅ Database Models (Partial)
- User and Role models
- RefreshToken model
- (Other models need to be created)

## Remaining Work

### Models to Create
- [ ] ServiceProvider
- [ ] ServiceListing
- [ ] VerificationAssignment
- [ ] Booking
- [ ] Payment
- [ ] Review
- [ ] NodalOfficerAssignment
- [ ] NodalOfficerRecommendation
- [ ] ManagerAssignment
- [ ] ServiceCategory

### Services to Implement
- [ ] ServiceService (service listing operations)
- [ ] AdminService (admin operations)
- [ ] BookingService (booking operations)
- [ ] VerificationService (verification operations)

### Routes to Complete
- [ ] Service routes (all endpoints)
- [ ] Admin routes (all endpoints)
- [ ] Booking routes (all endpoints)
- [ ] Verification routes (all endpoints)

### Utilities
- [ ] Email service (convert from nodemailer)
- [ ] Role utilities

## Key Differences

### 1. Async/Await
- **Node.js**: Mix of callbacks, promises, async/await
- **FastAPI**: All routes are async functions

### 2. Dependency Injection
- **Express**: Middleware functions, `req.app.locals`
- **FastAPI**: `Depends()` for dependencies, cleaner DI

### 3. Validation
- **Node.js**: Zod schemas
- **FastAPI**: Pydantic models (similar but different syntax)

### 4. Database
- **Node.js**: Prisma ORM
- **FastAPI**: Beanie ODM (MongoDB-specific, similar to Prisma)

### 5. Error Handling
- **Express**: Middleware with `next(error)`
- **FastAPI**: Exception handlers with `@app.exception_handler`

## Next Steps

1. Complete all database models
2. Implement all services
3. Complete all routes
4. Test all endpoints
5. Update frontend if needed (should be minimal)

## Running the FastAPI Backend

```bash
cd backend_python
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

The backend will run on `http://localhost:3000` (same port as before).

