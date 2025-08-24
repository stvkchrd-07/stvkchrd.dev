// js/post.js

// --- EVENT LISTENERS ---
document.addEventListener('DOMContentLoaded', () => {
    // --- Supabase and Post Loading Logic ---

    // Check for config
    if (!window.env || !window.env.SUPABASE_URL || !window.env.SUPABASE_ANON_KEY) {
        console.warn('Supabase environment variables are not set. Skipping post load.');
        const loadingDiv = document.getElementById('post-loading');
        loadingDiv.innerHTML = '<p class="text-lg text-red-600">Configuration error. Cannot connect to the database.</p>';
        return;
    }

    const { createClient } = window.supabase;
    const supabaseClient = createClient(window.env.SUPABASE_URL, window.env.SUPABASE_ANON_KEY);

    const getPostIdFromUrl = () => {
        const params = new URLSearchParams(window.location.search);
        return params.get('id');
    };

    const loadPost = async () => {
        const postId = getPostIdFromUrl();
        const loadingDiv = document.getElementById('post-loading');
        const contentArea = document.getElementById('post-content-area');
        const notFoundDiv = document.getElementById('post-not-found');

        if (!postId) {
            loadingDiv.classList.add('hidden');
            notFoundDiv.classList.remove('hidden');
            return;
        }

        try {
            // Fetch the specific post using its ID
            const { data: post, error } = await supabaseClient
                .from('posts')
                .select('title, content, date') // Using 'date' for consistency with other files
                .eq('id', postId)
                .single(); // .single() is crucial to get one object, not an array

            if (error || !post) {
                throw new Error('Post not found or database error.');
            }

            // Populate the page with the fetched data
            document.title = `${post.title} | Satvik Chaturvedi`;
            document.getElementById('post-date').textContent = new Date(post.date).toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'long',
                day: 'numeric',
            });
            document.getElementById('post-title').textContent = post.title;
            
            // Use the 'marked' library to parse markdown content into HTML
            if (window.marked) {
                document.getElementById('post-body').innerHTML = marked.parse(post.content);
            } else {
                console.error('Marked.js library not found.');
                document.getElementById('post-body').textContent = 'Error: Markdown parser not loaded.';
            }

            // Show the content and hide the loading message
            loadingDiv.classList.add('hidden');
            contentArea.classList.remove('hidden');

        } catch (error) {
            console.warn('Error loading post:', error.message);
            loadingDiv.classList.add('hidden');
            notFoundDiv.classList.remove('hidden');
        }
    };

    // --- Load the post ---
    loadPost();
});

function copyEmailToClipboard(email) {
    const textArea = document.createElement('textarea');
    textArea.value = email;
    textArea.style.position = 'fixed';
    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();
    try {
        document.execCommand('copy');
        const toast = document.getElementById('copy-toast');
        if (toast) {
            toast.textContent = `${email} copied to clipboard`;
            toast.classList.add('show');
            setTimeout(() => { toast.classList.remove('show'); }, 800);
        }
    } catch (err) {
        console.error('Fallback: Oops, unable to copy', err);
    }
    document.body.removeChild(textArea);
}