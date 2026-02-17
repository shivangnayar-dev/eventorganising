# 🗄️ Create Database Structure - Step by Step Guide

This guide will help you create the complete database structure with all schemas and authentication on your server.

## 📋 What Will Be Created

1. **Database Collections/Schemas:**
   - User (with authentication)
   - Role (user roles)
   - ServiceCategory
   - FormFieldConfig
   - VerificationCheckpointConfig
   - ServiceListing
   - ServiceProvider
   - Booking
   - Review
   - VerificationAssignment
   - ManagerAssignment
   - NodalOfficerAssignment
   - NodalOfficerRecommendation
   - RefreshToken

2. **Initial Data:**
   - Admin user with authentication
   - 8 Service Categories
   - 10 Form Field Configurations
   - 11 Verification Checkpoint Configurations

---

## 🚀 Method 1: Upload Script and Run (Recommended)

### Step 1: Upload the Script

**Run this on your LOCAL machine (Mac):**

```bash
cd /Users/shivangnayar/eventorganising
rsync -avz backend_python/scripts/init_database.py root@72.61.232.15:/var/www/eventorganising/backend/scripts/
```

You'll be prompted for your SSH password.

### Step 2: Run on Server

**SSH into your server:**
```bash
ssh root@72.61.232.15
```

**Navigate to backend and activate virtual environment:**
```bash
cd /var/www/eventorganising/backend
source venv/bin/activate
```

**Run the initialization script:**
```bash
python scripts/init_database.py
```

---

## 🚀 Method 2: Create Script Directly on Server

If you prefer to create the script directly on the server:

**SSH into your server:**
```bash
ssh root@72.61.232.15
cd /var/www/eventorganising/backend
source venv/bin/activate
```

**Create the script:**
```bash
nano scripts/init_database.py
```

**Then copy the entire content from:** `backend_python/scripts/init_database.py`

**Save:** Press `Ctrl+X`, then `Y`, then `Enter`

**Make it executable:**
```bash
chmod +x scripts/init_database.py
```

**Run it:**
```bash
python scripts/init_database.py
```

---

## 🚀 Method 3: Run Individual Scripts

If you prefer to run the existing scripts individually:

**On your server:**
```bash
cd /var/www/eventorganising/backend
source venv/bin/activate

# 1. Create admin user
python scripts/create_admin.py

# 2. Seed form fields
python scripts/seed_form_fields.py

# 3. Seed verification checkpoints
python scripts/seed_verification_checkpoints.py
```

---

## ✅ Expected Output

When you run `init_database.py`, you should see:

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
✅ Created category: Party Halls
✅ Created category: Banquet Halls
✅ Created category: Outdoor Venues
✅ Created category: Restaurants
✅ Created category: Hotels
✅ Created category: Community Centers

📝 Seeding Form Field Configurations
============================================================
✅ Created field: Property/Venue Name (title)
✅ Created field: Description (description)
✅ Created field: Location (location)
✅ Created field: Full Address (address)
✅ Created field: Pincode (pincode)
✅ Created field: Guest Capacity (capacity)
✅ Created field: Property Type (propertyType)
✅ Created field: Event Types (eventTypes)
✅ Created field: Amenities (amenities)
✅ Created field: Price Per Day (pricePerDay)

✅ Seeding Verification Checkpoint Configurations
============================================================
✅ Created checkpoint: Venue Exists at Location (venue_exists)
✅ Created checkpoint: Details Accuracy (details_accuracy)
✅ Created checkpoint: Overall Venue Rating (overall_rating)
✅ Created checkpoint: Capacity Verification (capacity_verification)
✅ Created checkpoint: Amenities Verification (amenities_verification)
✅ Created checkpoint: Location Accuracy (location_accuracy)
✅ Created checkpoint: Safety & Compliance Check (safety_compliance)
✅ Created checkpoint: Upload Venue Photos (photo_uploads)
✅ Created checkpoint: Upload Venue Videos (Optional) (video_uploads)
✅ Created checkpoint: Additional Feedback (additional_feedback)
✅ Created checkpoint: Verification Recommendation (recommendation)

✅ Database Initialization Complete!
============================================================
```

---

## 🔍 Verify Database Structure

After running the script, verify everything was created:

**Connect to MongoDB:**
```bash
mongosh mongodb://localhost:27017/eventorganising
```

**Check collections:**
```javascript
show collections
```

You should see:
- User
- Role
- ServiceCategory
- FormFieldConfig
- VerificationCheckpointConfig
- (and other collections as they're used)

**Check admin user:**
```javascript
db.User.find({email: "admin@example.com"}).pretty()
```

**Check roles:**
```javascript
db.Role.find().pretty()
```

**Check service categories:**
```javascript
db.ServiceCategory.find().pretty()
```

**Check form fields:**
```javascript
db.FormFieldConfig.find().pretty()
```

**Check verification checkpoints:**
```javascript
db.VerificationCheckpointConfig.find().pretty()
```

**Exit MongoDB:**
```javascript
exit
```

---

## 🔐 Admin Login Credentials

After initialization, you can login with:
- **Email:** `admin@example.com`
- **Password:** `Pass@1234`
- **Roles:** ADMIN, MANAGER

---

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

### Script not found?
Make sure you're in the correct directory:
```bash
cd /var/www/eventorganising/backend
ls -la scripts/
```

### Permission denied?
```bash
chmod +x scripts/init_database.py
```

### Python module errors?
Make sure virtual environment is activated:
```bash
source venv/bin/activate
pip list | grep fastapi
```

---

## 📊 Database Schema Overview

The database will have these main collections:

1. **User** - User accounts with authentication
2. **Role** - User roles (ADMIN, MANAGER, NODAL_OFFICER, PROVIDER)
3. **ServiceCategory** - Categories for venues (Wedding, Conference, etc.)
4. **FormFieldConfig** - Dynamic form field configurations
5. **VerificationCheckpointConfig** - Verification checkpoint configurations
6. **ServiceListing** - Venue/service listings
7. **ServiceProvider** - Service provider profiles
8. **Booking** - Booking records
9. **Review** - Reviews and ratings
10. **VerificationAssignment** - Verification assignments for nodal officers
11. **ManagerAssignment** - Manager assignments
12. **NodalOfficerAssignment** - Nodal officer assignments
13. **NodalOfficerRecommendation** - Recommendations from nodal officers
14. **RefreshToken** - JWT refresh tokens

---

## ✅ Next Steps

After creating the database structure:

1. ✅ Test login at: http://72.61.232.15
2. ✅ Login with admin credentials
3. ✅ Explore the admin dashboard
4. ✅ Check form field configurations
5. ✅ Check verification checkpoint configurations

---

## 🔄 Re-running the Script

The script is **idempotent** - safe to run multiple times:
- ✅ Won't create duplicate users
- ✅ Won't create duplicate categories/fields/checkpoints
- ✅ Will update existing data if needed

Run it anytime to ensure your database is properly initialized!

