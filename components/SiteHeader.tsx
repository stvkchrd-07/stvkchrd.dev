'use client';

import Link from 'next/link';
import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import ThemeToggle from './ThemeToggle';
import RaoModal from './RaoModal';

export default function SiteHeader({ active }: { active?: 'home' | 'blog' }) {
  const [menuOpen, setMenuOpen] = useState(false);
  const [raoOpen, setRaoOpen] = useState(false);

  const snapAnim = { duration: 0, type: "tween" as const };

  return (
    <>
      <header className="mb-10 md:mb-16">
        <div className="flex flex-row justify-between items-center border-b-[2px] border-[var(--text-color)] pb-3 mb-4">
          <Link href="/" className="site-name font-black text-2xl md:text-3xl uppercase tracking-tighter hover:bg-[var(--accent-color)] hover:text-black transition-none px-2 py-1 -ml-2">
            Satvik Chaturvedi
          </Link>

          <nav className="hidden md:block">
            <ul className="flex space-x-2 text-sm md:text-base">
              {['X', 'in', '@'].map((item, idx) => {
                const links = ['https://x.com/StvkChrd', 'https://www.linkedin.com/in/stvkchrd', 'mailto:satvikc73@gmail.com'];
                return (
                  <motion.li key={item} whileHover={{ y: -3 }} whileTap={{ y: 0 }} transition={snapAnim}>
                    <a href={links[idx]} target={item === '@' ? '_self' : '_blank'} rel="noopener" className="block strict-border px-3 py-1.5 font-black uppercase accent-hover bg-[var(--bg-color)]">
                      {item}
                    </a>
                  </motion.li>
                );
              })}
              <motion.li whileHover={{ y: -3 }} whileTap={{ y: 0 }} transition={snapAnim}>
                <Link href="/blog" className={`block strict-border px-4 py-1.5 font-black uppercase accent-hover ${active === 'blog' ? 'bg-[var(--text-color)] text-[var(--bg-color)]' : 'bg-[var(--bg-color)]'}`}>
                  BLOG
                </Link>
              </motion.li>
              <motion.li whileHover={{ y: -3 }} whileTap={{ y: 0 }} transition={snapAnim}>
                <button onClick={() => setRaoOpen(true)} className="block strict-border px-4 py-1.5 font-black uppercase bg-[var(--accent-color)] text-black hover:bg-[var(--text-color)] hover:text-[var(--bg-color)] transition-none">
                  RAO AI ✦
                </button>
              </motion.li>
              <li className="flex items-center"><ThemeToggle /></li>
            </ul>
          </nav>

          <div className="flex items-center space-x-2 md:hidden text-sm">
            <ThemeToggle />
            <motion.button 
              whileTap={{ y: 2 }}
              onClick={() => setMenuOpen(!menuOpen)}
              className="strict-border px-3 py-1.5 font-black uppercase bg-[var(--accent-color)] text-black"
            >
              {menuOpen ? 'CLOSE' : 'MENU'}
            </motion.button>
          </div>
        </div>

        <AnimatePresence>
          {menuOpen && (
            <motion.div 
              initial={{ height: 0 }}
              animate={{ height: 'auto' }}
              exit={{ height: 0 }}
              transition={{ duration: 0.1, ease: "linear" }}
              className="overflow-hidden border-b-[2px] border-[var(--text-color)] bg-[var(--bg-color)] md:hidden"
            >
              <ul className="flex flex-col text-base uppercase">
                <Link href="/blog" className="p-3 font-black border-b-[2px] border-[var(--text-color)] text-left w-full strict-hover">BLOG</Link>
                <button onClick={() => { setRaoOpen(true); setMenuOpen(false); }} className="p-3 font-black text-left w-full bg-[var(--accent-color)] text-black hover:bg-[var(--text-color)] hover:text-[var(--accent-color)] transition-none">RAO AI ✦</button>
              </ul>
            </motion.div>
          )}
        </AnimatePresence>
      </header>
      <RaoModal isOpen={raoOpen} onClose={() => setRaoOpen(false)} />
    </>
  );
}
