"use client";
import { useState } from 'react';
import ProjectModal from './ProjectModal';

export default function LabSection({ projects }: { projects: any[] }) {
  const [selectedProject, setSelectedProject] = useState<any>(null);

  return (
    <section id="lab" className="mt-16 md:mt-24 relative border-t-4 border-dashed border-text pt-12">
      <div className="absolute -top-6 left-1/2 -translate-x-1/2 bg-bg px-4">
        <h2 className="font-pixel text-3xl md:text-4xl text-electric bg-lime px-3 py-1 border-2 border-text shadow-neo transform -rotate-2">
          ★ The Lab ★
        </h2>
      </div>
      
      <p className="font-pixel text-center mb-10 text-lg md:text-xl opacity-80">
        Warning: Experimental ventures below. Click to inspect.
      </p>
      
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 md:gap-8">
        {projects.map((proj) => (
          <div 
            key={proj.id} 
            onClick={() => setSelectedProject(proj)}
            className="neo-card p-0 relative group cursor-pointer hover:-translate-y-2 transition-transform bg-card flex flex-col h-full"
          >
            <div className="h-56 w-full border-b-2 border-text overflow-hidden bg-black relative">
              {proj.image_url ? (
                <img 
                  src={proj.image_url} 
                  alt={proj.title} 
                  className="w-full h-full object-cover opacity-90 group-hover:opacity-100 group-hover:scale-105 transition-all duration-300" 
                />
              ) : (
                <div className="w-full h-full flex items-center justify-center">
                  <span className="font-pixel text-lime text-xl">AWAITING_IMG</span>
                </div>
              )}
            </div>
            <div className="p-5 flex-1 flex flex-col justify-between">
              <div>
                <h3 className="font-black text-xl md:text-2xl uppercase mb-2 line-clamp-1">{proj.title}</h3>
                <p className="text-sm md:text-base font-medium line-clamp-2 opacity-90">{proj.description}</p>
              </div>
              <div className="mt-6 flex justify-end">
                 <span className="font-pixel text-electric group-hover:text-lime font-bold text-lg border-b-2 border-transparent group-hover:border-lime transition-colors">
                   View Details &gt;
                 </span>
              </div>
            </div>
          </div>
        ))}
      </div>

      <ProjectModal project={selectedProject} onClose={() => setSelectedProject(null)} />
    </section>
  );
}
