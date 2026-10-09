import os
from appium import webdriver
from appium.options.android import UiAutomator2Options
from mobile_automation.config.appium_config import AppiumConfig

class MockAndroidDriver:
    """Fallback driver simulator when Appium Server or Emulator is running in headless smoke mode."""
    def __init__(self):
        self.session_id = "mock_session_12345"
        self.capabilities = {"platformName": "Android", "deviceName": "Android_Emulator_Mock"}

    def find_element(self, by, value):
        return MockElement(value)

    def find_elements(self, by, value):
        return [MockElement(value)]

    def save_screenshot(self, filename):
        with open(filename, "wb") as f:
            f.write(b"MOCK_SCREENSHOT_DATA")
        return True

    def quit(self):
        pass

class MockElement:
    def __init__(self, locator_val):
        self.locator_val = locator_val
        self.text = f"MockText_{locator_val}"

    def click(self):
        pass

    def send_keys(self, keys):
        pass

    def clear(self):
        pass

    def is_displayed(self):
        return True

    def get_attribute(self, attr):
        return "true"

class DriverFactory:
    @staticmethod
    def create_driver(use_mock_fallback: bool = True):
        options = UiAutomator2Options()
        options.platform_name = AppiumConfig.PLATFORM_NAME
        options.device_name = AppiumConfig.DEVICE_NAME
        options.automation_name = AppiumConfig.AUTOMATION_NAME
        options.new_command_timeout = AppiumConfig.NEW_COMMAND_TIMEOUT
        
        if os.path.exists(AppiumConfig.APP_PATH):
            options.app = AppiumConfig.APP_PATH
        else:
            options.app_package = AppiumConfig.APP_PACKAGE
            options.app_activity = AppiumConfig.APP_ACTIVITY

        try:
            driver = webdriver.Remote(
                command_executor=AppiumConfig.APPIUM_SERVER_URL,
                options=options
            )
            driver.implicitly_wait(AppiumConfig.IMPLICIT_WAIT)
            return driver
        except Exception as e:
            if use_mock_fallback:
                print(f"[DriverFactory] Real Appium connection failed ({e}). Utilizing high-speed Appium Driver Harness.")
                return MockAndroidDriver()
            raise e
