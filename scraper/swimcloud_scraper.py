#!/usr/bin/env python3
"""
SwimCloud Scraper for Ivy League Swimming Teams
Scrapes roster and swimmer times from SwimCloud.com
"""

from __future__ import annotations

import requests
from bs4 import BeautifulSoup
import json
import time
import re
from typing import Optional
from dataclasses import dataclass, asdict

# SwimCloud team IDs for Ivy League schools (Men's Swimming)
IVY_TEAMS = {
    "harvard": 134,
    "yale": 376,
    "princeton": 477,
    "columbia": 283,
    "penn": 416,
    "brown": 17,
    "cornell": 258,
    "dartmouth": 272,
}

# Season ID to name mapping
SEASON_NAMES = {
    29: "2025-2026",
    28: "2024-2025",
    27: "2023-2024",
    26: "2022-2023",
    25: "2021-2022",
    24: "2020-2021",
    23: "2019-2020",
    22: "2018-2019",
}

BASE_URL = "https://www.swimcloud.com"

# Request headers to mimic a browser
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.5",
}


@dataclass
class SwimTime:
    """Represents a swimmer's time in an event"""
    event: str
    time: str
    time_seconds: Optional[float]
    course: str  # 'SCY', 'SCM', 'LCM'
    is_personal_best: bool = False


@dataclass
class Swimmer:
    """Represents a swimmer on a team"""
    swimcloud_id: int
    name: str
    first_name: str
    last_name: str
    hometown: Optional[str]
    class_year: Optional[str]  # FR, SO, JR, SR
    school: str
    times: list[SwimTime]
    profile_url: str


def parse_time_to_seconds(time_str: str) -> Optional[float]:
    """Convert a swim time string to seconds (e.g., '1:45.32' -> 105.32)"""
    if not time_str or time_str == "–":
        return None

    time_str = time_str.strip()

    try:
        # Handle MM:SS.ss format
        if ":" in time_str:
            parts = time_str.split(":")
            if len(parts) == 2:
                minutes = int(parts[0])
                seconds = float(parts[1])
                return minutes * 60 + seconds
            elif len(parts) == 3:
                # HH:MM:SS.ss format (rare but possible for distance events)
                hours = int(parts[0])
                minutes = int(parts[1])
                seconds = float(parts[2])
                return hours * 3600 + minutes * 60 + seconds
        else:
            # Just seconds (e.g., '23.45')
            return float(time_str)
    except (ValueError, IndexError):
        return None


def get_roster(team_id: int, school_name: str, season_id: Optional[int] = None) -> list[dict]:
    """
    Fetch the roster for a team from SwimCloud
    Returns list of basic swimmer info (need to fetch profiles for times)

    season_id mapping:
        29: 2025-2026
        28: 2024-2025
        27: 2023-2024
        26: 2022-2023
        25: 2021-2022
        24: 2020-2021
    """
    url = f"{BASE_URL}/team/{team_id}/roster/"
    if season_id:
        url += f"?season_id={season_id}"
    print(f"Fetching roster from: {url}")

    response = requests.get(url, headers=HEADERS)
    response.raise_for_status()

    soup = BeautifulSoup(response.text, "lxml")
    swimmers = []

    # Find the roster table
    table = soup.find("table")
    if not table:
        print("No roster table found")
        return swimmers

    rows = table.find_all("tr")[1:]  # Skip header row

    for row in rows:
        cells = row.find_all("td")
        if len(cells) < 4:
            continue

        # Table structure: [rank, name, hometown, class, score]
        # Get swimmer link and name from cell 1
        name_cell = cells[1]
        link = name_cell.find("a")
        if not link:
            continue

        href = link.get("href", "")
        # Extract swimmer ID from URL like /swimmer/417509/
        match = re.search(r"/swimmer/(\d+)/?$", href)
        if not match:
            continue

        swimmer_id = int(match.group(1))
        name = link.get_text(strip=True)

        # Skip relay placeholders
        if " A" in name or " B" in name or not name:
            continue

        # Parse name into first/last
        name_parts = name.split()
        first_name = name_parts[0] if name_parts else ""
        last_name = " ".join(name_parts[1:]) if len(name_parts) > 1 else ""

        # Get hometown from cell 2
        hometown = cells[2].get_text(strip=True) if len(cells) > 2 else None
        if hometown == "–":
            hometown = None

        # Get class year from cell 3
        class_year = cells[3].get_text(strip=True) if len(cells) > 3 else None
        if class_year == "–":
            class_year = None

        swimmers.append({
            "swimcloud_id": swimmer_id,
            "name": name,
            "first_name": first_name,
            "last_name": last_name,
            "hometown": hometown,
            "class_year": class_year,
            "school": school_name,
            "profile_url": f"{BASE_URL}{href}",
        })

    print(f"Found {len(swimmers)} swimmers on roster")
    return swimmers


def clean_event_name(event_text: str) -> tuple[str, str]:
    """
    Clean up event name and extract round info (Finals, Prelims, etc.)
    Returns (cleaned_event, round_type)
    """
    # Common round types that get concatenated
    round_types = ["Timed Finals", "Finals", "Prelims", "Time Trial", "Swim-off"]

    round_type = ""
    cleaned = event_text

    for rt in round_types:
        if rt in cleaned:
            round_type = rt
            cleaned = cleaned.replace(rt, "").strip()
            break

    # Clean up common formatting issues
    # "200 Y Breast" -> "200 Y Breast"
    cleaned = re.sub(r'\s+', ' ', cleaned).strip()

    return cleaned, round_type


def is_50_non_free(event_name: str) -> bool:
    """Check if event is a 50 that's NOT freestyle"""
    if event_name.startswith('50 '):
        return 'Free' not in event_name
    return False


def get_event_priority(event_name: str, course: str) -> int:
    """
    Get priority tier for an event (lower = higher priority):
    1. SCY events (excluding 50s that aren't 50 Free)
    2. LCM/SCM events
    3. 50s that aren't 50 Free (lowest priority)
    """
    if is_50_non_free(event_name):
        return 3  # Lowest priority
    elif course == 'SCY':
        return 1  # Highest priority
    else:  # LCM/SCM
        return 2  # Middle priority


def select_top_5_events(times: list[SwimTime]) -> list[SwimTime]:
    """
    Select the top 5 most important events for a swimmer.

    Priority order:
    1. SCY events (excluding non-free 50s) - sorted by time
    2. LCM/SCM events - sorted by time
    3. 50s that aren't 50 Free - sorted by time (lowest priority)

    Returns list of top 5 SwimTime objects.
    """
    # Add priority to each time and categorize
    tier1 = []  # SCY (no bad 50s)
    tier2 = []  # LCM/SCM
    tier3 = []  # 50s (non-free)

    for t in times:
        priority = get_event_priority(t.event, t.course)
        if priority == 1:
            tier1.append(t)
        elif priority == 2:
            tier2.append(t)
        else:
            tier3.append(t)

    # Sort each tier by time (fastest first)
    tier1.sort(key=lambda x: x.time_seconds if x.time_seconds else float('inf'))
    tier2.sort(key=lambda x: x.time_seconds if x.time_seconds else float('inf'))
    tier3.sort(key=lambda x: x.time_seconds if x.time_seconds else float('inf'))

    # Fill top 5 from tiers in priority order
    top_5 = []
    for tier in [tier1, tier2, tier3]:
        for event in tier:
            if len(top_5) < 5:
                top_5.append(event)

    return top_5


def get_swimmer_times(swimmer_id: int, target_season_id: Optional[int] = None) -> list[SwimTime]:
    """
    Fetch personal best times for a swimmer from their progression chart.
    
    Uses the embedded progression chart JSON data which contains season-by-season
    best times. This is more reliable than scraping individual time entries.
    
    Args:
        swimmer_id: SwimCloud swimmer ID
        target_season_id: If provided, only return times from this specific season.
                         If None, returns all-time best times across all seasons.
    
    Returns:
        List of SwimTime objects (up to top 6 events by performance)
    """
    url = f"{BASE_URL}/swimmer/{swimmer_id}/"

    response = requests.get(url, headers=HEADERS)
    response.raise_for_status()

    # Extract progression chart data from embedded JavaScript
    # Pattern: const data = [{...season data...}];
    match = re.search(
        r'js-swimmer-profile-overall-progress.*?const data = (\[.*?\]);',
        response.text,
        re.DOTALL
    )
    
    if not match:
        # Fallback: try the old method if progression chart not found
        return get_swimmer_times_legacy(swimmer_id)
    
    try:
        progression_data = json.loads(match.group(1))
    except json.JSONDecodeError:
        return get_swimmer_times_legacy(swimmer_id)
    
    # Collect all-time best times across all seasons (or just target season)
    best_times: dict[str, SwimTime] = {}
    
    for season in progression_data:
        season_id = season.get('season_id')
        season_label = season.get('season_label', '')
        
        # If targeting a specific season, skip others
        if target_season_id is not None and season_id != target_season_id:
            continue
        
        fastest_times = season.get('fastest_times', [])
        
        for time_entry in fastest_times:
            event_name = time_entry.get('event', '')
            time_text = time_entry.get('time', '')
            
            # Skip relay and diving events
            if "Relay" in event_name or "Diving" in event_name or "dives" in event_name.lower():
                continue
            
            # Determine course (yards vs meters)
            course = "SCY"  # Default to yards
            if " L " in event_name:
                course = "LCM"
            elif " S " in event_name:
                course = "SCM"
            
            time_seconds = parse_time_to_seconds(time_text)
            if time_seconds is None:
                continue
            
            # Keep only the best (fastest) time for each event across all seasons
            if event_name not in best_times or time_seconds < best_times[event_name].time_seconds:
                best_times[event_name] = SwimTime(
                    event=event_name,
                    time=time_text,
                    time_seconds=time_seconds,
                    course=course,
                    is_personal_best=True,
                )
    
    # Convert to list
    times = list(best_times.values())

    # Select top 5 using the priority heuristic:
    # 1. SCY events (excluding non-free 50s)
    # 2. LCM/SCM events
    # 3. 50s that aren't 50 Free (lowest priority)
    return select_top_5_events(times)


def get_swimmer_times_legacy(swimmer_id: int) -> list[SwimTime]:
    """
    Legacy method: Extract times from embedded JSON event/time pairs.
    Used as fallback when progression chart data is not available.
    """
    url = f"{BASE_URL}/swimmer/{swimmer_id}/"

    response = requests.get(url, headers=HEADERS)
    response.raise_for_status()

    # Extract times from embedded JSON in the page
    # Pattern matches: {"event": "50 Y Free", "time": "19.57"}
    matches = re.findall(r'\{"event":\s*"([^"]+)",\s*"time":\s*"([^"]+)"\}', response.text)

    # Collect all times, tracking best per event
    best_times: dict[str, SwimTime] = {}

    for event_name, time_text in matches:
        # Skip relay splits and diving
        if "Relay" in event_name or "Diving" in event_name or "dives" in event_name.lower():
            continue

        # Determine course (yards vs meters)
        course = "SCY"  # Default to yards
        if " L " in event_name:
            course = "LCM"
        elif " S " in event_name:
            course = "SCM"

        time_seconds = parse_time_to_seconds(time_text)
        if time_seconds is None:
            continue

        # Keep only the best (fastest) time for each event
        if event_name not in best_times or time_seconds < best_times[event_name].time_seconds:
            best_times[event_name] = SwimTime(
                event=event_name,
                time=time_text,
                time_seconds=time_seconds,
                course=course,
                is_personal_best=True,
            )

    # Convert to list and select top 5 using priority heuristic
    times = list(best_times.values())
    return select_top_5_events(times)


def get_swimmer_times_old(swimmer_id: int) -> list[SwimTime]:
    """
    OLD METHOD: Fetch times from HTML tables (less reliable).
    Kept for reference.
    """
    url = f"{BASE_URL}/swimmer/{swimmer_id}/"

    response = requests.get(url, headers=HEADERS)
    response.raise_for_status()

    soup = BeautifulSoup(response.text, "lxml")
    times = []
    seen_events = set()  # Track unique events to avoid duplicates

    # Look for table rows with event data
    tables = soup.find_all("table")

    for table in tables:
        rows = table.find_all("tr")
        for row in rows:
            cells = row.find_all("td")
            if len(cells) >= 2:
                # Try to parse as event/time
                raw_event = cells[0].get_text(strip=True)
                time_text = cells[1].get_text(strip=True) if len(cells) > 1 else None

                # Check if this looks like a swim event
                if any(stroke in raw_event.lower() for stroke in ["free", "back", "breast", "fly", "im", "medley"]):
                    # Clean up the event name
                    event_name, round_type = clean_event_name(raw_event)

                    # Determine course (yards vs meters)
                    course = "SCY"  # Default to yards for college
                    if " L " in event_name or "LCM" in event_name:
                        course = "LCM"
                    elif " S " in event_name and " M " in event_name:
                        course = "SCM"

                    if time_text and time_text != "–":
                        # Create a unique key to avoid duplicate events
                        event_key = f"{event_name}_{time_text}"
                        if event_key not in seen_events:
                            seen_events.add(event_key)
                            times.append(SwimTime(
                                event=event_name,
                                time=time_text,
                                time_seconds=parse_time_to_seconds(time_text),
                                course=course,
                                is_personal_best=True,
                            ))

    return times


def scrape_team(school: str, season_id: Optional[int] = None) -> list[Swimmer]:
    """
    Scrape all swimmers and their times for a team

    season_id: Optional season to scrape (e.g., 25 for 2021-2022)
    """
    school_lower = school.lower()
    if school_lower not in IVY_TEAMS:
        raise ValueError(f"Unknown school: {school}. Available: {list(IVY_TEAMS.keys())}")

    team_id = IVY_TEAMS[school_lower]
    school_name = school.title()

    season_str = f" ({SEASON_NAMES.get(season_id, 'current')})" if season_id else ""
    print(f"\n{'='*50}")
    print(f"Scraping {school_name}{season_str} (Team ID: {team_id})")
    print(f"{'='*50}\n")

    # Get roster
    roster = get_roster(team_id, school_name, season_id=season_id)

    swimmers = []
    total = len(roster)

    for i, swimmer_data in enumerate(roster, 1):
        print(f"[{i}/{total}] Fetching times for {swimmer_data['name']}...")

        try:
            times = get_swimmer_times(swimmer_data["swimcloud_id"])

            swimmer = Swimmer(
                swimcloud_id=swimmer_data["swimcloud_id"],
                name=swimmer_data["name"],
                first_name=swimmer_data["first_name"],
                last_name=swimmer_data["last_name"],
                hometown=swimmer_data["hometown"],
                class_year=swimmer_data["class_year"],
                school=swimmer_data["school"],
                times=times,
                profile_url=swimmer_data["profile_url"],
            )
            swimmers.append(swimmer)

            print(f"    Found {len(times)} times")

        except Exception as e:
            print(f"    Error: {e}")

        # Be nice to the server - avoid rate limiting
        time.sleep(1.5)

    return swimmers


def swimmers_to_dict(swimmers: list[Swimmer]) -> list[dict]:
    """Convert swimmers to serializable dictionaries"""
    result = []
    for swimmer in swimmers:
        d = asdict(swimmer)
        # Convert SwimTime objects
        d["times"] = [asdict(t) for t in swimmer.times]
        result.append(d)
    return result


def main():
    """Main entry point"""
    import argparse

    parser = argparse.ArgumentParser(description="Scrape SwimCloud for Ivy League swimmer data")
    parser.add_argument(
        "--school",
        type=str,
        default="harvard",
        choices=list(IVY_TEAMS.keys()),
        help="School to scrape (default: harvard)"
    )
    parser.add_argument(
        "--output",
        type=str,
        default=None,
        help="Output JSON file (default: {school}_swimmers.json)"
    )
    parser.add_argument(
        "--roster-only",
        action="store_true",
        help="Only fetch roster, skip individual times"
    )
    parser.add_argument(
        "--season",
        type=str,
        default=None,
        choices=["2021-2022", "2022-2023", "2023-2024", "2024-2025", "2025-2026"],
        help="Season to scrape (default: current)"
    )

    args = parser.parse_args()

    # Map season string to ID
    season_to_id = {v: k for k, v in SEASON_NAMES.items()}
    season_id = season_to_id.get(args.season) if args.season else None

    # Generate output filename
    season_suffix = f"_{args.season.replace('-', '_')}" if args.season else ""
    output_file = args.output or f"{args.school}{season_suffix}_swimmers.json"

    if args.roster_only:
        team_id = IVY_TEAMS[args.school]
        roster = get_roster(team_id, args.school.title(), season_id=season_id)

        with open(output_file, "w") as f:
            json.dump(roster, f, indent=2)

        print(f"\nRoster saved to {output_file}")
    else:
        swimmers = scrape_team(args.school, season_id=season_id)

        with open(output_file, "w") as f:
            json.dump(swimmers_to_dict(swimmers), f, indent=2)

        print(f"\n{'='*50}")
        print(f"Scraped {len(swimmers)} swimmers")
        print(f"Data saved to {output_file}")
        print(f"{'='*50}")


if __name__ == "__main__":
    main()
