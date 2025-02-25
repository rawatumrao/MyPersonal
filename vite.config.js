// vite.config.js
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import babel from '@rollup/plugin-babel';

export default defineConfig({
    plugins: [
        react(),
        babel({
            babelHelpers: 'bundled',
            extensions: ['.js', '.jsx'],
            exclude: 'node_modules/**',
        })
    ],
    build: {
        outDir: 'dist',
        rollupOptions: {
            output: {
                entryFileNames: 'index.js',
                assetFileNames: 'assets/[name].[ext]',
            }
        }
    },
    resolve: {
        alias: {
            'bitmovin-player': 'bitmovin-player/modules/bitmovinplayer'
        }
    }
});
