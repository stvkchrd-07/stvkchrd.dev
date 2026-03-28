#!/bin/bash

echo "🩹 Patching Invalid Easing Type..."

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
                {/* Blinking cursor fixed: using linear ease with sharp opacity drops */}
                <motion.div 
                  className="w-2 h-3 bg-[var(--text-color)] absolute top-2 left-2"
                  animate={{ opacity: [1, 1, 0, 0, 1] }}
                  transition={{ 
                    repeat: Infinity, 
                    duration: 0.8, 
                    times: [0, 0.49, 0.5, 0.99, 1],
                    ease: "linear" 
                  }}
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

echo "✅ Cursor patched! Check your browser."