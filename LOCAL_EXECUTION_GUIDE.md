# 💻 Local Execution Guide - Phase 7 E2E Automation

This guide describes how to run the enterprise Selenium E2E test suite locally against local or live staging environments.

---

## 📋 Prerequisites
1. **Python 3.10+** installed.
2. **Google Chrome** installed.
3. Python dependencies: `selenium`, `openpyxl`, `requests`.

```bash
pip install selenium openpyxl requests
```

---

## 🚀 Running the Framework Locally

### 1. Set the Target Deployment URL
By default, tests target the live GitHub Pages URL:
`https://breshinipriya-cpu.github.io/Dockhub-bio/`

You can override the target URL using the `BASE_URL` environment variable:

**PowerShell (Windows):**
```powershell
$env:BASE_URL="https://breshinipriya-cpu.github.io/Dockhub-bio/"
$env:HEADLESS="true"
python automation/run_framework.py
```

**Bash / macOS / Linux:**
```bash
export BASE_URL="https://breshinipriya-cpu.github.io/Dockhub-bio/"
export HEADLESS="true"
python automation/run_framework.py
```

---

## 📁 Generated Reports & Outputs
After execution finishes, reports will be saved in `automation/reports/`:
- **Excel Reports**: `automation/reports/Excel/Automation_Test_Report.xlsx`
- **HTML Reports**: `automation/reports/HTML/execution-report.html`
- **Summary**: `automation/reports/Summary/summary.md`
- **Screenshots**: `automation/screenshots/`
- **Execution Logs**: `automation/logs/`
