/// <reference types="vitest" />
import { defineConfig } from "vite";
import { configDefaults } from "vitest/config";
import react from "@vitejs/plugin-react";
import svgr from 'vite-plugin-svgr';

// https:vitejs.dev/config/
export default defineConfig({
  plugins: [react(), svgr()],
  build: {
    outDir: "build",
    target: "esnext",
  },
  test: {
    // ...
    include: [
      ...configDefaults.include,
      "tests.{js,mjs,cjs,ts,mts,cts,jsx,tsx}",
    ],
  },
});
