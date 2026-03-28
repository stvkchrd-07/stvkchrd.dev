'use client';

import Link from 'next/link';
import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import ThemeToggle from './ThemeToggle';
import RaoModal from './RaoModal';

export default function SiteHeader({ active }: { active?: 'home' | 'blog' }) {
  const [menuOpen, setMenuOpen] = useState(false);
  const [raoOpen, setRaoOpen] = useState(false);

  // Apple-like spring physics
  const springAnim = {
    type: "spring" as const,
    stiffness: 400,
    damping: 17
  };

  return (
    <>
      <header className="mb-12 md:mb-20">
        <div className="flex flex-row justify-between items-center border-b-2 border-black pb-4 mb-4">
          <Link href="/" className="site-name hover:underline transition-all duration-300">
            Satvik Chaturvedi
          </Link>

          {/* Desktop nav */}
          <nav className="hidden md:block">
            <ul className="flex space-x-2">
              {['X', 'in', '@'].map((item, idx) => {
                const links = ['https://x.com/StvkChrd', 'https://www.linkedin.com/in/stvkchrd', 'mailto:satvikc73@gmail.com'];
                return (
                  <motion.li key={item} whileHover={{ scale: 1.05, y: -2 }} whileTap={{ scale: 0.95 }} transition={springAnim}>
                    <a href={links[idx]} target={item === '@' ? '_self' : '_blank'} rel="noopener" className="block border-2 border-black p-3 font-bold brutalist-hover">
                      {item}
                    </a>
                  </motion.li>
                );
              })}
              <motion.li whileHover={{ scale: 1.05, y: -2 }} whileTap={{ scale: 0.95 }} transition={springAnim}>
                <Link href="/blog" className="block border-2 border-black px-4 py-3 font-bold brutalist-hover" style={active === 'blog' ? { background: 'var(--text-color)', color: 'var(--bg-color)' } : undefined}>
                  BLOG
                </Link>
              </motion.li>
              <motion.li whileHover={{ scale: 1.05, y: -2 }} whileTap={{ scale: 0.95 }} transition={springAnim}>
                <button onClick={() => setRaoOpen(true)} className="block border-2 border-black px-4 py-3 font-bold brutalist-hover">
                  RAO AI ✦
                </button>
              </motion.li>
              <li><ThemeToggle /></li>
            </ul>
          </nav>

          {/* Mobile: theme + hamburger */}
          <div className="flex items-center space-x-2 md:hidden">
            <ThemeToggle />
            <motion.button 
              whileTap={{ scale: 0.9 }}
              onClick={() => setMenuOpen(!menuOpen)}
              className="border-2 border-black p-3 font-bold brutalist-hover"
            >
              {menuOpen ? '✕' : '☰'}
            </motion.button>
          </div>
        </div>

        {/* Smooth Mobile Dropdown */}
        <AnimatePresence>
          {menuOpen && (
            <motion.div 
              initial={{ height: 0, opacity: 0 }}
              animate={{ height: 'auto', opacity: 1 }}
              exit={{ height: 0, opacity: 0 }}
              className="overflow-hidden border-b-2 border-black bg-[var(--bg-color)] md:hidden"
            >
              <ul className="flex flex-col">
                <Link href="/blog" className="p-4 font-black border-b border-black text-left w-full hover:bg-[var(--text-color)] hover:text-[var(--bg-color)] transition-colors">BLOG</Link>
                <button onClick={() => { setRaoOpen(true); setMenuOpen(false); }} className="p-4 font-black text-left w-full hover:bg-[var(--text-color)] hover:text-[var(--bg-color)] transition-colors">RAO AI ✦</button>
              </ul>
            </motion.div>
          )}
        </AnimatePresence>
      </header>
      <RaoModal isOpen={raoOpen} onClose={() => setRaoOpen(false)} />
    </>
  );
}