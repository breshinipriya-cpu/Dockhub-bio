import logging
import os
from datetime import datetime
from automation.config.config import Config

class LoggerUtility:
    _logger = None

    @staticmethod
    def get_logger():
        if LoggerUtility._logger is None:
            os.makedirs(Config.LOGS_DIR, exist_ok=True)
            log_filename = os.path.join(
                Config.LOGS_DIR,
                f"execution_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
            )
            
            logger = logging.getLogger("AutomationFramework")
            logger.setLevel(logging.INFO)
            
            # Formatter
            formatter = logging.Formatter(
                '%(asctime)s - [%(levelname)s] - %(name)s - %(message)s'
            )
            
            # File Handler
            file_handler = logging.FileHandler(log_filename)
            file_handler.setFormatter(formatter)
            logger.addHandler(file_handler)
            
            # Console Handler
            console_handler = logging.StreamHandler()
            console_handler.setFormatter(formatter)
            logger.addHandler(console_handler)
            
            LoggerUtility._logger = logger
            
        return LoggerUtility._logger
