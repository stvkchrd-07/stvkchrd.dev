#!/bin/bash

echo "🚀 Initiating 3D Retro-Futuristic Overhaul..."

# 1. Install Required 3D Libraries
echo "📦 Installing Three.js and React-Three-Fiber..."
npm install three @types/three @react-three/fiber @react-three/drei

# 2. Update Global Styles for Retro-Futurism
echo "🎨 Applying Cyber-Void Color Palette..."
cat << 'EOF' > styles/globals.css
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
    --bg-color: #02040A; /* Deep Cyber Void */
    --text-color: #E2E8F0; /* Sharp Silver */
    --card-bg: rgba(2, 4, 10, 0.6);
    --brutalist-hover-bg: #00F0FF; /* Neon Cyan */
    --brutalist-hover-text: #02040A;
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
    /* Subtle CRT glow behind main content */
    text-shadow: 0 0 2px rgba(226, 232, 240, 0.3);
}

.brutalist-hover { transition: all 0.2s ease-out; }
.brutalist-hover:hover {
    background-color: var(--brutalist-hover-bg) !important;
    color: var(--brutalist-hover-text) !important;
    box-shadow: 0 0 15px rgba(0, 240, 255, 0.5);
    border-color: var(--brutalist-hover-bg) !important;
}

/* CRT Scanline Overlay */
.scanlines {
    position: fixed;
    top: 0; left: 0; width: 100vw; height: 100vh;
    background: linear-gradient(rgba(18, 16, 16, 0) 50%, rgba(0, 0, 0, 0.25) 50%), linear-gradient(90deg, rgba(255, 0, 0, 0.06), rgba(0, 255, 0, 0.02), rgba(0, 0, 255, 0.06));
    background-size: 100% 4px, 6px 100%;
    z-index: 9999;
    pointer-events: none;
    opacity: 0.4;
}
EOF

# 3. Create the Quirky Interactive 3D Background
echo "🌌 Building Gyroscopic 3D Background..."
cat << 'EOF' > components/CanvasBackground.tsx
'use client';

import { useRef, useEffect, useState } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { Float, Stars } from '@react-three/drei';
import * as THREE from 'three';

function FloatingShapes() {
  const groupRef = useRef<THREE.Group>(null);
  const [mouse, setMouse] = useState({ x: 0, y: 0 });
  const [gyro, setGyro] = useState({ alpha: 0, beta: 0, gamma: 0 });

  useEffect(() => {
    // Mouse tracking
    const handleMouseMove = (e: MouseEvent) => {
      setMouse({
        x: (e.clientX / window.innerWidth) * 2 - 1,
        y: -(e.clientY / window.innerHeight) * 2 + 1,
      });
    };

    // Gyroscope tracking (Mobile)
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
    if (!groupRef.current) return;
    
    // Smoothly interpolate camera/group rotation based on mouse OR gyro
    const targetX = gyro.beta ? gyro.beta * 0.01 : mouse.y * 0.5;
    const targetY = gyro.gamma ? gyro.gamma * 0.01 : mouse.x * 0.5;

    groupRef.current.rotation.x = THREE.MathUtils.lerp(groupRef.current.rotation.x, targetX, 0.05);
    groupRef.current.rotation.y = THREE.MathUtils.lerp(groupRef.current.rotation.y, targetY, 0.05);
  });

  return (
    <group ref={groupRef}>
      <Stars radius={100} depth={50} count={3000} factor={4} saturation={1} fade speed={1} />
      
      {/* Quirky Floating Geometries */}
      {Array.from({ length: 15 }).map((_, i) => (
        <Float key={i} speed={2} rotationIntensity={2} floatIntensity={3}>
          <mesh position={[(Math.random() - 0.5) * 20, (Math.random() - 0.5) * 20, (Math.random() - 0.5) * -15 - 5]}>
            {i % 3 === 0 ? <torusGeometry args={[1, 0.2, 16, 32]} /> : i % 3 === 1 ? <octahedronGeometry args={[1]} /> : <boxGeometry args={[1, 1, 1]} />}
            <meshStandardMaterial 
              color={i % 2 === 0 ? "#00F0FF" : "#FF003C"} 
              wireframe={i % 2 !== 0}
              emissive={i % 2 === 0 ? "#00F0FF" : "#000000"}
              emissiveIntensity={0.5}
              transparent opacity={0.7}
            />
          </mesh>
        </Float>
      ))}
    </group>
  );
}

export default function CanvasBackground() {
  return (
    <div className="fixed inset-0 z-0 bg-[#02040A] pointer-events-none">
      <Canvas camera={{ position: [0, 0, 5], fov: 75 }}>
        <ambientLight intensity={0.2} />
        <pointLight position={[10, 10, 10]} intensity={1} color="#00F0FF" />
        <FloatingShapes />
      </Canvas>
    </div>
  );
}
EOF

# 4. Create the 3D Ultra-Realistic Loading Computer
echo "🖥️ Rendering 3D Loading Screen..."
cat << 'EOF' > components/LoadingScreen.tsx
'use client';

import { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Canvas, useFrame } from '@react-three/fiber';
import { Environment, Float, ContactShadows } from '@react-three/drei';
import * as THREE from 'three';

// 3D Retro Computer Component
function RetroComputerModel() {
  const groupRef = useRef<THREE.Group>(null);

  useFrame((state) => {
    if (groupRef.current) {
      // Gentle floating and subtle rotation
      groupRef.current.rotation.y = Math.sin(state.clock.elapsedTime * 0.5) * 0.1;
    }
  });

  return (
    <Float speed={2} rotationIntensity={0.2} floatIntensity={0.5}>
      <group ref={groupRef} position={[0, -0.5, 0]}>
        {/* Main Monitor Body */}
        <mesh position={[0, 1.2, 0]}>
          <boxGeometry args={[2.2, 1.8, 2]} />
          <meshStandardMaterial color="#b5b0a1" roughness={0.6} metalness={0.2} />
        </mesh>
        
        {/* Bezel */}
        <mesh position={[0, 1.2, 1.05]}>
          <boxGeometry args={[1.9, 1.5, 0.1]} />
          <meshStandardMaterial color="#8a867b" roughness={0.8} />
        </mesh>

        {/* Ultra-Realistic Glowing CRT Screen */}
        <mesh position={[0, 1.2, 1.06]}>
          <planeGeometry args={[1.7, 1.3]} />
          <meshStandardMaterial 
            color="#000000" 
            emissive="#00F0FF" 
            emissiveIntensity={1.5}
            toneMapped={false}
          />
        </mesh>

        {/* Base / Neck */}
        <mesh position={[0, 0.2, 0]}>
          <cylinderGeometry args={[0.3, 0.5, 0.4, 32]} />
          <meshStandardMaterial color="#8a867b" roughness={0.7} />
        </mesh>
        <mesh position={[0, 0, 0]}>
          <boxGeometry args={[1.5, 0.1, 1.5]} />
          <meshStandardMaterial color="#b5b0a1" roughness={0.6} />
        </mesh>
      </group>
    </Float>
  );
}

export default function LoadingScreen() {
  const [progress, setProgress] = useState(0);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const duration = 2500; // Increased to 2.5s so we can enjoy the 3D model
    const intervalTime = 25;
    const steps = duration / intervalTime;
    let currentStep = 0;

    const timer = setInterval(() => {
      currentStep++;
      setProgress(Math.min(100, Math.floor((currentStep / steps) * 100)));
      
      if (currentStep >= steps) {
        clearInterval(timer);
        setTimeout(() => setIsLoading(false), 400);
      }
    }, intervalTime);

    return () => clearInterval(timer);
  }, []);

  return (
    <AnimatePresence>
      {isLoading && (
        <motion.div
          initial={{ opacity: 1 }}
          exit={{ opacity: 0, transition: { duration: 0.8, ease: "easeInOut" } }}
          className="fixed inset-0 z-[999] bg-[#02040A] flex flex-col items-center justify-center pointer-events-none"
        >
          {/* 3D Canvas for Computer */}
          <div className="w-full h-64 md:h-96 relative">
            <Canvas camera={{ position: [0, 1, 5], fov: 45 }}>
              <ambientLight intensity={0.5} />
              <spotLight position={[10, 10, 10]} angle={0.15} penumbra={1} intensity={1} castShadow />
              <RetroComputerModel />
              <Environment preset="city" />
              <ContactShadows position={[0, -1, 0]} opacity={0.4} scale={10} blur={2} far={4} />
            </Canvas>
          </div>

          {/* Loading Bar */}
          <div className="w-64 md:w-96 mt-4">
            <div className="flex justify-between mb-2 font-black text-[#00F0FF] tracking-widest text-xs uppercase drop-shadow-[0_0_5px_rgba(0,240,255,0.8)]">
              <span>Booting Protocol_</span>
              <span>{progress}%</span>
            </div>
            <div className="h-2 w-full border-2 border-[#00F0FF] p-[2px] shadow-[0_0_10px_rgba(0,240,255,0.3)]">
              <motion.div 
                className="h-full bg-[#00F0FF]"
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

# 5. Add CRT Scanlines to Layout
echo "📺 Adding CRT Filter to Root..."
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
        <div className="scanlines" /> {/* Retro CRT Filter overlay */}
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

echo "✅ 3D Retro-Futuristic Upgrade Complete!"
echo "⚠️ IMPORTANT: Wait for npm to finish installing, then run 'npm run dev'"