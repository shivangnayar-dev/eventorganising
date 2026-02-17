# Event Organising Backend - FastAPI

FastAPI backend for the Event Organising application, converted from Node.js/Express.

## Features

- ✅ FastAPI with async/await support
- ✅ MongoDB with Beanie ODM (similar to Prisma)
- ✅ JWT authentication with refresh tokens
- ✅ Role-based access control (RBAC)
- ✅ Rate limiting
- ✅ CORS support
- ✅ Request validation with Pydantic
- ✅ Comprehensive error handling
- ✅ Logging with Loguru

## Project Structure

```
backend_python/
├── app/
│   ├── __init__.py
│   ├── main.py                 # FastAPI application entry point
│   ├── config/
│   │   ├── env.py              # Environment configuration
│   │   └── logger.py           # Logging configuration
│   ├── database/
│   │   └── connection.py        # Database connection and initialization
│   ├── models/                 # Beanie document models
│   │   ├── user.py
│   │   ├── refresh_token.py
│   │   └── ...
│   ├── routes/                 # API routes
│   │   ├── auth.py
│   │   ├── service.py
│   │   └── ...
│   ├── services/               # Business logic
│   │   ├── auth_service.py
│   │   └── ...
│   ├── middleware/             # Middleware
│   │   ├── auth_middleware.py
│   │   ├── error_handler.py
│   │   └── rate_limiter.py
│   └── utils/                  # Utility functions
│       ├── jwt.py
│       ├── password.py
│       └── refresh_token.py
├── requirements.txt
├── .env.example
└── README.md
```

## Setup

### 1. Install Dependencies

```bash
cd backend_python
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Configure Environment

```bash
cp .env.example .env
# Edit .env with your configuration
```

### 3. Run the Server

```bash
# Development
uvicorn app.main:app --reload --host 0.0.0.0 --port 3000

# Production
uvicorn app.main:app --host 0.0.0.0 --port 3000
```

## API Endpoints

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user
- `POST /auth/refresh` - Refresh access token
- `POST /auth/logout` - Logout user
- `GET /auth/profile` - Get current user profile

### Services
- `GET /service/public` - List published services (public)
- `GET /service/categories/navbar` - Get navbar categories
- `POST /service/create` - Create service (authenticated)
- `GET /service/pending` - List pending services
- `GET /service/my` - List user's services
- `GET /service/managed` - List managed services (manager)
- `POST /service/assign` - Assign verification agent
- `POST /service/assign-nodal-officer` - Assign nodal officer

### Admin
- `GET /admin/dashboard` - Admin dashboard
- `GET /admin/users` - List users
- `GET /admin/services` - List all services
- `POST /admin/create-manager` - Create manager
- `POST /admin/assign-manager` - Assign manager to area

### Booking
- `POST /booking/create` - Create booking

## Migration Notes

### Key Differences from Node.js/Express

1. **Async/Await**: FastAPI uses native async/await, all routes are async
2. **Dependency Injection**: FastAPI uses `Depends()` for dependencies
3. **Validation**: Pydantic models instead of Zod schemas
4. **Database**: Beanie ODM instead of Prisma
5. **Error Handling**: FastAPI exception handlers instead of Express middleware
6. **Request/Response**: Pydantic models for request/response validation

### Database Models

- Beanie models use Python classes with Pydantic
- Field aliases for MongoDB field names
- Relationships use `Link` type from Beanie

### Authentication

- JWT tokens work the same way
- Refresh tokens stored in MongoDB
- Middleware uses FastAPI dependencies

## Development

```bash
# Run with auto-reload
uvicorn app.main:app --reload

# Run with specific port
uvicorn app.main:app --reload --port 3000
```

## Production Deployment

```bash
# Install production dependencies
pip install -r requirements.txt

# Run with Gunicorn (recommended)
gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:3000
```

## Environment Variables

See `.env.example` for all required environment variables.

## Notes

- This is a conversion from Node.js/Express to FastAPI
- All functionality should be equivalent
- MongoDB database structure remains the same
- Frontend can use the same API endpoints

