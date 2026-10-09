from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage

class IncidentPage(BasePage):
    INPUT_TITLE = (By.ID, "title")
    INPUT_DESC = (By.ID, "description")
    SELECT_SEVERITY = (By.ID, "severity")
    BTN_SUBMIT = (By.ID, "btnSubmitIncident")
    NOTICE_BOX = (By.ID, "incidentFormNotice")

    def submit_incident(self, title: str, description: str, severity: str = "Low"):
        self.type_text(self.INPUT_TITLE, title)
        self.type_text(self.INPUT_DESC, description)
        
        sev_el = self.find_element(self.SELECT_SEVERITY)
        for option in sev_el.find_elements(By.TAG_NAME, "option"):
            if option.text.lower() == severity.lower():
                option.click()
                break
        self.click(self.BTN_SUBMIT)

    def get_notice_text(self) -> str:
        return self.get_text(self.NOTICE_BOX)
