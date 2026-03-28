#!/bin/bash

echo "🔄 Starting Aesthetic Overhaul..."

# 1. Create Loading Screen Component
echo "⏳ Building Loading Screen..."
cat << 'EOF' > components/LoadingScreen.tsx
'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

export default function LoadingScreen() {
  const [progress, setProgress] = useState(0);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const duration = 1500; // 1.5 seconds loading time
    const intervalTime = 15;
    const steps = duration / intervalTime;
    let currentStep = 0;

    const timer = setInterval(() => {
      currentStep++;
      setProgress(Math.min(100, Math.floor((currentStep / steps) * 100)));
      
      if (currentStep >= steps) {
        clearInterval(timer);
        setTimeout(() => setIsLoading(false), 200);
      }
    }, intervalTime);

    return () => clearInterval(timer);
  }, []);

  return (
    <AnimatePresence>
      {isLoading && (
        <motion.div
          initial={{ opacity: 1 }}
          exit={{ opacity: 0, transition: { duration: 0.5, ease: "easeOut" } }}
          className="fixed inset-0 z-[999] bg-[var(--bg-color)] flex flex-col items-center justify-center pointer-events-none"
        >
          <div className="w-64 md:w-96">
            <div className="flex justify-between mb-2 font-black text-[var(--text-color)] tracking-widest text-sm uppercase">
              <span>System Boot</span>
              <span>{progress}%</span>
            </div>
            <div className="h-2 w-full border-2 border-[var(--text-color)] p-[2px]">
              <motion.div 
                className="h-full bg-[var(--text-color)]"
                initial={{ width: 0 }}
                animate={{ width: `${progress}%` }}
                transition={{ duration: 0.1, ease: "linear" }}
              />
            </div>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
EOF

# 2. Update Layout to include Loading Screen
echo "🗂️ Updating Root Layout..."
cat << 'EOF' > app/layout.tsx
import type { Metadata } from 'next';
import { Inter, Lora } from 'next/font/google';
import CanvasBackground from '@/components/CanvasBackground';
import LoadingScreen from '@/components/LoadingScreen';
import '@/styles/globals.css';

const inter = Inter({ subsets: ['latin'], weight: ['400', '700', '900'], variable: '--font-inter' });
// Added a serif font specifically for the traditional blog look
const lora = Lora({ subsets: ['latin'], weight: ['400', '600'], variable: '--font-lora' });

export const metadata: Metadata = {
  title: 'Satvik Chaturvedi',
  description: 'Satvik Chaturvedi — builder, founder, experimenter.'
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className={`${inter.variable} ${lora.variable} font-sans p-4 md:p-8 dark`}>
        <LoadingScreen />
        <CanvasBackground />
        <div className="content-wrapper max-w-7xl mx-auto">
          {children}
        </div>
      </body>
    </html>
  );
}
EOF

# 3. Update Home Page (Square Cards & Order)
echo "🏠 Reformatting Home Page..."
cat << 'EOF' > app/page.tsx
import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import CWOSlider from '@/components/CWOSlider';
import { createServerSupabaseClient } from '@/lib/supabase/server';
import * as motion from "framer-motion/client";

const sampleCWO = [
  { id: 1, title: 'TheCommonCo', tag: 'Streetwear / Merch', description: 'Scaling bulk corporate merch orders. Working on overseas pricing models and influencer outreach campaigns.', status: 'Active' },
  { id: 2, title: 'Sirenn', tag: 'Luxury Streetwear', description: 'Building the brand identity and early product line for a future luxury streetwear label.', status: 'Building' }
];

const sampleProjects = [
  { id: 1, title: 'Portfolio Website', subtitle: '2025 — Personal Website', description: '', imageUrl: '', liveUrl: '#' },
  { id: 2, title: 'Sample Project', subtitle: '2025 — Web App', description: '', imageUrl: '', liveUrl: '#' },
  { id: 3, title: 'UtilityHub', subtitle: '2026 — Browser Utilities', description: '', imageUrl: '', liveUrl: '#' },
  { id: 4, title: 'Toefury', subtitle: '2025 — E-commerce', description: '', imageUrl: '', liveUrl: '#' }
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
      <p className="font-black uppercase tracking-widest opacity-60 text-sm mb-12">Pivot &middot; Experiment &middot; Ship &middot; Scale</p>

      <main className="grid grid-cols-1 gap-16 md:gap-24">
        
        {/* Section 1: Currently Working On (Top Priority) */}
        <section id="currently-working-on">
          <h2 className="font-black text-3xl md:text-5xl mb-6 tracking-tight">Currently Working On</h2>
          <CWOSlider items={displayCWO} />
        </section>

        {/* Section 2: Square Projects */}
        <section id="projects">
          <h2 className="font-black text-3xl md:text-5xl mb-6 tracking-tight">Projects</h2>
          {/* Grid configured to make cards naturally square-ish */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {displayProjects.map((project) => (
              <motion.div
                key={project.id}
                whileHover={{ y: -6 }}
                whileTap={{ y: 0 }}
                transition={{ duration: 0.15, ease: "easeOut" as const }}
                // Added aspect-square to force perfect square dimensions
                className="aspect-square flex flex-col justify-between border-2 border-[var(--text-color)] p-6 md:p-8 bg-[var(--card-bg)] backdrop-blur-sm cursor-pointer brutalist-hover"
              >
                <div>
                  <h3 className="font-black text-2xl leading-tight mb-2">{project.title}</h3>
                  <p className="text-sm md:text-base opacity-70 leading-relaxed">{project.subtitle}</p>
                </div>
                {/* Visual indicator that it's clickable */}
                <div className="self-end opacity-0 group-hover:opacity-100 transition-opacity">
                  <span className="font-black text-xl">↗</span>
                </div>
              </motion.div>
            ))}
          </div>
          <div className="h-24 md:h-48" />
        </section>
      </main>

      <SiteFooter />
    </>
  );
}
EOF

# 4. Update Blog Page (Traditional Aesthetic)
echo "🖋️ Applying Traditional Blog Aesthetic..."
cat << 'EOF' > app/blog/page.tsx
import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import { createServerSupabaseClient } from '@/lib/supabase/server';
import { marked } from 'marked';
import Link from 'next/link';
import * as motion from "framer-motion/client";

const samplePosts = [
  { id: 1, title: 'Welcome to My Blog', date: '2025-01-15', content: 'This is a sample blog post. Configure Supabase to load real posts. The aesthetics here are designed to be calm, centered, and optimized for long-form reading.' },
  { id: 2, title: 'Building This Portfolio', date: '2025-01-10', content: 'I built this portfolio using Next.js, Three.js, and Supabase. The goal was to separate the loud, brutalist portfolio from the quiet, traditional reading experience.' }
];

export default async function BlogPage() {
  const supabase = createServerSupabaseClient();
  const { data: posts } = await supabase.from('posts').select('*').order('date', { ascending: false });
  const displayPosts = posts && posts.length > 0 ? posts : samplePosts;

  return (
    <>
      <SiteHeader active="blog" />
      
      {/* Traditional Blog Container */}
      <main className="max-w-3xl mx-auto mt-16 md:mt-24 px-4 font-serif">
        <header className="mb-16 text-center">
          <p className="font-sans text-xs font-bold tracking-[0.2em] uppercase opacity-50 mb-4">लेख</p>
          <h1 className="text-4xl md:text-6xl font-normal tracking-tight">Writings & Thoughts</h1>
        </header>

        <section id="blog-posts" className="space-y-16">
          {displayPosts.map((post) => (
            <motion.article 
              key={post.id} 
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.4, ease: "easeOut" as const }}
              className="group cursor-pointer"
            >
              <Link href={`/post/${post.id}`} className="block">
                <p className="font-sans text-sm tracking-widest uppercase opacity-60 mb-3">
                  {new Date(post.date).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })}
                </p>
                <h2 className="text-3xl md:text-4xl font-normal leading-tight mb-4 group-hover:opacity-70 transition-opacity">
                  {post.title}
                </h2>
                <div
                  className="text-lg md:text-xl leading-relaxed opacity-80 mb-6"
                  dangerouslySetInnerHTML={{
                    __html: marked.parse(post.content.slice(0, 200) + (post.content.length > 200 ? '...' : '')) as string
                  }}
                />
                <span className="font-sans text-sm font-bold tracking-widest uppercase opacity-0 group-hover:opacity-100 transition-opacity">
                  Read Article →
                </span>
              </Link>
            </motion.article>
          ))}
          <div className="h-24 md:h-48" />
        </section>
      </main>

      <SiteFooter />
    </>
  );
}
EOF

# 5. Update Tailwind to Recognize Serif Font
echo "⚙️ Configuring Serif Font in Tailwind..."
cat << 'EOF' > tailwind.config.ts
import type { Config } from "tailwindcss";

export default {
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['var(--font-inter)', 'sans-serif'],
        serif: ['var(--font-lora)', 'serif'],
      },
    },
  },
  plugins: [],
} satisfies Config;
EOF

echo "✅ Aesthetic update complete! Run 'npm run dev' to see the changes."