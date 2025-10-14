import requests
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
from typing import Dict, List, Optional
import time
import re
from config import Config

class ScholarshipScraper:
    """Advanced web scraper for scholarship information"""
    
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        })
    
    def scrape_scholarship_page(self, url: str, use_selenium: bool = False) -> Dict:
        """Scrape scholarship details from a URL"""
        try:
            if use_selenium:
                return self._scrape_with_selenium(url)
            else:
                return self._scrape_with_requests(url)
        except Exception as e:
            return {"error": f"Scraping failed: {str(e)}", "url": url}
    
    def _scrape_with_requests(self, url: str) -> Dict:
        """Scrape using requests and BeautifulSoup"""
        response = self.session.get(url, timeout=10)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.content, 'html.parser')
        
        # Extract scholarship information
        data = {
            "url": url,
            "title": self._extract_title(soup),
            "description": self._extract_description(soup),
            "eligibility": self._extract_eligibility(soup),
            "deadline": self._extract_deadline(soup),
            "amount": self._extract_amount(soup),
            "requirements": self._extract_requirements(soup),
            "application_link": self._extract_application_link(soup, url),
            "contact": self._extract_contact(soup),
        }
        
        return data
    
    def _scrape_with_selenium(self, url: str) -> Dict:
        """Scrape dynamic content using Selenium"""
        driver = self._get_driver()
        
        try:
            driver.get(url)
            time.sleep(3)  # Wait for dynamic content
            
            # Get page source after JavaScript execution
            soup = BeautifulSoup(driver.page_source, 'html.parser')
            
            data = {
                "url": url,
                "title": self._extract_title(soup),
                "description": self._extract_description(soup),
                "eligibility": self._extract_eligibility(soup),
                "deadline": self._extract_deadline(soup),
                "amount": self._extract_amount(soup),
                "requirements": self._extract_requirements(soup),
                "application_link": self._extract_application_link(soup, url),
                "contact": self._extract_contact(soup),
            }
            
            return data
        finally:
            driver.quit()
    
    def get_form_structure(self, url: str) -> Dict:
        """Extract form structure from application page"""
        driver = self._get_driver()
        
        try:
            driver.get(url)
            WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.TAG_NAME, "form"))
            )
            
            forms = driver.find_elements(By.TAG_NAME, "form")
            form_data = []
            
            for form in forms:
                fields = []
                
                # Find all input fields
                inputs = form.find_elements(By.TAG_NAME, "input")
                for inp in inputs:
                    field_info = {
                        "type": inp.get_attribute("type") or "text",
                        "name": inp.get_attribute("name"),
                        "id": inp.get_attribute("id"),
                        "placeholder": inp.get_attribute("placeholder"),
                        "required": inp.get_attribute("required") is not None,
                        "value": inp.get_attribute("value"),
                    }
                    fields.append(field_info)
                
                # Find all textarea fields
                textareas = form.find_elements(By.TAG_NAME, "textarea")
                for textarea in textareas:
                    field_info = {
                        "type": "textarea",
                        "name": textarea.get_attribute("name"),
                        "id": textarea.get_attribute("id"),
                        "placeholder": textarea.get_attribute("placeholder"),
                        "required": textarea.get_attribute("required") is not None,
                    }
                    fields.append(field_info)
                
                # Find all select fields
                selects = form.find_elements(By.TAG_NAME, "select")
                for select in selects:
                    options = [opt.text for opt in select.find_elements(By.TAG_NAME, "option")]
                    field_info = {
                        "type": "select",
                        "name": select.get_attribute("name"),
                        "id": select.get_attribute("id"),
                        "required": select.get_attribute("required") is not None,
                        "options": options,
                    }
                    fields.append(field_info)
                
                form_data.append({
                    "action": form.get_attribute("action"),
                    "method": form.get_attribute("method"),
                    "fields": fields,
                })
            
            return {"forms": form_data, "url": url}
        finally:
            driver.quit()
    
    def _get_driver(self) -> webdriver.Chrome:
        """Initialize Chrome WebDriver with options"""
        chrome_options = Options()
        for option in Config.CHROME_OPTIONS:
            chrome_options.add_argument(option)
        
        service = Service(ChromeDriverManager().install())
        driver = webdriver.Chrome(service=service, options=chrome_options)
        return driver
    
    def _extract_title(self, soup: BeautifulSoup) -> str:
        """Extract scholarship title"""
        # Try multiple selectors
        selectors = [
            ('h1', {}),
            ('h2', {}),
            ('title', {}),
            ('meta', {'property': 'og:title'}),
        ]
        
        for tag, attrs in selectors:
            element = soup.find(tag, attrs)
            if element:
                if tag == 'meta':
                    return element.get('content', '').strip()
                return element.get_text().strip()
        
        return "Title not found"
    
    def _extract_description(self, soup: BeautifulSoup) -> str:
        """Extract scholarship description"""
        # Try meta description first
        meta_desc = soup.find('meta', {'name': 'description'})
        if meta_desc:
            return meta_desc.get('content', '').strip()
        
        # Look for description in common containers
        desc_keywords = ['description', 'about', 'overview', 'summary']
        for keyword in desc_keywords:
            element = soup.find(['div', 'p', 'section'], class_=re.compile(keyword, re.I))
            if element:
                return element.get_text().strip()[:500]
        
        # Fallback to first paragraph
        first_p = soup.find('p')
        if first_p:
            return first_p.get_text().strip()[:500]
        
        return "Description not found"
    
    def _extract_eligibility(self, soup: BeautifulSoup) -> List[str]:
        """Extract eligibility criteria"""
        eligibility = []
        keywords = ['eligibility', 'eligible', 'requirements', 'criteria', 'who can apply']
        
        for keyword in keywords:
            section = soup.find(['div', 'section', 'ul'], class_=re.compile(keyword, re.I))
            if not section:
                section = soup.find(['h2', 'h3', 'h4'], string=re.compile(keyword, re.I))
                if section:
                    section = section.find_next(['ul', 'ol', 'div'])
            
            if section:
                items = section.find_all('li')
                if items:
                    eligibility = [item.get_text().strip() for item in items]
                else:
                    eligibility = [section.get_text().strip()]
                break
        
        return eligibility if eligibility else ["Eligibility criteria not found"]
    
    def _extract_deadline(self, soup: BeautifulSoup) -> str:
        """Extract application deadline"""
        keywords = ['deadline', 'due date', 'last date', 'apply by']
        
        for keyword in keywords:
            element = soup.find(string=re.compile(keyword, re.I))
            if element:
                # Get the parent and extract date
                parent = element.find_parent()
                if parent:
                    text = parent.get_text()
                    # Look for date patterns
                    date_pattern = r'\d{1,2}[/-]\d{1,2}[/-]\d{2,4}|\d{1,2}\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{2,4}'
                    match = re.search(date_pattern, text, re.I)
                    if match:
                        return match.group()
        
        return "Deadline not specified"
    
    def _extract_amount(self, soup: BeautifulSoup) -> str:
        """Extract scholarship amount"""
        # Look for currency patterns
        currency_pattern = r'\$\s*[\d,]+|\₹\s*[\d,]+|USD\s*[\d,]+|INR\s*[\d,]+'
        
        text = soup.get_text()
        matches = re.findall(currency_pattern, text)
        
        if matches:
            # Return the largest amount found
            amounts = [re.sub(r'[^\d]', '', m) for m in matches]
            amounts = [int(a) for a in amounts if a]
            if amounts:
                max_amount = max(amounts)
                return f"${max_amount:,}" if max_amount > 100 else "Amount not specified"
        
        return "Amount not specified"
    
    def _extract_requirements(self, soup: BeautifulSoup) -> List[str]:
        """Extract required documents/materials"""
        requirements = []
        keywords = ['required', 'documents', 'materials', 'submit', 'application materials']
        
        for keyword in keywords:
            section = soup.find(['div', 'section', 'ul'], class_=re.compile(keyword, re.I))
            if not section:
                section = soup.find(['h2', 'h3', 'h4'], string=re.compile(keyword, re.I))
                if section:
                    section = section.find_next(['ul', 'ol', 'div'])
            
            if section:
                items = section.find_all('li')
                if items:
                    requirements = [item.get_text().strip() for item in items]
                else:
                    requirements = [section.get_text().strip()]
                break
        
        return requirements if requirements else ["Requirements not specified"]
    
    def _extract_application_link(self, soup: BeautifulSoup, base_url: str) -> str:
        """Extract application form link"""
        keywords = ['apply', 'application', 'submit', 'register']
        
        for keyword in keywords:
            link = soup.find('a', string=re.compile(keyword, re.I))
            if not link:
                link = soup.find('a', class_=re.compile(keyword, re.I))
            
            if link and link.get('href'):
                href = link.get('href')
                if href.startswith('http'):
                    return href
                else:
                    # Make absolute URL
                    from urllib.parse import urljoin
                    return urljoin(base_url, href)
        
        return base_url
    
    def _extract_contact(self, soup: BeautifulSoup) -> Dict:
        """Extract contact information"""
        contact = {}
        
        # Extract email
        email_pattern = r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
        emails = re.findall(email_pattern, soup.get_text())
        if emails:
            contact['email'] = emails[0]
        
        # Extract phone
        phone_pattern = r'\+?\d{1,3}[-.\s]?\(?\d{1,4}\)?[-.\s]?\d{1,4}[-.\s]?\d{1,9}'
        phones = re.findall(phone_pattern, soup.get_text())
        if phones:
            contact['phone'] = phones[0]
        
        return contact if contact else {"contact": "Not specified"}
