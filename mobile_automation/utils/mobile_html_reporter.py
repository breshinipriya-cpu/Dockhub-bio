import os
import json
from typing import List, Dict, Any
from mobile_automation.config.appium_config import AppiumConfig

class MobileHTMLReporter:
    @staticmethod
    def generate_html_reports(results: List[Dict[str, Any]], output_dir: str = None) -> Dict[str, str]:
        target_dir = output_dir or os.path.join(AppiumConfig.REPORTS_DIR, "HTML")
        os.makedirs(target_dir, exist_ok=True)

        total = len(results)
        passed = sum(1 for r in results if r["status"].upper() == "PASSED")
        failed = sum(1 for r in results if r["status"].upper() == "FAILED")
        skipped = sum(1 for r in results if r["status"].upper() in ["SKIPPED", "BLOCKED"])
        pass_rate = (passed / total * 100.0) if total > 0 else 0.0

        # Also write JSON results file
        json_dir = os.path.join(AppiumConfig.REPORTS_DIR, "JSON")
        os.makedirs(json_dir, exist_ok=True)
        json_file = os.path.join(json_dir, "execution-results.json")
        with open(json_file, "w", encoding="utf-8") as f:
            json.dump({
                "total": total,
                "passed": passed,
                "failed": failed,
                "skipped": skipped,
                "pass_rate": pass_rate,
                "device_info": {
                    "platform": AppiumConfig.PLATFORM_NAME,
                    "version": AppiumConfig.PLATFORM_VERSION,
                    "device": AppiumConfig.DEVICE_NAME,
                    "automation_engine": AppiumConfig.AUTOMATION_NAME
                },
                "results": results
            }, f, indent=2)

        # File 1: execution-report.html
        report_file = os.path.join(target_dir, "execution-report.html")
        rows_html = ""
        for r in results:
            status = r["status"].upper()
            badge_class = "pass" if status == "PASSED" else "fail" if status == "FAILED" else "skip"
            rows_html += f"""
            <tr>
                <td><code>{r['test_id']}</code></td>
                <td>{r['module']}</td>
                <td>{r['name']}</td>
                <td><span class="badge {badge_class}">{status}</span></td>
                <td>{r.get('duration_ms', 0):.1f} ms</td>
                <td>{r.get('failure_reason', '-')}</td>
            </tr>
            """

        html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Android Appium E2E Automation Report</title>
    <style>
        body {{ font-family: 'Segoe UI', system-ui, sans-serif; background-color: #0b0f19; color: #e2e8f0; margin: 0; padding: 24px; }}
        h1 {{ color: #38bdf8; font-size: 24px; }}
        .device-info {{ background: #1e293b; padding: 12px 20px; border-radius: 8px; font-size: 13px; color: #94a3b8; margin-bottom: 20px; border: 1px solid #334155; }}
        .metrics {{ display: flex; gap: 16px; margin: 20px 0; }}
        .card {{ background: #1e293b; border: 1px solid #334155; border-radius: 8px; padding: 16px 24px; flex: 1; }}
        .card h3 {{ margin: 0; font-size: 13px; color: #94a3b8; text-transform: uppercase; }}
        .card p {{ margin: 8px 0 0 0; font-size: 28px; font-weight: bold; }}
        .card.pass p {{ color: #4ade80; }}
        .card.fail p {{ color: #f87171; }}
        .card.rate p {{ color: #38bdf8; }}
        table {{ width: 100%; border-collapse: collapse; background: #1e293b; border-radius: 8px; overflow: hidden; margin-top: 20px; }}
        th, td {{ padding: 12px 16px; text-align: left; border-bottom: 1px solid #334155; font-size: 13px; }}
        th {{ background: #0f172a; color: #94a3b8; }}
        .badge {{ padding: 4px 8px; border-radius: 12px; font-size: 11px; font-weight: bold; }}
        .badge.pass {{ background: rgba(74, 222, 128, 0.2); color: #4ade80; }}
        .badge.fail {{ background: rgba(248, 113, 113, 0.2); color: #f87171; }}
        .badge.skip {{ background: rgba(250, 204, 21, 0.2); color: #facc15; }}
    </style>
</head>
<body>
    <h1>📱 Android Appium E2E Automation Report</h1>
    <div class="device-info">
        <strong>Device Info:</strong> {AppiumConfig.DEVICE_NAME} ({AppiumConfig.PLATFORM_NAME} {AppiumConfig.PLATFORM_VERSION}) | Engine: {AppiumConfig.AUTOMATION_NAME} | Package: <code>{AppiumConfig.APP_PACKAGE}</code>
    </div>
    
    <div class="metrics">
        <div class="card"><h3>Total Tests</h3><p>{total}</p></div>
        <div class="card pass"><h3>Passed</h3><p>{passed}</p></div>
        <div class="card fail"><h3>Failed</h3><p>{failed}</p></div>
        <div class="card rate"><h3>Pass Rate</h3><p>{pass_rate:.1f}%</p></div>
    </div>

    <table>
        <thead>
            <tr>
                <th>Test ID</th>
                <th>Module</th>
                <th>Test Name</th>
                <th>Status</th>
                <th>Duration</th>
                <th>Details</th>
            </tr>
        </thead>
        <tbody>
            {rows_html}
        </tbody>
    </table>
</body>
</html>"""

        with open(report_file, "w", encoding="utf-8") as f:
            f.write(html_content)

        # File 2: dashboard.html
        dashboard_file = os.path.join(target_dir, "dashboard.html")
        dashboard_content = html_content.replace("Execution Report", "Executive Dashboard")
        with open(dashboard_file, "w", encoding="utf-8") as f:
            f.write(dashboard_content)

        # File 3: trends.html
        trends_file = os.path.join(target_dir, "trends.html")
        trends_content = html_content.replace("Execution Report", "Historical Trends Analysis")
        with open(trends_file, "w", encoding="utf-8") as f:
            f.write(trends_content)

        return {
            "execution_report": report_file,
            "dashboard": dashboard_file,
            "trends": trends_file
        }
