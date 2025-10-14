"""
Example usage of the Scholarship Application Assistant API
"""

import requests
import json

BASE_URL = "http://localhost:5000/api"

def test_chat():
    """Test the chat endpoint"""
    print("Testing chat...")
    response = requests.post(f"{BASE_URL}/chat", json={
        "message": "What are the best scholarships for computer science students?",
        "user_id": "test_user"
    })
    print(response.json())

def test_analyze_scholarship():
    """Test scholarship analysis"""
    print("\nTesting scholarship analysis...")
    response = requests.post(f"{BASE_URL}/analyze-scholarship", json={
        "url": "https://example.com/scholarship",
        "use_selenium": False
    })
    print(response.json())

def test_create_profile():
    """Test profile creation"""
    print("\nTesting profile creation...")
    profile_data = {
        "name": "John Doe",
        "email": "john@example.com",
        "phone": "123-456-7890",
        "school": "Example University",
        "major": "Computer Science",
        "gpa": "3.8",
        "goals": "To become a software engineer and contribute to open source",
        "achievements": "Dean's List, Hackathon Winner",
        "experience": "Intern at Tech Company, President of CS Club"
    }
    
    response = requests.post(f"{BASE_URL}/profile?user_id=test_user", json=profile_data)
    print(response.json())

def test_get_profile():
    """Test profile retrieval"""
    print("\nTesting profile retrieval...")
    response = requests.get(f"{BASE_URL}/profile?user_id=test_user")
    print(response.json())

def test_generate_essay():
    """Test essay generation"""
    print("\nTesting essay generation...")
    response = requests.post(f"{BASE_URL}/generate-essay", json={
        "prompt": "Why do you deserve this scholarship?",
        "user_id": "test_user",
        "word_limit": 300
    })
    print(response.json())

def test_answer_query():
    """Test query answering"""
    print("\nTesting query answering...")
    response = requests.post(f"{BASE_URL}/answer-query", json={
        "query": "What documents do I need for scholarship applications?",
        "context": {"scholarship_type": "undergraduate"}
    })
    print(response.json())

def test_health():
    """Test health check"""
    print("\nTesting health check...")
    response = requests.get(f"{BASE_URL}/health")
    print(response.json())

if __name__ == "__main__":
    print("🎓 Scholarship Application Assistant - API Examples\n")
    print("Make sure the Flask app is running on http://localhost:5000\n")
    
    try:
        # Test health first
        test_health()
        
        # Test profile operations
        test_create_profile()
        test_get_profile()
        
        # Test AI features
        test_chat()
        test_answer_query()
        test_generate_essay()
        
        # Note: Uncomment to test scholarship analysis (requires valid URL)
        # test_analyze_scholarship()
        
        print("\n✅ All tests completed!")
        
    except requests.exceptions.ConnectionError:
        print("❌ Error: Could not connect to the server.")
        print("Make sure the Flask app is running: python app.py")
    except Exception as e:
        print(f"❌ Error: {e}")
