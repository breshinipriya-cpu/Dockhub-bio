import sys
import os

# Insert workspace root in sys.path
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(BASE_DIR))

from mobile_automation.config.appium_config import AppiumConfig
from mobile_automation.utils.appium_logger import AppiumLogger
from mobile_automation.tests.test_mobile_suite import MobileTestSuiteRunner
from mobile_automation.utils.mobile_excel_reporter import MobileExcelReporter
from mobile_automation.utils.mobile_html_reporter import MobileHTMLReporter
from mobile_automation.utils.mobile_summary_generator import MobileSummaryGenerator

def main():
    logger = AppiumLogger.get_logger()
    logger.info("=================================================================")
    logger.info("  ANDROID APPIUM MOBILE E2E AUTOMATION & CI/CD REPORTING HARNESS ")
    logger.info("=================================================================")

    # Step 1: Run 480 Mobile Appium E2E Test Cases
    runner = MobileTestSuiteRunner()
    results = runner.run_all_480_mobile_tests()

    total = len(results)
    passed = sum(1 for r in results if r["status"].upper() == "PASSED")
    failed = sum(1 for r in results if r["status"].upper() == "FAILED")
    pass_rate = (passed / total * 100.0) if total > 0 else 0.0

    logger.info("-----------------------------------------------------------------")
    logger.info(f"Total Appium Tests Executed: {total}")
    logger.info(f"Passed                    : {passed}")
    logger.info(f"Failed                    : {failed}")
    logger.info(f"Pass Percentage           : {pass_rate:.2f}%")
    logger.info("-----------------------------------------------------------------")

    # Step 2: Generate Reports
    logger.info("Generating Excel Reports...")
    excel_files = MobileExcelReporter.generate_excel_reports(results)

    logger.info("Generating HTML & JSON Reports...")
    html_files = MobileHTMLReporter.generate_html_reports(results)

    logger.info("Publishing Step Summary...")
    summary_file = MobileSummaryGenerator.generate_summary(results)
    logger.info(f"Summary Written to: {summary_file}")

    # Step 3: Failure criteria enforcement
    if pass_rate < 95.0:
        logger.error(f"Mobile Pipeline FAILED: Pass rate ({pass_rate:.2f}%) below required threshold of 95.0%.")
        sys.exit(1)

    logger.info("[SUCCESS] Mobile Appium Automation execution completed cleanly!")
    sys.exit(0)

if __name__ == "__main__":
    main()
