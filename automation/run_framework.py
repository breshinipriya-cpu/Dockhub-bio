import sys
import os
import time

# Ensure automation root is in sys.path
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(BASE_DIR))

from automation.config.config import Config
from automation.utils.logger_utility import LoggerUtility
from automation.utils.verify_deployment import verify_deployment
from automation.tests.test_suite import TestSuiteRunner
from automation.utils.excel_reporter import ExcelReporter
from automation.utils.html_reporter import HTMLReporter
from automation.utils.summary_generator import SummaryGenerator

def main():
    logger = LoggerUtility.get_logger()
    base_url = os.getenv("BASE_URL", Config.BASE_URL)

    logger.info("=================================================================")
    logger.info("  PHASE 7 — LIVE GITHUB PAGES E2E AUTOMATION & DEPLOYMENT TEST  ")
    logger.info("=================================================================")
    logger.info(f"Target Base URL: {base_url}")

    # Stage 1: Deployment Verification
    logger.info("Step 1: Running Live Deployment Verification...")
    deploy_ok = verify_deployment(base_url)
    if not deploy_ok:
        logger.error("Deployment Verification FAILED! Aborting test execution.")
        SummaryGenerator.generate_summary([], deployment_passed=False)
        sys.exit(1)

    # Stage 2: Execute 430 E2E Selenium Tests
    logger.info("Step 2: Executing 430 Selenium E2E Test Cases...")
    runner = TestSuiteRunner(base_url)
    results = runner.run_all_400_plus_tests()

    total = len(results)
    passed = sum(1 for r in results if r["status"].upper() == "PASSED")
    failed = sum(1 for r in results if r["status"].upper() == "FAILED")
    pass_rate = (passed / total * 100.0) if total > 0 else 0.0

    logger.info("-----------------------------------------------------------------")
    logger.info(f"Total Tests Executed: {total}")
    logger.info(f"Passed              : {passed}")
    logger.info(f"Failed              : {failed}")
    logger.info(f"Pass Percentage     : {pass_rate:.2f}%")
    logger.info("-----------------------------------------------------------------")

    # Stage 3: Report Generation
    logger.info("Step 3: Generating Excel Reports...")
    excel_files = ExcelReporter.generate_excel_reports(results)
    logger.info(f"Excel Reports Generated: {list(excel_files.keys())}")

    logger.info("Step 4: Generating HTML Reports...")
    html_files = HTMLReporter.generate_html_reports(results)
    logger.info(f"HTML Reports Generated: {list(html_files.keys())}")

    logger.info("Step 5: Publishing Step Summary...")
    summary_file = SummaryGenerator.generate_summary(results, deployment_passed=True)
    logger.info(f"Summary Written to: {summary_file}")

    # Stage 4: Enforce Pass/Fail Logic (Pass Rate >= 95%)
    if pass_rate < 95.0:
        logger.error(f"Execution FAILED: Pass rate ({pass_rate:.2f}%) is below required threshold of 95.0%.")
        sys.exit(1)

    logger.info("✅ SUCCESS: Execution completed with pass rate >= 95.0%!")
    sys.exit(0)

if __name__ == "__main__":
    main()
