import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import babel from '@rollup/plugin-babel';

export default defineConfig({
    plugins: [react()],
    build: {
        outDir: 'dist',
        rollupOptions: {
            input: './index.html',
            output: {
                entryFileNames: 'index.js',
                assetFileNames: 'assets/[name].[ext]',
            },
            plugins: [
                babel({
                    babelHelpers: 'bundled',
                    extensions: ['.js', '.jsx'],
                    exclude: 'node_modules/**',
                }),
            ],
        },
    },
});
