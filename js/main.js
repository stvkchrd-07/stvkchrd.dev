// js/main.js

// --- GLOBAL VARIABLES ---
let supabase;

// --- EVENT LISTENERS ---
document.addEventListener('DOMContentLoaded', () => {
    // 1. INITIALIZE SUPABASE CLIENT (This now runs safely after the page loads)
    const SUPABASE_URL = window.env.SUPABASE_URL;
    const SUPABASE_ANON_KEY = window.env.SUPABASE_ANON_KEY;
    supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

    // 2. LOAD DYNAMIC CONTENT
    loadPublicProjects();
});

// --- DYNAMIC PROJECT LOADING ---
async function loadPublicProjects() {
    if (!supabase) return; // Don't run if supabase isn't initialized

    const { data: projects, error } = await supabase.from('projects').select('*').order('id', { ascending: false });
    if (error) {
        console.error('Error fetching projects:', error);
        return;
    }

    const projectsContainer = document.querySelector('#projects .grid');
    if (!projectsContainer) return;
    
    projectsContainer.innerHTML = ''; // Clear hardcoded projects

    projects.forEach(project => {
        const projectDiv = document.createElement('div');
        projectDiv.className = 'brutalist-hover border-2 border-black p-6 bg-white/80 backdrop-blur-sm';
        projectDiv.innerHTML = `
            <h3 class="font-black text-2xl md:text-3xl">${project.title}</h3>
            <p class="mt-1 text-base">${project.subtitle}</p>
        `;
        projectDiv.onclick = () => openModal(project.title, project.description, project.imageUrl, project.liveUrl);
        projectsContainer.appendChild(projectDiv);
    });
}


// --- EXISTING PAGE LOGIC (Unaltered) ---

// --- LOADING SCREEN SCRIPT ---
const loaderText = document.getElementById('loader-text');
const loaderBar = document.getElementById('loader-bar');
const loaderContainer = document.getElementById('loader');
if (loaderContainer) {
    let progress = 0;
    const interval = setInterval(() => {
        progress += 1;
        if (loaderText) loaderText.textContent = `${progress}%`;
        if (loaderBar) loaderBar.style.width = `${progress}%`;
        if (progress >= 100) {
            clearInterval(interval);
            setTimeout(() => {
                loaderContainer.style.display = 'none';
            }, 500);
        }
    }, 10);
}


// --- PROJECT MODAL SCRIPT ---
const modal = document.getElementById('project-modal');
const modalTitle = document.getElementById('modal-title');
const modalDescription = document.getElementById('modal-description');
const modalImage = document.getElementById('modal-image');
const modalLink = document.getElementById('modal-link');

function openModal(title, description, imageUrl, projectUrl) {
    if (!modal) return;
    modalTitle.textContent = title;
    modalDescription.textContent = description;
    modalImage.src = imageUrl;
    modalLink.href = projectUrl;
    modal.style.display = 'block';
}

function closeModal() {
    if (modal) modal.style.display = 'none';
}

window.onclick = function(event) {
    if (event.target == modal) {
        closeModal();
    }
}

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
