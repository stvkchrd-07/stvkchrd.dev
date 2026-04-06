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
