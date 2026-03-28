import { notFound } from 'next/navigation';
import { marked } from 'marked';
import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import { createServerSupabaseClient } from '@/lib/supabase/server';
import Link from 'next/link';

export default async function PostPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const supabase = createServerSupabaseClient();

  const { data: post } = await supabase
    .from('posts')
    .select('title, content, date')
    .eq('id', id)
    .single();

  if (!post) notFound();

  return (
    <>
      <SiteHeader />
      <main className="mt-12">
        <article className="border-2 border-black p-6 md:p-8 bg-white/80 backdrop-blur-sm">
          <p className="text-base mb-2">
            {new Date(post.date).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })}
          </p>
          <h1 className="font-black text-3xl md:text-4xl mb-8">{post.title}</h1>
          <div
            className="post-content"
            dangerouslySetInnerHTML={{ __html: marked.parse(post.content) as string }}
          />
        </article>
        <div className="mt-8">
          <Link href="/blog" className="font-bold underline hover:no-underline">← Back to Blog</Link>
        </div>
        <div className="h-32 md:h-64 lg:h-96" />
      </main>
      <SiteFooter />
    </>
  );
}
