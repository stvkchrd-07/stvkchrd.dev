#!/bin/bash

echo "🚀 Installing Markdown & Typography engines..."
npm install react-markdown @tailwindcss/typography date-fns

# 1. Update Tailwind Config to include the Typography plugin
cat << 'EOF' > tailwind.config.ts
import type { Config } from "tailwindcss";

export default {
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['var(--font-inter)', 'sans-serif'],
        pixel: ['var(--font-vt323)', 'monospace'],
      },
      colors: {
        bg: 'var(--bg-color)',
        text: 'var(--text-color)',
        card: 'var(--card-bg)',
        lime: '#CCFF00',
        electric: '#0000FF',
      },
      boxShadow: {
        'neo': '4px 4px 0px 0px var(--text-color)',
        'neo-hover': '2px 2px 0px 0px var(--text-color)',
      }
    },
  },
  plugins: [
    require('@tailwindcss/typography'),
  ],
} satisfies Config;
EOF

# 2. Update Site Config to add the specific GitHub username for the API
cat << 'EOF' > config/site.ts
export const siteConfig = {
  name: "Satvik Chaturvedi",
  role: "Engineer. Architect. Founder.",
  status: "Shipping Active",
  description: "Building scalable intelligent systems and driving high-impact ventures. Clean code. Sharp execution.",
  links: {
    resume: "/Resume.pdf",
    twitter: "https://x.com/your_twitter_handle",
    linkedin: "https://linkedin.com/in/your_linkedin_handle",
    github: "https://github.com/your_github_handle"
  },
  githubUsername: "your_github_handle", // <-- Add your GitHub username here
  adminPin: process.env.NEXT_PUBLIC_ADMIN_PIN || "0000"
};
EOF

# 3. Update Homepage to fetch Live GitHub Status
cat << 'EOF' > app/page.tsx
import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import LabSection from '@/components/LabSection';
import { createServerSupabaseClient } from '@/lib/supabase/server';
import { siteConfig } from '@/config/site';

// Fetch live GitHub status (Caches for 1 hour to prevent API limits)
async function getGithubStatus() {
  try {
    const res = await fetch(`https://api.github.com/users/${siteConfig.githubUsername}/events/public`, { next: { revalidate: 3600 } });
    if (!res.ok) return siteConfig.status;
    const events = await res.json();
    const pushEvent = events.find((e: any) => e.type === "PushEvent");
    if (pushEvent) {
      const repoName = pushEvent.repo.name.split('/')[1];
      return `Building: ${repoName}`;
    }
    return siteConfig.status;
  } catch {
    return siteConfig.status;
  }
}

const TwitterIcon = ({ size = 20 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M22 4s-.7 2.1-2 3.4c1.6 10-9.4 17.3-18 11.6 2.2.1 4.4-.6 6-2C3 15.5.5 9.6 3 5c2.2 2.6 5.6 4.1 9 4-.9-4.2 4-6.6 7-3.8 1.1 0 3-1.2 3-1.2z"></path>
  </svg>
);

const LinkedinIcon = ({ size = 20 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M16 8a6 6 0 0 1 6 6v7h-4v-7a2 2 0 0 0-2-2 2 2 0 0 0-2 2v7h-4v-7a6 6 0 0 1 6-6z"></path>
    <rect width="4" height="12" x="2" y="9"></rect>
    <circle cx="4" cy="4" r="2"></circle>
  </svg>
);

const GithubIcon = ({ size = 20 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M15 22v-4a4.8 4.8 0 0 0-1-3.24c3-.34 6-1.53 6-6.76a5.2 5.2 0 0 0-1.5-3.8 5.2 5.2 0 0 0-.1-3.8s-1.2-.4-3.9 1.4a13.3 13.3 0 0 0-7 0c-2.7-1.8-3.9-1.4-3.9-1.4a5.2 5.2 0 0 0-.1 3.8 5.2 5.2 0 0 0-1.5 3.8c0 5.2 3 6.4 6 6.76a4.8 4.8 0 0 0-1 3.24v4"></path>
    <path d="M9 18c-4.51 2-5-2-7-2"></path>
  </svg>
);

export const dynamic = 'force-dynamic';

export default async function HomePage() {
  const supabase = createServerSupabaseClient();
  const githubStatus = await getGithubStatus();
  
  const { data: workingOn, error } = await supabase.from('working_on').select('*').order('id', { ascending: false });
  if (error) console.error("Database fetch error:", error);

  const displayProjects = workingOn && workingOn.length > 0 ? workingOn : [];

  return (
    <>
      <SiteHeader active="home" />
      <main className="grid grid-cols-1 gap-12 md:gap-16 mt-8 relative z-30">
        <section className="grid grid-cols-1 lg:grid-cols-12 gap-4 md:gap-6">
          <div className="col-span-1 lg:col-span-8 neo-card p-6 md:p-12 flex flex-col justify-between min-h-[40vh] relative z-40">
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
            <div className="neo-card p-6 flex flex-col justify-center items-center bg-lime text-black border-black relative z-40">
              <h3 className="font-black text-2xl uppercase text-center">Live Status</h3>
              {/* LIVE GITHUB API STATUS */}
              <p className="font-pixel text-lg mt-2 text-center bg-black text-lime px-3 py-1 truncate w-full" title={githubStatus}>{githubStatus}</p>
            </div>
            
            <div className="neo-card p-6 flex flex-col gap-3 justify-center bg-electric text-white border-black relative z-50">
               <a href={siteConfig.links.resume} target="_blank" rel="noopener noreferrer" className="neo-btn text-center bg-white text-black px-4 py-3 w-full border-black hover:bg-lime hover:scale-[1.02] active:scale-95 text-lg block font-bold cursor-pointer">
                 View Resume
               </a>
               <div className="flex gap-3">
                 <a href={siteConfig.links.twitter} target="_blank" rel="noopener noreferrer" className="neo-btn flex items-center justify-center flex-1 bg-black text-white py-3 border-white hover:bg-lime hover:text-black hover:border-black active:scale-95 cursor-pointer">
                   <TwitterIcon size={20} />
                 </a>
                 <a href={siteConfig.links.linkedin} target="_blank" rel="noopener noreferrer" className="neo-btn flex items-center justify-center flex-1 bg-black text-white py-3 border-white hover:bg-lime hover:text-black hover:border-black active:scale-95 cursor-pointer">
                   <LinkedinIcon size={20} />
                 </a>
                 <a href={siteConfig.links.github} target="_blank" rel="noopener noreferrer" className="neo-btn flex items-center justify-center flex-1 bg-black text-white py-3 border-white hover:bg-lime hover:text-black hover:border-black active:scale-95 cursor-pointer">
                   <GithubIcon size={20} />
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

# 4. Overhaul Admin Page to add Blog Editor Tab
cat << 'EOF' > app/admin/page.tsx
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
EOF

# 5. Build Dynamic Blog List Page
cat << 'EOF' > app/blog/page.tsx
import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import Link from 'next/link';
import { createServerSupabaseClient } from '@/lib/supabase/server';
import { format } from 'date-fns';

export const dynamic = 'force-dynamic';

export default async function BlogPage() {
  const supabase = createServerSupabaseClient();
  const { data: posts } = await supabase.from('blog_posts').select('*').order('created_at', { ascending: false });

  return (
    <>
      <SiteHeader active="blog" />
      <main className="max-w-3xl mx-auto mt-16 px-4 min-h-[60vh] relative z-30">
        <h1 className="font-black text-6xl md:text-7xl uppercase tracking-tighter mb-16 border-b-4 border-text pb-4 inline-block bg-lime px-2 shadow-neo transform -rotate-1">
          System.Log()
        </h1>
        
        <div className="flex flex-col gap-12">
          {!posts || posts.length === 0 ? (
            <p className="font-pixel text-xl opacity-50">No logs found. Database empty.</p>
          ) : (
            posts.map((post) => (
              <article key={post.id} className="group cursor-pointer flex flex-col md:flex-row gap-4 md:gap-8 items-start neo-card p-6 hover:-translate-y-1 transition-transform">
                <div className="w-full md:w-32 pt-1 border-b-2 md:border-b-0 md:border-l-4 border-text md:pl-4 pb-2 md:pb-0 mb-2 md:mb-0">
                   <p className="font-pixel text-electric font-bold">
                     {format(new Date(post.created_at), 'MMM dd, yyyy')}
                   </p>
                </div>
                <div className="flex-1 w-full">
                  <h2 className="font-black text-2xl md:text-3xl uppercase mb-3">
                    <Link href={`/blog/${post.slug}`} className="hover:text-electric hover:underline decoration-4 underline-offset-4 transition-colors before:content-['>_'] before:text-lime before:mr-2">
                      {post.title}
                    </Link>
                  </h2>
                  <p className="text-base font-medium opacity-80 leading-relaxed line-clamp-2">
                    {/* Simple regex to strip markdown characters for excerpt */}
                    {post.content.replace(/[#*`_>]/g, '')}
                  </p>
                </div>
              </article>
            ))
          )}
        </div>
      </main>
      <SiteFooter />
    </>
  );
}
EOF

# 6. Build the Single Markdown Render Page
mkdir -p app/blog/\[slug\]
cat << 'EOF' > app/blog/\[slug\]/page.tsx
import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import ReactMarkdown from 'react-markdown';
import { createServerSupabaseClient } from '@/lib/supabase/server';
import { format } from 'date-fns';
import { notFound } from 'next/navigation';
import Link from 'next/link';

export const dynamic = 'force-dynamic';

export default async function SingleBlogPage({ params }: { params: { slug: string } }) {
  const supabase = createServerSupabaseClient();
  const { data: post } = await supabase.from('blog_posts').select('*').eq('slug', params.slug).single();

  if (!post) {
    notFound();
  }

  return (
    <>
      <SiteHeader active="blog" />
      <main className="max-w-3xl mx-auto mt-12 px-4 min-h-[60vh] relative z-30 pb-20">
        
        <Link href="/blog" className="font-pixel text-electric hover:text-lime hover:underline mb-8 inline-block font-bold">
          &lt;- RETURN TO LOGS
        </Link>

        <header className="mb-12 border-b-4 border-text pb-8">
          <h1 className="font-black text-4xl md:text-6xl uppercase tracking-tighter leading-none mb-4">
            {post.title}
          </h1>
          <div className="flex items-center gap-4 font-pixel">
            <span className="bg-black text-lime px-2 py-1">AUTHOR: ADMIN</span>
            <span className="opacity-60">{format(new Date(post.created_at), 'MMMM do, yyyy')}</span>
          </div>
        </header>
        
        {/* The Prose class utilizes the Tailwind Typography plugin we just installed */}
        <article className="prose prose-lg prose-neutral dark:prose-invert max-w-none 
          prose-headings:font-black prose-headings:uppercase prose-headings:tracking-tight
          prose-a:text-electric prose-a:font-bold prose-a:underline prose-a:decoration-2 hover:prose-a:text-lime
          prose-p:font-medium prose-p:leading-relaxed prose-p:text-lg
          prose-pre:bg-card prose-pre:border-2 prose-pre:border-text prose-pre:rounded-none prose-pre:shadow-neo
          prose-img:border-2 prose-img:border-text prose-img:shadow-neo">
          <ReactMarkdown>{post.content}</ReactMarkdown>
        </article>

      </main>
      <SiteFooter />
    </>
  );
}
EOF

echo "✅ Blog Architecture and GitHub API installed! Restart server using 'npm run dev'."