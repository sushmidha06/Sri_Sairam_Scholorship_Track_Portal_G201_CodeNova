# 🚀 Quick Start Guide

## Setup in 5 Minutes

### Step 1: Get Your API Key
1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the API key

### Step 2: Run Setup Script
```bash
cd /home/raka/Downloads/chatbot
./setup.sh
```

### Step 3: Configure API Key
```bash
nano .env
```
Add your API key:
```
GEMINI_API_KEY=your_actual_api_key_here
```
Save and exit (Ctrl+X, Y, Enter)

### Step 4: Start the Application
```bash
source venv/bin/activate
python app.py
```

### Step 5: Open in Browser
Navigate to: **http://localhost:5000**

## 🎯 First Steps

1. **Create Your Profile**
   - Click "Profile" button
   - Fill in your information
   - Click "Save Profile"

2. **Try the Chat**
   - Type: "What scholarships are available for computer science students?"
   - Get AI-powered responses

3. **Analyze a Scholarship**
   - Click "Analyze Scholarship"
   - Enter a scholarship URL
   - Get detailed analysis

4. **Generate an Essay**
   - Click "Generate Essay"
   - Enter the essay prompt
   - Get a personalized essay

## 📝 Example Scholarship URLs to Test

- https://www.scholarships.com/
- https://www.fastweb.com/
- https://www.cappex.com/scholarships

## ⚡ Advanced Features

### Automatic Form Filling
```bash
# Use the chat interface
"Fill the application form at [URL]"
```

### Essay Generation
```bash
# Ask in chat
"Generate a 500-word essay about why I deserve this scholarship"
```

### Query Answering
```bash
# Ask anything
"What documents do I need?"
"How do I write a strong personal statement?"
"What are the eligibility requirements?"
```

## 🛠️ Troubleshooting

**Port already in use?**
```bash
# Kill existing process
lsof -ti:5000 | xargs kill -9
```

**Chrome driver issues?**
```bash
pip install --upgrade webdriver-manager
```

**API key not working?**
- Check for extra spaces in .env file
- Verify key is active in Google AI Studio
- Restart the application

## 📞 Need Help?

Check the full README.md for detailed documentation!
