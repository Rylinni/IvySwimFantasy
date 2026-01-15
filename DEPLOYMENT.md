# Deployment Guide - Ivy League Fantasy Swimming Backend

This guide explains how to build, push, and deploy the backend API using Docker and Docker Hub.

## Architecture Overview

```
Local Dev                          Docker Hub                    Production Server
┌─────────────┐                   ┌──────────────┐              ┌─────────────────┐
│             │   docker push     │              │  docker pull │                 │
│  Build      ├──────────────────►│  usaiinc/    ├─────────────►│  Backend API    │
│  Dockerfile │                   │  ivy-swim-   │              │  Running in     │
│             │                   │  backend     │              │  Container      │
└─────────────┘                   └──────────────┘              └─────────────────┘
```

## Prerequisites

1. **Docker** installed locally
2. **Docker Hub account** with access to `usaiinc` organization
3. **SSH access** to production server (if deploying)

## Quick Start - Local Development

Run the backend locally with hot-reload:

```bash
# From project root
docker-compose up --build

# Backend API available at http://localhost:8000
# API docs at http://localhost:8000/docs
```

This mounts your local `scraper/` directory so the API can read the JSON files.

## Production Deployment Workflow

### Step 1: Build the Docker Image

```bash
cd backend

# Build the image with a tag
docker build -t usaiinc/ivy-swim-backend:latest .

# Optional: tag with version
docker build -t usaiinc/ivy-swim-backend:v1.0.0 .
```

### Step 2: Test the Image Locally

```bash
# Run the container locally to test
docker run -d \
  -p 8000:8000 \
  -v $(pwd)/../scraper:/app/data:ro \
  --name ivy-swim-backend-test \
  usaiinc/ivy-swim-backend:latest

# Check health
curl http://localhost:8000/health

# Check swimmers
curl http://localhost:8000/api/swimmers

# Stop and remove test container
docker stop ivy-swim-backend-test
docker rm ivy-swim-backend-test
```

### Step 3: Push to Docker Hub

```bash
# Login to Docker Hub
docker login

# Push the image
docker push usaiinc/ivy-swim-backend:latest

# If you tagged with version, push that too
docker push usaiinc/ivy-swim-backend:v1.0.0
```

### Step 4: Deploy to Production Server

**Option A: SSH in and deploy manually**

```bash
# SSH into production server
ssh user@your-production-server.com

# Create data directory if it doesn't exist
mkdir -p /opt/ivy-swim/data

# Copy scraper JSON files to data directory
# (You'll need to set up a process to sync these regularly)

# Copy docker-compose.prod.yml to server
# Then run:
cd /opt/ivy-swim
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```

**Option B: Have your roommate deploy**

```bash
# Send only docker-compose.prod.yml to your roommate
# They will:
1. Place it on the production server
2. Run: docker-compose -f docker-compose.prod.yml pull
3. Run: docker-compose -f docker-compose.prod.yml up -d
```

### Step 5: Verify Deployment

```bash
# Check container status
docker ps

# Check logs
docker logs ivy-swim-backend-prod

# Test API
curl http://your-server:8000/health
curl http://your-server:8000/api/swimmers
```

## Update Workflow

When you make changes to the backend:

```bash
# 1. Build new image
cd backend
docker build -t usaiinc/ivy-swim-backend:latest .

# 2. Test locally (optional but recommended)
docker run -d -p 8000:8000 -v $(pwd)/../scraper:/app/data:ro usaiinc/ivy-swim-backend:latest
# Test endpoints...
docker stop <container-id>

# 3. Push to Docker Hub
docker push usaiinc/ivy-swim-backend:latest

# 4. On production server (or tell your roommate):
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```

## Environment Configuration

### docker-compose.yml (Local Development)

- Builds from local Dockerfile
- Mounts `./scraper` directory as `/app/data`
- Hot-reload enabled (mounts `main.py`)
- Port 8000 exposed

### docker-compose.prod.yml (Production)

- Uses remote image from Docker Hub: `usaiinc/ivy-swim-backend:latest`
- Mounts server data directory (update path in file)
- Restart policy: `always`
- Logging configured

**IMPORTANT**: Update the volume path in `docker-compose.prod.yml`:

```yaml
volumes:
  - /path/to/data:/app/data:ro  # Change this to your actual data directory
```

## API Endpoints

Once deployed, the backend provides:

| Endpoint | Description |
|----------|-------------|
| `GET /` | Health check + service info |
| `GET /health` | Health check for monitoring |
| `GET /api/swimmers` | Get all swimmers (with filters) |
| `GET /api/swimmers/{id}` | Get specific swimmer |
| `GET /api/schools` | List all schools |
| `GET /api/events` | List all events |
| `POST /api/reload` | Reload data from JSON files |

**Query Parameters for `/api/swimmers`:**
- `school` - Filter by school (e.g., `?school=Harvard`)
- `class_year` - Filter by class year (e.g., `?class_year=SR`)
- `event` - Filter by event (e.g., `?event=100 Y Free`)

## Data Volume

The backend needs access to scraped JSON files. These should be in the mounted data directory:

```
/app/data/
  ├── harvard_swimmers.json
  ├── yale_swimmers.json
  ├── princeton_swimmers.json
  ├── columbia_swimmers.json
  ├── penn_swimmers.json
  ├── brown_swimmers.json
  ├── cornell_swimmers.json
  └── dartmouth_swimmers.json
```

## Updating iOS App to Use Backend

Update `Services/DataService.swift`:

```swift
private let baseURL = "http://your-server:8000/api"  // Change to your production URL

// Then implement the fetchSwimmers() method to call /api/swimmers
```

## Monitoring

**Health checks:**
```bash
curl http://your-server:8000/health
```

**View logs:**
```bash
docker logs ivy-swim-backend-prod -f
```

**Container stats:**
```bash
docker stats ivy-swim-backend-prod
```

## Troubleshooting

### Container won't start
```bash
docker logs ivy-swim-backend-prod
docker inspect ivy-swim-backend-prod
```

### No swimmers loaded
- Check data directory is mounted correctly
- Check JSON files exist and are readable
- Check logs for parsing errors

### Can't reach API
- Check port 8000 is exposed and not blocked by firewall
- Check container is running: `docker ps`
- Check network settings in docker-compose.prod.yml

### Out of memory
```bash
# Check memory usage
docker stats

# Restart container
docker-compose -f docker-compose.prod.yml restart
```

## Security Notes

1. **CORS**: Currently allows all origins (`allow_origins=["*"]`). Update in production:
   ```python
   allow_origins=["https://your-ios-app-domain.com"]
   ```

2. **Data directory**: Mounted as read-only (`:ro`) for security

3. **Secrets**: If you add database/API keys, use Docker secrets or environment variables

## Next Steps

1. Set up automated scraper to update JSON files regularly
2. Add authentication/API keys if needed
3. Set up HTTPS/reverse proxy (nginx)
4. Add database for persistent storage
5. Implement fantasy league logic endpoints
6. Add meet results scraping and endpoints
