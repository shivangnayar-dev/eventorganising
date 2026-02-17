# 🚀 Running the Application Locally

## Prerequisites

1. ✅ Backend running on `http://localhost:3000`
2. ✅ MongoDB running locally
3. ✅ Flutter installed

## Step 1: Start Backend (if not running)

```bash
cd /Users/shivangnayar/eventorganising/backend
npm run dev
```

The backend should be running on: `http://localhost:3000`

## Step 2: Run Flutter Frontend

### Option 1: Run on Web (Easiest for Testing)

```bash
cd /Users/shivangnayar/eventorganising/frontend
flutter run -d chrome
```

This will:
- Open Chrome automatically
- Connect to `http://localhost:3000` (default in development)
- Hot reload enabled (save files to see changes instantly)

### Option 2: Run on iOS Simulator

```bash
# Open iOS Simulator first
open -a Simulator

# Then run Flutter
cd /Users/shivangnayar/eventorganising/frontend
flutter run -d ios
```

### Option 3: Run on macOS Desktop

```bash
cd /Users/shivangnayar/eventorganising/frontend
flutter run -d macos
```

## Step 3: Test Login

Once the app is running:

1. **Admin Login:**
   - Email: `admin@example.com`
   - Password: `Pass@1234`

2. **Provider Login:**
   - Email: `provider@example.com`
   - Password: `Pass@1234`

## API Configuration

The frontend is already configured to use `http://localhost:3000` in development mode.

If you need to change it, you can:

1. **Via command line:**
   ```bash
   flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
   ```

2. **Or modify the default in code:**
   - File: `frontend/lib/config/environment.dart`
   - Change line 21: `return 'http://localhost:3000';`

## Troubleshooting

### Backend not connecting
```bash
# Check if backend is running
curl http://localhost:3000/health

# Should return: {"status":"ok",...}
```

### CORS errors
Make sure your backend `.env` has:
```
CORS_ORIGIN="http://localhost:3000,http://localhost:8080"
```

### Flutter build errors
```bash
cd frontend
flutter clean
flutter pub get
flutter run -d chrome
```

## Quick Commands

```bash
# Start backend
cd backend && npm run dev

# Start frontend (in new terminal)
cd frontend && flutter run -d chrome

# View backend logs
cd backend && tail -f logs/combined.log
```

