from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage

class AlertsPage(BasePage):
    INCIDENT_LIST = (By.ID, "incidentList")
    RESOLVE_BUTTONS = (By.CSS_SELECTOR, "#incidentList button.btn-resolve")

    def get_incident_count(self) -> int:
        list_el = self.find_element(self.INCIDENT_LIST)
        items = list_el.find_elements(By.TAG_NAME, "li")
        if len(items) == 1 and "empty-msg" in items[0].get_attribute("class"):
            return 0
        return len(items)

    def resolve_first_incident(self):
        buttons = self.driver.find_elements(*self.RESOLVE_BUTTONS)
        if buttons:
            buttons[0].click()
