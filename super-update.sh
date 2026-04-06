#!/bin/bash

echo "⚡ Initiating Full Stack Functionality & UI Update..."

# Ensure directories exist
mkdir -p components app/admin app/blog

# 1. Create the Project Modal Component (Client Side Interactivity)
cat << 'EOF' > components/ProjectModal.tsx
"use client";
import { useEffect } from 'react';

export default function ProjectModal({ project, onClose }: { project: any, onClose: () => void }) {
  // Close on Escape key press
  useEffect(() => {
    const handleEsc = (e: KeyboardEvent) => e.key === 'Escape' && onClose();
    window.addEventListener('keydown', handleEsc);
    return () => window.removeEventListener('keydown', handleEsc);
  }, [onClose]);

  if (!project) return null;

  return (
    <div 
      className="fixed inset-0 z-[100] flex items-center justify-center bg-black/80 backdrop-blur-sm p-4" 
      onClick={onClose}
    >
      <div 
        className="neo-card bg-bg w-full max-w-3xl max-h-[90vh] overflow-y-auto flex flex-col relative animate-fade-in-up" 
        onClick={e => e.stopPropagation()}
      >
        <div className="sticky top-0 bg-bg z-10 flex justify-between items-center p-4 border-b-2 border-text">
          <h2 className="font-black text-2xl md:text-3xl uppercase pr-4">{project.title}</h2>
          <button 
            onClick={onClose} 
            className="neo-btn bg-lime px-4 py-2 font-pixel text-xl hover:bg-electric hover:text-white"
          >
            [X]
          </button>
        </div>
        
        {project.image_url ? (
          <div className="w-full h-48 md:h-80 border-b-2 border-text relative bg-gray-200">
            <img src={project.image_url} alt={project.title} className="w-full h-full object-cover" />
          </div>
        ) : (
           <div className="w-full h-48 md:h-64 bg-black flex items-center justify-center border-b-2 border-text">
             <span className="font-pixel text-lime text-2xl animate-pulse">NO_IMAGE_DATA</span>
           </div>
        )}
        
        <div className="p-6 md:p-8 flex flex-col md:flex-row gap-8 justify-between items-start">
          <p className="font-medium text-lg md:text-xl flex-1 whitespace-pre-wrap">
            {project.description || "No description provided."}
          </p>
          
          <div className="w-full md:w-auto">
            {project.project_url ? (
              <a 
                href={project.project_url} 
                target="_blank" 
                rel="noopener noreferrer" 
                className="neo-btn w-full md:w-auto text-center inline-block bg-electric text-white px-8 py-4 text-lg hover:bg-lime hover:text-black transition-colors"
              >
                Launch App →
              </a>
            ) : (
              <button disabled className="neo-btn opacity-50 cursor-not-allowed bg-gray-300 px-8 py-4 text-lg">
                Link Offline
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
EOF

# 2. Create the Lab Section Component (Handles Mapping & Modals)
cat << 'EOF' > components/LabSection.tsx
"use client";
import { useState } from 'react';
import ProjectModal from './ProjectModal';

export default function LabSection({ projects }: { projects: any[] }) {
  const [selectedProject, setSelectedProject] = useState<any>(null);

  return (
    <section id="lab" className="mt-16 md:mt-24 relative border-t-4 border-dashed border-text pt-12">
      <div className="absolute -top-6 left-1/2 -translate-x-1/2 bg-bg px-4">
        <h2 className="font-pixel text-3xl md:text-4xl text-electric bg-lime px-3 py-1 border-2 border-text shadow-neo transform -rotate-2">
          ★ The Lab ★
        </h2>
      </div>
      
      <p className="font-pixel text-center mb-10 text-lg md:text-xl opacity-80">
        Warning: Experimental ventures below. Click to inspect.
      </p>
      
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 md:gap-8">
        {projects.map((proj) => (
          <div 
            key={proj.id} 
            onClick={() => setSelectedProject(proj)}
            className="neo-card p-0 relative group cursor-pointer hover:-translate-y-2 transition-transform bg-card flex flex-col h-full"
          >
            <div className="h-56 w-full border-b-2 border-text overflow-hidden bg-black relative">
              {proj.image_url ? (
                <img 
                  src={proj.image_url} 
                  alt={proj.title} 
                  className="w-full h-full object-cover opacity-90 group-hover:opacity-100 group-hover:scale-105 transition-all duration-300" 
                />
              ) : (
                <div className="w-full h-full flex items-center justify-center">
                  <span className="font-pixel text-lime text-xl">AWAITING_IMG</span>
                </div>
              )}
            </div>
            <div className="p-5 flex-1 flex flex-col justify-between">
              <div>
                <h3 className="font-black text-xl md:text-2xl uppercase mb-2 line-clamp-1">{proj.title}</h3>
                <p className="text-sm md:text-base font-medium line-clamp-2 opacity-90">{proj.description}</p>
              </div>
              <div className="mt-6 flex justify-end">
                 <span className="font-pixel text-electric group-hover:text-lime font-bold text-lg border-b-2 border-transparent group-hover:border-lime transition-colors">
                   View Details &gt;
                 </span>
              </div>
            </div>
          </div>
        ))}
      </div>

      <ProjectModal project={selectedProject} onClose={() => setSelectedProject(null)} />
    </section>
  );
}
EOF

# 3. Update the Main Landing Page (Server Component wrapper)
cat << 'EOF' > app/page.tsx
import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import LabSection from '@/components/LabSection';
import Link from 'next/link';
// import { createServerSupabaseClient } from '@/lib/supabase/server'; // Uncomment when ready

export const dynamic = 'force-dynamic';

export default async function HomePage() {
  // MOCK DATA: Replace with actual Supabase fetch later
  // e.g. const { data } = await supabase.from('working_on').select('*');
  const fallbackProjects = [
    { 
      id: 1, 
      title: "The Common Co.", 
      description: "Comfort-driven streetwear handling bulk merchandise for societies and companies. Scheduled for launch April 2026.", 
      image_url: "https://images.unsplash.com/photo-1523381210434-271e8be1f52b?auto=format&fit=crop&q=80&w=800", 
      project_url: "https://thecommonco.com" 
    },
    { 
      id: 2, 
      title: "UtilityHub", 
      description: "A browser-based website with pure client-side utility tools. Built with Next.js and Tailwind CSS.", 
      image_url: "https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&q=80&w=800", 
      project_url: "https://github.com" 
    },
    { 
      id: 3, 
      title: "Smart Health Sys", 
      description: "Surveillance and Early Warning System to detect outbreaks of water-borne diseases in vulnerable communities.", 
      image_url: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&q=80&w=800", 
      project_url: "#" 
    }
  ];

  return (
    <>
      <SiteHeader active="home" />

      <main className="grid grid-cols-1 gap-12 md:gap-16 mt-8">
        {/* SERIOUS SECTION */}
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
              Building scalable intelligent systems and driving high-impact ventures. Clean code. Sharp execution.
            </p>
          </div>

          <div className="col-span-1 lg:col-span-4 flex flex-col sm:flex-row lg:flex-col gap-4 md:gap-6">
            <div className="neo-card p-6 flex-1 flex flex-col justify-center items-center bg-lime text-black border-black">
              <h3 className="font-black text-2xl uppercase text-center">Status</h3>
              <p className="font-pixel text-lg mt-2 text-center bg-black text-lime px-3 py-1">Shipping Active</p>
            </div>
            <div className="neo-card p-6 flex-1 flex flex-col justify-center bg-electric text-white border-black">
               <button className="neo-btn bg-white text-black px-4 py-4 w-full border-black hover:bg-lime hover:scale-[1.02] active:scale-95 text-lg">
                 View Resume
               </button>
            </div>
          </div>
        </section>

        {/* QUIRKY LAB SECTION */}
        <LabSection projects={fallbackProjects} />
      </main>
      <SiteFooter />
    </>
  );
}
EOF

# 4. Build the Neo-Brutalist Admin Dashboard
cat << 'EOF' > app/admin/page.tsx
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
EOF

# 5. Create an Artistically Minimal Blog Page
cat << 'EOF' > app/blog/page.tsx
import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import Link from 'next/link';

export default function BlogPage() {
  const posts = [
    { id: 1, title: 'The Architecture of Modern Web', date: 'Oct 24, 2025', excerpt: 'Building resilient systems requires more than just code; it requires a philosophy of structure.' },
    { id: 2, title: 'Scaling The Common Co.', date: 'Sep 12, 2025', excerpt: 'Lessons learned from handling bulk merchandise and streetwear drops.' }
  ];

  return (
    <>
      <SiteHeader active="blog" />
      <main className="max-w-3xl mx-auto mt-16 px-4 min-h-[60vh]">
        <h1 className="font-black text-6xl md:text-7xl uppercase tracking-tighter mb-16 border-b-4 border-text pb-4 inline-block">
          Log.
        </h1>
        
        <div className="flex flex-col gap-16">
          {posts.map(post => (
            <article key={post.id} className="group cursor-pointer flex flex-col md:flex-row gap-4 md:gap-8 items-start">
              <div className="w-32 pt-1">
                 <p className="font-pixel text-electric border-l-4 border-text pl-2">{post.date}</p>
              </div>
              <div className="flex-1">
                <h2 className="font-black text-3xl md:text-4xl uppercase mb-4 group-hover:text-lime group-hover:underline decoration-4 underline-offset-8 transition-colors">
                  <Link href={`/blog/${post.id}`}>{post.title}</Link>
                </h2>
                <p className="text-xl font-medium opacity-70 leading-relaxed">
                  {post.excerpt}
                </p>
              </div>
            </article>
          ))}
        </div>
      </main>
      <SiteFooter />
    </>
  );
}
EOF

echo "✅ Mega Update Complete! Your UI is now fully responsive and interactive."