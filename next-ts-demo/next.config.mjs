/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // 이미지 도메인 허용 (데모에서 Unsplash 이미지를 쓰므로 추가)
  images: {
    remotePatterns: [
      { protocol: "https", hostname: "images.unsplash.com" }
    ]
  },
  experimental: {
    typedRoutes: true
  }
};

export default nextConfig;
