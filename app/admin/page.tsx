'use client';

import { useState } from 'react';
import Link from 'next/link';
import { createClientComponentClient } from '@supabase/auth-helpers-nextjs';

export default function AdminDashboard() {
  const [activeTab, setActiveTab] = useState<'projects' | 'cwo' | 'posts'>('projects');
  const [loading, setLoading] = useState(false);
  const [status, setStatus] = useState('');
  
  const supabase = createClientComponentClient();

  // Form States
  const [title, setTitle] = useState('');
  const [subtitle, setSubtitle] = useState(''); // Used as "tag" for CWO
  const [description, setDescription] = useState('');
  const [statusText, setStatusText] = useState('Active');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setStatus('UPLOADING...');

    try {
      let error;
      if (activeTab === 'projects') {
        const { error: dbError } = await supabase.from('projects').insert([{ 
          title, subtitle, description 
        }]);
        error = dbError;
      } else if (activeTab === 'cwo') {
        const { error: dbError } = await supabase.from('working_on').insert([{ 
          title, tag: subtitle, description, status: statusText 
        }]);
        error = dbError;
      } else {
        // Assuming you have a 'posts' table for blog posts
        const { error: dbError } = await supabase.from('posts').insert([{ 
          title, content: description 
        }]);
        error = dbError;
      }

      if (error) throw error;
      
      setStatus('SUCCESS: DATA WRITTEN TO SUPABASE.');
      setTitle(''); setSubtitle(''); setDescription('');
    } catch (err: any) {
      console.error(err);
      setStatus(`ERROR: ${err.message}`);
    } finally {
      setLoading(false);
      setTimeout(() => setStatus(''), 4000);
    }
  };

  return (
    <div className="min-h-screen bg-[var(--bg-color)] text-[var(--text-color)] p-4 md:p-8 font-sans">
      <header className="flex justify-between items-center border-b-[2px] border-[var(--text-color)] pb-4 mb-8">
        <div>
          <h1 className="font-black text-2xl md:text-4xl uppercase tracking-tighter leading-none">SYSTEM_ADMIN</h1>
          <p className="text-xs font-bold uppercase tracking-widest opacity-50 mt-1">Database Control Panel</p>
        </div>
        <Link href="/" className="strict-border px-4 py-2 font-black uppercase text-xs md:text-sm bg-[var(--text-color)] text-[var(--bg-color)] active:translate-y-0.5">
          EXIT ↗
        </Link>
      </header>

      <div className="flex flex-wrap gap-2 mb-6">
        {['projects', 'cwo', 'posts'].map((tab) => (
          <button 
            key={tab}
            onClick={() => setActiveTab(tab as any)}
            className={`strict-border px-4 py-2 font-black uppercase text-sm transition-none ${activeTab === tab ? 'bg-[var(--accent-color)] text-black' : 'bg-[var(--bg-color)] text-[var(--text-color)]'}`}
          >
            {tab === 'cwo' ? 'FOCUS DB' : `${tab.toUpperCase()} DB`}
          </button>
        ))}
      </div>

      <main className="strict-border p-6 md:p-10 bg-[var(--card-bg)]">
        <h2 className="font-black text-xl uppercase border-b-[2px] border-[var(--text-color)] pb-2 mb-6">
          INSERT NEW {activeTab.toUpperCase()}
        </h2>
        
        <form onSubmit={handleSubmit} className="flex flex-col gap-4 max-w-2xl">
          <div className="flex flex-col gap-1">
            <label className="text-xs font-bold uppercase tracking-widest">Title</label>
            <input required value={title} onChange={e => setTitle(e.target.value)} type="text" className="strict-border p-2 bg-transparent focus:bg-[var(--text-color)] focus:text-[var(--bg-color)] outline-none font-bold" placeholder="ENTRY NAME" />
          </div>
          
          {activeTab !== 'posts' && (
            <div className="flex flex-col gap-1">
              <label className="text-xs font-bold uppercase tracking-widest">{activeTab === 'cwo' ? 'Tag' : 'Subtitle'}</label>
              <input required value={subtitle} onChange={e => setSubtitle(e.target.value)} type="text" className="strict-border p-2 bg-transparent focus:bg-[var(--text-color)] focus:text-[var(--bg-color)] outline-none font-bold" placeholder={activeTab === 'cwo' ? "e.g., Luxury" : "e.g., Web App"} />
            </div>
          )}

          {activeTab === 'cwo' && (
             <div className="flex flex-col gap-1">
              <label className="text-xs font-bold uppercase tracking-widest">Status</label>
              <input required value={statusText} onChange={e => setStatusText(e.target.value)} type="text" className="strict-border p-2 bg-transparent focus:bg-[var(--text-color)] focus:text-[var(--bg-color)] outline-none font-bold" placeholder="e.g., Active, Building" />
            </div>
          )}
          
          <div className="flex flex-col gap-1">
            <label className="text-xs font-bold uppercase tracking-widest">{activeTab === 'posts' ? 'Content (Markdown)' : 'Description'}</label>
            <textarea required value={description} onChange={e => setDescription(e.target.value)} rows={5} className="strict-border p-2 bg-transparent focus:bg-[var(--text-color)] focus:text-[var(--bg-color)] outline-none font-bold resize-none" placeholder="ENTER DETAILS..."></textarea>
          </div>

          <div className="flex items-center gap-4 mt-2">
            <button disabled={loading} type="submit" className="strict-border px-6 py-3 font-black uppercase bg-[var(--accent-color)] text-black active:translate-y-1 active:shadow-none disabled:opacity-50">
              {loading ? 'PROCESSING...' : 'UPLOAD TO SUPABASE'}
            </button>
            {status && <span className="font-bold text-xs tracking-widest uppercase">{status}</span>}
          </div>
        </form>
      </main>
    </div>
  );
}
