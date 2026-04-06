"use client";
import { useEffect } from 'react';
import { motion } from 'framer-motion';

export default function ProjectModal({ project, onClose }: { project: any, onClose: () => void }) {
  useEffect(() => {
    const handleEsc = (e: KeyboardEvent) => e.key === 'Escape' && onClose();
    window.addEventListener('keydown', handleEsc);
    return () => window.removeEventListener('keydown', handleEsc);
  }, [onClose]);

  return (
    <div 
      className="fixed inset-0 z-[100] flex items-center justify-center bg-black/80 backdrop-blur-sm p-4" 
      onClick={onClose}
    >
      <motion.div 
        initial={{ opacity: 0, scale: 0.9, y: 40 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.95, y: 20 }}
        transition={{ type: "spring", stiffness: 500, damping: 25 }}
        className="neo-card bg-bg w-full max-w-3xl max-h-[90vh] overflow-y-auto flex flex-col relative" 
        onClick={e => e.stopPropagation()}
      >
        <div className="sticky top-0 bg-bg z-10 flex justify-between items-center p-4 border-b-2 border-text">
          <h2 className="font-black text-2xl md:text-3xl uppercase pr-4">{project.title}</h2>
          <button 
            onClick={onClose} 
            className="neo-btn bg-lime px-4 py-2 font-pixel text-xl hover:bg-electric hover:text-white"
          >
            [X]
          </button>
        </div>
        
        {project.image_url ? (
          <div className="w-full h-48 md:h-80 border-b-2 border-text relative bg-gray-200">
            <img src={project.image_url} alt={project.title} className="w-full h-full object-cover" />
          </div>
        ) : (
           <div className="w-full h-48 md:h-64 bg-black flex items-center justify-center border-b-2 border-text">
             <span className="font-pixel text-lime text-2xl animate-pulse">NO_IMAGE_DATA</span>
           </div>
        )}
        
        <div className="p-6 md:p-8 flex flex-col md:flex-row gap-8 justify-between items-start">
          <p className="font-medium text-lg md:text-xl flex-1 whitespace-pre-wrap">
            {project.description}
          </p>
          
          <div className="w-full md:w-auto">
            {project.project_url ? (
              <a 
                href={project.project_url} 
                target="_blank" 
                rel="noopener noreferrer" 
                className="neo-btn w-full md:w-auto text-center inline-block bg-electric text-white px-8 py-4 text-lg hover:bg-lime hover:text-black transition-colors"
              >
                Launch App →
              </a>
            ) : (
              <button disabled className="neo-btn opacity-50 cursor-not-allowed bg-gray-300 px-8 py-4 text-lg">
                Link Offline
              </button>
            )}
          </div>
        </div>
      </motion.div>
    </div>
  );
}
