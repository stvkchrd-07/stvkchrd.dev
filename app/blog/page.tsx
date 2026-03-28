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
