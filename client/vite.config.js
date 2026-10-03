import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  preview: {
    allowedHosts: [
      'app-fullstack-frontend-2026.azurewebsites.net'
    ]
  }
})