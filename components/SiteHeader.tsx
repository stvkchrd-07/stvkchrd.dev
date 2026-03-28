'use client';

import Link from 'next/link';
import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import ThemeToggle from './ThemeToggle';
import RaoModal from './RaoModal';

export default function SiteHeader({ active }: { active?: string }) {
  const [raoOpen, setRaoOpen] = useState(false);

  const navItem = {
    type: "spring",
    stiffness: 400,
    damping: 17
  };

  return (
    <>
      <header className="mb-12 md:mb-20">
        <div className="flex flex-row justify-between items-center border-b-2 border-black pb-4">
          <Link href="/" className="site-name font-black text-4xl hover:line-through transition-all duration-300">
            Satvik Chaturvedi
          </Link>

          <nav className="hidden md:block">
            <ul className="flex space-x-2">
              {['X', 'in', '@'].map((item) => (
                <motion.li key={item} whileHover={{ scale: 1.1, y: -2 }} whileTap={{ scale: 0.95 }} transition={navItem}>
                  <a href="#" className="block border-2 border-black p-3 font-bold hover:bg-black hover:text-white transition-colors duration-200">
                    {item}
                  </a>
                </motion.li>
              ))}
              <motion.li whileHover={{ scale: 1.05 }} transition={navItem}>
                <button onClick={() => setRaoOpen(true)} className="border-2 border-black px-4 py-3 font-bold hover:bg-black hover:text-white transition-colors">
                  RAO AI ✦
                </button>
              </motion.li>
              <li><ThemeToggle /></li>
            </ul>
          </nav>
        </div>
      </header>
      <RaoModal isOpen={raoOpen} onClose={() => setRaoOpen(false)} />
    </>
  );
}
