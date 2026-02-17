# Upload Commands for Latest Changes

## Frontend Upload

Upload the built frontend to the server:

```bash
cd /Users/shivangnayar/eventorganising/frontend
rsync -avz --delete build/web/ root@72.61.232.15:/var/www/eventorganising/frontend/
```

## Backend Upload

Upload the backend code to the server:

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

### 2. Run Seed Script (first time only - to populate form fields)

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

## Notes

- You'll be prompted for the SSH password when running rsync commands
- The `--delete` flag for frontend removes files on server that don't exist locally
- The `--exclude` flags for backend prevent uploading virtual environment and cache files
- Backend service restart is required for code changes to take effect
- Frontend changes take effect immediately (no restart needed)

