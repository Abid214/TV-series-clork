# # Stage 1: Build React frontend
# FROM node:18 AS frontend

# WORKDIR /app/frontend
# COPY frontend/package*.json ./
# RUN npm install
# COPY frontend/ .
# RUN npm run build

# # Stage 2: Set up Django
# FROM python:3.11-slim

# ENV PYTHONDONTWRITEBYTECODE 1
# ENV PYTHONUNBUFFERED 1

# WORKDIR /app

# # Install system dependencies
# RUN apt-get update && apt-get install -y \
#     build-essential libpq-dev curl && \
#     rm -rf /var/lib/apt/lists/*

# # Install Python dependencies
# COPY backend/requirements.txt .
# RUN pip install --upgrade pip && pip install -r requirements.txt

# # Copy backend and frontend build
# COPY backend/ ./backend/
# COPY --from=frontend /app/frontend/dist/ ./frontend_dist/

# # Set environment variables
# ENV DJANGO_SETTINGS_MODULE=backend.settings

# # Collect static files
# WORKDIR /app/backend
# RUN python manage.py collectstatic --noinput

# EXPOSE 8000
# CMD ["gunicorn", "backend.wsgi:application", "--bind", "0.0.0.0:8000"]

# Stage 1: Frontend build
FROM node:18 AS frontend

WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ .
RUN npm run build

# Stage 2: Django backend
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV DJANGO_SETTINGS_MODULE=backend.settings

# Create a non-root user
RUN useradd -m appuser
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential libpq-dev curl && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY backend/requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy backend and frontend build
COPY backend/ ./backend/
COPY --from=frontend /app/frontend/dist/ ./backend/static/

# Set ownership
RUN chown -R appuser:appuser /app

USER appuser

WORKDIR /app/backend
RUN python manage.py collectstatic --noinput

EXPOSE 8000
CMD ["gunicorn", "backend.wsgi:application", "--bind", "0.0.0.0:8000"]