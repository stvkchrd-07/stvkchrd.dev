import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import CWOCard from '@/components/CWOCard';
import { createServerSupabaseClient } from '@/lib/supabase/server';

const sampleCWO = [
  { id: 1, title: 'TheCommonCo', tag: 'Merch', description: 'Scaling bulk corporate merch orders. We deliver and ship fast quick.', status: 'Active' },
  { id: 2, title: 'Sirenn', tag: 'Luxury', description: 'Building the brand identity and early product line for a future streetwear label.', status: 'Building' }
];

const sampleProjects = [
  { id: 1, title: 'UtilityHub', subtitle: 'Browser Utilities', description: '', imageUrl: '', liveUrl: '#' },
  { id: 2, title: 'Toefury', subtitle: 'E-commerce', description: '', imageUrl: '', liveUrl: '#' },
  { id: 3, title: 'SurFlow Events', subtitle: 'Event Management', description: '', imageUrl: '', liveUrl: '#' },
  { id: 4, title: 'Portfolio Core', subtitle: 'Architecture', description: '', imageUrl: '', liveUrl: '#' }
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
      
      {/* Statement block - Responsive text scaling */}
      <div className="mb-8 md:mb-12 strict-border rounded-xl p-4 md:p-8 bg-[var(--text-color)] text-[var(--bg-color)]">
        <h1 className="font-black text-4xl sm:text-5xl md:text-7xl uppercase tracking-tighter leading-[0.9]">
          PIVOT.<br/>
          EXPERIMENT.<br/>
          <span className="text-[var(--accent-color)]">SHIP.</span> SCALE.
        </h1>
      </div>

      <main className="grid grid-cols-1 gap-10 md:gap-16">
        
        <section id="currently-working-on">
          <div className="flex justify-between items-end border-b-[2px] border-[var(--text-color)] pb-2 mb-4 md:mb-6">
            <h2 className="font-black text-2xl sm:text-3xl md:text-5xl tracking-tighter uppercase leading-none">Focus</h2>
            <span className="font-black text-xs sm:text-sm md:text-xl text-[var(--text-color)] bg-[var(--accent-color)] border-[2px] border-[var(--text-color)] px-2 py-0.5 md:px-3 md:py-1 rounded-md">LIVE</span>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 md:gap-8">
            {displayCWO.map(item => (
              <CWOCard key={item.id} item={item} />
            ))}
          </div>
        </section>

        <section id="projects">
          <div className="flex justify-between items-end border-b-[2px] border-[var(--text-color)] pb-2 mb-4 md:mb-6">
            <h2 className="font-black text-2xl sm:text-3xl md:text-5xl tracking-tighter uppercase leading-none">Projects Section</h2>
          </div>
          
          {/* Mobile: Tight padding to prevent text overflow in 2 columns */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-2 md:gap-4">
            {displayProjects.map((project, index) => (
              <div
                key={project.id}
                className={`strict-border rounded-xl p-2.5 sm:p-4 md:p-5 bg-[var(--card-bg)] flex flex-col justify-between strict-hover cursor-pointer aspect-square ${index % 4 === 0 ? 'md:col-span-2' : 'col-span-1'}`}
              >
                <div>
                  <h3 className="font-black text-base sm:text-lg md:text-3xl leading-tight mb-1 tracking-tighter uppercase break-words line-clamp-2">{project.title}</h3>
                  <p className="text-[9px] sm:text-xs font-bold uppercase tracking-widest border-t-[2px] border-current pt-1 mt-1 opacity-90 truncate">{project.subtitle}</p>
                </div>
                <div className="self-end bg-[var(--bg-color)] text-[var(--text-color)] px-1.5 py-0.5 sm:px-2 sm:py-1 strict-border rounded-md md:rounded-lg mt-2">
                  <span className="font-black text-xs sm:text-base md:text-xl leading-none">→</span>
                </div>
              </div>
            ))}
          </div>
          <div className="h-10 md:h-24" />
        </section>
      </main>

      <SiteFooter />
    </>
  );
}
