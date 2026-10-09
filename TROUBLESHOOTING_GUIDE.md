# 🛠️ Troubleshooting Guide - Live E2E Automation Pipeline

This document provides resolutions for common issues encountered during local or CI/CD execution.

---

## 1. Deployment Verification Fails (HTTP 404 / 503)

### Symptom:
`verify_deployment.py` logs `Deployment verification FAILED for URL: https://breshinipriya-cpu.github.io/Dockhub-bio/`

### Root Cause:
GitHub Pages deployment has not finished building or Pages source is not set to `GitHub Actions`.

### Solution:
1. Ensure GitHub Repository Settings -> Pages -> Source is set to **GitHub Actions**.
2. Allow up to 30-60 seconds for GitHub Pages CDN propagation after initial push.

---

## 2. ChromeDriver / Headless Chrome Launch Error

### Symptom:
`selenium.common.exceptions.WebDriverException: Message: unknown error: cannot find Chrome binary`

### Solution:
Install Google Chrome or ChromeDriver on local machine, or run with headless options:
```python
options.add_argument("--headless=new")
options.add_argument("--no-sandbox")
options.add_argument("--disable-dev-shm-usage")
```

---

## 3. Workflow Fails Pass Rate Threshold (< 95%)

### Symptom:
`Execution FAILED: Pass rate (88.00%) is below required threshold of 95.0%`

### Solution:
1. Inspect uploaded Excel artifact `Automation_Test_Report.xlsx` -> **Failed Tests** sheet.
2. Review failure screenshots in `automation/screenshots/`.
3. Fix UI locators or timing parameters in `automation/pages/`.
