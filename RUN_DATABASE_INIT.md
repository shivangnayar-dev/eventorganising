# 🗄️ Database Initialization Guide

This guide shows you how to initialize your database with all schemas and authentication.

## 📋 What This Does

The initialization script will:
1. ✅ Initialize database connection (creates all collections/schemas)
2. ✅ Create admin user with authentication (email: `admin@example.com`, password: `Pass@1234`)
3. ✅ Seed service categories (Wedding Venues, Conference Halls, etc.)
4. ✅ Seed form field configurations (for venue submission form)
5. ✅ Seed verification checkpoint configurations (for nodal officers)

## 🚀 Run on Server

**SSH into your server:**
```bash
ssh root@72.61.232.15
```

**Navigate to backend directory:**
```bash
cd /var/www/eventorganising/backend
source venv/bin/activate
```

**Run the initialization script:**
```bash
python scripts/init_database.py
```

## 📤 Upload Script First (if needed)

If you haven't uploaded the latest backend code, run this from your **local machine**:

```bash
cd /Users/shivangnayar/eventorganising
rsync -avz --exclude 'venv' --exclude '__pycache__' --exclude '*.pyc' backend_python/scripts/init_database.py root@72.61.232.15:/var/www/eventorganising/backend/scripts/
```

## ✅ Expected Output

You should see:
```
🚀 Database Initialization Script
============================================================
📦 Initializing database connection...
✅ Database initialized successfully

👤 Creating Admin User with Authentication
============================================================
✅ Admin user created: admin@example.com
✅ Added ADMIN role
✅ Added MANAGER role

📋 Admin User Details:
   Email: admin@example.com
   Password: Pass@1234
   Roles: ADMIN, MANAGER

📂 Seeding Service Categories
============================================================
✅ Created category: Wedding Venues
✅ Created category: Conference Halls
...

📝 Seeding Form Field Configurations
============================================================
✅ Created field: Property/Venue Name (title)
...

✅ Seeding Verification Checkpoint Configurations
============================================================
✅ Created checkpoint: Venue Exists at Location (venue_exists)
...

✅ Database Initialization Complete!
```

## 🔐 Admin Login Credentials

After running the script, you can login with:
- **Email:** `admin@example.com`
- **Password:** `Pass@1234`
- **Roles:** ADMIN, MANAGER

## 🔄 Re-running the Script

The script is **idempotent** - it's safe to run multiple times:
- ✅ Won't create duplicate admin users
- ✅ Won't create duplicate categories/fields/checkpoints
- ✅ Will update existing data if needed

## 🛠️ Troubleshooting

### MongoDB not running?
```bash
systemctl status mongod
systemctl start mongod
```

### Database connection error?
Check your `.env` file:
```bash
cat /var/www/eventorganising/backend/.env
```

Make sure `DATABASE_URL` is correct:
```
DATABASE_URL=mongodb://localhost:27017/eventorganising
```

### Permission errors?
```bash
chmod +x /var/www/eventorganising/backend/scripts/init_database.py
```

## 📊 Verify Database

After initialization, you can verify in MongoDB:

```bash
# Connect to MongoDB
mongosh mongodb://localhost:27017/eventorganising

# Check collections
show collections

# Check admin user
db.User.find({email: "admin@example.com"})

# Check roles
db.Role.find({userId: "..."})

# Check service categories
db.ServiceCategory.find()

# Check form fields
db.FormFieldConfig.find()

# Check verification checkpoints
db.VerificationCheckpointConfig.find()
```

## ✅ Done!

Your database is now fully initialized with:
- ✅ All schemas/collections created
- ✅ Admin user with authentication
- ✅ Default data seeded

You can now use your application!

