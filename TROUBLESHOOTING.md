# ❌ App Not Connecting to Local Server - Troubleshooting Guide

## Quick Diagnostic

**Run this first:** Double-click `diagnose-connection.bat`

This will check:
- ✅ Is backend running?
- ✅ What's your computer's IP?
- ✅ What device are you using?
- ✅ Is Flutter installed?
- ✅ Current configuration

---

## Most Common Issues

### Issue 1: Backend Not Running ⚠️

**Symptom:** App shows "Connection refused" or "Network error"

**Check:**
1. Open browser and go to: http://localhost:8000/health
2. Should see: `{"status": "healthy", ...}`

**Solution:**
```cmd
Double-click: START_EVERYTHING.bat
```

Keep the backend window open!

---

### Issue 2: Wrong IP Configuration ⚠️

**The IP address depends on what device you're using:**

#### ✅ Android Emulator (Most Common)
- **Config should be:** `http://10.0.2.2:8000`
- **File:** `lib/core/config/app_config.dart` line 9
- **Current setting:** Already set to this ✅

#### ❌ Physical Android/iOS Device
- **Config should be:** `http://YOUR_COMPUTER_IP:8000`
- **How to find your IP:**
  1. Run: `diagnose-connection.bat`
  2. OR Windows: `ipconfig` (look for IPv4 Address like 192.168.1.100)
  3. OR Mac: `ifconfig` (look for inet)
- **Edit:** `lib/core/config/app_config.dart` line 9
- **Change to:** `defaultValue: 'http://192.168.1.XXX:8000',`

#### ❌ iOS Simulator
- **Config should be:** `http://localhost:8000`
- **Edit:** `lib/core/config/app_config.dart` line 9
- **Change to:** `defaultValue: 'http://localhost:8000',`

---

### Issue 3: App Not Rebuilt After Config Change ⚠️

**If you changed the config file, you MUST rebuild:**

**Solution:**
```cmd
Double-click: rebuild-flutter.bat

OR manually:
flutter clean
flutter pub get
flutter run
```

---

## Step-by-Step Troubleshooting

### Step 1: Verify Backend is Running

```cmd
# Check in browser
http://localhost:8000/health

# Should see:
{"status": "healthy", ...}
```

If NOT working:
- Run `START_EVERYTHING.bat`
- Check backend window for errors
- Try `cd backend && python run.py`

---

### Step 2: Check Device Type

```cmd
flutter devices
```

Output will show:
- `emulator-XXXX` = Android Emulator → Use 10.0.2.2:8000 ✅
- `00XXXXXX` = Physical Device → Use your computer's IP
- `iOS Simulator` = iOS Simulator → Use localhost:8000

---

### Step 3: Update Configuration if Needed

**File:** `lib/core/config/app_config.dart`

**For Android Emulator (current):**
```dart
defaultValue: 'http://10.0.2.2:8000',  // ✅ Already set
```

**For Physical Device:**
```dart
defaultValue: 'http://192.168.1.100:8000',  // Replace with YOUR IP
```

**For iOS Simulator:**
```dart
defaultValue: 'http://localhost:8000',
```

---

### Step 4: Rebuild Flutter App

After ANY config change:
```cmd
flutter clean
flutter pub get
flutter run
```

Or double-click: `rebuild-flutter.bat`

---

### Step 5: Test Connection

In the app:
1. Try to login
2. Check error message
3. Look at Flutter console output

Common errors:
- `Connection refused` = Backend not running
- `Network unreachable` = Wrong IP address
- `Timeout` = Firewall blocking or wrong IP

---

## Advanced Troubleshooting

### Check Firewall (Windows)

If using physical device:
1. Windows Search → "Firewall"
2. "Allow an app through Windows Firewall"
3. Make sure Python is allowed on Private network

### Test Backend from Command Line

```cmd
curl http://localhost:8000/health
```

Should return JSON.

### Test Backend from Network (Physical Device)

```cmd
curl http://YOUR_COMPUTER_IP:8000/health
```

If this fails, it's a firewall issue.

### Check Flask Output

Look at the backend window for incoming requests.
Should see lines like:
```
127.0.0.1 - - [date] "GET /health HTTP/1.1" 200
```

When app tries to connect, you should see the requests appear.

---

## Quick Reference

### Files to Check
```
lib/core/config/app_config.dart  → API configuration
lib/services/api_client.dart     → API client (uses AppConfig)
backend/run.py                   → Backend server config
```

### Commands
```cmd
# Diagnose issues
diagnose-connection.bat

# Start backend
START_EVERYTHING.bat

# Rebuild Flutter
rebuild-flutter.bat

# Check devices
flutter devices

# Check Flutter doctor
flutter doctor

# Check your IP
ipconfig  (Windows)
ifconfig  (Mac/Linux)

# Test backend
curl http://localhost:8000/health
```

### URLs by Device Type
```
Android Emulator:  http://10.0.2.2:8000
iOS Simulator:     http://localhost:8000
Physical Device:   http://YOUR_COMPUTER_IP:8000
Web Browser:       http://localhost:8000
```

---

## Still Not Working?

1. **Run diagnostics:**
   ```cmd
   diagnose-connection.bat
   ```

2. **Check both windows:**
   - Backend window: Should show server running, no errors
   - Flutter console: Should show build success, what error appears?

3. **Try production server temporarily:**
   Edit `app_config.dart` line 9:
   ```dart
   defaultValue: 'https://yamenmod912.pythonanywhere.com',
   ```
   Then `flutter clean && flutter run`
   
   If this works, problem is with local setup.
   If this doesn't work, problem is with the app itself.

4. **Take screenshot of:**
   - Backend window
   - Flutter console error
   - App error message
   - Result of `diagnose-connection.bat`

---

## Summary Checklist

- [ ] Backend running (`http://localhost:8000/health` works)
- [ ] Correct IP in config based on device type
- [ ] Flutter rebuilt after config change (`flutter clean && flutter run`)
- [ ] Device connected (`flutter devices` shows it)
- [ ] Firewall allows Python (if using physical device)
- [ ] No proxy or VPN interfering
