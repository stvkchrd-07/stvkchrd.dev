'use client';

import { useEffect, useRef, useState } from 'react';

interface Message {
  role: 'user' | 'ai';
  text: string;
}

interface Props {
  isOpen: boolean;
  onClose: () => void;
}

export default function RaoModal({ isOpen, onClose }: Props) {
  const [messages, setMessages] = useState<Message[]>([
    { role: 'ai', text: 'hey, what do you want? 👀' }
  ]);
  const [micState, setMicState] = useState<'idle' | 'listening' | 'thinking'>('idle');
  const [hasSpeechSupport, setHasSpeechSupport] = useState(true);
  const [textInput, setTextInput] = useState('');
  const recognitionRef = useRef<any>(null);
  const listeningRef = useRef(false);
  const permissionRef = useRef(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const historyRef = useRef<{ role: string; content: string }[]>([]);

  useEffect(() => {
    const SR = (window as any).SpeechRecognition || (window as any).webkitSpeechRecognition;
    if (!SR) { setHasSpeechSupport(false); return; }
    setupRecognition();
  }, []);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  function setupRecognition() {
    const SR = (window as any).SpeechRecognition || (window as any).webkitSpeechRecognition;
    const rec = new SR();
    rec.continuous = false;
    rec.interimResults = false;
    rec.lang = 'en-IN';
    rec.onresult = (e: any) => {
      const transcript = e.results[0][0].transcript;
      addMessage(transcript, 'user');
      setMicState('thinking');
      sendToGroq(transcript);
    };
    rec.onend = () => {
      listeningRef.current = false;
      setMicState(prev => prev === 'listening' ? 'idle' : prev);
    };
    rec.onerror = () => {
      listeningRef.current = false;
      setMicState('idle');
    };
    recognitionRef.current = rec;
  }

  async function toggleMic() {
    if (listeningRef.current) {
      recognitionRef.current?.stop();
      listeningRef.current = false;
      setMicState('idle');
      return;
    }
    if (!permissionRef.current) {
      try {
        const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
        stream.getTracks().forEach(t => t.stop());
        permissionRef.current = true;
        setupRecognition();
      } catch {
        addMessage('mic permission nahi mila. browser settings mein allow karo. rao ki jai ho 🙏', 'ai');
        return;
      }
    }
    try {
      recognitionRef.current?.start();
      listeningRef.current = true;
      setMicState('listening');
    } catch {
      setTimeout(() => {
        try { recognitionRef.current?.start(); listeningRef.current = true; setMicState('listening'); } catch {}
      }, 300);
    }
  }

  async function sendToGroq(userText: string) {
    const groqKey = process.env.NEXT_PUBLIC_GROQ_API_KEY;
    const elevenKey = process.env.NEXT_PUBLIC_ELEVENLABS_API_KEY;

    if (!groqKey || groqKey === 'your-groq-api-key') {
      const msg = 'NEXT_PUBLIC_GROQ_API_KEY set karo .env.local mein. rao ki jai ho';
      addMessage(msg + ' 🙏', 'ai');
      await speakElevenLabs(msg, elevenKey);
      setMicState('idle');
      return;
    }

    historyRef.current.push({ role: 'user', content: userText });

    try {
      const res = await fetch('https://api.groq.com/openai/v1/chat/completions', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${groqKey}` },
        body: JSON.stringify({
          model: 'llama-3.1-8b-instant',
          max_tokens: 150,
          messages: [
            {
              role: 'system',
              content: 'You are RAO AI — a fun, casual, helpful voice assistant on Satvik Chaturvedi\'s personal website. Named after his friend Rao. Keep replies SHORT (2-3 sentences max) because responses are spoken aloud. Be friendly and playful. You MUST end every single reply with the exact phrase: "rao ki jai ho" — no exceptions. No markdown, no asterisks. Plain conversational text only.'
            },
            ...historyRef.current
          ]
        })
      });
      const data = await res.json();
      if (data.choices?.[0]?.message?.content) {
        const reply = data.choices[0].message.content;
        historyRef.current.push({ role: 'assistant', content: reply });
        addMessage(reply, 'ai');
        await speakElevenLabs(reply, elevenKey);
      } else {
        const fallback = 'kuch gadbad hai. rao ki jai ho';
        addMessage(fallback + ' 🙏', 'ai');
        await speakElevenLabs(fallback, elevenKey);
      }
    } catch {
      const err = 'network issue lag raha hai. rao ki jai ho';
      addMessage(err + ' 🙏', 'ai');
      await speakElevenLabs(err, elevenKey);
    }
    setMicState('idle');
  }

  async function speakElevenLabs(text: string, apiKey?: string) {
    if (!apiKey || apiKey === 'your-elevenlabs-api-key') {
      browserSpeak(text);
      return;
    }
    try {
      const res = await fetch('https://api.elevenlabs.io/v1/text-to-speech/pNInz6obpgDQGcFmaJgB', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'xi-api-key': apiKey },
        body: JSON.stringify({ text, model_id: 'eleven_turbo_v2_5', voice_settings: { stability: 0.5, similarity_boost: 0.75, speed: 0.88 } })
      });
      if (!res.ok) { browserSpeak(text); return; }
      const blob = await res.blob();
      const url = URL.createObjectURL(blob);
      const audio = new Audio(url);
      audio.play();
      audio.onended = () => URL.revokeObjectURL(url);
    } catch { browserSpeak(text); }
  }

  function browserSpeak(text: string) {
    if (!window.speechSynthesis) return;
    window.speechSynthesis.cancel();
    const u = new SpeechSynthesisUtterance(text);
    u.lang = 'en-IN'; u.rate = 0.9;
    const voices = window.speechSynthesis.getVoices();
    const v = voices.find(v => v.lang === 'en-IN') || voices.find(v => v.lang.startsWith('en'));
    if (v) u.voice = v;
    window.speechSynthesis.speak(u);
  }

  function addMessage(text: string, role: 'user' | 'ai') {
    setMessages(prev => [...prev, { role, text }]);
  }

  async function handleTextSend() {
    if (!textInput.trim()) return;
    const msg = textInput.trim();
    setTextInput('');
    addMessage(msg, 'user');
    setMicState('thinking');
    await sendToGroq(msg);
  }

  if (!isOpen) return null;

  return (
    <div
      id="rao-modal"
      style={{ display: 'flex' }}
      onClick={(e) => { if (e.target === e.currentTarget) onClose(); }}
    >
      <div className="rao-modal-content">
        <div className="rao-header">
          <span className="font-black text-xl">RAO AI ✦</span>
          <button className="rao-close" onClick={onClose}>&times;</button>
        </div>

        <div className="rao-messages">
          {messages.map((m, i) => (
            <div key={i} className={`rao-msg ${m.role === 'user' ? 'rao-msg-user' : 'rao-msg-ai'}`}>
              {m.text}
            </div>
          ))}
          <div ref={messagesEndRef} />
        </div>

        {hasSpeechSupport ? (
          <div className="rao-voice-section">
            <button
              className={`rao-mic-btn rao-mic-${micState}`}
              onClick={toggleMic}
              disabled={micState === 'thinking'}
              title="Tap to speak"
            >
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" width="28" height="28">
                <path d="M12 1a4 4 0 0 1 4 4v6a4 4 0 0 1-8 0V5a4 4 0 0 1 4-4zm0 2a2 2 0 0 0-2 2v6a2 2 0 0 0 4 0V5a2 2 0 0 0-2-2zm7 8a1 1 0 0 1 1 1 8 8 0 0 1-7 7.93V22h2a1 1 0 0 1 0 2H9a1 1 0 0 1 0-2h2v-2.07A8 8 0 0 1 4 12a1 1 0 0 1 2 0 6 6 0 0 0 12 0 1 1 0 0 1 1-1z"/>
              </svg>
            </button>
            <span className="rao-status-text">
              {micState === 'listening' ? 'listening...' : micState === 'thinking' ? 'rao is thinking...' : 'tap to speak'}
            </span>
          </div>
        ) : (
          <div className="rao-input-row">
            <input
              type="text"
              placeholder="type your question..."
              value={textInput}
              onChange={e => setTextInput(e.target.value)}
              onKeyDown={e => e.key === 'Enter' && handleTextSend()}
            />
            <button onClick={handleTextSend}>SEND</button>
          </div>
        )}
      </div>
    </div>
  );
}
