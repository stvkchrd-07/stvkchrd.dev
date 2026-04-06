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
