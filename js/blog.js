// js/blog.js

// --- GLOBAL VARIABLES ---
let supabaseClient;

// --- EVENT LISTENERS ---
document.addEventListener('DOMContentLoaded', () => {
    // 1. INITIALIZE SUPABASE CLIENT
    // Use destructuring for clarity and create a single client instance.
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
        console.error('Error fetching posts:', error);
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

// --- THREE.JS BACKGROUND SCRIPT ---
const canvas = document.getElementById('bg-canvas');
if (canvas) {
    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
    camera.position.z = 10;
    const renderer = new THREE.WebGLRenderer({ canvas: canvas, alpha: true, antialias: true });
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    const particleCount = 2000; // Less dense
    const positions = new Float32Array(particleCount * 3);
    for (let i = 0; i < particleCount * 3; i++) { positions[i] = (Math.random() - 0.5) * 20; }
    const particlesGeometry = new THREE.BufferGeometry();
    particlesGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    const particlesMaterial = new THREE.PointsMaterial({ color: 0x000000, size: 0.02, sizeAttenuation: true });
    const particles = new THREE.Points(particlesGeometry, particlesMaterial);
    scene.add(particles);
    const mouse = new THREE.Vector2();
    window.addEventListener('mousemove', (event) => { mouse.x = (event.clientX / window.innerWidth) * 2 - 1; mouse.y = -(event.clientY / window.innerHeight) * 2 + 1; });
    const clock = new THREE.Clock();
    const animate = () => {
        const elapsedTime = clock.getElapsedTime();
        particles.rotation.y = -0.04 * elapsedTime; // Slower
        particles.rotation.x = -0.04 * elapsedTime; // Slower
        if(mouse.x !== 0 && mouse.y !== 0){
            const targetX = mouse.x * 0.2;
            const targetY = mouse.y * 0.2;
            particles.rotation.y += (targetX - particles.rotation.y) * 0.01; // Slower
            particles.rotation.x += (targetY - particles.rotation.x) * 0.01; // Slower
        }
        renderer.render(scene, camera);
        window.requestAnimationFrame(animate);
    };
    window.addEventListener('resize', () => {
        camera.aspect = window.innerWidth / window.innerHeight;
        camera.updateProjectionMatrix();
        renderer.setSize(window.innerWidth, window.innerHeight);
        renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    });
    animate();
}
