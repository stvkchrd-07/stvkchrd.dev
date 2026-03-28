#!/bin/bash

echo "⬛ Finalizing Clean Neo-Brutalist System & Rao AI Interface..."

# 1. Global Styles (Clean Colors & Strict Shadows)
echo "🎨 Writing Global Styles..."
cat << 'EOF' > styles/globals.css
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
    --bg-color: #FAFAFA;
    --text-color: #000000;
    --card-bg: #FFFFFF;
    --accent-color: #2563EB; /* Clean Cobalt Blue */
}

body.dark {
    --bg-color: #121212;
    --text-color: #FFFFFF;
    --card-bg: #1A1A1A;
    --accent-color: #00E5FF; /* Crisp Electric Cyan */
}

body {
    font-family: 'Inter', sans-serif;
    background-color: var(--bg-color);
    color: var(--text-color);
    overflow-x: hidden;
    line-height: 1.6;
}

* { border-radius: 0 !important; }

.content-wrapper {
    position: relative;
    z-index: 1;
}

/* Tighter, Stricter Neo-Brutalist Shadows */
.neo-border {
    border: 2px solid var(--text-color);
}

.neo-shadow {
    box-shadow: 4px 4px 0px var(--text-color);
    transition: transform 0.1s ease-out, box-shadow 0.1s ease-out, background-color 0.1s ease-out;
}

.neo-shadow:hover {
    transform: translate(-2px, -2px);
    box-shadow: 6px 6px 0px var(--text-color);
    background-color: var(--accent-color);
    color: #000000 !important;
}

.neo-shadow:active {
    transform: translate(2px, 2px);
    box-shadow: 2px 2px 0px var(--text-color);
}
EOF

# 2. Canvas Background (3D Particles)
echo "🌌 Writing 3D Canvas Background..."
cat << 'EOF' > components/CanvasBackground.tsx
'use client';

import { useRef, useEffect, useState, useMemo } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import * as THREE from 'three';

function ParticleField() {
  const pointsRef = useRef<THREE.Points>(null);
  const [mouse, setMouse] = useState({ x: 0, y: 0 });
  const [gyro, setGyro] = useState({ alpha: 0, beta: 0, gamma: 0 });

  const [positions, phases] = useMemo(() => {
    const pos = new Float32Array(2000 * 3);
    const ph = new Float32Array(2000);
    for (let i = 0; i < 2000; i++) {
      pos[i * 3] = (Math.random() - 0.5) * 15;
      pos[i * 3 + 1] = (Math.random() - 0.5) * 15;
      pos[i * 3 + 2] = (Math.random() - 0.5) * 15;
      ph[i] = Math.random() * Math.PI * 2;
    }
    return [pos, ph];
  }, []);

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      setMouse({
        x: (e.clientX / window.innerWidth) * 2 - 1,
        y: -(e.clientY / window.innerHeight) * 2 + 1,
      });
    };

    const handleOrientation = (e: DeviceOrientationEvent) => {
      if (e.beta && e.gamma) {
        setGyro({ alpha: e.alpha || 0, beta: e.beta, gamma: e.gamma });
      }
    };

    window.addEventListener('mousemove', handleMouseMove);
    window.addEventListener('deviceorientation', handleOrientation);
    return () => {
      window.removeEventListener('mousemove', handleMouseMove);
      window.removeEventListener('deviceorientation', handleOrientation);
    };
  }, []);

  useFrame((state) => {
    if (!pointsRef.current) return;
    const positionsAttr = pointsRef.current.geometry.attributes.position;
    for (let i = 0; i < 2000; i++) {
      positionsAttr.getY(i); 
      const x = positionsAttr.getX(i);
      const z = positionsAttr.getZ(i);
      positionsAttr.setY(i, Math.sin(state.clock.elapsedTime * 0.5 + x + z) * 0.5 + (Math.sin(phases[i]) * 5));
    }
    positionsAttr.needsUpdate = true;
    const targetX = gyro.beta ? gyro.beta * 0.01 : mouse.y * 0.2;
    const targetY = gyro.gamma ? gyro.gamma * 0.01 : mouse.x * 0.2;
    pointsRef.current.rotation.x = THREE.MathUtils.lerp(pointsRef.current.rotation.x, targetX, 0.05);
    pointsRef.current.rotation.y = THREE.MathUtils.lerp(pointsRef.current.rotation.y, targetY + state.clock.elapsedTime * 0.05, 0.05);
  });

  return (
    <points ref={pointsRef}>
      <bufferGeometry>
        <bufferAttribute attach="attributes-position" count={2000} array={positions} itemSize={3} />
      </bufferGeometry>
      <pointsMaterial size={0.03} color="#888888" transparent opacity={0.6} sizeAttenuation={true} />
    </points>
  );
}

export default function CanvasBackground() {
  return (
    <div className="fixed inset-0 z-0 bg-transparent pointer-events-none">
      <Canvas camera={{ position: [0, 0, 5], fov: 60 }}>
        <ParticleField />
      </Canvas>
    </div>
  );
}
EOF

# 3. Clean Layout
echo "🗂️ Writing Root Layout..."
cat << 'EOF' > app/layout.tsx
import type { Metadata } from 'next';
import { Inter, Lora } from 'next/font/google';
import CanvasBackground from '@/components/CanvasBackground';
import LoadingScreen from '@/components/LoadingScreen';
import '@/styles/globals.css';

const inter = Inter({ subsets: ['latin'], weight: ['400', '700', '900'], variable: '--font-inter' });
const lora = Lora({ subsets: ['latin'], weight: ['400', '600'], variable: '--font-lora' });

export const metadata: Metadata = {
  title: 'Satvik Chaturvedi',
  description: 'Satvik Chaturvedi — builder, founder, experimenter.'
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className={`${inter.variable} ${lora.variable} font-sans p-4 md:p-8 dark`}>
        <LoadingScreen />
        <CanvasBackground />
        <div className="content-wrapper max-w-7xl mx-auto">
          {children}
        </div>
      </body>
    </html>
  );
}
EOF

# 4. Loading Screen
echo "⏳ Writing Loading Screen..."
cat << 'EOF' > components/LoadingScreen.tsx
'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

export default function LoadingScreen() {
  const [progress, setProgress] = useState(0);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const duration = 1000;
    const intervalTime = 15;
    const steps = duration / intervalTime;
    let currentStep = 0;

    const timer = setInterval(() => {
      currentStep++;
      setProgress(Math.min(100, Math.floor((currentStep / steps) * 100)));
      if (currentStep >= steps) {
        clearInterval(timer);
        setTimeout(() => setIsLoading(false), 200);
      }
    }, intervalTime);
    return () => clearInterval(timer);
  }, []);

  return (
    <AnimatePresence>
      {isLoading && (
        <motion.div
          initial={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -20, transition: { duration: 0.3, ease: "easeIn" } }}
          className="fixed inset-0 z-[999] bg-[var(--bg-color)] flex flex-col items-center justify-center pointer-events-none"
        >
          <div className="w-56 md:w-72">
            <h1 className="font-black text-5xl md:text-6xl tracking-tighter mb-3 text-center">
              {progress}%
            </h1>
            <div className="h-3 w-full neo-border bg-[var(--card-bg)] p-0.5">
              <motion.div 
                className="h-full bg-[var(--text-color)]"
                initial={{ width: 0 }}
                animate={{ width: `${progress}%` }}
                transition={{ duration: 0.1, ease: "linear" }}
              />
            </div>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
EOF

# 5. Site Header
echo "⛓️ Writing Site Header..."
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

  const strictAnim = { duration: 0.1, ease: "easeOut" as const };

  return (
    <>
      <header className="mb-10 md:mb-16">
        <div className="flex flex-row justify-between items-center border-b-2 border-[var(--text-color)] pb-3 mb-4">
          <Link href="/" className="site-name hover:underline transition-all duration-300 font-black text-2xl md:text-3xl tracking-tight">
            Satvik Chaturvedi
          </Link>

          <nav className="hidden md:block">
            <ul className="flex space-x-2 text-sm md:text-base">
              {['X', 'in', '@'].map((item, idx) => {
                const links = ['https://x.com/StvkChrd', 'https://www.linkedin.com/in/stvkchrd', 'mailto:satvikc73@gmail.com'];
                return (
                  <motion.li key={item} whileHover={{ y: -2 }} whileTap={{ y: 2 }} transition={strictAnim}>
                    <a href={links[idx]} target={item === '@' ? '_self' : '_blank'} rel="noopener" className="block border-2 border-[var(--text-color)] px-3 py-2 font-bold hover:bg-[var(--accent-color)] hover:text-black transition-colors duration-100">
                      {item}
                    </a>
                  </motion.li>
                );
              })}
              <motion.li whileHover={{ y: -2 }} whileTap={{ y: 2 }} transition={strictAnim}>
                <Link href="/blog" className="block border-2 border-[var(--text-color)] px-4 py-2 font-bold hover:bg-[var(--accent-color)] hover:text-black transition-colors duration-100" style={active === 'blog' ? { background: 'var(--text-color)', color: 'var(--bg-color)' } : undefined}>
                  BLOG
                </Link>
              </motion.li>
              <motion.li whileHover={{ y: -2 }} whileTap={{ y: 2 }} transition={strictAnim}>
                <button onClick={() => setRaoOpen(true)} className="block border-2 border-[var(--text-color)] px-4 py-2 font-bold hover:bg-[var(--accent-color)] hover:text-black transition-colors duration-100">
                  RAO AI ✦
                </button>
              </motion.li>
              <li><ThemeToggle /></li>
            </ul>
          </nav>

          <div className="flex items-center space-x-2 md:hidden text-sm">
            <ThemeToggle />
            <motion.button 
              whileTap={{ y: 2 }}
              onClick={() => setMenuOpen(!menuOpen)}
              className="border-2 border-[var(--text-color)] px-3 py-2 font-bold"
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
              <ul className="flex flex-col text-sm">
                <Link href="/blog" className="p-3 font-black border-b border-[var(--text-color)] text-left w-full hover:bg-[var(--text-color)] hover:text-[var(--bg-color)] transition-colors">BLOG</Link>
                <button onClick={() => { setRaoOpen(true); setMenuOpen(false); }} className="p-3 font-black text-left w-full hover:bg-[var(--text-color)] hover:text-[var(--bg-color)] transition-colors">RAO AI ✦</button>
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

# 6. Rao AI Modal (NEW: Aesthetic Voice Interface)
echo "🎙️ Writing Rao AI Voice Interface..."
cat << 'EOF' > components/RaoModal.tsx
'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

export default function RaoModal({ isOpen, onClose }: { isOpen: boolean, onClose: () => void }) {
  const [isListening, setIsListening] = useState(false);

  // Stop listening if modal closes
  useEffect(() => {
    if (!isOpen) setIsListening(false);
  }, [isOpen]);

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="fixed inset-0 z-[1000] flex items-center justify-center bg-[var(--bg-color)]/80 backdrop-blur-md p-4"
        >
          {/* Click background to close */}
          <div className="absolute inset-0" onClick={onClose} />
          
          <motion.div
            initial={{ scale: 0.95, y: 10 }}
            animate={{ scale: 1, y: 0 }}
            exit={{ scale: 0.95, y: 10 }}
            transition={{ duration: 0.15, ease: "easeOut" }}
            className="relative w-full max-w-sm bg-[var(--card-bg)] neo-border neo-shadow flex flex-col overflow-hidden"
            onClick={(e) => e.stopPropagation()} // Prevent closing when clicking inside modal
          >
            {/* Modal Header */}
            <div className="border-b-2 border-[var(--text-color)] p-3 flex justify-between items-center bg-[var(--text-color)] text-[var(--bg-color)]">
              <h3 className="font-black tracking-widest uppercase text-xs">RAO AI // Comms</h3>
              <button onClick={onClose} className="font-black hover:text-[var(--accent-color)] transition-colors">✕</button>
            </div>

            {/* Modal Body - Voice Visualizer */}
            <div className="p-8 flex flex-col items-center justify-center min-h-[220px] relative">
              <div className="flex items-end justify-center gap-2 h-16 mb-6">
                {[1, 2, 3, 4, 5].map((i) => (
                  <motion.div
                    key={i}
                    animate={{ height: isListening ? ['20%', '100%', '20%'] : '10%' }}
                    transition={{ 
                      repeat: Infinity, 
                      duration: isListening ? 0.4 + (i % 3) * 0.15 : 1, 
                      ease: "easeInOut" 
                    }}
                    className={`w-4 border-2 border-[var(--text-color)] ${isListening ? 'bg-[var(--accent-color)]' : 'bg-[var(--bg-color)]'}`}
                  />
                ))}
              </div>
              <p className="font-bold uppercase tracking-widest text-xs opacity-70">
                {isListening ? "Listening for input..." : "System Idle"}
              </p>
            </div>

            {/* Modal Footer - Controls */}
            <div className="p-4 border-t-2 border-[var(--text-color)] bg-[var(--bg-color)] flex justify-center">
              <button
                onClick={() => setIsListening(!isListening)}
                className={`w-full py-3 font-black uppercase tracking-widest text-sm neo-border neo-shadow transition-colors duration-100 ${
                  isListening 
                    ? 'bg-red-500 text-black border-black shadow-[4px_4px_0px_#000]' 
                    : 'bg-[var(--text-color)] text-[var(--bg-color)] hover:bg-[var(--accent-color)] hover:text-black'
                }`}
              >
                {isListening ? 'Terminate Connection' : 'Initialize Mic'}
              </button>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
EOF

# 7. Home Page
echo "🏠 Writing Home Page..."
cat << 'EOF' > app/page.tsx
import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import CWOSlider from '@/components/CWOSlider';
import { createServerSupabaseClient } from '@/lib/supabase/server';
import * as motion from "framer-motion/client";

const sampleCWO = [
  { id: 1, title: 'TheCommonCo', tag: 'Streetwear / Merch', description: 'Scaling bulk corporate merch orders. Working on overseas pricing models and influencer outreach campaigns.', status: 'Active' },
  { id: 2, title: 'Sirenn', tag: 'Luxury Streetwear', description: 'Building the brand identity and early product line for a future luxury streetwear label.', status: 'Building' }
];

const sampleProjects = [
  { id: 1, title: 'Portfolio Website', subtitle: '2025 — Personal Website', description: '', imageUrl: '', liveUrl: '#' },
  { id: 2, title: 'Sample Project', subtitle: '2025 — Web App', description: '', imageUrl: '', liveUrl: '#' },
  { id: 3, title: 'UtilityHub', subtitle: '2026 — Browser Utilities', description: '', imageUrl: '', liveUrl: '#' },
  { id: 4, title: 'Toefury', subtitle: '2025 — E-commerce', description: '', imageUrl: '', liveUrl: '#' }
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
      <p className="font-bold uppercase tracking-wider opacity-80 text-xs mb-10 neo-border inline-block px-3 py-1.5 bg-[var(--accent-color)] text-black">
        Pivot &middot; Experiment &middot; Ship &middot; Scale
      </p>

      <main className="grid grid-cols-1 gap-12 md:gap-16">
        <section id="currently-working-on">
          <h2 className="font-black text-3xl md:text-4xl mb-6 tracking-tight uppercase">Currently Working On</h2>
          <CWOSlider items={displayCWO} />
        </section>

        <section id="projects">
          <h2 className="font-black text-3xl md:text-4xl mb-6 tracking-tight uppercase">Projects</h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {displayProjects.map((project) => (
              <motion.div
                key={project.id}
                className="aspect-square flex flex-col justify-between neo-border neo-shadow p-5 md:p-6 bg-[var(--card-bg)] cursor-pointer group"
              >
                <div>
                  <h3 className="font-black text-2xl leading-tight mb-1 tracking-tight group-hover:text-black transition-colors duration-100">{project.title}</h3>
                  <p className="text-xs md:text-sm font-bold opacity-80 uppercase tracking-widest group-hover:text-black transition-colors duration-100">{project.subtitle}</p>
                </div>
                <div className="self-end bg-[var(--text-color)] text-[var(--bg-color)] p-1.5 group-hover:bg-black group-hover:text-[var(--accent-color)] transition-colors duration-100">
                  <span className="font-black text-lg leading-none">↗</span>
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

# 8. CWO Slider
echo "⚙️ Writing CWO Slider..."
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
    <div className="relative overflow-hidden neo-border neo-shadow group bg-[var(--card-bg)]">
      <motion.div 
        className="flex"
        animate={{ x: `-${current * 100}%` }}
        transition={{ duration: 0.25, ease: "easeOut" }}
        onTouchStart={onTouchStart}
        onTouchEnd={onTouchEnd}
      >
        {items.map((item) => (
          <div key={item.id} className="min-w-full p-6 md:p-10 flex flex-col gap-3 min-h-[200px] justify-center group-hover:text-black transition-colors duration-100">
            <span className="text-xs font-black tracking-widest uppercase bg-[var(--text-color)] text-[var(--bg-color)] px-2 py-1 w-max group-hover:bg-black group-hover:text-[var(--accent-color)] transition-colors duration-100">
              {item.tag}
            </span>
            <h3 className="font-black text-3xl md:text-4xl tracking-tight">{item.title}</h3>
            <p className="text-sm md:text-base font-medium leading-relaxed max-w-2xl mt-1 flex-1">
              {item.description}
            </p>
            {item.status && (
              <span className="inline-block mt-2 px-3 py-1.5 text-xs font-black uppercase tracking-widest neo-border w-max bg-[var(--bg-color)] text-[var(--text-color)] group-hover:border-black group-hover:text-black transition-colors duration-100">
                {item.status}
              </span>
            )}
          </div>
        ))}
      </motion.div>

      <div className="absolute bottom-4 left-0 right-0 flex justify-center gap-3">
        {items.map((_, i) => (
          <button
            key={i}
            onClick={() => go(i)}
            className={`w-3 h-3 neo-border transition-colors duration-100 ${
              i === current ? 'bg-[var(--text-color)]' : 'bg-transparent'
            }`}
          />
        ))}
      </div>
    </div>
  );
}
EOF

echo "✅ Final Script Applied successfully! Delete '.next' and run 'npm run dev'."