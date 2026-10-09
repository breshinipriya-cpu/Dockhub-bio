import os

class AppiumConfig:
    # Appium Server URL
    APPIUM_SERVER_URL = os.getenv("APPIUM_SERVER_URL", "http://localhost:4723")
    
    # Device & Platform Capabilities
    PLATFORM_NAME = os.getenv("MOBILE_PLATFORM_NAME", "Android")
    PLATFORM_VERSION = os.getenv("MOBILE_PLATFORM_VERSION", "13.0")
    DEVICE_NAME = os.getenv("MOBILE_DEVICE_NAME", "Android_Emulator")
    AUTOMATION_NAME = os.getenv("MOBILE_AUTOMATION_NAME", "UiAutomator2")
    
    # App Path (Default to built APK in dockhub_bio)
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    DEFAULT_APK = os.path.join(BASE_DIR, "dockhub_bio", "build", "app", "outputs", "flutter-apk", "app-debug.apk")
    APP_PATH = os.getenv("MOBILE_APP_PATH", DEFAULT_APK)
    
    APP_PACKAGE = os.getenv("MOBILE_APP_PACKAGE", "bio.dockhub.dockhub_bio")
    APP_ACTIVITY = os.getenv("MOBILE_APP_ACTIVITY", ".MainActivity")
    
    # Timeouts & Retries
    IMPLICIT_WAIT = int(os.getenv("MOBILE_IMPLICIT_WAIT", "10"))
    EXPLICIT_WAIT = int(os.getenv("MOBILE_EXPLICIT_WAIT", "15"))
    NEW_COMMAND_TIMEOUT = int(os.getenv("MOBILE_COMMAND_TIMEOUT", "300"))
    
    # Directories
    REPORTS_DIR = os.path.join(BASE_DIR, "Test Results")
    SCREENSHOTS_DIR = os.path.join(REPORTS_DIR, "Screenshots")
    LOGS_DIR = os.path.join(REPORTS_DIR, "Logs")
