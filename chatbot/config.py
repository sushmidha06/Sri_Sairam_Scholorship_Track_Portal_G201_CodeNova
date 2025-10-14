import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    """Application configuration"""
    
    # Flask settings
    SECRET_KEY = os.getenv('FLASK_SECRET_KEY', 'dev-secret-key-change-in-production')
    FLASK_ENV = os.getenv('FLASK_ENV', 'development')
    
    # API Keys
    GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
    
    # File upload settings
    UPLOAD_FOLDER = os.getenv('UPLOAD_FOLDER', 'uploads')
    MAX_CONTENT_LENGTH = int(os.getenv('MAX_CONTENT_LENGTH', 16 * 1024 * 1024))  # 16MB
    ALLOWED_EXTENSIONS = {'pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'}
    
    # Directories
    SCREENSHOTS_FOLDER = 'screenshots'
    USER_PROFILES_FOLDER = 'user_profiles'
    CHROMA_DB_FOLDER = 'chroma_db'
    
    # Selenium settings
    CHROME_OPTIONS = [
        '--headless',
        '--no-sandbox',
        '--disable-dev-shm-usage',
        '--disable-gpu',
        '--window-size=1920,1080',
        '--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    ]
    
    # AI Model settings
    GEMINI_MODEL = 'gemini-pro'  # Compatible with older API version
    TEMPERATURE = 0.7
    MAX_TOKENS = 2048
    
    @staticmethod
    def init_app():
        """Initialize application directories"""
        for folder in [Config.UPLOAD_FOLDER, Config.SCREENSHOTS_FOLDER, 
                      Config.USER_PROFILES_FOLDER, Config.CHROMA_DB_FOLDER]:
            os.makedirs(folder, exist_ok=True)
