// js/blog.js

// --- GLOBAL VARIABLES ---
let blogSupabaseClient;

// Sample blog posts for when Supabase is not configured
const sampleBlogPosts = [
    {
        id: 1,
        title: "Welcome to My Blog",
        date: "2025-01-15",
        content: "This is a sample blog post to demonstrate the website functionality. Replace with your actual blog posts by configuring Supabase or updating the sample data. You can write about your projects, thoughts, or anything you'd like to share with your audience."
    },
    {
        id: 2,
        title: "Building This Portfolio",
        date: "2025-01-10",
        content: "I built this portfolio website using modern web technologies including HTML5, CSS3, JavaScript, and Three.js for the interactive background. The design follows a brutalist aesthetic with clean typography and smooth animations."
    }
];

// --- EVENT LISTENERS ---
document.addEventListener('DOMContentLoaded', () => {
    // 1. CHECK CONFIG AND INITIALIZE SUPABASE CLIENT
    if (!window.env || !window.env.SUPABASE_URL || !window.env.SUPABASE_ANON_KEY) {
        console.warn('Supabase credentials not found. Using sample data.');
        loadSampleBlogPosts();
    } else {
        try {
            const { createClient } = window.supabase;
            blogSupabaseClient = createClient(window.env.SUPABASE_URL, window.env.SUPABASE_ANON_KEY);
            loadPublicBlogPosts();
        } catch (error) {
            console.error('Error initializing Supabase client:', error);
            loadSampleBlogPosts();
        }
    }
});

// --- DYNAMIC BLOG POST LOADING ---
async function loadPublicBlogPosts() {
    if (!blogSupabaseClient) {
        loadSampleBlogPosts();
        return;
    }

    try {
        const { data: posts, error } = await blogSupabaseClient.from('posts').select('*').order('date', { ascending: false });
        if (error) {
            console.warn('Error fetching posts:', error);
            loadSampleBlogPosts();
            return;
        }

        if (!posts || posts.length === 0) {
            console.log('No blog posts found in database, loading sample data');
            loadSampleBlogPosts();
            return;
        }

        displayBlogPosts(posts);
    } catch (error) {
        console.error('Error in loadPublicBlogPosts:', error);
        loadSampleBlogPosts();
    }
}

function loadSampleBlogPosts() {
    console.log('Loading sample blog posts');
    displayBlogPosts(sampleBlogPosts);
}

function displayBlogPosts(posts) {
    const postsContainer = document.querySelector('#blog-posts .space-y-8');
    if (!postsContainer) return;

    postsContainer.innerHTML = ''; // Clear existing content

    posts.forEach(post => {
        const postDiv = document.createElement('div');
        postDiv.className = 'border-2 border-black p-6 md:p-8 bg-white/80 backdrop-blur-sm';
        
        // Create a summary and parse it as Markdown if marked is available
        const summaryMarkdown = post.content.substring(0, 250) + (post.content.length > 250 ? '...' : '');
        let summaryHtml = summaryMarkdown;
        
        if (window.marked) {
            summaryHtml = marked.parse(summaryMarkdown);
        }

        postDiv.innerHTML = `
            <p class="text-base mb-2">${new Date(post.date).toLocaleDateString()}</p>
            <h2 class="font-black text-3xl md:text-4xl mb-4">${post.title}</h2>
            <div class="text-lg mb-4 post-summary">${summaryHtml}</div>
            <a href="post.html?id=${post.id}" class="font-bold underline hover:no-underline">Read More &rarr;</a>
        `;
        postsContainer.appendChild(postDiv);
    });
}


// copyEmailToClipboard is in utils.js — loaded before this file
