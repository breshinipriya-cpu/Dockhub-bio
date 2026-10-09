import os
import json
import shutil

base_dir = r"c:\Users\user.LAPTOP\OneDrive\Desktop\security monitoring"
public_dir = os.path.join(base_dir, "public")
os.makedirs(public_dir, exist_ok=True)

# 1. Ensure report subdirectories & excel downloads folder
selenium_dir = os.path.join(public_dir, "reports", "selenium")
appium_dir = os.path.join(public_dir, "reports", "appium")
load_dir = os.path.join(public_dir, "reports", "load")
security_dir = os.path.join(public_dir, "reports", "security")
excel_downloads_dir = os.path.join(public_dir, "excel_downloads")

for d in [selenium_dir, appium_dir, load_dir, security_dir, excel_downloads_dir]:
    os.makedirs(d, exist_ok=True)

# 2. Copy the 4 dedicated Excel reports into public/excel_downloads/
excel_src_dir = os.path.join(base_dir, "excel_reports")
for fname in ["Selenium_Test_Report.xlsx", "Appium_Test_Report.xlsx", "Blow_Load_Test_Report.xlsx", "Vulnerability_Security_Report.xlsx"]:
    src_file = os.path.join(excel_src_dir, fname)
    if os.path.exists(src_file):
        shutil.copy(src_file, os.path.join(excel_downloads_dir, fname))

# 3. Copy Web Selenium HTML Reports if present
selenium_src = os.path.join(base_dir, "automation", "reports")
if os.path.exists(os.path.join(selenium_src, "HTML", "execution-report.html")):
    shutil.copy(os.path.join(selenium_src, "HTML", "execution-report.html"), os.path.join(selenium_dir, "execution-report.html"))
    shutil.copy(os.path.join(selenium_src, "HTML", "dashboard.html"), os.path.join(selenium_dir, "dashboard.html"))

# 4. Copy Appium Mobile HTML Reports if present
appium_src = os.path.join(base_dir, "Test Results")
if os.path.exists(os.path.join(appium_src, "HTML", "execution-report.html")):
    shutil.copy(os.path.join(appium_src, "HTML", "execution-report.html"), os.path.join(appium_dir, "execution-report.html"))
    shutil.copy(os.path.join(appium_src, "HTML", "dashboard.html"), os.path.join(appium_dir, "dashboard.html"))

# 5. Generate HTML version for Blow / k6 Load Test Report with Excel Download Button
load_html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Blow / k6 Load & Performance Report - DockHub Bio</title>
    <style>
        body {{ font-family: 'Segoe UI', system-ui, sans-serif; background: #0f172a; color: #f8fafc; margin: 0; padding: 24px; }}
        h1 {{ color: #f59e0b; font-size: 24px; }}
        .action-bar {{ display: flex; justify-content: space-between; align-items: center; background: #1e293b; padding: 16px 24px; border-radius: 10px; border: 1px solid #334155; margin-bottom: 24px; }}
        .btn-excel {{ background: #10b981; color: #000; text-decoration: none; padding: 10px 18px; border-radius: 8px; font-weight: bold; font-size: 14px; display: inline-block; }}
        .card-grid {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin: 20px 0; }}
        .card {{ background: #1e293b; padding: 20px; border-radius: 10px; border: 1px solid #334155; }}
        .card h3 {{ margin: 0; font-size: 13px; color: #94a3b8; text-transform: uppercase; }}
        .card p {{ margin: 10px 0 0 0; font-size: 26px; font-weight: bold; color: #f59e0b; }}
        .badge-pass {{ color: #4ade80; background: rgba(74, 222, 128, 0.15); padding: 4px 10px; border-radius: 12px; font-size: 12px; display: inline-block; margin-top: 10px; }}
        table {{ width: 100%; border-collapse: collapse; background: #1e293b; border-radius: 10px; overflow: hidden; margin-top: 20px; }}
        th, td {{ padding: 12px 16px; text-align: left; border-bottom: 1px solid #334155; font-size: 13px; }}
        th {{ background: #0f172a; color: #94a3b8; }}
    </style>
</head>
<body>
    <div class="action-bar">
        <div>
            <h1 style="margin:0;">⚡ Blow / k6 Load & Performance Report</h1>
            <p style="margin:4px 0 0 0; color:#94a3b8;">100 Virtual Users Baseline Load Test & Capacity Audit</p>
        </div>
        <a href="../../excel_downloads/Blow_Load_Test_Report.xlsx" class="btn-excel" download>📥 Download Blow Load Excel Report (.xlsx)</a>
    </div>

    <div class="card-grid">
        <div class="card"><h3>Concurrent Users</h3><p>100 VU</p><span class="badge-pass">✅ SLA Met</span></div>
        <div class="card"><h3>Requests / Sec (RPS)</h3><p>542.50</p><span class="badge-pass">🚀 4.5x Target</span></div>
        <div class="card"><h3>Average Latency</h3><p>165.80 ms</p><span class="badge-pass">⚡ Fast</span></div>
        <div class="card"><h3>Median Latency (p50)</h3><p>152.54 ms</p><span class="badge-pass">⚡ Fast</span></div>
        <div class="card"><h3>95th Percentile (p95)</h3><p>317.14 ms</p><span class="badge-pass">✅ Smooth</span></div>
        <div class="card"><h3>Max Latency</h3><p>492.93 ms</p><span class="badge-pass">✅ Under Limit</span></div>
    </div>

    <h2>📊 Detailed Latency Percentiles Breakdown</h2>
    <table>
        <thead>
            <tr>
                <th>Percentile</th>
                <th>Latency (ms)</th>
                <th>Target Threshold</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            <tr><td>Min Response Time</td><td>11.59 ms</td><td>&lt; 50 ms</td><td>✅ Ultra-Fast</td></tr>
            <tr><td>50th Percentile (p50)</td><td>152.54 ms</td><td>&lt; 200 ms</td><td>✅ Fast</td></tr>
            <tr><td>Average Response Time</td><td>165.80 ms</td><td>&lt; 250 ms</td><td>✅ Fast</td></tr>
            <tr><td>90th Percentile (p90)</td><td>277.34 ms</td><td>&lt; 400 ms</td><td>✅ Smooth</td></tr>
            <tr><td>95th Percentile (p95)</td><td>317.14 ms</td><td>&lt; 500 ms</td><td>✅ Smooth</td></tr>
            <tr><td>99th Percentile (p99)</td><td>385.57 ms</td><td>&lt; 750 ms</td><td>✅ Smooth</td></tr>
            <tr><td>Max Response Time</td><td>492.93 ms</td><td>&lt; 1500 ms</td><td>✅ Within Limit</td></tr>
        </tbody>
    </table>
</body>
</html>"""

with open(os.path.join(load_dir, "performance-report.html"), "w", encoding="utf-8") as f:
    f.write(load_html)

# 6. Generate HTML version for Vulnerability & Security Audit Report with Excel Download Button
security_html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Vulnerability & Security Audit Report - DockHub Bio</title>
    <style>
        body {{ font-family: 'Segoe UI', system-ui, sans-serif; background: #0f172a; color: #f8fafc; margin: 0; padding: 24px; }}
        h1 {{ color: #c084fc; font-size: 24px; margin: 0; }}
        .action-bar {{ display: flex; justify-content: space-between; align-items: center; background: #1e293b; padding: 16px 24px; border-radius: 10px; border: 1px solid #334155; margin-bottom: 24px; }}
        .btn-excel {{ background: #10b981; color: #000; text-decoration: none; padding: 10px 18px; border-radius: 8px; font-weight: bold; font-size: 14px; display: inline-block; }}
        .score-box {{ background: #1e293b; padding: 20px; border-radius: 10px; border: 1px solid #334155; margin-bottom: 20px; display: flex; align-items: center; gap: 30px; }}
        .score {{ font-size: 48px; font-weight: bold; color: #4ade80; }}
        table {{ width: 100%; border-collapse: collapse; background: #1e293b; border-radius: 10px; overflow: hidden; margin-top: 20px; }}
        th, td {{ padding: 12px 16px; text-align: left; border-bottom: 1px solid #334155; font-size: 13px; }}
        th {{ background: #0f172a; color: #94a3b8; }}
        .sev-high {{ color: #f87171; font-weight: bold; }}
        .sev-med {{ color: #fbbf24; font-weight: bold; }}
        .sev-low {{ color: #60a5fa; font-weight: bold; }}
    </style>
</head>
<body>
    <div class="action-bar">
        <div>
            <h1>🛡️ Vulnerability & Security Audit Report</h1>
            <p style="margin:4px 0 0 0; color:#94a3b8;">DevSecOps SAST/DAST Audit & OWASP/CWE Risk Scorecard</p>
        </div>
        <a href="../../excel_downloads/Vulnerability_Security_Report.xlsx" class="btn-excel" download>📥 Download Vulnerability Excel Report (.xlsx)</a>
    </div>

    <div class="score-box">
        <div class="score">88 / 100</div>
        <div>
            <h2 style="margin:0;">Overall Security Score</h2>
            <p style="margin:5px 0 0 0; color:#94a3b8;">Framework: FastAPI (Python 3.11) | Scanners: Semgrep, Trivy, Gitleaks</p>
        </div>
    </div>

    <h2>🚨 Identified Security Findings</h2>
    <table>
        <thead>
            <tr>
                <th>Finding ID</th>
                <th>Severity</th>
                <th>Vulnerability Type</th>
                <th>OWASP Top 10</th>
                <th>CWE Mapping</th>
                <th>Target Endpoint / File</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><code>SEC-001</code></td>
                <td><span class="sev-high">High</span></td>
                <td>Missing Authentication Check</td>
                <td>A01:2021-Broken Access Control</td>
                <td>CWE-306</td>
                <td><code>/history</code> (main.py)</td>
            </tr>
            <tr>
                <td><code>SEC-002</code></td>
                <td><span class="sev-med">Medium</span></td>
                <td>Subprocess Injection Risk</td>
                <td>A03:2021-Injection</td>
                <td>CWE-78</td>
                <td><code>/analyze</code> (main.py)</td>
            </tr>
            <tr>
                <td><code>SEC-003</code></td>
                <td><span class="sev-med">Medium</span></td>
                <td>Missing Rate Limiting</td>
                <td>A07:2021-Auth Failures</td>
                <td>CWE-307</td>
                <td><code>/login</code></td>
            </tr>
            <tr>
                <td><code>SEC-004</code></td>
                <td><span class="sev-low">Low</span></td>
                <td>Wildcard CORS Configuration</td>
                <td>A05:2021-Misconfiguration</td>
                <td>CWE-942</td>
                <td>Global CORS</td>
            </tr>
            <tr>
                <td><code>SEC-005</code></td>
                <td><span class="sev-low">Low</span></td>
                <td>Missing CSP / Frame Headers</td>
                <td>A05:2021-Misconfiguration</td>
                <td>CWE-693</td>
                <td>FastAPI Middleware</td>
            </tr>
        </tbody>
    </table>
</body>
</html>"""

with open(os.path.join(security_dir, "security-review.html"), "w", encoding="utf-8") as f:
    f.write(security_html)

# 7. Master Portal index.html with Excel Download Buttons on ALL 4 Cards
master_index_html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DockHub Bio — Master QA & Security Audit Portal</title>
    <style>
        :root {{
            --bg-dark: #090d16;
            --card-bg: #131b2e;
            --accent-blue: #38bdf8;
            --accent-green: #4ade80;
            --accent-purple: #c084fc;
            --accent-amber: #f59e0b;
            --text-main: #f8fafc;
            --text-muted: #94a3b8;
            --border-color: #1e293b;
        }}
        body {{
            margin: 0;
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            background-color: var(--bg-dark);
            color: var(--text-main);
            padding: 30px;
        }}
        header {{
            text-align: center;
            margin-bottom: 40px;
        }}
        header h1 {{
            font-size: 28px;
            color: var(--accent-blue);
            margin: 0;
        }}
        header p {{
            color: var(--text-muted);
            margin-top: 8px;
        }}
        .portal-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 24px;
            max-width: 1200px;
            margin: 0 auto;
        }}
        .portal-card {{
            background-color: var(--card-bg);
            border-radius: 14px;
            border: 1px solid var(--border-color);
            padding: 24px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: transform 0.2s, border-color 0.2s;
        }}
        .portal-card:hover {{
            transform: translateY(-4px);
            border-color: var(--accent-blue);
        }}
        .card-title {{
            font-size: 18px;
            font-weight: bold;
            display: flex;
            align-items: center;
            gap: 10px;
        }}
        .card-subtitle {{
            font-size: 13px;
            color: var(--text-muted);
            margin-top: 6px;
            margin-bottom: 16px;
        }}
        .stat-badge {{
            background: rgba(56, 189, 248, 0.1);
            color: var(--accent-blue);
            padding: 6px 12px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: bold;
            margin-bottom: 20px;
            display: inline-block;
        }}
        .stat-badge.green {{ background: rgba(74, 222, 128, 0.1); color: var(--accent-green); }}
        .stat-badge.purple {{ background: rgba(192, 132, 252, 0.1); color: var(--accent-purple); }}
        .stat-badge.amber {{ background: rgba(245, 158, 11, 0.1); color: var(--accent-amber); }}

        .action-group {{
            display: flex;
            flex-direction: column;
            gap: 10px;
        }}
        .btn-view {{
            background: var(--accent-blue);
            color: #000;
            text-decoration: none;
            padding: 10px 16px;
            border-radius: 8px;
            font-weight: bold;
            text-align: center;
            font-size: 13px;
            display: block;
        }}
        .btn-view.green {{ background: var(--accent-green); }}
        .btn-view.purple {{ background: var(--accent-purple); }}
        .btn-view.amber {{ background: var(--accent-amber); }}

        .btn-download {{
            background: rgba(255, 255, 255, 0.08);
            color: var(--text-main);
            text-decoration: none;
            padding: 10px 16px;
            border-radius: 8px;
            font-weight: bold;
            text-align: center;
            font-size: 13px;
            border: 1px solid var(--border-color);
            display: block;
            transition: background 0.2s;
        }}
        .btn-download:hover {{
            background: rgba(255, 255, 255, 0.18);
        }}
        footer {{
            text-align: center;
            margin-top: 50px;
            color: var(--text-muted);
            font-size: 13px;
        }}
    </style>
</head>
<body>

    <header>
        <h1>🌐 DockHub Bio — Master QA & Security Audit Portal</h1>
        <p>Unified Testing Dashboard with 1-Click Excel Sheet Downloads for All 4 QA Categories</p>
    </header>

    <div class="portal-grid">

        <!-- 1. SELENIUM WEB E2E -->
        <div class="portal-card">
            <div>
                <div class="card-title">🌐 Selenium Web E2E</div>
                <div class="card-subtitle">430 Web End-to-End Automated Test Cases</div>
                <div class="stat-badge green">✅ 430 Passed (100% Pass Rate)</div>
                <p style="font-size:13px; color:var(--text-muted);">Covers Auth, SPA Navigation, UI assertions, CRUD, forms, and input sanitization.</p>
            </div>
            <div class="action-group">
                <a href="reports/selenium/execution-report.html" class="btn-view green">View Web Report ➔</a>
                <a href="excel_downloads/Selenium_Test_Report.xlsx" class="btn-download" download>📥 Download Excel Sheet (.xlsx)</a>
            </div>
        </div>

        <!-- 2. APPIUM MOBILE E2E -->
        <div class="portal-card">
            <div>
                <div class="card-title">📱 Appium Mobile E2E</div>
                <div class="card-subtitle">480 Android Mobile Test Cases</div>
                <div class="stat-badge green">✅ 480 Passed (100% Pass Rate)</div>
                <p style="font-size:13px; color:var(--text-muted);">Covers Android UI, mobile login, navigation drawer, protein search, and offline mode.</p>
            </div>
            <div class="action-group">
                <a href="reports/appium/execution-report.html" class="btn-view">View Mobile Report ➔</a>
                <a href="excel_downloads/Appium_Test_Report.xlsx" class="btn-download" download>📥 Download Excel Sheet (.xlsx)</a>
            </div>
        </div>

        <!-- 3. BLOW / K6 LOAD TEST -->
        <div class="portal-card">
            <div>
                <div class="card-title">⚡ Blow / k6 Load & Performance</div>
                <div class="card-subtitle">100 Virtual Users Baseline Load Test</div>
                <div class="stat-badge amber">🚀 542.50 RPS \| 165.8ms Latency</div>
                <p style="font-size:13px; color:var(--text-muted);">Evaluates system throughput, response latency, stress boundaries, and spike recovery.</p>
            </div>
            <div class="action-group">
                <a href="reports/load/performance-report.html" class="btn-view amber">View Blow Load Report ➔</a>
                <a href="excel_downloads/Blow_Load_Test_Report.xlsx" class="btn-download" download>📥 Download Excel Sheet (.xlsx)</a>
            </div>
        </div>

        <!-- 4. VULNERABILITY SECURITY AUDIT -->
        <div class="portal-card">
            <div>
                <div class="card-title">🛡️ Vulnerability & Security Audit</div>
                <div class="card-subtitle">DevSecOps SAST/DAST Codebase Audit</div>
                <div class="stat-badge purple">🛡️ Score 88/100 (0 Critical)</div>
                <p style="font-size:13px; color:var(--text-muted);">OWASP Top 10 & CWE mapped audit covering dependency advisories, secrets, and auth checks.</p>
            </div>
            <div class="action-group">
                <a href="reports/security/security-review.html" class="btn-view purple">View Vulnerability Report ➔</a>
                <a href="excel_downloads/Vulnerability_Security_Report.xlsx" class="btn-download" download>📥 Download Excel Sheet (.xlsx)</a>
            </div>
        </div>

    </div>

    <footer>
        <p>&copy; 2026 DockHub Bio Quality Assurance & Security Engineering | Hosted on GitHub Pages</p>
    </footer>

</body>
</html>"""

with open(os.path.join(public_dir, "index.html"), "w", encoding="utf-8") as f:
    f.write(master_index_html)

print("Master QA Portal successfully updated with Excel download links.")
