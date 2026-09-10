import Link from 'next/link';
import { Play, Calendar, MapPin, Download, Share2, Sparkles } from 'lucide-react';

interface EventPageProps {
  params: {
    slug: string;
  };
}

export default async function EventGalleryPage({ params }: EventPageProps) {
  const { slug } = params;

  // Realistic event data matching prompt specifications
  const isAhmedMariam = slug === 'ahmed-mariam';
  const event = {
    name: isAhmedMariam ? 'Ahmed & Mariam Wedding' : 'Corporate Gala 2026',
    date: '10 September 2026',
    venue: 'Four Seasons Nile Plaza, Cairo',
    client: 'Ahmed & Mariam',
    primaryColor: '#86CFFF',
    videoCount: 84,
  };

  // Mock list of ready videos
  const videos = Array.from({ length: 12 }, (_, i) => {
    const num = 84 - i;
    const codes = ['8F3K2A', '9X7L4Q', '4M9T1Z', '2P8W5K', '7N3R9B', '1K6D8Y', '5B2N8C', '3V9X7L', '6M4P1Q', '8J2R5T', '9C7W3K', '4Z8D1P'];
    return {
      id: `vid-${num}`,
      number: num,
      shortCode: codes[i % codes.length],
      duration: '00:15',
      title: `Spin #${num}`,
      views: 24 + (i * 3),
    };
  });

  return (
    <div className="min-h-screen flex flex-col bg-luster-bg text-luster-text">
      {/* 1. Header Navigation */}
      <header className="sticky top-0 z-40 bg-luster-bg/90 backdrop-blur-md border-b border-luster-border px-6 py-4">
        <div className="max-w-6xl mx-auto flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <div className="w-8 h-8 rounded-lg bg-luster-header border border-luster-accent/40 flex items-center justify-center font-black text-xs text-luster-accent">
              360
            </div>
            <span className="font-extrabold tracking-wider text-sm text-luster-text">LUSTER 360</span>
          </div>
          <span className="text-xs font-semibold text-luster-textMuted tracking-wider uppercase">
            Official Event Gallery
          </span>
        </div>
      </header>

      {/* 2. Cinematic Hero Banner */}
      <section className="relative overflow-hidden py-16 px-6 bg-gradient-to-b from-luster-header/40 via-luster-panel to-luster-bg border-b border-luster-border">
        <div className="max-w-4xl mx-auto text-center relative z-10">
          <div className="inline-flex items-center space-x-2 px-3 py-1 rounded-full bg-luster-accentMuted border border-luster-accent/30 text-luster-accent text-xs font-semibold uppercase tracking-widest mb-4">
            <Sparkles className="w-3.5 h-3.5" />
            <span>360 Degree Memories</span>
          </div>

          <h1 className="text-4xl md:text-5xl font-black text-luster-text tracking-tight mb-4 uppercase">
            {event.name}
          </h1>

          <div className="flex flex-wrap items-center justify-center gap-4 text-sm text-luster-textMuted mb-6">
            <span className="flex items-center">
              <Calendar className="w-4 h-4 mr-1.5 text-luster-accent" />
              {event.date}
            </span>
            <span className="text-luster-borderLight">•</span>
            <span className="flex items-center">
              <MapPin className="w-4 h-4 mr-1.5 text-luster-accent" />
              {event.venue}
            </span>
          </div>

          <div className="inline-block px-4 py-1.5 rounded-xl bg-luster-surface border border-luster-border text-xs font-bold text-luster-text">
            {event.videoCount} VIDEOS CAPTURED
          </div>
        </div>
      </section>

      {/* 3. Video Grid Section */}
      <main className="flex-1 max-w-6xl w-full mx-auto px-6 py-12">
        <div className="flex items-center justify-between mb-8 pb-4 border-b border-luster-border">
          <h2 className="text-lg font-bold tracking-wide uppercase text-luster-text">
            Event Memories
          </h2>
          <span className="text-xs text-luster-textMuted">Tap any video to watch & download</span>
        </div>

        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-5">
          {videos.map((vid) => (
            <Link
              key={vid.id}
              href={`/v/${vid.shortCode}`}
              className="group relative rounded-xl overflow-hidden bg-luster-panel border border-luster-border hover:border-luster-accent/60 transition duration-200 flex flex-col"
            >
              {/* Thumbnail Container */}
              <div className="relative aspect-[9/16] bg-luster-surface flex items-center justify-center overflow-hidden">
                <div className="w-12 h-12 rounded-full bg-luster-header/80 border border-luster-accent/40 flex items-center justify-center text-luster-accent group-hover:scale-110 transition duration-200 shadow-xl">
                  <Play className="w-5 h-5 ml-0.5 fill-current" />
                </div>

                <div className="absolute top-2 left-2 px-2 py-0.5 rounded-md bg-black/70 text-[11px] font-mono font-bold text-luster-accent">
                  #{vid.number}
                </div>

                <div className="absolute bottom-2 right-2 px-2 py-0.5 rounded-md bg-black/80 text-[11px] font-mono text-white font-semibold">
                  {vid.duration}
                </div>
              </div>

              {/* Video Info */}
              <div className="p-3 bg-luster-panel border-t border-luster-border flex items-center justify-between">
                <div>
                  <h3 className="text-xs font-bold text-luster-text group-hover:text-luster-accent transition">
                    {vid.title}
                  </h3>
                  <p className="text-[10px] text-luster-textDark font-mono mt-0.5">
                    Code: {vid.shortCode}
                  </p>
                </div>
                <span className="text-[10px] text-luster-textMuted">{vid.views} views</span>
              </div>
            </Link>
          ))}
        </div>
      </main>

      {/* 4. Elegant Luster Footer */}
      <footer className="border-t border-luster-border bg-luster-panel py-12 px-6 text-center">
        <div className="max-w-md mx-auto space-y-4">
          <p className="text-xs font-bold tracking-widest text-luster-accent uppercase">
            KEEP YOUR MEMORIES SHINE FOREVER.
          </p>
          <div className="text-sm font-black tracking-widest text-luster-text">
            LUSTER 360
          </div>
          <p className="text-[11px] text-luster-textDark">
            Captured with professional high-speed 360 photobooth technology.
          </p>
        </div>
      </footer>
    </div>
  );
}
