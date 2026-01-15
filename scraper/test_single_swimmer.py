#!/usr/bin/env python3
"""
Single Swimmer Progression Chart Tester

A focused script to debug and test progression chart extraction for one swimmer.
Uses Playwright for browser automation to bypass bot protection.

Usage:
    # First time setup:
    pip install playwright
    playwright install chromium

    # From a local HTML file (for testing parsing):
    python test_single_swimmer.py --file sample_swimmer_page.html

    # From SwimCloud (live) using browser automation:
    python test_single_swimmer.py 418666
    python test_single_swimmer.py https://www.swimcloud.com/swimmer/418666/

    # Use headless mode (no visible browser):
    python test_single_swimmer.py 418666 --headless
"""

import json
import re
import sys
import argparse
from pathlib import Path
from typing import Optional

# Try to import Playwright, provide helpful message if missing
try:
    from playwright.sync_api import sync_playwright, TimeoutError as PlaywrightTimeout
    PLAYWRIGHT_AVAILABLE = True
except ImportError:
    PLAYWRIGHT_AVAILABLE = False

BASE_URL = "https://www.swimcloud.com"


def parse_time_to_seconds(time_str: str) -> Optional[float]:
    """Convert a swim time string to seconds (e.g., '1:45.32' -> 105.32)"""
    if not time_str or time_str == "–":
        return None

    time_str = time_str.strip()

    try:
        if ":" in time_str:
            parts = time_str.split(":")
            if len(parts) == 2:
                minutes = int(parts[0])
                seconds = float(parts[1])
                return minutes * 60 + seconds
            elif len(parts) == 3:
                hours = int(parts[0])
                minutes = int(parts[1])
                seconds = float(parts[2])
                return hours * 3600 + minutes * 60 + seconds
        else:
            return float(time_str)
    except (ValueError, IndexError):
        return None


def extract_swimmer_id(input_str: str) -> int:
    """Extract swimmer ID from URL or direct ID input"""
    # If it's just a number
    if input_str.isdigit():
        return int(input_str)

    # Try to extract from URL
    match = re.search(r'/swimmer/(\d+)/?', input_str)
    if match:
        return int(match.group(1))

    raise ValueError(f"Could not extract swimmer ID from: {input_str}")


def fetch_swimmer_page(swimmer_id: int, headless: bool = True) -> str:
    """
    Fetch the swimmer's profile page using Playwright browser automation.
    This bypasses bot protection by using a real browser with stealth settings.
    """
    if not PLAYWRIGHT_AVAILABLE:
        print("ERROR: Playwright is not installed.")
        print("Install with: pip install playwright && playwright install chromium")
        sys.exit(1)

    url = f"{BASE_URL}/swimmer/{swimmer_id}/"
    print(f"\n{'='*60}")
    print(f"Fetching: {url}")
    print(f"Using Playwright (headless={headless})")
    print(f"{'='*60}\n")

    with sync_playwright() as p:
        # Launch browser with stealth settings
        browser = p.chromium.launch(
            headless=headless,
            args=[
                "--disable-blink-features=AutomationControlled",
                "--disable-dev-shm-usage",
                "--no-sandbox",
            ]
        )

        # Create context with realistic settings
        context = browser.new_context(
            user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            viewport={"width": 1920, "height": 1080},
            locale="en-US",
            timezone_id="America/New_York",
            color_scheme="light",
        )

        page = context.new_page()

        # Add stealth script to hide automation markers
        page.add_init_script("""
            Object.defineProperty(navigator, 'webdriver', {get: () => undefined});
            Object.defineProperty(navigator, 'languages', {get: () => ['en-US', 'en']});
            Object.defineProperty(navigator, 'plugins', {get: () => [1, 2, 3, 4, 5]});
        """)

        try:
            # Navigate and wait for the page to fully load
            print("Loading page...")
            response = page.goto(url, wait_until="domcontentloaded", timeout=30000)

            print(f"Initial response status: {response.status}")

            # Wait for potential Cloudflare challenge
            print("Waiting for any protection challenges...")
            page.wait_for_timeout(5000)

            # Check if we're on a challenge page and wait
            for attempt in range(3):
                title = page.title()
                if "403" in title or "Forbidden" in title or "Attention" in title or "Cloudflare" in title:
                    print(f"  Challenge detected (attempt {attempt+1}/3), waiting...")
                    page.wait_for_timeout(5000)
                else:
                    break

            # Final page state
            title = page.title()
            print(f"Page title: {title}")

            # Get the page content
            html = page.content()
            print(f"Content length: {len(html)} characters")

            # Quick check for progression chart
            if "js-swimmer-profile-overall-progress" in html:
                print("✓ Progression chart element found in page")
            else:
                print("⚠ Progression chart element NOT found - page may not have loaded correctly")

            return html

        except PlaywrightTimeout as e:
            print(f"Timeout error: {e}")
            raise
        finally:
            browser.close()


def extract_progression_chart(html: str) -> Optional[list]:
    """
    Extract progression chart JSON from the page HTML.
    Returns the raw parsed JSON data or None if not found.
    """
    print("\n--- Searching for progression chart data ---\n")

    # Original pattern from swimcloud_scraper.py
    pattern1 = r'js-swimmer-profile-overall-progress.*?const data = (\[.*?\]);'
    match = re.search(pattern1, html, re.DOTALL)

    if match:
        print("✓ Found progression chart with pattern 1 (js-swimmer-profile-overall-progress)")
        json_str = match.group(1)
        print(f"  Raw JSON length: {len(json_str)} chars")
        print(f"  First 200 chars: {json_str[:200]}...")

        try:
            data = json.loads(json_str)
            print(f"  ✓ Successfully parsed JSON")
            return data
        except json.JSONDecodeError as e:
            print(f"  ✗ JSON parse error: {e}")
            return None

    # Alternative patterns to try
    print("✗ Pattern 1 not found, trying alternatives...")

    # Pattern 2: Look for any "const data = [" followed by season data
    pattern2 = r'const data = (\[\s*\{[^;]+\}\s*\]);'
    matches = re.findall(pattern2, html, re.DOTALL)
    if matches:
        print(f"  Found {len(matches)} potential data arrays")
        for i, m in enumerate(matches):
            if 'season_id' in m or 'fastest_times' in m:
                print(f"  ✓ Match {i+1} looks like progression data")
                try:
                    data = json.loads(m)
                    return data
                except json.JSONDecodeError:
                    continue

    # Pattern 3: Search for the progression chart section specifically
    pattern3 = r'<script[^>]*>([^<]*overall-progress[^<]*)</script>'
    script_matches = re.findall(pattern3, html, re.DOTALL | re.IGNORECASE)
    if script_matches:
        print(f"  Found {len(script_matches)} scripts mentioning 'overall-progress'")
        for script in script_matches:
            print(f"    Script preview: {script[:100]}...")

    # Debug: Show what we can find
    print("\n--- Debug: Searching for related patterns ---")
    if 'season_id' in html:
        print("  ✓ 'season_id' found in page")
    else:
        print("  ✗ 'season_id' NOT found in page")

    if 'fastest_times' in html:
        print("  ✓ 'fastest_times' found in page")
    else:
        print("  ✗ 'fastest_times' NOT found in page")

    if 'overall-progress' in html:
        print("  ✓ 'overall-progress' found in page")
    else:
        print("  ✗ 'overall-progress' NOT found in page")

    # Try to find any JSON arrays with event/time data
    event_time_pattern = r'\{"event":\s*"([^"]+)",\s*"time":\s*"([^"]+)"\}'
    event_matches = re.findall(event_time_pattern, html)
    if event_matches:
        print(f"  ✓ Found {len(event_matches)} event/time pairs (legacy format)")
        for event, time in event_matches[:5]:
            print(f"    - {event}: {time}")
        if len(event_matches) > 5:
            print(f"    ... and {len(event_matches) - 5} more")

    return None


def parse_progression_data(data: list) -> dict:
    """
    Parse the progression chart data into a structured format.
    Returns a dict with season info and all times.
    """
    result = {
        "seasons": [],
        "all_times": {},  # event -> best time
    }

    print(f"\n--- Parsing {len(data)} seasons of data ---\n")

    for season in data:
        season_id = season.get('season_id')
        season_label = season.get('season_label', 'Unknown')
        fastest_times = season.get('fastest_times', [])

        print(f"Season: {season_label} (ID: {season_id})")
        print(f"  Events: {len(fastest_times)}")

        season_info = {
            "season_id": season_id,
            "label": season_label,
            "times": []
        }

        for entry in fastest_times:
            event = entry.get('event', '')
            time_str = entry.get('time', '')

            # Skip relays and diving
            if "Relay" in event or "Diving" in event or "dives" in event.lower():
                continue

            time_seconds = parse_time_to_seconds(time_str)

            # Determine course
            course = "SCY"
            if " L " in event:
                course = "LCM"
            elif " S " in event:
                course = "SCM"

            time_info = {
                "event": event,
                "time": time_str,
                "time_seconds": time_seconds,
                "course": course
            }

            season_info["times"].append(time_info)
            print(f"    {event}: {time_str} ({course})")

            # Track all-time best
            if time_seconds is not None:
                if event not in result["all_times"] or time_seconds < result["all_times"][event]["time_seconds"]:
                    result["all_times"][event] = time_info

        result["seasons"].append(season_info)
        print()

    return result


def is_50_non_free(event_name: str) -> bool:
    """Check if event is a 50 that's NOT freestyle"""
    if event_name.startswith('50 '):
        return 'Free' not in event_name
    return False


def get_event_priority(event: dict) -> int:
    """
    Get priority tier for an event (lower = higher priority):
    1. SCY events (excluding 50s that aren't 50 Free)
    2. LCM/SCM events
    3. 50s that aren't 50 Free (lowest priority)
    """
    course = event['course']
    event_name = event['event']

    if is_50_non_free(event_name):
        return 3  # Lowest priority
    elif course == 'SCY':
        return 1  # Highest priority
    else:  # LCM/SCM
        return 2  # Middle priority


def select_top_5_events(all_times: dict) -> list:
    """
    Select the top 5 most important events for a swimmer.

    Priority order:
    1. SCY events (excluding non-free 50s) - sorted by time
    2. LCM/SCM events - sorted by time
    3. 50s that aren't 50 Free - sorted by time (lowest priority)

    Returns list of top 5 event dicts.
    """
    # Add priority to each event
    events = []
    for event_name, time_info in all_times.items():
        event_data = time_info.copy()
        event_data['priority'] = get_event_priority(time_info)
        events.append(event_data)

    # Separate into tiers
    tier1 = [e for e in events if e['priority'] == 1]  # SCY (no bad 50s)
    tier2 = [e for e in events if e['priority'] == 2]  # LCM/SCM
    tier3 = [e for e in events if e['priority'] == 3]  # 50s (non-free)

    # Sort each tier by time (fastest first)
    tier1.sort(key=lambda x: x['time_seconds'] if x['time_seconds'] else float('inf'))
    tier2.sort(key=lambda x: x['time_seconds'] if x['time_seconds'] else float('inf'))
    tier3.sort(key=lambda x: x['time_seconds'] if x['time_seconds'] else float('inf'))

    # Fill top 5 from tiers in priority order
    top_5 = []
    for tier in [tier1, tier2, tier3]:
        for event in tier:
            if len(top_5) < 5:
                top_5.append(event)

    return top_5


def display_summary(parsed_data: dict):
    """Display a summary of the swimmer's top 5 most important times"""
    all_times = parsed_data["all_times"]

    # Get top 5 using the heuristic
    top_5 = select_top_5_events(all_times)

    print("\n" + "="*60)
    print("TOP 5 MOST IMPORTANT EVENTS")
    print("="*60 + "\n")

    tier_names = {1: "SCY", 2: "LCM", 3: "50-low"}
    for i, t in enumerate(top_5, 1):
        tier = tier_names.get(t['priority'], '?')
        print(f"{i}. {t['event']:20} {t['time']:>10}  [{tier}]")

    print(f"\n(Selected from {len(all_times)} unique events)")


def main():
    parser = argparse.ArgumentParser(
        description="Test progression chart extraction for a single swimmer",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # First time setup:
  pip install playwright && playwright install chromium

  # Test parsing with a local HTML file:
  python test_single_swimmer.py --file sample_swimmer_page.html

  # Fetch from SwimCloud using browser automation:
  python test_single_swimmer.py 418666
  python test_single_swimmer.py https://www.swimcloud.com/swimmer/418666/

  # Show browser window while fetching:
  python test_single_swimmer.py 418666 --no-headless
        """
    )
    parser.add_argument(
        "swimmer",
        nargs="?",
        help="Swimmer ID or SwimCloud URL"
    )
    parser.add_argument(
        "--file", "-f",
        type=str,
        help="Path to local HTML file to parse (for testing)"
    )
    parser.add_argument(
        "--output", "-o",
        type=str,
        help="Output JSON file for extracted data"
    )
    parser.add_argument(
        "--headless",
        action="store_true",
        default=True,
        help="Run browser in headless mode (default: True)"
    )
    parser.add_argument(
        "--no-headless",
        action="store_true",
        help="Show browser window while fetching"
    )

    args = parser.parse_args()

    # Handle headless flag
    headless = not args.no_headless

    # Determine source: local file or live fetch
    if args.file:
        # Local file mode
        file_path = Path(args.file)
        if not file_path.exists():
            print(f"Error: File not found: {args.file}")
            sys.exit(1)

        print(f"\n{'='*60}")
        print(f"Reading local file: {args.file}")
        print(f"{'='*60}\n")

        with open(file_path, "r") as f:
            html = f.read()

        print(f"Content length: {len(html)} characters")
        swimmer_id = "local"

    elif args.swimmer:
        # Live fetch mode with Playwright
        try:
            swimmer_id = extract_swimmer_id(args.swimmer)
            print(f"Swimmer ID: {swimmer_id}")
        except ValueError as e:
            print(f"Error: {e}")
            sys.exit(1)

        try:
            html = fetch_swimmer_page(swimmer_id, headless=headless)
        except Exception as e:
            print(f"Error fetching page: {e}")
            print("\nTroubleshooting:")
            print("  1. Make sure Playwright is installed: pip install playwright")
            print("  2. Install browser: playwright install chromium")
            print("  3. Try with --no-headless to see the browser")
            sys.exit(1)

        # Save raw HTML for debugging
        debug_file = f"debug_swimmer_{swimmer_id}.html"
        with open(debug_file, "w") as f:
            f.write(html)
        print(f"Saved raw HTML to: {debug_file}")

    else:
        parser.print_help()
        sys.exit(1)

    # Extract progression chart
    progression_data = extract_progression_chart(html)

    if progression_data is None:
        print("\n" + "="*60)
        print("FAILED: Could not extract progression chart data")
        print("="*60)
        print("\nPossible issues:")
        print("  - The page structure has changed")
        print("  - This swimmer doesn't have progression data")
        print("  - The HTML file is incomplete")
        sys.exit(1)

    # Save raw progression data
    output_file = args.output or f"debug_swimmer_{swimmer_id}_progression.json"
    with open(output_file, "w") as f:
        json.dump(progression_data, f, indent=2)
    print(f"Saved progression JSON to: {output_file}")

    # Parse and display
    parsed = parse_progression_data(progression_data)
    display_summary(parsed)

    # Save top 5 events to JSON
    top_5 = select_top_5_events(parsed["all_times"])
    top_5_file = f"swimmer_{swimmer_id}_top5.json"
    top_5_output = {
        "swimmer_id": swimmer_id,
        "top_5_events": [
            {
                "event": t["event"],
                "time": t["time"],
                "time_seconds": t["time_seconds"],
                "course": t["course"]
            }
            for t in top_5
        ]
    }
    with open(top_5_file, "w") as f:
        json.dump(top_5_output, f, indent=2)
    print(f"\nSaved top 5 events to: {top_5_file}")

    print("\n✓ Success! Progression chart extracted and parsed.")


if __name__ == "__main__":
    main()
