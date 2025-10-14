import google.generativeai as genai
from typing import Dict, List, Optional
import json
from config import Config

class GeminiClient:
    """Advanced Gemini AI client for scholarship assistance"""
    
    def __init__(self):
        genai.configure(api_key=Config.GEMINI_API_KEY)
        self.model = genai.GenerativeModel(Config.GEMINI_MODEL)
        self.chat_history = []
        
    def analyze_scholarship(self, scholarship_data: Dict) -> Dict:
        """Analyze scholarship requirements and provide insights"""
        prompt = f"""
        Analyze the following scholarship information and provide detailed insights:
        
        Scholarship Data:
        {json.dumps(scholarship_data, indent=2)}
        
        Please provide:
        1. Key eligibility requirements
        2. Important deadlines
        3. Required documents
        4. Application tips
        5. Success factors
        
        Format the response as JSON with these keys: eligibility, deadlines, documents, tips, success_factors
        """
        
        try:
            response = self.model.generate_content(prompt)
            return self._parse_json_response(response.text)
        except Exception as e:
            return {"error": f"Analysis failed: {str(e)}"}
    
    def generate_essay(self, prompt_text: str, user_profile: Dict, word_limit: int = 500) -> str:
        """Generate personalized scholarship essay"""
        essay_prompt = f"""
        Write a compelling scholarship essay based on the following:
        
        Essay Prompt: {prompt_text}
        
        Applicant Profile:
        - Name: {user_profile.get('name', 'N/A')}
        - Education: {user_profile.get('education', 'N/A')}
        - Achievements: {user_profile.get('achievements', 'N/A')}
        - Goals: {user_profile.get('goals', 'N/A')}
        - Experience: {user_profile.get('experience', 'N/A')}
        
        Requirements:
        - Word limit: approximately {word_limit} words
        - Be authentic and personal
        - Highlight unique qualities
        - Show passion and commitment
        - Include specific examples
        
        Write the essay now:
        """
        
        try:
            response = self.model.generate_content(essay_prompt)
            return response.text
        except Exception as e:
            return f"Essay generation failed: {str(e)}"
    
    def answer_query(self, query: str, context: Optional[Dict] = None) -> str:
        """Answer scholarship-related queries with context awareness"""
        context_str = ""
        if context:
            context_str = f"\n\nContext:\n{json.dumps(context, indent=2)}"
        
        prompt = f"""
        You are an expert scholarship advisor. Answer the following question comprehensively:
        
        Question: {query}{context_str}
        
        Provide a detailed, helpful, and accurate response. If you're unsure, suggest where to find the information.
        """
        
        try:
            response = self.model.generate_content(prompt)
            return response.text
        except Exception as e:
            return f"I apologize, but I encountered an error: {str(e)}"
    
    def extract_form_fields(self, html_content: str) -> List[Dict]:
        """Extract and categorize form fields from HTML"""
        prompt = f"""
        Analyze this HTML form and extract all input fields:
        
        {html_content[:3000]}  # Limit to avoid token overflow
        
        For each field, identify:
        1. Field name/id
        2. Field type (text, email, date, select, etc.)
        3. Label or placeholder
        4. Whether it's required
        5. Suggested mapping to user profile fields
        
        Return as JSON array with keys: name, type, label, required, profile_mapping
        """
        
        try:
            response = self.model.generate_content(prompt)
            return self._parse_json_response(response.text)
        except Exception as e:
            return []
    
    def generate_recommendation_letter(self, user_profile: Dict, scholarship_info: Dict) -> str:
        """Generate a recommendation letter draft"""
        prompt = f"""
        Generate a professional recommendation letter for a scholarship application:
        
        Student Profile:
        {json.dumps(user_profile, indent=2)}
        
        Scholarship Information:
        {json.dumps(scholarship_info, indent=2)}
        
        Write a compelling recommendation letter that:
        - Highlights the student's strengths
        - Provides specific examples
        - Aligns with scholarship values
        - Maintains professional tone
        """
        
        try:
            response = self.model.generate_content(prompt)
            return response.text
        except Exception as e:
            return f"Letter generation failed: {str(e)}"
    
    def optimize_application(self, application_data: Dict, scholarship_criteria: Dict) -> Dict:
        """Provide optimization suggestions for the application"""
        prompt = f"""
        Review this scholarship application and provide optimization suggestions:
        
        Application Data:
        {json.dumps(application_data, indent=2)}
        
        Scholarship Criteria:
        {json.dumps(scholarship_criteria, indent=2)}
        
        Provide:
        1. Strengths of the application
        2. Areas for improvement
        3. Missing information
        4. Alignment score (0-100)
        5. Specific recommendations
        
        Format as JSON with keys: strengths, improvements, missing, score, recommendations
        """
        
        try:
            response = self.model.generate_content(prompt)
            return self._parse_json_response(response.text)
        except Exception as e:
            return {"error": str(e)}
    
    def chat(self, message: str, user_profile: Optional[Dict] = None) -> str:
        """Interactive chat for scholarship assistance"""
        self.chat_history.append({"role": "user", "content": message})
        
        context = ""
        if user_profile:
            context = f"\n\nUser Profile: {json.dumps(user_profile, indent=2)}"
        
        # Build conversation history
        conversation = "\n".join([
            f"{msg['role']}: {msg['content']}" 
            for msg in self.chat_history[-10:]  # Last 10 messages
        ])
        
        prompt = f"""
        You are a helpful scholarship application assistant. Continue this conversation:
        
        {conversation}{context}
        
        Provide helpful, accurate, and friendly responses. If the user needs to apply for a scholarship,
        guide them through the process step by step.
        """
        
        try:
            response = self.model.generate_content(prompt)
            assistant_message = response.text
            self.chat_history.append({"role": "assistant", "content": assistant_message})
            return assistant_message
        except Exception as e:
            return f"I apologize, but I encountered an error: {str(e)}"
    
    def _parse_json_response(self, text: str) -> Dict:
        """Parse JSON from AI response, handling markdown code blocks"""
        try:
            # Remove markdown code blocks if present
            if "```json" in text:
                text = text.split("```json")[1].split("```")[0]
            elif "```" in text:
                text = text.split("```")[1].split("```")[0]
            
            return json.loads(text.strip())
        except json.JSONDecodeError:
            # If JSON parsing fails, return the text as-is
            return {"response": text}
    
    def reset_chat(self):
        """Reset chat history"""
        self.chat_history = []
