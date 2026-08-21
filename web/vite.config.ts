import { defineConfig } from "vite";
import solid from "@solidjs/vite-plugin";

export default defineConfig({
  plugins: [solid()],
  build: {
    lib: {
      entry: "src/index.tsx",
      formats: ["es"],
      fileName: () => "index.js",
    },
    rollupOptions: {
      external: [
        "solid-js",
        "@solidjs/web",
        "@solidjs/signals",
        /^solid-js\//,
        /^@solidjs\//,
      ],
    },
    target: "es2020",
    minify: false,
  },
  test: {
    environment: "node",
    include: ["test/**/*.test.ts"],
  },
});
