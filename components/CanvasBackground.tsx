'use client';

import { useRef, useEffect, useState, useMemo } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import * as THREE from 'three';

function ParticleField() {
  const pointsRef = useRef<THREE.Points>(null);
  const [mouse, setMouse] = useState({ x: 0, y: 0 });
  const [gyro, setGyro] = useState({ alpha: 0, beta: 0, gamma: 0 });

  // REDUCED PARTICLES: 2000 -> 400 for ultra-minimal look
  const [positions, phases] = useMemo(() => {
    const pos = new Float32Array(400 * 3);
    const ph = new Float32Array(400);
    for (let i = 0; i < 400; i++) {
      pos[i * 3] = (Math.random() - 0.5) * 15;
      pos[i * 3 + 1] = (Math.random() - 0.5) * 15;
      pos[i * 3 + 2] = (Math.random() - 0.5) * 15;
      ph[i] = Math.random() * Math.PI * 2;
    }
    return [pos, ph];
  }, []);

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      setMouse({ x: (e.clientX / window.innerWidth) * 2 - 1, y: -(e.clientY / window.innerHeight) * 2 + 1 });
    };
    const handleOrientation = (e: DeviceOrientationEvent) => {
      if (e.beta && e.gamma) setGyro({ alpha: e.alpha || 0, beta: e.beta, gamma: e.gamma });
    };

    const requestGyroPermission = () => {
      if (typeof (DeviceOrientationEvent as any).requestPermission === 'function') {
        (DeviceOrientationEvent as any).requestPermission().then((state: string) => {
            if (state === 'granted') window.addEventListener('deviceorientation', handleOrientation);
          }).catch(console.error);
      } else {
        window.addEventListener('deviceorientation', handleOrientation);
      }
    };

    window.addEventListener('mousemove', handleMouseMove);
    window.addEventListener('click', requestGyroPermission, { once: true });
    window.addEventListener('touchstart', requestGyroPermission, { once: true });

    return () => {
      window.removeEventListener('mousemove', handleMouseMove);
      window.removeEventListener('deviceorientation', handleOrientation);
    };
  }, []);

  useFrame((state) => {
    if (!pointsRef.current) return;
    const positionsAttr = pointsRef.current.geometry.attributes.position;
    for (let i = 0; i < 400; i++) {
      positionsAttr.getY(i); 
      const x = positionsAttr.getX(i);
      const z = positionsAttr.getZ(i);
      positionsAttr.setY(i, Math.sin(state.clock.elapsedTime * 0.3 + x + z) * 0.5 + (Math.sin(phases[i]) * 5));
    }
    positionsAttr.needsUpdate = true;
    const targetX = gyro.beta ? gyro.beta * 0.01 : mouse.y * 0.1;
    const targetY = gyro.gamma ? gyro.gamma * 0.01 : mouse.x * 0.1;
    pointsRef.current.rotation.x = THREE.MathUtils.lerp(pointsRef.current.rotation.x, targetX, 0.05);
    pointsRef.current.rotation.y = THREE.MathUtils.lerp(pointsRef.current.rotation.y, targetY + state.clock.elapsedTime * 0.02, 0.05);
  });

  return (
    <points ref={pointsRef}>
      <bufferGeometry>
        <bufferAttribute attach="attributes-position" args={[positions, 3]} />
      </bufferGeometry>
      {/* MINIMAL STYLE: Size 0.02, Opacity 0.3 */}
      <pointsMaterial size={0.02} color="#FFFFFF" transparent opacity={0.3} sizeAttenuation={true} />
    </points>
  );
}

export default function CanvasBackground() {
  return (
    <div className="fixed inset-0 z-0 bg-transparent pointer-events-none">
      <Canvas camera={{ position: [0, 0, 5], fov: 60 }} dpr={[1, 1.5]} performance={{ min: 0.5 }}>
        <ParticleField />
      </Canvas>
    </div>
  );
}
