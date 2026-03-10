// js/rao.js — RAO AI | Groq LLM + ElevenLabs TTS + Web Speech Recognition

let raoListening = false;
let raoRecognition = null;
let raoConversationHistory = [];

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
    if (SpeechRecognition) {
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
            if (raoListening) setMicState('idle');
            raoListening = false;
        };

        raoRecognition.onerror = (e) => {
            console.error('Speech recognition error:', e.error);
            setMicState('idle');
            raoListening = false;
            if (e.error === 'not-allowed') {
                const msg = 'mic access nahi mila bhai. browser mein allow karo. rao ki jai ho';
                appendMessage(msg + ' 🙏', 'ai');
                speakElevenLabs(msg);
            }
        };
    } else {
        const micBtn = document.getElementById('rao-mic-btn');
        if (micBtn) micBtn.style.display = 'none';
        const fallback = document.getElementById('rao-fallback');
        if (fallback) fallback.style.display = 'flex';
    }
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
        if (raoListening) setMicState('idle');
        raoListening = false;
    };

    raoRecognition.onerror = (e) => {
        console.error('Speech recognition error:', e.error);
        setMicState('idle');
        raoListening = false;
    };
}

function toggleMic() {
    if (raoListening) {
        stopListening();
    } else {
        startListening();
    }
}

function startListening() {
    if (!raoRecognition) return;
    try {
        raoRecognition.start();
        raoListening = true;
        setMicState('listening');
    } catch (e) { console.error(e); }
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
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${groqKey}`
            },
            body: JSON.stringify({
                model: 'llama-3.1-8b-instant',
                max_tokens: 150,
                messages: [
                    {
                        role: 'system',
                        content: `You are RAO AI — a fun, casual, helpful voice assistant on Satvik Chaturvedi's personal website. Named after his friend Rao. Keep replies SHORT (2-3 sentences max) because responses are spoken aloud. Be friendly and playful. You MUST end every single reply with the exact phrase: "rao ki jai ho" — no exceptions. No markdown, no asterisks. Plain conversational text only.`
                    },
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
            console.error('Groq error:', data);
        }
    } catch (err) {
        const errMsg = 'network issue lag raha hai bhai. rao ki jai ho';
        appendMessage(errMsg + ' 🙏', 'ai');
        await speakElevenLabs(errMsg, elevenKey);
        console.error('Groq fetch error:', err);
    }

    setMicState('idle');
}

async function speakElevenLabs(text, apiKey) {
    if (!apiKey || apiKey === 'YOUR_ELEVENLABS_API_KEY_HERE') {
        // Fallback to browser TTS if no ElevenLabs key
        browserSpeak(text);
        return;
    }

    try {
        const response = await fetch('https://api.elevenlabs.io/v1/text-to-speech/pNInz6obpgDQGcFmaJgB', {
            // Using "Adam" voice — natural, clear, free tier friendly
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'xi-api-key': apiKey
            },
            body: JSON.stringify({
                text: text,
                model_id: 'eleven_turbo_v2_5', // fastest + cheapest on free tier
                voice_settings: {
                    stability: 0.5,
                    similarity_boost: 0.75,
                    speed: 1.05
                }
            })
        });

        if (!response.ok) {
            console.warn('ElevenLabs failed, falling back to browser TTS');
            browserSpeak(text);
            return;
        }

        const audioBlob = await response.blob();
        const audioUrl = URL.createObjectURL(audioBlob);
        const audio = new Audio(audioUrl);
        audio.play();
        audio.onended = () => URL.revokeObjectURL(audioUrl);
    } catch (err) {
        console.warn('ElevenLabs error, falling back:', err);
        browserSpeak(text);
    }
}

function browserSpeak(text) {
    if (!window.speechSynthesis) return;
    window.speechSynthesis.cancel();
    const utterance = new SpeechSynthesisUtterance(text);
    utterance.lang = 'en-IN';
    utterance.rate = 1.0;
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
