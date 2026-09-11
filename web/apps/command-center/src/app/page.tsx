'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { Smartphone, Calendar, HardDrive, ArrowUpRight, CloudUpload, Radio, RefreshCw } from 'lucide-react';

interface Device {
  id: string;
  device_identifier: string;
  device_name: string;
  calculatedStatus: 'ONLINE' | 'OFFLINE';
  currentState: string;
  battery_level?: number;
  storage_free_bytes?: number;
  platform?: string;
  last_heartbeat?: string;
}

interface EventItem {
  id: string;
  name: string;
  venue?: string;
  client_name?: string;
  status: string;
  calculatedDuration?: string;
  gallery_slug?: string;
}

export default function CommandCenterDashboard() {
  const [devices, setDevices] = useState<Device[]>([]);
  const [events, setEvents] = useState<EventItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [lastRefreshed, setLastRefreshed] = useState<Date>(new Date());

  const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000';

  const pollLiveData = async () => {
    try {
      // 1. Fetch live fleet telemetry
      const devRes = await fetch(`${apiUrl}/api/v1/devices/fleet`);
      const devData = await devRes.json();
      if (devData.success) {
        setDevices(devData.data || []);
      }

      // 2. Fetch live events
      const evtRes = await fetch(`${apiUrl}/api/v1/events`);
      const evtData = await evtRes.json();
      if (evtData.success) {
        setEvents(evtData.data || []);
      }
      setLastRefreshed(new Date());
    } catch {
      // Ignore transient polling failure
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    pollLiveData();
    const interval = setInterval(pollLiveData, 3000); // 3-second live refresh
    return () => clearInterval(interval);
  }, []);

  const onlineDevicesCount = devices.filter(d => d.calculatedStatus === 'ONLINE').length;
  const activeEvents = events.filter(e => e.status === 'ACTIVE');
  const activeEvent = activeEvents[0] || null;

  const totalRecorded = devices.reduce((sum, d) => sum + ((d as any).capturesRecorded || 0), 0);
  const totalUploaded = devices.reduce((sum, d) => sum + ((d as any).capturesUploaded || 0), 0);
  const totalPending = devices.reduce((sum, d) => sum + ((d as any).capturesPending || 0), 0);

  return (
    <div className="p-8 space-y-8">
      {/* 1. Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-black tracking-tight text-luster-text">OPERATIONS DASHBOARD</h1>
          <p className="text-xs text-luster-textMuted mt-1">Live fleet telemetry, event durations, and media storage pipelines</p>
        </div>
        <div className="flex items-center space-x-3">
          <div className="flex items-center space-x-2 px-3 py-1.5 rounded-xl bg-luster-panel border border-luster-border text-[11px] font-mono text-luster-textMuted">
            <Radio className="w-3 h-3 text-luster-success animate-pulse" />
            <span>LIVE 3S SYNC</span>
          </div>
          {activeEvent && (
            <Link
              href={`http://localhost:3000/event/${activeEvent.gallery_slug || 'ahmed-mariam'}`}
              target="_blank"
              className="flex items-center space-x-2 px-3.5 py-2 rounded-xl bg-luster-surface border border-luster-border text-xs font-bold text-luster-text hover:border-luster-borderLight transition"
            >
              <span>Customer Gallery</span>
              <ArrowUpRight className="w-3.5 h-3.5 text-luster-accent" />
            </Link>
          )}
        </div>
      </div>

      {/* 2. Top Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <div className="p-5 rounded-2xl bg-luster-panel border border-luster-border">
          <div className="flex items-center justify-between mb-3">
            <span className="text-[11px] font-bold text-luster-textMuted tracking-wider uppercase">ACTIVE DEVICES</span>
            <Smartphone className="w-4 h-4 text-luster-success" />
          </div>
          <div className="text-2xl font-black text-luster-text tracking-tight font-mono">
            {onlineDevicesCount} / {devices.length}
          </div>
          <div className="text-xs text-luster-textDark mt-1 font-medium">Booths currently online</div>
        </div>

        <div className="p-5 rounded-2xl bg-luster-panel border border-luster-border">
          <div className="flex items-center justify-between mb-3">
            <span className="text-[11px] font-bold text-luster-textMuted tracking-wider uppercase">ACTIVE EVENTS</span>
            <Calendar className="w-4 h-4 text-luster-accent" />
          </div>
          <div className="text-2xl font-black text-luster-text tracking-tight font-mono">
            {activeEvents.length}
          </div>
          <div className="text-xs text-luster-textDark mt-1 font-medium">Live events running</div>
        </div>

        <div className="p-5 rounded-2xl bg-luster-panel border border-luster-border">
          <div className="flex items-center justify-between mb-3">
            <span className="text-[11px] font-bold text-luster-textMuted tracking-wider uppercase">CAPTURES / UPLOADS</span>
            <CloudUpload className="w-4 h-4 text-luster-accent" />
          </div>
          <div className="text-2xl font-black text-luster-text tracking-tight font-mono">
            {totalRecorded} <span className="text-xs font-bold text-slate-500">rec</span> / {totalUploaded} <span className="text-xs font-bold text-emerald-400">up</span>
          </div>
          <div className="text-xs text-luster-textDark mt-1 font-medium flex items-center justify-between">
            <span>{totalPending > 0 ? `${totalPending} uploading to Drive...` : 'All synced to Google Drive'}</span>
            {totalPending > 0 && <span className="w-2 h-2 rounded-full bg-amber-400 animate-pulse" />}
          </div>
        </div>

        <div className="p-5 rounded-2xl bg-luster-panel border border-luster-border">
          <div className="flex items-center justify-between mb-3">
            <span className="text-[11px] font-bold text-luster-textMuted tracking-wider uppercase">STORAGE HEALTH</span>
            <HardDrive className="w-4 h-4 text-luster-success" />
          </div>
          <div className="text-2xl font-black text-luster-text tracking-tight">
            GOOGLE DRIVE
          </div>
          <div className="text-xs text-luster-textDark mt-1 font-medium">V1 Connected • Active Master</div>
        </div>
      </div>

      {/* Mobile Booth Quick Connect Banner */}
      <div className="p-6 rounded-2xl bg-gradient-to-r from-luster-panel via-luster-surface to-luster-panel border border-luster-accent/30 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
        <div className="flex items-center space-x-4">
          <div className="w-12 h-12 rounded-2xl bg-luster-accent/10 border border-luster-accent/40 flex items-center justify-center text-luster-accent">
            <Smartphone className="w-6 h-6" />
          </div>
          <div>
            <div className="flex items-center space-x-2">
              <h2 className="text-base font-black text-luster-text">TEST ON YOUR MOBILE PHONE (NO APK REQUIRED)</h2>
              <span className="px-2 py-0.5 rounded-full bg-luster-success/10 border border-luster-success/30 text-[10px] text-luster-success font-bold">
                LOCAL WI-FI READY
              </span>
            </div>
            <p className="text-xs text-luster-textMuted mt-1">
              Open Safari or Chrome on your phone and browse to: <code className="px-2 py-0.5 rounded bg-luster-bg border border-luster-border text-luster-accent font-mono font-bold">http://192.168.1.5:3001/booth</code>
            </p>
          </div>
        </div>

        <div className="flex items-center space-x-3 w-full md:w-auto">
          <Link
            href="/booth"
            target="_blank"
            className="flex-1 md:flex-initial px-4 py-2.5 rounded-xl bg-luster-accent text-luster-bg text-xs font-black uppercase tracking-wider hover:opacity-90 transition flex items-center justify-center space-x-2 shadow-lg shadow-luster-accent/20"
          >
            <span>Launch Mobile Booth Simulator</span>
            <ArrowUpRight className="w-4 h-4" />
          </Link>
        </div>
      </div>

      {/* 3. Active Event Spotlight */}
      {activeEvent ? (
        <div className="p-6 rounded-2xl bg-luster-panel border border-luster-accent/40 shadow-xl relative overflow-hidden">
          <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-6 border-b border-luster-border">
            <div>
              <div className="inline-flex items-center space-x-2 px-2.5 py-0.5 rounded-full bg-luster-accentMuted text-luster-accent text-[11px] font-bold uppercase tracking-wider mb-2">
                <span className="w-2 h-2 rounded-full bg-luster-accent animate-pulse" />
                <span>LIVE EVENT MONITOR</span>
              </div>
              <h2 className="text-2xl font-black text-luster-text">{activeEvent.name}</h2>
              <p className="text-xs text-luster-textMuted mt-1">
                {activeEvent.venue || 'Live Event Venue'} • Client: {activeEvent.client_name || 'Event Client'}
              </p>
            </div>

            <div className="flex items-center space-x-6">
              <div className="text-right">
                <span className="text-[10px] font-bold text-luster-textDark uppercase">CURRENT DURATION</span>
                <div className="text-2xl font-black font-mono text-luster-accent">
                  {activeEvent.calculatedDuration || '00h 00m'}
                </div>
              </div>
              <div className="text-right">
                <span className="text-[10px] font-bold text-luster-textDark uppercase">STATUS</span>
                <div className="text-xs font-bold px-2.5 py-1 rounded-md bg-luster-success/20 text-luster-success mt-1">
                  {activeEvent.status}
                </div>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mt-6">
            <div className="p-4 rounded-xl bg-luster-surface border border-luster-border">
              <span className="text-[10px] font-bold text-luster-textDark uppercase">TOTAL CAPTURES</span>
              <div className="text-xl font-black text-luster-text mt-1">{totalRecorded}</div>
            </div>
            <div className="p-4 rounded-xl bg-luster-surface border border-luster-border">
              <span className="text-[10px] font-bold text-luster-textDark uppercase">UPLOADED TO DRIVE</span>
              <div className="text-xl font-black text-luster-success mt-1">{totalUploaded}</div>
            </div>
            <div className="p-4 rounded-xl bg-luster-surface border border-luster-border">
              <span className="text-[10px] font-bold text-luster-textDark uppercase">PENDING UPLOAD</span>
              <div className="text-xl font-black text-luster-warning mt-1">{totalPending}</div>
            </div>
            <div className="p-4 rounded-xl bg-luster-surface border border-luster-border">
              <span className="text-[10px] font-bold text-luster-textDark uppercase">STORAGE PROVIDER</span>
              <div className="text-sm font-bold text-luster-accent mt-1">Google Drive V1</div>
            </div>
          </div>
        </div>
      ) : (
        <div className="p-8 rounded-2xl bg-luster-panel border border-dashed border-luster-border text-center">
          <Calendar className="w-8 h-8 text-luster-textDark mx-auto mb-3" />
          <h3 className="text-sm font-bold text-luster-text">No Live Event Active</h3>
          <p className="text-xs text-luster-textMuted mt-1 max-w-sm mx-auto">
            When you activate an event from the Events Monitor or your mobile booth app, live duration and captures will stream here.
          </p>
          <Link
            href="/events"
            className="inline-block mt-4 px-4 py-2 rounded-xl bg-luster-surface border border-luster-border text-xs font-bold text-luster-accent hover:border-luster-accent transition"
          >
            Go to Events Monitor
          </Link>
        </div>
      )}

      {/* 4. Active Device Fleet Grid (True Live Presence) */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-sm font-bold tracking-wider text-luster-text uppercase">Hardware Fleet Live Status</h2>
          <Link href="/devices" className="text-xs text-luster-accent hover:underline font-bold">
            View All Devices &rarr;
          </Link>
        </div>

        {devices.length === 0 ? (
          <div className="p-12 rounded-2xl bg-luster-panel border border-dashed border-luster-border text-center">
            <Smartphone className="w-8 h-8 text-luster-textDark mx-auto mb-3" />
            <h3 className="text-sm font-bold text-luster-text">0 Booths Connected</h3>
            <p className="text-xs text-luster-textMuted mt-1 max-w-md mx-auto">
              No mobile booth devices are currently connected. Launch the LUSTER 360 mobile app on your phone or tablet to see it appear here in real time.
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
            {devices.map((d) => {
              const isOnline = d.calculatedStatus === 'ONLINE';
              const freeGb = d.storage_free_bytes
                ? (d.storage_free_bytes / (1024 * 1024 * 1024)).toFixed(1) + ' GB free'
                : 'Storage nominal';

              return (
                <div
                  key={d.id}
                  className={`p-5 rounded-2xl bg-luster-panel border transition ${
                    isOnline ? 'border-luster-border hover:border-luster-accent' : 'border-luster-border/50 opacity-60'
                  }`}
                >
                  <div className="flex items-center justify-between mb-3">
                    <div className="flex items-center space-x-2">
                      <span className={`w-2.5 h-2.5 rounded-full ${isOnline ? 'bg-luster-success' : 'bg-luster-danger'}`} />
                      <span className="font-mono font-bold text-xs text-luster-text">{d.device_identifier || d.id}</span>
                    </div>
                    <span
                      className={`text-[10px] font-bold px-2 py-0.5 rounded-md ${
                        isOnline ? 'bg-luster-success/20 text-luster-success' : 'bg-luster-surface text-luster-textDark'
                      }`}
                    >
                      {isOnline ? (d.currentState || 'ONLINE') : 'OFFLINE'}
                    </span>
                  </div>

                  <h3 className="text-sm font-bold text-luster-text">{d.device_name || 'Mobile Booth Unit'}</h3>
                  <p className="text-xs text-luster-textMuted mt-0.5">{d.platform || 'Android / iOS'}</p>

                  <div className="mt-4 pt-3 border-t border-luster-border flex items-center justify-between text-xs text-luster-textDark">
                    <span>Battery: {d.battery_level !== undefined && d.battery_level !== null ? `${d.battery_level}%` : 'N/A'}</span>
                    <span>{freeGb}</span>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}
