# Scraper Status

**Last Updated:** January 14, 2026

## Current State: Ready to Scrape

The scraper has been updated and tested but we're blocked by SwimCloud's bot protection (403 errors). When network access is restored, we can run the full scrape.

---

## What's Been Done

### 1. Single Swimmer Script (`test_single_swimmer.py`)
- Uses Playwright for browser automation (bypasses bot protection when network allows)
- Extracts progression chart data from SwimCloud profiles
- Applies the "top 5 most important events" heuristic
- Tested successfully with Matthew Chung (ID: 418666)

**Usage:**
```bash
python test_single_swimmer.py <swimmer_id>
python test_single_swimmer.py --file <local_html_file>
```

### 2. Main Scraper (`swimcloud_scraper.py`)
- Updated with same top 5 heuristic
- Team IDs corrected for all Ivy League schools

### 3. Top 5 Event Selection Heuristic

Events are prioritized in this order:

| Priority | Category | Description |
|----------|----------|-------------|
| 1 (highest) | SCY | Short Course Yards events, excluding 50s that aren't 50 Free |
| 2 (middle) | LCM/SCM | Long Course and Short Course Meters events |
| 3 (lowest) | Non-free 50s | 50 Fly, 50 Back, 50 Breast (any course) |

Within each tier, events are sorted by fastest time. Top 5 are selected by filling from Tier 1 first, then Tier 2, then Tier 3.

**Example (Matthew Chung):**
```
1. 100 Y Free    46.28   [SCY]
2. 200 Y Free    1:37.47 [SCY]
3. 200 Y IM      1:50.03 [SCY]
4. 400 Y IM      3:54.46 [SCY]
5. 500 Y Free    4:23.30 [SCY]
```

---

## Team IDs (Verified)

```python
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
```

---

## Next Steps (When Network Access Available)

1. **Test single swimmer fetch:**
   ```bash
   python test_single_swimmer.py 418666
   ```

2. **If that works, run full team scrape:**
   ```bash
   python swimcloud_scraper.py --school harvard --season 2024-2025
   ```

3. **Repeat for all schools:**
   ```bash
   python swimcloud_scraper.py --school yale --season 2024-2025
   python swimcloud_scraper.py --school princeton --season 2024-2025
   # ... etc
   ```

---

## Files Overview

| File | Purpose |
|------|---------|
| `swimcloud_scraper.py` | Main scraper - fetches full team rosters and times |
| `test_single_swimmer.py` | Test script - fetch/parse single swimmer |
| `generate_swift_data.py` | Convert JSON to Swift code for iOS app |
| `requirements.txt` | Python dependencies (includes playwright) |
| `*_swimmers.json` | Scraped data output files |

---

## Troubleshooting

**403 Forbidden errors:**
- SwimCloud has bot protection at the AWS/CDN level
- Sometimes works on different networks (try VPN, mobile hotspot, etc.)
- Playwright with stealth settings helps but doesn't always bypass

**Playwright not installed:**
```bash
pip install playwright
playwright install chromium
```
