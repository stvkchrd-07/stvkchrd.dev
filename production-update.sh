#!/bin/bash

echo "⚡ Upgrading to Full-Fledged Production Build..."

# Install lucide-react for sharp, minimalist icons
npm install lucide-react

mkdir -p config

# 1. Create a Central Site Config
cat << 'EOF' > config/site.ts
export const siteConfig = {
  name: "Satvik Chaturvedi",
  role: "Engineer. Architect. Founder.",
  status: "Shipping Active",
  description: "Building scalable intelligent systems and driving high-impact ventures. Clean code. Sharp execution.",
  links: {
    resume: "/resume.pdf",
    twitter: "https://x.com/your_twitter_handle",
    linkedin: "https://linkedin.com/in/your_linkedin_handle",
    github: "https://github.com/your_github_handle"
  },
  adminPin: process.env.NEXT_PUBLIC_ADMIN_PIN || "0000" // Default pin if env not set
};
EOF

# 2. Make Supabase Clients Safe (Won't crash if env is missing during build)
cat << 'EOF' > lib/supabase/server.ts
import { createClient } from '@supabase/supabase-js';

export function createServerSupabaseClient() {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
  const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';
  
  if (!supabaseUrl || !supabaseAnonKey) {
    console.warn("⚠️ Supabase credentials missing. Returning dummy client.");
    // Return a dummy client that safely fails queries instead of crashing the app
    return { from: () => ({ select: () => ({ order: () => ({ data: [], error: { message: "No DB configuration" } }) }) }) } as any;
  }

  return createClient(supabaseUrl, supabaseAnonKey, {
    auth: { persistSession: false, autoRefreshToken: false }
  });
}
EOF

cat << 'EOF' > lib/supabase/client.ts
import { createClient } from '@supabase/supabase-js';

export const createBrowserClient = () => {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
  const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';
  return createClient(supabaseUrl, supabaseAnonKey);
};
EOF

# 3. Update Home Page to use Config and handle DB errors gracefully
cat << 'EOF' > app/page.tsx
import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import LabSection from '@/components/LabSection';
import { createServerSupabaseClient } from '@/lib/supabase/server';
import { siteConfig } from '@/config/site';
import { Github, Twitter, Linkedin } from 'lucide-react';

export const dynamic = 'force-dynamic';

export default async function HomePage() {
  const supabase = createServerSupabaseClient();
  
  // Safe fetch with error handling
  const { data: workingOn, error } = await supabase
    .from('working_on')
    .select('*')
    .order('id', { ascending: false });

  if (error) {
    console.error("Database fetch error:", error);
  }

  const displayProjects = workingOn && workingOn.length > 0 ? workingOn : [];

  return (
    <>
      <SiteHeader active="home" />

      <main className="grid grid-cols-1 gap-12 md:gap-16 mt-8">
        <section className="grid grid-cols-1 lg:grid-cols-12 gap-4 md:gap-6">
          <div className="col-span-1 lg:col-span-8 neo-card p-6 md:p-12 flex flex-col justify-between min-h-[40vh]">
            <div>
              <p className="font-pixel text-electric text-lg md:text-2xl mb-4 uppercase tracking-widest bg-text text-bg inline-block px-2 py-1">
                &gt; System.Init()
              </p>
              <h1 className="text-4xl sm:text-5xl md:text-7xl font-black uppercase tracking-tighter leading-none mb-6">
                Engineer.<br />
                <span className="text-lime" style={{ WebkitTextStroke: '1px var(--text-color)' }}>Architect.</span><br />
                Founder.
              </h1>
            </div>
            <p className="max-w-md font-medium text-base md:text-lg leading-snug">
              {siteConfig.description}
            </p>
          </div>

          <div className="col-span-1 lg:col-span-4 flex flex-col gap-4 md:gap-6">
            <div className="neo-card p-6 flex flex-col justify-center items-center bg-lime text-black border-black">
              <h3 className="font-black text-2xl uppercase text-center">Status</h3>
              <p className="font-pixel text-lg mt-2 text-center bg-black text-lime px-3 py-1">{siteConfig.status}</p>
            </div>
            
            {/* DYNAMIC LINKED BUTTONS */}
            <div className="neo-card p-6 flex flex-col gap-3 justify-center bg-electric text-white border-black">
               <a href={siteConfig.links.resume} target="_blank" rel="noopener noreferrer" className="neo-btn text-center bg-white text-black px-4 py-3 w-full border-black hover:bg-lime hover:scale-[1.02] active:scale-95 text-lg block font-bold">
                 View Resume
               </a>
               <div className="flex gap-3">
                 <a href={siteConfig.links.twitter} target="_blank" rel="noopener noreferrer" className="neo-btn flex items-center justify-center flex-1 bg-black text-white py-3 border-white hover:bg-lime hover:text-black hover:border-black active:scale-95">
                   <Twitter size={20} />
                 </a>
                 <a href={siteConfig.links.linkedin} target="_blank" rel="noopener noreferrer" className="neo-btn flex items-center justify-center flex-1 bg-black text-white py-3 border-white hover:bg-lime hover:text-black hover:border-black active:scale-95">
                   <Linkedin size={20} />
                 </a>
                 <a href={siteConfig.links.github} target="_blank" rel="noopener noreferrer" className="neo-btn flex items-center justify-center flex-1 bg-black text-white py-3 border-white hover:bg-lime hover:text-black hover:border-black active:scale-95">
                   <Github size={20} />
                 </a>
               </div>
            </div>
          </div>
        </section>

        {error ? (
          <div className="neo-card p-8 bg-red-500 text-white font-pixel text-center text-xl">
             [ DATABASE CONNECTION FAILED ]
          </div>
        ) : (
          <LabSection projects={displayProjects} />
        )}
      </main>
      <SiteFooter />
    </>
  );
}
EOF

# 4. Completely Overhaul Admin Page (Auth + Read + Delete + Create)
cat << 'EOF' > app/admin/page.tsx
"use client";
import { useState, useEffect } from 'react';
import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import { createBrowserClient } from '@/lib/supabase/client';
import { siteConfig } from '@/config/site';
import { Trash2 } from 'lucide-react';

export default function AdminPage() {
  const [isAuth, setIsAuth] = useState(false);
  const [pinInput, setPinInput] = useState('');
  
  const [status, setStatus] = useState('');
  const [isUploading, setIsUploading] = useState(false);
  const [projects, setProjects] = useState<any[]>([]);
  
  const supabase = createBrowserClient();

  // Fetch existing projects
  const fetchProjects = async () => {
    const { data } = await supabase.from('working_on').select('*').order('id', { ascending: false });
    if (data) setProjects(data);
  };

  useEffect(() => {
    if (isAuth) fetchProjects();
  }, [isAuth]);

  // Auth Handler
  const handleAuth = (e: React.FormEvent) => {
    e.preventDefault();
    if (pinInput === siteConfig.adminPin) {
      setIsAuth(true);
    } else {
      setStatus('ACCESS DENIED: Invalid PIN');
      setTimeout(() => setStatus(''), 3000);
    }
  };

  // Upload Handler
  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsUploading(true);
    setStatus('Processing payload...');

    const formData = new FormData(e.currentTarget);
    const title = formData.get('title') as string;
    const description = formData.get('description') as string;
    const projectUrl = formData.get('projectUrl') as string;
    const imageFile = formData.get('imageFile') as File;

    let imageUrl = '';

    try {
      if (imageFile && imageFile.size > 0) {
        setStatus('Uploading image to bucket...');
        const fileExt = imageFile.name.split('.').pop();
        const fileName = `${Date.now()}.${fileExt}`;
        const filePath = `projects/${fileName}`;

        const { error: uploadError } = await supabase.storage.from('portfolio').upload(filePath, imageFile);
        if (uploadError) throw uploadError;

        const { data: publicUrlData } = supabase.storage.from('portfolio').getPublicUrl(filePath);
        imageUrl = publicUrlData.publicUrl;
      }

      setStatus('Writing to database...');
      const { error: insertError } = await supabase.from('working_on').insert([{ 
        title, description, image_url: imageUrl, project_url: projectUrl 
      }]);

      if (insertError) throw insertError;

      setStatus('SUCCESS: Project deployed.');
      (e.target as HTMLFormElement).reset();
      fetchProjects(); // Refresh the list
    } catch (error: any) {
      console.error(error);
      setStatus(`ERROR: ${error.message}`);
    } finally {
      setIsUploading(false);
      setTimeout(() => setStatus(''), 6000);
    }
  };

  // Delete Handler
  const handleDelete = async (id: number, imageUrl: string) => {
    if (!window.confirm("Are you sure you want to delete this project?")) return;
    
    setStatus('Deleting project...');
    try {
      // 1. Delete from DB
      const { error: deleteError } = await supabase.from('working_on').delete().eq('id', id);
      if (deleteError) throw deleteError;

      // 2. Attempt to delete image from storage (if it exists)
      if (imageUrl && imageUrl.includes('portfolio/projects/')) {
        const filePath = imageUrl.split('portfolio/')[1];
        await supabase.storage.from('portfolio').remove([filePath]);
      }

      setStatus('SUCCESS: Project deleted.');
      fetchProjects();
    } catch (error: any) {
      setStatus(`ERROR: ${error.message}`);
    } finally {
      setTimeout(() => setStatus(''), 4000);
    }
  };

  if (!isAuth) {
    return (
      <main className="min-h-screen flex items-center justify-center p-4 bg-bg">
        <form onSubmit={handleAuth} className="neo-card p-8 bg-card max-w-sm w-full flex flex-col gap-4">
           <h1 className="font-pixel text-3xl uppercase text-center text-electric">System.Login</h1>
           <input type="password" placeholder="Enter PIN" value={pinInput} onChange={e => setPinInput(e.target.value)} className="p-4 border-2 border-text text-center text-2xl tracking-widest font-pixel focus:outline-none focus:border-lime" autoFocus />
           <button type="submit" className="neo-btn bg-black text-lime py-3 uppercase">Authenticate</button>
           {status && <p className="text-red-500 font-bold text-center mt-2">{status}</p>}
        </form>
      </main>
    );
  }

  return (
    <>
      <SiteHeader active="admin" />
      <main className="max-w-5xl mx-auto mt-8 p-4 min-h-[70vh] grid grid-cols-1 md:grid-cols-2 gap-8">
        
        {/* LEFT: UPLOAD FORM */}
        <div className="neo-card p-6 md:p-8 bg-card self-start">
          <div className="flex items-center justify-between border-b-4 border-text pb-4 mb-6">
             <h1 className="font-black text-2xl uppercase">Deploy Project</h1>
             <span className="font-pixel bg-lime text-black px-2 py-1 border-2 border-black">SECURE</span>
          </div>
          
          <form onSubmit={handleSubmit} className="flex flex-col gap-4">
            <div className="flex flex-col gap-1">
              <label className="font-bold text-xs uppercase">Project Title</label>
              <input name="title" type="text" className="p-2 border-2 border-text bg-bg focus:outline-none focus:border-lime" required />
            </div>
            <div className="flex flex-col gap-1">
              <label className="font-bold text-xs uppercase">Description</label>
              <textarea name="description" className="p-2 border-2 border-text bg-bg h-24 focus:outline-none focus:border-lime" required></textarea>
            </div>
            <div className="flex flex-col gap-1">
              <label className="font-bold text-xs uppercase">Image Upload</label>
              <input name="imageFile" type="file" accept="image/*" className="p-2 border-2 border-text bg-bg text-sm file:mr-2 file:py-1 file:px-2 file:border-0 file:bg-lime file:font-bold file:cursor-pointer" />
            </div>
            <div className="flex flex-col gap-1">
              <label className="font-bold text-xs uppercase">Live URL</label>
              <input name="projectUrl" type="url" className="p-2 border-2 border-text bg-bg focus:outline-none focus:border-lime" />
            </div>
            <button disabled={isUploading} type="submit" className={`neo-btn text-white py-3 mt-2 ${isUploading ? 'bg-gray-500' : 'bg-electric hover:bg-lime hover:text-black'}`}>
              {isUploading ? 'Deploying...' : 'Upload Payload'}
            </button>
          </form>

          {status && (
            <div className={`mt-4 p-3 border-2 border-black font-pixel font-bold text-sm text-center ${status.includes('ERROR') ? 'bg-red-500 text-white' : 'bg-lime text-black animate-pulse'}`}>
              {status}
            </div>
          )}
        </div>

        {/* RIGHT: MANAGE PROJECTS */}
        <div className="neo-card p-6 md:p-8 bg-bg border-dashed self-start">
          <h1 className="font-black text-2xl uppercase border-b-4 border-text pb-4 mb-6">Manage Fleet</h1>
          
          <div className="flex flex-col gap-4 max-h-[60vh] overflow-y-auto pr-2">
            {projects.length === 0 ? (
              <p className="font-pixel opacity-50 text-center py-10">No projects deployed.</p>
            ) : (
              projects.map(proj => (
                <div key={proj.id} className="border-2 border-text bg-card p-3 flex items-center justify-between group">
                  <div className="flex items-center gap-3 overflow-hidden">
                    {proj.image_url ? (
                      <img src={proj.image_url} alt="thumb" className="w-12 h-12 object-cover border-2 border-text" />
                    ) : (
                      <div className="w-12 h-12 bg-black border-2 border-text"></div>
                    )}
                    <div>
                      <h3 className="font-bold uppercase line-clamp-1">{proj.title}</h3>
                      <a href={proj.project_url} target="_blank" className="text-xs text-electric hover:underline truncate block">Link</a>
                    </div>
                  </div>
                  <button onClick={() => handleDelete(proj.id, proj.image_url)} className="p-2 bg-red-500 text-white border-2 border-text hover:bg-black transition-colors" title="Delete Project">
                    <Trash2 size={18} />
                  </button>
                </div>
              ))
            )}
          </div>
        </div>

      </main>
    </>
  );
}
EOF

echo "✅ Update Complete!"
echo "⚠️ IMPORTANT NEXT STEPS:"
echo "1. Go to 'config/site.ts' to input your actual Twitter/LinkedIn URLs."
echo "2. Add 'NEXT_PUBLIC_ADMIN_PIN=1234' to your .env.local (Default is 0000)."
echo "3. Restart your dev server with 'npm run dev'."