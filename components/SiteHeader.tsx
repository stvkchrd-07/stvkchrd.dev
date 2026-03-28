'use client';

import Link from 'next/link';
import { useState } from 'react';
import ThemeToggle from './ThemeToggle';
import RaoModal from './RaoModal';

interface Props {
  active?: 'home' | 'blog';
}

export default function SiteHeader({ active }: Props) {
  const [menuOpen, setMenuOpen] = useState(false);
  const [raoOpen, setRaoOpen] = useState(false);

  return (
    <>
      <header className="mb-12 md:mb-20">
        <div className="flex flex-row justify-between items-center border-b-2 border-black pb-4 mb-4">
          <Link href="/" className="site-name hover:underline">
            Satvik Chaturvedi
          </Link>

          {/* Desktop nav */}
          <nav className="hidden md:block">
            <ul className="flex space-x-2">
              <li><a href="https://x.com/StvkChrd" target="_blank" rel="noopener" className="brutalist-hover block border-2 border-black p-3 font-bold">X</a></li>
              <li><a href="https://www.linkedin.com/in/stvkchrd" target="_blank" rel="noopener" className="brutalist-hover block border-2 border-black p-3 font-bold">in</a></li>
              <li><a href="mailto:satvikc73@gmail.com" className="brutalist-hover block border-2 border-black p-3 font-bold">@</a></li>
              <li>
                <Link
                  href="/blog"
                  className="brutalist-hover block border-2 border-black px-4 py-3 font-bold"
                  style={active === 'blog' ? { background: 'var(--text-color)', color: 'var(--bg-color)' } : undefined}
                >
                  BLOG
                </Link>
              </li>
              <li>
                <button
                  onClick={() => setRaoOpen(true)}
                  className="brutalist-hover block border-2 border-black px-4 py-3 font-bold"
                >
                  RAO AI ✦
                </button>
              </li>
              <li><ThemeToggle /></li>
            </ul>
          </nav>

          {/* Mobile: theme + hamburger */}
          <div className="flex items-center space-x-2 md:hidden">
            <ThemeToggle />
            <button
              onClick={() => setMenuOpen(!menuOpen)}
              className="brutalist-hover border-2 border-black p-3 font-bold"
              aria-label="Menu"
            >
              {menuOpen ? '✕' : '☰'}
            </button>
          </div>
        </div>

        {/* Mobile dropdown */}
        {menuOpen && (
          <div className="mobile-menu open md:hidden">
            <ul>
              <li><a href="https://x.com/StvkChrd" target="_blank" rel="noopener" className="mobile-menu-item">X (Twitter)</a></li>
              <li><a href="https://www.linkedin.com/in/stvkchrd" target="_blank" rel="noopener" className="mobile-menu-item">LinkedIn</a></li>
              <li><a href="mailto:satvikc73@gmail.com" className="mobile-menu-item">Email</a></li>
              <li><Link href="/blog" className="mobile-menu-item" onClick={() => setMenuOpen(false)}>Blog</Link></li>
              <li>
                <button
                  className="mobile-menu-item w-full text-left"
                  onClick={() => { setRaoOpen(true); setMenuOpen(false); }}
                >
                  RAO AI ✦
                </button>
              </li>
            </ul>
          </div>
        )}
      </header>

      <RaoModal isOpen={raoOpen} onClose={() => setRaoOpen(false)} />
    </>
  );
}
