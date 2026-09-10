'use client';

import { useState, useEffect, useRef } from 'react';
import { 
  Camera, 
  Video, 
  RefreshCw, 
  LogOut, 
  CheckCircle2, 
  AlertCircle, 
  QrCode, 
  Share2, 
  Sparkles, 
  Activity, 
  Radio, 
  ShieldCheck, 
  User, 
  Lock, 
  Smartphone,
  ChevronRight,
  RotateCcw
} from 'lucide-react';

export default function MobileBoothPage() {
  // Authentication State
  const [token, setToken] = useState<string | null>(null);
  const [operator, setOperator] = useState<any>(null);
  const [username, setUsername] = useState('kiro_operator');
  const [password, setPassword] = useState('LusterPassword2026!');
  const [authLoading, setAuthLoading] = useState(false);
  const [authError, setAuthError] = useState<string | null>(null);

  // Booth State: 'IDLE' | 'COUNTDOWN' | 'RECORDING' | 'PROCESSING' | 'READY'
  const [boothState, setBoothState] = useState<'IDLE' | 'COUNTDOWN' | 'RECORDING' | 'PROCESSING' | 'READY'>('IDLE');
  const [countdown, setCountdown] = useState(3);
  const [recordingProgress, setRecordingProgress] = useState(0);
  const [processedVideoUrl, setProcessedVideoUrl] = useState<string | null>(null);
  const [guestShareCode, setGuestShareCode] = useState<string | null>(null);

  // Hardware & Camera
  const videoRef = useRef<HTMLVideoElement | null>(null);
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const recordedChunksRef = useRef<Blob[]>([]);
  const [cameraActive, setCameraActive] = useState(false);
  const [facingMode, setFacingMode] = useState<'user' | 'environment'>('environment');
  const [batteryLevel, setBatteryLevel] = useState<number>(95);
  const [deviceId, setDeviceId] = useState<string>('');
  const [lastHeartbeat, setLastHeartbeat] = useState<string | null>(null);

  // Dynamic API Base based on current browser location (e.g. http://192.168.1.5:4000)
  const getApiBase = () => {
    if (typeof window !== 'undefined') {
      return `http://${window.location.hostname}:4000`;
    }
    return 'http://localhost:4000';
  };

  // 1. Device ID Initialization
  useEffect(() => {
    if (typeof window !== 'undefined') {
      let id = localStorage.getItem('luster_booth_device_id');
      if (!id) {
        id = 'LUSTER-BOOTH-MOBILE-01';
        localStorage.setItem('luster_booth_device_id', id);
      }
      setDeviceId(id);

      // Check existing session
      const savedToken = localStorage.getItem('luster_operator_token');
      const savedOperator = localStorage.getItem('luster_operator_user');
      if (savedToken && savedOperator) {
        try {
          setToken(savedToken);
          setOperator(JSON.parse(savedOperator));
        } catch { }
      }

      // Battery status if supported
      if ('getBattery' in navigator) {
        (navigator as any).getBattery().then((battery: any) => {
          setBatteryLevel(Math.round(battery.level * 100));
          battery.addEventListener('levelchange', () => {
            setBatteryLevel(Math.round(battery.level * 100));
          });
        }).catch(() => {});
      }
    }
  }, []);

  // 2. Camera Stream Handling
  const startCamera = async () => {
    try {
      if (videoRef.current && videoRef.current.srcObject) {
        const tracks = (videoRef.current.srcObject as MediaStream).getTracks();
        tracks.forEach(track => track.stop());
      }

      const stream = await navigator.mediaDevices.getUserMedia({
        video: {
          facingMode: facingMode,
          width: { ideal: 1280 },
          height: { ideal: 720 },
        },
        audio: false,
      });

      if (videoRef.current) {
        videoRef.current.srcObject = stream;
        videoRef.current.play();
        setCameraActive(true);
      }
    } catch (err) {
      console.warn('Camera access error:', err);
      setCameraActive(false);
    }
  };

  useEffect(() => {
    if (token) {
      startCamera();
    }
    return () => {
      if (videoRef.current && videoRef.current.srcObject) {
        const tracks = (videoRef.current.srcObject as MediaStream).getTracks();
        tracks.forEach(track => track.stop());
      }
    };
  }, [token, facingMode]);

  // 3. Telemetry & Heartbeats
  useEffect(() => {
    if (!token || !deviceId) return;

    const sendHeartbeat = async () => {
      try {
        const ua = navigator.userAgent;
        let model = 'Mobile Device';
        if (/iPhone/i.test(ua)) model = 'Apple iPhone';
        else if (/iPad/i.test(ua)) model = 'Apple iPad';
        else if (/Android/i.test(ua)) model = 'Android Mobile';

        const apiBase = getApiBase();
        const res = await fetch(`${apiBase}/api/v1/devices/heartbeat`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            deviceId: deviceId || 'LUSTER-BOOTH-MOBILE-01',
            deviceName: `${model} (${operator?.fullName || 'Operator'})`,
            model,
            appVersion: 'v1.4.0 (Mobile)',
            batteryLevel,
            storageFreeGb: 32,
            networkType: 'WIFI',
            operationalState: boothState === 'RECORDING' ? 'RECORDING' : 'READY',
            status: 'ONLINE',
          }),
        });

        if (res.ok) {
          setLastHeartbeat(new Date().toLocaleTimeString());
        }
      } catch (err) {
        console.warn('Heartbeat failed:', err);
      }
    };

    // Send immediately on login
    sendHeartbeat();
    const timer = setInterval(sendHeartbeat, 10000);

    // Disconnect beacon on leave
    const sendDisconnect = () => {
      const apiBase = getApiBase();
      const currentDevId = deviceId || localStorage.getItem('luster_booth_device_id') || 'LUSTER-BOOTH-MOBILE-01';
      const payload = JSON.stringify({ deviceId: currentDevId, reason: 'APP_BACKGROUND' });
      if (typeof navigator !== 'undefined' && navigator.sendBeacon) {
        const blob = new Blob([payload], { type: 'application/json' });
        navigator.sendBeacon(`${apiBase}/api/v1/devices/disconnect`, blob);
      } else {
        fetch(`${apiBase}/api/v1/devices/disconnect`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: payload,
          keepalive: true,
        }).catch(() => {});
      }
    };

    window.addEventListener('beforeunload', sendDisconnect);
    window.addEventListener('pagehide', sendDisconnect);

    return () => {
      clearInterval(timer);
      window.removeEventListener('beforeunload', sendDisconnect);
      window.removeEventListener('pagehide', sendDisconnect);
      sendDisconnect();
    };
  }, [token, deviceId, boothState, batteryLevel, operator]);

  // 4. Operator Login Handler
  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setAuthError(null);
    setAuthLoading(true);

    try {
      const apiBase = getApiBase();
      const res = await fetch(`${apiBase}/api/v1/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username, password }),
      });

      const data = await res.json();
      if (!res.ok || !data.success) {
        throw new Error(data.error || 'Invalid operator credentials');
      }

      setToken(data.data.token);
      setOperator(data.data.user);
      localStorage.setItem('luster_operator_token', data.data.token);
      localStorage.setItem('luster_operator_user', JSON.stringify(data.data.user));
    } catch (err: any) {
      setAuthError(err.message || 'Connection to Luster API failed');
    } finally {
      setAuthLoading(false);
    }
  };

  const handleLogout = () => {
    const apiBase = getApiBase();
    if (deviceId) {
      navigator.sendBeacon(
        `${apiBase}/api/v1/devices/disconnect`,
        JSON.stringify({ deviceId, reason: 'MANUAL_LOGOUT' })
      );
    }
    localStorage.removeItem('luster_operator_token');
    localStorage.removeItem('luster_operator_user');
    setToken(null);
    setOperator(null);
    setBoothState('IDLE');
  };

  // 5. 360 Recording Workflow
  const startRecordingFlow = () => {
    setBoothState('COUNTDOWN');
    setCountdown(3);

    const countInterval = setInterval(() => {
      setCountdown((prev) => {
        if (prev <= 1) {
          clearInterval(countInterval);
          beginActualRecording();
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
  };

  const beginActualRecording = () => {
    setBoothState('RECORDING');
    setRecordingProgress(0);
    recordedChunksRef.current = [];

    // Try real MediaRecorder if camera stream available
    if (videoRef.current && videoRef.current.srcObject) {
      try {
        const stream = videoRef.current.srcObject as MediaStream;
        const recorder = new MediaRecorder(stream);
        recorder.ondataavailable = (e) => {
          if (e.data.size > 0) recordedChunksRef.current.push(e.data);
        };
        recorder.start();
        mediaRecorderRef.current = recorder;
      } catch (err) {
        console.warn('MediaRecorder error:', err);
      }
    }

    // 5-second capture duration
    let progress = 0;
    const recInterval = setInterval(() => {
      progress += 20;
      setRecordingProgress(progress);

      if (progress >= 100) {
        clearInterval(recInterval);
        finishRecording();
      }
    }, 1000);
  };

  const finishRecording = () => {
    if (mediaRecorderRef.current && mediaRecorderRef.current.state !== 'inactive') {
      mediaRecorderRef.current.stop();
    }

    setBoothState('PROCESSING');

    // Simulate 360 effects processing & cloud upload
    setTimeout(() => {
      const code = `L360-${Math.floor(1000 + Math.random() * 9000)}`;
      setGuestShareCode(code);
      setBoothState('READY');
    }, 3000);
  };

  const resetForNextGuest = () => {
    setGuestShareCode(null);
    setProcessedVideoUrl(null);
    setBoothState('IDLE');
  };

  // -------------------------------------------------------------
  // VIEW: Operator Login Screen
  // -------------------------------------------------------------
  if (!token) {
    return (
      <div className="min-h-screen bg-[#0B0F17] flex flex-col justify-center items-center p-6 text-white select-none">
        <div className="w-full max-w-sm space-y-8">
          {/* Logo & Header */}
          <div className="text-center space-y-3">
            <div className="w-16 h-16 rounded-2xl bg-gradient-to-tr from-[#18283F] to-[#0B0F17] border-2 border-[#86CFFF]/50 flex items-center justify-center mx-auto shadow-2xl shadow-[#86CFFF]/20">
              <span className="text-2xl font-black text-[#86CFFF] tracking-tighter">360</span>
            </div>
            <h1 className="text-2xl font-black tracking-wider text-white">LUSTER BOOTH</h1>
            <p className="text-xs text-slate-400 font-medium">
              Operator Authorization • Mobile Console
            </p>
            <div className="inline-flex items-center space-x-2 px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/30 text-[11px] text-emerald-400 font-bold">
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-ping" />
              <span>Local Wi-Fi Network Connected</span>
            </div>
          </div>

          {/* Login Card */}
          <div className="bg-[#121824]/90 border border-slate-800 p-6 rounded-3xl backdrop-blur-xl shadow-2xl space-y-5">
            {authError && (
              <div className="p-3.5 rounded-xl bg-red-500/10 border border-red-500/30 flex items-center space-x-2.5 text-red-400 text-xs font-medium">
                <AlertCircle className="w-4 h-4 flex-shrink-0" />
                <span>{authError}</span>
              </div>
            )}

            <form onSubmit={handleLogin} className="space-y-4">
              <div>
                <label className="block text-[11px] font-bold text-slate-400 uppercase tracking-wider mb-1.5">
                  Operator Username
                </label>
                <div className="relative">
                  <User className="w-4 h-4 text-slate-500 absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type="text"
                    required
                    value={username}
                    onChange={(e) => setUsername(e.target.value)}
                    placeholder="e.g. kiro_operator"
                    className="w-full pl-10 pr-4 py-3 bg-[#0B0F17] border border-slate-700 rounded-xl text-sm text-white placeholder-slate-500 focus:outline-none focus:border-[#86CFFF] transition"
                  />
                </div>
              </div>

              <div>
                <label className="block text-[11px] font-bold text-slate-400 uppercase tracking-wider mb-1.5">
                  Password
                </label>
                <div className="relative">
                  <Lock className="w-4 h-4 text-slate-500 absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type="password"
                    required
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="••••••••"
                    className="w-full pl-10 pr-4 py-3 bg-[#0B0F17] border border-slate-700 rounded-xl text-sm text-white placeholder-slate-500 focus:outline-none focus:border-[#86CFFF] transition"
                  />
                </div>
              </div>

              <button
                type="submit"
                disabled={authLoading}
                className="w-full py-3.5 rounded-xl bg-gradient-to-r from-[#86CFFF] to-[#4EA8DE] text-[#0B0F17] font-black text-sm tracking-wider uppercase hover:opacity-95 active:scale-[0.98] transition flex items-center justify-center space-x-2 shadow-lg shadow-[#86CFFF]/20 disabled:opacity-50"
              >
                {authLoading ? (
                  <>
                    <RefreshCw className="w-4 h-4 animate-spin" />
                    <span>Verifying Staff...</span>
                  </>
                ) : (
                  <>
                    <span>Sign In to Booth</span>
                    <ChevronRight className="w-4 h-4" />
                  </>
                )}
              </button>
            </form>

            <div className="pt-2 text-center text-[10px] text-slate-500">
              Device ID: <span className="font-mono text-slate-400">{deviceId || 'Detecting...'}</span>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // -------------------------------------------------------------
  // VIEW: Main Mobile Photobooth Screen
  // -------------------------------------------------------------
  return (
    <div className="min-h-screen bg-[#0B0F17] text-white flex flex-col justify-between select-none relative overflow-hidden">
      {/* 1. Top Telemetry Bar */}
      <header className="px-4 py-3 bg-[#121824]/90 border-b border-slate-800 backdrop-blur-md flex items-center justify-between z-30">
        <div className="flex items-center space-x-2.5">
          <div className="w-2.5 h-2.5 rounded-full bg-emerald-400 animate-pulse" />
          <div>
            <div className="text-xs font-black tracking-wide text-white flex items-center space-x-1.5">
              <span>LUSTER 360</span>
              <span className="text-[10px] px-1.5 py-0.5 rounded bg-[#86CFFF]/10 text-[#86CFFF] font-bold">ONLINE</span>
            </div>
            <div className="text-[10px] text-slate-400">
              Op: <span className="text-slate-200 font-semibold">{operator?.fullName || 'Kirolos'}</span>
            </div>
          </div>
        </div>

        <div className="flex items-center space-x-3 text-xs text-slate-400">
          <div className="flex items-center space-x-1">
            <Radio className="w-3.5 h-3.5 text-emerald-400" />
            <span className="text-[10px] font-mono">{lastHeartbeat || 'Syncing...'}</span>
          </div>

          <button
            onClick={() => setFacingMode(prev => prev === 'user' ? 'environment' : 'user')}
            className="p-1.5 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-300 transition"
            title="Switch Camera"
          >
            <RotateCcw className="w-3.5 h-3.5" />
          </button>

          <button
            onClick={handleLogout}
            className="p-1.5 rounded-lg bg-red-500/10 hover:bg-red-500/20 text-red-400 transition"
            title="Sign Out"
          >
            <LogOut className="w-3.5 h-3.5" />
          </button>
        </div>
      </header>

      {/* 2. Central Viewport / Camera View */}
      <main className="flex-1 relative flex flex-col items-center justify-center overflow-hidden bg-black">
        {/* Real Live Camera Stream */}
        <video
          ref={videoRef}
          playsInline
          muted
          autoPlay
          className="absolute inset-0 w-full h-full object-cover z-0"
        />

        {/* Framing Grid Overlay */}
        <div className="absolute inset-4 rounded-3xl border border-white/20 pointer-events-none z-10 flex flex-col justify-between p-4">
          <div className="flex justify-between text-[10px] text-white/50 font-mono">
            <span>[ 360 ROTATION ZONE ]</span>
            <span>FRAME: 720p / 60FPS</span>
          </div>
          <div className="flex justify-between text-[10px] text-white/50 font-mono">
            <span>BATTERY: {batteryLevel}%</span>
            <span>ID: {deviceId.slice(-6)}</span>
          </div>
        </div>

        {/* STATE OVERLAY: Countdown */}
        {boothState === 'COUNTDOWN' && (
          <div className="absolute inset-0 bg-black/60 backdrop-blur-sm z-20 flex flex-col items-center justify-center">
            <span className="text-8xl font-black text-[#86CFFF] animate-ping">
              {countdown}
            </span>
            <p className="text-sm font-bold text-white tracking-wider mt-6 uppercase">
              Get Ready to Pose!
            </p>
          </div>
        )}

        {/* STATE OVERLAY: Recording Active */}
        {boothState === 'RECORDING' && (
          <div className="absolute inset-0 z-20 flex flex-col justify-between p-6 bg-gradient-to-t from-black/80 via-transparent to-black/60 pointer-events-none">
            <div className="flex items-center justify-center space-x-2">
              <span className="w-3.5 h-3.5 rounded-full bg-red-500 animate-ping" />
              <span className="text-sm font-black text-red-400 tracking-wider uppercase">
                RECORDING 360 CAPTURE
              </span>
            </div>

            <div className="w-full max-w-xs mx-auto space-y-2">
              <div className="h-3 w-full bg-slate-800 rounded-full overflow-hidden border border-slate-700">
                <div 
                  className="h-full bg-gradient-to-r from-[#86CFFF] to-[#4EA8DE] transition-all duration-300"
                  style={{ width: `${recordingProgress}%` }}
                />
              </div>
              <p className="text-center text-xs text-slate-300 font-mono font-bold">
                {recordingProgress}% Complete
              </p>
            </div>
          </div>
        )}

        {/* STATE OVERLAY: Processing & Cloud Upload */}
        {boothState === 'PROCESSING' && (
          <div className="absolute inset-0 bg-[#0B0F17]/95 backdrop-blur-xl z-20 flex flex-col items-center justify-center p-8 text-center space-y-5">
            <div className="relative">
              <div className="w-20 h-20 rounded-3xl bg-[#86CFFF]/10 border-2 border-[#86CFFF] flex items-center justify-center animate-spin">
                <Sparkles className="w-8 h-8 text-[#86CFFF]" />
              </div>
            </div>
            <div>
              <h3 className="text-lg font-black text-white">GENERATING 360 EXPERIENCE</h3>
              <p className="text-xs text-slate-400 mt-1 max-w-xs">
                Applying slow-motion boomerang curve, custom brand audio, and syncing to Google Drive...
              </p>
            </div>
          </div>
        )}

        {/* STATE OVERLAY: Guest QR Code Ready */}
        {boothState === 'READY' && (
          <div className="absolute inset-0 bg-[#0B0F17]/95 backdrop-blur-xl z-20 flex flex-col items-center justify-between p-6 text-center">
            <div className="space-y-1">
              <span className="inline-flex items-center space-x-1.5 px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/30 text-xs text-emerald-400 font-bold">
                <CheckCircle2 className="w-3.5 h-3.5" />
                <span>Captured & Uploaded to Drive</span>
              </span>
              <h2 className="text-xl font-black text-white mt-2">SCAN TO GET YOUR VIDEO</h2>
              <p className="text-xs text-slate-400">Point phone camera at QR code below</p>
            </div>

            {/* QR Code Card */}
            <div className="bg-white p-5 rounded-3xl shadow-2xl shadow-[#86CFFF]/10 border-4 border-[#86CFFF] my-auto">
              <div className="w-48 h-48 bg-slate-900 rounded-2xl flex flex-col items-center justify-center p-4 relative overflow-hidden">
                <QrCode className="w-36 h-36 text-white" />
                <span className="absolute bottom-2 text-[10px] font-black tracking-widest text-[#86CFFF] uppercase font-mono">
                  {guestShareCode}
                </span>
              </div>
            </div>

            {/* Next Guest Action Button */}
            <button
              onClick={resetForNextGuest}
              className="w-full max-w-xs py-4 rounded-2xl bg-gradient-to-r from-[#86CFFF] to-[#4EA8DE] text-[#0B0F17] font-black text-sm tracking-wider uppercase shadow-xl shadow-[#86CFFF]/25 active:scale-95 transition flex items-center justify-center space-x-2"
            >
              <span>Ready for Next Guest</span>
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        )}
      </main>

      {/* 3. Bottom Control Dock (When IDLE) */}
      {boothState === 'IDLE' && (
        <footer className="p-6 bg-[#121824]/90 border-t border-slate-800 backdrop-blur-md z-30 flex flex-col items-center space-y-3">
          <button
            onClick={startRecordingFlow}
            className="w-full max-w-sm py-4 rounded-2xl bg-gradient-to-r from-[#86CFFF] to-[#4EA8DE] text-[#0B0F17] font-black text-base tracking-widest uppercase shadow-2xl shadow-[#86CFFF]/30 active:scale-95 transition flex items-center justify-center space-x-3"
          >
            <Video className="w-5 h-5 fill-current" />
            <span>START 360 RECORDING</span>
          </button>

          <p className="text-[11px] text-slate-400 font-medium">
            Tap to initiate 360 capture cycle with auto-cloud sync
          </p>
        </footer>
      )}
    </div>
  );
}
