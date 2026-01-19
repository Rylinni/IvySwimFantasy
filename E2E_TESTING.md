# End-to-End Testing Guide

Complete guide for testing the full stack locally (iOS app → Backend API → Scraped data)

## Prerequisites

- Docker installed and running
- Xcode installed
- Scraped JSON files in `scraper/` directory

## Step 1: Start Backend API

```bash
# From project root
docker-compose up --build

# You should see:
# ✓ Container ivy-swim-backend Created
# ✓ Loaded X swimmers from /app/data
# ✓ Uvicorn running on http://0.0.0.0:8000
```

**Keep this terminal running!**

## Step 2: Test Backend API

In a new terminal, verify the API is working:

```bash
# Health check
curl http://localhost:8000/health
# Expected: {"status":"healthy"}

# Check swimmers loaded
curl http://localhost:8000/ | jq
# Expected: Service info with swimmer count

# Get all swimmers (Harvard only, to limit output)
curl "http://localhost:8000/api/swimmers?school=Harvard" | jq '.count'
# Expected: Number of Harvard swimmers

# Get all schools
curl http://localhost:8000/api/schools | jq
# Expected: List of schools with counts

# View API docs in browser
open http://localhost:8000/docs
```

## Step 3: Update iOS App (Already Done!)

The `DataService.swift` has been updated to point to `http://localhost:8000/api`.

**Note:** iOS Simulator can access `localhost` directly, but real devices need your Mac's IP address.

## Step 4: Run iOS App

```bash
# Open project in Xcode
open IvySwimFantasy.xcodeproj

# Or build from command line
xcodebuild -project IvySwimFantasy.xcodeproj \
  -scheme IvySwimFantasy \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  build

# Run in simulator (from Xcode):
# 1. Select iPhone 15 Pro (or any simulator)
# 2. Press ⌘R to build and run
```

## Step 5: Test API Integration (Quick Test)

### Option A: Add a Test Button to Your App

Add this to any SwiftUI view to test the connection:

```swift
Button("Test API Connection") {
    Task {
        do {
            let url = URL(string: "http://localhost:8000/api/schools")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data)
            print("✅ API Response:", json)
        } catch {
            print("❌ API Error:", error)
        }
    }
}
```

### Option B: Use Network Inspector

1. Run app in Simulator
2. Open Console app (macOS)
3. Filter for "IvySwimFantasy"
4. Watch for network requests

### Option C: Use Charles Proxy or Proxyman

Install [Proxyman](https://proxyman.io) to inspect HTTP traffic between app and API.

## Step 6: Full Integration Test Flow

1. **Backend is running** → `docker-compose up` ✓
2. **API responds** → `curl http://localhost:8000/health` ✓
3. **Data is loaded** → Check "swimmers_loaded" count in health check
4. **iOS app runs** → Xcode simulator shows app ✓
5. **App calls API** → Add test button and check logs

## Testing on Real Device (iPhone/iPad)

If testing on a real device, update the `baseURL`:

```swift
// In DataService.swift, change to your Mac's IP:
private let baseURL = "http://192.168.1.XXX:8000/api"  // Replace with your Mac's IP

// Find your IP:
// macOS: System Settings → Network → WiFi → Details → IP address
// or run: ifconfig | grep "inet " | grep -v 127.0.0.1
```

**Important:** Device must be on same WiFi network as your Mac.

## Common Issues & Solutions

### Backend won't start

```bash
# Check if port 8000 is already in use
lsof -i :8000

# Kill existing process
kill -9 <PID>

# Or change port in docker-compose.yml
ports:
  - "8001:8000"  # Use 8001 instead
```

### No swimmers loaded

```bash
# Check data directory is mounted
docker exec -it ivy-swim-backend ls -la /app/data

# Should see JSON files:
# harvard_swimmers.json
# yale_swimmers.json
# etc.

# If empty, check docker-compose.yml volume mount
```

### iOS app can't reach API

```bash
# Check app is using localhost
# In DataService.swift:
private let baseURL = "http://localhost:8000/api"

# Check backend is accessible from simulator
# Run in simulator terminal:
curl http://localhost:8000/health

# If using real device, use Mac's IP instead
```

### App Transport Security Error (iOS)

If you get ATS errors about insecure HTTP:

Add to `Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <!-- For production, use NSExceptionDomains instead -->
</dict>
```

### CORS errors

Backend already has CORS enabled for all origins. If you still see CORS errors:

Check `backend/main.py`:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Already set
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## Monitoring & Debugging

### View Backend Logs

```bash
# Follow logs in real-time
docker logs ivy-swim-backend -f

# Last 50 lines
docker logs ivy-swim-backend --tail 50
```

### View Network Requests in Xcode

1. Run app in Simulator
2. Xcode → Debug Navigator → Network (⌘7)
3. See all HTTP requests

### Check API Response Format

```bash
# Get a single swimmer
curl http://localhost:8000/api/swimmers | jq '.swimmers[0]'

# Compare with iOS Swimmer model structure
```

## Next Steps After E2E Works

1. **Implement full API integration** in `DataService.swift`
   - Map backend JSON to iOS Swimmer model
   - Handle API errors gracefully
   - Add loading states

2. **Add Info.plist configuration** for production
   - Proper ATS configuration
   - Only allow your production domain

3. **Switch to production URL** when deploying
   ```swift
   private let baseURL = "https://your-server.com/api"
   ```

4. **Add authentication** if needed
   - API keys
   - JWT tokens

## Quick Reference

| Component | URL/Command |
|-----------|-------------|
| Backend Health | http://localhost:8000/health |
| API Docs | http://localhost:8000/docs |
| Swimmers API | http://localhost:8000/api/swimmers |
| Schools API | http://localhost:8000/api/schools |
| Start Backend | `docker-compose up` |
| Stop Backend | `Ctrl+C` or `docker-compose down` |
| Rebuild Backend | `docker-compose up --build` |
| View Logs | `docker logs ivy-swim-backend -f` |
| Open in Xcode | `open IvySwimFantasy.xcodeproj` |
