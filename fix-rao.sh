#!/bin/bash

echo "🩹 Applying surgical fix to RAO AI and ElevenLabs API..."

# 1. Update the Backend API to safely return binary audio for Next.js 15
echo "🎙️ Hardening Backend API Route..."
cat << 'EOF' > app/api/rao/route.ts
import { NextResponse } from 'next/server';

export async function POST(req: Request) {
  try {
    const { text } = await req.json();
    const apiKey = process.env.ELEVENLABS_API_KEY;

    if (!apiKey) {
      console.error("SERVER ERROR: ELEVENLABS_API_KEY is missing. Did you restart the server?");
      return NextResponse.json({ error: "Missing ElevenLabs API Key in .env.local" }, { status: 500 });
    }

    const VOICE_ID = "pNInz6obbfIdG4L1peC2"; // Standard Adam voice, handles Hinglish well
    
    const response = await fetch(`https://api.elevenlabs.io/v1/text-to-speech/${VOICE_ID}/stream`, {
      method: 'POST',
      headers: {
        'Accept': 'audio/mpeg',
        'xi-api-key': apiKey,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        text: text,
        model_id: "eleven_multilingual_v2",
        voice_settings: {
          stability: 0.5,
          similarity_boost: 0.75,
        }
      })
    });

    if (!response.ok) {
      const errorData = await response.text();
      console.error("ELEVENLABS API ERROR:", errorData);
      return NextResponse.json({ error: `ElevenLabs Error: ${errorData}` }, { status: response.status });
    }

    const audioBuffer = await response.arrayBuffer();
    
    // Use standard Response (instead of NextResponse) for raw binary audio in Next.js 15
    return new Response(audioBuffer, {
      headers: {
        'Content-Type': 'audio/mpeg',
        'Cache-Control': 'no-store, max-age=0',
      }
    });

  } catch (error: any) {
    console.error("CRITICAL RAO AI Error:", error);
    return NextResponse.json({ error: error.message || "Internal Server Error" }, { status: 500 });
  }
}
EOF

# 2. Update the Frontend to display the EXACT error message
echo "🤖 Upgrading Frontend Error Handling..."
cat << 'EOF' > components/RaoModal.tsx
'use client';

import { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

export default function RaoModal({ isOpen, onClose }: { isOpen: boolean, onClose: () => void }) {
  const [input, setInput] = useState('');
  const [log, setLog] = useState<{role: 'user' | 'system', text: string}[]>([
    { role: 'system', text: 'RAO_OS v3.0 ONLINE. HINGLISH VOICE MODULE READY. ENTER COMMAND.' }
  ]);
  const [isSpeaking, setIsSpeaking] = useState(false);
  const logEndRef = useRef<HTMLDivElement>(null);
  const audioRef = useRef<HTMLAudioElement | null>(null);

  useEffect(() => {
    logEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [log]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim() || isSpeaking) return;

    const userText = input;
    setLog(prev => [...prev, { role: 'user', text: userText.toUpperCase() }]);
    setInput('');
    
    if (audioRef.current) {
      audioRef.current.pause();
    }

    let aiResponseText = "";
    if (userText.length < 10) {
      aiResponseText = `Bhai, thoda detail mein batao. ${userText} samajh nahi aaya.`;
    } else {
      aiResponseText = `Processing your request. Ek second ruko... Haan, ${userText.substring(0, 20)}... yeh data system mein update ho gaya hai. Sab theek chal raha hai.`;
    }
    
    setLog(prev => [...prev, { role: 'system', text: 'GENERATING HINGLISH VOICE...' }]);
    setIsSpeaking(true);

    try {
      const response = await fetch('/api/rao', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text: aiResponseText })
      });

      if (!response.ok) {
        // Read the exact error from the backend instead of a generic message
        const errData = await response.json().catch(() => ({ error: `HTTP ${response.status}` }));
        throw new Error(errData.error || "Server Error");
      }

      const audioBlob = await response.blob();
      const audioUrl = URL.createObjectURL(audioBlob);
      
      const audio = new Audio(audioUrl);
      audioRef.current = audio;
      
      setLog(prev => {
        const newLog = [...prev];
        newLog[newLog.length - 1] = { role: 'system', text: aiResponseText.toUpperCase() };
        return newLog;
      });

      audio.play();
      audio.onended = () => setIsSpeaking(false);

    } catch (error: any) {
      console.error("Frontend caught error:", error);
      setLog(prev => {
        const newLog = [...prev];
        newLog[newLog.length - 1] = { role: 'system', text: `ERR: ${error.message}` };
        return newLog;
      });
      setIsSpeaking(false);
    }
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
          className="fixed inset-0 z-[1000] flex items-center justify-center bg-[var(--bg-color)]/90 backdrop-blur-sm p-2 sm:p-4"
        >
          <div className="absolute inset-0" onClick={onClose} />
          
          <motion.div
            initial={{ scale: 0.98, y: 5 }} animate={{ scale: 1, y: 0 }} exit={{ scale: 0.98, y: 5 }}
            transition={{ duration: 0.1, ease: "linear" }}
            className="relative w-full max-w-lg bg-[var(--card-bg)] strict-border flex flex-col overflow-hidden h-[75vh] max-h-[600px]"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="border-b-[2px] border-[var(--text-color)] p-2 sm:p-3 flex justify-between items-center bg-[var(--text-color)] text-[var(--bg-color)]">
              <h3 className="font-black tracking-widest uppercase text-xs sm:text-sm">
                RAO AI // {isSpeaking ? 'SPEAKING...' : 'IDLE'}
              </h3>
              <button onClick={() => { if(audioRef.current) audioRef.current.pause(); onClose(); }} className="font-black active:text-[var(--accent-color)] text-xs px-2 py-1 strict-border bg-[var(--bg-color)] text-[var(--text-color)]">CLOSE ✕</button>
            </div>

            <div className="flex-1 p-3 sm:p-4 overflow-y-auto flex flex-col gap-3 font-mono text-xs sm:text-sm bg-[var(--card-bg)]">
              {log.map((entry, i) => (
                <div key={i} className={`p-2 max-w-[90%] strict-border font-bold uppercase leading-tight ${entry.role === 'user' ? 'self-end bg-[var(--accent-color)] text-black text-right' : 'self-start bg-[var(--text-color)] text-[var(--bg-color)]'}`}>
                  <span className="opacity-50 text-[9px] block mb-0.5">{entry.role === 'user' ? 'USER_IN' : 'SYS_OUT'}</span>
                  {entry.text}
                </div>
              ))}
              <div ref={logEndRef} />
            </div>

            <form onSubmit={handleSubmit} className="border-t-[2px] border-[var(--text-color)] bg-[var(--bg-color)] flex p-2 gap-2">
              <input
                type="text" value={input} onChange={(e) => setInput(e.target.value)} disabled={isSpeaking}
                placeholder={isSpeaking ? "WAIT FOR AUDIO..." : "ENTER TEXT FOR RAO..."}
                className="flex-1 bg-transparent strict-border p-2 font-black uppercase text-[16px] outline-none focus:bg-[var(--text-color)] focus:text-[var(--bg-color)] transition-none placeholder:text-[var(--text-color)] placeholder:opacity-50 disabled:opacity-50"
              />
              <button type="submit" disabled={isSpeaking} className="strict-border px-3 sm:px-4 py-2 font-black uppercase text-sm sm:text-base bg-[var(--accent-color)] text-black active:bg-[var(--text-color)] active:text-[var(--accent-color)] transition-none disabled:opacity-50">
                {isSpeaking ? '...' : 'EXEC'}
              </button>
            </form>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
EOF

echo "✅ Script complete. RAO AI is fully patched."