#!/bin/bash

echo "🌗 Upgrading Theme Engine & Toggle Button..."

# 1. Update Global Styles for Smooth Theme Transitions
echo "🎨 Injecting Smooth Color Transitions..."
cat << 'EOF' > styles/globals.css
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
    --bg-color: #FFFFFF;
    --text-color: #000000;
    --card-bg: #FFFFFF;
    --accent-color: #CCFF00; /* Neon Yellow */
    --border-weight: 2px;
}

body.dark {
    --bg-color: #000000;
    --text-color: #FFFFFF;
    --card-bg: #000000;
    --accent-color: #CCFF00;
}

body {
    font-family: 'Inter', system-ui, sans-serif;
    background-color: var(--bg-color);
    color: var(--text-color);
    overflow-x: hidden;
    line-height: 1.2;
    letter-spacing: -0.02em;
}

* { border-radius: 0 !important; }

.content-wrapper {
    position: relative;
    z-index: 1;
}

/* SMOOTH THEME ENGINE:
  This gracefully fades backgrounds and text colors globally when switching themes.
*/
body, 
.bg-\[var\(--bg-color\)\], 
.bg-\[var\(--card-bg\)\], 
.bg-\[var\(--text-color\)\],
.text-\[var\(--text-color\)\],
.text-\[var\(--bg-color\)\] {
    transition: background-color 0.5s ease-in-out, color 0.5s ease-in-out, border-color 0.5s ease-in-out;
}

/* Strict Borders */
.strict-border {
    border: var(--border-weight) solid var(--text-color);
    transition: border-color 0.5s ease-in-out; /* Smooth border color change */
}

/* INSTANT HOVERS:
  We override the smooth transitions here so your hover effects stay raw and snappy.
*/
.strict-hover {
    transition: transform 0s, background-color 0s, color 0s !important;
}

.strict-hover:hover {
    background-color: var(--text-color) !important;
    color: var(--bg-color) !important;
}

.accent-hover {
    transition: transform 0.05s linear !important;
}

.accent-hover:hover {
    background-color: var(--accent-color) !important;
    color: #000000 !important;
    border-color: #000000 !important;
    transform: translate(-3px, -3px);
}

.accent-hover:active {
    transform: translate(2px, 2px);
}

::selection {
    background-color: var(--accent-color);
    color: #000000;
}
EOF

# 2. Update ThemeToggle Component
echo "⚙️ Writing Neo-Brutalist Theme Button..."
cat << 'EOF' > components/ThemeToggle.tsx
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
EOF

echo "✅ Theme Engine Upgraded! Check your browser."