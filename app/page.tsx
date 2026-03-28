import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import CWOSlider from '@/components/CWOSlider';
import { createServerSupabaseClient } from '@/lib/supabase/server';
import * as motion from "framer-motion/client";

const sampleCWO = [
  { id: 1, title: 'TheCommonCo', tag: 'Merch', description: 'Scaling bulk corporate merch orders. We deliver and ship fast quick.', status: 'Active' },
  { id: 2, title: 'Sirenn', tag: 'Luxury', description: 'Building the brand identity and early product line for a future luxury streetwear label.', status: 'Building' }
];

const sampleProjects = [
  { id: 1, title: 'UtilityHub', subtitle: 'Browser Utilities', description: '', imageUrl: '', liveUrl: '#' },
  { id: 2, title: 'Toefury', subtitle: 'E-commerce', description: '', imageUrl: '', liveUrl: '#' },
  { id: 3, title: 'SurFlow Events', subtitle: 'Event Management', description: '', imageUrl: '', liveUrl: '#' },
  { id: 4, title: 'Portfolio Core', subtitle: 'System Architecture', description: '', imageUrl: '', liveUrl: '#' }
];

export default async function HomePage() {
  const supabase = createServerSupabaseClient();
  const { data: projects } = await supabase.from('projects').select('*').order('id', { ascending: false });
  const { data: workingOn } = await supabase.from('working_on').select('*').order('id', { ascending: false });

  const displayProjects = projects && projects.length > 0 ? projects : sampleProjects;
  const displayCWO = workingOn && workingOn.length > 0 ? workingOn : sampleCWO;

  return (
    <>
      <SiteHeader active="home" />
      
      {/* Statement block - MICRO Scaled */}
      <div className="mb-10 md:mb-12 strict-border p-4 md:p-6 bg-[var(--text-color)] text-[var(--bg-color)]">
        <h1 className="font-black text-3xl md:text-5xl uppercase tracking-tighter leading-[0.9]">
          PIVOT.<br/>
          EXPERIMENT.<br/>
          <span className="text-[var(--accent-color)]">SHIP.</span> SCALE.
        </h1>
      </div>

      <main className="grid grid-cols-1 gap-10 md:gap-14">
        <section id="currently-working-on">
          <div className="flex justify-between items-end border-b-[2px] border-[var(--text-color)] pb-2 mb-4">
            <h2 className="font-black text-2xl md:text-3xl tracking-tighter uppercase leading-none">Focus</h2>
            <span className="font-black text-sm md:text-base text-[var(--accent-color)] bg-[var(--text-color)] px-2">LIVE</span>
          </div>
          <CWOSlider items={displayCWO} />
        </section>

        <section id="projects">
          <div className="flex justify-between items-end border-b-[2px] border-[var(--text-color)] pb-2 mb-4">
            <h2 className="font-black text-2xl md:text-3xl tracking-tighter uppercase leading-none">Projects Section</h2>
          </div>
          
          {/* Small Squares Grid (2 columns on mobile, 4 on desktop) */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-4">
            {displayProjects.map((project) => (
              <motion.div
                key={project.id}
                className="strict-border p-3 md:p-4 bg-[var(--card-bg)] flex flex-col justify-between strict-hover cursor-pointer aspect-square"
              >
                <div>
                  <h3 className="font-black text-lg md:text-xl leading-tight mb-1 tracking-tighter uppercase">{project.title}</h3>
                  <p className="text-[10px] md:text-xs font-bold uppercase tracking-widest border-t-[2px] border-current pt-1 mt-1 opacity-90">{project.subtitle}</p>
                </div>
                <div className="self-end bg-[var(--bg-color)] text-[var(--text-color)] px-2 py-0.5 strict-border mt-2">
                  <span className="font-black text-sm leading-none">→</span>
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
