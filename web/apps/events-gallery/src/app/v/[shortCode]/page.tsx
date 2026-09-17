'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { ArrowLeft, Download, Share2, QrCode, Sparkles, Check, Loader2, MessageCircle } from 'lucide-react';

interface VideoPageProps {
  params: {
    shortCode: string;
  };
}

export default function CustomerVideoPage({ params }: VideoPageProps) {
  const { shortCode } = params;
  const [isPlaying, setIsPlaying] = useState(false);
  const [copied, setCopied] = useState(false);
  const [showQrModal, setShowQrModal] = useState(false);
  const [isReady, setIsReady] = useState(true);
  const [statusMessage, setStatusMessage] = useState('Processing Master Render');
  const [eventName, setEventName] = useState('Ahmed & Mariam Wedding');

  // Resolved streaming and download endpoints through LUSTER Media API
  const streamUrl = `http://localhost:4000/api/v1/media/stream/${shortCode}`;
  const downloadUrl = `http://localhost:4000/api/v1/media/download/${shortCode}`;
  const currentUrl = typeof window !== 'undefined' ? window.location.href : `https://gallery.luster360.com/v/${shortCode}`;
  const whatsappShareUrl = `https://api.whatsapp.com/send?text=${encodeURIComponent(
    `Check out my 360 photobooth spin from ${eventName}! 🎥✨ ${currentUrl}`
  )}`;

  // Auto-polling for processing/rendering status
  useEffect(() => {
    let timer: NodeJS.Timeout;

    const checkStatus = async () => {
      try {
        const res = await fetch(`http://localhost:4000/api/v1/videos/resolve/${shortCode}`);
        if (res.ok) {
          const body = await res.json();
          if (body.success && body.data) {
            const status = (body.data.storage_status || body.data.publication_status || 'READY').toUpperCase();
            if (status === 'READY') {
              setIsReady(true);
            } else {
              setIsReady(false);
              setStatusMessage(status === 'RENDERING' ? 'Rendering High-Speed Composite' : 'Uploading Master Video');
              // Poll again in 3.5 seconds
              timer = setTimeout(checkStatus, 3500);
            }
          }
        }
      } catch (_) {
        // Fallback: assume ready if backend API is not directly reachable on client side
        setIsReady(true);
      }
    };

    checkStatus();

    return () => {
      if (timer) clearTimeout(timer);
    };
  }, [shortCode]);

  const handleShare = async () => {
    if (typeof navigator !== 'undefined' && navigator.share) {
      try {
        await navigator.share({
          title: `Watch my 360 Spin! | Luster 360`,
          text: `Check out my 360 photobooth video from ${eventName}!`,
          url: currentUrl,
        });
      } catch (err) {
        copyToClipboard();
      }
    } else {
      copyToClipboard();
    }
  };

  const copyToClipboard = () => {
    navigator.clipboard.writeText(currentUrl);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="min-h-screen flex flex-col bg-luster-bg text-luster-text">
      {/* 1. Header */}
      <header className="px-6 py-4 border-b border-luster-border bg-luster-panel/80 backdrop-blur-md sticky top-0 z-40">
        <div className="max-w-md mx-auto flex items-center justify-between">
          <Link
            href="/event/ahmed-mariam"
            className="inline-flex items-center text-xs font-semibold text-luster-textMuted hover:text-luster-accent transition"
          >
            <ArrowLeft className="w-4 h-4 mr-1.5" />
            Back to Gallery
          </Link>
          <span className="font-extrabold text-xs tracking-wider text-luster-accent uppercase">
            LUSTER 360
          </span>
        </div>
      </header>

      {/* 2. Main Content Container */}
      <main className="flex-1 max-w-md w-full mx-auto px-5 py-6 flex flex-col items-center justify-center">
        {/* Event Context */}
        <div className="text-center mb-5">
          <h1 className="text-xl font-extrabold text-luster-text">
            {eventName}
          </h1>
          <p className="text-xs text-luster-textMuted font-mono mt-0.5">
            Spin Code: #{shortCode}
          </p>
        </div>

        {/* 3. Conditional: Processing vs Player */}
        {!isReady ? (
          <div className="w-full aspect-[9/16] rounded-2xl bg-luster-panel border border-luster-border shadow-2xl p-6 flex flex-col items-center justify-center text-center mb-6">
            <div className="relative mb-6">
              <div className="w-20 h-20 rounded-full border-4 border-luster-accent/20 border-t-luster-accent animate-spin" />
              <div className="absolute inset-0 flex items-center justify-center">
                <Sparkles className="w-8 h-8 text-luster-accent animate-pulse" />
              </div>
            </div>
            <h2 className="text-lg font-extrabold text-luster-text mb-2">
              {statusMessage}
            </h2>
            <p className="text-xs text-luster-textMuted max-w-xs leading-relaxed mb-6">
              Your 360 spin is currently undergoing speed ramping, color grading, and cloud optimization.
            </p>
            <div className="w-full bg-luster-surface rounded-full h-1.5 overflow-hidden">
              <div className="bg-luster-accent h-full w-2/3 animate-pulse" />
            </div>
            <p className="text-[11px] text-luster-textDark font-mono mt-3">
              Auto-refreshing every 3 seconds...
            </p>
          </div>
        ) : (
          <div className="w-full relative aspect-[9/16] rounded-2xl overflow-hidden bg-luster-panel border border-luster-border shadow-2xl mb-6">
            <video
              src={streamUrl}
              controls
              autoPlay
              playsInline
              className="w-full h-full object-cover"
              onPlay={() => setIsPlaying(true)}
              onPause={() => setIsPlaying(false)}
            >
              Your browser does not support HTML5 video streaming.
            </video>
          </div>
        )}

        {/* 4. Action Buttons */}
        <div className="w-full space-y-3">
          {/* Download Video Button */}
          <a
            href={downloadUrl}
            download
            className="w-full flex items-center justify-center space-x-2 py-4 px-6 rounded-xl bg-luster-accent text-luster-header font-bold text-sm hover:bg-luster-accentHover transition shadow-lg shadow-luster-accent/15"
          >
            <Download className="w-4 h-4 stroke-[2.5]" />
            <span>DOWNLOAD HIGH-QUALITY MP4</span>
          </a>

          {/* WhatsApp Direct Share Button */}
          <a
            href={whatsappShareUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="w-full flex items-center justify-center space-x-2 py-3.5 px-6 rounded-xl bg-[#25D366] text-white font-bold text-sm hover:bg-[#20bd5a] transition shadow-lg shadow-[#25D366]/20"
          >
            <MessageCircle className="w-4 h-4 fill-white stroke-[1.5]" />
            <span>SHARE ON WHATSAPP</span>
          </a>

          {/* Social Share & QR Buttons */}
          <div className="grid grid-cols-2 gap-3">
            <button
              onClick={handleShare}
              className="flex items-center justify-center space-x-2 py-3 px-4 rounded-xl bg-luster-surface border border-luster-border text-luster-text font-semibold text-xs hover:border-luster-borderLight transition"
            >
              {copied ? <Check className="w-4 h-4 text-luster-success" /> : <Share2 className="w-4 h-4 text-luster-accent" />}
              <span>{copied ? 'LINK COPIED' : 'SHARE LINK'}</span>
            </button>

            <button
              onClick={() => setShowQrModal(true)}
              className="flex items-center justify-center space-x-2 py-3 px-4 rounded-xl bg-luster-surface border border-luster-border text-luster-text font-semibold text-xs hover:border-luster-borderLight transition"
            >
              <QrCode className="w-4 h-4 text-luster-accent" />
              <span>SHOW QR CODE</span>
            </button>
          </div>
        </div>

        {/* Brand Tagline */}
        <div className="mt-8 text-center">
          <p className="text-[11px] font-bold tracking-widest text-luster-textDark uppercase">
            KEEP YOUR MEMORIES SHINE FOREVER.
          </p>
        </div>
      </main>

      {/* 5. QR Code Modal */}
      {showQrModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-6">
          <div className="max-w-sm w-full bg-luster-panel border border-luster-border rounded-2xl p-6 text-center shadow-2xl">
            <h3 className="text-base font-bold text-luster-text mb-1">
              Scan to Watch & Download
            </h3>
            <p className="text-xs text-luster-textMuted mb-4">
              Point your phone camera at this QR code
            </p>

            <div className="p-4 bg-white rounded-xl inline-block mb-4 shadow-md">
              <div className="w-48 h-48 bg-slate-900 rounded flex flex-col items-center justify-center text-white text-xs font-mono p-4">
                <QrCode className="w-24 h-24 text-luster-accent mb-2" />
                <span className="text-[10px] text-slate-400 break-all">{currentUrl}</span>
              </div>
            </div>

            <button
              onClick={() => setShowQrModal(false)}
              className="w-full py-2.5 rounded-xl bg-luster-surface border border-luster-border text-luster-text text-xs font-semibold hover:bg-luster-header transition"
            >
              Close
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
