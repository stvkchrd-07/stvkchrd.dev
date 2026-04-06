#!/bin/bash

echo "🔧 Fixing z-index and pointer-event blocking issues..."

# 1. Update Layout to force Canvas to the back and ignore clicks
cat << 'EOF' > app/layout.tsx
import type { Metadata } from 'next';
import { Inter, VT323 } from 'next/font/google';
import CanvasBackground from '@/components/CanvasBackground';
import LoadingScreen from '@/components/LoadingScreen';
import SmoothScroll from '@/components/SmoothScroll';
import '@/styles/globals.css';

const inter = Inter({ subsets: ['latin'], weight: ['400', '700', '900'], variable: '--font-inter' });
const vt323 = VT323({ subsets: ['latin'], weight: ['400'], variable: '--font-vt323' });

export const metadata: Metadata = {
  title: 'Satvik Chaturvedi',
  description: 'Satvik Chaturvedi — builder, founder, experimenter.'
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className={`${inter.variable} ${vt323.variable} font-sans p-4 md:p-8 dark relative min-h-screen`}>
        <LoadingScreen />
        
        {/* FIX: Force background to the absolute back and disable click interception */}
        <div className="fixed inset-0 z-[-1] pointer-events-none">
          <CanvasBackground />
        </div>

        <SmoothScroll>
          {/* FIX: Elevate the content wrapper so it sits on top and accepts clicks */}
          <div className="content-wrapper max-w-7xl mx-auto relative z-20 pointer-events-auto">
            {children}
          </div>
        </SmoothScroll>
      </body>
    </html>
  );
}
EOF

# 2. Fortify the Homepage buttons to ensure they have top-level interaction priority
cat << 'EOF' > app/page.tsx
import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import LabSection from '@/components/LabSection';
import { createServerSupabaseClient } from '@/lib/supabase/server';
import { siteConfig } from '@/config/site';

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
  
  const { data: workingOn, error } = await supabase
    .from('working_on')
    .select('*')
    .order('id', { ascending: false });

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
              <h3 className="font-black text-2xl uppercase text-center">Status</h3>
              <p className="font-pixel text-lg mt-2 text-center bg-black text-lime px-3 py-1">{siteConfig.status}</p>
            </div>
            
            {/* FIX: Added relative z-50 to ensure this block absolutely stays above everything */}
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

echo "✅ Click interception removed. Buttons are now fully active. Run 'npm run dev' to see."