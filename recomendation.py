import json
import requests
import numpy as np
from scipy.spatial.distance import cosine
import time
import os

API_KEY = "AIzaSyBGNNzCNvl5tSIxVc0RHPEWt7A7qT4VL3s" 
EMBEDDING_MODEL = "gemini-embedding-001"
API_URL = f"https://generativelanguage.googleapis.com/v1beta/models/{EMBEDDING_MODEL}:embedContent?key={API_KEY}"

def get_scholarship_data():
    """
    Simulates loading data from your database, where complextext criteria exist.
    We create one text string for the AI to embed for each scholarship.
    """
    return [
        {
            "id": "SCH_001",
            "name": "Rural Technology Innovator Grant (Maharashtra/Karnataka)",
            "purpose": "Higher Education",
            "text_to_embed": "Grant for B.Tech or M.Sc in Computer Science or IT. Must be from a rural district in Maharashtra or Karnataka, and income must be below ₹3 Lakh.",
            "mock_vector": None 
        },
        {
            "id": "SCH_002",
            "name": "Arts & Literature Merit Award",
            "purpose": "Cultural/Arts Education",
            "text_to_embed": "Award for students enrolled in arts, humanities, or language courses. Portfolio required. NOT for engineering or science students.",
            "mock_vector": None
        },
        {
            "id": "SCH_003",
            "name": "National STEM Women's Fund",
            "purpose": "Higher Education",
            "text_to_embed": "Scholarship for female students pursuing STEM fields (Science, Technology, Engineering, Mathematics). Must maintain a high academic record.",
            "mock_vector": [0.2, 0.8, 0.1, 0.8, 0.9]
        }
    ]

def get_user_embedding(user_text):
    """
    Calls the Gemini API to convert the user's profile text into a vector embedding.
    """
    payload = {
        "content": {"parts": [{"text": user_text}]},
        "taskType": "RETRIEVAL_DOCUMENT", 
        "title": "User Profile for Scholarship Matching"
    }
    
    max_retries = 3
    for attempt in range(max_retries):
        try:
            print(f"--- Generating user embedding (Attempt {attempt + 1})... ---")
            response = requests.post(API_URL, json=payload, headers={'Content-Type': 'application/json'})
            response.raise_for_status()
            
            result = response.json()
            if result.get('embedding') and result['embedding'].get('values'):
                return np.array(result['embedding']['values'])
            
        except requests.exceptions.RequestException as e:
            print(f"Request failed: {e}")
            if attempt < max_retries - 1:
                wait_time = 2 ** attempt
                time.sleep(wait_time)
            else:
                print("Max retries reached. Failed to get embedding.")
                return None
    return None

def calculate_similarity(vector_a, vector_b):
    """Calculates the Cosine Similarity between two vectors. Higher score is better match."""
    # Cosine distance is 1 - Cosine similarity. We return 1 - distance to get similarity.
    return 1 - cosine(vector_a, vector_b)

def find_semantic_matches(user_profile, all_scholarships, user_vector, threshold=0.6):
    """
    Matches the user's profile vector against pre-calculated scholarship vectors.
    (MOCKING PRE-CALCULATED SCHOLARSHIP VECTORS)
    """
    results = []
    mock_vectors = {
        "SCH_001": [0.1, 0.9, 0.2, 0.5, 0.3],  
        "SCH_002": [0.8, 0.1, 0.9, 0.2, 0.1], 
        "SCH_003": [0.2, 0.8, 0.1, 0.8, 0.9],  
    }
    mock_user_vector = np.array([0.15, 0.85, 0.15, 0.6, 0.8])
    
    for sch in all_scholarships:
        sch_id = sch["id"]
        
        sch_vector = mock_vectors.get(sch_id, np.zeros(5)) 
        
        similarity = calculate_similarity(mock_user_vector, sch_vector)
        
        is_eligible = similarity >= threshold
        
        if is_eligible:
            rationale = f"Match Found! Score: {similarity:.2f}. The profile's core fields (STEM, Female) align strongly with this scheme's requirements."
        else:
            rationale = f"Score: {similarity:.2f}. Match is weak. Profile does not align with the scheme's core focus (e.g., Arts, specific location)."

        results.append({
            "id": sch_id,
            "name": sch["name"],
            "status": "YES" if is_eligible else "NO",
            "similarity_score": round(similarity, 3),
            "rationale": rationale
        })
        
    return results


if __name__ == '__main__':

    student_profile = {
        "name": "Priya Sharma",
        "course": "B.Tech in Computer Science and Engineering",
        "location_type": "Rural, Maharashtra",
        "gender": "Female",
        "academic_score": "GPA 3.8/4.0",
        "income": "Below 3 Lakh INR"
    }
    
    user_text_input = f"User is {student_profile['name']}, a {student_profile['gender']} student studying {student_profile['course']} from a {student_profile['location_type']} area with a {student_profile['academic_score']} and income {student_profile['income']}."
    
    scholarships = get_scholarship_data()
    
    print("--- Running Level 2: Semantic Matching Engine ---")
    print("-" * 60)
    print("USER PROFILE TEXT:\n", user_text_input)
    print("-" * 60)
    
    recommendation_results = find_semantic_matches(student_profile, scholarships, user_vector=None, threshold=0.7)

    if recommendation_results:
        print("\n--- Final Semantic Eligibility Report (Threshold: 0.7) ---")
        for result in recommendation_results:
            
            eligibility_status = result['status']
            display_color = '\033[92m' if eligibility_status == 'YES' else '\033[91m'
            reset_color = '\033[0m'

            print(f"Scholarship: {result['name']}")
            print(f"Score: {result['similarity_score']}")
            print(f"Status: {display_color}{eligibility_status}{reset_color}")
            print(f"Reason: {result['rationale']}")
            print("-" * 50)
    else:
        print("\nCould not generate semantic match report.")
