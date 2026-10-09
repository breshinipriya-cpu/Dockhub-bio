from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage

class DashboardPage(BasePage):
    NAV_DASHBOARD = (By.ID, "navDashboard")
    NAV_AUTH = (By.ID, "navAuth")
    NAV_INCIDENT = (By.ID, "navIncident")
    NAV_ALERTS = (By.ID, "navAlerts")
    NAV_UPLOAD = (By.ID, "navUpload")
    NAV_REPORTS = (By.ID, "navReports")

    TOTAL_INCIDENTS = (By.ID, "totalIncidents")
    CRITICAL_ALERTS = (By.ID, "criticalAlerts")
    RESOLVED_INCIDENTS = (By.ID, "resolvedIncidents")

    def navigate_to_section(self, section_name: str):
        section_map = {
            "dashboard": self.NAV_DASHBOARD,
            "auth": self.NAV_AUTH,
            "incident": self.NAV_INCIDENT,
            "alerts": self.NAV_ALERTS,
            "upload": self.NAV_UPLOAD,
            "reports": self.NAV_REPORTS,
        }
        locator = section_map.get(section_name.lower())
        if locator:
            self.click(locator)

    def get_total_incidents(self) -> str:
        return self.get_text(self.TOTAL_INCIDENTS)

    def get_critical_alerts(self) -> str:
        return self.get_text(self.CRITICAL_ALERTS)

    def get_resolved_incidents(self) -> str:
        return self.get_text(self.RESOLVED_INCIDENTS)
