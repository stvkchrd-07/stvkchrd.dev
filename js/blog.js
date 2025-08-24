// js/blog.js

// --- GLOBAL VARIABLES ---
let supabaseClient;

// --- EVENT LISTENERS ---
document.addEventListener('DOMContentLoaded', () => {
    // 1. CHECK CONFIG AND INITIALIZE SUPABASE CLIENT
    if (!window.env || !window.env.SUPABASE_URL || !window.env.SUPABASE_ANON_KEY) {
        console.warn('Supabase environment variables are not set. Skipping blog load.');
        const postsContainer = document.querySelector('#blog-posts .space-y-8');
        if (postsContainer) postsContainer.innerHTML = '<p class="text-red-600">Could not connect to the database. Configuration is missing.</p>';
        return;
    }
    const { createClient } = window.supabase;
    supabaseClient = createClient(window.env.SUPABASE_URL, window.env.SUPABASE_ANON_KEY);

    // 2. LOAD DYNAMIC CONTENT
    loadPublicBlogPosts();
});

// --- DYNAMIC BLOG POST LOADING ---
async function loadPublicBlogPosts() {
    if (!supabaseClient) return; // Don't run if supabase isn't initialized

    const { data: posts, error } = await supabaseClient.from('posts').select('*').order('date', { ascending: false });
    if (error) {
        console.warn('Error fetching posts:', error);
        return;
    }

    const postsContainer = document.querySelector('#blog-posts .space-y-8');
    if (!postsContainer) return;

    postsContainer.innerHTML = ''; // Clear hardcoded posts

    posts.forEach(post => {
        const postDiv = document.createElement('div');
        postDiv.className = 'border-2 border-black p-6 md:p-8 bg-white/80 backdrop-blur-sm';
        
        // Create a summary and parse it as Markdown
        const summaryMarkdown = post.content.substring(0, 250) + (post.content.length > 250 ? '...' : '');
        const summaryHtml = marked.parse(summaryMarkdown);

        postDiv.innerHTML = `
            <p class="text-base mb-2">${new Date(post.date).toLocaleDateString()}</p>
            <h2 class="font-black text-3xl md:text-4xl mb-4">${post.title}</h2>
            <div class="text-lg mb-4 post-summary">${summaryHtml}</div>
            <a href="post.html?id=${post.id}" class="font-bold underline hover:no-underline">Read More &rarr;</a>
        `;
        postsContainer.appendChild(postDiv);
    });
}


// --- EXISTING PAGE LOGIC (Unaltered) ---

// --- EMAIL COPY SCRIPT ---
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

// Background handled globally by main.js to avoid duplicate initializations
