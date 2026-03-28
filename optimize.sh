#!/bin/bash

echo "🚀 Installing Smooth Scroll and Optimizing Performance..."

# 1. Install Lenis for Smooth Scrolling
npm install @studio-freight/react-lenis

# 2. Create the Smooth Scroll Wrapper Component
echo "🌊 Building Smooth Scroll Engine..."
cat << 'EOF' > components/SmoothScroll.tsx
'use client';

import { ReactLenis } from '@studio-freight/react-lenis';

export default function SmoothScroll({ children }: { children: React.ReactNode }) {
  return (
    <ReactLenis root options={{ lerp: 0.1, duration: 1.2, smoothWheel: true }}>
      {children}
    </ReactLenis>
  );
}
EOF

# 3. Wrap Layout in Smooth Scroll
echo "🗂️ Integrating Smooth Scroll into Layout..."
cat << 'EOF' > app/layout.tsx
import type { Metadata } from 'next';
import { Inter, Lora } from 'next/font/google';
import CanvasBackground from '@/components/CanvasBackground';
import LoadingScreen from '@/components/LoadingScreen';
import SmoothScroll from '@/components/SmoothScroll';
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
        <SmoothScroll>
          <div className="content-wrapper max-w-7xl mx-auto">
            {children}
          </div>
        </SmoothScroll>
      </body>
    </html>
  );
}
EOF

# 4. Optimize 3D Canvas Background (DPR Clamping)
echo "🌌 Optimizing 3D Canvas Rendering..."
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
        <bufferAttribute attach="attributes-position" args={[positions, 3]} />
      </bufferGeometry>
      <pointsMaterial size={0.03} color="#888888" transparent opacity={0.6} sizeAttenuation={true} />
    </points>
  );
}

export default function CanvasBackground() {
  return (
    <div className="fixed inset-0 z-0 bg-transparent pointer-events-none">
      {/* PERFORMANCE FIX: Clamp DPR to max 1.5 to prevent massive lag on high-res mobile screens */}
      <Canvas camera={{ position: [0, 0, 5], fov: 60 }} dpr={[1, 1.5]} performance={{ min: 0.5 }}>
        <ParticleField />
      </Canvas>
    </div>
  );
}
EOF

# 5. Optimize CWOSlider (Pause on hover/touch)
echo "⚙️ Upgrading Slider Logic (Pause on Hover)..."
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
  const [isPaused, setIsPaused] = useState(false);
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const touchStartX = useRef(0);

  const go = (index: number) => setCurrent(index);

  useEffect(() => {
    // If user is hovering or touching, do not auto-scroll
    if (isPaused) return;

    intervalRef.current = setInterval(() => {
      setCurrent(prev => (prev + 1) % items.length);
    }, 5000);
    
    return () => { if (intervalRef.current) clearInterval(intervalRef.current); };
  }, [items.length, isPaused]);

  const onTouchStart = (e: React.TouchEvent) => { 
    setIsPaused(true);
    touchStartX.current = e.touches[0].clientX; 
  };
  
  const onTouchEnd = (e: React.TouchEvent) => {
    setIsPaused(false);
    const diff = touchStartX.current - e.changedTouches[0].clientX;
    if (Math.abs(diff) > 40) {
      setCurrent(prev => diff > 0 ? Math.min(prev + 1, items.length - 1) : Math.max(prev - 1, 0));
    }
  };

  return (
    <div 
      className="relative overflow-hidden strict-border bg-[var(--card-bg)]"
      onMouseEnter={() => setIsPaused(true)}
      onMouseLeave={() => setIsPaused(false)}
    >
      <motion.div 
        className="flex"
        animate={{ x: `-${current * 100}%` }}
        transition={{ duration: 0.2, ease: "easeInOut" }} /* Smoother slide curve */
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

echo "✅ Optimization Complete! Run 'npm run dev' and try scrolling."