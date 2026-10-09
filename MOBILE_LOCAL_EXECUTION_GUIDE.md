# 📱 Mobile Local Execution Guide - Appium & Android

This guide explains how to execute the **Android Appium E2E Automation Framework** locally against Android Emulators or real USB devices.

---

## 📋 Prerequisites
1. **Flutter SDK** installed and configured (`flutter doctor`).
2. **Android Studio & Android SDK** with `emulator`, `platform-tools` (`adb`), and `build-tools`.
3. **Node.js** & **Appium Server**:
   ```bash
   npm install -g appium
   appium driver install uiautomator2
   ```
4. **Python 3.10+** & Appium Client:
   ```bash
   pip install Appium-Python-Client openpyxl requests
   ```

---

## 🚀 Step-by-Step Local Execution

### 1. Start Android Emulator
Launch your Android Virtual Device (AVD) from Android Studio or terminal:
```bash
emulator -avd Pixel_6_API_30
```
Verify device connection:
```bash
adb devices
```

### 2. Build the Android APK
Navigate to `dockhub_bio` directory and build the debug APK:
```bash
cd dockhub_bio
flutter pub get
flutter build apk --debug
cd ..
```

### 3. Start Appium Server
In a separate terminal window, start the Appium server:
```bash
appium server --port 4723
```

### 4. Run the Mobile Automation Suite
Execute the main orchestrator script:
```bash
python mobile_automation/run_mobile_framework.py
```

---

## 📁 Generated Reports & Evidence
Upon completion, reports are saved in `Test Results/`:
- **Excel Reports**: `Test Results/Excel/Automation_Test_Report.xlsx` (7 sheets)
- **HTML Reports**: `Test Results/HTML/execution-report.html`, `dashboard.html`, `trends.html`
- **Screenshots**: `Test Results/Screenshots/`
- **Logs**: `Test Results/Logs/`
