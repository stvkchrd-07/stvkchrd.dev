'use client';

import { useState } from 'react';
import Link from 'next/link';
import ThemeToggle from '@/components/ThemeToggle';

export default function AdminDashboard() {
  // Replace this with your actual Supabase auth/data fetching logic
  const [activeTab, setActiveTab] = useState('projects');

  return (
    <div className="min-h-screen bg-[var(--bg-color)] text-[var(--text-color)] p-4 md:p-8 font-sans">
      
      {/* Admin Header */}
      <header className="flex justify-between items-center border-b-[2px] border-[var(--text-color)] pb-4 mb-8">
        <div>
          <h1 className="font-black text-2xl md:text-4xl uppercase tracking-tighter leading-none">SYSTEM_ADMIN</h1>
          <p className="text-xs font-bold uppercase tracking-widest opacity-50 mt-1">Authorized Access Only</p>
        </div>
        <div className="flex gap-2">
          <ThemeToggle />
          <Link href="/" className="strict-border px-4 py-2 font-black uppercase text-xs md:text-sm bg-[var(--text-color)] text-[var(--bg-color)] active:translate-y-0.5">
            EXIT ↗
          </Link>
        </div>
      </header>

      {/* Control Panel Tabs */}
      <div className="flex gap-2 mb-6">
        <button 
          onClick={() => setActiveTab('projects')}
          className={`strict-border px-4 py-2 font-black uppercase text-sm transition-none ${activeTab === 'projects' ? 'bg-[var(--accent-color)] text-black' : 'bg-[var(--bg-color)] text-[var(--text-color)]'}`}
        >
          PROJECTS DB
        </button>
        <button 
          onClick={() => setActiveTab('cwo')}
          className={`strict-border px-4 py-2 font-black uppercase text-sm transition-none ${activeTab === 'cwo' ? 'bg-[var(--accent-color)] text-black' : 'bg-[var(--bg-color)] text-[var(--text-color)]'}`}
        >
          FOCUS DB
        </button>
      </div>

      {/* Content Area - Put your forms here! */}
      <main className="strict-border p-6 md:p-10 bg-[var(--card-bg)] rounded-xl">
        <h2 className="font-black text-xl uppercase border-b-[2px] border-[var(--text-color)] pb-2 mb-6">
          {activeTab === 'projects' ? 'MANAGE PROJECTS' : 'MANAGE CURRENT FOCUS'}
        </h2>
        
        {/* Example Placeholder Form matching the Brutalist aesthetic */}
        <form className="flex flex-col gap-4 max-w-2xl">
          <div className="flex flex-col gap-1">
            <label className="text-xs font-bold uppercase tracking-widest">Title</label>
            <input type="text" className="strict-border p-2 bg-transparent focus:bg-[var(--text-color)] focus:text-[var(--bg-color)] outline-none font-bold" placeholder="PROJECT NAME" />
          </div>
          
          <div className="flex flex-col gap-1">
            <label className="text-xs font-bold uppercase tracking-widest">Description</label>
            <textarea rows={4} className="strict-border p-2 bg-transparent focus:bg-[var(--text-color)] focus:text-[var(--bg-color)] outline-none font-bold resize-none" placeholder="ENTER DETAILS..."></textarea>
          </div>

          <button type="button" className="strict-border self-start px-6 py-3 mt-2 font-black uppercase bg-[var(--accent-color)] text-black active:translate-y-1 active:shadow-none">
            UPLOAD TO SUPABASE
          </button>
        </form>
      </main>

    </div>
  );
}
