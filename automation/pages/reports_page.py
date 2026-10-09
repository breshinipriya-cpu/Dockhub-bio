from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage

class ReportsPage(BasePage):
    BTN_DOWNLOAD = (By.ID, "btnDownloadReport")
    INPUT_FILE = (By.ID, "evidenceFile")
    BTN_UPLOAD = (By.ID, "btnUpload")
    UPLOAD_STATUS = (By.ID, "uploadStatus")

    def click_download_report(self):
        self.click(self.BTN_DOWNLOAD)

    def upload_file(self, file_path: str):
        file_input = self.find_element(self.INPUT_FILE)
        file_input.send_keys(file_path)
        self.click(self.BTN_UPLOAD)

    def get_upload_status(self) -> str:
        return self.get_text(self.UPLOAD_STATUS)
