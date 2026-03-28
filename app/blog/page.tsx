import SiteHeader from '@/components/SiteHeader';
import SiteFooter from '@/components/SiteFooter';
import { createServerSupabaseClient } from '@/lib/supabase/server';
import { marked } from 'marked';
import Link from 'next/link';

const samplePosts = [
  { id: 1, title: 'Welcome to My Blog', date: '2025-01-15', content: 'This is a sample blog post. Configure Supabase to load real posts.' },
  { id: 2, title: 'Building This Portfolio', date: '2025-01-10', content: 'I built this portfolio using Next.js, Three.js, and Supabase.' }
];

export default async function BlogPage() {
  const supabase = createServerSupabaseClient();
  const { data: posts } = await supabase.from('posts').select('*').order('date', { ascending: false });
  const displayPosts = posts && posts.length > 0 ? posts : samplePosts;

  return (
    <>
      <SiteHeader active="blog" />
      <p className="lekh-title mt-2">लेख</p>

      <main className="mt-12">
        <section id="blog-posts">
          <div className="space-y-8">
            {displayPosts.map((post) => (
              <article key={post.id} className="border-2 border-black p-6 md:p-8 bg-white/80 backdrop-blur-sm">
                <p className="text-base mb-2">{new Date(post.date).toLocaleDateString()}</p>
                <h2 className="font-black text-3xl md:text-4xl mb-4">{post.title}</h2>
                <div
                  className="text-lg mb-4"
                  dangerouslySetInnerHTML={{
                    __html: marked.parse(post.content.slice(0, 250) + (post.content.length > 250 ? '...' : '')) as string
                  }}
                />
                <Link href={`/post/${post.id}`} className="font-bold underline hover:no-underline">
                  Read More →
                </Link>
              </article>
            ))}
          </div>
          <div className="h-32 md:h-64 lg:h-96" />
        </section>
      </main>

      <SiteFooter />
    </>
  );
}
