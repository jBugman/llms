import { defineConfig, type Plugin } from 'vite'
import deno from '@deno/vite-plugin'
import tailwindcss from '@tailwindcss/vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    deno(),
    tailwindcss() as Plugin[],
  ],
  server: {
    port: 3000,
  }
})
