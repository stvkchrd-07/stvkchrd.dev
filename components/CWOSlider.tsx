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
    <div className="relative overflow-hidden border-2 border-[var(--text-color)] group mb-12">
      <motion.div 
        className="flex"
        animate={{ x: `-${current * 100}%` }}
        transition={{ duration: 0.3, ease: [0.25, 1, 0.5, 1] }}
        onTouchStart={onTouchStart}
        onTouchEnd={onTouchEnd}
      >
        {items.map((item) => (
          <div key={item.id} className="min-w-full p-8 md:p-10 bg-[var(--card-bg)] flex flex-col gap-3 min-h-[220px] justify-center">
            <span className="text-xs font-black tracking-[0.15em] uppercase opacity-60">
              {item.tag}
            </span>
            <h3 className="font-black text-3xl md:text-4xl">{item.title}</h3>
            <p className="text-base md:text-lg leading-relaxed opacity-90 max-w-3xl mt-2 flex-1">
              {item.description}
            </p>
            {item.status && (
              <span className="inline-block mt-4 px-4 py-1.5 text-xs font-black uppercase tracking-widest border-2 border-[var(--text-color)] w-max">
                {item.status}
              </span>
            )}
          </div>
        ))}
      </motion.div>

      <div className="absolute bottom-5 left-0 right-0 flex justify-center gap-3">
        {items.map((_, i) => (
          <button
            key={i}
            onClick={() => go(i)}
            className={`w-3 h-3 border-2 border-[var(--text-color)] transition-colors duration-150 ${
              i === current ? 'bg-[var(--text-color)]' : 'bg-transparent'
            }`}
          />
        ))}
      </div>
    </div>
  );
}
