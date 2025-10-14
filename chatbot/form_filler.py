from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait, Select
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.keys import Keys
from webdriver_manager.chrome import ChromeDriverManager
from typing import Dict, List, Optional
import time
import os
from datetime import datetime
from config import Config

class FormFiller:
    """Intelligent automated form filling system"""
    
    def __init__(self, headless: bool = True):
        self.headless = headless
        self.driver = None
        self.field_mappings = self._create_field_mappings()
    
    def _create_field_mappings(self) -> Dict:
        """Create intelligent field mappings"""
        return {
            # Personal Information
            'name': ['name', 'full_name', 'fullname', 'applicant_name', 'student_name', 'your_name'],
            'first_name': ['first_name', 'firstname', 'fname', 'given_name'],
            'last_name': ['last_name', 'lastname', 'lname', 'surname', 'family_name'],
            'email': ['email', 'email_address', 'e-mail', 'mail', 'contact_email'],
            'phone': ['phone', 'telephone', 'mobile', 'contact_number', 'phone_number', 'tel'],
            'date_of_birth': ['dob', 'date_of_birth', 'birth_date', 'birthdate', 'birthday'],
            'address': ['address', 'street_address', 'home_address', 'residential_address'],
            'city': ['city', 'town', 'municipality'],
            'state': ['state', 'province', 'region'],
            'zip': ['zip', 'zipcode', 'postal_code', 'postcode', 'pincode'],
            'country': ['country', 'nation', 'nationality'],
            
            # Educational Information
            'school': ['school', 'university', 'college', 'institution', 'school_name'],
            'major': ['major', 'field_of_study', 'degree', 'program', 'course'],
            'gpa': ['gpa', 'grade', 'cgpa', 'average', 'grade_point'],
            'graduation_year': ['graduation_year', 'grad_year', 'expected_graduation', 'year_of_graduation'],
            'education_level': ['education_level', 'degree_level', 'qualification'],
            
            # Essay/Statement
            'essay': ['essay', 'statement', 'personal_statement', 'motivation', 'why_apply'],
            'goals': ['goals', 'career_goals', 'future_plans', 'objectives'],
            'achievements': ['achievements', 'accomplishments', 'awards', 'honors'],
            'experience': ['experience', 'work_experience', 'activities', 'extracurricular'],
            
            # Financial
            'income': ['income', 'family_income', 'annual_income', 'household_income'],
            'financial_need': ['financial_need', 'need', 'why_need_scholarship'],
        }
    
    def initialize_driver(self):
        """Initialize Chrome WebDriver"""
        chrome_options = Options()
        if self.headless:
            for option in Config.CHROME_OPTIONS:
                chrome_options.add_argument(option)
        else:
            chrome_options.add_argument('--start-maximized')
        
        service = Service(ChromeDriverManager().install())
        self.driver = webdriver.Chrome(service=service, options=chrome_options)
    
    def fill_form(self, url: str, user_profile: Dict, screenshot: bool = True) -> Dict:
        """Automatically fill scholarship application form"""
        if not self.driver:
            self.initialize_driver()
        
        try:
            self.driver.get(url)
            WebDriverWait(self.driver, 10).until(
                EC.presence_of_element_located((By.TAG_NAME, "form"))
            )
            
            # Find all forms on the page
            forms = self.driver.find_elements(By.TAG_NAME, "form")
            filled_fields = []
            
            for form_index, form in enumerate(forms):
                # Find all input fields
                inputs = form.find_elements(By.TAG_NAME, "input")
                for inp in inputs:
                    field_filled = self._fill_input_field(inp, user_profile)
                    if field_filled:
                        filled_fields.append(field_filled)
                
                # Find all textarea fields
                textareas = form.find_elements(By.TAG_NAME, "textarea")
                for textarea in textareas:
                    field_filled = self._fill_textarea_field(textarea, user_profile)
                    if field_filled:
                        filled_fields.append(field_filled)
                
                # Find all select fields
                selects = form.find_elements(By.TAG_NAME, "select")
                for select_elem in selects:
                    field_filled = self._fill_select_field(select_elem, user_profile)
                    if field_filled:
                        filled_fields.append(field_filled)
            
            # Take screenshot if requested
            screenshot_path = None
            if screenshot:
                screenshot_path = self._take_screenshot()
            
            return {
                "success": True,
                "url": url,
                "filled_fields": filled_fields,
                "screenshot": screenshot_path,
                "message": f"Successfully filled {len(filled_fields)} fields"
            }
            
        except Exception as e:
            return {
                "success": False,
                "url": url,
                "error": str(e),
                "message": "Form filling failed"
            }
    
    def _fill_input_field(self, element, user_profile: Dict) -> Optional[Dict]:
        """Fill an input field based on its attributes"""
        try:
            field_type = element.get_attribute("type") or "text"
            field_name = element.get_attribute("name") or element.get_attribute("id") or ""
            field_name_lower = field_name.lower()
            
            # Skip hidden, submit, and button fields
            if field_type in ['hidden', 'submit', 'button', 'reset']:
                return None
            
            # Skip if field is already filled
            if element.get_attribute("value"):
                return None
            
            # Find matching profile field
            value = None
            matched_key = None
            
            for profile_key, field_patterns in self.field_mappings.items():
                for pattern in field_patterns:
                    if pattern in field_name_lower:
                        value = user_profile.get(profile_key)
                        matched_key = profile_key
                        break
                if value:
                    break
            
            # Handle special field types
            if field_type == "email" and not value:
                value = user_profile.get('email')
                matched_key = 'email'
            elif field_type == "tel" and not value:
                value = user_profile.get('phone')
                matched_key = 'phone'
            elif field_type == "date" and not value:
                value = user_profile.get('date_of_birth')
                matched_key = 'date_of_birth'
            elif field_type == "number" and 'gpa' in field_name_lower:
                value = user_profile.get('gpa')
                matched_key = 'gpa'
            
            # Fill the field if value found
            if value:
                element.clear()
                element.send_keys(str(value))
                return {
                    "field_name": field_name,
                    "field_type": field_type,
                    "profile_key": matched_key,
                    "value_filled": True
                }
            
            return None
            
        except Exception as e:
            return None
    
    def _fill_textarea_field(self, element, user_profile: Dict) -> Optional[Dict]:
        """Fill a textarea field"""
        try:
            field_name = element.get_attribute("name") or element.get_attribute("id") or ""
            field_name_lower = field_name.lower()
            
            # Skip if already filled
            if element.get_attribute("value") or element.text:
                return None
            
            # Find matching content
            value = None
            matched_key = None
            
            for profile_key, field_patterns in self.field_mappings.items():
                for pattern in field_patterns:
                    if pattern in field_name_lower:
                        value = user_profile.get(profile_key)
                        matched_key = profile_key
                        break
                if value:
                    break
            
            # Fill the field
            if value:
                element.clear()
                element.send_keys(str(value))
                return {
                    "field_name": field_name,
                    "field_type": "textarea",
                    "profile_key": matched_key,
                    "value_filled": True
                }
            
            return None
            
        except Exception as e:
            return None
    
    def _fill_select_field(self, element, user_profile: Dict) -> Optional[Dict]:
        """Fill a select dropdown field"""
        try:
            field_name = element.get_attribute("name") or element.get_attribute("id") or ""
            field_name_lower = field_name.lower()
            
            # Find matching value
            value = None
            matched_key = None
            
            for profile_key, field_patterns in self.field_mappings.items():
                for pattern in field_patterns:
                    if pattern in field_name_lower:
                        value = user_profile.get(profile_key)
                        matched_key = profile_key
                        break
                if value:
                    break
            
            if value:
                select = Select(element)
                
                # Try to select by visible text
                try:
                    select.select_by_visible_text(str(value))
                    return {
                        "field_name": field_name,
                        "field_type": "select",
                        "profile_key": matched_key,
                        "value_filled": True
                    }
                except:
                    # Try to select by value
                    try:
                        select.select_by_value(str(value))
                        return {
                            "field_name": field_name,
                            "field_type": "select",
                            "profile_key": matched_key,
                            "value_filled": True
                        }
                    except:
                        pass
            
            return None
            
        except Exception as e:
            return None
    
    def upload_file(self, file_input_selector: str, file_path: str) -> bool:
        """Upload a file to a form"""
        try:
            file_input = self.driver.find_element(By.CSS_SELECTOR, file_input_selector)
            file_input.send_keys(os.path.abspath(file_path))
            return True
        except Exception as e:
            return False
    
    def submit_form(self, submit_button_selector: Optional[str] = None) -> Dict:
        """Submit the form"""
        try:
            if submit_button_selector:
                submit_button = self.driver.find_element(By.CSS_SELECTOR, submit_button_selector)
            else:
                # Find submit button automatically
                submit_button = self.driver.find_element(By.CSS_SELECTOR, "input[type='submit'], button[type='submit']")
            
            # Take screenshot before submission
            screenshot_before = self._take_screenshot("before_submit")
            
            submit_button.click()
            time.sleep(3)  # Wait for submission
            
            # Take screenshot after submission
            screenshot_after = self._take_screenshot("after_submit")
            
            return {
                "success": True,
                "screenshot_before": screenshot_before,
                "screenshot_after": screenshot_after,
                "message": "Form submitted successfully"
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "message": "Form submission failed"
            }
    
    def _take_screenshot(self, suffix: str = "") -> str:
        """Take a screenshot of the current page"""
        try:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"screenshot_{timestamp}_{suffix}.png" if suffix else f"screenshot_{timestamp}.png"
            filepath = os.path.join(Config.SCREENSHOTS_FOLDER, filename)
            
            self.driver.save_screenshot(filepath)
            return filepath
        except Exception as e:
            return None
    
    def get_current_url(self) -> str:
        """Get current page URL"""
        return self.driver.current_url if self.driver else None
    
    def get_page_source(self) -> str:
        """Get current page HTML source"""
        return self.driver.page_source if self.driver else None
    
    def close(self):
        """Close the browser"""
        if self.driver:
            self.driver.quit()
            self.driver = None
    
    def __enter__(self):
        """Context manager entry"""
        self.initialize_driver()
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit"""
        self.close()
