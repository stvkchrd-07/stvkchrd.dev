// js/post.js

// --- EVENT LISTENERS ---
document.addEventListener('DOMContentLoaded', () => {
    // --- Supabase and Post Loading Logic ---

    // Check for config
    if (!window.env || !window.env.SUPABASE_URL || !window.env.SUPABASE_ANON_KEY) {
        console.error('Error: Supabase environment variables are not set.');
        const loadingDiv = document.getElementById('post-loading');
        loadingDiv.innerHTML = '<p class="text-lg text-red-600">Configuration error. Cannot connect to the database.</p>';
        return;
    }

    const { createClient } = window.supabase;
    const supabaseClient = createClient(window.env.SUPABASE_URL, window.env.SUPABASE_ANON_KEY);

    const getPostIdFromUrl = () => {
        const params = new URLSearchParams(window.location.search);
        return params.get('id');
    };

    const loadPost = async () => {
        const postId = getPostIdFromUrl();
        const loadingDiv = document.getElementById('post-loading');
        const contentArea = document.getElementById('post-content-area');
        const notFoundDiv = document.getElementById('post-not-found');

        if (!postId) {
            loadingDiv.classList.add('hidden');
            notFoundDiv.classList.remove('hidden');
            return;
        }

        try {
            // Fetch the specific post using its ID
            const { data: post, error } = await supabaseClient
                .from('posts')
                .select('title, content, date') // Using 'date' for consistency with other files
                .eq('id', postId)
                .single(); // .single() is crucial to get one object, not an array

            if (error || !post) {
                throw new Error('Post not found or database error.');
            }

            // Populate the page with the fetched data
            document.title = `${post.title} | Satvik Chaturvedi`;
            document.getElementById('post-date').textContent = new Date(post.date).toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'long',
                day: 'numeric',
            });
            document.getElementById('post-title').textContent = post.title;
            
            // Use the 'marked' library to parse markdown content into HTML
            if (window.marked) {
                document.getElementById('post-body').innerHTML = marked.parse(post.content);
            } else {
                console.error('Marked.js library not found.');
                document.getElementById('post-body').textContent = 'Error: Markdown parser not loaded.';
            }

            // Show the content and hide the loading message
            loadingDiv.classList.add('hidden');
            contentArea.classList.remove('hidden');

        } catch (error) {
            console.error('Error loading post:', error.message);
            loadingDiv.classList.add('hidden');
            notFoundDiv.classList.remove('hidden');
        }
    };

    // --- Three.js Background (Particle System for consistency) ---
    const initThreeJSBackground = () => {
        const canvas = document.getElementById('bg-canvas');
        if (!canvas) return;
        
        try {
            const scene = new THREE.Scene();
            const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
            camera.position.z = 10;
            const renderer = new THREE.WebGLRenderer({ canvas: canvas, alpha: true, antialias: true });
            renderer.setSize(window.innerWidth, window.innerHeight);
            renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
            
            const particleCount = 2000;
            const positions = new Float32Array(particleCount * 3);
            for (let i = 0; i < particleCount * 3; i++) {
                positions[i] = (Math.random() - 0.5) * 20;
            }
            
            const particlesGeometry = new THREE.BufferGeometry();
            particlesGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
            const particlesMaterial = new THREE.PointsMaterial({ color: 0x000000, size: 0.02, sizeAttenuation: true });
            const particles = new THREE.Points(particlesGeometry, particlesMaterial);
            scene.add(particles);
            
            const mouse = new THREE.Vector2();
            window.addEventListener('mousemove', (event) => {
                mouse.x = (event.clientX / window.innerWidth) * 2 - 1;
                mouse.y = -(event.clientY / window.innerHeight) * 2 + 1;
            });
            
            const clock = new THREE.Clock();
            const animate = () => {
                const elapsedTime = clock.getElapsedTime();
                particles.rotation.y = -0.04 * elapsedTime;
                particles.rotation.x = -0.04 * elapsedTime;
                
                if (mouse.x !== 0 && mouse.y !== 0) {
                    const targetX = mouse.x * 0.2;
                    const targetY = mouse.y * 0.2;
                    particles.rotation.y += (targetX - particles.rotation.y) * 0.01;
                    particles.rotation.x += (targetY - particles.rotation.x) * 0.01;
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
        } catch (e) {
            console.error("Failed to initialize Three.js background", e);
        }
    };

    // --- Load the post and initialize Three.js background ---
    loadPost();
    initThreeJSBackground();
});

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