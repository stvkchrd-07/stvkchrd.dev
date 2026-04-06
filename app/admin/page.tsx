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
