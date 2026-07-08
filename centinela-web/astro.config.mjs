// @ts-check
import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://proyecto-centinela.vercel.app',
  compressHTML: true,
  integrations: [
    sitemap({
      filter: (page) => !page.includes('/404'),
    }),
  ],
});
