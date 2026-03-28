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
