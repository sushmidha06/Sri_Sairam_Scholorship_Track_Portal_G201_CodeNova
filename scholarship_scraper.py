import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from bs4 import BeautifulSoup
import json

def scrape_scholarships(site_url, selectors):
    """
    Generic scraper for scholarship sites.
    site_url: The URL to scrape.
    selectors: Dict with keys 'container', 'name', 'description', etc.
    IMPORTANT: Ensure compliance with the site's ToS. Use responsibly.
    """
    options = Options()
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    
    driver = webdriver.Chrome(options=options)
    
    scholarships = []
    try:
        print(f"Starting scrape from {site_url}...")
        driver.get(site_url)
        
        # Wait for content to load
        WebDriverWait(driver, 15).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, selectors['container']))
        )
        
        soup = BeautifulSoup(driver.page_source, 'html.parser')
        
        for item in soup.find_all("div", class_=selectors.get('item_class', selectors['container'])):
            name = "Unknown"
            if 'name' in selectors:
                name_elem = item.find(selectors['name'])
                name = name_elem.get_text(strip=True) if name_elem else "Unknown"
            
            description = "No description"
            if 'description' in selectors:
                desc_elem = item.find(selectors['description'])
                description = desc_elem.get_text(strip=True) if desc_elem else "No description"
            
            eligibility = selectors.get('eligibility', 'Not specified')
            amount = selectors.get('amount', 'Varies')
            deadline = selectors.get('deadline', 'Check site')
            
            scholarships.append({
                "id": f"{selectors.get('prefix', 'SCH')}_{len(scholarships)+1:03d}",
                "name": name,
                "purpose": "Scholarship",
                "text_to_embed": f"{name}: {description}. Eligibility: {eligibility}.",
                "mock_vector": None
            })
        
        print(f"Scraped {len(scholarships)} scholarships.")
    except Exception as e:
        print(f"Scraping failed: {e}")
    finally:
        driver.quit()
    
    return scholarships

# Example usage for scholarships.gov.in (update selectors based on inspection)
if __name__ == "__main__":
    site_url = "https://www.vidyasaarathi.co.in"
    selectors = {
        'container': '.scheme-list, .scholarship-item',  # Inspect and replace
        'item_class': 'scheme-list',  # Adjust
        'name': 'h3, h4',  # Adjust
        'description': 'p',  # Adjust
        'prefix': 'NSP'
    }
    data = scrape_scholarships(site_url, selectors)
    if data:
        with open("scraped_scholarships.json", "w") as f:
            json.dump(data, f, indent=4)
        print("Saved to scraped_scholarships.json")
    else:
        print("No data scraped.")
