import os
import json
from typing import List, Dict, Any
from automation.config.config import Config

class HTMLReporter:
    @staticmethod
    def generate_html_reports(results: List[Dict[str, Any]], output_dir: str = None) -> Dict[str, str]:
        target_dir = output_dir or os.path.join(Config.REPORTS_DIR, "HTML")
        os.makedirs(target_dir, exist_ok=True)

        total = len(results)
        passed = sum(1 for r in results if r["status"].upper() == "PASSED")
        failed = sum(1 for r in results if r["status"].upper() == "FAILED")
        skipped = sum(1 for r in results if r["status"].upper() in ["SKIPPED", "BLOCKED"])
        pass_rate = (passed / total * 100.0) if total > 0 else 0.0

        # Save JSON output as well
        json_dir = os.path.join(Config.REPORTS_DIR, "JSON")
        os.makedirs(json_dir, exist_ok=True)
        json_path = os.path.join(json_dir, "execution-results.json")
        with open(json_path, "w") as f:
            json.dump({
                "total": total,
                "passed": passed,
                "failed": failed,
                "skipped": skipped,
                "pass_rate": pass_rate,
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
    <title>E2E Automation Execution Report - Live GitHub Pages</title>
    <style>
        body {{ font-family: 'Segoe UI', system-ui, sans-serif; background-color: #0d1117; color: #c9d1d9; margin: 0; padding: 24px; }}
        h1 {{ color: #58a6ff; font-size: 24px; }}
        .metrics {{ display: flex; gap: 16px; margin: 20px 0; }}
        .card {{ background: #161b22; border: 1px solid #30363d; border-radius: 8px; padding: 16px 24px; flex: 1; }}
        .card h3 {{ margin: 0; font-size: 13px; color: #8b949e; text-transform: uppercase; }}
        .card p {{ margin: 8px 0 0 0; font-size: 28px; font-weight: bold; }}
        .card.pass p {{ color: #3fb950; }}
        .card.fail p {{ color: #f85149; }}
        .card.rate p {{ color: #a5d6ff; }}
        table {{ width: 100%; border-collapse: collapse; background: #161b22; border-radius: 8px; overflow: hidden; margin-top: 20px; }}
        th, td {{ padding: 12px 16px; text-align: left; border-bottom: 1px solid #30363d; font-size: 13px; }}
        th {{ background: #21262d; color: #8b949e; }}
        .badge {{ padding: 4px 8px; border-radius: 12px; font-size: 11px; font-weight: bold; }}
        .badge.pass {{ background: rgba(63, 185, 80, 0.2); color: #3fb950; }}
        .badge.fail {{ background: rgba(248, 81, 73, 0.2); color: #f85149; }}
        .badge.skip {{ background: rgba(210, 153, 34, 0.2); color: #d29922; }}
    </style>
</head>
<body>
    <h1>🚀 Live E2E Automation Execution Report</h1>
    <p>Target Environment: <code>{Config.BASE_URL}</code></p>
    
    <div class="metrics">
        <div class="card"><div class="card"><h3>Total Tests</h3><p>{total}</p></div></div>
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

        with open(report_file, "w") as f:
            f.write(html_content)

        # File 2: dashboard.html
        dashboard_file = os.path.join(target_dir, "dashboard.html")
        dashboard_content = html_content.replace("Execution Report", "Executive Quality Dashboard")
        with open(dashboard_file, "w") as f:
            f.write(dashboard_content)

        return {
            "execution_report": report_file,
            "dashboard": dashboard_file
        }
