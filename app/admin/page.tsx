'use client';

import { useEffect, useRef, useState } from 'react';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import Link from 'next/link';

type Tab = 'projects' | 'blog' | 'working';

interface Item { id: number; title: string; subtitle?: string; tag?: string; status?: string; date?: string; }

export default function AdminPage() {
  const [tab, setTab] = useState<Tab>('projects');
  const [client, setClient] = useState<SupabaseClient | null>(null);
  const [projects, setProjects] = useState<Item[]>([]);
  const [posts, setPosts] = useState<Item[]>([]);
  const [working, setWorking] = useState<Item[]>([]);
  const toastRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const url = process.env.NEXT_PUBLIC_SUPABASE_URL!;
    const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
    if (!url || !key) { showToast('Missing Supabase env vars', true); return; }
    const c = createClient(url, key);
    setClient(c);
    loadAll(c);
  }, []);

  function showToast(msg: string, error = false) {
    const el = toastRef.current;
    if (!el) return;
    el.textContent = msg;
    el.className = `admin-toast show${error ? ' error' : ''}`;
    setTimeout(() => { el.className = 'admin-toast'; }, 2800);
  }

  async function loadAll(c: SupabaseClient) {
    const [p, po, w] = await Promise.all([
      c.from('projects').select('id,title,subtitle').order('id', { ascending: false }),
      c.from('posts').select('id,title,date').order('date', { ascending: false }),
      c.from('working_on').select('id,title,tag,status').order('id', { ascending: false })
    ]);
    if (p.data) setProjects(p.data);
    if (po.data) setPosts(po.data);
    if (w.data) setWorking(w.data);
  }

  // --- PROJECTS ---
  async function addProject(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (!client) return;
    const f = e.currentTarget;
    const btn = f.querySelector('button') as HTMLButtonElement;
    btn.disabled = true; btn.textContent = 'Saving...';
    const { error } = await client.from('projects').insert([{
      title: (f.querySelector('#p-title') as HTMLInputElement).value,
      subtitle: (f.querySelector('#p-subtitle') as HTMLInputElement).value,
      description: (f.querySelector('#p-desc') as HTMLTextAreaElement).value,
      imageUrl: (f.querySelector('#p-image') as HTMLInputElement).value,
      liveUrl: (f.querySelector('#p-url') as HTMLInputElement).value,
    }]);
    btn.disabled = false; btn.textContent = 'Add Project';
    if (error) { showToast('Error: ' + error.message, true); return; }
    showToast('Project added ✓');
    f.reset();
    const { data } = await client.from('projects').select('id,title,subtitle').order('id', { ascending: false });
    if (data) setProjects(data);
  }

  async function deleteProject(id: number) {
    if (!client || !confirm('Delete this project?')) return;
    const { error } = await client.from('projects').delete().eq('id', id);
    if (error) { showToast('Error deleting', true); return; }
    showToast('Deleted');
    setProjects(prev => prev.filter(p => p.id !== id));
  }

  // --- POSTS ---
  async function addPost(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (!client) return;
    const f = e.currentTarget;
    const btn = f.querySelector('button') as HTMLButtonElement;
    btn.disabled = true; btn.textContent = 'Publishing...';
    const { error } = await client.from('posts').insert([{
      title: (f.querySelector('#b-title') as HTMLInputElement).value,
      date: (f.querySelector('#b-date') as HTMLInputElement).value,
      content: (f.querySelector('#b-content') as HTMLTextAreaElement).value,
    }]);
    btn.disabled = false; btn.textContent = 'Publish Post';
    if (error) { showToast('Error: ' + error.message, true); return; }
    showToast('Post published ✓');
    f.reset();
    (f.querySelector('#b-date') as HTMLInputElement).value = new Date().toISOString().split('T')[0];
    const { data } = await client.from('posts').select('id,title,date').order('date', { ascending: false });
    if (data) setPosts(data);
  }

  async function deletePost(id: number) {
    if (!client || !confirm('Delete this post?')) return;
    const { error } = await client.from('posts').delete().eq('id', id);
    if (error) { showToast('Error deleting', true); return; }
    showToast('Deleted');
    setPosts(prev => prev.filter(p => p.id !== id));
  }

  // --- WORKING ON ---
  async function addWorking(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (!client) return;
    const f = e.currentTarget;
    const btn = f.querySelector('button') as HTMLButtonElement;
    btn.disabled = true; btn.textContent = 'Saving...';
    const { error } = await client.from('working_on').insert([{
      title: (f.querySelector('#w-title') as HTMLInputElement).value,
      tag: (f.querySelector('#w-tag') as HTMLInputElement).value,
      description: (f.querySelector('#w-desc') as HTMLTextAreaElement).value,
      status: (f.querySelector('#w-status') as HTMLInputElement).value || 'Active',
    }]);
    btn.disabled = false; btn.textContent = 'Add Card';
    if (error) { showToast('Error: ' + error.message, true); return; }
    showToast('Card added ✓');
    f.reset();
    const { data } = await client.from('working_on').select('id,title,tag,status').order('id', { ascending: false });
    if (data) setWorking(data);
  }

  async function deleteWorking(id: number) {
    if (!client || !confirm('Delete this card?')) return;
    const { error } = await client.from('working_on').delete().eq('id', id);
    if (error) { showToast('Error deleting', true); return; }
    showToast('Deleted');
    setWorking(prev => prev.filter(w => w.id !== id));
  }

  const today = new Date().toISOString().split('T')[0];

  return (
    <div style={{ minHeight: '100vh', backgroundColor: '#111', color: '#fff', padding: '2rem', fontFamily: 'Inter, sans-serif' }}>
      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '2px solid #333', paddingBottom: '1.5rem', marginBottom: '2rem' }}>
        <span style={{ fontWeight: 900, fontSize: 'clamp(1.75rem, 5vw, 3rem)', letterSpacing: '-0.03em' }}>Admin Panel</span>
        <Link href="/" style={{ fontWeight: 700, color: '#888', textDecoration: 'none', border: '1.5px solid #333', padding: '0.5rem 1rem', fontSize: '0.9rem' }}>
          ← Back to Site
        </Link>
      </div>

      {/* Tabs */}
      <div style={{ display: 'flex', borderBottom: '2px solid #333', marginBottom: '2rem' }}>
        {(['projects', 'blog', 'working'] as Tab[]).map(t => (
          <button key={t} onClick={() => setTab(t)} style={{
            padding: '0.75rem 1.5rem', fontWeight: 900, fontSize: '0.85rem',
            letterSpacing: '0.08em', textTransform: 'uppercase', cursor: 'pointer',
            border: 'none', background: 'transparent',
            color: tab === t ? '#fff' : '#666',
            borderBottom: tab === t ? '3px solid #fff' : '3px solid transparent',
            marginBottom: '-2px', fontFamily: 'Inter, sans-serif'
          }}>
            {t === 'working' ? 'Working On' : t === 'blog' ? 'Blog Posts' : 'Projects'}
          </button>
        ))}
      </div>

      {/* PROJECTS TAB */}
      {tab === 'projects' && (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '3rem' }}>
          <div>
            <p style={{ fontWeight: 900, fontSize: '0.85rem', letterSpacing: '0.1em', textTransform: 'uppercase', color: '#888', marginBottom: '1.25rem' }}>Add New Project</p>
            <div style={{ border: '2px solid #333', padding: '1.5rem', backgroundColor: '#1a1a1a' }}>
              <form onSubmit={addProject}>
                <label style={{ display: 'block', fontSize: '0.75rem', fontWeight: 900, letterSpacing: '0.1em', textTransform: 'uppercase', color: '#888', marginBottom: '0.4rem' }}>Title</label>
                <input id="p-title" className="admin-input" placeholder="e.g. TheCommonCo" required />
                <label style={{ display: 'block', fontSize: '0.75rem', fontWeight: 900, letterSpacing: '0.1em', textTransform: 'uppercase', color: '#888', marginBottom: '0.4rem' }}>Subtitle</label>
                <input id="p-subtitle" className="admin-input" placeholder="e.g. 2025 — Streetwear Brand" required />
                <label style={{ display: 'block', fontSize: '0.75rem', fontWeight: 900, letterSpacing: '0.1em', textTransform: 'uppercase', color: '#888', marginBottom: '0.4rem' }}>Description</label>
                <textarea id="p-desc" className="admin-textarea" placeholder="What's this project about?" required />
                <label style={{ display: 'block', fontSize: '0.75rem', fontWeight: 900, letterSpacing: '0.1em', textTransform: 'uppercase', color: '#888', marginBottom: '0.4rem' }}>Image URL</label>
                <input id="p-image" type="url" className="admin-input" placeholder="https://..." required />
                <label style={{ display: 'block', fontSize: '0.75rem', fontWeight: 900, letterSpacing: '0.1em', textTransform: 'uppercase', color: '#888', marginBottom: '0.4rem' }}>Live URL</label>
                <input id="p-url" type="url" className="admin-input" placeholder="https://..." required />
                <button type="submit" className="admin-btn">Add Project</button>
              </form>
            </div>
          </div>
          <div>
            <p style={{ fontWeight: 900, fontSize: '0.85rem', letterSpacing: '0.1em', textTransform: 'uppercase', color: '#888', marginBottom: '1.25rem' }}>Existing Projects</p>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
              {projects.length === 0 ? <p style={{ color: '#888' }}>No projects yet.</p> : projects.map(p => (
                <div key={p.id} className="admin-list-item">
                  <div><div className="admin-list-item-title">{p.title}</div><div className="admin-list-item-sub">{p.subtitle}</div></div>
                  <button className="admin-delete-btn" onClick={() => deleteProject(p.id)}>Delete</button>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* BLOG TAB */}
      {tab === 'blog' && (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '3rem' }}>
          <div>
            <p style={{ fontWeight: 900, fontSize: '0.85rem', letterSpacing: '0.1em', textTransform: 'uppercase', color: '#888', marginBottom: '1.25rem' }}>Add New Post</p>
            <div style={{ border: '2px solid #333', padding: '1.5rem', backgroundColor: '#1a1a1a' }}>
              <form onSubmit={addPost}>
                <label style={{ display: 'block', fontSize: '0.75rem', fontWeight: 900, letterSpacing: '0.1em', textTransform: 'uppercase', color: '#888', marginBottom: '0.4rem' }}>Title</label>
                <input id="b-title" className="admin-input" placeholder="Post title" required />
                <label style={{ display: 'block', fontSize: '0.75rem', fontWeight: 900, letterSpacing: '0.1em', textTransform: 'uppercase', color: '#888', marginBottom: '0.4rem' }}>Date</label>
                <input id="b-date" type="date" className="admin-input" defaultValue={today} required />
                <label style={{ display: 'block', fontSize: '0.75rem', fontWeight: 900, letterSpacing: '0.1em', textTransform: 'uppercase', color: '#888', marginBottom: '0.4rem' }}>Content (Markdown supported)</label>
                <textarea id="b-content" className="admin-textarea" style={{ minHeight: '220px' }} placeholder="Write your post here..." required />
                <button type="submit" className="admin-btn">Publish Post</button>
              </form>
            </div>
          </div>
          <div>
            <p style={{ fontWeight: 900, fontSize: '0.85rem', letterSpacing: '0.1em', textTransform: 'uppercase', color: '#888', marginBottom: '1.25rem' }}>Existing Posts</p>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
              {posts.length === 0 ? <p style={{ color: '#888' }}>No posts yet.</p> : posts.map(p => (
                <div key={p.id} className="admin-list-item">
                  <div><div className="admin-list-item-title">{p.title}</div><div className="admin-list-item-sub">{p.date ? new Date(p.date).toLocaleDateString() : ''}</div></div>
                  <button className="admin-delete-btn" onClick={() => deletePost(p.id)}>Delete</button>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* WORKING ON TAB */}
      {tab === 'working' && (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '3rem' }}>
          <div>
            <p style={{ fontWeight: 900, fontSize: '0.85rem', letterSpacing: '0.1em', textTransform: 'uppercase', color: '#888', marginBottom: '1.25rem' }}>Add Card</p>
            <div style={{ border: '2px solid #333', padding: '1.5rem', backgroundColor: '#1a1a1a' }}>
              <form onSubmit={addWorking}>
                <label style={{ display: 'block', fontSize: '0.75rem', fontWeight: 900, letterSpacing: '0.1em', textTransform: 'uppercase', color: '#888', marginBottom: '0.4rem' }}>Title</label>
                <input id="w-title" className="admin-input" placeholder="e.g. SurFlow Events" required />
                <label style={{ display: 'block', fontSize: '0.75rem', fontWeight: 900, letterSpacing: '0.1em', textTransform: 'uppercase', color: '#888', marginBottom: '0.4rem' }}>Tag / Category</label>
                <input id="w-tag" className="admin-input" placeholder="e.g. Event Management" />
                <label style={{ display: 'block', fontSize: '0.75rem', fontWeight: 900, letterSpacing: '0.1em', textTransform: 'uppercase', color: '#888', marginBottom: '0.4rem' }}>Description</label>
                <textarea id="w-desc" className="admin-textarea" placeholder="What are you working on?" required />
                <label style={{ display: 'block', fontSize: '0.75rem', fontWeight: 900, letterSpacing: '0.1em', textTransform: 'uppercase', color: '#888', marginBottom: '0.4rem' }}>Status</label>
                <input id="w-status" className="admin-input" placeholder="e.g. Active / Building / Paused" />
                <button type="submit" className="admin-btn">Add Card</button>
              </form>
            </div>
          </div>
          <div>
            <p style={{ fontWeight: 900, fontSize: '0.85rem', letterSpacing: '0.1em', textTransform: 'uppercase', color: '#888', marginBottom: '1.25rem' }}>Existing Cards</p>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
              {working.length === 0 ? <p style={{ color: '#888' }}>No cards yet.</p> : working.map(w => (
                <div key={w.id} className="admin-list-item">
                  <div><div className="admin-list-item-title">{w.title}</div><div className="admin-list-item-sub">{w.tag} {w.status ? '· ' + w.status : ''}</div></div>
                  <button className="admin-delete-btn" onClick={() => deleteWorking(w.id)}>Delete</button>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      <div ref={toastRef} className="admin-toast" />
    </div>
  );
}
