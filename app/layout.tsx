import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import CanvasBackground from '@/components/CanvasBackground';
import '@/styles/globals.css';

const inter = Inter({ subsets: ['latin'], weight: ['400', '900'] });

export const metadata: Metadata = {
  title: 'Satvik Chaturvedi',
  description: 'Satvik Chaturvedi — builder, founder, experimenter.'
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className={`${inter.className} p-4 md:p-8 dark`}>
        <CanvasBackground />
        <div className="content-wrapper max-w-7xl mx-auto">
          {children}
        </div>
      </body>
    </html>
  );
}
