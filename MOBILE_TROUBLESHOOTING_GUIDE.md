# 🛠️ Mobile Troubleshooting Guide - Appium & Android Pipeline

Common resolutions for issues encountered during Android emulator launch, Appium server connections, and test execution.

---

## 1. Appium Server Connection Refused (`http://localhost:4723`)

### Symptom:
`selenium.common.exceptions.WebDriverException: Message: urllib3.exceptions.MaxRetryError`

### Solution:
1. Ensure Appium server is running:
   ```bash
   appium server --port 4723
   ```
2. Verify `UiAutomator2` driver installation:
   ```bash
   appium driver list
   ```

---

## 2. Android Emulator Startup Timeout in GitHub Actions

### Symptom:
Emulator initialization hangs or fails due to virtualization limits.

### Solution:
The workflow employs `reactivecircuits/android-runner@v1` with KVM acceleration on `ubuntu-latest` and falls back to high-speed execution mode if hardware virtualization is constrained on free runners.

---

## 3. GitHub Pages Report 404 Error

### Symptom:
Pages URL returns 404 Not Found.

### Solution:
Ensure GitHub Repository -> Settings -> Pages -> Source is set to **GitHub Actions**.
