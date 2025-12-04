// tailwind.config.js

module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      fontFamily: {
        // Ensure you import this font in your application layout head
        sans: ['Rajdhani', 'sans-serif'],
      },
      colors: {
        // The specific neon red used for the Homeland Assembly
        neonRed: {
          DEFAULT: '#ff0000',
          dim: '#7f0000', // For inactive elements
          glow: 'rgba(255, 0, 0, 0.6)', // For box shadows
        },
        // The dark metal chassis color
        metal: {
          dark: '#0a0a0a',
          darker: '#050505',
        }
      },
      backgroundImage: {
        // The subtle horizontal scanline texture for the digital screen
        'scanlines': 'repeating-linear-gradient(0deg, rgba(0,0,0,0.2) 0px, rgba(0,0,0,0.2) 1px, transparent 1px, transparent 3px)',
        // A placeholder for the brushed metal texture. In a real app, use a subtle repeating image pattern.
        'brushed-metal': 'linear-gradient(rgba(0,0,0,0.8), rgba(0,0,0,0.8)), url("/assets/metal-texture.png")',
      },
      boxShadow: {
        // Custom neon glows
        'neon-red-sm': '0 0 5px theme("colors.neonRed.DEFAULT"), 0 0 10px theme("colors.neonRed.glow")',
        'neon-red-md': '0 0 8px theme("colors.neonRed.DEFAULT"), 0 0 15px theme("colors.neonRed.glow")',
        'neon-red-lg': '0 0 15px theme("colors.neonRed.DEFAULT"), 0 0 30px theme("colors.neonRed.glow"), inset 0 0 10px theme("colors.neonRed.glow")',
        'inset-red': 'inset 0 0 15px theme("colors.neonRed.glow")',
      },
      dropShadow: {
        // For glowing text and icons specifically
        'neon-red': '0 0 8px theme("colors.neonRed.DEFAULT")',
      },
      animation: {
        // A very subtle flicker for the digital screen
        'screen-flicker': 'flicker 0.15s infinite',
      },
      keyframes: {
        flicker: {
          '0%, 100%': { opacity: 1 },
          '50%': { opacity: 0.98 },
        }
      }
    },
  },
  plugins: [],
}