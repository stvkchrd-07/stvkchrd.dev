import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import CWOSlider from '@/components/CWOSlider';
import { createServerSupabaseClient } from '@/lib/supabase/server';
import * as motion from "framer-motion/client";

const sampleCWO = [
  { id: 1, title: 'TheCommonCo', tag: 'Streetwear / Merch', description: 'Scaling bulk corporate merch orders. Working on overseas pricing models and influencer outreach campaigns.', status: 'Active' },
  { id: 2, title: 'Sirenn', tag: 'Luxury Streetwear', description: 'Building the brand identity and early product line for a future luxury streetwear label.', status: 'Building' },
  { id: 3, title: 'SurFlow Events', tag: 'Event Management', description: 'Connecting underrated artists with cafés, restaurants, and corporate venues for curated weekend experiences.', status: 'Active' }
];

const sampleProjects = [
  { id: 1, title: 'Portfolio Website', subtitle: '2025 — Personal Website', description: '', imageUrl: '', liveUrl: '#' },
  { id: 2, title: 'Sample Project', subtitle: '2025 — Web App', description: '', imageUrl: '', liveUrl: '#' }
];

export default async function HomePage() {
  const supabase = createServerSupabaseClient();

  const { data: projects } = await supabase
    .from('projects').select('*').order('id', { ascending: false });

  const { data: workingOn } = await supabase
    .from('working_on').select('*').order('id', { ascending: false });

  const displayProjects = projects && projects.length > 0 ? projects : sampleProjects;
  const displayCWO = workingOn && workingOn.length > 0 ? workingOn : sampleCWO;

  return (
    <>
      <SiteHeader active="home" />
      <p className="pivot-experiment mt-2 font-black uppercase tracking-wide opacity-80">Pivot &middot; Experiment &middot; Ship &middot; Scale</p>

      <main className="grid grid-cols-1 gap-8 md:gap-12 mt-12">
        <section id="currently-working-on" className="mb-4">
          <h2 className="font-black text-4xl md:text-5xl mb-6">Currently Working On</h2>
          <CWOSlider items={displayCWO} />
        </section>

        <section id="projects">
          <h2 className="font-black text-4xl md:text-5xl mb-6">Projects</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {displayProjects.map((project) => (
              <motion.div
                key={project.id}
                whileHover={{ y: -6 }}
                whileTap={{ y: 0 }}
                transition={{ duration: 0.15, ease: "easeOut" as const }}
                className="border-2 border-[var(--text-color)] p-8 bg-[var(--card-bg)] backdrop-blur-sm cursor-pointer brutalist-hover"
              >
                <h3 className="font-black text-2xl md:text-3xl">{project.title}</h3>
                <p className="mt-2 text-base opacity-80">{project.subtitle}</p>
              </motion.div>
            ))}
          </div>
          <div className="h-32 md:h-64 lg:h-96" />
        </section>
      </main>

      <SiteFooter />
    </>
  );
}
