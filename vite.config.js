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
        })
    ],
    build: {
        lib: {
            entry: 'src/main.jsx',
            name: 'GlobalMeetUI',
            fileName: 'index',
            formats: ['umd'],
        },
        rollupOptions: {
            output: {
                globals: {
                    react: 'React',
                    'react-dom': 'ReactDOM',
                },
            },
        },
    },
});
