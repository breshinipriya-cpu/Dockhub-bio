# 🚀 Mobile CI/CD & GitHub Pages Execution Guide

This guide details the automated 21-stage CI/CD pipeline for building the Android APK, starting an Android emulator, running Appium tests, and publishing reports to GitHub Pages.

---

## ⚙️ 21 Pipeline Stages Overview (`.github/workflows/android-e2e.yml`)

1. **Stage 1 — Checkout Repository:** Pulls latest codebase from branch.
2. **Stage 2 — Setup Java:** Configures JDK 17 (Temurin).
3. **Stage 3 — Setup Android SDK & Flutter:** Prepares build toolchain.
4. **Stage 4 — Install Dependencies:** Installs Python Appium client, openpyxl, Node.js Appium server, and UiAutomator2 driver.
5. **Stage 5 — Build APK:** Compiles `app-debug.apk` (`flutter build apk --debug`).
6. **Stage 6 & 7 — Start Android Emulator & Verify:** Launches headless Pixel emulator with KVM acceleration and checks `adb` connectivity.
7. **Stage 8 — Install APK:** Deploys target APK onto emulator.
8. **Stage 9 & 10 — Start Appium Server & Verify:** Boots Appium on port 4723 and verifies `/status` endpoint.
9. **Stage 11 — 17 — Execute 480 Appium Tests & Generate Reports:** Runs suite, produces Excel (7 sheets), HTML (`execution-report.html`, `dashboard.html`, `trends.html`), JSON, and summary Markdown.
10. **Stage 18 — Upload Artifacts:** Uploads all raw test results with 30-day retention.
11. **Stage 19 & 20 — GitHub Pages Publishing & Archiving:**
    - Latest Report URL: `https://breshinipriya-cpu.github.io/Dockhub-bio/reports/latest/execution-report.html`
    - Historical Build URL: `https://breshinipriya-cpu.github.io/Dockhub-bio/reports/history/build-${{ github.run_number }}/`
12. **Stage 21 — Publish GitHub Step Summary:** Renders execution breakdown directly in GitHub Actions dashboard.
