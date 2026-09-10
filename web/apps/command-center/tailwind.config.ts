import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        luster: {
          bg: '#0b0f17',
          panel: '#101622',
          surface: '#151d2e',
          header: '#18283f',
          border: '#1e293b',
          borderLight: '#2a3b53',
          accent: '#86cfff',
          accentHover: '#9ee2ff',
          accentMuted: 'rgba(134, 207, 255, 0.15)',
          text: '#f8fafc',
          textMuted: '#94a3b8',
          textDark: '#64748b',
          success: '#10b981',
          warning: '#f59e0b',
          danger: '#ef4444',
        },
      },
      fontFamily: {
        sans: ['Inter', '-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'sans-serif'],
        mono: ['JetBrains Mono', 'Fira Code', 'Consolas', 'monospace'],
      },
    },
  },
  plugins: [],
};

export default config;
