#!/bin/bash

echo "⬛ Starting Heavy Brutalist Upgrade..."

# 1. Update Tailwind Config
echo "🛠️ Configuring Tailwind..."
cat << 'EOF' > tailwind.config.ts
import type { Config } from "tailwindcss";

export default {
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
} satisfies Config;
EOF

# 2. Update Global Styles (Zinc/Paper White & No Fades)
echo "🎨 Updating Colors and Typography..."
cat << 'EOF' > styles/globals.css
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
    --bg-color: #F4F4F5;
    --text-color: #09090B;
    --card-bg: rgba(244, 244, 245, 0.85);
    --brutalist-hover-bg: #09090B;
    --brutalist-hover-text: #F4F4F5;
    --particle-color-value: #09090B;
}

body.dark {
    --bg-color: #09090B;
    --text-color: #FAFAFA;
    --card-bg: rgba(9, 9, 11, 0.85);
    --brutalist-hover-bg: #FAFAFA;
    --brutalist-hover-text: #09090B;
    --particle-color-value: #FAFAFA;
}

body {
    font-family: 'Inter', sans-serif;
    background-color: var(--bg-color);
    color: var(--text-color);
    overflow-x: hidden;
    line-height: 1.6;
}

* { border-radius: 0 !important; }

#bg-canvas {
    position: fixed;
    top: 0; left: 0;
    width: 100%; height: 100%;
    z-index: -1;
}

.content-wrapper {
    position: relative;
    z-index: 1;
}

.brutalist-hover { transition: none; }
.brutalist-hover:hover {
    background-color: var(--brutalist-hover-bg) !important;
    color: var(--brutalist-hover-text) !important;
}
EOF

# 3. Update CWO Slider (Restored CSS + Mechanical Slide)
echo "⚙️ Fixing CWO Slider..."
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
    }, 4000);
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
    <div className="relative overflow-hidden border-2 border-[var(--text-color)] group mb-12">
      <motion.div 
        className="flex"
        animate={{ x: `-${current * 100}%` }}
        transition={{ duration: 0.3, ease: [0.25, 1, 0.5, 1] }}
        onTouchStart={onTouchStart}
        onTouchEnd={onTouchEnd}
      >
        {items.map((item) => (
          <div key={item.id} className="min-w-full p-8 md:p-10 bg-[var(--card-bg)] flex flex-col gap-3 min-h-[220px] justify-center">
            <span className="text-xs font-black tracking-[0.15em] uppercase opacity-60">
              {item.tag}
            </span>
            <h3 className="font-black text-3xl md:text-4xl">{item.title}</h3>
            <p className="text-base md:text-lg leading-relaxed opacity-90 max-w-3xl mt-2 flex-1">
              {item.description}
            </p>
            {item.status && (
              <span className="inline-block mt-4 px-4 py-1.5 text-xs font-black uppercase tracking-widest border-2 border-[var(--text-color)] w-max">
                {item.status}
              </span>
            )}
          </div>
        ))}
      </motion.div>

      <div className="absolute bottom-5 left-0 right-0 flex justify-center gap-3">
        {items.map((_, i) => (
          <button
            key={i}
            onClick={() => go(i)}
            className={`w-3 h-3 border-2 border-[var(--text-color)] transition-colors duration-150 ${
              i === current ? 'bg-[var(--text-color)]' : 'bg-transparent'
            }`}
          />
        ))}
      </div>
    </div>
  );
}
EOF

# 4. Update Header (Sharp upward bumps, no scaling)
echo "⛓️ Hardening the Header..."
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

  const brutalAnim = { duration: 0.15, ease: "easeOut" };

  return (
    <>
      <header className="mb-12 md:mb-20">
        <div className="flex flex-row justify-between items-center border-b-2 border-[var(--text-color)] pb-4 mb-4">
          <Link href="/" className="site-name hover:underline transition-all duration-300 font-black text-3xl md:text-4xl">
            Satvik Chaturvedi
          </Link>

          <nav className="hidden md:block">
            <ul className="flex space-x-2">
              {['X', 'in', '@'].map((item, idx) => {
                const links = ['https://x.com/StvkChrd', 'https://www.linkedin.com/in/stvkchrd', 'mailto:satvikc73@gmail.com'];
                return (
                  <motion.li key={item} whileHover={{ y: -4 }} whileTap={{ y: 0 }} transition={brutalAnim}>
                    <a href={links[idx]} target={item === '@' ? '_self' : '_blank'} rel="noopener" className="block border-2 border-[var(--text-color)] p-3 font-bold brutalist-hover">
                      {item}
                    </a>
                  </motion.li>
                );
              })}
              <motion.li whileHover={{ y: -4 }} whileTap={{ y: 0 }} transition={brutalAnim}>
                <Link href="/blog" className="block border-2 border-[var(--text-color)] px-4 py-3 font-bold brutalist-hover" style={active === 'blog' ? { background: 'var(--text-color)', color: 'var(--bg-color)' } : undefined}>
                  BLOG
                </Link>
              </motion.li>
              <motion.li whileHover={{ y: -4 }} whileTap={{ y: 0 }} transition={brutalAnim}>
                <button onClick={() => setRaoOpen(true)} className="block border-2 border-[var(--text-color)] px-4 py-3 font-bold brutalist-hover">
                  RAO AI ✦
                </button>
              </motion.li>
              <li><ThemeToggle /></li>
            </ul>
          </nav>

          <div className="flex items-center space-x-2 md:hidden">
            <ThemeToggle />
            <motion.button 
              whileTap={{ y: 2 }}
              onClick={() => setMenuOpen(!menuOpen)}
              className="border-2 border-[var(--text-color)] p-3 font-bold brutalist-hover"
            >
              {menuOpen ? '✕' : '☰'}
            </motion.button>
          </div>
        </div>

        <AnimatePresence>
          {menuOpen && (
            <motion.div 
              initial={{ height: 0, opacity: 0 }}
              animate={{ height: 'auto', opacity: 1 }}
              exit={{ height: 0, opacity: 0 }}
              className="overflow-hidden border-b-2 border-[var(--text-color)] bg-[var(--bg-color)] md:hidden"
            >
              <ul className="flex flex-col">
                <Link href="/blog" className="p-4 font-black border-b border-[var(--text-color)] text-left w-full hover:bg-[var(--text-color)] hover:text-[var(--bg-color)] transition-colors">BLOG</Link>
                <button onClick={() => { setRaoOpen(true); setMenuOpen(false); }} className="p-4 font-black text-left w-full hover:bg-[var(--text-color)] hover:text-[var(--bg-color)] transition-colors">RAO AI ✦</button>
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

# 5. Update Home Page Cards
echo "🏗️ Updating Home Page Project Cards..."
cat << 'EOF' > app/page.tsx
import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import CWOSlider from '@/components/CWOSlider';
import { createServerSupabaseClient } from '@/lib/supabase/server';
import * as motion from "framer-motion/client";

const sampleCWO = [
  { id: 1, title: 'TheCommonCo', tag: 'Streetwear / Merch', description: 'Scaling bulk corporate merch orders. Working on overseas pricing models and influencer outreach campaigns.', status: 'Active' },
  { id: 2, title: 'Sirenn', tag: 'Luxury Streetwear', description: 'Building the brand identity and early product line for a future luxury streetwear label.', status: 'Building' },
  { id: 3, title: 'SurFlow Events', tag: 'Event Management', description: 'Connecting underrated artists with cafés, restaurants, and corporate venues for curated weekend experiences.', status: 'Active' }
];

const sampleProjects = [
  { id: 1, title: 'Portfolio Website', subtitle: '2025 — Personal Website', description: '', imageUrl: '', liveUrl: '#' },
  { id: 2, title: 'Sample Project', subtitle: '2025 — Web App', description: '', imageUrl: '', liveUrl: '#' }
];

export default async function HomePage() {
  const supabase = createServerSupabaseClient();

  const { data: projects } = await supabase
    .from('projects').select('*').order('id', { ascending: false });

  const { data: workingOn } = await supabase
    .from('working_on').select('*').order('id', { ascending: false });

  const displayProjects = projects && projects.length > 0 ? projects : sampleProjects;
  const displayCWO = workingOn && workingOn.length > 0 ? workingOn : sampleCWO;

  return (
    <>
      <SiteHeader active="home" />
      <p className="pivot-experiment mt-2 font-black uppercase tracking-wide opacity-80">Pivot &middot; Experiment &middot; Ship &middot; Scale</p>

      <main className="grid grid-cols-1 gap-8 md:gap-12 mt-12">
        <section id="currently-working-on" className="mb-4">
          <h2 className="font-black text-4xl md:text-5xl mb-6">Currently Working On</h2>
          <CWOSlider items={displayCWO} />
        </section>

        <section id="projects">
          <h2 className="font-black text-4xl md:text-5xl mb-6">Projects</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {displayProjects.map((project) => (
              <motion.div
                key={project.id}
                whileHover={{ y: -6 }}
                whileTap={{ y: 0 }}
                transition={{ duration: 0.15, ease: "easeOut" }}
                className="border-2 border-[var(--text-color)] p-8 bg-[var(--card-bg)] backdrop-blur-sm cursor-pointer brutalist-hover"
              >
                <h3 className="font-black text-2xl md:text-3xl">{project.title}</h3>
                <p className="mt-2 text-base opacity-80">{project.subtitle}</p>
              </motion.div>
            ))}
          </div>
          <div className="h-32 md:h-64 lg:h-96" />
        </section>
      </main>

      <SiteFooter />
    </>
  );
}
EOF

# 6. Update Page Transition Template
echo "🎞️ Snapping Page Transitions..."
cat << 'EOF' > app/template.tsx
"use client";

import { motion } from "framer-motion";

export default function Template({ children }: { children: React.ReactNode }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 5 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.2, ease: "easeOut" }}
    >
      {children}
    </motion.div>
  );
}
EOF

echo "✅ Brutalist Upgrade Complete! Delete the '.next' folder and run 'npm run dev' to see it."