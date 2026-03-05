// js/blog.js

let blogSupabaseClient;

const sampleBlogPosts = [
    {
        id: 1,
        title: 'Welcome to My Blog',
        date: '2025-01-15',
        content: 'This is a sample blog post to demonstrate the website functionality. Replace with your actual blog posts by configuring Supabase or updating the sample data.',
    },
    {
        id: 2,
        title: 'Building This Portfolio',
        date: '2025-01-10',
        content: 'I built this portfolio website using modern web technologies including HTML5, CSS3, JavaScript, and Three.js for the interactive background.',
    },
];

function toSafeSummary(markdownText) {
    const trimmed = (markdownText || '').slice(0, 250);
    const summaryText = `${trimmed}${(markdownText || '').length > 250 ? '…' : ''}`;

    if (!window.marked) {
        return `<p>${escapeHtml(summaryText)}</p>`;
    }

    const rendered = marked.parse(summaryText, { breaks: true });
    return rendered.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '');
}

function createPostCard(post) {
    const postDiv = document.createElement('article');
    postDiv.className = 'border-2 border-black p-6 md:p-8 bg-white/80 backdrop-blur-sm';

    const date = document.createElement('p');
    date.className = 'text-base mb-2';
    date.textContent = formatDate(post.date);

    const title = document.createElement('h2');
    title.className = 'font-black text-3xl md:text-4xl mb-4';
    title.textContent = post.title || 'Untitled post';

    const summary = document.createElement('div');
    summary.className = 'text-lg mb-4 post-summary';
    summary.innerHTML = toSafeSummary(post.content);

    const readMore = document.createElement('a');
    readMore.href = `post.html?id=${encodeURIComponent(post.id)}`;
    readMore.className = 'font-bold underline hover:no-underline';
    readMore.innerHTML = 'Read More &rarr;';

    postDiv.append(date, title, summary, readMore);
    return postDiv;
}

function displayBlogPosts(posts) {
    const postsContainer = document.querySelector('#blog-posts .space-y-8');
    if (!postsContainer) return;

    postsContainer.innerHTML = '';
    posts.forEach((post) => {
        postsContainer.appendChild(createPostCard(post));
    });
}

async function loadPublicBlogPosts() {
    if (!blogSupabaseClient) {
        displayBlogPosts(sampleBlogPosts);
        return;
    }

    try {
        const { data: posts, error } = await blogSupabaseClient
            .from('posts')
            .select('*')
            .order('date', { ascending: false });

        if (error || !posts || posts.length === 0) {
            displayBlogPosts(sampleBlogPosts);
            return;
        }

        displayBlogPosts(posts);
    } catch (error) {
        console.error('Error loading blog posts:', error);
        displayBlogPosts(sampleBlogPosts);
    }
}

document.addEventListener('DOMContentLoaded', () => {
    if (!window.env || !window.env.SUPABASE_URL || !window.env.SUPABASE_ANON_KEY || !window.supabase) {
        displayBlogPosts(sampleBlogPosts);
        return;
    }

    const { createClient } = window.supabase;
    blogSupabaseClient = createClient(window.env.SUPABASE_URL, window.env.SUPABASE_ANON_KEY);
    loadPublicBlogPosts();
});
