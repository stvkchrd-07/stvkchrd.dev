'use client';

import { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

export default function RaoModal({ isOpen, onClose }: { isOpen: boolean, onClose: () => void }) {
  const [input, setInput] = useState('');
  const [log, setLog] = useState<{role: 'user' | 'system', text: string}[]>([
    { role: 'system', text: 'RAO_OS v3.0 ONLINE. NEURAL NET CONNECTED. ENTER COMMAND.' }
  ]);
  const [isTyping, setIsTyping] = useState(false);
  const logEndRef = useRef<HTMLDivElement>(null);

  // Auto-scroll to bottom of chat
  useEffect(() => {
    logEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [log]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim() || isTyping) return;

    const userText = input;
    // Add user message to log
    setLog(prev => [...prev, { role: 'user', text: userText.toUpperCase() }]);
    setInput('');
    setIsTyping(true);

    try {
      const response = await fetch('/api/rao', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: userText })
      });

      if (!response.ok) {
        const errData = await response.json().catch(() => ({ error: `HTTP ${response.status}` }));
        throw new Error(errData.error || "Server Error");
      }

      const data = await response.json();
      
      // Add system response to log
      setLog(prev => [...prev, { role: 'system', text: data.text.toUpperCase() }]);

    } catch (error: any) {
      console.error("Frontend error:", error);
      setLog(prev => [...prev, { role: 'system', text: `ERR: ${error.message}` }]);
    } finally {
      setIsTyping(false);
    }
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
          className="fixed inset-0 z-[1000] flex items-center justify-center bg-[var(--bg-color)]/90 backdrop-blur-sm p-2 sm:p-4"
        >
          <div className="absolute inset-0" onClick={onClose} />
          
          <motion.div
            initial={{ scale: 0.98, y: 5 }} animate={{ scale: 1, y: 0 }} exit={{ scale: 0.98, y: 5 }}
            transition={{ duration: 0.1, ease: "linear" }}
            className="relative w-full max-w-lg bg-[var(--card-bg)] strict-border flex flex-col overflow-hidden h-[75vh] max-h-[600px]"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="border-b-[2px] border-[var(--text-color)] p-2 sm:p-3 flex justify-between items-center bg-[var(--text-color)] text-[var(--bg-color)]">
              <h3 className="font-black tracking-widest uppercase text-xs sm:text-sm">
                RAO AI // {isTyping ? 'PROCESSING...' : 'IDLE'}
              </h3>
              <button onClick={onClose} className="font-black active:text-[var(--accent-color)] text-xs px-2 py-1 strict-border bg-[var(--bg-color)] text-[var(--text-color)]">CLOSE ✕</button>
            </div>

            <div className="flex-1 p-3 sm:p-4 overflow-y-auto flex flex-col gap-3 font-mono text-xs sm:text-sm bg-[var(--card-bg)]">
              {log.map((entry, i) => (
                <div key={i} className={`p-3 max-w-[90%] strict-border font-bold uppercase leading-relaxed whitespace-pre-wrap ${entry.role === 'user' ? 'self-end bg-[var(--accent-color)] text-black text-right' : 'self-start bg-[var(--text-color)] text-[var(--bg-color)]'}`}>
                  <span className="opacity-50 text-[9px] block mb-1">{entry.role === 'user' ? 'USER_IN' : 'SYS_OUT'}</span>
                  {entry.text}
                </div>
              ))}
              {isTyping && (
                <div className="p-3 max-w-[90%] strict-border font-bold uppercase self-start bg-[var(--text-color)] text-[var(--bg-color)] animate-pulse">
                  <span className="opacity-50 text-[9px] block mb-1">SYS_OUT</span>
                  GENERATING RESPONSE...
                </div>
              )}
              <div ref={logEndRef} />
            </div>

            <form onSubmit={handleSubmit} className="border-t-[2px] border-[var(--text-color)] bg-[var(--bg-color)] flex p-2 gap-2">
              <input
                type="text" value={input} onChange={(e) => setInput(e.target.value)} disabled={isTyping}
                placeholder={isTyping ? "WAITING FOR SYSTEM..." : "ENTER COMMAND..."}
                className="flex-1 bg-transparent strict-border p-2 font-black uppercase text-[16px] outline-none focus:bg-[var(--text-color)] focus:text-[var(--bg-color)] transition-none placeholder:text-[var(--text-color)] placeholder:opacity-50 disabled:opacity-50"
              />
              <button type="submit" disabled={isTyping} className="strict-border px-3 sm:px-4 py-2 font-black uppercase text-sm sm:text-base bg-[var(--accent-color)] text-black active:bg-[var(--text-color)] active:text-[var(--accent-color)] transition-none disabled:opacity-50">
                {isTyping ? '...' : 'EXEC'}
              </button>
            </form>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
