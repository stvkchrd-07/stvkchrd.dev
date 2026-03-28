#!/bin/bash

echo "🔧 Applying System Fixes (Caching, Gyro, Particles, Admin CSS)..."

# 1. Fix Home Page Caching (Force Dynamic)
echo "⚡ Disabling Next.js Cache on Home Page..."
cat << 'EOF' > app/page.tsx
import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import CWOCard from '@/components/CWOCard';
import { createServerSupabaseClient } from '@/lib/supabase/server';
import * as motion from "framer-motion/client";

// FIX: This forces Next.js to always fetch fresh data from Supabase instead of caching it!
export const dynamic = 'force-dynamic';

export default async function HomePage() {
  const supabase = createServerSupabaseClient();
  const { data: projects } = await supabase.from('projects').select('*').order('id', { ascending: false });
  const { data: workingOn } = await supabase.from('working_on').select('*').order('id', { ascending: false });

  // Fallbacks if DB is empty
  const displayProjects = projects && projects.length > 0 ? projects : [];
  const displayCWO = workingOn && workingOn.length > 0 ? workingOn : [];

  return (
    <>
      <SiteHeader active="home" />
      
      {/* Ultra Minimal Single Line */}
      <div className="mb-10 text-center opacity-40">
        <p className="text-[9px] md:text-[10px] font-bold uppercase tracking-[0.5em] whitespace-nowrap">
          PIVOT &bull; EXPERIMENT &bull; <span className="text-[var(--accent-color)]">SHIP</span> &bull; SCALE
        </p>
      </div>

      <main className="grid grid-cols-1 gap-10 md:gap-14">
        <section id="currently-working-on">
          <div className="flex justify-between items-end border-b-[2px] border-[var(--text-color)] pb-2 mb-4">
            <h2 className="font-black text-2xl md:text-3xl tracking-tighter uppercase leading-none">Focus</h2>
            <span className="font-black text-xs md:text-sm text-[var(--accent-color)] bg-[var(--text-color)] px-2">LIVE</span>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {displayCWO.map(item => (
              <CWOCard key={item.id} item={item} />
            ))}
          </div>
        </section>

        <section id="projects">
          <div className="flex justify-between items-end border-b-[2px] border-[var(--text-color)] pb-2 mb-4">
            <h2 className="font-black text-2xl md:text-3xl tracking-tighter uppercase leading-none">Projects Section</h2>
          </div>
          
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-4">
            {displayProjects.map((project) => (
              <motion.div
                key={project.id}
                className="strict-border p-3 md:p-4 bg-[var(--card-bg)] flex flex-col justify-between strict-hover cursor-pointer aspect-square rounded-xl"
              >
                <div>
                  <h3 className="font-black text-base md:text-lg leading-tight mb-1 tracking-tighter uppercase">{project.title}</h3>
                  <p className="text-[10px] md:text-xs font-bold uppercase tracking-widest border-t-[2px] border-current pt-1 mt-1 opacity-90">{project.subtitle}</p>
                </div>
                <div className="self-end bg-[var(--bg-color)] text-[var(--text-color)] px-2 py-0.5 strict-border mt-2 rounded-lg">
                  <span className="font-black text-xs leading-none">→</span>
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

# 2. Fix 3D Canvas (White Particles + iOS Gyro Security Bypass)
echo "🌌 Upgrading 3D Particles and Mobile Gyro..."
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

    // FIX: iOS 13+ requires explicit permission triggered by a user action
    const requestGyroPermission = () => {
      if (typeof (DeviceOrientationEvent as any).requestPermission === 'function') {
        (DeviceOrientationEvent as any).requestPermission()
          .then((permissionState: string) => {
            if (permissionState === 'granted') {
              window.addEventListener('deviceorientation', handleOrientation);
            }
          })
          .catch(console.error);
      } else {
        // Android or non-iOS devices
        window.addEventListener('deviceorientation', handleOrientation);
      }
    };

    window.addEventListener('mousemove', handleMouseMove);
    
    // Trigger gyro permission on the user's very first click or tap
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
        <bufferAttribute attach="attributes-position" args={[positions, 3]} />
      </bufferGeometry>
      {/* FIX: Pure White particles, 100% opacity, slightly larger (0.05) */}
      <pointsMaterial size={0.05} color="#FFFFFF" transparent opacity={1.0} sizeAttenuation={true} />
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

# 3. Create a Micro-Brutalist Admin Dashboard
echo "🎛️ Styling the Admin Page..."
mkdir -p app/admin
cat << 'EOF' > app/admin/page.tsx
'use client';

import { useState } from 'react';
import Link from 'next/link';
import ThemeToggle from '@/components/ThemeToggle';

export default function AdminDashboard() {
  // Replace this with your actual Supabase auth/data fetching logic
  const [activeTab, setActiveTab] = useState('projects');

  return (
    <div className="min-h-screen bg-[var(--bg-color)] text-[var(--text-color)] p-4 md:p-8 font-sans">
      
      {/* Admin Header */}
      <header className="flex justify-between items-center border-b-[2px] border-[var(--text-color)] pb-4 mb-8">
        <div>
          <h1 className="font-black text-2xl md:text-4xl uppercase tracking-tighter leading-none">SYSTEM_ADMIN</h1>
          <p className="text-xs font-bold uppercase tracking-widest opacity-50 mt-1">Authorized Access Only</p>
        </div>
        <div className="flex gap-2">
          <ThemeToggle />
          <Link href="/" className="strict-border px-4 py-2 font-black uppercase text-xs md:text-sm bg-[var(--text-color)] text-[var(--bg-color)] active:translate-y-0.5">
            EXIT ↗
          </Link>
        </div>
      </header>

      {/* Control Panel Tabs */}
      <div className="flex gap-2 mb-6">
        <button 
          onClick={() => setActiveTab('projects')}
          className={`strict-border px-4 py-2 font-black uppercase text-sm transition-none ${activeTab === 'projects' ? 'bg-[var(--accent-color)] text-black' : 'bg-[var(--bg-color)] text-[var(--text-color)]'}`}
        >
          PROJECTS DB
        </button>
        <button 
          onClick={() => setActiveTab('cwo')}
          className={`strict-border px-4 py-2 font-black uppercase text-sm transition-none ${activeTab === 'cwo' ? 'bg-[var(--accent-color)] text-black' : 'bg-[var(--bg-color)] text-[var(--text-color)]'}`}
        >
          FOCUS DB
        </button>
      </div>

      {/* Content Area - Put your forms here! */}
      <main className="strict-border p-6 md:p-10 bg-[var(--card-bg)] rounded-xl">
        <h2 className="font-black text-xl uppercase border-b-[2px] border-[var(--text-color)] pb-2 mb-6">
          {activeTab === 'projects' ? 'MANAGE PROJECTS' : 'MANAGE CURRENT FOCUS'}
        </h2>
        
        {/* Example Placeholder Form matching the Brutalist aesthetic */}
        <form className="flex flex-col gap-4 max-w-2xl">
          <div className="flex flex-col gap-1">
            <label className="text-xs font-bold uppercase tracking-widest">Title</label>
            <input type="text" className="strict-border p-2 bg-transparent focus:bg-[var(--text-color)] focus:text-[var(--bg-color)] outline-none font-bold" placeholder="PROJECT NAME" />
          </div>
          
          <div className="flex flex-col gap-1">
            <label className="text-xs font-bold uppercase tracking-widest">Description</label>
            <textarea rows={4} className="strict-border p-2 bg-transparent focus:bg-[var(--text-color)] focus:text-[var(--bg-color)] outline-none font-bold resize-none" placeholder="ENTER DETAILS..."></textarea>
          </div>

          <button type="button" className="strict-border self-start px-6 py-3 mt-2 font-black uppercase bg-[var(--accent-color)] text-black active:translate-y-1 active:shadow-none">
            UPLOAD TO SUPABASE
          </button>
        </form>
      </main>

    </div>
  );
}
EOF

echo "✅ System successfully patched! Run 'npm run dev' to test."