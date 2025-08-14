// --- LOADING SCREEN SCRIPT ---
const loaderText = document.getElementById('loader-text');
const loaderBar = document.getElementById('loader-bar');
const loaderContainer = document.getElementById('loader');
let progress = 0;
const interval = setInterval(() => {
    progress += 1;
    loaderText.textContent = `${progress}%`;
    loaderBar.style.width = `${progress}%`;
    if (progress >= 100) {
        clearInterval(interval);
        setTimeout(() => {
            loaderContainer.style.display = 'none';
        }, 500);
    }
}, 10);

// --- PROJECT MODAL SCRIPT ---
const modal = document.getElementById('project-modal');
const modalTitle = document.getElementById('modal-title');
const modalDescription = document.getElementById('modal-description');
const modalImage = document.getElementById('modal-image');
const modalLink = document.getElementById('modal-link');

function openModal(title, description, imageUrl, projectUrl) {
    modalTitle.textContent = title;
    modalDescription.textContent = description;
    modalImage.src = imageUrl;
    modalLink.href = projectUrl;
    modal.style.display = 'block';
}

function closeModal() {
    modal.style.display = 'none';
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
    textArea.style.position = 'fixed'; // Prevent scrolling to bottom
    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();
    try {
        document.execCommand('copy');
        const toast = document.getElementById('copy-toast');
        toast.textContent = `${email} copied to clipboard`;
        toast.classList.add('show');
        setTimeout(() => { toast.classList.remove('show'); }, 800);
    } catch (err) {
        console.error('Fallback: Oops, unable to copy', err);
    }
    document.body.removeChild(textArea);
}

// --- THREE.JS BACKGROUND SCRIPT ---
const scene = new THREE.Scene();
const canvas = document.getElementById('bg-canvas');
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
