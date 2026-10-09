# ⚙️ Mobile Repository Configuration Guide

Settings and permissions required to enable automated Android APK builds, Appium E2E testing, and GitHub Pages report hosting.

---

## 🔑 Required Repository Permissions
Ensure the following permissions are configured in GitHub Repository Settings:

1. **Actions Permissions:**
   - **Workflow permissions:** Set to `Read and write permissions`.
   - **Allow GitHub Actions to create and approve pull requests:** Checked.

2. **GitHub Pages Settings:**
   - **Source:** `GitHub Actions`.
   - **Custom Domain:** Optional.

---

## 🌐 Live Hosted Report Links
Once the workflow completes on GitHub Actions, reports are accessible at:

- **Latest Execution Report:**
  `https://breshinipriya-cpu.github.io/Dockhub-bio/reports/latest/execution-report.html`

- **Historical Execution Archive:**
  `https://breshinipriya-cpu.github.io/Dockhub-bio/reports/history/build-1/execution-report.html`
