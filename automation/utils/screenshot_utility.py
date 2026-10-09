import os
from datetime import datetime
from automation.config.config import Config
from automation.utils.logger_utility import LoggerUtility

class ScreenshotUtility:
    @staticmethod
    def capture_screenshot(driver, test_id: str, status: str = "FAILED") -> str:
        os.makedirs(Config.SCREENSHOTS_DIR, exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{test_id}_{status}_{timestamp}.png"
        filepath = os.path.join(Config.SCREENSHOTS_DIR, filename)
        
        try:
            driver.save_screenshot(filepath)
            LoggerUtility.get_logger().info(f"Screenshot captured: {filepath}")
            return filepath
        except Exception as e:
            LoggerUtility.get_logger().error(f"Failed to capture screenshot for {test_id}: {e}")
            return ""
