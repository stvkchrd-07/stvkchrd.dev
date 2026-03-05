// js/post.js

function getPostIdFromUrl() {
    const params = new URLSearchParams(window.location.search);
    return params.get('id');
}

function renderPostBody(markdownText) {
    if (!window.marked) {
        return `<p>${escapeHtml(markdownText || '')}</p>`;
    }

    const rendered = marked.parse(markdownText || '', { breaks: true });
    return rendered.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '');
}

document.addEventListener('DOMContentLoaded', async () => {
    const loadingDiv = document.getElementById('post-loading');
    const contentArea = document.getElementById('post-content-area');
    const notFoundDiv = document.getElementById('post-not-found');

    const fail = () => {
        if (loadingDiv) loadingDiv.classList.add('hidden');
        if (notFoundDiv) notFoundDiv.classList.remove('hidden');
    };

    const postId = getPostIdFromUrl();
    if (!postId) {
        fail();
        return;
    }

    if (!window.env || !window.env.SUPABASE_URL || !window.env.SUPABASE_ANON_KEY || !window.supabase) {
        if (loadingDiv) {
            loadingDiv.innerHTML = '<p class="text-lg text-red-600">Configuration error. Cannot connect to the database.</p>';
        }
        return;
    }

    try {
        const { createClient } = window.supabase;
        const supabaseClient = createClient(window.env.SUPABASE_URL, window.env.SUPABASE_ANON_KEY);

        const { data: post, error } = await supabaseClient
            .from('posts')
            .select('title, content, date')
            .eq('id', postId)
            .single();

        if (error || !post) {
            throw new Error('Post not found');
        }

        document.title = `${post.title} | Satvik Chaturvedi`;
        document.getElementById('post-date').textContent = formatDate(post.date, {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
        });
        document.getElementById('post-title').textContent = post.title || 'Untitled post';
        document.getElementById('post-body').innerHTML = renderPostBody(post.content);

        if (loadingDiv) loadingDiv.classList.add('hidden');
        if (contentArea) contentArea.classList.remove('hidden');
    } catch (error) {
        console.warn('Error loading post:', error);
        fail();
    }
});
