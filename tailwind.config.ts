import type { Config } from "tailwindcss";

export default {
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['var(--font-inter)', 'sans-serif'],
        pixel: ['var(--font-vt323)', 'monospace'],
      },
      colors: {
        bg: 'var(--bg-color)',
        text: 'var(--text-color)',
        card: 'var(--card-bg)',
        lime: '#CCFF00',
        electric: '#0000FF',
      },
      boxShadow: {
        'neo': '4px 4px 0px 0px var(--text-color)',
        'neo-hover': '2px 2px 0px 0px var(--text-color)',
      }
    },
  },
  plugins: [],
} satisfies Config;
