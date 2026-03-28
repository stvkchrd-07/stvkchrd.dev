#!/bin/bash

echo "🔄 Updating Projects Section & Integrating Custom CWO Cards..."

# 1. Create the Custom CWOCard Component
echo "🎴 Building Custom CWOCard..."
cat << 'EOF' > components/CWOCard.tsx
'use client';

import React from 'react';

interface CWOItem {
  id: number;
  title: string;
  tag?: string;
  description: string;
  status?: string;
}

export default function CWOCard({ item }: { item: CWOItem }) {
  return (
    <div className="cwo-wrapper h-full">
      <div className="card h-full flex flex-col">
        <div className="card-pattern-grid" />
        <div className="card-overlay-dots" />
        
        {/* Top Decorative Pattern */}
        <div className="bold-pattern">
          <svg viewBox="0 0 100 100">
            <path strokeDasharray="15 10" strokeWidth={10} stroke="var(--text-color)" fill="none" d="M0,0 L100,0 L100,100 L0,100 Z" />
          </svg>
        </div>
        
        {/* Header Section */}
        <div className="card-title-area">
          <span className="truncate pr-4">{item.title}</span>
          {item.tag && <span className="card-tag whitespace-nowrap">{item.tag}</span>}
        </div>
        
        {/* Body Section */}
        <div className="card-body flex-1 flex flex-col">
          <div className="card-description flex-1">
            {item.description}
          </div>
          
          <div className="card-actions">
            {item.status && (
              <button className="card-button">{item.status}</button>
            )}
          </div>
        </div>
        
        {/* Bottom Decorative Dots */}
        <div className="dots-pattern">
          <svg viewBox="0 0 80 40">
            {[10, 30, 50, 70].map(cx => (
              <React.Fragment key={cx}>
                <circle fill="var(--text-color)" r={2} cy={10} cx={cx} />
                {cx !== 70 && <circle fill="var(--text-color)" r={2} cy={20} cx={cx + 10} />}
                <circle fill="var(--text-color)" r={2} cy={30} cx={cx} />
              </React.Fragment>
            ))}
          </svg>
        </div>
        
        <div className="accent-shape" />
      </div>

      <style jsx>{`
        .cwo-wrapper {
          font-size: 16px; /* Base size for em scaling */
        }
        
        .card {
          --primary: var(--text-color);
          --accent: var(--accent-color);
          --bg: var(--bg-color);
          --shadow-color: var(--text-color);
          --pattern-color: rgba(0, 0, 0, 0.1);

          position: relative;
          width: 100%;
          background: var(--bg);
          border: 2px solid var(--text-color);
          border-radius: 0.6em; /* Requested rounded edges */
          box-shadow: 6px 6px 0 var(--shadow-color);
          transition: all 0.2s ease-out;
          overflow: hidden;
          z-index: 1;
        }

        .card:hover {
          transform: translate(-4px, -4px);
          box-shadow: 10px 10px 0 var(--shadow-color);
        }

        .card:hover .card-pattern-grid,
        .card:hover .card-overlay-dots {
          opacity: 1;
        }

        .card-pattern-grid {
          position: absolute;
          inset: 0;
          background-image: linear-gradient(to right, rgba(0, 0, 0, 0.05) 1px, transparent 1px),
                            linear-gradient(to bottom, rgba(0, 0, 0, 0.05) 1px, transparent 1px);
          background-size: 1em 1em;
          pointer-events: none;
          opacity: 0.5;
          transition: opacity 0.4s ease;
          z-index: -1;
        }

        .card-overlay-dots {
          position: absolute;
          inset: 0;
          background-image: radial-gradient(var(--pattern-color) 1px, transparent 1px);
          background-size: 1em 1em;
          pointer-events: none;
          opacity: 0;
          transition: opacity 0.4s ease;
          z-index: -1;
        }

        .bold-pattern {
          position: absolute;
          top: 0;
          right: 0;
          width: 6em;
          height: 6em;
          opacity: 0.1;
          pointer-events: none;
          z-index: -1;
        }

        .card-title-area {
          position: relative;
          padding: 1.2em;
          background: var(--primary);
          color: var(--bg);
          font-weight: 900;
          font-size: 1.2em;
          display: flex;
          justify-content: space-between;
          align-items: center;
          border-bottom: 2px solid var(--text-color);
          text-transform: uppercase;
          letter-spacing: 0.05em;
          overflow: hidden;
        }

        .card-tag {
          background: var(--bg);
          color: var(--text-color);
          font-size: 0.6em;
          font-weight: 800;
          padding: 0.4em 0.8em;
          border: 2px solid var(--text-color);
          border-radius: 0.3em;
          box-shadow: 2px 2px 0 var(--shadow-color);
          transform: rotate(3deg);
          transition: all 0.2s ease;
        }

        .card:hover .card-tag {
          transform: rotate(-2deg) scale(1.05);
          background: var(--accent);
        }

        .card-body {
          position: relative;
          padding: 1.5em;
          z-index: 2;
        }

        .card-description {
          margin-bottom: 1.5em;
          font-size: 0.95em;
          line-height: 1.5;
          font-weight: 600;
        }

        .card-actions {
          margin-top: auto;
          padding-top: 1em;
          border-top: 2px dashed rgba(0, 0, 0, 0.2);
          display: flex;
          justify-content: flex-start;
        }

        .card-button {
          position: relative;
          background: var(--bg);
          color: var(--text-color);
          font-size: 0.85em;
          font-weight: 800;
          padding: 0.6em 1.2em;
          border: 2px solid var(--text-color);
          border-radius: 0.4em;
          box-shadow: 3px 3px 0 var(--shadow-color);
          cursor: pointer;
          transition: all 0.1s ease;
          text-transform: uppercase;
          letter-spacing: 0.05em;
        }

        .card-button:hover {
          background: var(--accent);
          transform: translate(-2px, -2px);
          box-shadow: 5px 5px 0 var(--shadow-color);
        }

        .card-button:active {
          transform: translate(2px, 2px);
          box-shadow: 1px 1px 0 var(--shadow-color);
        }

        .dots-pattern {
          position: absolute;
          bottom: 1em;
          right: 1em;
          width: 6em;
          height: 3em;
          opacity: 0.2;
          pointer-events: none;
          z-index: 1;
        }

        .accent-shape {
          position: absolute;
          width: 2em;
          height: 2em;
          background: var(--accent);
          border: 2px solid var(--text-color);
          border-radius: 0.3em;
          transform: rotate(45deg);
          bottom: -1em;
          right: 3em;
          z-index: 0;
          transition: transform 0.3s ease;
        }

        .card:hover .accent-shape {
          transform: rotate(90deg) scale(1.2);
        }
      `}</style>
    </div>
  );
}
EOF

# 2. Update Home Page (Grid for CWOCard & Square Rounded Project Cards)
echo "🏠 Updating Home Page Layout..."
cat << 'EOF' > app/page.tsx
import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import CWOCard from '@/components/CWOCard';
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
      
      <div className="mb-12 md:mb-16 strict-border rounded-xl p-5 md:p-8 bg-[var(--text-color)] text-[var(--bg-color)]">
        <h1 className="font-black text-4xl md:text-7xl uppercase tracking-tighter leading-[0.9]">
          PIVOT.<br/>
          EXPERIMENT.<br/>
          <span className="text-[var(--accent-color)]">SHIP.</span> SCALE.
        </h1>
      </div>

      <main className="grid grid-cols-1 gap-12 md:gap-16">
        
        {/* Updated CWO Section using new grid cards */}
        <section id="currently-working-on">
          <div className="flex justify-between items-end border-b-[2px] border-[var(--text-color)] pb-2 mb-6">
            <h2 className="font-black text-3xl md:text-5xl tracking-tighter uppercase leading-none">Focus</h2>
            <span className="font-black text-lg md:text-xl text-[var(--text-color)] bg-[var(--accent-color)] border-[2px] border-[var(--text-color)] px-3 py-1 rounded-md">LIVE</span>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 md:gap-8">
            {displayCWO.map(item => (
              <CWOCard key={item.id} item={item} />
            ))}
          </div>
        </section>

        <section id="projects">
          {/* Renamed to Projects Section */}
          <div className="flex justify-between items-end border-b-[2px] border-[var(--text-color)] pb-2 mb-6">
            <h2 className="font-black text-3xl md:text-5xl tracking-tighter uppercase leading-none">Projects Section</h2>
          </div>
          
          {/* Square cards with slightly rounded edges */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {displayProjects.map((project, index) => (
              <motion.div
                key={project.id}
                className={`strict-border rounded-xl p-5 md:p-6 bg-[var(--card-bg)] flex flex-col justify-between strict-hover cursor-pointer aspect-square ${index % 4 === 0 ? 'md:col-span-2' : 'md:col-span-1'}`}
              >
                <div>
                  <h3 className="font-black text-2xl md:text-4xl leading-none mb-2 tracking-tighter uppercase">{project.title}</h3>
                  <p className="text-sm font-bold uppercase tracking-widest border-t-[2px] border-current pt-2 mt-2">{project.subtitle}</p>
                </div>
                <div className="self-end bg-[var(--bg-color)] text-[var(--text-color)] px-3 py-1 strict-border rounded-lg mt-6">
                  <span className="font-black text-xl leading-none">→</span>
                </div>
              </motion.div>
            ))}
          </div>
          <div className="h-16 md:h-24" />
        </section>
      </main>

      <SiteFooter />
    </>
  );
}
EOF

echo "✅ Custom layouts applied! Check out your new Cards and Rounded Squares."