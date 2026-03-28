import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import CWOCard from '@/components/CWOCard';
import { createServerSupabaseClient } from '@/lib/supabase/server';
import * as motion from "framer-motion/client";

// FIX: This forces Next.js to always fetch fresh data from Supabase instead of caching it!
export const dynamic = 'force-dynamic';

export default async function HomePage() {
  const supabase = createServerSupabaseClient();
  const { data: projects } = await supabase.from('projects').select('*').order('id', { ascending: false });
  const { data: workingOn } = await supabase.from('working_on').select('*').order('id', { ascending: false });

  // Fallbacks if DB is empty
  const displayProjects = projects && projects.length > 0 ? projects : [];
  const displayCWO = workingOn && workingOn.length > 0 ? workingOn : [];

  return (
    <>
      <SiteHeader active="home" />
      
      {/* Ultra Minimal Single Line */}
      <div className="mb-10 text-center opacity-40">
        <p className="text-[9px] md:text-[10px] font-bold uppercase tracking-[0.5em] whitespace-nowrap">
          PIVOT &bull; EXPERIMENT &bull; <span className="text-[var(--accent-color)]">SHIP</span> &bull; SCALE
        </p>
      </div>

      <main className="grid grid-cols-1 gap-10 md:gap-14">
        <section id="currently-working-on">
          <div className="flex justify-between items-end border-b-[2px] border-[var(--text-color)] pb-2 mb-4">
            <h2 className="font-black text-2xl md:text-3xl tracking-tighter uppercase leading-none">Focus</h2>
            <span className="font-black text-xs md:text-sm text-[var(--accent-color)] bg-[var(--text-color)] px-2">LIVE</span>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {displayCWO.map(item => (
              <CWOCard key={item.id} item={item} />
            ))}
          </div>
        </section>

        <section id="projects">
          <div className="flex justify-between items-end border-b-[2px] border-[var(--text-color)] pb-2 mb-4">
            <h2 className="font-black text-2xl md:text-3xl tracking-tighter uppercase leading-none">Projects Section</h2>
          </div>
          
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-4">
            {displayProjects.map((project) => (
              <motion.div
                key={project.id}
                className="strict-border p-3 md:p-4 bg-[var(--card-bg)] flex flex-col justify-between strict-hover cursor-pointer aspect-square rounded-xl"
              >
                <div>
                  <h3 className="font-black text-base md:text-lg leading-tight mb-1 tracking-tighter uppercase">{project.title}</h3>
                  <p className="text-[10px] md:text-xs font-bold uppercase tracking-widest border-t-[2px] border-current pt-1 mt-1 opacity-90">{project.subtitle}</p>
                </div>
                <div className="self-end bg-[var(--bg-color)] text-[var(--text-color)] px-2 py-0.5 strict-border mt-2 rounded-lg">
                  <span className="font-black text-xs leading-none">→</span>
                </div>
              </motion.div>
            ))}
          </div>
          <div className="h-10 md:h-20" />
        </section>
      </main>

      <SiteFooter />
    </>
  );
}
