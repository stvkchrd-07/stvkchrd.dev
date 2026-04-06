import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import Link from 'next/link';

export default function BlogPage() {
  const posts = [
    { id: 1, title: 'The Architecture of Modern Web', date: 'Oct 24, 2025', excerpt: 'Building resilient systems requires more than just code; it requires a philosophy of structure.' },
    { id: 2, title: 'Scaling The Common Co.', date: 'Sep 12, 2025', excerpt: 'Lessons learned from handling bulk merchandise and streetwear drops.' }
  ];

  return (
    <>
      <SiteHeader active="blog" />
      <main className="max-w-3xl mx-auto mt-16 px-4 min-h-[60vh]">
        <h1 className="font-black text-6xl md:text-7xl uppercase tracking-tighter mb-16 border-b-4 border-text pb-4 inline-block">
          Log.
        </h1>
        
        <div className="flex flex-col gap-16">
          {posts.map(post => (
            <article key={post.id} className="group cursor-pointer flex flex-col md:flex-row gap-4 md:gap-8 items-start">
              <div className="w-32 pt-1">
                 <p className="font-pixel text-electric border-l-4 border-text pl-2">{post.date}</p>
              </div>
              <div className="flex-1">
                <h2 className="font-black text-3xl md:text-4xl uppercase mb-4 group-hover:text-lime group-hover:underline decoration-4 underline-offset-8 transition-colors">
                  <Link href={`/blog/${post.id}`}>{post.title}</Link>
                </h2>
                <p className="text-xl font-medium opacity-70 leading-relaxed">
                  {post.excerpt}
                </p>
              </div>
            </article>
          ))}
        </div>
      </main>
      <SiteFooter />
    </>
  );
}
