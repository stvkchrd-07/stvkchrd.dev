// js/admin.js — Admin panel with Projects, Blog Posts, Working On

let supabaseClient;

// --- INIT ---
document.addEventListener('DOMContentLoaded', () => {
    if (!window.env || !window.env.SUPABASE_URL || !window.env.SUPABASE_ANON_KEY) {
        showToast('No Supabase config found. Add keys to config.js', 'error');
        return;
    }
    try {
        const { createClient } = window.supabase;
        supabaseClient = createClient(window.env.SUPABASE_URL, window.env.SUPABASE_ANON_KEY);
        loadProjects();
        loadBlogPosts();
        loadWorkingOn();

        document.getElementById('add-project-form').addEventListener('submit', handleAddProject);
        document.getElementById('add-blog-form').addEventListener('submit', handleAddBlogPost);
        document.getElementById('add-working-form').addEventListener('submit', handleAddWorkingOn);

        // Default today's date in blog form
        document.getElementById('blog-date').value = new Date().toISOString().split('T')[0];
    } catch (e) {
        showToast('Error initialising Supabase', 'error');
        console.error(e);
    }
});

// --- TABS ---
function switchTab(name) {
    document.querySelectorAll('.admin-panel').forEach(p => p.classList.remove('active'));
    document.querySelectorAll('.admin-tab').forEach(t => t.classList.remove('active'));
    document.getElementById('tab-' + name).classList.add('active');
    event.target.classList.add('active');
}

// --- TOAST ---
function showToast(msg, type = 'success') {
    const toast = document.getElementById('admin-toast');
    toast.textContent = msg;
    toast.className = 'admin-toast show' + (type === 'error' ? ' error' : '');
    setTimeout(() => { toast.classList.remove('show'); }, 2800);
}

// =====================
// PROJECTS
// =====================
async function loadProjects() {
    const list = document.getElementById('existing-projects-list');
    const { data, error } = await supabaseClient.from('projects').select('*').order('id', { ascending: false });
    if (error) { list.innerHTML = '<p class="admin-empty">Error loading projects.</p>'; return; }
    if (!data || data.length === 0) { list.innerHTML = '<p class="admin-empty">No projects yet.</p>'; return; }
    list.innerHTML = '';
    data.forEach(p => {
        const el = document.createElement('div');
        el.className = 'admin-list-item';
        el.innerHTML = `
            <div>
                <div class="admin-list-item-title">${p.title}</div>
                <div class="admin-list-item-sub">${p.subtitle || ''}</div>
            </div>
            <button class="admin-delete-btn" onclick="deleteProject(${p.id})">Delete</button>
        `;
        list.appendChild(el);
    });
}

async function handleAddProject(e) {
    e.preventDefault();
    const btn = e.target.querySelector('button[type=submit]');
    btn.disabled = true;
    btn.textContent = 'Saving...';

    const { error } = await supabaseClient.from('projects').insert([{
        title: document.getElementById('project-title').value,
        subtitle: document.getElementById('project-subtitle').value,
        description: document.getElementById('project-description').value,
        imageUrl: document.getElementById('project-image-url').value,
        liveUrl: document.getElementById('project-live-url').value,
    }]);

    btn.disabled = false;
    btn.textContent = 'Add Project';

    if (error) { showToast('Error adding project', 'error'); console.error(error); return; }
    showToast('Project added ✓');
    e.target.reset();
    loadProjects();
}

async function deleteProject(id) {
    if (!confirm('Delete this project?')) return;
    const { error } = await supabaseClient.from('projects').delete().match({ id });
    if (error) { showToast('Error deleting project', 'error'); return; }
    showToast('Project deleted');
    loadProjects();
}

// =====================
// BLOG POSTS
// =====================
async function loadBlogPosts() {
    const list = document.getElementById('existing-posts-list');
    const { data, error } = await supabaseClient.from('posts').select('*').order('date', { ascending: false });
    if (error) { list.innerHTML = '<p class="admin-empty">Error loading posts.</p>'; return; }
    if (!data || data.length === 0) { list.innerHTML = '<p class="admin-empty">No posts yet.</p>'; return; }
    list.innerHTML = '';
    data.forEach(p => {
        const el = document.createElement('div');
        el.className = 'admin-list-item';
        el.innerHTML = `
            <div>
                <div class="admin-list-item-title">${p.title}</div>
                <div class="admin-list-item-sub">${new Date(p.date).toLocaleDateString()}</div>
            </div>
            <button class="admin-delete-btn" onclick="deletePost(${p.id})">Delete</button>
        `;
        list.appendChild(el);
    });
}

async function handleAddBlogPost(e) {
    e.preventDefault();
    const btn = e.target.querySelector('button[type=submit]');
    btn.disabled = true;
    btn.textContent = 'Publishing...';

    const { error } = await supabaseClient.from('posts').insert([{
        title: document.getElementById('blog-title').value,
        date: document.getElementById('blog-date').value,
        content: document.getElementById('blog-content').value,
    }]);

    btn.disabled = false;
    btn.textContent = 'Publish Post';

    if (error) { showToast('Error publishing post', 'error'); console.error(error); return; }
    showToast('Post published ✓');
    e.target.reset();
    document.getElementById('blog-date').value = new Date().toISOString().split('T')[0];
    loadBlogPosts();
}

async function deletePost(id) {
    if (!confirm('Delete this post?')) return;
    const { error } = await supabaseClient.from('posts').delete().match({ id });
    if (error) { showToast('Error deleting post', 'error'); return; }
    showToast('Post deleted');
    loadBlogPosts();
}

// =====================
// CURRENTLY WORKING ON
// =====================
async function loadWorkingOn() {
    const list = document.getElementById('existing-working-list');
    const { data, error } = await supabaseClient.from('working_on').select('*').order('id', { ascending: false });
    if (error) { list.innerHTML = '<p class="admin-empty">Error loading cards.</p>'; return; }
    if (!data || data.length === 0) { list.innerHTML = '<p class="admin-empty">No cards yet.</p>'; return; }
    list.innerHTML = '';
    data.forEach(w => {
        const el = document.createElement('div');
        el.className = 'admin-list-item';
        el.innerHTML = `
            <div>
                <div class="admin-list-item-title">${w.title}</div>
                <div class="admin-list-item-sub">${w.tag || ''} ${w.status ? '· ' + w.status : ''}</div>
            </div>
            <button class="admin-delete-btn" onclick="deleteWorkingOn(${w.id})">Delete</button>
        `;
        list.appendChild(el);
    });
}

async function handleAddWorkingOn(e) {
    e.preventDefault();
    const btn = e.target.querySelector('button[type=submit]');
    btn.disabled = true;
    btn.textContent = 'Saving...';

    const { error } = await supabaseClient.from('working_on').insert([{
        title: document.getElementById('working-title').value,
        tag: document.getElementById('working-tag').value,
        description: document.getElementById('working-description').value,
        status: document.getElementById('working-status').value || 'Active',
    }]);

    btn.disabled = false;
    btn.textContent = 'Add Card';

    if (error) { showToast('Error adding card', 'error'); console.error(error); return; }
    showToast('Card added ✓');
    e.target.reset();
    loadWorkingOn();
}

async function deleteWorkingOn(id) {
    if (!confirm('Delete this card?')) return;
    const { error } = await supabaseClient.from('working_on').delete().match({ id });
    if (error) { showToast('Error deleting card', 'error'); return; }
    showToast('Card deleted');
    loadWorkingOn();
}
