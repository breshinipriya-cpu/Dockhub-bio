import os
from datetime import datetime
from mobile_automation.config.appium_config import AppiumConfig
from mobile_automation.utils.appium_logger import AppiumLogger

class AppiumScreenshot:
    @staticmethod
    def capture_screenshot(driver, test_id: str, status: str = "FAILED") -> str:
        os.makedirs(AppiumConfig.SCREENSHOTS_DIR, exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{test_id}_{status}_{timestamp}.png"
        filepath = os.path.join(AppiumConfig.SCREENSHOTS_DIR, filename)
        
        try:
            driver.save_screenshot(filepath)
            AppiumLogger.get_logger().info(f"Screenshot saved to: {filepath}")
            return filepath
        except Exception as e:
            AppiumLogger.get_logger().error(f"Failed to capture screenshot for {test_id}: {e}")
            return ""
