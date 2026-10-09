from mobile_automation.pages.base_page import BasePage

class MobileLoginPage(BasePage):
    EMAIL_FIELD = "email_field"
    PASSWORD_FIELD = "password_field"
    LOGIN_BTN = "login_button"
    SIGNUP_LINK = "signup_link"

    def login(self, email: str, password: str):
        self.type_text("id", self.EMAIL_FIELD, email)
        self.type_text("id", self.PASSWORD_FIELD, password)
        self.click("id", self.LOGIN_BTN)

class MobileDashboardPage(BasePage):
    SEARCH_BAR = "search_bar"
    SEARCH_BTN = "search_btn"
    HISTORY_TAB = "history_tab"
    SAVED_TAB = "saved_tab"

    def search_protein(self, query: str):
        self.type_text("id", self.SEARCH_BAR, query)
        self.click("id", self.SEARCH_BTN)
