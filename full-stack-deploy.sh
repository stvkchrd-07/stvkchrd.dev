#!/bin/bash

echo "⚙️ Installing dependencies (Framer Motion & Supabase Client)..."
npm install framer-motion @supabase/supabase-js

# Ensure directories exist
mkdir -p components lib/supabase app/admin

# 1. Create a Browser Supabase Client for the Admin upload
cat << 'EOF' > lib/supabase/client.ts
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';

export const createBrowserClient = () => createClient(supabaseUrl, supabaseAnonKey);
EOF

# 2. Update LabSection to use Framer Motion's AnimatePresence
cat << 'EOF' > components/LabSection.tsx
"use client";
import { useState } from 'react';
import ProjectModal from './ProjectModal';
import { AnimatePresence } from 'framer-motion';

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

      <AnimatePresence>
        {selectedProject && (
          <ProjectModal project={selectedProject} onClose={() => setSelectedProject(null)} />
        )}
      </AnimatePresence>
    </section>
  );
}
EOF

# 3. Update Project Modal with Aggressive Framer Motion Snaps
cat << 'EOF' > components/ProjectModal.tsx
"use client";
import { useEffect } from 'react';
import { motion } from 'framer-motion';

export default function ProjectModal({ project, onClose }: { project: any, onClose: () => void }) {
  useEffect(() => {
    const handleEsc = (e: KeyboardEvent) => e.key === 'Escape' && onClose();
    window.addEventListener('keydown', handleEsc);
    return () => window.removeEventListener('keydown', handleEsc);
  }, [onClose]);

  return (
    <div 
      className="fixed inset-0 z-[100] flex items-center justify-center bg-black/80 backdrop-blur-sm p-4" 
      onClick={onClose}
    >
      <motion.div 
        initial={{ opacity: 0, scale: 0.9, y: 40 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.95, y: 20 }}
        transition={{ type: "spring", stiffness: 500, damping: 25 }}
        className="neo-card bg-bg w-full max-w-3xl max-h-[90vh] overflow-y-auto flex flex-col relative" 
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
            {project.description}
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
      </motion.div>
    </div>
  );
}
EOF

# 4. Wire up Admin Dashboard to Upload Images & Insert to Supabase
cat << 'EOF' > app/admin/page.tsx
"use client";
import { useState } from 'react';
import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import { createBrowserClient } from '@/lib/supabase/client';

export default function AdminPage() {
  const [status, setStatus] = useState('');
  const [isUploading, setIsUploading] = useState(false);
  const supabase = createBrowserClient();

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
      // 1. Upload Image to Storage if provided
      if (imageFile && imageFile.size > 0) {
        setStatus('Uploading image to bucket...');
        const fileExt = imageFile.name.split('.').pop();
        const fileName = `${Date.now()}.${fileExt}`;
        const filePath = `projects/${fileName}`;

        const { error: uploadError } = await supabase.storage
          .from('portfolio')
          .upload(filePath, imageFile);

        if (uploadError) throw uploadError;

        const { data: publicUrlData } = supabase.storage
          .from('portfolio')
          .getPublicUrl(filePath);
          
        imageUrl = publicUrlData.publicUrl;
      }

      // 2. Insert into Database
      setStatus('Writing to database...');
      const { error: insertError } = await supabase
        .from('working_on')
        .insert([{ 
          title, 
          description, 
          image_url: imageUrl, 
          project_url: projectUrl 
        }]);

      if (insertError) throw insertError;

      setStatus('SUCCESS: Project deployed.');
      (e.target as HTMLFormElement).reset();
    } catch (error: any) {
      console.error(error);
      setStatus(`ERROR: ${error.message}`);
    } finally {
      setIsUploading(false);
      setTimeout(() => setStatus(''), 6000);
    }
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
                <input name="title" type="text" placeholder="e.g. Toefury" className="p-3 border-2 border-text font-sans bg-card focus:outline-none focus:border-lime" required />
              </div>

              <div className="flex flex-col gap-1">
                <label className="font-bold text-sm uppercase">Detailed Description</label>
                <textarea name="description" placeholder="Appears in the pop-up modal..." className="p-3 border-2 border-text font-sans bg-card h-32 focus:outline-none focus:border-lime" required></textarea>
              </div>

              <div className="flex flex-col gap-1">
                <label className="font-bold text-sm uppercase">Upload Landing Page Screenshot</label>
                <input name="imageFile" type="file" accept="image/*" className="p-3 border-2 border-text font-sans bg-card focus:outline-none focus:border-lime file:mr-4 file:py-2 file:px-4 file:border-0 file:bg-lime file:text-black file:font-bold file:cursor-pointer hover:file:bg-electric hover:file:text-white" required />
              </div>

              <div className="flex flex-col gap-1">
                <label className="font-bold text-sm uppercase">Live URL / Repo Link</label>
                <input name="projectUrl" type="url" placeholder="https://..." className="p-3 border-2 border-text font-sans bg-card focus:outline-none focus:border-lime" />
              </div>
              
              <button disabled={isUploading} type="submit" className={`neo-btn text-white py-4 mt-4 text-xl transition-colors w-full ${isUploading ? 'bg-gray-500 cursor-not-allowed' : 'bg-electric hover:bg-lime hover:text-black'}`}>
                {isUploading ? 'Deploying...' : 'Upload & Deploy'}
              </button>
            </form>

            {status && (
              <div className={`mt-6 p-4 border-2 border-black font-pixel font-bold text-lg text-center ${status.includes('ERROR') ? 'bg-red-500 text-white' : 'bg-lime text-black animate-pulse'}`}>
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

# 5. Connect Frontend Home Page to Real Data & Activate Links
cat << 'EOF' > app/page.tsx
import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import LabSection from '@/components/LabSection';
import { createServerSupabaseClient } from '@/lib/supabase/server';

export const dynamic = 'force-dynamic';

export default async function HomePage() {
  const supabase = createServerSupabaseClient();
  
  // Fetch real data from the database
  const { data: workingOn } = await supabase
    .from('working_on')
    .select('*')
    .order('id', { ascending: false });

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
              Building scalable intelligent systems and driving high-impact ventures. Clean code. Sharp execution.
            </p>
          </div>

          <div className="col-span-1 lg:col-span-4 flex flex-col gap-4 md:gap-6">
            <div className="neo-card p-6 flex flex-col justify-center items-center bg-lime text-black border-black">
              <h3 className="font-black text-2xl uppercase text-center">Status</h3>
              <p className="font-pixel text-lg mt-2 text-center bg-black text-lime px-3 py-1">Shipping Active</p>
            </div>
            
            {/* LINKED BUTTONS SECTION */}
            <div className="neo-card p-6 flex flex-col gap-3 justify-center bg-electric text-white border-black">
               {/* Replace /resume.pdf with your actual resume path if different */}
               <a href="/resume.pdf" target="_blank" rel="noopener noreferrer" className="neo-btn text-center bg-white text-black px-4 py-3 w-full border-black hover:bg-lime hover:scale-[1.02] active:scale-95 text-lg block">
                 View Resume
               </a>
               <div className="flex gap-3">
                 <a href="https://x.com/your_twitter_handle" target="_blank" rel="noopener noreferrer" className="neo-btn text-center flex-1 bg-black text-white py-3 border-white hover:bg-lime hover:text-black hover:border-black active:scale-95">
                   [ X ]
                 </a>
                 <a href="https://linkedin.com/in/your_linkedin_handle" target="_blank" rel="noopener noreferrer" className="neo-btn text-center flex-1 bg-black text-white py-3 border-white hover:bg-lime hover:text-black hover:border-black active:scale-95">
                   [ IN ]
                 </a>
               </div>
            </div>
          </div>
        </section>

        {/* Dynamic Lab Section fetching from Supabase */}
        <LabSection projects={displayProjects} />
      </main>
      <SiteFooter />
    </>
  );
}
EOF

echo "✅ Full-stack integration complete! Run 'npm run dev' to see."