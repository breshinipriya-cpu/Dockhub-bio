import logging
import os
from datetime import datetime
from mobile_automation.config.appium_config import AppiumConfig

class AppiumLogger:
    _logger = None

    @staticmethod
    def get_logger():
        if AppiumLogger._logger is None:
            os.makedirs(AppiumConfig.LOGS_DIR, exist_ok=True)
            log_filename = os.path.join(
                AppiumConfig.LOGS_DIR,
                f"appium_execution_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
            )
            
            logger = logging.getLogger("AppiumMobileFramework")
            logger.setLevel(logging.INFO)
            
            formatter = logging.Formatter(
                '%(asctime)s - [%(levelname)s] - AppiumFramework - %(message)s'
            )
            
            file_handler = logging.FileHandler(log_filename)
            file_handler.setFormatter(formatter)
            logger.addHandler(file_handler)
            
            console_handler = logging.StreamHandler()
            console_handler.setFormatter(formatter)
            logger.addHandler(console_handler)
            
            AppiumLogger._logger = logger
            
        return AppiumLogger._logger
