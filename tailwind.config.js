/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./app/**/*.{js,jsx,ts,tsx}', './src/**/*.{js,jsx,ts,tsx}'],
  presets: [require('nativewind/preset')],
  theme: {
    extend: {
      colors: {
        primary: '#6A0DAD',
        'primary-light': '#8B3DCC',
        'primary-dark': '#4A0878',
        'primary-surface': '#F3E8FF',
        background: '#FFFFFF',
        surface: '#FFFFFF',
        'surface-variant': '#F8F9FA',
        'text-primary': '#1A1A2E',
        'text-secondary': '#6B7280',
        'text-tertiary': '#9CA3AF',
        border: '#E5E7EB',
        success: '#10B981',
        error: '#EF4444',
        'weight-indifferent': '#9CA3AF',
        'weight-wished': '#6A0DAD',
        'weight-redhibitory': '#EF4444',
      },
      borderRadius: {
        card: '24px',
        input: '16px',
        button: '16px',
      },
    },
  },
  plugins: [],
};
