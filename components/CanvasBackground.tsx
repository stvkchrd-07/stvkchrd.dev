'use client';

import { useEffect, useRef } from 'react';
import * as THREE from 'three';

export default function CanvasBackground() {
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const rafRef = useRef<number | null>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
    camera.position.z = 10;

    const renderer = new THREE.WebGLRenderer({ canvas, alpha: true, antialias: true });
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

    const particleCount = 2000;
    const positions = new Float32Array(particleCount * 3);
    for (let i = 0; i < particleCount * 3; i++) {
      positions[i] = (Math.random() - 0.5) * 20;
    }
    const geometry = new THREE.BufferGeometry();
    geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));

    const getColor = () =>
      getComputedStyle(document.body).getPropertyValue('--particle-color-value').trim() || '#ffffff';

    const material = new THREE.PointsMaterial({
      size: 0.02,
      sizeAttenuation: true,
      color: new THREE.Color(getColor())
    });

    const particles = new THREE.Points(geometry, material);
    scene.add(particles);

    // Target rotation driven by mouse or gyro
    const target = { x: 0, y: 0 };
    let gyroActive = false;

    const onMouseMove = (e: MouseEvent) => {
      if (gyroActive) return;
      target.x = (e.clientY / window.innerHeight - 0.5) * 1.2;
      target.y = (e.clientX / window.innerWidth - 0.5) * 1.2;
    };

    const enableGyro = () => {
      gyroActive = true;
      window.addEventListener('deviceorientation', (e: DeviceOrientationEvent) => {
        const beta = e.beta ?? 0;
        const gamma = e.gamma ?? 0;
        target.x = THREE.MathUtils.clamp((beta - 90) / 60, -1, 1) * 1.5;
        target.y = THREE.MathUtils.clamp(gamma / 45, -1, 1) * 1.5;
      }, { passive: true });
    };

    const isMobile = /Mobi|Android|iPhone|iPad/i.test(navigator.userAgent);
    const isIOS = /iPhone|iPad/i.test(navigator.userAgent);

    if (isMobile) {
      if (isIOS && typeof (DeviceOrientationEvent as any).requestPermission === 'function') {
        const btn = document.createElement('button');
        btn.id = 'gyro-permission-btn';
        btn.textContent = '🔄 Enable Motion';
        btn.style.cssText = [
          'position:fixed', 'bottom:24px', 'left:50%', 'transform:translateX(-50%)',
          'z-index:999', 'padding:12px 24px', 'font-family:Inter,sans-serif',
          'font-weight:900', 'font-size:0.85rem', 'letter-spacing:0.06em',
          'border:2px solid #000', 'background:#fff', 'color:#000',
          'cursor:pointer', 'box-shadow:3px 3px 0 #000'
        ].join(';');
        document.body.appendChild(btn);
        btn.addEventListener('click', () => {
          (DeviceOrientationEvent as any).requestPermission()
            .then((state: string) => { if (state === 'granted') enableGyro(); })
            .catch(() => {});
          btn.style.opacity = '0';
          btn.style.transition = 'opacity 0.3s';
          setTimeout(() => btn.remove(), 350);
        });
      } else {
        enableGyro();
      }
    }

    const onResize = () => {
      camera.aspect = window.innerWidth / window.innerHeight;
      camera.updateProjectionMatrix();
      renderer.setSize(window.innerWidth, window.innerHeight);
      renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    };

    // Watch for theme class changes to update particle color
    const observer = new MutationObserver(() => {
      material.color.set(new THREE.Color(getColor()));
    });
    observer.observe(document.body, { attributes: true, attributeFilter: ['class'] });

    window.addEventListener('mousemove', onMouseMove, { passive: true });
    window.addEventListener('resize', onResize, { passive: true });

    const animate = () => {
      particles.rotation.x += (target.x - particles.rotation.x) * 0.05;
      particles.rotation.y += (target.y - particles.rotation.y) * 0.05;
      renderer.render(scene, camera);
      rafRef.current = window.requestAnimationFrame(animate);
    };
    animate();

    return () => {
      if (rafRef.current) cancelAnimationFrame(rafRef.current);
      observer.disconnect();
      window.removeEventListener('mousemove', onMouseMove);
      window.removeEventListener('resize', onResize);
      geometry.dispose();
      material.dispose();
      renderer.dispose();
    };
  }, []);

  return <canvas id="bg-canvas" ref={canvasRef} />;
}
