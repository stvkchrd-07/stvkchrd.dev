'use client';

import { useState, useEffect } from 'react';

export default function ThemeToggle() {
  const [isDark, setIsDark] = useState(false);
  const [mounted, setMounted] = useState(false);

  // Sync with current body class on load
  useEffect(() => {
    setMounted(true);
    if (document.body.classList.contains('dark')) {
      setIsDark(true);
    }
  }, []);

  const toggleTheme = () => {
    const nextDark = !isDark;
    setIsDark(nextDark);
    
    if (nextDark) {
      document.body.classList.add('dark');
    } else {
      document.body.classList.remove('dark');
    }
  };

  // Prevent hydration mismatch by rendering a placeholder until mounted
  if (!mounted) {
    return (
      <button className="strict-border px-3 py-1.5 font-black uppercase bg-[var(--bg-color)] text-[var(--text-color)] min-w-[90px] opacity-50">
        ...
      </button>
    );
  }

  return (
    <button
      onClick={toggleTheme}
      className="strict-border px-3 py-1.5 font-black uppercase bg-[var(--bg-color)] text-[var(--text-color)] accent-hover min-w-[90px] flex items-center justify-center gap-1"
      aria-label="Toggle Theme"
    >
      {isDark ? 'DARK ☾' : 'LIGHT ☼'}
    </button>
  );
}
