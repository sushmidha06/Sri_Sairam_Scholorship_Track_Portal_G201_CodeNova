# 🎓 AI-Powered Scholarship Application Assistant

An advanced chatbot system that automates scholarship applications using AI, web scraping, and intelligent form filling. This system can analyze scholarships, answer queries, generate essays, and automatically fill application forms without manual intervention.

## ✨ Features

### 🤖 AI-Powered Intelligence
- **Gemini AI Integration**: Advanced natural language processing for intelligent conversations
- **Context-Aware Responses**: Understands scholarship-related queries with context
- **Essay Generation**: Creates personalized scholarship essays based on user profiles
- **Application Optimization**: Analyzes and suggests improvements for applications

### 🌐 Web Scraping & Analysis
- **Automatic Scholarship Extraction**: Scrapes scholarship details from URLs
- **Dynamic Content Support**: Uses Selenium for JavaScript-heavy pages
- **Intelligent Parsing**: Extracts eligibility, deadlines, requirements, and amounts
- **Form Structure Analysis**: Identifies and categorizes form fields automatically

### 📝 Automated Form Filling
- **Smart Field Mapping**: Intelligently matches form fields to user profile data
- **Multi-Field Support**: Handles text inputs, textareas, selects, dates, and files
- **Screenshot Capture**: Takes screenshots before and after form submission
- **Headless Mode**: Runs in background for seamless automation

### 👤 User Profile Management
- **Comprehensive Profiles**: Stores personal, educational, and achievement data
- **Profile Validation**: Checks completeness and suggests missing information
- **Multiple Profiles**: Support for managing different user profiles
- **Document Management**: Handles transcripts, resumes, and recommendation letters

### 💬 Interactive Chat Interface
- **Modern UI**: Beautiful, responsive design with Tailwind CSS
- **Real-time Chat**: Instant responses with typing indicators
- **Quick Actions**: One-click access to common tasks
- **Session Management**: Maintains conversation context

## 🚀 Quick Start

### Prerequisites

- Python 3.8 or higher
- Google Chrome browser
- Gemini API key (get from [Google AI Studio](https://makersuite.google.com/app/apikey))

### Installation

1. **Clone or download the repository**
```bash
cd /home/raka/Downloads/chatbot
```

2. **Create virtual environment**
```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies**
```bash
pip install -r requirements.txt
```

4. **Configure environment variables**
```bash
cp .env.example .env
```

Edit `.env` and add your Gemini API key:
```
GEMINI_API_KEY=your_actual_api_key_here
FLASK_SECRET_KEY=your_random_secret_key
```

5. **Run the application**
```bash
python app.py
```

6. **Open your browser**
Navigate to: `http://localhost:5000`

## 📖 Usage Guide

### 1. Create Your Profile

Click the "Profile" button and fill in your information:
- **Personal Info**: Name, email, phone, address
- **Education**: School, major, GPA, graduation year
- **Additional**: Goals, achievements, experience

### 2. Analyze a Scholarship

- Click "Analyze Scholarship"
- Enter the scholarship URL
- Get AI-powered analysis of requirements and eligibility

### 3. Fill Application Forms

- Click "Fill Application"
- Enter the application form URL
- The system automatically fills fields based on your profile
- Review the screenshot to verify

### 4. Generate Essays

- Click "Generate Essay"
- Enter the essay prompt
- Specify word limit (optional)
- Get a personalized, AI-generated essay

### 5. Ask Questions

Use the chat interface to ask any scholarship-related questions:
- "What scholarships am I eligible for?"
- "How do I write a strong personal statement?"
- "What documents do I need for scholarship applications?"

## 🏗️ Architecture

```
chatbot/
├── app.py                      # Flask application & API endpoints
├── config.py                   # Configuration settings
├── gemini_client.py           # AI integration (Gemini)
├── scholarship_scraper.py     # Web scraping module
├── form_filler.py             # Automated form filling
├── user_profile_manager.py    # Profile management
├── requirements.txt           # Python dependencies
├── .env                       # Environment variables
├── templates/
│   └── index.html            # Main web interface
├── static/
│   ├── style.css             # Custom styles
│   └── app.js                # Frontend JavaScript
├── uploads/                   # Uploaded documents
├── screenshots/               # Form screenshots
├── user_profiles/             # User profile data
└── chroma_db/                # Vector database (future use)
```

## 🔌 API Endpoints

### Chat
- `POST /api/chat` - Send chat messages
- `POST /api/answer-query` - Answer specific queries

### Scholarship Operations
- `POST /api/analyze-scholarship` - Analyze scholarship URL
- `POST /api/fill-form` - Auto-fill application form
- `POST /api/get-form-structure` - Extract form fields

### Profile Management
- `GET /api/profile` - Get user profile
- `POST /api/profile` - Create profile
- `PUT /api/profile` - Update profile
- `DELETE /api/profile` - Delete profile

### Content Generation
- `POST /api/generate-essay` - Generate scholarship essay
- `POST /api/optimize-application` - Get optimization tips

### Utilities
- `POST /api/upload` - Upload documents
- `GET /api/screenshots/<filename>` - View screenshots
- `GET /api/health` - Health check

## 🔧 Advanced Configuration

### Selenium Options

Modify `config.py` to customize browser behavior:
```python
CHROME_OPTIONS = [
    '--headless',              # Run without GUI
    '--no-sandbox',            # Required for some systems
    '--disable-dev-shm-usage', # Overcome limited resource problems
    '--window-size=1920,1080', # Set window size
]
```

### AI Model Settings

Adjust AI behavior in `config.py`:
```python
GEMINI_MODEL = 'gemini-pro'
TEMPERATURE = 0.7      # Creativity (0.0-1.0)
MAX_TOKENS = 2048      # Response length
```

## 🎯 Advanced Features

### Custom Field Mappings

Edit `form_filler.py` to add custom field mappings:
```python
self.field_mappings = {
    'custom_field': ['pattern1', 'pattern2', 'pattern3'],
    # Add more mappings
}
```

### Essay Templates

Customize essay generation in `gemini_client.py`:
```python
def generate_essay(self, prompt_text, user_profile, word_limit=500):
    # Modify the prompt template
    essay_prompt = f"""
    Your custom instructions here...
    """
```

## 🛡️ Security Best Practices

1. **Never commit `.env` file** - Contains sensitive API keys
2. **Use strong SECRET_KEY** - Generate with `python -c "import secrets; print(secrets.token_hex(32))"`
3. **Validate user inputs** - All inputs are sanitized
4. **Secure file uploads** - Only allowed extensions are accepted
5. **HTTPS in production** - Use SSL certificates for production deployment

## 🐛 Troubleshooting

### Chrome Driver Issues
```bash
# Update webdriver-manager
pip install --upgrade webdriver-manager
```

### API Key Errors
- Verify your Gemini API key in `.env`
- Check API quota at Google AI Studio
- Ensure internet connection is stable

### Form Filling Not Working
- Try enabling Selenium mode (use_selenium=True)
- Check if the website blocks automation
- Verify your profile is complete

### Port Already in Use
```bash
# Change port in app.py
app.run(debug=True, host='0.0.0.0', port=5001)
```

## 📊 Performance Tips

1. **Use headless mode** for faster form filling
2. **Cache scholarship data** to reduce scraping
3. **Batch process** multiple applications
4. **Monitor API usage** to stay within limits

## 🤝 Contributing

Contributions are welcome! Areas for improvement:
- Additional scholarship websites support
- More sophisticated field mapping algorithms
- Multi-language support
- PDF form filling capabilities
- Email notification system

## 📝 License

This project is provided as-is for educational purposes.

## 🙏 Acknowledgments

- **Google Gemini AI** - For powerful language models
- **Selenium** - For web automation
- **BeautifulSoup** - For HTML parsing
- **Flask** - For web framework
- **Tailwind CSS** - For beautiful UI

## 📧 Support

For issues or questions:
1. Check the troubleshooting section
2. Review API documentation
3. Ensure all dependencies are installed correctly

## 🎉 Getting Started Checklist

- [ ] Install Python 3.8+
- [ ] Install Chrome browser
- [ ] Get Gemini API key
- [ ] Clone repository
- [ ] Install dependencies
- [ ] Configure `.env` file
- [ ] Run application
- [ ] Create user profile
- [ ] Test with a scholarship URL

---

**Happy Scholarship Hunting! 🎓✨**
