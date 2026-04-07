import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import Link from 'next/link';
import { createServerSupabaseClient } from '@/lib/supabase/server';
import { format } from 'date-fns';

export const dynamic = 'force-dynamic';

export default async function BlogPage() {
  const supabase = createServerSupabaseClient();
  const { data: posts } = await supabase.from('blog_posts').select('*').order('created_at', { ascending: false });

  return (
    <>
      <SiteHeader active="blog" />
      <main className="max-w-3xl mx-auto mt-16 px-4 min-h-[60vh] relative z-30">
        <h1 className="font-black text-6xl md:text-7xl uppercase tracking-tighter mb-16 border-b-4 border-text pb-4 inline-block bg-lime px-2 shadow-neo transform -rotate-1">
          System.Log()
        </h1>
        
        <div className="flex flex-col gap-12">
          {!posts || posts.length === 0 ? (
            <p className="font-pixel text-xl opacity-50">No logs found. Database empty.</p>
          ) : (
            posts.map((post) => (
              <article key={post.id} className="group cursor-pointer flex flex-col md:flex-row gap-4 md:gap-8 items-start neo-card p-6 hover:-translate-y-1 transition-transform">
                <div className="w-full md:w-32 pt-1 border-b-2 md:border-b-0 md:border-l-4 border-text md:pl-4 pb-2 md:pb-0 mb-2 md:mb-0">
                   <p className="font-pixel text-electric font-bold">
                     {format(new Date(post.created_at), 'MMM dd, yyyy')}
                   </p>
                </div>
                <div className="flex-1 w-full">
                  <h2 className="font-black text-2xl md:text-3xl uppercase mb-3">
                    <Link href={`/blog/${post.slug}`} className="hover:text-electric hover:underline decoration-4 underline-offset-4 transition-colors before:content-['>_'] before:text-lime before:mr-2">
                      {post.title}
                    </Link>
                  </h2>
                  <p className="text-base font-medium opacity-80 leading-relaxed line-clamp-2">
                    {/* Simple regex to strip markdown characters for excerpt */}
                    {post.content.replace(/[#*`_>]/g, '')}
                  </p>
                </div>
              </article>
            ))
          )}
        </div>
      </main>
      <SiteFooter />
    </>
  );
}
