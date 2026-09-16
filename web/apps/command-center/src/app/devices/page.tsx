'use client';

import { useState, useEffect } from 'react';
import { Smartphone, Battery, HardDrive, Wifi, Radio, RefreshCw } from 'lucide-react';

interface Device {
  id: string;
  device_identifier: string;
  device_name: string;
  calculatedStatus: 'ONLINE' | 'OFFLINE';
  currentState: string;
  battery_level?: number;
  is_charging?: boolean;
  storage_free_bytes?: number;
  storage_total_bytes?: number;
  platform?: string;
  app_version?: string;
  last_heartbeat?: string;
  secondsSinceHeartbeat?: number;
}

export default function DevicesPage() {
  const [devices, setDevices] = useState<Device[]>([]);
  const [loading, setLoading] = useState(true);

  // Relative URL routes through Next.js rewrites to backend port 4000 seamlessly
  const apiUrl = '';

  const fetchDevices = async () => {
    try {
      const res = await fetch(`${apiUrl}/api/v1/devices/fleet`);
      const data = await res.json();
      if (data.success) {
        setDevices(data.data || []);
      }
    } catch {
      // Ignore network hiccup
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDevices();
    const interval = setInterval(fetchDevices, 3000);
    return () => clearInterval(interval);
  }, []);

  const onlineCount = devices.filter(d => d.calculatedStatus === 'ONLINE').length;

  return (
    <div className="p-8 space-y-8">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-black tracking-tight text-luster-text">HARDWARE FLEET MONITOR</h1>
          <p className="text-xs text-luster-textMuted mt-1">
            Real-time device heartbeats, battery telemetry, and operational presence
          </p>
        </div>
        <div className="flex items-center space-x-3">
          <span className="text-xs font-mono font-bold text-luster-accent">
            {onlineCount} Online / {devices.length} Registered
          </span>
          <button
            onClick={fetchDevices}
            className="p-2 rounded-xl bg-luster-panel border border-luster-border hover:border-luster-borderLight text-luster-textMuted hover:text-luster-text transition"
          >
            <RefreshCw className="w-4 h-4" />
          </button>
        </div>
      </div>

      {/* Android Mobile App Installation Banner */}
      <div className="p-6 rounded-2xl bg-gradient-to-r from-luster-header/80 via-luster-panel to-luster-surface border border-luster-accent/30 flex flex-col md:flex-row items-center justify-between gap-6 shadow-xl shadow-black/40">
        <div className="flex items-center space-x-5">
          <div className="w-24 h-24 bg-white p-2 rounded-xl flex items-center justify-center shrink-0 shadow-lg">
            <img
              src="https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=http://192.168.1.6:3001/luster360.apk"
              alt="Scan to Download APK"
              className="w-full h-full object-contain"
            />
          </div>
          <div className="space-y-1.5">
            <div className="flex items-center space-x-2">
              <span className="px-2 py-0.5 rounded text-[10px] font-black bg-luster-accent text-luster-header tracking-wider uppercase">
                Release v1.0.0
              </span>
              <span className="text-xs font-mono text-luster-success font-bold">● APK READY</span>
            </div>
            <h2 className="text-base font-black text-luster-text tracking-wide">
              INSTALL LUSTER 360 ON YOUR ANDROID PHONE
            </h2>
            <p className="text-xs text-luster-textMuted max-w-lg leading-relaxed">
              Scan this QR code with your phone camera or download directly. Once installed, log in with operator credentials to link camera telemetry, hardware controls, and cloud uploads.
            </p>
            <p className="text-[11px] font-mono text-luster-accent">
              Direct Phone URL: <span className="underline select-all">http://192.168.1.6:3001/luster360.apk</span>
            </p>
          </div>
        </div>
        <div className="flex flex-col sm:flex-row items-center gap-3 shrink-0">
          <a
            href="/luster360.apk"
            download="Luster-360-v1.0.0.apk"
            className="px-5 py-3 rounded-xl bg-luster-accent text-luster-header font-black text-xs tracking-wider flex items-center space-x-2 hover:bg-luster-accent/90 transition shadow-lg shadow-luster-accent/20"
          >
            <Smartphone className="w-4 h-4" />
            <span>DOWNLOAD APK (53.6 MB)</span>
          </a>
        </div>
      </div>

      {loading ? (
        <div className="p-16 text-center text-xs text-luster-textMuted">Loading live fleet telemetry...</div>
      ) : devices.length === 0 ? (
        <div className="p-16 rounded-2xl bg-luster-panel border border-dashed border-luster-border text-center space-y-3">
          <Smartphone className="w-10 h-10 text-luster-textDark mx-auto" />
          <h3 className="text-sm font-bold text-luster-text">0 Booths Connected</h3>
          <p className="text-xs text-luster-textMuted max-w-sm mx-auto">
            When an operator logs into the LUSTER 360 mobile app on an Android phone, the device will appear here instantly.
          </p>
        </div>
      ) : (
        <div className="space-y-4">
          {devices.map((d) => {
            const isOnline = d.calculatedStatus === 'ONLINE';
            const freeGb = d.storage_free_bytes ? `${(d.storage_free_bytes / (1024 * 1024 * 1024)).toFixed(1)} GB free` : 'N/A';
            const totalGb = d.storage_total_bytes ? `${(d.storage_total_bytes / (1024 * 1024 * 1024)).toFixed(0)} GB` : '';

            return (
              <div
                key={d.id}
                className={`p-6 rounded-2xl bg-luster-panel border transition ${
                  isOnline ? 'border-luster-border hover:border-luster-borderLight' : 'border-luster-border/40 opacity-70'
                }`}
              >
                <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                  {/* Left Info */}
                  <div className="flex items-start space-x-4">
                    <div className="w-12 h-12 rounded-xl bg-luster-header border border-luster-border flex items-center justify-center text-luster-accent">
                      <Smartphone className="w-6 h-6" />
                    </div>
                    <div>
                      <div className="flex items-center space-x-3">
                        <h2 className="text-sm font-bold text-luster-text">{d.device_name}</h2>
                        <span
                          className={`inline-flex items-center space-x-1.5 px-2.5 py-0.5 rounded-full text-[10px] font-bold ${
                            isOnline
                              ? 'bg-luster-success/20 text-luster-success border border-luster-success/30'
                              : 'bg-luster-surface text-luster-textDark'
                          }`}
                        >
                          <span className={`w-1.5 h-1.5 rounded-full ${isOnline ? 'bg-luster-success animate-pulse' : 'bg-luster-danger'}`} />
                          <span>{isOnline ? 'ONLINE' : 'OFFLINE'}</span>
                        </span>
                      </div>
                      <div className="flex items-center space-x-4 text-[11px] text-luster-textDark mt-1 font-mono">
                        <span>ID: {d.device_identifier}</span>
                        <span>•</span>
                        <span>{d.platform}</span>
                        <span>•</span>
                        <span>v{d.app_version || '1.0.0'}</span>
                      </div>
                    </div>
                  </div>

                  {/* Right Telemetry */}
                  <div className="flex items-center space-x-6 text-xs text-luster-textMuted">
                    {/* Battery */}
                    <div className="flex items-center space-x-2">
                      <Battery className={`w-4 h-4 ${isOnline ? 'text-luster-success' : 'text-luster-textDark'}`} />
                      <span className="font-mono">{d.battery_level !== undefined && d.battery_level !== null ? `${d.battery_level}%` : 'N/A'}</span>
                    </div>

                    {/* Storage */}
                    <div className="flex items-center space-x-2">
                      <HardDrive className="w-4 h-4 text-luster-accent" />
                      <span className="font-mono">{freeGb} {totalGb ? `/ ${totalGb}` : ''}</span>
                    </div>

                    {/* Last Heartbeat */}
                    <div className="text-right">
                      <span className="text-[10px] block text-luster-textDark font-bold uppercase">LAST SEEN</span>
                      <span className="text-[11px] font-mono text-luster-text">
                        {d.secondsSinceHeartbeat !== null && d.secondsSinceHeartbeat !== undefined
                          ? d.secondsSinceHeartbeat < 10
                            ? 'Just now'
                            : `${d.secondsSinceHeartbeat}s ago`
                          : 'Never'}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
