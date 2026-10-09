import sys
import os
import time
import requests
from urllib.parse import urljoin
from automation.config.config import Config
from automation.utils.logger_utility import LoggerUtility

def verify_deployment(base_url: str = None, retries: int = 12, delay: int = 10) -> bool:
    url = base_url or Config.BASE_URL
    logger = LoggerUtility.get_logger()
    logger.info(f"Verifying live deployment availability at: {url}")

    for attempt in range(1, retries + 1):
        try:
            if url.startswith("file://"):
                file_path = url.replace("file:///", "").replace("file://", "")
                if os.path.exists(file_path):
                    logger.info("Local HTML file verified successfully.")
                    return True
                else:
                    logger.warning("Local HTML file path does not exist.")
                    return False
            response = requests.get(url, timeout=15)
            logger.info(f"[Attempt {attempt}/{retries}] Status code: {response.status_code}")

            if response.status_code == 200:
                html_content = response.text
                
                # Check for mandatory HTML structure
                if "<html" in html_content and "</html" in html_content:
                    logger.info("Main HTML page rendered successfully.")
                else:
                    logger.warning("Main page did not contain valid HTML tags.")

                # Check CSS Asset
                css_url = urljoin(url, "style.css")
                css_resp = requests.get(css_url, timeout=10)
                if css_resp.status_code == 200:
                    logger.info("CSS asset (style.css) loaded successfully.")
                else:
                    logger.warning(f"CSS asset returned HTTP {css_resp.status_code}")

                # Check JS Asset
                js_url = urljoin(url, "script.js")
                js_resp = requests.get(js_url, timeout=10)
                if js_resp.status_code == 200:
                    logger.info("JavaScript asset (script.js) loaded successfully.")
                else:
                    logger.warning(f"JS asset returned HTTP {js_resp.status_code}")

                logger.info("Live deployment verification PASSED successfully!")
                return True

        except Exception as e:
            logger.warning(f"[Attempt {attempt}/{retries}] Connection attempt failed: {e}")

        time.sleep(delay)

    logger.error(f"Deployment verification FAILED for URL: {url}")
    return False

if __name__ == "__main__":
    target_url = sys.argv[1] if len(sys.argv) > 1 else Config.BASE_URL
    success = verify_deployment(target_url)
    if not success:
        sys.exit(1)
