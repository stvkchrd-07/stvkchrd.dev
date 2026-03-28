'use client';

import { useEffect, useRef, useState } from 'react';

interface CWOItem {
  id: number;
  title: string;
  tag?: string;
  description: string;
  status?: string;
}

interface Props {
  items: CWOItem[];
}

export default function CWOSlider({ items }: Props) {
  const [current, setCurrent] = useState(0);
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const sliderRef = useRef<HTMLDivElement>(null);
  const touchStartX = useRef(0);

  const go = (index: number) => {
    setCurrent(index);
  };

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
    <div className="cwo-slider-wrapper">
      <div
        ref={sliderRef}
        className="cwo-slider"
        style={{ transform: `translateX(-${current * 100}%)` }}
        onTouchStart={onTouchStart}
        onTouchEnd={onTouchEnd}
      >
        {items.map((item) => (
          <div key={item.id} className="cwo-card">
            <div className="cwo-card-tag">{item.tag || ''}</div>
            <h3 className="font-black text-2xl md:text-3xl mb-2">{item.title}</h3>
            <p className="cwo-card-desc">{item.description}</p>
            <span className="cwo-status">{item.status || 'In Progress'}</span>
          </div>
        ))}
      </div>
      <div className="cwo-dots">
        {items.map((_, i) => (
          <button
            key={i}
            className={`cwo-dot ${i === current ? 'cwo-dot-active' : ''}`}
            onClick={() => go(i)}
            aria-label={`Go to card ${i + 1}`}
          />
        ))}
      </div>
    </div>
  );
}
