import os
from datetime import datetime
from typing import List, Dict, Any
from automation.config.config import Config

class SummaryGenerator:
    @staticmethod
    def generate_summary(results: List[Dict[str, Any]], deployment_passed: bool = True, output_dir: str = None) -> str:
        target_dir = output_dir or os.path.join(Config.REPORTS_DIR, "Summary")
        os.makedirs(target_dir, exist_ok=True)
        summary_file = os.path.join(target_dir, "summary.md")

        total = len(results)
        passed = sum(1 for r in results if r["status"].upper() == "PASSED")
        failed = sum(1 for r in results if r["status"].upper() == "FAILED")
        skipped = sum(1 for r in results if r["status"].upper() in ["SKIPPED", "BLOCKED"])
        pass_rate = (passed / total * 100.0) if total > 0 else 0.0

        build_status = "PASS" if deployment_passed else "FAIL"
        deploy_status = "PASS" if deployment_passed else "FAIL"
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC")

        # Top passing modules
        modules = {}
        for r in results:
            mod = r.get("module", "General")
            if mod not in modules:
                modules[mod] = {"total": 0, "passed": 0}
            modules[mod]["total"] += 1
            if r["status"].upper() == "PASSED":
                modules[mod]["passed"] += 1

        top_passing_html = ""
        for mod, counts in modules.items():
            rate = (counts["passed"] / counts["total"] * 100.0) if counts["total"] > 0 else 0.0
            top_passing_html += f"- **{mod}**: {rate:.1f}% ({counts['passed']}/{counts['total']})\n"

        failed_items_html = ""
        failed_tests = [r for r in results if r["status"].upper() == "FAILED"]
        if not failed_tests:
            failed_items_html = "- *None! All executed tests passed cleanly.*\n"
        else:
            for r in failed_tests[:10]:
                failed_items_html += f"- **{r['test_id']}**: {r['name']} — `{r.get('failure_reason', 'Assertion Error')}`\n"

        markdown_content = f"""# Live GitHub Pages E2E Execution Summary

**Deployment URL:**
{Config.BASE_URL}

**Execution Date:**
{timestamp}

**Build Status:**
{build_status}

**Deployment Status:**
{deploy_status}

**Total Test Cases:**
{total}

**Execution Statistics:**
- **Executed:** {total}
- **Passed:** {passed}
- **Failed:** {failed}
- **Skipped:** {skipped}

**Pass Percentage:**
{pass_rate:.2f}%

---

### 🏆 Top Passing Modules:
{top_passing_html}

### ⚠️ Failed Tests Overview:
{failed_items_html}

---

### 📦 Artifacts Generated:
- ✓ Excel Reports (`Automation_Test_Report.xlsx`, `Summary_Report.xlsx`, etc.)
- ✓ HTML Reports (`execution-report.html`, `dashboard.html`)
- ✓ Screenshots (`screenshots/`)
- ✓ Logs (`logs/`)
- ✓ JSON Results (`execution-results.json`)
"""

        with open(summary_file, "w", encoding="utf-8") as f:
            f.write(markdown_content)

        # Write to $GITHUB_STEP_SUMMARY if present
        github_summary_env = os.getenv("GITHUB_STEP_SUMMARY")
        if github_summary_env:
            try:
                with open(github_summary_env, "a", encoding="utf-8") as f:
                    f.write(markdown_content)
            except Exception as e:
                print(f"Notice: Could not write to GITHUB_STEP_SUMMARY: {e}")

        return summary_file
