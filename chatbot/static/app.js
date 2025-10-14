let sessionId = null;
const userId = 'default';

window.addEventListener('load', () => {
    addWelcomeMessage();
});

function addWelcomeMessage() {
    const container = document.getElementById('chatContainer');
    container.innerHTML = `
        <div class="message mb-4">
            <div class="flex items-start space-x-3">
                <div class="bg-indigo-500 text-white rounded-full w-10 h-10 flex items-center justify-center">
                    <i class="fas fa-robot"></i>
                </div>
                <div class="bg-white rounded-lg p-4 shadow-sm max-w-2xl">
                    <p class="text-gray-800">👋 Hello! I'm your scholarship application assistant.</p>
                    <p class="mt-2 text-sm text-gray-600">I can help you find scholarships, fill applications, and answer questions!</p>
                </div>
            </div>
        </div>
    `;
}

function handleKeyPress(event) {
    if (event.key === 'Enter') {
        sendMessage();
    }
}

async function sendMessage() {
    const input = document.getElementById('messageInput');
    const message = input.value.trim();
    
    if (!message) return;
    
    addMessage(message, 'user');
    input.value = '';
    
    try {
        const response = await fetch('/api/chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ message, session_id: sessionId, user_id: userId })
        });
        
        const data = await response.json();
        
        if (data.success) {
            sessionId = data.session_id;
            addMessage(data.response, 'bot');
        }
    } catch (error) {
        addMessage('Sorry, I encountered an error.', 'bot');
    }
}

function addMessage(text, sender) {
    const container = document.getElementById('chatContainer');
    const messageDiv = document.createElement('div');
    messageDiv.className = 'message mb-4';
    
    if (sender === 'user') {
        messageDiv.innerHTML = `
            <div class="flex items-start space-x-3 justify-end">
                <div class="bg-indigo-600 text-white rounded-lg p-4 shadow-sm max-w-2xl">
                    <p>${escapeHtml(text)}</p>
                </div>
            </div>
        `;
    } else {
        messageDiv.innerHTML = `
            <div class="flex items-start space-x-3">
                <div class="bg-indigo-500 text-white rounded-full w-10 h-10 flex items-center justify-center">
                    <i class="fas fa-robot"></i>
                </div>
                <div class="bg-white rounded-lg p-4 shadow-sm max-w-2xl">
                    <p class="text-gray-800 whitespace-pre-wrap">${escapeHtml(text)}</p>
                </div>
            </div>
        `;
    }
    
    container.appendChild(messageDiv);
    container.scrollTop = container.scrollHeight;
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function toggleProfile() {
    alert('Profile feature - implement modal UI');
}

function showAnalyzeModal() {
    const url = prompt('Enter scholarship URL:');
    if (url) analyzeScholarship(url);
}

function showFillFormModal() {
    const url = prompt('Enter application form URL:');
    if (url) fillForm(url);
}

function showEssayModal() {
    const prompt = prompt('Enter essay prompt:');
    if (prompt) generateEssay(prompt);
}

async function analyzeScholarship(url) {
    addMessage(`Analyzing scholarship at: ${url}`, 'user');
    
    try {
        const response = await fetch('/api/analyze-scholarship', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ url })
        });
        
        const data = await response.json();
        
        if (data.success) {
            const scholarship = data.scholarship_data;
            const message = `📚 ${scholarship.title}\n\n${scholarship.description}\n\nAmount: ${scholarship.amount}\nDeadline: ${scholarship.deadline}`;
            addMessage(message, 'bot');
        } else {
            addMessage('Error analyzing scholarship: ' + data.error, 'bot');
        }
    } catch (error) {
        addMessage('Error connecting to server', 'bot');
    }
}

async function fillForm(url) {
    addMessage(`Filling form at: ${url}`, 'user');
    
    try {
        const response = await fetch('/api/fill-form', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ url, user_id: userId })
        });
        
        const data = await response.json();
        
        if (data.success) {
            addMessage(data.message, 'bot');
        } else {
            addMessage('Error: ' + data.error, 'bot');
        }
    } catch (error) {
        addMessage('Error connecting to server', 'bot');
    }
}

async function generateEssay(prompt) {
    addMessage(`Generate essay for: ${prompt}`, 'user');
    
    try {
        const response = await fetch('/api/generate-essay', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ prompt, user_id: userId })
        });
        
        const data = await response.json();
        
        if (data.success) {
            addMessage(data.essay, 'bot');
        } else {
            addMessage('Error: ' + data.error, 'bot');
        }
    } catch (error) {
        addMessage('Error connecting to server', 'bot');
    }
}
