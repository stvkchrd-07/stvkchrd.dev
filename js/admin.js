/*
=====================================================================
|                ADMIN PAGE JAVASCRIPT (CORRECTED)                  |
=====================================================================
*/

// 1. INITIALIZE SUPABASE CLIENT
// IMPORTANT: Make sure these are correct
const SUPABASE_URL = 'https://nxhoyxvuyehqnnrqhyom.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54aG95eHZ1eWVocW5ucnFoeW9tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUyMDg2OTEsImV4cCI6MjA3MDc4NDY5MX0.pRUwKmZOxBOQCWdJLJLPgIP_YDkXp5iMPUBN2RpHb5I';

const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// --- EVENT LISTENERS ---
document.addEventListener('DOMContentLoaded', () => {
    // When the page loads, fetch and display existing content
    loadProjects();
    loadBlogPosts();

    // Add event listeners to the forms
    const addProjectForm = document.getElementById('add-project-form');
    addProjectForm.addEventListener('submit', handleAddProject);

    const addBlogForm = document.getElementById('add-blog-form');
    addBlogForm.addEventListener('submit', handleAddBlogPost);
});

// --- PROJECT MANAGEMENT ---

async function loadProjects() {
    const { data: projects, error } = await supabase.from('projects').select('*').order('id', { ascending: false });
    
    // DEBUG: Check the console for errors or data
    if (error) {
        console.error('Error fetching projects:', error);
        return;
    }
    console.log("Projects fetched from Supabase:", projects); // Check if data arrives here

    const projectList = document.getElementById('existing-projects-list');
    projectList.innerHTML = ''; // Clear the list first

    if (!projects || projects.length === 0) {
        projectList.innerHTML = '<p>No projects found. Add one using the form above.</p>';
        return;
    }

    projects.forEach(project => {
        const projectElement = document.createElement('div');
        projectElement.className = 'border-2 border-black p-4 bg-white flex justify-between items-center';
        // CORRECTED: Added quotes around the project.id in the onclick function
        projectElement.innerHTML = `
            <div>
                <h4 class="font-bold text-xl">${project.title}</h4>
                <p>${project.subtitle}</p>
            </div>
            <div>
                <button class="underline text-red-600" onclick="deleteProject(${project.id})">Delete</button>
            </div>
        `;
        projectList.appendChild(projectElement);
    });
}

async function handleAddProject(event) {
    event.preventDefault();
    const newProject = {
        title: document.getElementById('project-title').value,
        subtitle: document.getElementById('project-subtitle').value,
        description: document.getElementById('project-description').value,
        imageUrl: document.getElementById('project-image-url').value,
        liveUrl: document.getElementById('project-live-url').value,
    };

    const { error } = await supabase.from('projects').insert([newProject]);
    if (error) {
        console.error('Error adding project:', error);
        alert('Error: Could not add project.');
    } else {
        event.target.reset();
        loadProjects();
    }
}

async function deleteProject(id) {
    if (confirm('Are you sure you want to delete this project?')) {
        const { error } = await supabase.from('projects').delete().match({ id: id });
        if (error) {
            console.error('Error deleting project:', error);
            alert('Error: Could not delete project.');
        } else {
            loadProjects();
        }
    }
}

// --- BLOG POST MANAGEMENT ---

async function loadBlogPosts() {
    const { data: posts, error } = await supabase.from('posts').select('*').order('date', { ascending: false });
    if (error) {
        console.error('Error fetching posts:', error);
        return;
    }
    
    const postList = document.getElementById('existing-posts-list');
    postList.innerHTML = '';

    if (!posts || posts.length === 0) {
        postList.innerHTML = '<p>No blog posts found. Add one using the form above.</p>';
        return;
    }

    posts.forEach(post => {
        const postElement = document.createElement('div');
        postElement.className = 'border-2 border-black p-4 bg-white flex justify-between items-center';
        // CORRECTED: Added quotes around the post.id in the onclick function
        postElement.innerHTML = `
            <div>
                <h4 class="font-bold text-xl">${post.title}</h4>
                <p>${new Date(post.date).toLocaleDateString()}</p>
            </div>
            <div>
                <button class="underline text-red-600" onclick="deletePost(${post.id})">Delete</button>
            </div>
        `;
        postList.appendChild(postElement);
    });
}

async function handleAddBlogPost(event) {
    event.preventDefault();
    const newPost = {
        title: document.getElementById('blog-title').value,
        date: document.getElementById('blog-date').value,
        content: document.getElementById('blog-content').value,
    };

    const { error } = await supabase.from('posts').insert([newPost]);
    if (error) {
        console.error('Error adding post:', error);
        alert('Error: Could not add post.');
    } else {
        event.target.reset();
        loadBlogPosts();
    }
}

async function deletePost(id) {
    if (confirm('Are you sure you want to delete this post?')) {
        const { error } = await supabase.from('posts').delete().match({ id: id });
        if (error) {
            console.error('Error deleting post:', error);
            alert('Error: Could not delete post.');
        } else {
            loadBlogPosts();
        }
    }
}
