#!/bin/bash

echo "📱 Optimizing Neo-Brutalist System for Mobile Devices..."

# 1. Update Global Styles (Touch Optimization & Sticky Hover Fix)
echo "🎨 Fixing Touch Interactions..."
cat << 'EOF' > styles/globals.css
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
    --bg-color: #FFFFFF;
    --text-color: #000000;
    --card-bg: #FFFFFF;
    --accent-color: #CCFF00;
    --border-weight: 2px;
}

body.dark {
    --bg-color: #000000;
    --text-color: #FFFFFF;
    --card-bg: #000000;
    --accent-color: #CCFF00;
}

body {
    font-family: 'Inter', system-ui, sans-serif;
    background-color: var(--bg-color);
    color: var(--text-color);
    overflow-x: hidden;
    line-height: 1.2;
    letter-spacing: -0.02em;
    /* Remove default tap highlight on mobile for cleaner feel */
    -webkit-tap-highlight-color: transparent; 
}

* { border-radius: 0 !important; }

.content-wrapper {
    position: relative;
    z-index: 1;
}

/* Smooth Theme Transitions */
body, 
.bg-\[var\(--bg-color\)\], 
.bg-\[var\(--card-bg\)\], 
.bg-\[var\(--text-color\)\],
.text-\[var\(--text-color\)\],
.text-\[var\(--bg-color\)\] {
    transition: background-color 0.5s ease-in-out, color 0.5s ease-in-out, border-color 0.5s ease-in-out;
}

.strict-border {
    border: var(--border-weight) solid var(--text-color);
    transition: border-color 0.5s ease-in-out;
}

/* Base states (no transitions for snappiness) */
.strict-hover {
    transition: transform 0s, background-color 0s, color 0s !important;
}
.accent-hover {
    transition: transform 0.05s linear !important;
}

/* DESKTOP ONLY: Hover effects */
@media (hover: hover) {
    .strict-hover:hover {
        background-color: var(--text-color) !important;
        color: var(--bg-color) !important;
    }
    .accent-hover:hover {
        background-color: var(--accent-color) !important;
        color: #000000 !important;
        border-color: #000000 !important;
        transform: translate(-3px, -3px);
    }
}

/* MOBILE/TOUCH ONLY: Active (Tap) effects for tactile feedback */
.strict-hover:active {
    background-color: var(--text-color) !important;
    color: var(--bg-color) !important;
}
.accent-hover:active {
    transform: translate(2px, 2px) !important;
    background-color: var(--accent-color) !important;
    color: #000000 !important;
}

::selection {
    background-color: var(--accent-color);
    color: #000000;
}
EOF

# 2. Update Home Page (Mobile Spacing Adjustments)
echo "🏠 Optimizing Home Page Layout for Small Screens..."
cat << 'EOF' > app/page.tsx
import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import CWOCard from '@/components/CWOCard';
import { createServerSupabaseClient } from '@/lib/supabase/server';

const sampleCWO = [
  { id: 1, title: 'TheCommonCo', tag: 'Merch', description: 'Scaling bulk corporate merch orders. We deliver and ship fast quick.', status: 'Active' },
  { id: 2, title: 'Sirenn', tag: 'Luxury', description: 'Building the brand identity and early product line for a future streetwear label.', status: 'Building' }
];

const sampleProjects = [
  { id: 1, title: 'UtilityHub', subtitle: 'Browser Utilities', description: '', imageUrl: '', liveUrl: '#' },
  { id: 2, title: 'Toefury', subtitle: 'E-commerce', description: '', imageUrl: '', liveUrl: '#' },
  { id: 3, title: 'SurFlow Events', subtitle: 'Event Management', description: '', imageUrl: '', liveUrl: '#' },
  { id: 4, title: 'Portfolio Core', subtitle: 'Architecture', description: '', imageUrl: '', liveUrl: '#' }
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
      
      {/* Statement block - Responsive text scaling */}
      <div className="mb-8 md:mb-12 strict-border rounded-xl p-4 md:p-8 bg-[var(--text-color)] text-[var(--bg-color)]">
        <h1 className="font-black text-4xl sm:text-5xl md:text-7xl uppercase tracking-tighter leading-[0.9]">
          PIVOT.<br/>
          EXPERIMENT.<br/>
          <span className="text-[var(--accent-color)]">SHIP.</span> SCALE.
        </h1>
      </div>

      <main className="grid grid-cols-1 gap-10 md:gap-16">
        
        <section id="currently-working-on">
          <div className="flex justify-between items-end border-b-[2px] border-[var(--text-color)] pb-2 mb-4 md:mb-6">
            <h2 className="font-black text-2xl sm:text-3xl md:text-5xl tracking-tighter uppercase leading-none">Focus</h2>
            <span className="font-black text-xs sm:text-sm md:text-xl text-[var(--text-color)] bg-[var(--accent-color)] border-[2px] border-[var(--text-color)] px-2 py-0.5 md:px-3 md:py-1 rounded-md">LIVE</span>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 md:gap-8">
            {displayCWO.map(item => (
              <CWOCard key={item.id} item={item} />
            ))}
          </div>
        </section>

        <section id="projects">
          <div className="flex justify-between items-end border-b-[2px] border-[var(--text-color)] pb-2 mb-4 md:mb-6">
            <h2 className="font-black text-2xl sm:text-3xl md:text-5xl tracking-tighter uppercase leading-none">Projects Section</h2>
          </div>
          
          {/* Mobile: Tight padding to prevent text overflow in 2 columns */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-2 md:gap-4">
            {displayProjects.map((project, index) => (
              <div
                key={project.id}
                className={`strict-border rounded-xl p-2.5 sm:p-4 md:p-5 bg-[var(--card-bg)] flex flex-col justify-between strict-hover cursor-pointer aspect-square ${index % 4 === 0 ? 'md:col-span-2' : 'col-span-1'}`}
              >
                <div>
                  <h3 className="font-black text-base sm:text-lg md:text-3xl leading-tight mb-1 tracking-tighter uppercase break-words line-clamp-2">{project.title}</h3>
                  <p className="text-[9px] sm:text-xs font-bold uppercase tracking-widest border-t-[2px] border-current pt-1 mt-1 opacity-90 truncate">{project.subtitle}</p>
                </div>
                <div className="self-end bg-[var(--bg-color)] text-[var(--text-color)] px-1.5 py-0.5 sm:px-2 sm:py-1 strict-border rounded-md md:rounded-lg mt-2">
                  <span className="font-black text-xs sm:text-base md:text-xl leading-none">→</span>
                </div>
              </div>
            ))}
          </div>
          <div className="h-10 md:h-24" />
        </section>
      </main>

      <SiteFooter />
    </>
  );
}
EOF

# 3. Update CWOCard (Dynamic Responsive Scaling)
echo "🎴 Implementing Responsive Scaling for Cards..."
cat << 'EOF' > components/CWOCard.tsx
'use client';

import React from 'react';

interface CWOItem {
  id: number;
  title: string;
  tag?: string;
  description: string;
  status?: string;
}

export default function CWOCard({ item }: { item: CWOItem }) {
  return (
    <div className="cwo-wrapper h-full">
      <div className="card h-full flex flex-col">
        <div className="card-pattern-grid" />
        <div className="card-overlay-dots" />
        
        <div className="bold-pattern">
          <svg viewBox="0 0 100 100">
            <path strokeDasharray="15 10" strokeWidth={10} stroke="var(--text-color)" fill="none" d="M0,0 L100,0 L100,100 L0,100 Z" />
          </svg>
        </div>
        
        {/* Adjusted header for mobile: allows wrapping if tags get squished */}
        <div className="card-title-area flex-col items-start sm:flex-row sm:items-center gap-2 sm:gap-0">
          <span className="truncate w-full sm:w-auto sm:pr-4">{item.title}</span>
          {item.tag && <span className="card-tag whitespace-nowrap self-start sm:self-auto">{item.tag}</span>}
        </div>
        
        <div className="card-body flex-1 flex flex-col">
          <div className="card-description flex-1">
            {item.description}
          </div>
          
          <div className="card-actions">
            {item.status && (
              <button className="card-button accent-hover">{item.status}</button>
            )}
          </div>
        </div>
        
        <div className="dots-pattern">
          <svg viewBox="0 0 80 40">
            {[10, 30, 50, 70].map(cx => (
              <React.Fragment key={cx}>
                <circle fill="var(--text-color)" r={2} cy={10} cx={cx} />
                {cx !== 70 && <circle fill="var(--text-color)" r={2} cy={20} cx={cx + 10} />}
                <circle fill="var(--text-color)" r={2} cy={30} cx={cx} />
              </React.Fragment>
            ))}
          </svg>
        </div>
        
        <div className="accent-shape" />
      </div>

      <style jsx>{`
        /* MAGIC SCALING: Adjusting base font size scales the entire em-based card layout! */
        .cwo-wrapper { font-size: 13px; }
        @media (min-width: 640px) { .cwo-wrapper { font-size: 14px; } }
        @media (min-width: 1024px) { .cwo-wrapper { font-size: 16px; } }
        
        .card {
          --primary: var(--text-color);
          --accent: var(--accent-color);
          --bg: var(--bg-color);
          --shadow-color: var(--text-color);
          --pattern-color: rgba(0, 0, 0, 0.1);

          position: relative;
          width: 100%;
          background: var(--bg);
          border: 2px solid var(--text-color);
          border-radius: 0.6em;
          box-shadow: 6px 6px 0 var(--shadow-color);
          transition: all 0.2s ease-out;
          overflow: hidden;
          z-index: 1;
        }

        /* Hover effects mapped to hover-capable devices only */
        @media (hover: hover) {
          .card:hover {
            transform: translate(-4px, -4px);
            box-shadow: 10px 10px 0 var(--shadow-color);
          }
          .card:hover .card-pattern-grid,
          .card:hover .card-overlay-dots {
            opacity: 1;
          }
          .card:hover .accent-shape {
            transform: rotate(90deg) scale(1.2);
          }
          .card:hover .card-tag {
            transform: rotate(-2deg) scale(1.05);
            background: var(--accent);
          }
        }

        /* Tactile touch feedback */
        .card:active {
          transform: translate(2px, 2px);
          box-shadow: 4px 4px 0 var(--shadow-color);
        }

        .card-pattern-grid {
          position: absolute;
          inset: 0;
          background-image: linear-gradient(to right, rgba(0, 0, 0, 0.05) 1px, transparent 1px),
                            linear-gradient(to bottom, rgba(0, 0, 0, 0.05) 1px, transparent 1px);
          background-size: 1em 1em;
          pointer-events: none;
          opacity: 0.5;
          transition: opacity 0.4s ease;
          z-index: -1;
        }

        .card-overlay-dots {
          position: absolute;
          inset: 0;
          background-image: radial-gradient(var(--pattern-color) 1px, transparent 1px);
          background-size: 1em 1em;
          pointer-events: none;
          opacity: 0;
          transition: opacity 0.4s ease;
          z-index: -1;
        }

        .bold-pattern {
          position: absolute;
          top: 0; right: 0;
          width: 6em; height: 6em;
          opacity: 0.1;
          pointer-events: none;
          z-index: -1;
        }

        .card-title-area {
          position: relative;
          padding: 1.2em;
          background: var(--primary);
          color: var(--bg);
          font-weight: 900;
          font-size: 1.2em;
          display: flex;
          border-bottom: 2px solid var(--text-color);
          text-transform: uppercase;
          letter-spacing: 0.05em;
          overflow: hidden;
        }

        .card-tag {
          background: var(--bg);
          color: var(--text-color);
          font-size: 0.6em;
          font-weight: 800;
          padding: 0.4em 0.8em;
          border: 2px solid var(--text-color);
          border-radius: 0.3em;
          box-shadow: 2px 2px 0 var(--shadow-color);
          transform: rotate(3deg);
          transition: all 0.2s ease;
        }

        .card-body {
          position: relative;
          padding: 1.5em;
          z-index: 2;
        }

        .card-description {
          margin-bottom: 1.5em;
          font-size: 0.95em;
          line-height: 1.5;
          font-weight: 600;
        }

        .card-actions {
          margin-top: auto;
          padding-top: 1em;
          border-top: 2px dashed rgba(0, 0, 0, 0.2);
          display: flex;
          justify-content: flex-start;
        }

        .card-button {
          position: relative;
          background: var(--bg);
          color: var(--text-color);
          font-size: 0.85em;
          font-weight: 800;
          padding: 0.6em 1.2em;
          border: 2px solid var(--text-color);
          border-radius: 0.4em;
          box-shadow: 3px 3px 0 var(--shadow-color);
          cursor: pointer;
          text-transform: uppercase;
          letter-spacing: 0.05em;
        }

        .dots-pattern {
          position: absolute;
          bottom: 1em; right: 1em;
          width: 6em; height: 3em;
          opacity: 0.2;
          pointer-events: none;
          z-index: 1;
        }

        .accent-shape {
          position: absolute;
          width: 2em; height: 2em;
          background: var(--accent);
          border: 2px solid var(--text-color);
          border-radius: 0.3em;
          transform: rotate(45deg);
          bottom: -1em; right: 3em;
          z-index: 0;
          transition: transform 0.3s ease;
        }
      `}</style>
    </div>
  );
}
EOF

# 4. Update Header (Better Mobile Touch Targets)
echo "⛓️ Increasing Navigation Touch Targets..."
cat << 'EOF' > components/SiteHeader.tsx
'use client';

import Link from 'next/link';
import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import ThemeToggle from './ThemeToggle';
import RaoModal from './RaoModal';

export default function SiteHeader({ active }: { active?: 'home' | 'blog' }) {
  const [menuOpen, setMenuOpen] = useState(false);
  const [raoOpen, setRaoOpen] = useState(false);

  const snapAnim = { duration: 0, type: "tween" as const };

  return (
    <>
      <header className="mb-8 md:mb-16">
        <div className="flex flex-row justify-between items-center border-b-[2px] border-[var(--text-color)] pb-3 mb-4">
          <Link href="/" className="site-name font-black text-xl sm:text-2xl md:text-3xl uppercase tracking-tighter hover:bg-[var(--accent-color)] hover:text-black transition-none px-2 py-1 -ml-2">
            Satvik Chaturvedi
          </Link>

          <nav className="hidden md:block">
            <ul className="flex space-x-2 text-sm md:text-base">
              {['X', 'in', '@'].map((item, idx) => {
                const links = ['https://x.com/StvkChrd', 'https://www.linkedin.com/in/stvkchrd', 'mailto:satvikc73@gmail.com'];
                return (
                  <motion.li key={item} whileHover={{ y: -3 }} whileTap={{ y: 0 }} transition={snapAnim}>
                    <a href={links[idx]} target={item === '@' ? '_self' : '_blank'} rel="noopener" className="block strict-border px-3 py-1.5 font-black uppercase accent-hover bg-[var(--bg-color)]">
                      {item}
                    </a>
                  </motion.li>
                );
              })}
              <motion.li whileHover={{ y: -3 }} whileTap={{ y: 0 }} transition={snapAnim}>
                <Link href="/blog" className={`block strict-border px-4 py-1.5 font-black uppercase accent-hover ${active === 'blog' ? 'bg-[var(--text-color)] text-[var(--bg-color)]' : 'bg-[var(--bg-color)]'}`}>
                  BLOG
                </Link>
              </motion.li>
              <motion.li whileHover={{ y: -3 }} whileTap={{ y: 0 }} transition={snapAnim}>
                <button onClick={() => setRaoOpen(true)} className="block strict-border px-4 py-1.5 font-black uppercase bg-[var(--accent-color)] text-black hover:bg-[var(--text-color)] hover:text-[var(--bg-color)] transition-none">
                  RAO AI ✦
                </button>
              </motion.li>
              <li className="flex items-center"><ThemeToggle /></li>
            </ul>
          </nav>

          <div className="flex items-center space-x-2 md:hidden text-xs sm:text-sm">
            <ThemeToggle />
            <button 
              onClick={() => setMenuOpen(!menuOpen)}
              className="strict-border px-3 py-2 font-black uppercase bg-[var(--accent-color)] text-black active:translate-y-1 active:shadow-none transition-transform"
            >
              {menuOpen ? 'CLOSE ✕' : 'MENU ☰'}
            </button>
          </div>
        </div>

        <AnimatePresence>
          {menuOpen && (
            <motion.div 
              initial={{ height: 0 }}
              animate={{ height: 'auto' }}
              exit={{ height: 0 }}
              transition={{ duration: 0.1, ease: "linear" }}
              className="overflow-hidden border-b-[2px] border-[var(--text-color)] bg-[var(--bg-color)] md:hidden"
            >
              <ul className="flex flex-col text-sm sm:text-base uppercase">
                <Link href="/blog" className="p-4 font-black border-b-[2px] border-[var(--text-color)] text-left w-full active:bg-[var(--text-color)] active:text-[var(--bg-color)]">BLOG</Link>
                <button onClick={() => { setRaoOpen(true); setMenuOpen(false); }} className="p-4 font-black text-left w-full bg-[var(--accent-color)] text-black active:bg-[var(--text-color)] active:text-[var(--accent-color)]">RAO AI ✦</button>
              </ul>
            </motion.div>
          )}
        </AnimatePresence>
      </header>
      <RaoModal isOpen={raoOpen} onClose={() => setRaoOpen(false)} />
    </>
  );
}
EOF

# 5. Update Rao AI Modal (iOS Zoom Fix)
echo "🎙️ Fixing Rao Modal Mobile Inputs..."
cat << 'EOF' > components/RaoModal.tsx
'use client';

import { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

export default function RaoModal({ isOpen, onClose }: { isOpen: boolean, onClose: () => void }) {
  const [input, setInput] = useState('');
  const [log, setLog] = useState<{role: 'user' | 'system', text: string}[]>([
    { role: 'system', text: 'RAO_OS v1.0 ONLINE. AWAITING COMMAND.' }
  ]);
  const logEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    logEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [log]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim()) return;

    setLog(prev => [...prev, { role: 'user', text: input.toUpperCase() }]);
    setInput('');

    setTimeout(() => {
      setLog(prev => [...prev, { 
        role: 'system', 
        text: 'ERR: ENDPOINT NOT CONNECTED IN DEMO MODE.' 
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
          className="fixed inset-0 z-[1000] flex items-center justify-center bg-[var(--bg-color)]/90 backdrop-blur-sm p-2 sm:p-4"
        >
          <div className="absolute inset-0" onClick={onClose} />
          
          <motion.div
            initial={{ scale: 0.98, y: 5 }}
            animate={{ scale: 1, y: 0 }}
            exit={{ scale: 0.98, y: 5 }}
            transition={{ duration: 0.1, ease: "linear" }}
            className="relative w-full max-w-lg bg-[var(--card-bg)] strict-border flex flex-col overflow-hidden h-[75vh] max-h-[600px]"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="border-b-[2px] border-[var(--text-color)] p-2 sm:p-3 flex justify-between items-center bg-[var(--text-color)] text-[var(--bg-color)]">
              <h3 className="font-black tracking-widest uppercase text-xs sm:text-sm">RAO AI // TERMINAL</h3>
              <button onClick={onClose} className="font-black active:text-[var(--accent-color)] text-xs px-2 py-1 strict-border bg-[var(--bg-color)] text-[var(--text-color)]">CLOSE ✕</button>
            </div>

            <div className="flex-1 p-3 sm:p-4 overflow-y-auto flex flex-col gap-3 font-mono text-xs sm:text-sm bg-[var(--card-bg)]">
              {log.map((entry, i) => (
                <div 
                  key={i} 
                  className={`p-2 max-w-[90%] strict-border font-bold uppercase leading-tight ${
                    entry.role === 'user' 
                      ? 'self-end bg-[var(--accent-color)] text-black text-right' 
                      : 'self-start bg-[var(--text-color)] text-[var(--bg-color)]'
                  }`}
                >
                  <span className="opacity-50 text-[9px] block mb-0.5">
                    {entry.role === 'user' ? 'USER_IN' : 'SYS_OUT'}
                  </span>
                  {entry.text}
                </div>
              ))}
              <div ref={logEndRef} />
            </div>

            <form onSubmit={handleSubmit} className="border-t-[2px] border-[var(--text-color)] bg-[var(--bg-color)] flex p-2 gap-2">
              {/* text-[16px] specifically prevents iOS from auto-zooming into the input field! */}
              <input
                type="text"
                value={input}
                onChange={(e) => setInput(e.target.value)}
                placeholder="ENTER COMMAND..."
                className="flex-1 bg-transparent strict-border p-2 font-black uppercase text-[16px] outline-none focus:bg-[var(--text-color)] focus:text-[var(--bg-color)] transition-none placeholder:text-[var(--text-color)] placeholder:opacity-50"
              />
              <button
                type="submit"
                className="strict-border px-3 sm:px-4 py-2 font-black uppercase text-sm sm:text-base bg-[var(--accent-color)] text-black active:bg-[var(--text-color)] active:text-[var(--accent-color)] transition-none"
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

echo "✅ Mobile optimization complete! Smooth touch interactions enabled."