import type { Metadata } from 'next';
import { Inter, Lora } from 'next/font/google';
import CanvasBackground from '@/components/CanvasBackground';
import LoadingScreen from '@/components/LoadingScreen';
import SmoothScroll from '@/components/SmoothScroll';
import '@/styles/globals.css';

const inter = Inter({ subsets: ['latin'], weight: ['400', '700', '900'], variable: '--font-inter' });
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
        <SmoothScroll>
          <div className="content-wrapper max-w-7xl mx-auto">
            {children}
          </div>
        </SmoothScroll>
      </body>
    </html>
  );
}
