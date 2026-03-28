#!/bin/bash

echo "🟨 Initiating Neo-Brutalist Aesthetic Override..."

# 1. Update Global Styles (Neo-Brutalism: High Contrast, Hard Shadows)
echo "🎨 Applying Neo-Brutalist CSS..."
cat << 'EOF' > styles/globals.css
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
    --bg-color: #FAFAFA; /* Harsh paper white */
    --text-color: #000000; /* Pitch black */
    --card-bg: #FFFFFF;
    --accent-color: #FFE600; /* Neo-brutalist Yellow accent */
}

body.dark {
    --bg-color: #121212;
    --text-color: #FFFFFF;
    --card-bg: #1E1E1E;
    --accent-color: #FF3366; /* Neo-brutalist Pink accent for dark mode */
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

/* Neo-Brutalist Hard Shadows & Interactions */
.neo-border {
    border: 3px solid var(--text-color);
}

.neo-shadow {
    box-shadow: 6px 6px 0px var(--text-color);
    transition: all 0.15s ease-out;
}

.neo-shadow:hover {
    transform: translate(-2px, -2px);
    box-shadow: 8px 8px 0px var(--text-color);
    background-color: var(--accent-color);
    color: #000000;
}

.neo-shadow:active {
    transform: translate(4px, 4px);
    box-shadow: 2px 2px 0px var(--text-color);
}
EOF

# 2. Re-implement 3D Particles (Flowing + Gyro)
echo "🌌 Building Gyroscopic Particle Flow..."
cat << 'EOF' > components/CanvasBackground.tsx
'use client';

import { useRef, useEffect, useState, useMemo } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import * as THREE from 'three';

function ParticleField() {
  const pointsRef = useRef<THREE.Points>(null);
  const [mouse, setMouse] = useState({ x: 0, y: 0 });
  const [gyro, setGyro] = useState({ alpha: 0, beta: 0, gamma: 0 });

  // Generate 2000 random particles
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
    
    // Wave animation for particles
    const positionsAttr = pointsRef.current.geometry.attributes.position;
    for (let i = 0; i < 2000; i++) {
      positionsAttr.getY(i); // Read
      const x = positionsAttr.getX(i);
      const z = positionsAttr.getZ(i);
      // Create a flowing wave effect
      positionsAttr.setY(i, Math.sin(state.clock.elapsedTime * 0.5 + x + z) * 0.5 + (Math.sin(phases[i]) * 5));
    }
    positionsAttr.needsUpdate = true;

    // Gyro & Mouse Camera tracking
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

# 3. Clean up Layout (Remove CRT Scanlines)
echo "🗂️ Removing Cyberpunk Overlays..."
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

# 4. Neo-Brutalist Loading Screen
echo "⏳ Stripping down Loading Screen..."
cat << 'EOF' > components/LoadingScreen.tsx
'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

export default function LoadingScreen() {
  const [progress, setProgress] = useState(0);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const duration = 1200; // Fast, aggressive load
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
          exit={{ opacity: 0, y: -50, transition: { duration: 0.4, ease: "easeIn" } }}
          className="fixed inset-0 z-[999] bg-[var(--bg-color)] flex flex-col items-center justify-center pointer-events-none"
        >
          <div className="w-72 md:w-96">
            <h1 className="font-black text-6xl md:text-8xl tracking-tighter mb-4 text-center">
              {progress}%
            </h1>
            <div className="h-4 w-full neo-border bg-[var(--card-bg)] p-1">
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

# 5. Apply Neo-Brutalism to Home Page Cards
echo "🏠 Upgrading Project Cards to Neo-Brutalism..."
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

  const { data: projects } = await supabase
    .from('projects').select('*').order('id', { ascending: false });

  const { data: workingOn } = await supabase
    .from('working_on').select('*').order('id', { ascending: false });

  const displayProjects = projects && projects.length > 0 ? projects : sampleProjects;
  const displayCWO = workingOn && workingOn.length > 0 ? workingOn : sampleCWO;

  return (
    <>
      <SiteHeader active="home" />
      <p className="font-black uppercase tracking-widest opacity-80 text-sm mb-12 neo-border inline-block p-2 bg-[var(--accent-color)] text-black">
        Pivot &middot; Experiment &middot; Ship &middot; Scale
      </p>

      <main className="grid grid-cols-1 gap-16 md:gap-24">
        
        <section id="currently-working-on">
          <h2 className="font-black text-4xl md:text-6xl mb-8 tracking-tighter uppercase">Currently Working On</h2>
          <CWOSlider items={displayCWO} />
        </section>

        <section id="projects">
          <h2 className="font-black text-4xl md:text-6xl mb-8 tracking-tighter uppercase">Projects</h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
            {displayProjects.map((project) => (
              <motion.div
                key={project.id}
                className="aspect-square flex flex-col justify-between neo-border neo-shadow p-6 md:p-8 bg-[var(--card-bg)] cursor-pointer"
              >
                <div>
                  <h3 className="font-black text-3xl leading-tight mb-2 tracking-tighter">{project.title}</h3>
                  <p className="text-sm md:text-base font-bold opacity-80 uppercase tracking-widest">{project.subtitle}</p>
                </div>
                <div className="self-end bg-[var(--text-color)] text-[var(--bg-color)] p-2">
                  <span className="font-black text-2xl leading-none">↗</span>
                </div>
              </motion.div>
            ))}
          </div>
          <div className="h-24 md:h-48" />
        </section>
      </main>

      <SiteFooter />
    </>
  );
}
EOF

# 6. Apply Neo-Brutalism to CWOSlider
echo "⚙️ Fixing CWO Slider Borders..."
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
    <div className="relative overflow-hidden neo-border neo-shadow group mb-12 bg-[var(--card-bg)]">
      <motion.div 
        className="flex"
        animate={{ x: `-${current * 100}%` }}
        transition={{ duration: 0.3, ease: [0.25, 1, 0.5, 1] }}
        onTouchStart={onTouchStart}
        onTouchEnd={onTouchEnd}
      >
        {items.map((item) => (
          <div key={item.id} className="min-w-full p-8 md:p-12 flex flex-col gap-4 min-h-[250px] justify-center">
            <span className="text-xs font-black tracking-widest uppercase bg-[var(--text-color)] text-[var(--bg-color)] px-3 py-1 w-max">
              {item.tag}
            </span>
            <h3 className="font-black text-4xl md:text-5xl tracking-tighter">{item.title}</h3>
            <p className="text-lg md:text-xl font-medium leading-relaxed max-w-3xl mt-2 flex-1">
              {item.description}
            </p>
            {item.status && (
              <span className="inline-block mt-4 px-4 py-2 text-sm font-black uppercase tracking-widest neo-border w-max bg-[var(--accent-color)] text-black">
                {item.status}
              </span>
            )}
          </div>
        ))}
      </motion.div>

      <div className="absolute bottom-6 left-0 right-0 flex justify-center gap-4">
        {items.map((_, i) => (
          <button
            key={i}
            onClick={() => go(i)}
            className={`w-4 h-4 neo-border transition-colors duration-150 ${
              i === current ? 'bg-[var(--text-color)]' : 'bg-transparent'
            }`}
          />
        ))}
      </div>
    </div>
  );
}
EOF

echo "✅ Neo-Brutalism Restored! Delete your '.next' folder and run 'npm run dev'."