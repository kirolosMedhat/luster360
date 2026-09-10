import Link from 'next/link';

export default function HomePage() {
  return (
    <main className="min-h-screen flex flex-col items-center justify-center p-6 text-center">
      <div className="max-w-md w-full p-8 rounded-2xl bg-luster-panel border border-luster-border shadow-2xl">
        <div className="w-16 h-16 mx-auto mb-6 rounded-2xl bg-luster-header border border-luster-accent/30 flex items-center justify-center">
          <span className="text-2xl font-black text-luster-accent tracking-wider">360</span>
        </div>

        <h1 className="text-3xl font-extrabold text-luster-text tracking-tight mb-2">
          LUSTER 360
        </h1>
        <p className="text-sm font-semibold tracking-widest text-luster-accent mb-6 uppercase">
          Event Media Platform
        </p>

        <p className="text-sm text-luster-textMuted mb-8 leading-relaxed">
          Welcome to the official guest media portal. Scan your booth QR code or visit your dedicated event gallery to view and download your 360 spins.
        </p>

        <div className="space-y-3">
          <Link
            href="/event/ahmed-mariam"
            className="block w-full py-3.5 px-4 rounded-xl bg-luster-accent text-luster-header font-bold text-sm hover:bg-luster-accentHover transition shadow-lg shadow-luster-accent/10"
          >
            Open Demo Event: Ahmed & Mariam Wedding
          </Link>
          <Link
            href="/v/8F3K2A"
            className="block w-full py-3.5 px-4 rounded-xl bg-luster-surface border border-luster-border text-luster-text font-semibold text-sm hover:border-luster-borderLight transition"
          >
            Open Demo Video: Spin #127
          </Link>
        </div>

        <div className="mt-8 pt-6 border-t border-luster-border/60">
          <p className="text-xs text-luster-textDark uppercase tracking-wider font-semibold">
            KEEP YOUR MEMORIES SHINE FOREVER.
          </p>
        </div>
      </div>
    </main>
  );
}
