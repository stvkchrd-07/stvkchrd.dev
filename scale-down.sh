#!/bin/bash

echo "📏 Scaling down Neo-Brutalist elements for better readability..."

# 1. Update Global Styles (Thinner 2px border, slightly looser line height for readability)
echo "🎨 Updating Border Weights..."
cat << 'EOF' > styles/globals.css
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
    --bg-color: #FFFFFF;
    --text-color: #000000;
    --card-bg: #FFFFFF;
    --accent-color: #CCFF00; /* High-visibility Neon Yellow */
    --border-weight: 2px; /* Thinned from 3px to match smaller text */
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
    line-height: 1.2; /* Slightly loosened for smaller text readability */
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
    transform: translate(-3px, -3px); /* Slightly smaller shift */
}

.accent-hover:active {
    transform: translate(2px, 2px);
}

::selection {
    background-color: var(--accent-color);
    color: #000000;
}
EOF

# 2. Update Header (Smaller Site Name & Nav Links)
echo "⛓️ Resizing Header..."
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
      <header className="mb-10 md:mb-16">
        <div className="flex flex-row justify-between items-center border-b-[2px] border-[var(--text-color)] pb-3 mb-4">
          <Link href="/" className="site-name font-black text-2xl md:text-3xl uppercase tracking-tighter hover:bg-[var(--accent-color)] hover:text-black transition-none px-2 py-1 -ml-2">
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

          <div className="flex items-center space-x-2 md:hidden text-sm">
            <ThemeToggle />
            <motion.button 
              whileTap={{ y: 2 }}
              onClick={() => setMenuOpen(!menuOpen)}
              className="strict-border px-3 py-1.5 font-black uppercase bg-[var(--accent-color)] text-black"
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
              className="overflow-hidden border-b-[2px] border-[var(--text-color)] bg-[var(--bg-color)] md:hidden"
            >
              <ul className="flex flex-col text-base uppercase">
                <Link href="/blog" className="p-3 font-black border-b-[2px] border-[var(--text-color)] text-left w-full strict-hover">BLOG</Link>
                <button onClick={() => { setRaoOpen(true); setMenuOpen(false); }} className="p-3 font-black text-left w-full bg-[var(--accent-color)] text-black hover:bg-[var(--text-color)] hover:text-[var(--accent-color)] transition-none">RAO AI ✦</button>
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

# 3. Update Home Page (Smaller Headings & Padding)
echo "🏠 Scaling down Home Page Grid..."
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
      
      {/* Statement block - Scaled Down */}
      <div className="mb-12 md:mb-16 strict-border p-5 md:p-8 bg-[var(--text-color)] text-[var(--bg-color)]">
        <h1 className="font-black text-4xl md:text-7xl uppercase tracking-tighter leading-[0.9]">
          PIVOT.<br/>
          EXPERIMENT.<br/>
          <span className="text-[var(--accent-color)]">SHIP.</span> SCALE.
        </h1>
      </div>

      <main className="grid grid-cols-1 gap-12 md:gap-16">
        <section id="currently-working-on">
          <div className="flex justify-between items-end border-b-[2px] border-[var(--text-color)] pb-2 mb-5">
            <h2 className="font-black text-3xl md:text-5xl tracking-tighter uppercase leading-none">Focus</h2>
            <span className="font-black text-lg md:text-xl text-[var(--accent-color)] bg-[var(--text-color)] px-2">LIVE</span>
          </div>
          <CWOSlider items={displayCWO} />
        </section>

        <section id="projects">
          <div className="flex justify-between items-end border-b-[2px] border-[var(--text-color)] pb-2 mb-5">
            <h2 className="font-black text-3xl md:text-5xl tracking-tighter uppercase leading-none">Archive</h2>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
            {displayProjects.map((project, index) => (
              <motion.div
                key={project.id}
                className={`strict-border p-5 md:p-6 bg-[var(--card-bg)] flex flex-col justify-between strict-hover cursor-pointer min-h-[200px] ${index % 4 === 0 ? 'md:col-span-2' : 'md:col-span-1'}`}
              >
                <div>
                  <h3 className="font-black text-2xl md:text-4xl leading-none mb-2 tracking-tighter uppercase">{project.title}</h3>
                  <p className="text-sm font-bold uppercase tracking-widest border-t-[2px] border-current pt-2 mt-2">{project.subtitle}</p>
                </div>
                <div className="self-end bg-[var(--bg-color)] text-[var(--text-color)] px-2 py-1 strict-border mt-6">
                  <span className="font-black text-xl leading-none">→</span>
                </div>
              </motion.div>
            ))}
          </div>
          <div className="h-16 md:h-24" />
        </section>
      </main>

      <SiteFooter />
    </>
  );
}
EOF

# 4. Update CWOSlider (Tighter Padding, Smaller Text)
echo "⚙️ Resizing Focus Slider..."
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
          <div key={item.id} className="min-w-full p-6 md:p-10 flex flex-col gap-3 min-h-[240px] justify-center strict-hover cursor-grab active:cursor-grabbing">
            <div className="flex justify-between items-start">
              <h3 className="font-black text-4xl md:text-5xl tracking-tighter uppercase leading-none">{item.title}</h3>
              <span className="text-xs font-black tracking-widest uppercase bg-[var(--accent-color)] text-black px-2 py-1 strict-border">
                {item.tag}
              </span>
            </div>
            <p className="text-lg md:text-xl font-bold leading-snug max-w-3xl mt-3">
              {item.description}
            </p>
          </div>
        ))}
      </motion.div>

      <div className="absolute bottom-4 left-5 flex gap-2">
        {items.map((_, i) => (
          <button
            key={i}
            onClick={() => go(i)}
            className={`w-8 h-2 strict-border transition-none ${
              i === current ? 'bg-[var(--accent-color)]' : 'bg-[var(--bg-color)]'
            }`}
          />
        ))}
      </div>
    </div>
  );
}
EOF

echo "✅ UI successfully scaled down! Run 'npm run dev' to view the crisp, readable layout."