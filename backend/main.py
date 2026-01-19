"""
Ivy League Fantasy Swimming - Backend API
FastAPI server that serves scraped swimmer data to the iOS app
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Optional
import json
import os
from pathlib import Path
from datetime import datetime

app = FastAPI(
    title="Ivy League Fantasy Swimming API",
    version="1.0.0",
    description="Backend API for Ivy League Fantasy Swimming app"
)

# CORS middleware for iOS app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Data directory - will be mounted as volume in Docker
DATA_DIR = Path(os.getenv("DATA_DIR", "/app/data"))

# In-memory cache for swimmer data
swimmers_cache = {}
last_loaded = None


def load_swimmer_data():
    """Load all swimmer JSON files from data directory"""
    global swimmers_cache, last_loaded

    swimmers = []
    schools = ["harvard", "yale", "princeton", "columbia", "penn", "brown", "cornell", "dartmouth"]

    for school in schools:
        json_file = DATA_DIR / f"{school}_swimmers.json"
        if json_file.exists():
            try:
                with open(json_file, 'r') as f:
                    school_swimmers = json.load(f)
                    if isinstance(school_swimmers, list):
                        swimmers.extend(school_swimmers)
                    else:
                        swimmers.append(school_swimmers)
            except Exception as e:
                print(f"Error loading {json_file}: {e}")

    swimmers_cache = swimmers
    last_loaded = datetime.now()
    print(f"Loaded {len(swimmers)} swimmers from {DATA_DIR}")
    return swimmers


@app.on_event("startup")
async def startup_event():
    """Load swimmer data on startup"""
    load_swimmer_data()


@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "status": "ok",
        "service": "Ivy League Fantasy Swimming API",
        "version": "1.0.0",
        "swimmers_loaded": len(swimmers_cache),
        "last_loaded": last_loaded.isoformat() if last_loaded else None
    }


@app.get("/health")
async def health():
    """Health check for Docker/K8s"""
    return {"status": "healthy"}


@app.get("/api/swimmers")
async def get_swimmers(
    school: Optional[str] = None,
    class_year: Optional[str] = None,
    event: Optional[str] = None
):
    """
    Get all swimmers with optional filters

    Query params:
    - school: Filter by school name (e.g., "Harvard")
    - class_year: Filter by class year (e.g., "SR", "JR")
    - event: Filter swimmers who have times in this event (e.g., "100 Y Free")
    """
    if not swimmers_cache:
        load_swimmer_data()

    swimmers = swimmers_cache

    # Apply filters
    if school:
        swimmers = [s for s in swimmers if s.get("school", "").lower() == school.lower()]

    if class_year:
        swimmers = [s for s in swimmers if s.get("class_year", "").upper() == class_year.upper()]

    if event:
        swimmers = [
            s for s in swimmers
            if any(t.get("event") == event for t in s.get("times", []))
        ]

    return {
        "swimmers": swimmers,
        "count": len(swimmers),
        "filters": {
            "school": school,
            "class_year": class_year,
            "event": event
        }
    }


@app.get("/api/swimmers/{swimmer_id}")
async def get_swimmer(swimmer_id: int):
    """Get a specific swimmer by SwimCloud ID"""
    if not swimmers_cache:
        load_swimmer_data()

    swimmer = next(
        (s for s in swimmers_cache if s.get("swimcloud_id") == swimmer_id),
        None
    )

    if not swimmer:
        raise HTTPException(status_code=404, detail=f"Swimmer {swimmer_id} not found")

    return swimmer


@app.get("/api/schools")
async def get_schools():
    """Get list of all schools with swimmer counts"""
    if not swimmers_cache:
        load_swimmer_data()

    schools = {}
    for swimmer in swimmers_cache:
        school = swimmer.get("school", "Unknown")
        schools[school] = schools.get(school, 0) + 1

    return {
        "schools": [
            {"name": name, "swimmer_count": count}
            for name, count in sorted(schools.items())
        ]
    }


@app.get("/api/events")
async def get_events():
    """Get list of all events with swimmer counts"""
    if not swimmers_cache:
        load_swimmer_data()

    events = {}
    for swimmer in swimmers_cache:
        for time_entry in swimmer.get("times", []):
            event = time_entry.get("event")
            if event:
                events[event] = events.get(event, 0) + 1

    return {
        "events": [
            {"event": name, "swimmer_count": count}
            for name, count in sorted(events.items())
        ]
    }


@app.post("/api/reload")
async def reload_data():
    """Reload swimmer data from files (useful after scraper runs)"""
    swimmers = load_swimmer_data()
    return {
        "status": "reloaded",
        "swimmers_loaded": len(swimmers),
        "timestamp": datetime.now().isoformat()
    }


@app.get("/api/meet/results")
async def get_meet_results():
    """
    Placeholder for meet results endpoint
    TODO: Implement when meet scraping is added
    """
    return {
        "message": "Meet results endpoint - not yet implemented",
        "status": "placeholder"
    }


@app.get("/api/league/standings")
async def get_league_standings():
    """
    Placeholder for fantasy league standings
    TODO: Implement fantasy league logic
    """
    return {
        "message": "League standings endpoint - not yet implemented",
        "status": "placeholder"
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
