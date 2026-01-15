#!/usr/bin/env python3
"""
Generate Swift code for swimmer times from scraped JSON files
"""

import json
import glob
import os

def main():
    # Find all 2021-2022 JSON files
    json_files = glob.glob("*_2021_2022_swimmers.json")

    all_swimmers = []
    for filepath in json_files:
        with open(filepath) as f:
            swimmers = json.load(f)
            all_swimmers.extend(swimmers)

    print("// Times data for 2021-2022 swimmers")
    print("// Maps (firstName, lastName) -> [SwimTime]")
    print("let swimmer2022Times: [String: [SwimTime]] = [")

    for swimmer in all_swimmers:
        first = swimmer["first_name"]
        last = swimmer["last_name"]
        times = swimmer.get("times", [])

        if not times:
            continue

        key = f'"{first} {last}"'
        print(f"    {key}: [")

        for t in times:
            event = t["event"]
            time_str = t["time"]
            time_sec = t["time_seconds"]
            course = t["course"]

            # Map course to Swift enum
            course_enum = ".scy"
            if course == "LCM":
                course_enum = ".lcm"
            elif course == "SCM":
                course_enum = ".scm"

            print(f'        SwimTime(event: "{event}", time: "{time_str}", timeSeconds: {time_sec}, course: {course_enum}),')

        print("    ],")

    print("]")

if __name__ == "__main__":
    main()
