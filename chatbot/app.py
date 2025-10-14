from flask import Flask, request, jsonify, render_template, send_from_directory
from flask_cors import CORS
import os
import uuid
from werkzeug.utils import secure_filename
from config import Config
from gemini_client import GeminiClient
from scholarship_scraper import ScholarshipScraper
from form_filler import FormFiller
from user_profile_manager import UserProfileManager

app = Flask(__name__)
app.config.from_object(Config)
CORS(app)

# Initialize components
Config.init_app()
gemini_client = GeminiClient()
scraper = ScholarshipScraper()
profile_manager = UserProfileManager()

# Store active sessions
sessions = {}

@app.route('/')
def index():
    """Serve the main chat interface"""
    return render_template('index.html')

@app.route('/api/chat', methods=['POST'])
def chat():
    """Handle chat messages"""
    try:
        data = request.json
        message = data.get('message', '')
        session_id = data.get('session_id', str(uuid.uuid4()))
        user_id = data.get('user_id', 'default')
        
        # Get user profile
        user_profile = profile_manager.get_profile(user_id)
        
        # Get or create session
        if session_id not in sessions:
            sessions[session_id] = {
                'gemini_client': GeminiClient(),
                'user_id': user_id
            }
        
        client = sessions[session_id]['gemini_client']
        response = client.chat(message, user_profile)
        
        return jsonify({
            'success': True,
            'response': response,
            'session_id': session_id
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/analyze-scholarship', methods=['POST'])
def analyze_scholarship():
    """Analyze scholarship from URL"""
    try:
        data = request.json
        url = data.get('url')
        use_selenium = data.get('use_selenium', False)
        
        if not url:
            return jsonify({'success': False, 'error': 'URL is required'}), 400
        
        # Scrape scholarship data
        scholarship_data = scraper.scrape_scholarship_page(url, use_selenium)
        
        if 'error' in scholarship_data:
            return jsonify({'success': False, 'error': scholarship_data['error']}), 400
        
        # Analyze with AI
        analysis = gemini_client.analyze_scholarship(scholarship_data)
        
        return jsonify({
            'success': True,
            'scholarship_data': scholarship_data,
            'analysis': analysis
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/fill-form', methods=['POST'])
def fill_form():
    """Automatically fill scholarship application form"""
    try:
        data = request.json
        url = data.get('url')
        user_id = data.get('user_id', 'default')
        headless = data.get('headless', True)
        
        if not url:
            return jsonify({'success': False, 'error': 'URL is required'}), 400
        
        # Get user profile
        user_profile = profile_manager.get_profile(user_id)
        
        if not user_profile:
            return jsonify({
                'success': False,
                'error': 'User profile not found. Please create a profile first.'
            }), 400
        
        # Fill form
        with FormFiller(headless=headless) as filler:
            result = filler.fill_form(url, user_profile, screenshot=True)
        
        return jsonify(result)
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/profile', methods=['GET', 'POST', 'PUT', 'DELETE'])
def manage_profile():
    """Manage user profiles"""
    try:
        user_id = request.args.get('user_id', 'default')
        
        if request.method == 'GET':
            profile = profile_manager.get_profile(user_id)
            
            if not profile:
                # Return template for new users
                return jsonify({
                    'success': True,
                    'profile': profile_manager.get_profile_template(),
                    'is_new': True
                })
            
            validation = profile_manager.validate_profile(profile)
            
            return jsonify({
                'success': True,
                'profile': profile,
                'validation': validation,
                'is_new': False
            })
        
        elif request.method == 'POST':
            profile_data = request.json
            profile = profile_manager.create_profile(user_id, profile_data)
            
            return jsonify({
                'success': True,
                'profile': profile,
                'message': 'Profile created successfully'
            })
        
        elif request.method == 'PUT':
            updates = request.json
            profile = profile_manager.update_profile(user_id, updates)
            
            return jsonify({
                'success': True,
                'profile': profile,
                'message': 'Profile updated successfully'
            })
        
        elif request.method == 'DELETE':
            success = profile_manager.delete_profile(user_id)
            
            return jsonify({
                'success': success,
                'message': 'Profile deleted successfully' if success else 'Profile not found'
            })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/generate-essay', methods=['POST'])
def generate_essay():
    """Generate scholarship essay"""
    try:
        data = request.json
        prompt_text = data.get('prompt')
        user_id = data.get('user_id', 'default')
        word_limit = data.get('word_limit', 500)
        
        if not prompt_text:
            return jsonify({'success': False, 'error': 'Essay prompt is required'}), 400
        
        user_profile = profile_manager.get_profile(user_id)
        
        if not user_profile:
            return jsonify({
                'success': False,
                'error': 'User profile not found'
            }), 400
        
        essay = gemini_client.generate_essay(prompt_text, user_profile, word_limit)
        
        return jsonify({
            'success': True,
            'essay': essay
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/answer-query', methods=['POST'])
def answer_query():
    """Answer scholarship-related queries"""
    try:
        data = request.json
        query = data.get('query')
        context = data.get('context')
        
        if not query:
            return jsonify({'success': False, 'error': 'Query is required'}), 400
        
        answer = gemini_client.answer_query(query, context)
        
        return jsonify({
            'success': True,
            'answer': answer
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/upload', methods=['POST'])
def upload_file():
    """Upload documents"""
    try:
        if 'file' not in request.files:
            return jsonify({'success': False, 'error': 'No file provided'}), 400
        
        file = request.files['file']
        
        if file.filename == '':
            return jsonify({'success': False, 'error': 'No file selected'}), 400
        
        if file:
            filename = secure_filename(file.filename)
            filepath = os.path.join(Config.UPLOAD_FOLDER, filename)
            file.save(filepath)
            
            return jsonify({
                'success': True,
                'filename': filename,
                'filepath': filepath,
                'message': 'File uploaded successfully'
            })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/screenshots/<filename>')
def get_screenshot(filename):
    """Serve screenshot files"""
    return send_from_directory(Config.SCREENSHOTS_FOLDER, filename)

@app.route('/api/list-profiles', methods=['GET'])
def list_profiles():
    """List all user profiles"""
    try:
        profiles = profile_manager.list_profiles()
        
        return jsonify({
            'success': True,
            'profiles': profiles
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/optimize-application', methods=['POST'])
def optimize_application():
    """Get optimization suggestions for application"""
    try:
        data = request.json
        application_data = data.get('application_data')
        scholarship_criteria = data.get('scholarship_criteria')
        
        if not application_data or not scholarship_criteria:
            return jsonify({
                'success': False,
                'error': 'Both application data and scholarship criteria are required'
            }), 400
        
        optimization = gemini_client.optimize_application(application_data, scholarship_criteria)
        
        return jsonify({
            'success': True,
            'optimization': optimization
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/get-form-structure', methods=['POST'])
def get_form_structure():
    """Extract form structure from URL"""
    try:
        data = request.json
        url = data.get('url')
        
        if not url:
            return jsonify({'success': False, 'error': 'URL is required'}), 400
        
        form_structure = scraper.get_form_structure(url)
        
        return jsonify({
            'success': True,
            'form_structure': form_structure
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'success': True,
        'status': 'healthy',
        'message': 'Scholarship Application Assistant is running'
    })

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
