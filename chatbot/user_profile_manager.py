import json
import os
from typing import Dict, Optional
from datetime import datetime
from config import Config

class UserProfileManager:
    """Manage user profiles for scholarship applications"""
    
    def __init__(self):
        self.profiles_dir = Config.USER_PROFILES_FOLDER
        os.makedirs(self.profiles_dir, exist_ok=True)
    
    def create_profile(self, user_id: str, profile_data: Dict) -> Dict:
        """Create a new user profile"""
        profile = {
            "user_id": user_id,
            "created_at": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat(),
            **profile_data
        }
        
        self._save_profile(user_id, profile)
        return profile
    
    def get_profile(self, user_id: str) -> Optional[Dict]:
        """Retrieve user profile"""
        profile_path = self._get_profile_path(user_id)
        
        if os.path.exists(profile_path):
            with open(profile_path, 'r') as f:
                return json.load(f)
        return None
    
    def update_profile(self, user_id: str, updates: Dict) -> Dict:
        """Update existing profile"""
        profile = self.get_profile(user_id)
        
        if not profile:
            return self.create_profile(user_id, updates)
        
        profile.update(updates)
        profile["updated_at"] = datetime.now().isoformat()
        
        self._save_profile(user_id, profile)
        return profile
    
    def delete_profile(self, user_id: str) -> bool:
        """Delete user profile"""
        profile_path = self._get_profile_path(user_id)
        
        if os.path.exists(profile_path):
            os.remove(profile_path)
            return True
        return False
    
    def list_profiles(self) -> list:
        """List all user profiles"""
        profiles = []
        
        for filename in os.listdir(self.profiles_dir):
            if filename.endswith('.json'):
                user_id = filename[:-5]  # Remove .json
                profile = self.get_profile(user_id)
                if profile:
                    profiles.append({
                        "user_id": user_id,
                        "name": profile.get("name", "Unknown"),
                        "email": profile.get("email", ""),
                        "created_at": profile.get("created_at", "")
                    })
        
        return profiles
    
    def validate_profile(self, profile: Dict) -> Dict:
        """Validate profile completeness"""
        required_fields = {
            'personal': ['name', 'email', 'phone', 'date_of_birth', 'address'],
            'educational': ['school', 'major', 'gpa', 'graduation_year'],
            'additional': ['goals', 'achievements', 'experience']
        }
        
        missing_fields = {}
        completeness = {}
        
        for category, fields in required_fields.items():
            missing = [f for f in fields if not profile.get(f)]
            missing_fields[category] = missing
            completeness[category] = (len(fields) - len(missing)) / len(fields) * 100
        
        overall_completeness = sum(completeness.values()) / len(completeness)
        
        return {
            "is_complete": overall_completeness == 100,
            "overall_completeness": round(overall_completeness, 2),
            "category_completeness": completeness,
            "missing_fields": missing_fields
        }
    
    def get_profile_template(self) -> Dict:
        """Get empty profile template"""
        return {
            # Personal Information
            "name": "",
            "first_name": "",
            "last_name": "",
            "email": "",
            "phone": "",
            "date_of_birth": "",
            "address": "",
            "city": "",
            "state": "",
            "zip": "",
            "country": "",
            "gender": "",
            "nationality": "",
            
            # Educational Information
            "school": "",
            "major": "",
            "gpa": "",
            "graduation_year": "",
            "education_level": "",
            "previous_education": [],
            
            # Essays and Statements
            "essay": "",
            "goals": "",
            "achievements": "",
            "experience": "",
            "extracurricular": "",
            "leadership": "",
            "community_service": "",
            
            # Financial Information
            "income": "",
            "financial_need": "",
            
            # References
            "references": [],
            
            # Documents
            "documents": {
                "transcript": "",
                "resume": "",
                "recommendation_letters": [],
                "essays": []
            }
        }
    
    def _save_profile(self, user_id: str, profile: Dict):
        """Save profile to file"""
        profile_path = self._get_profile_path(user_id)
        
        with open(profile_path, 'w') as f:
            json.dump(profile, f, indent=2)
    
    def _get_profile_path(self, user_id: str) -> str:
        """Get profile file path"""
        return os.path.join(self.profiles_dir, f"{user_id}.json")
