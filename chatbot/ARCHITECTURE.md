# 🏗️ System Architecture

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        USER INTERFACE                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Chat Box    │  │  Quick       │  │  Profile     │      │
│  │  Interface   │  │  Actions     │  │  Manager     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      FLASK REST API                          │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │  /chat   │ │ /analyze │ │ /profile │ │ /fill    │      │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                     BUSINESS LOGIC LAYER                     │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────┐  │
│  │  Gemini AI     │  │  Web Scraper   │  │  Form Filler │  │
│  │  Client        │  │  (BS4/Selenium)│  │  (Selenium)  │  │
│  └────────────────┘  └────────────────┘  └──────────────┘  │
│  ┌────────────────┐  ┌────────────────┐                    │
│  │  Profile       │  │  Config        │                    │
│  │  Manager       │  │  Manager       │                    │
│  └────────────────┘  └────────────────┘                    │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      DATA & EXTERNAL                         │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │  User    │ │  Upload  │ │  Screen  │ │  Gemini  │      │
│  │ Profiles │ │  Files   │ │  Shots   │ │   API    │      │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## Component Interaction Flow

### 1. Chat Interaction Flow
```
User Message
    ↓
Chat Interface (JavaScript)
    ↓
POST /api/chat
    ↓
Flask Route Handler
    ↓
Gemini Client
    ↓
AI Processing (Context + History)
    ↓
Response Generation
    ↓
JSON Response
    ↓
Display in Chat
```

### 2. Scholarship Analysis Flow
```
Scholarship URL
    ↓
POST /api/analyze-scholarship
    ↓
Scholarship Scraper
    ├─→ BeautifulSoup (Static)
    └─→ Selenium (Dynamic)
    ↓
Extract: Title, Description, Eligibility, etc.
    ↓
Gemini AI Analysis
    ↓
Structured Analysis Response
    ↓
Display to User
```

### 3. Form Filling Flow
```
Application URL + User Profile
    ↓
POST /api/fill-form
    ↓
Form Filler (Selenium)
    ↓
Load Page & Detect Fields
    ↓
Match Fields to Profile
    ├─→ Personal Info
    ├─→ Educational Info
    └─→ Essays/Statements
    ↓
Fill Each Field
    ↓
Take Screenshots
    ↓
Return Success + Screenshots
```

### 4. Essay Generation Flow
```
Essay Prompt + User Profile
    ↓
POST /api/generate-essay
    ↓
Gemini Client
    ↓
Build Context:
    ├─→ User Background
    ├─→ Achievements
    ├─→ Goals
    └─→ Prompt Requirements
    ↓
AI Generation
    ↓
Formatted Essay
    ↓
Return to User
```

## Module Dependencies

```
app.py
├── config.py
├── gemini_client.py
│   └── google.generativeai
├── scholarship_scraper.py
│   ├── requests
│   ├── beautifulsoup4
│   └── selenium
├── form_filler.py
│   └── selenium
└── user_profile_manager.py
    └── json
```

## Data Models

### User Profile Schema
```json
{
  "user_id": "string",
  "created_at": "ISO8601",
  "updated_at": "ISO8601",
  "name": "string",
  "email": "string",
  "phone": "string",
  "date_of_birth": "string",
  "address": "string",
  "city": "string",
  "state": "string",
  "zip": "string",
  "country": "string",
  "school": "string",
  "major": "string",
  "gpa": "string",
  "graduation_year": "string",
  "education_level": "string",
  "goals": "text",
  "achievements": "text",
  "experience": "text",
  "documents": {
    "transcript": "path",
    "resume": "path",
    "recommendation_letters": ["paths"],
    "essays": ["paths"]
  }
}
```

### Scholarship Data Schema
```json
{
  "url": "string",
  "title": "string",
  "description": "text",
  "eligibility": ["string"],
  "deadline": "string",
  "amount": "string",
  "requirements": ["string"],
  "application_link": "string",
  "contact": {
    "email": "string",
    "phone": "string"
  }
}
```

### Form Field Schema
```json
{
  "name": "string",
  "type": "text|email|tel|date|select|textarea",
  "id": "string",
  "label": "string",
  "placeholder": "string",
  "required": "boolean",
  "options": ["string"],
  "profile_mapping": "string"
}
```

## API Endpoints Reference

### Chat & Query
- **POST /api/chat** - Interactive chat
- **POST /api/answer-query** - Specific queries

### Scholarship Operations
- **POST /api/analyze-scholarship** - Analyze URL
- **POST /api/fill-form** - Auto-fill form
- **POST /api/get-form-structure** - Extract fields

### Profile Management
- **GET /api/profile** - Retrieve profile
- **POST /api/profile** - Create profile
- **PUT /api/profile** - Update profile
- **DELETE /api/profile** - Delete profile
- **GET /api/list-profiles** - List all profiles

### Content Generation
- **POST /api/generate-essay** - Generate essay
- **POST /api/optimize-application** - Optimize tips

### Utilities
- **POST /api/upload** - Upload files
- **GET /api/screenshots/<filename>** - View screenshot
- **GET /api/health** - Health check

## Security Architecture

```
┌─────────────────────────────────────────┐
│         Security Layers                  │
├─────────────────────────────────────────┤
│  1. Environment Variables (.env)        │
│     - API Keys                          │
│     - Secret Keys                       │
├─────────────────────────────────────────┤
│  2. Input Validation                    │
│     - Type checking                     │
│     - Sanitization                      │
│     - File extension validation         │
├─────────────────────────────────────────┤
│  3. File Upload Security                │
│     - Size limits                       │
│     - Allowed extensions                │
│     - Secure filename handling          │
├─────────────────────────────────────────┤
│  4. Session Management                  │
│     - UUID-based sessions               │
│     - No sensitive data in sessions     │
├─────────────────────────────────────────┤
│  5. Error Handling                      │
│     - No stack traces to client         │
│     - Generic error messages            │
└─────────────────────────────────────────┘
```

## Scalability Considerations

### Current Design
- **Single-threaded Flask** (development)
- **In-memory sessions** (temporary)
- **File-based storage** (profiles)

### Production Recommendations
```
┌─────────────────────────────────────────┐
│  Load Balancer (Nginx)                  │
└──────────────┬──────────────────────────┘
               ↓
┌──────────────────────────────────────────┐
│  Application Servers (Gunicorn)          │
│  ├─ Worker 1                             │
│  ├─ Worker 2                             │
│  └─ Worker N                             │
└──────────────┬───────────────────────────┘
               ↓
┌──────────────────────────────────────────┐
│  Cache Layer (Redis)                     │
│  - Session storage                       │
│  - API response caching                  │
└──────────────┬───────────────────────────┘
               ↓
┌──────────────────────────────────────────┐
│  Database (PostgreSQL)                   │
│  - User profiles                         │
│  - Application history                   │
└──────────────────────────────────────────┘
```

## Performance Optimization

### Current Optimizations
1. **Headless browser mode** - Faster form filling
2. **Dual scraping modes** - Choose based on page type
3. **Session reuse** - Maintain AI context
4. **Lazy loading** - Load resources on demand

### Future Optimizations
1. **Caching layer** - Redis for frequent queries
2. **Queue system** - Celery for background tasks
3. **CDN** - Static asset delivery
4. **Database indexing** - Fast profile lookups
5. **Connection pooling** - Efficient API calls

## Deployment Architecture

```
Development:
    Flask dev server → localhost:5000

Production:
    Domain (HTTPS)
        ↓
    Nginx (Reverse Proxy)
        ↓
    Gunicorn (WSGI Server)
        ↓
    Flask Application
        ↓
    External Services (Gemini API)
```

## Monitoring & Logging

### Recommended Stack
```
Application Logs
    ↓
Logging Framework (Python logging)
    ↓
Log Aggregation (ELK Stack)
    ├─ Elasticsearch (Storage)
    ├─ Logstash (Processing)
    └─ Kibana (Visualization)
    ↓
Alerting (PagerDuty/Slack)
```

## Technology Choices Rationale

| Technology | Why Chosen |
|------------|-----------|
| **Flask** | Lightweight, flexible, easy to deploy |
| **Gemini Pro** | State-of-the-art AI, free tier available |
| **Selenium** | Industry standard for browser automation |
| **BeautifulSoup** | Fast HTML parsing for static content |
| **Tailwind CSS** | Rapid UI development, modern design |
| **JSON Storage** | Simple, no database setup required |

---

This architecture is designed for:
- ✅ Ease of development
- ✅ Maintainability
- ✅ Scalability
- ✅ Security
- ✅ Performance
