'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { 
  Calendar, 
  Clock, 
  Film, 
  CheckCircle2, 
  ArrowUpRight, 
  Plus, 
  RefreshCw, 
  ExternalLink, 
  Play, 
  Layers, 
  HardDrive, 
  X,
  AlertCircle,
  Smartphone
} from 'lucide-react';

interface EventItem {
  id: string;
  name: string;
  client_name?: string;
  venue?: string;
  event_date?: string;
  status: string;
  started_at?: string;
  duration?: string;
  calculatedDuration?: string;
  gallery_slug?: string;
  drive_root_folder_id?: string;
  drive_videos_folder_id?: string;
  device?: string;
  videoStats?: {
    total: number;
    uploaded: number;
    pending: number;
    failed: number;
  };
}

export default function EventsPage() {
  const [events, setEvents] = useState<EventItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [creating, setCreating] = useState(false);
  const [createError, setCreateError] = useState<string | null>(null);

  // Form State
  const [name, setName] = useState('');
  const [clientName, setClientName] = useState('');
  const [venue, setVenue] = useState('');
  const [eventDate, setEventDate] = useState(new Date().toISOString().split('T')[0]);

  const fetchLiveEvents = async () => {
    try {
      const res = await fetch('/api/v1/events');
      const json = await res.json();
      if (json.success && Array.isArray(json.data)) {
        setEvents(json.data);
      }
    } catch (err) {
      console.warn('Could not fetch events:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchLiveEvents();
    const timer = setInterval(fetchLiveEvents, 3000);
    return () => clearInterval(timer);
  }, []);

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) return;
    setCreating(true);
    setCreateError(null);

    try {
      const res = await fetch('/api/v1/events', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name: name.trim(),
          clientName: clientName.trim() || 'Private Client',
          venue: venue.trim() || 'Commercial Venue',
          eventDate,
        }),
      });

      const json = await res.json();
      if (!res.ok || !json.success) {
        throw new Error(json.error?.message || json.error || 'Failed to create event');
      }

      setShowCreateModal(false);
      setName('');
      setClientName('');
      setVenue('');
      await fetchLiveEvents();
    } catch (err: any) {
      setCreateError(err.message || 'Error creating event');
    } finally {
      setCreating(false);
    }
  };

  return (
    <div className="p-8 max-w-7xl mx-auto space-y-8 select-none">
      {/* 1. Header with Darkroom / Taste Aesthetic */}
      <div className="flex flex-col sm:row sm:items-center justify-between gap-4 pb-6 border-b border-[#1E2330]">
        <div>
          <div className="flex items-center space-x-2 text-[11px] font-mono text-[#86CFFF] tracking-widest uppercase mb-1">
            <span className="w-2 h-2 rounded-full bg-[#86CFFF] animate-pulse" />
            <span>OPERATIONAL EVENT SESSIONS</span>
          </div>
          <h1 className="text-2xl font-black tracking-tight text-white">EVENT MONITORING</h1>
          <p className="text-xs text-slate-400 mt-0.5">
            Real-time session timers, active booth bindings, and cloud storage pipelines
          </p>
        </div>

        <div className="flex items-center space-x-3">
          <button
            onClick={() => fetchLiveEvents()}
            className="p-2.5 rounded-xl bg-[#141822] border border-[#232A3B] text-slate-400 hover:text-white hover:border-[#86CFFF] transition"
            title="Refresh events"
          >
            <RefreshCw className="w-4 h-4" />
          </button>
          <button
            onClick={() => setShowCreateModal(true)}
            className="px-4 py-2.5 rounded-xl bg-[#86CFFF] text-[#0B0F17] font-black text-xs uppercase tracking-wider shadow-lg shadow-[#86CFFF]/20 hover:bg-[#9ee2ff] active:scale-95 transition flex items-center space-x-2"
          >
            <Plus className="w-4 h-4" />
            <span>CREATE NEW EVENT</span>
          </button>
        </div>
      </div>

      {/* 2. Events List */}
      {loading && events.length === 0 ? (
        <div className="p-16 rounded-2xl bg-[#12151E] border border-[#1E2330] text-center space-y-3">
          <RefreshCw className="w-6 h-6 text-[#86CFFF] animate-spin mx-auto" />
          <p className="text-xs text-slate-400 font-mono">Syncing operational events...</p>
        </div>
      ) : events.length === 0 ? (
        <div className="p-16 rounded-2xl bg-[#12151E] border border-dashed border-[#232A3B] text-center space-y-4">
          <Calendar className="w-10 h-10 text-slate-600 mx-auto" />
          <div>
            <h3 className="text-sm font-bold text-white">No Events Found</h3>
            <p className="text-xs text-slate-400 mt-1 max-w-sm mx-auto">
              Create your first 360 event to configure duration, custom PNG overlays, soundtrack, and booth hardware.
            </p>
          </div>
          <button
            onClick={() => setShowCreateModal(true)}
            className="px-4 py-2.5 rounded-xl bg-[#86CFFF] text-[#0B0F17] font-bold text-xs uppercase tracking-wider"
          >
            Create First Event
          </button>
        </div>
      ) : (
        <div className="space-y-4">
          {events.map((e) => {
            const isActive = e.status === 'ACTIVE';
            const durationDisplay = e.duration || e.calculatedDuration || '00h 00m';
            const totalVids = e.videoStats?.total || 0;
            const upVids = e.videoStats?.uploaded || 0;

            return (
              <div
                key={e.id}
                className={`p-6 rounded-2xl bg-[#12151E] border transition-all duration-200 ${
                  isActive 
                    ? 'border-[#86CFFF]/50 shadow-xl shadow-[#86CFFF]/5' 
                    : 'border-[#1E2330] hover:border-[#2A3345]'
                }`}
              >
                {/* Event Card Header */}
                <div className="flex flex-col md:flex-row md:items-center justify-between pb-4 border-b border-[#1E2330] gap-4">
                  <div className="space-y-1">
                    <div className="flex items-center space-x-3">
                      <h2 className="text-lg font-black text-white tracking-wide">{e.name}</h2>
                      <span
                        className={`text-[10px] font-mono font-bold px-2.5 py-0.5 rounded-full flex items-center space-x-1.5 ${
                          isActive
                            ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/30'
                            : 'bg-slate-800 text-slate-400 border border-slate-700'
                        }`}
                      >
                        {isActive && <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />}
                        <span>{e.status}</span>
                      </span>
                    </div>
                    <p className="text-xs text-slate-400">
                      Client: <span className="text-slate-200 font-semibold">{e.client_name || 'Commercial Client'}</span>
                      <span className="mx-2 text-slate-600">•</span>
                      Venue: <span className="text-slate-200">{e.venue || 'Private Location'}</span>
                    </p>
                  </div>

                  {/* Actions: Launch Booth & Public Gallery */}
                  <div className="flex items-center space-x-3">
                    <Link
                      href={`/booth?eventId=${e.id}`}
                      target="_blank"
                      className="flex items-center space-x-2 px-3.5 py-2 rounded-xl bg-[#86CFFF] text-[#0B0F17] text-xs font-black uppercase tracking-wider hover:bg-[#9ee2ff] active:scale-95 transition shadow-lg shadow-[#86CFFF]/15"
                    >
                      <Smartphone className="w-3.5 h-3.5" />
                      <span>Launch Booth</span>
                    </Link>

                    <Link
                      href={`http://localhost:3000/event/${e.gallery_slug || 'preview'}`}
                      target="_blank"
                      className="flex items-center space-x-2 px-3.5 py-2 rounded-xl bg-[#181D29] border border-[#262F42] text-xs font-bold text-slate-200 hover:text-white hover:border-[#86CFFF] transition"
                    >
                      <span>Gallery</span>
                      <ArrowUpRight className="w-3.5 h-3.5 text-[#86CFFF]" />
                    </Link>
                  </div>
                </div>

                {/* Metrics Grid */}
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-3.5 mt-4">
                  <div className="p-3.5 rounded-xl bg-[#0E1017] border border-[#1A1E29]">
                    <span className="text-[10px] font-mono font-bold text-slate-500 uppercase tracking-wider">
                      LIVE DURATION
                    </span>
                    <div className="text-lg font-black font-mono text-[#86CFFF] mt-0.5">
                      {durationDisplay}
                    </div>
                  </div>

                  <div className="p-3.5 rounded-xl bg-[#0E1017] border border-[#1A1E29]">
                    <span className="text-[10px] font-mono font-bold text-slate-500 uppercase tracking-wider">
                      CAPTURES
                    </span>
                    <div className="text-lg font-black font-mono text-white mt-0.5">
                      {totalVids} <span className="text-xs text-slate-500 font-normal">vids</span>
                    </div>
                  </div>

                  <div className="p-3.5 rounded-xl bg-[#0E1017] border border-[#1A1E29]">
                    <span className="text-[10px] font-mono font-bold text-slate-500 uppercase tracking-wider">
                      DRIVE SYNC
                    </span>
                    <div className="text-lg font-black font-mono text-emerald-400 mt-0.5">
                      {upVids} <span className="text-xs text-slate-500 font-normal">synced</span>
                    </div>
                  </div>

                  <div className="p-3.5 rounded-xl bg-[#0E1017] border border-[#1A1E29]">
                    <span className="text-[10px] font-mono font-bold text-slate-500 uppercase tracking-wider">
                      STORAGE STATUS
                    </span>
                    <div className="text-xs font-bold text-slate-300 mt-1 flex items-center space-x-1.5">
                      <HardDrive className="w-3.5 h-3.5 text-emerald-400" />
                      <span>Google Drive Root</span>
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* 3. Create Event Modal */}
      {showCreateModal && (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-md z-50 flex items-center justify-center p-6">
          <div className="w-full max-w-md bg-[#12151E] border border-[#262F42] rounded-3xl p-6 space-y-5 shadow-2xl">
            <div className="flex items-center justify-between pb-3 border-b border-[#1E2330]">
              <div>
                <h3 className="text-base font-black text-white">CREATE NEW EVENT</h3>
                <p className="text-xs text-slate-400">Provisions Google Drive folder structure and booth profile</p>
              </div>
              <button
                onClick={() => setShowCreateModal(false)}
                className="p-1 rounded-lg text-slate-400 hover:text-white hover:bg-[#1E2330]"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {createError && (
              <div className="p-3 rounded-xl bg-red-500/10 border border-red-500/30 text-xs text-red-400 flex items-center space-x-2">
                <AlertCircle className="w-4 h-4 flex-shrink-0" />
                <span>{createError}</span>
              </div>
            )}

            <form onSubmit={handleCreate} className="space-y-4">
              <div>
                <label className="block text-[11px] font-mono font-bold text-slate-400 uppercase tracking-wider mb-1.5">
                  Event Name *
                </label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Ahmed & Mariam Royal Wedding"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  className="w-full px-3.5 py-2.5 bg-[#0B0D13] border border-[#232A3B] rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none focus:border-[#86CFFF]"
                />
              </div>

              <div>
                <label className="block text-[11px] font-mono font-bold text-slate-400 uppercase tracking-wider mb-1.5">
                  Client Name
                </label>
                <input
                  type="text"
                  placeholder="e.g. Ahmed Medhat"
                  value={clientName}
                  onChange={(e) => setClientName(e.target.value)}
                  className="w-full px-3.5 py-2.5 bg-[#0B0D13] border border-[#232A3B] rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none focus:border-[#86CFFF]"
                />
              </div>

              <div>
                <label className="block text-[11px] font-mono font-bold text-slate-400 uppercase tracking-wider mb-1.5">
                  Venue / Location
                </label>
                <input
                  type="text"
                  placeholder="e.g. Four Seasons Nile Plaza, Cairo"
                  value={venue}
                  onChange={(e) => setVenue(e.target.value)}
                  className="w-full px-3.5 py-2.5 bg-[#0B0D13] border border-[#232A3B] rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none focus:border-[#86CFFF]"
                />
              </div>

              <div>
                <label className="block text-[11px] font-mono font-bold text-slate-400 uppercase tracking-wider mb-1.5">
                  Event Date
                </label>
                <input
                  type="date"
                  value={eventDate}
                  onChange={(e) => setEventDate(e.target.value)}
                  className="w-full px-3.5 py-2.5 bg-[#0B0D13] border border-[#232A3B] rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none focus:border-[#86CFFF]"
                />
              </div>

              <div className="pt-2 flex items-center space-x-3">
                <button
                  type="button"
                  onClick={() => setShowCreateModal(false)}
                  className="flex-1 py-3 rounded-xl bg-[#181D29] border border-[#262F42] text-xs font-bold text-slate-300 hover:text-white"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={creating}
                  className="flex-1 py-3 rounded-xl bg-[#86CFFF] text-[#0B0F17] font-black text-xs uppercase tracking-wider shadow-lg shadow-[#86CFFF]/20 hover:bg-[#9ee2ff] disabled:opacity-50"
                >
                  {creating ? 'Provisioning Drive...' : 'Create Event'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
