// js/main.js

// --- GLOBAL VARIABLES ---
let supabaseClient;
let particlesMaterial; // Make particlesMaterial globally accessible
let particleColorAnimationCounter = 0; // Used to cancel in-flight color animations

function normalizeUrl(url) {
    if (!url || typeof url !== 'string') return '';
    const trimmed = url.trim();
    if (!trimmed) return '';
    return /^https?:\/\//i.test(trimmed) ? trimmed : `https://${trimmed}`;
}

// Sample projects for when Supabase is not configured
const sampleProjects = [
    {
        title: "Portfolio Website",
        subtitle: "2025 - Personal Website",
        description: "A modern, responsive portfolio website built with HTML, CSS, and JavaScript. Features include dark/light theme toggle, Three.js particle background, and dynamic content loading.",
        imageUrl: "https://via.placeholder.com/600x400/000000/FFFFFF?text=Portfolio+Website",
        liveUrl: "#"
    },
    {
        title: "Sample Project",
        subtitle: "2025 - Web Application",
        description: "This is a sample project to demonstrate the website functionality. Replace with your actual projects by configuring Supabase or updating the sample data.",
        imageUrl: "https://via.placeholder.com/600x400/333333/FFFFFF?text=Sample+Project",
        liveUrl: "#"
    }
];

function getParticleCssColor() {
    // Read from body so body.dark overrides take effect
    return getComputedStyle(document.body).getPropertyValue('--particle-color-value').trim();
}

function animateParticleColorTo(targetCssColor, durationMs = 300) {
    if (!particlesMaterial || !targetCssColor) return;
    const targetColor = new THREE.Color(targetCssColor);
    const startColor = particlesMaterial.color.clone();
    const startTime = performance.now();
    const thisAnimationId = ++particleColorAnimationCounter;
    const tempColor = new THREE.Color();
    function step(now) {
        if (thisAnimationId !== particleColorAnimationCounter) return; // superseded
        const t = Math.min(1, (now - startTime) / durationMs);
        tempColor.copy(startColor).lerp(targetColor, t);
        particlesMaterial.color.set(tempColor);
        if (t < 1) {
            requestAnimationFrame(step);
        }
    }
    requestAnimationFrame(step);
}

// --- THEME TOGGLE FUNCTIONS ---
function applyTheme(theme) {
    document.body.classList.toggle('dark', theme === 'dark');
    // Update icon: show sun when dark (click to go light), moon when light (click to go dark)
    const icon = document.getElementById('theme-icon');
    if (icon) icon.textContent = theme === 'dark' ? '☀️' : '🌙';
    if (particlesMaterial) {
        const particleColor = getParticleCssColor();
        animateParticleColorTo(particleColor, 350);
    }
}

function toggleTheme() {
    const currentTheme = localStorage.getItem('theme') || 'light';
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    localStorage.setItem('theme', newTheme);
    applyTheme(newTheme);
}

// --- EVENT LISTENERS ---
document.addEventListener('DOMContentLoaded', () => {
    // 1. SETUP THEME TOGGLE BUTTON
    const themeToggleButton = document.getElementById('theme-toggle');
    if (themeToggleButton) {
        themeToggleButton.addEventListener('click', toggleTheme);
    }


    // 2. CHECK CONFIG AND INITIALIZE SUPABASE CLIENT
    if (!window.env || !window.env.SUPABASE_URL || !window.env.SUPABASE_ANON_KEY) {
        console.warn('Supabase credentials not found. Using sample data.');
        loadSampleProjects();
    } else {
        try {
            const { createClient } = window.supabase;
            supabaseClient = createClient(window.env.SUPABASE_URL, window.env.SUPABASE_ANON_KEY);
            loadPublicProjects();
        } catch (error) {
            console.error('Error initializing Supabase client:', error);
            loadSampleProjects();
        }
    }

    // 3. INITIALIZE THREE.JS AND APPLY THEME
    initializeThreeJS();
    const savedTheme = localStorage.getItem('theme') || 'dark';
    applyTheme(savedTheme);
});

// --- DYNAMIC PROJECT LOADING ---
async function loadPublicProjects() {
    if (!supabaseClient) {
        loadSampleProjects();
        return;
    }

    try {
        const { data: projects, error } = await supabaseClient.from('projects').select('*').order('id', { ascending: false });
        if (error) {
            console.error('Error fetching projects:', error);
            loadSampleProjects();
            return;
        }

        if (!projects || projects.length === 0) {
            console.log('No projects found in database, loading sample data');
            loadSampleProjects();
            return;
        }

        displayProjects(projects);
    } catch (error) {
        console.error('Error in loadPublicProjects:', error);
        loadSampleProjects();
    }
}

function loadSampleProjects() {
    console.log('Loading sample projects');
    displayProjects(sampleProjects);
}

function displayProjects(projects) {
    const projectsContainer = document.querySelector('#projects .grid');
    if (!projectsContainer) return;
    
    projectsContainer.innerHTML = ''; // Clear existing content

    projects.forEach(project => {
        const projectDiv = document.createElement('div');
        projectDiv.className = 'brutalist-hover border-2 border-black p-6 bg-white/80 backdrop-blur-sm cursor-pointer';
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

// copyEmailToClipboard is in utils.js

// --- THREE.JS BACKGROUND SCRIPT ---
function initializeThreeJS() {
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
        
        // Use the global particlesMaterial variable
        particlesMaterial = new THREE.PointsMaterial({ size: 0.02, sizeAttenuation: true });
        const initialColor = getParticleCssColor();
        if (initialColor) {
            particlesMaterial.color.set(initialColor);
        }
        
        const particles = new THREE.Points(particlesGeometry, particlesMaterial);
        scene.add(particles);
        // Target rotation driven by mouse or gyro
        const target = { x: 0, y: 0 };
        let gyroActive = false;

        // --- DESKTOP: mouse moves particles ---
        window.addEventListener('mousemove', (event) => {
            if (gyroActive) return; // gyro takes priority on mobile
            target.x = ((event.clientY / window.innerHeight) - 0.5) * 1.2;
            target.y = ((event.clientX / window.innerWidth) - 0.5) * 1.2;
        }, { passive: true });

        // --- MOBILE GYROSCOPE ---
        function enableGyro() {
            gyroActive = true;
            let baseAlpha = null; // calibrate on first reading

            window.addEventListener('deviceorientation', (event) => {
                // beta  = front-back tilt (-180 to 180), controls X rotation
                // gamma = left-right tilt (-90 to 90),  controls Y rotation
                const beta  = event.beta  !== null ? event.beta  : 0;
                const gamma = event.gamma !== null ? event.gamma : 0;

                // Normalise: phone held upright (beta~90) = neutral
                target.x = THREE.MathUtils.clamp((beta - 90) / 60, -1, 1) * 1.5;
                target.y = THREE.MathUtils.clamp(gamma / 45, -1, 1) * 1.5;
            }, { passive: true });
        }

        const isMobile = /Mobi|Android|iPhone|iPad/i.test(navigator.userAgent);
        const isIOS    = /iPhone|iPad/i.test(navigator.userAgent);

        if (isMobile) {
            if (isIOS && typeof DeviceOrientationEvent !== 'undefined'
                      && typeof DeviceOrientationEvent.requestPermission === 'function') {
                // Show a clean one-time button — auto-removed after tap
                const gyroBtn = document.createElement('button');
                gyroBtn.id = 'gyro-permission-btn';
                gyroBtn.textContent = '🔄 Enable Motion';
                gyroBtn.style.cssText = [
                    'position:fixed', 'bottom:24px', 'left:50%',
                    'transform:translateX(-50%)', 'z-index:999',
                    'padding:12px 24px', 'font-family:Inter,sans-serif',
                    'font-weight:900', 'font-size:0.85rem', 'letter-spacing:0.06em',
                    'border:2px solid #000', 'background:#fff', 'color:#000',
                    'cursor:pointer', 'box-shadow:3px 3px 0 #000'
                ].join(';');
                document.body.appendChild(gyroBtn);

                gyroBtn.addEventListener('click', () => {
                    DeviceOrientationEvent.requestPermission()
                        .then(state => { if (state === 'granted') enableGyro(); })
                        .catch(() => {});
                    gyroBtn.style.opacity = '0';
                    gyroBtn.style.transition = 'opacity 0.3s';
                    setTimeout(() => gyroBtn.remove(), 350);
                });
            } else {
                // Android — fires without permission
                enableGyro();
            }
        }

        const clock = new THREE.Clock();
        const animate = () => {
            clock.getDelta(); // keep clock ticking but don't use elapsed for rotation
            // Smooth lerp towards target — feels like the scene is floating
            particles.rotation.x += (target.x - particles.rotation.x) * 0.05;
            particles.rotation.y += (target.y - particles.rotation.y) * 0.05;
            renderer.render(scene, camera);
            window.requestAnimationFrame(animate);
        };
        window.addEventListener('resize', () => {
            camera.aspect = window.innerWidth / window.innerHeight;
            camera.updateProjectionMatrix();
            renderer.setSize(window.innerWidth, window.innerHeight);
            renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
        }, { passive: true });
        animate();
    }
}

// --- CURRENTLY WORKING ON SLIDER ---
const sampleWorkingOn = [
    {
        title: "TheCommonCo",
        tag: "Streetwear / Merch",
        description: "Scaling bulk corporate merch orders. Working on overseas pricing models and influencer outreach campaigns.",
        status: "Active"
    },
    {
        title: "Sirenn",
        tag: "Luxury Streetwear",
        description: "Building the brand identity and early product line for a future luxury streetwear label.",
        status: "Building"
    },
    {
        title: "SurFlow Events",
        tag: "Event Management",
        description: "Connecting underrated artists with cafés, restaurants, and corporate venues for curated weekend experiences.",
        status: "Active"
    }
];

let cwoIndex = 0;

function initCWO(items) {
    const slider = document.getElementById('cwo-slider');
    const dotsContainer = document.getElementById('cwo-dots');
    if (!slider || !dotsContainer) return;

    slider.innerHTML = '';
    dotsContainer.innerHTML = '';

    items.forEach((item, i) => {
        const card = document.createElement('div');
        card.className = 'cwo-card';
        card.innerHTML = `
            <div class="cwo-card-tag">${item.tag || ''}</div>
            <h3 class="font-black text-2xl md:text-3xl mb-2">${item.title}</h3>
            <p class="cwo-card-desc">${item.description}</p>
            <span class="cwo-status">${item.status || 'In Progress'}</span>
        `;
        slider.appendChild(card);

        const dot = document.createElement('button');
        dot.className = 'cwo-dot' + (i === 0 ? ' cwo-dot-active' : '');
        dot.setAttribute('aria-label', `Go to card ${i + 1}`);
        dot.addEventListener('click', () => goToCWO(i));
        dotsContainer.appendChild(dot);
    });

    goToCWO(0);

    // Auto-advance every 4s
    setInterval(() => {
        cwoIndex = (cwoIndex + 1) % items.length;
        goToCWO(cwoIndex);
    }, 4000);

    // Touch swipe support
    let touchStartX = 0;
    slider.addEventListener('touchstart', e => { touchStartX = e.touches[0].clientX; }, { passive: true });
    slider.addEventListener('touchend', e => {
        const diff = touchStartX - e.changedTouches[0].clientX;
        if (Math.abs(diff) > 40) {
            cwoIndex = diff > 0
                ? Math.min(cwoIndex + 1, items.length - 1)
                : Math.max(cwoIndex - 1, 0);
            goToCWO(cwoIndex);
        }
    }, { passive: true });
}

function goToCWO(index) {
    cwoIndex = index;
    const slider = document.getElementById('cwo-slider');
    if (slider) slider.style.transform = `translateX(-${index * 100}%)`;
    document.querySelectorAll('.cwo-dot').forEach((dot, i) => {
        dot.classList.toggle('cwo-dot-active', i === index);
    });
}

document.addEventListener('DOMContentLoaded', () => {
    // Load CWO from Supabase if available, else use sample
    if (window.supabase && window.env && window.env.SUPABASE_URL) {
        try {
            const { createClient } = window.supabase;
            const client = createClient(window.env.SUPABASE_URL, window.env.SUPABASE_ANON_KEY);
            client.from('working_on').select('*').order('id', { ascending: false })
                .then(({ data, error }) => {
                    if (error || !data || data.length === 0) {
                        initCWO(sampleWorkingOn);
                    } else {
                        initCWO(data);
                    }
                });
        } catch(e) {
            initCWO(sampleWorkingOn);
        }
    } else {
        initCWO(sampleWorkingOn);
    }
});
