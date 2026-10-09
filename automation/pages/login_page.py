from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage

class LoginPage(BasePage):
    INPUT_EMAIL = (By.ID, "loginEmail")
    INPUT_PASSWORD = (By.ID, "loginPassword")
    SELECT_ROLE = (By.ID, "userRole")
    BTN_LOGIN = (By.ID, "btnLogin")
    BTN_LOGOUT = (By.ID, "btnLogout")
    MSG_BOX = (By.ID, "authMessageBox")
    USER_STATUS = (By.ID, "userStatusText")

    def login(self, email: str, password: str, role: str = "Administrator"):
        self.type_text(self.INPUT_EMAIL, email)
        self.type_text(self.INPUT_PASSWORD, password)
        # Select role
        role_el = self.find_element(self.SELECT_ROLE)
        for option in role_el.find_elements(By.TAG_NAME, "option"):
            if option.text.lower() == role.lower():
                option.click()
                break
        self.click(self.BTN_LOGIN)

    def logout(self):
        if self.is_displayed(self.BTN_LOGOUT):
            self.click(self.BTN_LOGOUT)

    def get_auth_message(self) -> str:
        return self.get_text(self.MSG_BOX)

    def get_status_text(self) -> str:
        return self.get_text(self.USER_STATUS)
