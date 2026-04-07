"use client";
import { useState, useEffect } from 'react';
import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import { createBrowserClient } from '@/lib/supabase/client';
import { siteConfig } from '@/config/site';
import { Trash2, Image as ImageIcon } from 'lucide-react';

export default function AdminPage() {
  const [isAuth, setIsAuth] = useState(false);
  const [pinInput, setPinInput] = useState('');
  const [activeTab, setActiveTab] = useState<'projects' | 'blog'>('projects');
  
  const [status, setStatus] = useState('');
  const [isUploading, setIsUploading] = useState(false);
  const [projects, setProjects] = useState<any[]>([]);
  const [blogs, setBlogs] = useState<any[]>([]);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  
  const supabase = createBrowserClient();

  const fetchData = async () => {
    const { data: projData } = await supabase.from('working_on').select('*').order('id', { ascending: false });
    if (projData) setProjects(projData);

    const { data: blogData } = await supabase.from('blog_posts').select('*').order('created_at', { ascending: false });
    if (blogData) setBlogs(blogData);
  };

  useEffect(() => { if (isAuth) fetchData(); }, [isAuth]);

  const handleAuth = (e: React.FormEvent) => {
    e.preventDefault();
    if (pinInput === siteConfig.adminPin) setIsAuth(true);
    else { setStatus('ACCESS DENIED'); setTimeout(() => setStatus(''), 3000); }
  };

  // --- PROJECT UPLOAD HANDLER ---
  const handleProjectSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsUploading(true);
    setStatus('Deploying project...');
    const formData = new FormData(e.currentTarget);
    let imageUrl = '';
    try {
      const imageFile = formData.get('imageFile') as File;
      if (imageFile && imageFile.size > 0) {
        const filePath = `projects/${Date.now()}.${imageFile.name.split('.').pop()}`;
        await supabase.storage.from('portfolio').upload(filePath, imageFile);
        imageUrl = supabase.storage.from('portfolio').getPublicUrl(filePath).data.publicUrl;
      }
      await supabase.from('working_on').insert([{ 
        title: formData.get('title'), description: formData.get('description'), 
        image_url: imageUrl, project_url: formData.get('projectUrl') 
      }]);
      setStatus('SUCCESS: Project deployed.');
      (e.target as HTMLFormElement).reset(); setPreviewUrl(null); fetchData();
    } catch (err: any) { setStatus(`ERROR: ${err.message}`); } 
    finally { setIsUploading(false); setTimeout(() => setStatus(''), 4000); }
  };

  // --- BLOG UPLOAD HANDLER ---
  const handleBlogSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsUploading(true);
    setStatus('Publishing Log...');
    const formData = new FormData(e.currentTarget);
    const title = formData.get('title') as string;
    const slug = title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)+/g, ''); // Auto-generate slug
    
    try {
      await supabase.from('blog_posts').insert([{ 
        title, slug, content: formData.get('content') 
      }]);
      setStatus('SUCCESS: Log published.');
      (e.target as HTMLFormElement).reset(); fetchData();
    } catch (err: any) { setStatus(`ERROR: ${err.message}`); } 
    finally { setIsUploading(false); setTimeout(() => setStatus(''), 4000); }
  };

  const handleDelete = async (table: string, id: number, imageUrl?: string) => {
    if (!window.confirm("Confirm deletion?")) return;
    setStatus('Deleting...');
    try {
      await supabase.from(table).delete().eq('id', id);
      if (imageUrl && imageUrl.includes('portfolio/projects/')) {
        await supabase.storage.from('portfolio').remove([imageUrl.split('portfolio/')[1]]);
      }
      setStatus('SUCCESS: Deleted.'); fetchData();
    } catch (err: any) { setStatus(`ERROR: ${err.message}`); } 
    finally { setTimeout(() => setStatus(''), 3000); }
  };

  if (!isAuth) return (
    <main className="min-h-screen flex items-center justify-center p-4 relative z-50">
      <form onSubmit={handleAuth} className="neo-card p-8 bg-card max-w-sm w-full flex flex-col gap-4">
         <h1 className="font-pixel text-3xl text-center text-electric">System.Login</h1>
         <input type="password" value={pinInput} onChange={e => setPinInput(e.target.value)} className="p-4 border-2 border-text text-center text-2xl font-pixel focus:outline-none focus:border-lime" autoFocus />
         <button type="submit" className="neo-btn bg-black text-lime py-3">Auth</button>
         {status && <p className="text-red-500 font-bold text-center mt-2">{status}</p>}
      </form>
    </main>
  );

  return (
    <>
      <SiteHeader active="admin" />
      <main className="max-w-5xl mx-auto mt-8 p-4 min-h-[70vh] relative z-50">
        
        {/* TABS */}
        <div className="flex gap-4 mb-8 border-b-4 border-text pb-4">
          <button onClick={() => setActiveTab('projects')} className={`neo-btn px-6 py-2 text-xl font-black ${activeTab === 'projects' ? 'bg-lime text-black border-black' : 'bg-bg text-text'}`}>[ LAB PROJECTS ]</button>
          <button onClick={() => setActiveTab('blog')} className={`neo-btn px-6 py-2 text-xl font-black ${activeTab === 'blog' ? 'bg-electric text-white border-black' : 'bg-bg text-text'}`}>[ MDX LOGS ]</button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {/* UPLOAD FORM (DYNAMIC) */}
          <div className="neo-card p-6 md:p-8 bg-card self-start">
            <h1 className="font-black text-2xl uppercase mb-6">{activeTab === 'projects' ? 'Deploy Project' : 'Write Log'}</h1>
            
            {activeTab === 'projects' ? (
              <form onSubmit={handleProjectSubmit} className="flex flex-col gap-4">
                <input name="title" placeholder="Title" type="text" className="p-2 border-2 border-text bg-bg" required />
                <textarea name="description" placeholder="Description" className="p-2 border-2 border-text bg-bg h-24" required></textarea>
                <input name="imageFile" type="file" accept="image/*" onChange={(e) => setPreviewUrl(e.target.files?.[0] ? URL.createObjectURL(e.target.files[0]) : null)} className="p-2 border-2 border-text bg-bg text-sm file:mr-2 file:bg-lime file:border-0 file:font-bold" />
                {previewUrl && <img src={previewUrl} className="w-full h-32 object-cover border-2 border-text" />}
                <input name="projectUrl" placeholder="Live URL" type="url" className="p-2 border-2 border-text bg-bg" />
                <button disabled={isUploading} type="submit" className="neo-btn text-white py-3 mt-2 bg-electric hover:bg-lime hover:text-black">Upload Payload</button>
              </form>
            ) : (
              <form onSubmit={handleBlogSubmit} className="flex flex-col gap-4">
                <input name="title" placeholder="Log Title" type="text" className="p-2 border-2 border-text bg-bg font-bold text-lg" required />
                <textarea name="content" placeholder="Write in Markdown (# Heading, **bold**, etc)..." className="p-4 border-2 border-text bg-bg h-64 font-pixel text-lg" required></textarea>
                <button disabled={isUploading} type="submit" className="neo-btn text-white py-3 mt-2 bg-electric hover:bg-lime hover:text-black">Publish Markdown</button>
              </form>
            )}
            {status && <div className="mt-4 p-3 border-2 border-black font-pixel font-bold text-center bg-lime text-black">{status}</div>}
          </div>

          {/* MANAGE (DYNAMIC) */}
          <div className="neo-card p-6 md:p-8 bg-bg border-dashed self-start">
            <h1 className="font-black text-2xl uppercase mb-6">Manage Data</h1>
            <div className="flex flex-col gap-4 max-h-[60vh] overflow-y-auto pr-2">
              {(activeTab === 'projects' ? projects : blogs).map(item => (
                <div key={item.id} className="border-2 border-text bg-card p-3 flex items-center justify-between">
                  <div className="flex-1 overflow-hidden pr-4">
                    <h3 className="font-bold uppercase truncate">{item.title}</h3>
                    <p className="text-xs font-pixel opacity-70 truncate">{activeTab === 'projects' ? item.project_url : `Slug: /${item.slug}`}</p>
                  </div>
                  <button onClick={() => handleDelete(activeTab === 'projects' ? 'working_on' : 'blog_posts', item.id, item.image_url)} className="p-2 bg-red-500 text-white border-2 border-text hover:bg-black">
                    <Trash2 size={18} />
                  </button>
                </div>
              ))}
            </div>
          </div>
        </div>
      </main>
    </>
  );
}
