#!/bin/bash

echo "🟨 Initiating Strict Neo-Brutalist Override (Neon Yellow Edition)..."

# 1. Global Styles (Pure Black/White, Neon Yellow, No Shadows, 3px Borders)
echo "🎨 Writing Strict Global Styles..."
cat << 'EOF' > styles/globals.css
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
    --bg-color: #FFFFFF;
    --text-color: #000000;
    --card-bg: #FFFFFF;
    --accent-color: #CCFF00; /* High-visibility Neon Yellow */
    --border-weight: 3px;
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
    line-height: 1.1; /* Extremely tight line height for a raw feel */
    letter-spacing: -0.02em;
}

* { border-radius: 0 !important; }

.content-wrapper {
    position: relative;
    z-index: 1;
}

/* Strict Borders - NO Shadows */
.strict-border {
    border: var(--border-weight) solid var(--text-color);
}

/* Interactions: Snappy, instant, inverting */
.strict-hover {
    transition: transform 0s, background-color 0s, color 0s;
}

.strict-hover:hover {
    background-color: var(--text-color);
    color: var(--bg-color);
}

/* Accent Button/Link Hover */
.accent-hover {
    transition: transform 0.05s linear;
}

.accent-hover:hover {
    background-color: var(--accent-color) !important;
    color: #000000 !important;
    transform: translate(-4px, -4px);
}

.accent-hover:active {
    transform: translate(2px, 2px);
}

/* Text Selection Accent */
::selection {
    background-color: var(--accent-color);
    color: #000000;
}
EOF

# 2. Site Header (Static, Bold, Snappy Links)
echo "⛓️ Writing Aggressive Site Header..."
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

  // Zero-easing, instant snap
  const snapAnim = { duration: 0, type: "tween" as const };

  return (
    <>
      <header className="mb-12 md:mb-24">
        <div className="flex flex-row justify-between items-center border-b-[3px] border-[var(--text-color)] pb-4 mb-4">
          <Link href="/" className="site-name font-black text-3xl md:text-5xl uppercase tracking-tighter hover:bg-[var(--accent-color)] hover:text-black transition-none px-2 py-1 -ml-2">
            Satvik Chaturvedi
          </Link>

          <nav className="hidden md:block">
            <ul className="flex space-x-3 text-base md:text-lg">
              {['X', 'in', '@'].map((item, idx) => {
                const links = ['https://x.com/StvkChrd', 'https://www.linkedin.com/in/stvkchrd', 'mailto:satvikc73@gmail.com'];
                return (
                  <motion.li key={item} whileHover={{ y: -4 }} whileTap={{ y: 0 }} transition={snapAnim}>
                    <a href={links[idx]} target={item === '@' ? '_self' : '_blank'} rel="noopener" className="block strict-border px-4 py-2 font-black uppercase accent-hover bg-[var(--bg-color)]">
                      {item}
                    </a>
                  </motion.li>
                );
              })}
              <motion.li whileHover={{ y: -4 }} whileTap={{ y: 0 }} transition={snapAnim}>
                <Link href="/blog" className={`block strict-border px-5 py-2 font-black uppercase accent-hover ${active === 'blog' ? 'bg-[var(--text-color)] text-[var(--bg-color)]' : 'bg-[var(--bg-color)]'}`}>
                  BLOG
                </Link>
              </motion.li>
              <motion.li whileHover={{ y: -4 }} whileTap={{ y: 0 }} transition={snapAnim}>
                <button onClick={() => setRaoOpen(true)} className="block strict-border px-5 py-2 font-black uppercase bg-[var(--accent-color)] text-black hover:bg-[var(--text-color)] hover:text-[var(--bg-color)] transition-none">
                  RAO AI ✦
                </button>
              </motion.li>
              <li className="flex items-center"><ThemeToggle /></li>
            </ul>
          </nav>

          <div className="flex items-center space-x-3 md:hidden text-lg">
            <ThemeToggle />
            <motion.button 
              whileTap={{ y: 2 }}
              onClick={() => setMenuOpen(!menuOpen)}
              className="strict-border px-4 py-2 font-black uppercase bg-[var(--accent-color)] text-black"
            >
              {menuOpen ? 'CLOSE' : 'MENU'}
            </motion.button>
          </div>
        </div>

        <AnimatePresence>
          {menuOpen && (
            <motion.div 
              initial={{ height: 0 }}
              animate={{ height: 'auto' }}
              exit={{ height: 0 }}
              transition={{ duration: 0.1, ease: "linear" }}
              className="overflow-hidden border-b-[3px] border-[var(--text-color)] bg-[var(--bg-color)] md:hidden"
            >
              <ul className="flex flex-col text-lg uppercase">
                <Link href="/blog" className="p-4 font-black border-b-[3px] border-[var(--text-color)] text-left w-full strict-hover">BLOG</Link>
                <button onClick={() => { setRaoOpen(true); setMenuOpen(false); }} className="p-4 font-black text-left w-full bg-[var(--accent-color)] text-black hover:bg-[var(--text-color)] hover:text-[var(--accent-color)] transition-none">RAO AI ✦</button>
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

# 3. Home Page (Asymmetric Grid, High Contrast, Raw Typograpy)
echo "🏠 Writing Blocky Home Page..."
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
      
      {/* Statement block */}
      <div className="mb-16 md:mb-24 strict-border p-6 md:p-10 bg-[var(--text-color)] text-[var(--bg-color)]">
        <h1 className="font-black text-5xl md:text-8xl uppercase tracking-tighter leading-[0.85]">
          PIVOT.<br/>
          EXPERIMENT.<br/>
          <span className="text-[var(--accent-color)]">SHIP.</span> SCALE.
        </h1>
      </div>

      <main className="grid grid-cols-1 gap-16 md:gap-24">
        <section id="currently-working-on">
          <div className="flex justify-between items-end border-b-[3px] border-[var(--text-color)] pb-2 mb-6">
            <h2 className="font-black text-4xl md:text-6xl tracking-tighter uppercase leading-none">Focus</h2>
            <span className="font-black text-xl md:text-2xl text-[var(--accent-color)] bg-[var(--text-color)] px-2">LIVE</span>
          </div>
          <CWOSlider items={displayCWO} />
        </section>

        <section id="projects">
          <div className="flex justify-between items-end border-b-[3px] border-[var(--text-color)] pb-2 mb-6">
            <h2 className="font-black text-4xl md:text-6xl tracking-tighter uppercase leading-none">Archive</h2>
          </div>
          
          {/* Asymmetric Grid */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {displayProjects.map((project, index) => (
              <motion.div
                key={project.id}
                className={`strict-border p-6 md:p-8 bg-[var(--card-bg)] flex flex-col justify-between strict-hover cursor-pointer min-h-[250px] ${index % 4 === 0 ? 'md:col-span-2' : 'md:col-span-1'}`}
              >
                <div>
                  <h3 className="font-black text-3xl md:text-5xl leading-none mb-3 tracking-tighter uppercase">{project.title}</h3>
                  <p className="text-base font-bold uppercase tracking-widest border-t-[3px] border-current pt-2 mt-2">{project.subtitle}</p>
                </div>
                <div className="self-end bg-[var(--bg-color)] text-[var(--text-color)] px-3 py-1 strict-border mt-8">
                  <span className="font-black text-2xl leading-none">→</span>
                </div>
              </motion.div>
            ))}
          </div>
          <div className="h-16 md:h-32" />
        </section>
      </main>

      <SiteFooter />
    </>
  );
}
EOF

# 4. CWO Slider (Flat, Thick Borders, Instant Swipes)
echo "⚙️ Writing Flat CWO Slider..."
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
          <div key={item.id} className="min-w-full p-8 md:p-14 flex flex-col gap-4 min-h-[300px] justify-center strict-hover cursor-grab active:cursor-grabbing">
            <div className="flex justify-between items-start">
              <h3 className="font-black text-5xl md:text-7xl tracking-tighter uppercase leading-none">{item.title}</h3>
              <span className="text-sm font-black tracking-widest uppercase bg-[var(--accent-color)] text-black px-3 py-1 strict-border">
                {item.tag}
              </span>
            </div>
            <p className="text-xl md:text-3xl font-bold leading-tight max-w-4xl mt-4">
              {item.description}
            </p>
          </div>
        ))}
      </motion.div>

      <div className="absolute bottom-6 left-6 flex gap-2">
        {items.map((_, i) => (
          <button
            key={i}
            onClick={() => go(i)}
            className={`w-12 h-3 strict-border transition-none ${
              i === current ? 'bg-[var(--accent-color)]' : 'bg-[var(--bg-color)]'
            }`}
          />
        ))}
      </div>
    </div>
  );
}
EOF

echo "✅ Strict Neo-Brutalism Overwritten! Run 'npm run dev' to see it."