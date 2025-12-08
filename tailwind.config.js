// tailwind.config.js
module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  safelist: [
    'gap-8', 'max-w-4xl', 'md:flex-row', 'w-full', 'max-w-xl'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Rajdhani', 'sans-serif'],
        mono: ['"Fira Code"', 'monospace'],
      },
      colors: {
        metal: { light: '#1a1a1a', DEFAULT: '#0a0a0a', dark: '#050505' },
        cyan: { 50: '#ecfeff', 100: '#cffafe', 200: '#a5f3fc', 300: '#67e8f9', 400: '#22d3ee', 500: '#06b6d4', 600: '#0891b2', 700: '#0e7490', 800: '#155e75', 900: '#164e63' },
        magenta: {
          50: '#fdf4ff',
          100: '#fae8ff',
          200: '#f5d0fe',
          300: '#f0abfc',
          400: '#e879f9',
          500: '#d946ef',
          600: '#c026d3',
          700: '#a21caf',
          800: '#86198f',
          900: '#701a75',
        },
        green: {
          50: '#f0fdf4',
          100: '#dcfce7',
          200: '#bbf7d0',
          300: '#86efac',
          400: '#4ade80',
          500: '#22c55e',
          600: '#16a34a',
          700: '#15803d',
          800: '#166534',
          900: '#14532d',
        },
        'theme-homeland': { DEFAULT: '#ff4500', glow: 'rgba(255, 69, 0, 0.6)' },
        'theme-forward': { DEFAULT: '#00f7ff', glow: 'rgba(0, 247, 255, 0.6)' },
        'theme-labor': { DEFAULT: '#d2691e', glow: 'rgba(210, 105, 30, 0.6)' },
        'theme-preservation': { DEFAULT: '#8b8b83', glow: 'rgba(139, 139, 131, 0.6)' },
        'theme-renewal': { DEFAULT: '#32cd32', glow: 'rgba(50, 205, 50, 0.6)' },
      },
      backgroundImage: {
        'scanlines': 'repeating-linear-gradient(0deg, rgba(0,0,0,0.15) 0px, rgba(0,0,0,0.15) 1px, transparent 1px, transparent 2px)',
        'brushed-metal': 'repeating-linear-gradient(45deg, rgba(255,255,255,0.02) 0px, rgba(255,255,255,0.02) 1px, transparent 1px, transparent 5px), linear-gradient(to bottom, #1a1a1a, #050505)',
      },
      animation: {
        'screen-flicker': 'flicker 0.1s infinite alternate',
        // Animations for the three layers
        'neon-halo': 'neon-halo 3s ease-in-out infinite',
        'neon-glow': 'neon-glow 3s ease-in-out infinite',
        'neon-core': 'neon-core 3s ease-in-out infinite',
      },
      keyframes: {
        flicker: { '0%': { opacity: 1 }, '100%': { opacity: 0.97 } },
        
        // Animates the wide halo's blur and opacity
        'neon-halo': {
          '0%, 100%': { opacity: '0.6', filter: 'blur(10px)' },
          '50%': { opacity: '1', filter: 'blur(15px)' },
        },
        
        // Animates the tight glow's blur and opacity
        'neon-glow': {
          '0%, 100%': { opacity: '0.7', filter: 'blur(3px)' },
          '50%': { opacity: '1', filter: 'blur(5px)' },
        },
        
        // Animates the sharp core's opacity
        'neon-core': {
          '0%, 100%': { opacity: '0.9' },
          '50%': { opacity: '1' },
        },
      },
      boxShadow: {
        'glow-cyan-sm': '0 0 5px rgba(34, 211, 238, 0.5)',
        'glow-cyan-md': '0 0 15px rgba(34, 211, 238, 0.5)',
        'glow-cyan-offset-sm': '-3px 0 5px rgba(0, 255, 255, 0.7)',
        'glow-magenta-sm': '3px 0 5px rgba(255, 0, 255, 0.7)',
        'glow-green-sm': '0 3px 5px rgba(0, 255, 0, 0.7)',
      },
      dropShadow: {
        'glow-cyan-sm': '0 0 5px rgba(34, 211, 238, 0.5)',
        'glow-cyan-md': '0 0 15px rgba(34, 211, 238, 0.5)',
        'glow-cyan-offset-sm': '-3px 0 5px rgba(0, 255, 255, 0.7)',
        'glow-magenta-sm': '3px 0 5px rgba(255, 0, 255, 0.7)',
        'glow-green-sm': '0 3px 5px rgba(0, 255, 0, 0.7)',
      }
    },
  },
  plugins: [],
}