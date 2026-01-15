# Ivy League Fantasy Swimming - Backend API

FastAPI backend service that serves scraped swimmer data to the iOS app.

## Quick Start

### Local Development

```bash
# From project root
docker-compose up --build

# Or run directly with Python
cd backend
pip install -r requirements.txt
python main.py
```

API available at:
- **Base URL**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs (Swagger UI)
- **Health Check**: http://localhost:8000/health

## API Endpoints

### Health & Info
- `GET /` - Service information and health
- `GET /health` - Health check endpoint

### Swimmers
- `GET /api/swimmers` - Get all swimmers (supports filtering)
  - Query params: `?school=Harvard&class_year=SR&event=100 Y Free`
- `GET /api/swimmers/{id}` - Get specific swimmer by SwimCloud ID

### Data
- `GET /api/schools` - List all schools with swimmer counts
- `GET /api/events` - List all events with swimmer counts
- `POST /api/reload` - Reload data from JSON files

### Placeholders (not yet implemented)
- `GET /api/meet/results` - Meet results
- `GET /api/league/standings` - Fantasy league standings

## Docker Deployment

See [DEPLOYMENT.md](../DEPLOYMENT.md) for full deployment instructions.

### Build Image
```bash
docker build -t usaiinc/ivy-swim-backend:latest .
```

### Push to Docker Hub
```bash
docker push usaiinc/ivy-swim-backend:latest
```

### Run Container
```bash
docker run -d \
  -p 8000:8000 \
  -v /path/to/data:/app/data:ro \
  usaiinc/ivy-swim-backend:latest
```

## Architecture

```
┌─────────────────┐
│   iOS App       │
│   (SwiftUI)     │
└────────┬────────┘
         │ HTTP
         ▼
┌─────────────────┐
│  FastAPI        │
│  Backend        │◄──── Docker Container
│  (main.py)      │
└────────┬────────┘
         │ reads
         ▼
┌─────────────────┐
│  JSON Data      │
│  (scraped)      │◄──── Mounted Volume
│  /app/data/     │
└─────────────────┘
```

## Data Format

The backend expects JSON files in the mounted data directory:

```
/app/data/
  ├── harvard_swimmers.json
  ├── yale_swimmers.json
  ├── princeton_swimmers.json
  └── ...
```

Each file contains an array of swimmer objects:

```json
[
  {
    "swimcloud_id": 418666,
    "name": "Matthew Chung",
    "first_name": "Matthew",
    "last_name": "Chung",
    "hometown": "San Francisco, CA",
    "class_year": "SR",
    "school": "Harvard",
    "times": [
      {
        "event": "100 Y Free",
        "time": "46.28",
        "time_seconds": 46.28,
        "course": "SCY"
      }
    ]
  }
]
```

## Environment Variables

- `DATA_DIR` - Directory containing JSON files (default: `/app/data`)
- `PORT` - Port to run on (default: `8000`)
- `PYTHONUNBUFFERED` - Disable Python output buffering (set to `1`)

## Development

### Run with Hot Reload

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Test Endpoints

```bash
# Get all swimmers
curl http://localhost:8000/api/swimmers

# Filter by school
curl "http://localhost:8000/api/swimmers?school=Harvard"

# Filter by class year
curl "http://localhost:8000/api/swimmers?class_year=SR"

# Get specific swimmer
curl http://localhost:8000/api/swimmers/418666

# Get schools
curl http://localhost:8000/api/schools

# Get events
curl http://localhost:8000/api/events
```

## Dependencies

- **FastAPI** - Modern Python web framework
- **Uvicorn** - ASGI server
- **Pydantic** - Data validation

See [requirements.txt](requirements.txt) for versions.

## Future Enhancements

- [ ] Add database (PostgreSQL) for persistent storage
- [ ] Implement meet results scraping and endpoints
- [ ] Add fantasy league logic and scoring
- [ ] Add authentication/API keys
- [ ] Add caching layer (Redis)
- [ ] Add WebSocket support for live meet updates
- [ ] Add admin endpoints for data management
