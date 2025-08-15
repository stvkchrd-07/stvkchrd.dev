// js/blog.js

// --- SUPABASE INITIALIZATION ---
// IMPORTANT: Replace these with your actual Supabase Project URL and Anon Key
const SUPABASE_URL = 'https://nxhoyxvuyehqnnrqhyom.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54aG95eHZ1eWVocW5ucnFoeW9tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUyMDg2OTEsImV4cCI6MjA3MDc4NDY5MX0.pRUwKmZOxBOQCWdJLJLPgIP_YDkXp5iMPUBN2RpHb5I';
const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// --- EVENT LISTENERS ---
document.addEventListener('DOMContentLoaded', () => {
    // This will now fetch blog posts from your database when the page loads
    loadPublicBlogPosts();
});

// --- DYNAMIC BLOG POST LOADING ---
async function loadPublicBlogPosts() {
    const { data: posts, error } = await supabase.from('posts').select('*').order('date', { ascending: false });
    if (error) {
        console.error('Error fetching posts:', error);
        return;
    }

    const postsContainer = document.querySelector('#blog-posts .space-y-8');
    if (!postsContainer) return; // Exit if the container isn't on the page

    postsContainer.innerHTML = ''; // Clear any hardcoded posts

    posts.forEach(post => {
        const postDiv = document.createElement('div');
        postDiv.className = 'border-2 border-black p-6 md:p-8 bg-white/80 backdrop-blur-sm';
        // Displaying a summary. A full "Read More" would require a separate page for each post.
        const summary = post.content.substring(0, 250) + '...'; 
        postDiv.innerHTML = `
            <p class="text-base mb-2">${new Date(post.date).toLocaleDateString()}</p>
            <h2 class="font-black text-3xl md:text-4xl mb-4">${post.title}</h2>
            <p class="text-lg mb-4">${summary}</p>
            <a href="#" class="font-bold underline hover:no-underline">Read More &rarr;</a>
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
    const particleCount = 5000;
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
        particles.rotation.y = -0.1 * elapsedTime;
        particles.rotation.x = -0.1 * elapsedTime;
        if(mouse.x !== 0 && mouse.y !== 0){
            const targetX = mouse.x * 0.2;
            const targetY = mouse.y * 0.2;
            particles.rotation.y += (targetX - particles.rotation.y) * 0.02;
            particles.rotation.x += (targetY - particles.rotation.x) * 0.02;
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
