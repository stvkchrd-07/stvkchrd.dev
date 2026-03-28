'use client';

import React from 'react';

export default function SiteFooter() {
  return (
    <footer className="w-full mt-20 pb-10 border-t-[1px] border-[var(--text-color)] opacity-30">
      <div className="flex flex-col md:flex-row justify-between items-center pt-4 gap-2">
        
        {/* Minimalist Email Link */}
        <a
          href="mailto:satvikc73@gmail.com"
          className="text-[9px] md:text-[10px] font-black uppercase tracking-[0.3em] hover:text-[var(--accent-color)] transition-colors"
        >
          satvikc73@gmail.com
        </a>

        {/* Minimalist Copyright */}
        <span className="text-[9px] md:text-[10px] font-bold uppercase tracking-[0.3em] text-center md:text-right">
          © 2025 Satvik Chaturvedi &bull; All rights reserved.
        </span>
        
      </div>
    </footer>
  );
}
