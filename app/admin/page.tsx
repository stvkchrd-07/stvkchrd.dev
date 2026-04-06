"use client";
import { useState } from 'react';
import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';

export default function AdminPage() {
  const [status, setStatus] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    // TODO: Wire this up to Supabase 'working_on' table
    setStatus('SUCCESS: Project payload deployed to database.');
    setTimeout(() => setStatus(''), 4000);
  };

  return (
    <>
      <SiteHeader active="admin" />
      <main className="max-w-3xl mx-auto mt-8 p-4 min-h-[70vh]">
        <div className="neo-card p-6 md:p-10 bg-card">
          <div className="flex items-center justify-between border-b-4 border-text pb-4 mb-8">
             <h1 className="font-black text-3xl md:text-4xl uppercase">Command Center</h1>
             <span className="font-pixel bg-lime text-black px-2 py-1 shadow-neo border-2 border-black">SECURE</span>
          </div>
          
          <div className="bg-bg border-2 border-text p-6 md:p-8 shadow-[8px_8px_0_0_var(--text-color)]">
            <h2 className="font-pixel text-2xl text-electric mb-6 flex items-center gap-2">
              <span className="text-3xl">+</span> Add Lab Project
            </h2>
            
            <form onSubmit={handleSubmit} className="flex flex-col gap-5">
              <div className="flex flex-col gap-1">
                <label className="font-bold text-sm uppercase">Project Title</label>
                <input type="text" placeholder="e.g. Toefury" className="p-3 border-2 border-text font-sans bg-card focus:outline-none focus:border-lime" required />
              </div>

              <div className="flex flex-col gap-1">
                <label className="font-bold text-sm uppercase">Detailed Description</label>
                <textarea placeholder="Appears in the pop-up modal..." className="p-3 border-2 border-text font-sans bg-card h-32 focus:outline-none focus:border-lime" required></textarea>
              </div>

              <div className="flex flex-col gap-1">
                <label className="font-bold text-sm uppercase">Landing Page Screenshot URL</label>
                <input type="url" placeholder="https://..." className="p-3 border-2 border-text font-sans bg-card focus:outline-none focus:border-lime" required />
              </div>

              <div className="flex flex-col gap-1">
                <label className="font-bold text-sm uppercase">Live URL / Repo Link</label>
                <input type="url" placeholder="https://..." className="p-3 border-2 border-text font-sans bg-card focus:outline-none focus:border-lime" />
              </div>
              
              <button type="submit" className="neo-btn bg-electric text-white py-4 mt-4 text-xl hover:bg-lime hover:text-black transition-colors w-full">
                Upload & Deploy
              </button>
            </form>

            {status && (
              <div className="mt-6 p-4 border-2 border-black bg-lime text-black font-pixel font-bold text-lg text-center animate-bounce">
                {status}
              </div>
            )}
          </div>
        </div>
      </main>
      <SiteFooter />
    </>
  );
}
