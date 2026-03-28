#!/bin/bash

echo "🗜️ Shrinking elements and upgrading RAO AI Terminal..."

# 1. Update Home Page (Smaller Text, Small Square Project Cards)
echo "🏠 Scaling down Home Page..."
cat << 'EOF' > app/page.tsx
import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import CWOSlider from '@/components/CWOSlider';
import { createServerSupabaseClient } from '@/lib/supabase/server';
import * as motion from "framer-motion/client";

const sampleCWO = [
  { id: 1, title: 'TheCommonCo', tag: 'Merch', description: 'Scaling bulk corporate merch orders. We deliver and ship fast quick.', status: 'Active' },
  { id: 2, title: 'Sirenn', tag: 'Luxury', description: 'Building the brand identity and early product line for a future luxury streetwear label.', status: 'Building' }
];

const sampleProjects = [
  { id: 1, title: 'UtilityHub', subtitle: 'Browser Utilities', description: '', imageUrl: '', liveUrl: '#' },
  { id: 2, title: 'Toefury', subtitle: 'E-commerce', description: '', imageUrl: '', liveUrl: '#' },
  { id: 3, title: 'SurFlow Events', subtitle: 'Event Management', description: '', imageUrl: '', liveUrl: '#' },
  { id: 4, title: 'Portfolio Core', subtitle: 'System Architecture', description: '', imageUrl: '', liveUrl: '#' }
];

export default async function HomePage() {
  const supabase = createServerSupabaseClient();
  const { data: projects } = await supabase.from('projects').select('*').order('id', { ascending: false });
  const { data: workingOn } = await supabase.from('working_on').select('*').order('id', { ascending: false });

  const displayProjects = projects && projects.length > 0 ? projects : sampleProjects;
  const displayCWO = workingOn && workingOn.length > 0 ? workingOn : sampleCWO;

  return (
    <>
      <SiteHeader active="home" />
      
      {/* Statement block - MICRO Scaled */}
      <div className="mb-10 md:mb-12 strict-border p-4 md:p-6 bg-[var(--text-color)] text-[var(--bg-color)]">
        <h1 className="font-black text-3xl md:text-5xl uppercase tracking-tighter leading-[0.9]">
          PIVOT.<br/>
          EXPERIMENT.<br/>
          <span className="text-[var(--accent-color)]">SHIP.</span> SCALE.
        </h1>
      </div>

      <main className="grid grid-cols-1 gap-10 md:gap-14">
        <section id="currently-working-on">
          <div className="flex justify-between items-end border-b-[2px] border-[var(--text-color)] pb-2 mb-4">
            <h2 className="font-black text-2xl md:text-3xl tracking-tighter uppercase leading-none">Focus</h2>
            <span className="font-black text-sm md:text-base text-[var(--accent-color)] bg-[var(--text-color)] px-2">LIVE</span>
          </div>
          <CWOSlider items={displayCWO} />
        </section>

        <section id="projects">
          <div className="flex justify-between items-end border-b-[2px] border-[var(--text-color)] pb-2 mb-4">
            <h2 className="font-black text-2xl md:text-3xl tracking-tighter uppercase leading-none">Projects Section</h2>
          </div>
          
          {/* Small Squares Grid (2 columns on mobile, 4 on desktop) */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-4">
            {displayProjects.map((project) => (
              <motion.div
                key={project.id}
                className="strict-border p-3 md:p-4 bg-[var(--card-bg)] flex flex-col justify-between strict-hover cursor-pointer aspect-square"
              >
                <div>
                  <h3 className="font-black text-lg md:text-xl leading-tight mb-1 tracking-tighter uppercase">{project.title}</h3>
                  <p className="text-[10px] md:text-xs font-bold uppercase tracking-widest border-t-[2px] border-current pt-1 mt-1 opacity-90">{project.subtitle}</p>
                </div>
                <div className="self-end bg-[var(--bg-color)] text-[var(--text-color)] px-2 py-0.5 strict-border mt-2">
                  <span className="font-black text-sm leading-none">→</span>
                </div>
              </motion.div>
            ))}
          </div>
          <div className="h-10 md:h-20" />
        </section>
      </main>

      <SiteFooter />
    </>
  );
}
EOF

# 2. Update CWOSlider (Scaled down text)
echo "⚙️ Shrinking Focus Slider..."
cat << 'EOF' > components/CWOSlider.tsx
'use client';

import { useEffect, useRef, useState } from 'react';
import { motion } from 'framer-motion';

interface CWOItem {
  id: number;
  title: string;
  tag?: string;
  description: string;
  status?: string;
}

export default function CWOSlider({ items }: { items: CWOItem[] }) {
  const [current, setCurrent] = useState(0);
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const touchStartX = useRef(0);

  const go = (index: number) => setCurrent(index);

  useEffect(() => {
    intervalRef.current = setInterval(() => {
      setCurrent(prev => (prev + 1) % items.length);
    }, 5000);
    return () => { if (intervalRef.current) clearInterval(intervalRef.current); };
  }, [items.length]);

  const onTouchStart = (e: React.TouchEvent) => { touchStartX.current = e.touches[0].clientX; };
  const onTouchEnd = (e: React.TouchEvent) => {
    const diff = touchStartX.current - e.changedTouches[0].clientX;
    if (Math.abs(diff) > 40) {
      setCurrent(prev => diff > 0 ? Math.min(prev + 1, items.length - 1) : Math.max(prev - 1, 0));
    }
  };

  return (
    <div className="relative overflow-hidden strict-border bg-[var(--card-bg)]">
      <motion.div 
        className="flex"
        animate={{ x: `-${current * 100}%` }}
        transition={{ duration: 0.15, ease: "linear" }}
        onTouchStart={onTouchStart}
        onTouchEnd={onTouchEnd}
      >
        {items.map((item) => (
          <div key={item.id} className="min-w-full p-5 md:p-8 flex flex-col gap-2 min-h-[180px] justify-center strict-hover cursor-grab active:cursor-grabbing">
            <div className="flex justify-between items-start">
              <h3 className="font-black text-2xl md:text-4xl tracking-tighter uppercase leading-none">{item.title}</h3>
              <span className="text-[10px] md:text-xs font-black tracking-widest uppercase bg-[var(--accent-color)] text-black px-2 py-0.5 strict-border">
                {item.tag}
              </span>
            </div>
            <p className="text-sm md:text-base font-bold leading-snug max-w-3xl mt-2">
              {item.description}
            </p>
          </div>
        ))}
      </motion.div>

      <div className="absolute bottom-3 left-4 flex gap-2">
        {items.map((_, i) => (
          <button
            key={i}
            onClick={() => go(i)}
            className={`w-6 h-1.5 strict-border transition-none ${
              i === current ? 'bg-[var(--accent-color)]' : 'bg-[var(--bg-color)]'
            }`}
          />
        ))}
      </div>
    </div>
  );
}
EOF

# 3. Update Rao AI Modal (Add Input/Output Console)
echo "🎙️ Upgrading RAO AI to Interactive Terminal..."
cat << 'EOF' > components/RaoModal.tsx
'use client';

import { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

export default function RaoModal({ isOpen, onClose }: { isOpen: boolean, onClose: () => void }) {
  const [input, setInput] = useState('');
  const [log, setLog] = useState<{role: 'user' | 'system', text: string}[]>([
    { role: 'system', text: 'RAO_OS v1.0 ONLINE. AWAITING INPUT.' }
  ]);
  const logEndRef = useRef<HTMLDivElement>(null);

  // Auto-scroll to bottom of log
  useEffect(() => {
    logEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [log]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim()) return;

    // Add user input
    setLog(prev => [...prev, { role: 'user', text: input.toUpperCase() }]);
    setInput('');

    // Simulate system response
    setTimeout(() => {
      setLog(prev => [...prev, { 
        role: 'system', 
        text: 'PROCESSING REQUEST... ENDPOINT NOT CONNECTED IN DEMO MODE.' 
      }]);
    }, 600);
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="fixed inset-0 z-[1000] flex items-center justify-center bg-[var(--bg-color)]/90 backdrop-blur-sm p-4"
        >
          {/* Click background to close */}
          <div className="absolute inset-0" onClick={onClose} />
          
          <motion.div
            initial={{ scale: 0.98, y: 5 }}
            animate={{ scale: 1, y: 0 }}
            exit={{ scale: 0.98, y: 5 }}
            transition={{ duration: 0.1, ease: "linear" }}
            className="relative w-full max-w-lg bg-[var(--card-bg)] strict-border flex flex-col overflow-hidden h-[70vh] max-h-[600px]"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Terminal Header */}
            <div className="border-b-[2px] border-[var(--text-color)] p-2 flex justify-between items-center bg-[var(--text-color)] text-[var(--bg-color)]">
              <h3 className="font-black tracking-widest uppercase text-xs">RAO AI // TERMINAL</h3>
              <button onClick={onClose} className="font-black hover:text-[var(--accent-color)] text-xs px-2 py-0.5 strict-border bg-[var(--bg-color)] text-[var(--text-color)]">CLOSE ✕</button>
            </div>

            {/* Terminal Output Log */}
            <div className="flex-1 p-4 overflow-y-auto flex flex-col gap-3 font-mono text-sm md:text-base bg-[var(--card-bg)]">
              {log.map((entry, i) => (
                <div 
                  key={i} 
                  className={`p-2 max-w-[85%] strict-border font-bold uppercase leading-tight ${
                    entry.role === 'user' 
                      ? 'self-end bg-[var(--accent-color)] text-black text-right' 
                      : 'self-start bg-[var(--text-color)] text-[var(--bg-color)]'
                  }`}
                >
                  <span className="opacity-50 text-[10px] block mb-1">
                    {entry.role === 'user' ? 'USER_INPUT' : 'SYS_OUTPUT'}
                  </span>
                  {entry.text}
                </div>
              ))}
              <div ref={logEndRef} />
            </div>

            {/* Terminal Input Form */}
            <form onSubmit={handleSubmit} className="border-t-[2px] border-[var(--text-color)] bg-[var(--bg-color)] flex p-2 gap-2">
              <input
                type="text"
                value={input}
                onChange={(e) => setInput(e.target.value)}
                placeholder="ENTER COMMAND..."
                className="flex-1 bg-transparent strict-border p-2 font-black uppercase text-sm md:text-base outline-none focus:bg-[var(--text-color)] focus:text-[var(--bg-color)] transition-none placeholder:text-[var(--text-color)] placeholder:opacity-50"
              />
              <button
                type="submit"
                className="strict-border px-4 py-2 font-black uppercase text-sm md:text-base bg-[var(--accent-color)] text-black hover:bg-[var(--text-color)] hover:text-[var(--accent-color)] transition-none"
              >
                EXEC
              </button>
            </form>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
EOF

echo "✅ Elements scaled down & RAO Terminal Online! Run 'npm run dev' to see changes."