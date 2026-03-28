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
