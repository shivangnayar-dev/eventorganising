# Upload Latest Changes to Server

## Frontend Upload (Latest Landing Page Improvements)

The frontend has been built successfully. Upload it with:

```bash
cd /Users/shivangnayar/eventorganising/frontend
rsync -avz --delete build/web/ root@72.61.232.15:/var/www/eventorganising/frontend/
```

## Backend Upload (Form Field Configurations)

Upload the backend code:

```bash
cd /Users/shivangnayar/eventorganising
rsync -avz --exclude 'venv' --exclude '__pycache__' --exclude '*.pyc' --exclude '.env' --exclude 'logs' backend_python/ root@72.61.232.15:/var/www/eventorganising/backend/
```

## After Upload

### 1. Restart Backend Service (on server)

```bash
ssh root@72.61.232.15
sudo systemctl restart eventorganising-backend
sudo systemctl status eventorganising-backend
```

### 2. Run Seed Script (if not already run - to populate form fields)

```bash
ssh root@72.61.232.15
cd /var/www/eventorganising/backend
source venv/bin/activate
python scripts/seed_form_fields.py
```

This will create the default form field configurations in the database.

### 3. Check Frontend (no restart needed)

The frontend files are static, so no restart is needed. Just refresh your browser at:
- http://72.61.232.15

## What's New

### Frontend:
✅ Modern landing page with improved UI
✅ Dual CTAs in hero section (for customers and business owners)
✅ New "How to Add Your Venue" section explaining the process
✅ Trust badges and verification indicators throughout
✅ Enhanced visual design with gradients and modern styling

### Backend:
✅ Form field configuration system (already uploaded)
✅ Admin can manage form fields (already uploaded)

## Notes

- You'll be prompted for the SSH password when running rsync commands
- Frontend changes take effect immediately (just refresh browser)
- Backend changes require service restart
- Run the seed script once to populate default form fields

