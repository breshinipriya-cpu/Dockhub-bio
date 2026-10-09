# 🚀 CI/CD Execution & GitHub Actions Setup Guide

This guide details how the continuous deployment and automated testing pipeline operates on GitHub Actions.

---

## ⚙️ GitHub Repository Configuration

To enable GitHub Pages deployment and automated testing:

1. Navigate to your repository settings on GitHub:
   `https://github.com/breshinipriya-cpu/Dockhub-bio/settings`
2. Scroll to **Pages** in the left sidebar.
3. Under **Build and deployment**:
   - **Source**: Select `GitHub Actions`.

---

## 🔄 Workflow Triggering & Execution Flow

The workflow `.github/workflows/deploy-and-test.yml` triggers automatically on:
- Every `push` to `main` branch
- Every `pull_request` targeting `main`
- Manual trigger (`workflow_dispatch`)

### Pipeline Execution Stages:
1. **Stage 1 - 5: Build & Deploy**
   - Checks out the repository.
   - Bundles `index.html`, `script.js`, and `style.css` into an deployment artifact.
   - Deploys static site to GitHub Pages (`https://breshinipriya-cpu.github.io/Dockhub-bio/`).

2. **Stage 6 - 7: Live Verification**
   - Polls the live URL until HTTP 200 is confirmed and CSS/JS assets return clean status.

3. **Stage 8 - 10: 430 Selenium E2E Tests**
   - Spawns Headless Chrome and executes all 430 test cases across 14 test modules.
   - Generates Excel, HTML, JSON, and summary reports.

4. **Stage 11 - 13: Artifact Upload & Summary**
   - Uploads all report artifacts with a 30-day retention period.
   - Publishes step summary directly to the GitHub Action run dashboard (`$GITHUB_STEP_SUMMARY`).
