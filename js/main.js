// js/main.js

let supabaseClient;
let particlesMaterial;
let particleColorAnimationCounter = 0;

const sampleProjects = [
    {
        title: 'Portfolio Website',
        subtitle: '2025 - Personal Website',
        description: 'A modern, responsive portfolio website built with HTML, CSS, and JavaScript. Features include dark/light theme toggle, Three.js particle background, and dynamic content loading.',
        imageUrl: 'https://via.placeholder.com/600x400/000000/FFFFFF?text=Portfolio+Website',
        liveUrl: '#',
    },
    {
        title: 'Sample Project',
        subtitle: '2025 - Web Application',
        description: 'This is sample content. Replace with your real projects by connecting Supabase.',
        imageUrl: 'https://via.placeholder.com/600x400/333333/FFFFFF?text=Sample+Project',
        liveUrl: '#',
    },
];

function getParticleCssColor() {
    return getComputedStyle(document.body).getPropertyValue('--particle-color-value').trim();
}

function animateParticleColorTo(targetCssColor, durationMs = 300) {
    if (!particlesMaterial || !window.THREE || !targetCssColor) return;

    const targetColor = new THREE.Color(targetCssColor);
    const startColor = particlesMaterial.color.clone();
    const startTime = performance.now();
    const thisAnimationId = ++particleColorAnimationCounter;
    const tempColor = new THREE.Color();

    function step(now) {
        if (thisAnimationId !== particleColorAnimationCounter) return;
        const t = Math.min(1, (now - startTime) / durationMs);
        tempColor.copy(startColor).lerp(targetColor, t);
        particlesMaterial.color.copy(tempColor);
        if (t < 1) {
            requestAnimationFrame(step);
        }
    }

    requestAnimationFrame(step);
}

function applyTheme(theme) {
    document.body.classList.toggle('dark', theme === 'dark');
    if (particlesMaterial) {
        animateParticleColorTo(getParticleCssColor(), 350);
    }
}

function toggleTheme() {
    const currentTheme = localStorage.getItem('theme') || 'light';
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    localStorage.setItem('theme', newTheme);
    applyTheme(newTheme);
}

function showLoaderIfPresent() {
    const loaderText = document.getElementById('loader-text');
    const loaderBar = document.getElementById('loader-bar');
    const loaderContainer = document.getElementById('loader');
    if (!loaderContainer) return;

    let progress = 0;
    const interval = setInterval(() => {
        progress += 2;
        if (loaderText) loaderText.textContent = `${Math.min(progress, 100)}%`;
        if (loaderBar) loaderBar.style.width = `${Math.min(progress, 100)}%`;

        if (progress >= 100) {
            clearInterval(interval);
            setTimeout(() => {
                loaderContainer.style.display = 'none';
            }, 250);
        }
    }, 8);
}

async function loadPublicProjects() {
    if (!supabaseClient) {
        displayProjects(sampleProjects);
        return;
    }

    try {
        const { data: projects, error } = await supabaseClient
            .from('projects')
            .select('*')
            .order('id', { ascending: false });

        if (error || !projects || projects.length === 0) {
            displayProjects(sampleProjects);
            return;
        }

        displayProjects(projects);
    } catch (error) {
        console.error('Error loading projects:', error);
        displayProjects(sampleProjects);
    }
}

function createProjectCard(project) {
    const projectDiv = document.createElement('article');
    projectDiv.className = 'brutalist-hover border-2 border-black p-6 bg-white/80 backdrop-blur-sm cursor-pointer';

    const title = document.createElement('h3');
    title.className = 'font-black text-2xl md:text-3xl';
    title.textContent = project.title || 'Untitled project';

    const subtitle = document.createElement('p');
    subtitle.className = 'mt-1 text-base';
    subtitle.textContent = project.subtitle || '';

    projectDiv.append(title, subtitle);
    projectDiv.addEventListener('click', () => {
        openModal(
            project.title || 'Untitled project',
            project.description || 'No description available.',
            project.imageUrl || '',
            project.liveUrl || '#'
        );
    });

    return projectDiv;
}

function displayProjects(projects) {
    const projectsContainer = document.querySelector('#projects .grid');
    if (!projectsContainer) return;

    projectsContainer.innerHTML = '';
    projects.forEach((project) => {
        projectsContainer.appendChild(createProjectCard(project));
    });
}

const modal = document.getElementById('project-modal');
const modalTitle = document.getElementById('modal-title');
const modalDescription = document.getElementById('modal-description');
const modalImage = document.getElementById('modal-image');
const modalLink = document.getElementById('modal-link');

function openModal(title, description, imageUrl, projectUrl) {
    if (!modal || !modalTitle || !modalDescription || !modalImage || !modalLink) return;

    modalTitle.textContent = title;
    modalDescription.textContent = description;
    modalImage.src = imageUrl || '';
    modalImage.alt = title ? `${title} preview` : 'Project preview';
    modalLink.href = projectUrl || '#';
    modal.style.display = 'block';
}

function closeModal() {
    if (modal) {
        modal.style.display = 'none';
    }
}

window.closeModal = closeModal;

window.addEventListener('click', (event) => {
    if (event.target === modal) {
        closeModal();
    }
});

function initializeThreeJS() {
    const canvas = document.getElementById('bg-canvas');
    if (!canvas || !window.THREE) return;

    const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    const particleCount = prefersReducedMotion ? 900 : 1800;

    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
    camera.position.z = 10;

    const renderer = new THREE.WebGLRenderer({ canvas, alpha: true, antialias: true });
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

    const positions = new Float32Array(particleCount * 3);
    for (let i = 0; i < particleCount * 3; i += 1) {
        positions[i] = (Math.random() - 0.5) * 20;
    }

    const particlesGeometry = new THREE.BufferGeometry();
    particlesGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));

    particlesMaterial = new THREE.PointsMaterial({ size: 0.02, sizeAttenuation: true });
    const initialColor = getParticleCssColor();
    if (initialColor) {
        particlesMaterial.color.set(initialColor);
    }

    const particles = new THREE.Points(particlesGeometry, particlesMaterial);
    scene.add(particles);

    const mouse = new THREE.Vector2();
    window.addEventListener('mousemove', (event) => {
        mouse.x = (event.clientX / window.innerWidth) * 2 - 1;
        mouse.y = -(event.clientY / window.innerHeight) * 2 + 1;
    }, { passive: true });

    const clock = new THREE.Clock();

    const animate = () => {
        const elapsedTime = clock.getElapsedTime();
        particles.rotation.y = -0.04 * elapsedTime;
        particles.rotation.x = -0.04 * elapsedTime;

        if (!prefersReducedMotion && (mouse.x !== 0 || mouse.y !== 0)) {
            particles.rotation.y += ((mouse.x * 0.2) - particles.rotation.y) * 0.01;
            particles.rotation.x += ((mouse.y * 0.2) - particles.rotation.x) * 0.01;
        }

        renderer.render(scene, camera);
        requestAnimationFrame(animate);
    };

    window.addEventListener('resize', () => {
        camera.aspect = window.innerWidth / window.innerHeight;
        camera.updateProjectionMatrix();
        renderer.setSize(window.innerWidth, window.innerHeight);
        renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    }, { passive: true });

    animate();
}

document.addEventListener('DOMContentLoaded', () => {
    const themeToggleButton = document.getElementById('theme-toggle');
    if (themeToggleButton) {
        themeToggleButton.addEventListener('click', toggleTheme);
    }

    const projectGrid = document.querySelector('#projects .grid');
    if (projectGrid) {
        if (!window.env || !window.env.SUPABASE_URL || !window.env.SUPABASE_ANON_KEY || !window.supabase) {
            displayProjects(sampleProjects);
        } else {
            const { createClient } = window.supabase;
            supabaseClient = createClient(window.env.SUPABASE_URL, window.env.SUPABASE_ANON_KEY);
            loadPublicProjects();
        }
    }

    initializeThreeJS();
    applyTheme(localStorage.getItem('theme') || 'light');
    showLoaderIfPresent();
});
