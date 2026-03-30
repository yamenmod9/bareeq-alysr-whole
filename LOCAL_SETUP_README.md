# Bareeq Al-Yusr - Local Development Setup

## Quick Start Guide

### Step 1: Start Backend Server

**Option A - Using Batch File (Easiest):**
1. Double-click `start-backend.bat` in the project root folder
2. A command window will open showing the server running on http://localhost:8000
3. Keep this window open

**Option B - Manual Command:**
1. Open Command Prompt or PowerShell
2. Run:
   ```cmd
   cd d:\Programming\bareeq-alysr-whole\backend
   python run.py
   ```
3. Keep this window open

**Verify Backend is Running:**
- Open browser and go to: http://localhost:8000/health
- You should see: `{"status": "healthy", ...}`

---

### Step 2: Start Flutter App

**Option A - Using Batch File (Easiest):**
1. Make sure your Android emulator or device is connected
2. Double-click `start-flutter.bat` in the project root folder
3. The app will build and launch

**Option B - Manual Command:**
1. Open a NEW Command Prompt or PowerShell window
2. Run:
   ```cmd
   cd d:\Programming\bareeq-alysr-whole
   flutter run
   ```

**Check Device is Connected:**
```cmd
flutter devices
```

---

### Step 3: Test the Installment Feature

1. **Login to the app** (as customer or merchant)

2. **As Merchant:**
   - Send a purchase request to a customer
   - Enter amount (e.g., 600 SAR)
   - Add description
   - Send

3. **As Customer:**
   - Go to "Requests" tab
   - You'll see the pending request
   - Click "Accept"
   - **Select installment plan** (e.g., "6 months")
   - Confirm

4. **Verify Installment is Saved:**
   - Go to "Transactions" tab
   - Find your transaction
   - Look at the "Installment Plan" column
   - Should show "6 months" ✅

5. **Check Repayments:**
   - Go to "Repayments" tab
   - Click on your transaction
   - Should see 6 monthly installments with due dates

---

## Backend Configuration

### Current Settings:
- **Server URL:** http://localhost:8000
- **Port:** 8000
- **Host:** 0.0.0.0 (accessible from network)

### Flutter App Configuration:
- **File:** `lib/core/config/app_config.dart`
- **Android Emulator:** `http://10.0.2.2:8000` ✅ (Currently set)
- **iOS Simulator:** `http://localhost:8000`
- **Physical Device:** `http://YOUR_COMPUTER_IP:8000`

---

## Troubleshooting

### Problem: "Connection refused" or "Cannot reach server"

**Solution 1:** Make sure backend is running
- Check the backend window is still open
- Visit http://localhost:8000/health in browser
- Should see JSON response

**Solution 2:** Check you're using correct IP
- Android Emulator: MUST use `10.0.2.2:8000` (not localhost)
- iOS Simulator: Use `localhost:8000`
- Physical Device: Use your computer's IP address

**Solution 3:** Restart everything
1. Close both command windows (backend and Flutter)
2. Start backend first: `start-backend.bat`
3. Start Flutter: `start-flutter.bat`

### Problem: Backend crashes or errors

**Check Python installed:**
```cmd
python --version
```
Should be Python 3.8+

**Install dependencies:**
```cmd
cd d:\Programming\bareeq-alysr-whole\backend
pip install -r requirements.txt
```

**Reset database:**
```cmd
cd d:\Programming\bareeq-alysr-whole\backend
python
>>> from app.flask_app import flask_app, init_database
>>> init_database(flask_app)
>>> exit()
```

### Problem: Flutter build errors

**Clean and rebuild:**
```cmd
cd d:\Programming\bareeq-alysr-whole
flutter clean
flutter pub get
flutter run
```

### Problem: "No devices found"

**For Android Emulator:**
1. Open Android Studio
2. Start an emulator (AVD Manager)
3. Wait for it to fully boot
4. Run `flutter devices` to verify

**For Physical Device:**
1. Enable USB Debugging on device
2. Connect via USB
3. Accept USB debugging prompt on device
4. Run `flutter devices` to verify

---

## Files Changed for Local Development

### 1. `lib/core/config/app_config.dart`
- Changed API URL to `http://10.0.2.2:8000`
- This allows Android Emulator to connect to localhost

### 2. Backend API Routes (All Updated)
- `accept_purchase_request()` - Now handles installment_months
- `customer_transactions_filtered()` - Returns installment data
- `merchant_transactions_paginated()` - Returns installment data

### 3. Backend Models
- `Transaction.to_dict()` - Includes installment_months from RepaymentPlan

---

## What's New - Installment Feature

### Backend Changes:
1. ✅ Accepts `installment_months` parameter when accepting purchase
2. ✅ Creates RepaymentPlan with selected months (3, 6, 9, 12, 18, 24)
3. ✅ Generates RepaymentSchedule (individual monthly payments)
4. ✅ Returns installment data in all transaction APIs
5. ✅ Validates installment plans (only allows 0, 3, 6, 9, 12, 18, 24)

### Frontend Changes:
1. ✅ AcceptPurchaseDialog shows installment options
2. ✅ Monthly payment preview before accepting
3. ✅ Transactions table shows "Installment Plan" column
4. ✅ Displays "Pay in Full" or "X months"
5. ✅ Fully localized (works in Arabic too)
6. ✅ Debug logging to verify data from backend

---

## Test Checklist

- [ ] Backend starts without errors
- [ ] Can access http://localhost:8000/health
- [ ] Flutter app connects to backend
- [ ] Can login successfully
- [ ] Merchant can send purchase request
- [ ] Customer sees pending request
- [ ] Customer can select installment plan (6 months)
- [ ] Transaction appears with "6 months" in Transactions tab
- [ ] Repayment schedule shows 6 installments in Repayments tab
- [ ] Works in both English and Arabic languages

---

## Next Steps After Testing

1. If everything works:
   - Upload updated backend to PythonAnywhere
   - Change Flutter config back to production URL
   - Build release APK: `flutter build apk --release`

2. If issues found:
   - Check backend console for errors
   - Check Flutter console for errors
   - Review debug logs in transactions page
   - Report specific error messages

---

## Getting Help

If you encounter issues:
1. Check both command windows for error messages
2. Take screenshot of errors
3. Check Flutter console output
4. Try the troubleshooting steps above
