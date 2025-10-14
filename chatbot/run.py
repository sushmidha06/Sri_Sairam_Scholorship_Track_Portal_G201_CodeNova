#!/usr/bin/env python3
"""
Convenience script to run the Scholarship Application Assistant
"""

import os
import sys

def check_requirements():
    """Check if all requirements are met"""
    errors = []
    
    # Check Python version
    if sys.version_info < (3, 8):
        errors.append("Python 3.8 or higher is required")
    
    # Check if .env exists
    if not os.path.exists('.env'):
        errors.append(".env file not found. Copy .env.example to .env and configure it")
    
    # Check if GEMINI_API_KEY is set
    from dotenv import load_dotenv
    load_dotenv()
    
    if not os.getenv('GEMINI_API_KEY'):
        errors.append("GEMINI_API_KEY not set in .env file")
    
    return errors

def main():
    """Main entry point"""
    print("🎓 Scholarship Application Assistant")
    print("=" * 50)
    
    # Check requirements
    errors = check_requirements()
    
    if errors:
        print("\n❌ Configuration errors found:")
        for error in errors:
            print(f"  - {error}")
        print("\nPlease fix these issues and try again.")
        sys.exit(1)
    
    print("✅ All checks passed!")
    print("\n🚀 Starting application...")
    print("📍 Server will be available at: http://localhost:5000")
    print("\n💡 Press Ctrl+C to stop the server\n")
    
    # Import and run the app
    from app import app
    app.run(debug=True, host='0.0.0.0', port=5000)

if __name__ == '__main__':
    main()
