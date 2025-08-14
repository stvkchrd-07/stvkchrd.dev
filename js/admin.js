/*
    =====================================================================
    |                ADMIN PAGE JAVASCRIPT (FRONTEND LOGIC)             |
    =====================================================================
    | This file contains the frontend logic for your admin panel.       |
    | It handles form submissions and displays data.                    |
    |                                                                   |
    | IMPORTANT: This is a TEMPLATE. To make it work, you must          |
    | connect it to a real backend and database (like Supabase).        |
    | The functions below (like `fetchProjects`, `addProject`, etc.)    |
    | are placeholders showing where you would make API calls.          |
    =====================================================================
*/

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
    console.log("Fetching projects from the database...");
    // ** BACKEND HOOK: Replace this with an API call to your database **
    const projects = await fetchProjectsFromDB(); // This is a placeholder
    
    const projectList = document.getElementById('existing-projects-list');
    projectList.innerHTML = ''; // Clear the list first

    if (projects.length === 0) {
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
                <button class="underline mr-4" onclick="editProject('${project.id}')">Edit</button>
                <button class="underline text-red-600" onclick="deleteProject('${project.id}')">Delete</button>
            </div>
        `;
        projectList.appendChild(projectElement);
    });
}

async function handleAddProject(event) {
    event.preventDefault();
    const title = document.getElementById('project-title').value;
    const subtitle = document.getElementById('project-subtitle').value;
    const description = document.getElementById('project-description').value;
    const imageUrl = document.getElementById('project-image-url').value;
    const liveUrl = document.getElementById('project-live-url').value;

    const newProject = { title, subtitle, description, imageUrl, liveUrl };
    
    console.log("Adding new project:", newProject);
    // ** BACKEND HOOK: Replace this with an API call to add the project to your DB **
    await addProjectToDB(newProject); // This is a placeholder

    // Reset the form and reload the project list
    event.target.reset();
    loadProjects();
}

// --- BLOG POST MANAGEMENT ---

async function loadBlogPosts() {
    console.log("Fetching blog posts from the database...");
    // ** BACKEND HOOK: Replace this with an API call to your database **
    const posts = await fetchBlogPostsFromDB(); // This is a placeholder

    const postList = document.getElementById('existing-posts-list');
    postList.innerHTML = ''; // Clear the list

    if (posts.length === 0) {
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
                <button class="underline mr-4" onclick="editPost('${post.id}')">Edit</button>
                <button class="underline text-red-600" onclick="deletePost('${post.id}')">Delete</button>
            </div>
        `;
        postList.appendChild(postElement);
    });
}

async function handleAddBlogPost(event) {
    event.preventDefault();
    const title = document.getElementById('blog-title').value;
    const date = document.getElementById('blog-date').value;
    const content = document.getElementById('blog-content').value;

    const newPost = { title, date, content };

    console.log("Adding new blog post:", newPost);
    // ** BACKEND HOOK: Replace this with an API call to add the post to your DB **
    await addBlogPostToDB(newPost); // This is a placeholder

    // Reset the form and reload the post list
    event.target.reset();
    loadBlogPosts();
}


/*
    =====================================================================
    |                   DATABASE HELPER FUNCTIONS (PLACEHOLDERS)        |
    =====================================================================
    | The functions below simulate fetching data from a database.       |
    | You will replace these with actual `fetch` calls to your backend. |
    =====================================================================
*/

// Placeholder for fetching projects
async function fetchProjectsFromDB() {
    // In a real app, this would be:
    // const response = await fetch('/api/projects');
    // const data = await response.json();
    // return data;
    return [
        { id: '1', title: 'Project Title One', subtitle: '2024 - Web Application' },
        { id: '2', title: 'Another Major Project', subtitle: '2023 - Mobile App' },
    ];
}

// Placeholder for adding a project
async function addProjectToDB(project) {
    // In a real app, this would be:
    // await fetch('/api/projects', {
    //     method: 'POST',
    //     headers: { 'Content-Type': 'application/json' },
    //     body: JSON.stringify(project)
    // });
    console.log('Pretending to save project to DB:', project);
    return;
}

// Placeholder for fetching blog posts
async function fetchBlogPostsFromDB() {
    return [
        { id: '101', title: 'On the Nature of Raw Design', date: '2025-08-10' },
        { id: '102', title: 'Why I Chose a Monospaced Font', date: '2025-07-28' },
    ];
}

// Placeholder for adding a blog post
async function addBlogPostToDB(post) {
    console.log('Pretending to save blog post to DB:', post);
    return;
}
