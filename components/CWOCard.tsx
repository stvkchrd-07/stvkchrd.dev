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
        
        <div className="bold-pattern">
          <svg viewBox="0 0 100 100">
            <path strokeDasharray="15 10" strokeWidth={10} stroke="var(--text-color)" fill="none" d="M0,0 L100,0 L100,100 L0,100 Z" />
          </svg>
        </div>
        
        {/* Adjusted header for mobile: allows wrapping if tags get squished */}
        <div className="card-title-area flex-col items-start sm:flex-row sm:items-center gap-2 sm:gap-0">
          <span className="truncate w-full sm:w-auto sm:pr-4">{item.title}</span>
          {item.tag && <span className="card-tag whitespace-nowrap self-start sm:self-auto">{item.tag}</span>}
        </div>
        
        <div className="card-body flex-1 flex flex-col">
          <div className="card-description flex-1">
            {item.description}
          </div>
          
          <div className="card-actions">
            {item.status && (
              <button className="card-button accent-hover">{item.status}</button>
            )}
          </div>
        </div>
        
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
        /* MAGIC SCALING: Adjusting base font size scales the entire em-based card layout! */
        .cwo-wrapper { font-size: 13px; }
        @media (min-width: 640px) { .cwo-wrapper { font-size: 14px; } }
        @media (min-width: 1024px) { .cwo-wrapper { font-size: 16px; } }
        
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
          border-radius: 0.6em;
          box-shadow: 6px 6px 0 var(--shadow-color);
          transition: all 0.2s ease-out;
          overflow: hidden;
          z-index: 1;
        }

        /* Hover effects mapped to hover-capable devices only */
        @media (hover: hover) {
          .card:hover {
            transform: translate(-4px, -4px);
            box-shadow: 10px 10px 0 var(--shadow-color);
          }
          .card:hover .card-pattern-grid,
          .card:hover .card-overlay-dots {
            opacity: 1;
          }
          .card:hover .accent-shape {
            transform: rotate(90deg) scale(1.2);
          }
          .card:hover .card-tag {
            transform: rotate(-2deg) scale(1.05);
            background: var(--accent);
          }
        }

        /* Tactile touch feedback */
        .card:active {
          transform: translate(2px, 2px);
          box-shadow: 4px 4px 0 var(--shadow-color);
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
          top: 0; right: 0;
          width: 6em; height: 6em;
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
          text-transform: uppercase;
          letter-spacing: 0.05em;
        }

        .dots-pattern {
          position: absolute;
          bottom: 1em; right: 1em;
          width: 6em; height: 3em;
          opacity: 0.2;
          pointer-events: none;
          z-index: 1;
        }

        .accent-shape {
          position: absolute;
          width: 2em; height: 2em;
          background: var(--accent);
          border: 2px solid var(--text-color);
          border-radius: 0.3em;
          transform: rotate(45deg);
          bottom: -1em; right: 3em;
          z-index: 0;
          transition: transform 0.3s ease;
        }
      `}</style>
    </div>
  );
}
