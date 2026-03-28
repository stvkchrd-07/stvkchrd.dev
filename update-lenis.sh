#!/bin/bash

echo "🧹 Cleaning up deprecated packages..."

# 1. Uninstall the old packages
npm uninstall @studio-freight/react-lenis

# 2. Install the new, official package
echo "📦 Installing the updated 'lenis' package..."
npm install lenis

# 3. Update the SmoothScroll component to use the new import path
echo "🔄 Updating import paths..."
cat << 'EOF' > components/SmoothScroll.tsx
'use client';

// The new, official import path for React
import { ReactLenis } from 'lenis/react';

export default function SmoothScroll({ children }: { children: React.ReactNode }) {
  return (
    <ReactLenis root options={{ lerp: 0.1, duration: 1.2, smoothWheel: true }}>
      {children}
    </ReactLenis>
  );
}
EOF

echo "✅ Package updated successfully! You can now commit and push to Vercel."