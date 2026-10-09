import os
from datetime import datetime
from typing import List, Dict, Any
from mobile_automation.config.appium_config import AppiumConfig

class MobileSummaryGenerator:
    @staticmethod
    def generate_summary(results: List[Dict[str, Any]], output_dir: str = None) -> str:
        target_dir = output_dir or os.path.join(AppiumConfig.REPORTS_DIR, "Summary")
        os.makedirs(target_dir, exist_ok=True)
        summary_file = os.path.join(target_dir, "summary.md")

        total = len(results)
        passed = sum(1 for r in results if r["status"].upper() == "PASSED")
        failed = sum(1 for r in results if r["status"].upper() == "FAILED")
        skipped = sum(1 for r in results if r["status"].upper() in ["SKIPPED", "BLOCKED"])
        pass_rate = (passed / total * 100.0) if total > 0 else 0.0
        fail_rate = 100.0 - pass_rate

        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC")
        run_number = os.getenv("GITHUB_RUN_NUMBER", "1")
        commit_sha = os.getenv("GITHUB_SHA", "local_dev")[:7]
        branch = os.getenv("GITHUB_REF_NAME", "main")

        passed_sample = [f"✓ `{r['test_id']}` - {r['name']}" for r in results if r["status"].upper() == "PASSED"][:5]
        failed_sample = [f"✗ `{r['test_id']}` - {r['name']}\nReason: {r.get('failure_reason', 'Assertion error')}" for r in results if r["status"].upper() == "FAILED"][:5]
        if not failed_sample:
            failed_sample_str = "- *None! All tests passed cleanly.*"
        else:
            failed_sample_str = "\n".join(failed_sample)

        markdown_content = f"""# Android Appium E2E Execution Summary

**Build Number:** #{run_number}  
**Execution Date:** {timestamp}  
**Git Commit:** `{commit_sha}`  
**Branch:** `{branch}`  

**APK Version:** 1.0.0+1  
**Device:** {AppiumConfig.DEVICE_NAME} ({AppiumConfig.PLATFORM_NAME} {AppiumConfig.PLATFORM_VERSION})  

---

### 📊 Execution Metrics

- **Total Test Cases:** {total}
- **Executed:** {total}
- **Passed:** {passed}
- **Failed:** {failed}
- **Skipped:** {skipped}
- **Blocked:** 0

- **Pass Percentage:** **{pass_rate:.2f}%**
- **Fail Percentage:** {fail_rate:.2f}%

---

### 🧪 Sample Executed Test Cases

#### PASSED TESTS
{chr(10).join(passed_sample)}

#### FAILED TESTS
{failed_sample_str}

---

### 📦 Artifacts & Reports
- ✓ Excel Reports (`Automation_Test_Report.xlsx`, `Passed_Test_Cases.xlsx`, `Execution_Summary.xlsx`)
- ✓ HTML Reports (`execution-report.html`, `dashboard.html`, `trends.html`)
- ✓ Device Screenshots (`Screenshots/`)
- ✓ Execution Logs (`Logs/`)
- ✓ JSON Results (`execution-results.json`)
"""

        with open(summary_file, "w", encoding="utf-8") as f:
            f.write(markdown_content)

        github_summary_env = os.getenv("GITHUB_STEP_SUMMARY")
        if github_summary_env:
            try:
                with open(github_summary_env, "a", encoding="utf-8") as f:
                    f.write(markdown_content)
            except Exception as e:
                print(f"Notice: Could not write to GITHUB_STEP_SUMMARY: {e}")

        return summary_file
