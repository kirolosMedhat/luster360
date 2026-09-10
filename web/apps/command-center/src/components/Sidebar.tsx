'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { LayoutDashboard, Smartphone, Calendar, HardDrive, Users, Settings, ExternalLink, Radio } from 'lucide-react';

export default function Sidebar() {
  const pathname = usePathname();

  // Hide sidebar completely on mobile booth screen for full-screen immersive UI
  if (pathname.startsWith('/booth')) {
    return null;
  }

  const navItems = [
    { name: 'Dashboard', href: '/', icon: LayoutDashboard },
    { name: 'Fleet Devices', href: '/devices', icon: Smartphone },
    { name: 'Events Monitor', href: '/events', icon: Calendar },
    { name: 'Storage Health', href: '/storage', icon: HardDrive },
    { name: 'Booth Operators', href: '/users', icon: Users },
  ];

  return (
    <aside className="w-64 bg-luster-panel border-r border-luster-border flex flex-col h-screen sticky top-0">
      {/* Brand Header */}
      <div className="p-6 border-b border-luster-border flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <div className="w-9 h-9 rounded-xl bg-luster-header border border-luster-accent/40 flex items-center justify-center font-black text-xs text-luster-accent">
            360
          </div>
          <div>
            <h1 className="font-extrabold text-sm tracking-wider text-luster-text">LUSTER</h1>
            <p className="text-[10px] text-luster-accent font-bold tracking-widest uppercase">COMMAND CENTER</p>
          </div>
        </div>
      </div>

      {/* Navigation Links */}
      <nav className="flex-1 p-4 space-y-1.5 overflow-y-auto">
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = pathname === item.href;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center space-x-3 px-3.5 py-2.5 rounded-xl text-xs font-bold transition ${
                isActive
                  ? 'bg-luster-accent text-luster-header shadow-md shadow-luster-accent/10'
                  : 'text-luster-textMuted hover:text-luster-text hover:bg-luster-surface'
              }`}
            >
              <Icon className="w-4 h-4" />
              <span>{item.name}</span>
            </Link>
          );
        })}
      </nav>

      {/* Realtime Live Telemetry Indicator */}
      <div className="p-4 border-t border-luster-border bg-luster-surface/50">
        <div className="flex items-center space-x-2 text-[11px] font-bold text-luster-success mb-2">
          <Radio className="w-3.5 h-3.5 animate-pulse" />
          <span>REALTIME STREAM ACTIVE</span>
        </div>
        <p className="text-[10px] text-luster-textDark">
          Connected to Luster Media API & Supabase Realtime Channel
        </p>
      </div>
    </aside>
  );
}
