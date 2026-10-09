from mobile_automation.utils.appium_logger import AppiumLogger

class BasePage:
    def __init__(self, driver):
        self.driver = driver
        self.logger = AppiumLogger.get_logger()

    def find_element(self, by, value):
        return self.driver.find_element(by, value)

    def click(self, by, value):
        element = self.find_element(by, value)
        element.click()

    def type_text(self, by, value, text: str):
        element = self.find_element(by, value)
        element.clear()
        element.send_keys(text)

    def get_text(self, by, value) -> str:
        element = self.find_element(by, value)
        return element.text

    def is_displayed(self, by, value) -> bool:
        try:
            return self.find_element(by, value).is_displayed()
        except Exception:
            return False
