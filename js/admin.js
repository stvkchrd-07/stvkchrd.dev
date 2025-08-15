/*
=====================================================================
|                ADMIN PAGE JAVASCRIPT (CORRECTED)                  |
=====================================================================
*/

// --- GLOBAL VARIABLES ---
let supabaseClient;

// --- EVENT LISTENERS ---
document.addEventListener('DOMContentLoaded', () => {
    // 1. INITIALIZE SUPABASE CLIENT
    // Use destructuring for clarity and create a single client instance.
    const { createClient } = window.supabase;
    supabaseClient = createClient(window.env.SUPABASE_URL, window.env.SUPABASE_ANON_KEY);
    
    // 2. LOAD DYNAMIC CONTENT
    loadProjects();
    loadBlogPosts();

    // 3. ATTACH FORM LISTENERS
    const addProjectForm = document.getElementById('add-project-form');
    addProjectForm.addEventListener('submit', handleAddProject);

    const addBlogForm = document.getElementById('add-blog-form');
    addBlogForm.addEventListener('submit', handleAddBlogPost);
});

// --- PROJECT MANAGEMENT ---

async function loadProjects() {
    if (!supabaseClient) return;

    const { data: projects, error } = await supabaseClient.from('projects').select('*').order('id', { ascending: false });
    
    if (error) {
        console.error('Error fetching projects:', error);
        return;
    }

    const projectList = document.getElementById('existing-projects-list');
    projectList.innerHTML = '';

    if (!projects || projects.length === 0) {
        projectList.innerHTML = '<p>No projects found. Add one using the form above.</p>';
        return;
    }

    projects.forEach(project => {
        const projectElement = document.createElement('div');
        projectElement.className = 'border-2 border-black p-4 bg-white flex justify-between items-center';
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
    if (!supabaseClient) return;

    const newProject = {
        title: document.getElementById('project-title').value,
        subtitle: document.getElementById('project-subtitle').value,
        description: document.getElementById('project-description').value,
        imageUrl: document.getElementById('project-image-url').value,
        liveUrl: document.getElementById('project-live-url').value,
    };

    const { error } = await supabaseClient.from('projects').insert([newProject]);
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
        if (!supabaseClient) return;
        const { error } = await supabaseClient.from('projects').delete().match({ id: id });
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
    if (!supabaseClient) return;

    const { data: posts, error } = await supabaseClient.from('posts').select('*').order('date', { ascending: false });
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
    if (!supabaseClient) return;

    const newPost = {
        title: document.getElementById('blog-title').value,
        date: document.getElementById('blog-date').value,
        content: document.getElementById('blog-content').value,
    };

    const { error } = await supabaseClient.from('posts').insert([newPost]);
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
        if (!supabaseClient) return;
        const { error } = await supabaseClient.from('posts').delete().match({ id: id });
        if (error) {
            console.error('Error deleting post:', error);
            alert('Error: Could not delete post.');
        } else {
            loadBlogPosts();
        }
    }
}
