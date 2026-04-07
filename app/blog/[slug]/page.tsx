import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import ReactMarkdown from 'react-markdown';
import { createServerSupabaseClient } from '@/lib/supabase/server';
import { format } from 'date-fns';
import { notFound } from 'next/navigation';
import Link from 'next/link';

export const dynamic = 'force-dynamic';

export default async function SingleBlogPage({ params }: { params: { slug: string } }) {
  const supabase = createServerSupabaseClient();
  const { data: post } = await supabase.from('blog_posts').select('*').eq('slug', params.slug).single();

  if (!post) {
    notFound();
  }

  return (
    <>
      <SiteHeader active="blog" />
      <main className="max-w-3xl mx-auto mt-12 px-4 min-h-[60vh] relative z-30 pb-20">
        
        <Link href="/blog" className="font-pixel text-electric hover:text-lime hover:underline mb-8 inline-block font-bold">
          &lt;- RETURN TO LOGS
        </Link>

        <header className="mb-12 border-b-4 border-text pb-8">
          <h1 className="font-black text-4xl md:text-6xl uppercase tracking-tighter leading-none mb-4">
            {post.title}
          </h1>
          <div className="flex items-center gap-4 font-pixel">
            <span className="bg-black text-lime px-2 py-1">AUTHOR: ADMIN</span>
            <span className="opacity-60">{format(new Date(post.created_at), 'MMMM do, yyyy')}</span>
          </div>
        </header>
        
        {/* The Prose class utilizes the Tailwind Typography plugin we just installed */}
        <article className="prose prose-lg prose-neutral dark:prose-invert max-w-none 
          prose-headings:font-black prose-headings:uppercase prose-headings:tracking-tight
          prose-a:text-electric prose-a:font-bold prose-a:underline prose-a:decoration-2 hover:prose-a:text-lime
          prose-p:font-medium prose-p:leading-relaxed prose-p:text-lg
          prose-pre:bg-card prose-pre:border-2 prose-pre:border-text prose-pre:rounded-none prose-pre:shadow-neo
          prose-img:border-2 prose-img:border-text prose-img:shadow-neo">
          <ReactMarkdown>{post.content}</ReactMarkdown>
        </article>

      </main>
      <SiteFooter />
    </>
  );
}
