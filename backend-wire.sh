#!/bin/bash

echo "🔌 Wiring up Supabase Admin, ElevenLabs Backend, and Minimal Particles..."

# 1. Minimal 3D Particles
echo "🌌 Minimizing 3D Canvas..."
cat << 'EOF' > components/CanvasBackground.tsx
'use client';

import { useRef, useEffect, useState, useMemo } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import * as THREE from 'three';

function ParticleField() {
  const pointsRef = useRef<THREE.Points>(null);
  const [mouse, setMouse] = useState({ x: 0, y: 0 });
  const [gyro, setGyro] = useState({ alpha: 0, beta: 0, gamma: 0 });

  // REDUCED PARTICLES: 2000 -> 400 for ultra-minimal look
  const [positions, phases] = useMemo(() => {
    const pos = new Float32Array(400 * 3);
    const ph = new Float32Array(400);
    for (let i = 0; i < 400; i++) {
      pos[i * 3] = (Math.random() - 0.5) * 15;
      pos[i * 3 + 1] = (Math.random() - 0.5) * 15;
      pos[i * 3 + 2] = (Math.random() - 0.5) * 15;
      ph[i] = Math.random() * Math.PI * 2;
    }
    return [pos, ph];
  }, []);

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      setMouse({ x: (e.clientX / window.innerWidth) * 2 - 1, y: -(e.clientY / window.innerHeight) * 2 + 1 });
    };
    const handleOrientation = (e: DeviceOrientationEvent) => {
      if (e.beta && e.gamma) setGyro({ alpha: e.alpha || 0, beta: e.beta, gamma: e.gamma });
    };

    const requestGyroPermission = () => {
      if (typeof (DeviceOrientationEvent as any).requestPermission === 'function') {
        (DeviceOrientationEvent as any).requestPermission().then((state: string) => {
            if (state === 'granted') window.addEventListener('deviceorientation', handleOrientation);
          }).catch(console.error);
      } else {
        window.addEventListener('deviceorientation', handleOrientation);
      }
    };

    window.addEventListener('mousemove', handleMouseMove);
    window.addEventListener('click', requestGyroPermission, { once: true });
    window.addEventListener('touchstart', requestGyroPermission, { once: true });

    return () => {
      window.removeEventListener('mousemove', handleMouseMove);
      window.removeEventListener('deviceorientation', handleOrientation);
    };
  }, []);

  useFrame((state) => {
    if (!pointsRef.current) return;
    const positionsAttr = pointsRef.current.geometry.attributes.position;
    for (let i = 0; i < 400; i++) {
      positionsAttr.getY(i); 
      const x = positionsAttr.getX(i);
      const z = positionsAttr.getZ(i);
      positionsAttr.setY(i, Math.sin(state.clock.elapsedTime * 0.3 + x + z) * 0.5 + (Math.sin(phases[i]) * 5));
    }
    positionsAttr.needsUpdate = true;
    const targetX = gyro.beta ? gyro.beta * 0.01 : mouse.y * 0.1;
    const targetY = gyro.gamma ? gyro.gamma * 0.01 : mouse.x * 0.1;
    pointsRef.current.rotation.x = THREE.MathUtils.lerp(pointsRef.current.rotation.x, targetX, 0.05);
    pointsRef.current.rotation.y = THREE.MathUtils.lerp(pointsRef.current.rotation.y, targetY + state.clock.elapsedTime * 0.02, 0.05);
  });

  return (
    <points ref={pointsRef}>
      <bufferGeometry>
        <bufferAttribute attach="attributes-position" args={[positions, 3]} />
      </bufferGeometry>
      {/* MINIMAL STYLE: Size 0.02, Opacity 0.3 */}
      <pointsMaterial size={0.02} color="#FFFFFF" transparent opacity={0.3} sizeAttenuation={true} />
    </points>
  );
}

export default function CanvasBackground() {
  return (
    <div className="fixed inset-0 z-0 bg-transparent pointer-events-none">
      <Canvas camera={{ position: [0, 0, 5], fov: 60 }} dpr={[1, 1.5]} performance={{ min: 0.5 }}>
        <ParticleField />
      </Canvas>
    </div>
  );
}
EOF

# 2. Fully Functional Admin Page (Supabase Insert Logic)
echo "🎛️ Wiring Admin Page to Supabase..."
cat << 'EOF' > app/admin/page.tsx
'use client';

import { useState } from 'react';
import Link from 'next/link';
import { createClientComponentClient } from '@supabase/auth-helpers-nextjs';

export default function AdminDashboard() {
  const [activeTab, setActiveTab] = useState<'projects' | 'cwo' | 'posts'>('projects');
  const [loading, setLoading] = useState(false);
  const [status, setStatus] = useState('');
  
  const supabase = createClientComponentClient();

  // Form States
  const [title, setTitle] = useState('');
  const [subtitle, setSubtitle] = useState(''); // Used as "tag" for CWO
  const [description, setDescription] = useState('');
  const [statusText, setStatusText] = useState('Active');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setStatus('UPLOADING...');

    try {
      let error;
      if (activeTab === 'projects') {
        const { error: dbError } = await supabase.from('projects').insert([{ 
          title, subtitle, description 
        }]);
        error = dbError;
      } else if (activeTab === 'cwo') {
        const { error: dbError } = await supabase.from('working_on').insert([{ 
          title, tag: subtitle, description, status: statusText 
        }]);
        error = dbError;
      } else {
        // Assuming you have a 'posts' table for blog posts
        const { error: dbError } = await supabase.from('posts').insert([{ 
          title, content: description 
        }]);
        error = dbError;
      }

      if (error) throw error;
      
      setStatus('SUCCESS: DATA WRITTEN TO SUPABASE.');
      setTitle(''); setSubtitle(''); setDescription('');
    } catch (err: any) {
      console.error(err);
      setStatus(`ERROR: ${err.message}`);
    } finally {
      setLoading(false);
      setTimeout(() => setStatus(''), 4000);
    }
  };

  return (
    <div className="min-h-screen bg-[var(--bg-color)] text-[var(--text-color)] p-4 md:p-8 font-sans">
      <header className="flex justify-between items-center border-b-[2px] border-[var(--text-color)] pb-4 mb-8">
        <div>
          <h1 className="font-black text-2xl md:text-4xl uppercase tracking-tighter leading-none">SYSTEM_ADMIN</h1>
          <p className="text-xs font-bold uppercase tracking-widest opacity-50 mt-1">Database Control Panel</p>
        </div>
        <Link href="/" className="strict-border px-4 py-2 font-black uppercase text-xs md:text-sm bg-[var(--text-color)] text-[var(--bg-color)] active:translate-y-0.5">
          EXIT ↗
        </Link>
      </header>

      <div className="flex flex-wrap gap-2 mb-6">
        {['projects', 'cwo', 'posts'].map((tab) => (
          <button 
            key={tab}
            onClick={() => setActiveTab(tab as any)}
            className={`strict-border px-4 py-2 font-black uppercase text-sm transition-none ${activeTab === tab ? 'bg-[var(--accent-color)] text-black' : 'bg-[var(--bg-color)] text-[var(--text-color)]'}`}
          >
            {tab === 'cwo' ? 'FOCUS DB' : `${tab.toUpperCase()} DB`}
          </button>
        ))}
      </div>

      <main className="strict-border p-6 md:p-10 bg-[var(--card-bg)]">
        <h2 className="font-black text-xl uppercase border-b-[2px] border-[var(--text-color)] pb-2 mb-6">
          INSERT NEW {activeTab.toUpperCase()}
        </h2>
        
        <form onSubmit={handleSubmit} className="flex flex-col gap-4 max-w-2xl">
          <div className="flex flex-col gap-1">
            <label className="text-xs font-bold uppercase tracking-widest">Title</label>
            <input required value={title} onChange={e => setTitle(e.target.value)} type="text" className="strict-border p-2 bg-transparent focus:bg-[var(--text-color)] focus:text-[var(--bg-color)] outline-none font-bold" placeholder="ENTRY NAME" />
          </div>
          
          {activeTab !== 'posts' && (
            <div className="flex flex-col gap-1">
              <label className="text-xs font-bold uppercase tracking-widest">{activeTab === 'cwo' ? 'Tag' : 'Subtitle'}</label>
              <input required value={subtitle} onChange={e => setSubtitle(e.target.value)} type="text" className="strict-border p-2 bg-transparent focus:bg-[var(--text-color)] focus:text-[var(--bg-color)] outline-none font-bold" placeholder={activeTab === 'cwo' ? "e.g., Luxury" : "e.g., Web App"} />
            </div>
          )}

          {activeTab === 'cwo' && (
             <div className="flex flex-col gap-1">
              <label className="text-xs font-bold uppercase tracking-widest">Status</label>
              <input required value={statusText} onChange={e => setStatusText(e.target.value)} type="text" className="strict-border p-2 bg-transparent focus:bg-[var(--text-color)] focus:text-[var(--bg-color)] outline-none font-bold" placeholder="e.g., Active, Building" />
            </div>
          )}
          
          <div className="flex flex-col gap-1">
            <label className="text-xs font-bold uppercase tracking-widest">{activeTab === 'posts' ? 'Content (Markdown)' : 'Description'}</label>
            <textarea required value={description} onChange={e => setDescription(e.target.value)} rows={5} className="strict-border p-2 bg-transparent focus:bg-[var(--text-color)] focus:text-[var(--bg-color)] outline-none font-bold resize-none" placeholder="ENTER DETAILS..."></textarea>
          </div>

          <div className="flex items-center gap-4 mt-2">
            <button disabled={loading} type="submit" className="strict-border px-6 py-3 font-black uppercase bg-[var(--accent-color)] text-black active:translate-y-1 active:shadow-none disabled:opacity-50">
              {loading ? 'PROCESSING...' : 'UPLOAD TO SUPABASE'}
            </button>
            {status && <span className="font-bold text-xs tracking-widest uppercase">{status}</span>}
          </div>
        </form>
      </main>
    </div>
  );
}
EOF

# 3. Create ElevenLabs Backend API Route
echo "🎙️ Creating ElevenLabs Backend API Route..."
mkdir -p app/api/rao
cat << 'EOF' > app/api/rao/route.ts
import { NextResponse } from 'next/server';

export async function POST(req: Request) {
  try {
    const { text } = await req.json();

    if (!process.env.ELEVENLABS_API_KEY) {
      return NextResponse.json({ error: "Missing ElevenLabs API Key" }, { status: 500 });
    }

    // You can change this to a specific Indian Male Voice ID from your ElevenLabs dashboard
    const VOICE_ID = "pNInz6obbfIdG4L1peC2"; // Placeholder Adam voice. Replace with your custom Hinglish voice ID.
    
    // Call ElevenLabs API
    const response = await fetch(`https://api.elevenlabs.io/v1/text-to-speech/${VOICE_ID}/stream`, {
      method: 'POST',
      headers: {
        'Accept': 'audio/mpeg',
        'xi-api-key': process.env.ELEVENLABS_API_KEY,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        text: text,
        // Turbo v2.5 is the best model for switching smoothly between Hindi and English
        model_id: "eleven_turbo_v2_5",
        voice_settings: {
          stability: 0.5,
          similarity_boost: 0.75,
        }
      })
    });

    if (!response.ok) {
      throw new Error(`ElevenLabs API error: ${response.statusText}`);
    }

    const audioBuffer = await response.arrayBuffer();
    
    return new NextResponse(audioBuffer, {
      headers: { 'Content-Type': 'audio/mpeg' }
    });

  } catch (error) {
    console.error("RAO AI Error:", error);
    return NextResponse.json({ error: "Voice generation failed." }, { status: 500 });
  }
}
EOF

# 4. Update Rao AI Frontend to play audio
echo "🎙️ Updating Rao Frontend to fetch and play voice..."
cat << 'EOF' > components/RaoModal.tsx
'use client';

import { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

export default function RaoModal({ isOpen, onClose }: { isOpen: boolean, onClose: () => void }) {
  const [input, setInput] = useState('');
  const [log, setLog] = useState<{role: 'user' | 'system', text: string}[]>([
    { role: 'system', text: 'RAO_OS v2.0 ONLINE. HINGLISH VOICE MODULE READY.' }
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
    
    // Stop any currently playing audio
    if (audioRef.current) {
      audioRef.current.pause();
    }

    // In a real app, you would send userText to Gemini/OpenAI here first to get a response.
    // For now, we assume RAO is repeating the text or generating a standard response to read out loud.
    const aiResponseText = `Processing: ${userText}. Bhai, system ekdum smooth chal raha hai.`;
    
    setLog(prev => [...prev, { role: 'system', text: 'GENERATING VOICE...' }]);
    setIsSpeaking(true);

    try {
      const response = await fetch('/api/rao', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text: aiResponseText })
      });

      if (!response.ok) throw new Error("API Route Failed");

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

    } catch (error) {
      console.error(error);
      setLog(prev => {
        const newLog = [...prev];
        newLog[newLog.length - 1] = { role: 'system', text: 'ERR: ELEVENLABS API KEY MISSING OR QUOTA EXCEEDED.' };
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
                placeholder={isSpeaking ? "WAIT FOR AUDIO TO FINISH..." : "ENTER TEXT FOR RAO..."}
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

echo "✅ Script complete. Backend API Route added."