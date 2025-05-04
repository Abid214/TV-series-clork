#!/usr/bin/env bash
cd backend
pip install -r ../requirements.txt
python manage.py migrate
python manage.py collectstatic --noinput
#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -o errexit

# Navigate to the backend directory
cd backend

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Run migrations
python manage.py migrate

# Collect static files
python manage.py collectstatic --noinput
