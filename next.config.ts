import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  eslint: {
    // This bypasses the circular JSON bug in Next 15 during Vercel builds
    ignoreDuringBuilds: true,
  },
};

export default nextConfig;
