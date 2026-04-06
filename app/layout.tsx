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
