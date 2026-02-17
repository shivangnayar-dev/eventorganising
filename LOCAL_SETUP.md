# 🚀 Local Setup with MongoDB

## Step 1: Install MongoDB

**On macOS, install MongoDB using Homebrew:**

```bash
# Install Homebrew if not installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install MongoDB
brew tap mongodb/brew
brew install mongodb-community

# Start MongoDB service
brew services start mongodb-community
```

**Verify MongoDB is running:**
```bash
mongosh --version
```

## Step 2: Setup Backend

```bash
cd /Users/shivangnayar/eventorganising/backend

# Install dependencies
npm install

# Create .env file
cp env.example .env

# Generate Prisma Client
npm run prisma:generate

# Initialize database schema
npm run prisma:push

# Seed database (creates admin user)
npm run seed
```

## Step 3: Run Application

```bash
# Development mode (with hot reload)
npm run dev

# Or production mode
npm run build
npm start
```

## Step 4: Test

- **API:** http://localhost:3000
- **Health Check:** http://localhost:3000/health
- **Admin Login:**
  - Email: `admin@example.com`
  - Password: `Pass@1234`

## Useful Commands

```bash
# MongoDB commands
brew services start mongodb-community  # Start MongoDB
brew services stop mongodb-community   # Stop MongoDB
brew services restart mongodb-community # Restart MongoDB
mongosh                                 # Connect to MongoDB shell

# Application commands
npm run dev          # Run in development mode
npm run build        # Build TypeScript
npm run seed         # Seed database
npm run prisma:push  # Update database schema
npm run prisma:studio # Open Prisma Studio (database GUI)
```

