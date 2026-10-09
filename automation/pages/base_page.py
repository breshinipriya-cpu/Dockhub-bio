from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from automation.config.config import Config
from automation.utils.logger_utility import LoggerUtility

class BasePage:
    def __init__(self, driver):
        self.driver = driver
        self.wait = WebDriverWait(driver, Config.EXPLICIT_WAIT)
        self.logger = LoggerUtility.get_logger()

    def open_url(self, url: str = None):
        target = url or Config.BASE_URL
        self.logger.info(f"Navigating to URL: {target}")
        self.driver.get(target)

    def find_element(self, locator):
        return self.wait.until(EC.presence_of_element_located(locator))

    def find_clickable(self, locator):
        return self.wait.until(EC.element_to_be_clickable(locator))

    def click(self, locator):
        element = self.find_clickable(locator)
        element.click()

    def type_text(self, locator, text: str):
        element = self.find_element(locator)
        element.clear()
        element.send_keys(text)

    def get_text(self, locator) -> str:
        element = self.find_element(locator)
        return element.text

    def is_displayed(self, locator) -> bool:
        try:
            return self.find_element(locator).is_displayed()
        except Exception:
            return False

    def get_page_title(self) -> str:
        return self.driver.title
