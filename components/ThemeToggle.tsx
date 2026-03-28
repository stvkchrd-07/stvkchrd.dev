'use client';

import { useEffect, useState } from 'react';

export default function ThemeToggle() {
  const [theme, setTheme] = useState<'dark' | 'light'>('dark');

  useEffect(() => {
    const saved = (localStorage.getItem('theme') as 'dark' | 'light' | null) ?? 'dark';
    setTheme(saved);
    document.body.classList.toggle('dark', saved === 'dark');
  }, []);

  function toggle() {
    const next = theme === 'dark' ? 'light' : 'dark';
    setTheme(next);
    localStorage.setItem('theme', next);
    document.body.classList.toggle('dark', next === 'dark');
  }

  return (
    <button
      onClick={toggle}
      className="brutalist-hover block border-2 border-black p-3 font-bold"
      title="Toggle theme"
      aria-label="Toggle dark/light mode"
    >
      <span>{theme === 'dark' ? '☀️' : '🌙'}</span>
    </button>
  );
}
