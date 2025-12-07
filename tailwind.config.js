// tailwind.config.js
const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        // Ensures our tech font is used.
        // Make sure you import a font like Rajdhani in your application.html.erb head!
        sans: ['Rajdhani', 'sans-serif', ...defaultTheme.fontFamily.sans],
        mono: ['"Fira Code"', 'monospace', ...defaultTheme.fontFamily.mono],
      },
      colors: {
        // The Neutral Dark Metal Palette
        metal: {
          light: '#1a1a1a',
          DEFAULT: '#0a0a0a',
          dark: '#050505',
        },
        // The Neutral Cyan Interface Glow
        cyan: {
          50: '#ecfeff',
          100: '#cffafe',
          200: '#a5f3fc',
          300: '#67e8f9',
          400: '#22d3ee',
          500: '#06b6d4',
          600: '#0891b2',
          700: '#0e7490',
          800: '#155e75',
          900: '#164e63',
        },
        // Faction Theme Color Stubs (for later use)
        'theme-homeland': { DEFAULT: '#ff4500', glow: 'rgba(255, 69, 0, 0.6)' },
        'theme-forward': { DEFAULT: '#00f7ff', glow: 'rgba(0, 247, 255, 0.6)' },
        'theme-labor': { DEFAULT: '#d2691e', glow: 'rgba(210, 105, 30, 0.6)' },
        'theme-preservation': { DEFAULT: '#8b8b83', glow: 'rgba(139, 139, 131, 0.6)' },
        'theme-renewal': { DEFAULT: '#32cd32', glow: 'rgba(50, 205, 50, 0.6)' },
      },
      backgroundImage: {
        // Simulated texture patterns using gradients
        'scanlines': 'repeating-linear-gradient(0deg, rgba(0,0,0,0.15) 0px, rgba(0,0,0,0.15) 1px, transparent 1px, transparent 2px)',
        'brushed-metal': 'repeating-linear-gradient(45deg, rgba(255,255,255,0.02) 0px, rgba(255,255,255,0.02) 1px, transparent 1px, transparent 5px), linear-gradient(to bottom, #1a1a1a, #050505)',
      },
      animation: {
        // The subtle screen flicker effect
        'screen-flicker': 'flicker 0.1s infinite alternate',
      },
      keyframes: {
        flicker: {
          '0%': { opacity: 1 },
          '100%': { opacity: 0.97 },
        }
      },
      boxShadow: {
        // Custom glows
        'glow-cyan-sm': '0 0 5px rgba(34, 211, 238, 0.5)',
        'glow-cyan-md': '0 0 15px rgba(34, 211, 238, 0.5)',
      },
      dropShadow: {
        'glow-cyan-sm': '0 0 5px rgba(34, 211, 238, 0.5)',
        'glow-cyan-md': '0 0 15px rgba(34, 211, 238, 0.5)',
      }
    },
  },
  plugins: [
    // require('@tailwindcss/forms'),
    // require('@tailwindcss/typography'),
    // require('@tailwindcss/container-queries'),
  ],
}