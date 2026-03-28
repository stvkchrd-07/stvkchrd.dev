#!/bin/bash

echo "🛠️ Fixing TypeScript Transition Errors..."

# 1. Update SiteHeader.tsx with 'as const'
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

  // Added 'as const' to fix TypeScript string literal errors
  const brutalAnim = { duration: 0.15, ease: "easeOut" as const };

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

# 2. Update page.tsx with 'as const'
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
                transition={{ duration: 0.15, ease: "easeOut" as const }}
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

# 3. Update template.tsx with 'as const'
cat << 'EOF' > app/template.tsx
"use client";

import { motion } from "framer-motion";

export default function Template({ children }: { children: React.ReactNode }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 5 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.2, ease: "easeOut" as const }}
    >
      {children}
    </motion.div>
  );
}
EOF

echo "✅ TypeScript errors fixed! Run 'npm run build' to verify."