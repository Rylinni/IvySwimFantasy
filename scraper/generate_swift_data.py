#!/usr/bin/env python3
"""
Convert scraped SwimCloud JSON data to Swift code for the iOS app
"""

from __future__ import annotations

import json
import os
from typing import Optional

# Map scraped event names to SwimEvent enum cases
EVENT_MAPPING = {
    "50 Y Free": "free50",
    "100 Y Free": "free100",
    "200 Y Free": "free200",
    "500 Y Free": "free500",
    "1000 Y Free": "free1000",
    "1650 Y Free": "free1650",
    "100 Y Back": "back100",
    "200 Y Back": "back200",
    "100 Y Breast": "breast100",
    "200 Y Breast": "breast200",
    "100 Y Fly": "fly100",
    "200 Y Fly": "fly200",
    "200 Y IM": "im200",
    "400 Y IM": "im400",
}

# Map class year
YEAR_MAPPING = {
    "FR": "freshman",
    "SO": "sophomore",
    "JR": "junior",
    "SR": "senior",
}

# Map school names
SCHOOL_MAPPING = {
    "Harvard": "harvard",
    "Yale": "yale",
    "Princeton": "princeton",
    "Columbia": "columbia",
    "Penn": "penn",
    "Brown": "brown",
    "Cornell": "cornell",
    "Dartmouth": "dartmouth",
}


def parse_events(times: list) -> list[str]:
    """Extract unique SwimEvent cases from swimmer times"""
    events = set()
    for time_entry in times:
        event_name = time_entry.get("event", "")
        # Try to match to known events
        for scraped, swift_case in EVENT_MAPPING.items():
            if scraped in event_name:
                events.add(swift_case)
                break
    return sorted(list(events))[:3]  # Limit to 3 events per swimmer


def generate_swimmer_tuple(swimmer: dict) -> Optional[str]:
    """Generate Swift tuple for a swimmer"""
    first_name = swimmer.get("first_name", "").strip()
    last_name = swimmer.get("last_name", "").strip()
    school = swimmer.get("school", "")
    class_year = swimmer.get("class_year")
    times = swimmer.get("times", [])

    # Skip if missing critical data
    if not first_name or not last_name:
        return None

    # Map school
    swift_school = SCHOOL_MAPPING.get(school)
    if not swift_school:
        return None

    # Map class year (default to freshman if unknown)
    swift_year = YEAR_MAPPING.get(class_year, "freshman")

    # Get events from times
    events = parse_events(times)
    if not events:
        # Default events if none found
        events = ["free100", "free200"]

    # Format events array
    events_str = ", ".join(f".{e}" for e in events)

    # Escape any quotes in names
    first_name = first_name.replace('"', '\\"')
    last_name = last_name.replace('"', '\\"')

    return f'            ("{first_name}", "{last_name}", .{swift_school}, .{swift_year}, [{events_str}]),'


def main():
    teams = ["harvard", "yale", "princeton", "columbia", "penn", "brown", "cornell", "dartmouth"]

    all_swimmers = []

    for team in teams:
        filename = f"{team}_swimmers.json"
        if os.path.exists(filename):
            with open(filename) as f:
                swimmers = json.load(f)
            all_swimmers.extend(swimmers)
            print(f"Loaded {len(swimmers)} swimmers from {team}")

    print(f"\nTotal: {len(all_swimmers)} swimmers")

    # Generate Swift code
    output_lines = []
    output_lines.append("        // Real Ivy League swimmers from SwimCloud")
    output_lines.append("        let swimmersData: [(String, String, IvySchool, ClassYear, [SwimEvent])] = [")

    skipped = 0
    for swimmer in all_swimmers:
        tuple_str = generate_swimmer_tuple(swimmer)
        if tuple_str:
            output_lines.append(tuple_str)
        else:
            skipped += 1

    output_lines.append("        ]")

    # Write to file
    output_file = "swimmers_swift_data.txt"
    with open(output_file, "w") as f:
        f.write("\n".join(output_lines))

    print(f"\nGenerated Swift data for {len(all_swimmers) - skipped} swimmers")
    print(f"Skipped {skipped} swimmers (missing data)")
    print(f"Output written to {output_file}")


if __name__ == "__main__":
    main()
