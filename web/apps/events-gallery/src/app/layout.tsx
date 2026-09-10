import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'Luster 360 Memories | Event Media Gallery',
  description: 'View, download, and share your 360 photobooth videos captured by Luster Photobooth.',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="dark">
      <body className="bg-luster-bg text-luster-text antialiased selection:bg-luster-accent selection:text-luster-header">
        {children}
      </body>
    </html>
  );
}
