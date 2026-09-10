/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  images: {
    domains: ['localhost', 'events.luster-photobooth.com'],
  },
};

module.exports = nextConfig;
