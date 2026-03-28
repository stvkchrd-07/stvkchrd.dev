#!/bin/bash

echo "🔽 Pinning and Styling the Footer..."

cat << 'EOF' > components/SiteFooter.tsx
'use client';

import React from 'react';

export default function SiteFooter() {
  return (
    <>
      {/* Invisible spacer so the fixed footer doesn't cover up the last project cards */}
      <div className="h-24 md:h-16 w-full pointer-events-none" aria-hidden="true"></div>
      
      {/* The Fixed Footer Bar */}
      <footer className="fixed bottom-0 left-0 w-full border-t-[2px] border-[var(--text-color)] bg-[var(--bg-color)] z-[100] px-4 py-3 md:px-8 flex flex-col sm:flex-row justify-between items-center gap-3 md:gap-0">
        
        {/* Email Button */}
        <a
          href="mailto:satvikc73@gmail.com"
          className="font-black text-xs md:text-sm uppercase tracking-widest bg-[var(--accent-color)] text-black px-3 py-1.5 strict-border hover:bg-[var(--text-color)] hover:text-[var(--bg-color)] transition-none active:translate-y-0.5 active:shadow-none"
        >
          satvikc73@gmail.com ↗
        </a>

        {/* Copyright Text */}
        <span className="font-bold text-[9px] md:text-[11px] uppercase tracking-widest opacity-80 text-center sm:text-right">
          © 2025 Satvik Chaturvedi. <br className="sm:hidden" /> All rights reserved.
        </span>
        
      </footer>
    </>
  );
}
EOF

echo "✅ Footer optimized and pinned! Check your browser."