#!/bin/bash
# apply-changes.sh — Run this from your project root in VS Code terminal
# Usage: bash apply-changes.sh

set -e
echo "Applying revamp changes..."

# ─────────────────────────────────────────
# js/utils.js
# ─────────────────────────────────────────
cat > js/utils.js << 'EOF'
function copyEmailToClipboard(email) {
    if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(email).then(() => {
            showCopyToast(email);
        }).catch(() => fallbackCopy(email));
    } else {
        fallbackCopy(email);
    }
}

function fallbackCopy(email) {
    const el = document.createElement('textarea');
    el.value = email;
    el.style.position = 'fixed';
    document.body.appendChild(el);
    el.focus();
    el.select();
    try { document.execCommand('copy'); showCopyToast(email); }
    catch (e) { console.error('Copy failed', e); }
    document.body.removeChild(el);
}

function showCopyToast(email) {
    const toast = document.getElementById('copy-toast');
    if (!toast) return;
    toast.textContent = email + ' copied to clipboard';
    toast.classList.add('show');
    setTimeout(() => toast.classList.remove('show'), 800);
}

function toggleMenu() {
    const menu = document.getElementById('mobile-menu');
    const icon = document.getElementById('hamburger-icon');
    if (!menu) return;
    const isOpen = menu.classList.contains('open');
    menu.classList.toggle('open', !isOpen);
    menu.classList.toggle('hidden', isOpen);
    if (icon) icon.textContent = isOpen ? '☰' : '✕';
}
EOF
echo "✓ js/utils.js"

# ─────────────────────────────────────────
# js/rao.js
# ─────────────────────────────────────────
cat > js/rao.js << 'EOF'
let raoListening = false;
let raoRecognition = null;
let raoConversationHistory = [];
let micPermissionGranted = false;

function openRao() {
    document.getElementById('rao-modal').style.display = 'flex';
}

function closeRao() {
    document.getElementById('rao-modal').style.display = 'none';
    stopListening();
}

document.addEventListener('DOMContentLoaded', () => {
    const modal = document.getElementById('rao-modal');
    if (modal) modal.addEventListener('click', (e) => { if (e.target === modal) closeRao(); });

    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (!SpeechRecognition) {
        const micBtn = document.getElementById('rao-mic-btn');
        if (micBtn) micBtn.style.display = 'none';
        const fallback = document.getElementById('rao-fallback');
        if (fallback) fallback.style.display = 'flex';
        return;
    }
    setupSpeechRecognition();
});

function setupSpeechRecognition() {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    raoRecognition = new SpeechRecognition();
    raoRecognition.continuous = false;
    raoRecognition.interimResults = false;
    raoRecognition.lang = 'en-IN';

    raoRecognition.onresult = (event) => {
        const transcript = event.results[0][0].transcript;
        appendMessage(transcript, 'user');
        setMicState('thinking');
        sendToGroq(transcript);
    };

    raoRecognition.onend = () => {
        raoListening = false;
        const btn = document.getElementById('rao-mic-btn');
        if (btn && btn.classList.contains('rao-mic-listening')) setMicState('idle');
    };

    raoRecognition.onerror = (e) => {
        console.error('Speech error:', e.error);
        raoListening = false;
        setMicState('idle');
    };
}

async function toggleMic() {
    if (raoListening) { stopListening(); return; }
    if (!micPermissionGranted) {
        try {
            const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
            stream.getTracks().forEach(t => t.stop());
            micPermissionGranted = true;
            setupSpeechRecognition();
        } catch (err) {
            appendMessage('mic permission nahi mila. browser settings mein allow karo. rao ki jai ho 🙏', 'ai');
            return;
        }
    }
    startListening();
}

function startListening() {
    if (!raoRecognition) return;
    try {
        raoRecognition.start();
        raoListening = true;
        setMicState('listening');
    } catch (e) {
        raoRecognition.stop();
        setTimeout(() => {
            try { raoRecognition.start(); raoListening = true; setMicState('listening'); }
            catch(e2) { console.error(e2); }
        }, 300);
    }
}

function stopListening() {
    if (raoRecognition && raoListening) {
        raoRecognition.stop();
        raoListening = false;
        setMicState('idle');
    }
}

function setMicState(state) {
    const btn = document.getElementById('rao-mic-btn');
    const status = document.getElementById('rao-status');
    if (!btn) return;
    btn.className = 'rao-mic-btn rao-mic-' + state;
    btn.disabled = state === 'thinking';
    if (state === 'listening') status.textContent = 'listening...';
    else if (state === 'thinking') status.textContent = 'rao is thinking...';
    else status.textContent = 'tap to speak';
}

async function sendToGroq(userText) {
    const groqKey = window.env && window.env.GROQ_API_KEY ? window.env.GROQ_API_KEY : null;
    const elevenKey = window.env && window.env.ELEVENLABS_API_KEY ? window.env.ELEVENLABS_API_KEY : null;

    if (!groqKey || groqKey === 'YOUR_GROQ_API_KEY_HERE') {
        const msg = 'config mein groq api key daalo bhai. rao ki jai ho';
        appendMessage(msg + ' 🙏', 'ai');
        await speakElevenLabs(msg, elevenKey);
        setMicState('idle');
        return;
    }

    raoConversationHistory.push({ role: 'user', content: userText });

    try {
        const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + groqKey },
            body: JSON.stringify({
                model: 'llama-3.1-8b-instant',
                max_tokens: 150,
                messages: [
                    { role: 'system', content: 'You are RAO AI — a fun, casual, helpful voice assistant on Satvik Chaturvedi\'s personal website. Named after his friend Rao. Keep replies SHORT (2-3 sentences max) because responses are spoken aloud. Be friendly and playful. You MUST end every single reply with the exact phrase: "rao ki jai ho" — no exceptions. No markdown, no asterisks. Plain conversational text only.' },
                    ...raoConversationHistory
                ]
            })
        });
        const data = await response.json();
        if (data.choices && data.choices[0] && data.choices[0].message) {
            const replyText = data.choices[0].message.content;
            raoConversationHistory.push({ role: 'assistant', content: replyText });
            appendMessage(replyText, 'ai');
            await speakElevenLabs(replyText, elevenKey);
        } else {
            const fallback = 'kuch toh gadbad hai. rao ki jai ho';
            appendMessage(fallback + ' 🙏', 'ai');
            await speakElevenLabs(fallback, elevenKey);
        }
    } catch (err) {
        const errMsg = 'network issue lag raha hai bhai. rao ki jai ho';
        appendMessage(errMsg + ' 🙏', 'ai');
        await speakElevenLabs(errMsg, elevenKey);
        console.error('Groq error:', err);
    }
    setMicState('idle');
}

async function speakElevenLabs(text, apiKey) {
    if (!apiKey || apiKey === 'YOUR_ELEVENLABS_API_KEY_HERE') { browserSpeak(text); return; }
    try {
        const response = await fetch('https://api.elevenlabs.io/v1/text-to-speech/pNInz6obpgDQGcFmaJgB', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'xi-api-key': apiKey },
            body: JSON.stringify({ text: text, model_id: 'eleven_turbo_v2_5', voice_settings: { stability: 0.5, similarity_boost: 0.75, speed: 0.88 } })
        });
        if (!response.ok) { browserSpeak(text); return; }
        const audioBlob = await response.blob();
        const audioUrl = URL.createObjectURL(audioBlob);
        const audio = new Audio(audioUrl);
        audio.play();
        audio.onended = () => URL.revokeObjectURL(audioUrl);
    } catch (err) { browserSpeak(text); }
}

function browserSpeak(text) {
    if (!window.speechSynthesis) return;
    window.speechSynthesis.cancel();
    const utterance = new SpeechSynthesisUtterance(text);
    utterance.lang = 'en-IN';
    utterance.rate = 0.9;
    const voices = window.speechSynthesis.getVoices();
    const preferred = voices.find(v => v.lang === 'en-IN') || voices.find(v => v.lang.startsWith('en'));
    if (preferred) utterance.voice = preferred;
    window.speechSynthesis.speak(utterance);
}

function appendMessage(text, sender) {
    const container = document.getElementById('rao-messages');
    if (!container) return;
    const div = document.createElement('div');
    div.className = sender === 'user' ? 'rao-msg rao-msg-user' : 'rao-msg rao-msg-ai';
    div.style.whiteSpace = 'pre-wrap';
    div.textContent = text;
    container.appendChild(div);
    container.scrollTop = container.scrollHeight;
}

function sendRaoText() {
    const input = document.getElementById('rao-text-input');
    if (!input) return;
    const msg = input.value.trim();
    if (!msg) return;
    input.value = '';
    appendMessage(msg, 'user');
    setMicState('thinking');
    sendToGroq(msg);
}
EOF
echo "✓ js/rao.js"

# ─────────────────────────────────────────
# js/config.local.js (only if it doesn't exist)
# ─────────────────────────────────────────
if [ ! -f js/config.local.js ]; then
cat > js/config.local.js << 'EOF'
// Local dev only. Override config.js here. Never commit this file.
// window.env = { GROQ_API_KEY: 'your-key-here' };
EOF
echo "✓ js/config.local.js (created)"
else
echo "- js/config.local.js already exists, skipping"
fi

# ─────────────────────────────────────────
# .gitignore — make sure config.local.js is ignored
# ─────────────────────────────────────────
if ! grep -q "config.local.js" .gitignore 2>/dev/null; then
echo "js/config.local.js" >> .gitignore
echo "✓ .gitignore updated"
fi

# ─────────────────────────────────────────
# css/style.css — append new styles
# ─────────────────────────────────────────
cat >> css/style.css << 'EOF'

/* ===== DARK MODE PROJECT CARD FIX ===== */
body.dark .brutalist-hover {
    background-color: rgba(30, 30, 30, 0.85);
    color: #ffffff;
    border-color: #ffffff;
}
body.dark .brutalist-hover:hover {
    background-color: #ffffff;
    color: #000000;
}
body.dark .bg-white\/80 {
    background-color: rgba(20, 20, 20, 0.85) !important;
}
body.dark footer {
    background-color: rgba(20, 20, 20, 0.85) !important;
    border-color: #ffffff !important;
}
body.dark footer p { color: #cccccc; }

/* ===== HAMBURGER MOBILE MENU ===== */
.mobile-menu {
    border-bottom: 2px solid var(--text-color);
    margin-bottom: 1rem;
    background-color: var(--bg-color);
}
.mobile-menu ul { list-style: none; padding: 0; margin: 0; }
.mobile-menu-item {
    display: block;
    padding: 1rem 0.5rem;
    font-weight: 900;
    font-size: 1rem;
    letter-spacing: 0.04em;
    border-bottom: 1px solid var(--text-color);
    color: var(--text-color);
    text-decoration: none;
    background: none;
    border-left: none; border-right: none; border-top: none;
    cursor: pointer;
    font-family: 'Inter', sans-serif;
    width: 100%;
    text-align: left;
    transition: background 0.15s, padding-left 0.15s;
}
.mobile-menu-item:last-child { border-bottom: none; }
.mobile-menu-item:hover {
    background-color: var(--text-color);
    color: var(--bg-color);
    padding-left: 1rem;
}
.mobile-menu.open { display: block !important; }

/* ===== CURRENTLY WORKING ON SLIDER ===== */
.cwo-slider-wrapper {
    position: relative;
    overflow: hidden;
    border: 2px solid var(--text-color);
}
.cwo-slider {
    display: flex;
    transition: transform 0.45s cubic-bezier(0.4, 0, 0.2, 1);
    will-change: transform;
}
.cwo-card {
    min-width: 100%;
    padding: 1.75rem 2rem;
    background-color: var(--card-bg);
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    min-height: 180px;
}
.cwo-card-tag {
    font-size: 0.75rem;
    font-weight: 900;
    letter-spacing: 0.12em;
    text-transform: uppercase;
    opacity: 0.5;
    margin-bottom: 0.25rem;
}
.cwo-card-desc { font-size: 0.95rem; line-height: 1.6; opacity: 0.85; flex: 1; }
.cwo-status {
    display: inline-block;
    margin-top: 0.75rem;
    padding: 0.25rem 0.75rem;
    border: 1.5px solid var(--text-color);
    font-size: 0.72rem;
    font-weight: 900;
    letter-spacing: 0.1em;
    text-transform: uppercase;
    align-self: flex-start;
}
.cwo-dots {
    display: flex;
    justify-content: center;
    gap: 0.5rem;
    padding: 0.75rem;
    border-top: 2px solid var(--text-color);
    background-color: var(--card-bg);
}
.cwo-dot {
    width: 10px; height: 10px;
    border: 2px solid var(--text-color);
    background: transparent;
    cursor: pointer; padding: 0;
    transition: background 0.2s;
}
.cwo-dot-active { background-color: var(--text-color); }

/* ===== RAO AI MODAL ===== */
#rao-modal {
    display: none;
    position: fixed;
    z-index: 200;
    inset: 0;
    background-color: rgba(0,0,0,0.5);
    backdrop-filter: blur(4px);
    align-items: flex-end;
    justify-content: flex-end;
    padding: 1.5rem;
}
.rao-modal-content {
    background-color: var(--modal-content-bg);
    border: 2px solid var(--text-color);
    width: 100%;
    max-width: 420px;
    display: flex;
    flex-direction: column;
    height: 520px;
}
.rao-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 2px solid var(--text-color);
    padding: 0.75rem 1rem;
    background-color: var(--text-color);
    color: var(--bg-color);
}
.rao-close {
    background: none; border: none;
    font-size: 1.5rem; font-weight: 900;
    cursor: pointer; color: var(--bg-color); line-height: 1;
}
.rao-messages {
    flex: 1; overflow-y: auto;
    padding: 1rem;
    display: flex; flex-direction: column; gap: 0.75rem;
}
.rao-msg {
    max-width: 85%;
    padding: 0.6rem 0.9rem;
    font-size: 0.9rem; line-height: 1.4;
    border: 1.5px solid var(--text-color);
}
.rao-msg-ai { align-self: flex-start; background-color: var(--bg-color); color: var(--text-color); }
.rao-msg-user { align-self: flex-end; background-color: var(--text-color); color: var(--bg-color); }
.rao-voice-section {
    display: flex; flex-direction: column; align-items: center;
    padding: 1.25rem; border-top: 2px solid var(--text-color); gap: 0.6rem;
}
.rao-mic-btn {
    width: 68px; height: 68px;
    border: 2px solid var(--text-color);
    background-color: var(--bg-color); color: var(--text-color);
    cursor: pointer; display: flex; align-items: center; justify-content: center;
    transition: transform 0.1s;
}
.rao-mic-btn:active { transform: scale(0.95); }
.rao-mic-idle { background-color: var(--bg-color); color: var(--text-color); }
.rao-mic-listening {
    background-color: var(--text-color); color: var(--bg-color);
    animation: rao-pulse 1s infinite;
}
.rao-mic-thinking { opacity: 0.5; cursor: not-allowed; }
@keyframes rao-pulse {
    0%, 100% { box-shadow: 0 0 0 0 rgba(0,0,0,0.4); }
    50% { box-shadow: 0 0 0 8px rgba(0,0,0,0); }
}
body.dark .rao-mic-listening { animation: rao-pulse-dark 1s infinite; }
@keyframes rao-pulse-dark {
    0%, 100% { box-shadow: 0 0 0 0 rgba(255,255,255,0.4); }
    50% { box-shadow: 0 0 0 8px rgba(255,255,255,0); }
}
.rao-status-text {
    font-size: 0.78rem; font-weight: 700;
    letter-spacing: 0.08em; text-transform: uppercase; opacity: 0.6;
}
.rao-input-row { display: flex; border-top: 2px solid var(--text-color); }
.rao-input-row input {
    flex: 1; padding: 0.75rem; border: none; outline: none;
    font-family: 'Inter', sans-serif; font-size: 0.9rem;
    background-color: var(--bg-color); color: var(--text-color);
}
.rao-input-row button {
    padding: 0.75rem 1rem;
    background-color: var(--text-color); color: var(--bg-color);
    border: none; font-weight: 900; font-family: 'Inter', sans-serif;
    cursor: pointer; font-size: 0.85rem; letter-spacing: 0.05em;
}

/* ===== MOBILE FIXES ===== */
@media (max-width: 640px) {
    #rao-modal { padding: 0; align-items: flex-end; justify-content: center; }
    .rao-modal-content { max-width: 100%; width: 100%; height: 80vh; border-bottom: none; }
    .rao-mic-btn { width: 80px; height: 80px; }
    .modal-content { width: 95%; margin: 5% auto; padding: 1.25rem; }
    body { padding: 0.75rem !important; }
}
@media (max-width: 380px) {
    header h1, header a.font-black { font-size: 1.6rem !important; }
}
EOF
echo "✓ css/style.css"

# ─────────────────────────────────────────
# Patch main.js — dark default + theme icon + gyro + CWO slider
# ─────────────────────────────────────────
node -e "
const fs = require('fs');
let c = fs.readFileSync('js/main.js', 'utf8');

// 1. Dark mode default
c = c.replace(
  \"const savedTheme = localStorage.getItem('theme') || 'light';\",
  \"const savedTheme = localStorage.getItem('theme') || 'dark';\"
);

// 2. Theme icon update in applyTheme
c = c.replace(
  \`function applyTheme(theme) {
    document.body.classList.toggle('dark', theme === 'dark');
    if (particlesMaterial) {\`,
  \`function applyTheme(theme) {
    document.body.classList.toggle('dark', theme === 'dark');
    const icon = document.getElementById('theme-icon');
    if (icon) icon.textContent = theme === 'dark' ? '☀️' : '🌙';
    if (particlesMaterial) {\`
);

fs.writeFileSync('js/main.js', c);
console.log('✓ js/main.js');
"

# ─────────────────────────────────────────
# Patch index.html — dark body class + theme icon + hamburger header + CWO section + RAO modal
# ─────────────────────────────────────────
node -e "
const fs = require('fs');
let c = fs.readFileSync('index.html', 'utf8');

// Add dark class to body
c = c.replace('<body class=\"p-4 md:p-8\">', '<body class=\"p-4 md:p-8 dark\">');

// Replace theme toggle button text
c = c.replace(
  /<li><button id=\"theme-toggle\".*?>MODE<\/button><\/li>/,
  '<li><button id=\"theme-toggle\" class=\"brutalist-hover block border-2 border-black p-3 font-bold\" title=\"Toggle theme\"><span id=\"theme-icon\">☀️</span></button></li>'
);

fs.writeFileSync('index.html', c);
console.log('✓ index.html patched');
"

# ─────────────────────────────────────────
# Patch blog.html — dark body + theme icon
# ─────────────────────────────────────────
node -e "
const fs = require('fs');
let c = fs.readFileSync('blog.html', 'utf8');
c = c.replace('<body class=\"p-4 md:p-8\">', '<body class=\"p-4 md:p-8 dark\">');
c = c.replace(
  /<li><button id=\"theme-toggle\".*?>MODE<\/button><\/li>/,
  '<li><button id=\"theme-toggle\" class=\"brutalist-hover block border-2 border-black p-3 font-bold\" title=\"Toggle theme\"><span id=\"theme-icon\">☀️</span></button></li>'
);
// Add utils.js if missing
if (!c.includes('js/utils.js')) {
  c = c.replace('<script src=\"js/main.js\" defer></script>', '<script src=\"js/utils.js\"></script>\n    <script src=\"js/main.js\" defer></script>');
}
fs.writeFileSync('blog.html', c);
console.log('✓ blog.html patched');
"

# ─────────────────────────────────────────
# Patch post.html — dark body + theme icon
# ─────────────────────────────────────────
node -e "
const fs = require('fs');
let c = fs.readFileSync('post.html', 'utf8');
c = c.replace('<body class=\"p-4 md:p-8\">', '<body class=\"p-4 md:p-8 dark\">');
c = c.replace(
  /<li><button id=\"theme-toggle\".*?>MODE<\/button><\/li>/,
  '<li><button id=\"theme-toggle\" class=\"brutalist-hover block border-2 border-black p-3 font-bold\" title=\"Toggle theme\"><span id=\"theme-icon\">☀️</span></button></li>'
);
if (!c.includes('js/utils.js')) {
  c = c.replace('<script src=\"js/main.js\" defer></script>', '<script src=\"js/utils.js\"></script>\n    <script src=\"js/main.js\" defer></script>');
}
fs.writeFileSync('post.html', c);
console.log('✓ post.html patched');
"

echo ""
echo "All changes applied successfully!"
echo "Now run: git add . && git commit -m 'hamburger nav + dark default + CWO slider + RAO AI' && git push"
