#!/bin/bash

echo "🌐 Initiating Futuristic Aesthetic Protocol..."

# 1. Update Global Styles (Tech Colors + Stripe Pattern)
echo "🎨 Updating Colors and Background Patterns..."
cat << 'EOF' > styles/globals.css
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
    --bg-color: #F8F9FA; /* Tech Silver / Off-white */
    --text-color: #0B0C10; /* Deep Void Black */
    --card-bg: rgba(248, 249, 250, 0.85);
    --brutalist-hover-bg: #0B0C10;
    --brutalist-hover-text: #F8F9FA;
}

body.dark {
    --bg-color: #0B0C10; /* Deep Void Black */
    --text-color: #E2E8F0; /* Soft Slate White */
    --card-bg: rgba(11, 12, 16, 0.85);
    --brutalist-hover-bg: #E2E8F0;
    --brutalist-hover-text: #0B0C10;
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

.brutalist-hover { transition: none; }
.brutalist-hover:hover {
    background-color: var(--brutalist-hover-bg) !important;
    color: var(--brutalist-hover-text) !important;
}

/* New Futuristic Striped/Grid Background */
.striped-pattern {
    position: fixed;
    inset: 0;
    z-index: -1;
    background-image: 
        linear-gradient(to right, var(--text-color) 1px, transparent 1px),
        linear-gradient(to bottom, var(--text-color) 1px, transparent 1px);
    background-size: 60px 60px;
    opacity: 0.06; /* Very subtle so it doesn't distract */
    /* Fades out the grid at the bottom of the screen */
    mask-image: linear-gradient(to bottom, black 30%, transparent 100%);
    -webkit-mask-image: linear-gradient(to bottom, black 30%, transparent 100%);
    pointer-events: none;
}
EOF

# 2. Replace Three.js with Striped Background
echo "🖼️ Replacing 3D Canvas with Striped Background..."
cat << 'EOF' > components/CanvasBackground.tsx
'use client';

// We keep the filename so we don't break app/layout.tsx imports,
// but we completely replace the heavy Three.js logic with clean CSS.
export default function CanvasBackground() {
  return (
    <div className="striped-pattern" aria-hidden="true" />
  );
}
EOF

# 3. Update Loading Screen with Animated Computer
echo "💻 Installing Animated Computer Boot Sequence..."
cat << 'EOF' > components/LoadingScreen.tsx
'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

export default function LoadingScreen() {
  const [progress, setProgress] = useState(0);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const duration = 1800; // 1.8 seconds
    const intervalTime = 15;
    const steps = duration / intervalTime;
    let currentStep = 0;

    const timer = setInterval(() => {
      currentStep++;
      setProgress(Math.min(100, Math.floor((currentStep / steps) * 100)));
      
      if (currentStep >= steps) {
        clearInterval(timer);
        setTimeout(() => setIsLoading(false), 300);
      }
    }, intervalTime);

    return () => clearInterval(timer);
  }, []);

  return (
    <AnimatePresence>
      {isLoading && (
        <motion.div
          initial={{ opacity: 1 }}
          exit={{ opacity: 0, transition: { duration: 0.6, ease: "easeOut" } }}
          className="fixed inset-0 z-[999] bg-[var(--bg-color)] flex flex-col items-center justify-center pointer-events-none"
        >
          {/* Animated Retro-Futuristic Computer */}
          <div className="mb-8 relative flex flex-col items-center">
            {/* Monitor */}
            <div className="w-24 h-20 border-2 border-[var(--text-color)] p-1.5 relative bg-[var(--bg-color)] z-10">
              <div className="w-full h-full border border-[var(--text-color)] overflow-hidden relative bg-[var(--card-bg)]">
                {/* Scanning line animation inside the screen */}
                <motion.div
                  className="w-full h-[2px] bg-[var(--text-color)] absolute opacity-50"
                  animate={{ top: ['0%', '100%', '0%'] }}
                  transition={{ repeat: Infinity, duration: 2, ease: "linear" }}
                />
                {/* Blinking cursor */}
                <motion.div 
                  className="w-2 h-3 bg-[var(--text-color)] absolute top-2 left-2"
                  animate={{ opacity: [1, 0, 1] }}
                  transition={{ repeat: Infinity, duration: 0.8, ease: "steps(2)" }}
                />
              </div>
            </div>
            {/* Stand */}
            <div className="w-6 h-3 border-x-2 border-b-2 border-[var(--text-color)]" />
            {/* Base */}
            <div className="w-16 h-1.5 border-2 border-[var(--text-color)]" />
          </div>

          {/* Loading Bar */}
          <div className="w-64 md:w-80">
            <div className="flex justify-between mb-2 font-black text-[var(--text-color)] tracking-widest text-xs uppercase opacity-80">
              <span>System.Initialize()</span>
              <span>{progress}%</span>
            </div>
            <div className="h-2 w-full border-2 border-[var(--text-color)] p-[2px]">
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

echo "✅ Aesthetic Upgrade Complete! Run 'npm run dev' to see it."