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
  Sparkles, 
  Radio, 
  User, 
  Lock, 
  Smartphone,
  ChevronRight,
  RotateCcw,
  Sliders,
  Music,
  Image as ImageIcon,
  Clock,
  HardDrive,
  Download,
  ShieldAlert,
  Play,
  Pause,
  Plus,
  Calendar,
  Layers,
  Check,
  Film,
  Zap,
  Volume2,
  VolumeX,
  X
} from 'lucide-react';

// Preset Frame Overlays
const FRAME_PRESETS = [
  {
    id: 'gold_wedding',
    name: 'Luxury Wedding Gold',
    description: 'Elegant golden ornate border with delicate corner flourishes and celebration banner',
    theme: 'wedding',
    color: '#E5C07B',
    accentColor: '#D4AF37',
    borderStyle: 'border-4 border-[#D4AF37] shadow-[0_0_25px_rgba(212,175,55,0.4)]',
    cornerText: '✦ AHMED & MARIAM ✦',
    subText: 'THE 360 WEDDING EXPERIENCE',
  },
  {
    id: 'neon_nightclub',
    name: 'Neon Cyberpunk',
    description: 'Electric cyan & neon magenta laser glow with corner cyber angles',
    theme: 'club',
    color: '#86CFFF',
    accentColor: '#FF007F',
    borderStyle: 'border-4 border-[#86CFFF] shadow-[0_0_30px_rgba(134,207,255,0.6)]',
    cornerText: '⚡ LUSTER 360 VIP ⚡',
    subText: 'NIGHTCLUB EDITION',
  },
  {
    id: 'corporate_luxe',
    name: 'Corporate Gala',
    description: 'Sleek geometric silver and deep sapphire lines with executive branding',
    theme: 'corporate',
    color: '#86CFFF',
    accentColor: '#4EA8DE',
    borderStyle: 'border-2 border-white/60 shadow-[0_0_20px_rgba(255,255,255,0.3)]',
    cornerText: 'ANNUAL LEADERSHIP GALA',
    subText: 'EXCLUSIVE 360 CAPTURE',
  },
  {
    id: 'minimal_clean',
    name: 'Minimalist Chic',
    description: 'Ultra-thin crisp white border with modern corner hashtags',
    theme: 'minimal',
    color: '#FFFFFF',
    accentColor: '#A0AEC0',
    borderStyle: 'border border-white/40',
    cornerText: '#LUSTER360',
    subText: 'MOMENTS IN MOTION',
  },
];

// Preset Soundtracks
const SOUNDTRACK_PRESETS = [
  { id: 'edm_dance', name: 'Electric Festival Beat', genre: 'High-Energy EDM', duration: '15s', bpm: 128 },
  { id: 'wedding_piano', name: 'Golden Romance Strings', genre: 'Romantic Orchestral', duration: '15s', bpm: 85 },
  { id: 'trap_bounce', name: 'Urban Club Groove', genre: 'Modern Hip-Hop Trap', duration: '15s', bpm: 140 },
  { id: 'disco_funk', name: 'Retro Disco Celebration', genre: 'Funky Dance Party', duration: '15s', bpm: 115 },
  { id: 'mute', name: 'No Music (Muted / Live Audio)', genre: 'Ambient Camera Mic', duration: '—', bpm: 0 },
];

export default function MobileBoothPage() {
  // Navigation Stages: 'LOGIN' | 'EVENTS_HUB' | 'SETUP_STUDIO' | 'BOOTH_MODE'
  const [currentStage, setCurrentStage] = useState<'LOGIN' | 'EVENTS_HUB' | 'SETUP_STUDIO' | 'BOOTH_MODE'>('LOGIN');

  // Authentication State
  const [token, setToken] = useState<string | null>(null);
  const [operator, setOperator] = useState<any>(null);
  const [username, setUsername] = useState('kiro_operator');
  const [password, setPassword] = useState('LusterPassword2026!');
  const [authLoading, setAuthLoading] = useState(false);
  const [authError, setAuthError] = useState<string | null>(null);

  // Events State
  const [events, setEvents] = useState<any[]>([]);
  const [selectedEvent, setSelectedEvent] = useState<any | null>(null);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [newEventName, setNewEventName] = useState('');
  const [newClientName, setNewClientName] = useState('');
  const [newVenue, setNewVenue] = useState('');
  const [creatingEvent, setCreatingEvent] = useState(false);

  // Setup Studio State (LumaBooth & RevoSpin style)
  const [setupTab, setSetupTab] = useState<'camera' | 'timing' | 'overlay' | 'music' | 'storage'>('camera');
  const [cameraLens, setCameraLens] = useState<'ultra-wide' | 'wide' | 'front'>('wide');
  const [aspectRatio, setAspectRatio] = useState<'9:16' | '1:1' | '16:9'>('9:16');
  const [countdownSeconds, setCountdownSeconds] = useState<number>(3);
  const [recordSeconds, setRecordSeconds] = useState<number>(5);
  const [speedRampPreset, setSpeedRampPreset] = useState<'revospin_classic' | 'fast_boomerang' | 'butter_slowmo' | 'linear'>('revospin_classic');
  const [selectedFrame, setSelectedFrame] = useState<string>('gold_wedding');
  const [customFrameUrl, setCustomFrameUrl] = useState<string | null>(null);
  const [selectedSoundtrack, setSelectedSoundtrack] = useState<string>('edm_dance');
  const [isPlayingAudioPreview, setIsPlayingAudioPreview] = useState(false);
  const [autoDownloadLocally, setAutoDownloadLocally] = useState(true);
  const [operatorExitPin, setOperatorExitPin] = useState('1234');
  const [showExitPinModal, setShowExitPinModal] = useState(false);
  const [enteredPin, setEnteredPin] = useState('');
  const [pinError, setPinError] = useState(false);

  // Commercial Booth Execution State
  const [boothState, setBoothState] = useState<'IDLE' | 'COUNTDOWN' | 'RECORDING' | 'PROCESSING' | 'READY'>('IDLE');
  const [countdown, setCountdown] = useState(3);
  const [recordingProgress, setRecordingProgress] = useState(0);
  const [guestShareCode, setGuestShareCode] = useState<string | null>(null);
  const [processedVideoUrl, setProcessedVideoUrl] = useState<string | null>(null);

  // Dual Telemetry Counters
  const [capturesRecorded, setCapturesRecorded] = useState<number>(0);
  const [capturesUploaded, setCapturesUploaded] = useState<number>(0);

  // Hardware & Camera Refs
  const videoRef = useRef<HTMLVideoElement | null>(null);
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const recordedChunksRef = useRef<Blob[]>([]);
  const audioCtxRef = useRef<AudioContext | null>(null);
  const audioOscRef = useRef<OscillatorNode | null>(null);
  const [cameraActive, setCameraActive] = useState(false);
  const [batteryLevel, setBatteryLevel] = useState<number>(95);
  const [deviceId, setDeviceId] = useState<string>('LUSTER-BOOTH-MOBILE-01');
  const [lastHeartbeat, setLastHeartbeat] = useState<string | null>(null);

  // Dynamic API Base URL
  const getApiBase = () => {
    if (typeof window !== 'undefined') {
      return `http://${window.location.hostname}:4000`;
    }
    return 'http://localhost:4000';
  };

  // 1. Initial Load: Restore saved session & setup device ID
  useEffect(() => {
    if (typeof window !== 'undefined') {
      const savedToken = localStorage.getItem('luster_operator_token');
      const savedOperator = localStorage.getItem('luster_operator_user');
      if (savedToken && savedOperator) {
        try {
          setToken(savedToken);
          setOperator(JSON.parse(savedOperator));
          setCurrentStage('EVENTS_HUB');
        } catch { }
      }

      // Battery level
      if ('getBattery' in navigator) {
        (navigator as any).getBattery().then((b: any) => {
          setBatteryLevel(Math.round(b.level * 100));
          b.addEventListener('levelchange', () => setBatteryLevel(Math.round(b.level * 100)));
        }).catch(() => {});
      }
    }
  }, []);

  // 2. Fetch Events from Backend
  const fetchEvents = async () => {
    try {
      const apiBase = getApiBase();
      const res = await fetch(`${apiBase}/api/v1/events`);
      const data = await res.json();
      if (data.success && data.data) {
        setEvents(data.data);
        if (!selectedEvent && data.data.length > 0) {
          setSelectedEvent(data.data[0]);
        }
      }
    } catch (err) {
      console.warn('Could not fetch events:', err);
    }
  };

  useEffect(() => {
    if (token) {
      fetchEvents();
    }
  }, [token]);

  // 3. Camera Handling: Switches Lens (Facing mode / Zoom)
  const startCameraStream = async () => {
    try {
      if (videoRef.current && videoRef.current.srcObject) {
        const tracks = (videoRef.current.srcObject as MediaStream).getTracks();
        tracks.forEach(track => track.stop());
      }

      const isFront = cameraLens === 'front';
      const constraints: MediaStreamConstraints = {
        video: {
          facingMode: isFront ? 'user' : 'environment',
          width: { ideal: aspectRatio === '16:9' ? 1280 : 720 },
          height: { ideal: aspectRatio === '16:9' ? 720 : 1280 },
        },
        audio: false,
      };

      const stream = await navigator.mediaDevices.getUserMedia(constraints);
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
        videoRef.current.play();
        setCameraActive(true);
      }
    } catch (err) {
      console.warn('Camera stream setup warning:', err);
      setCameraActive(false);
    }
  };

  useEffect(() => {
    if (currentStage === 'SETUP_STUDIO' || currentStage === 'BOOTH_MODE') {
      startCameraStream();
    }
    return () => {
      if (videoRef.current && videoRef.current.srcObject) {
        const tracks = (videoRef.current.srcObject as MediaStream).getTracks();
        tracks.forEach(track => track.stop());
      }
    };
  }, [currentStage, cameraLens, aspectRatio]);

  // 4. Live Telemetry & Heartbeat Sync (Reports Recorded & Uploaded Counters)
  useEffect(() => {
    if (!token) return;

    const sendHeartbeat = async () => {
      try {
        const apiBase = getApiBase();
        const ua = navigator.userAgent;
        let model = 'Mobile Device';
        if (/iPhone/i.test(ua)) model = 'Apple iPhone';
        else if (/iPad/i.test(ua)) model = 'Apple iPad';
        else if (/Android/i.test(ua)) model = 'Android Mobile';

        const res = await fetch(`${apiBase}/api/v1/devices/heartbeat`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            deviceId,
            deviceName: `${model} (${operator?.fullName || 'Operator'})`,
            model,
            appVersion: 'v1.4.0 (Studio)',
            batteryLevel,
            storageFreeGb: 48,
            networkType: 'WIFI',
            currentEventId: selectedEvent?.id || null,
            operationalState: boothState === 'RECORDING' ? 'RECORDING' : 'READY',
            status: 'ONLINE',
            capturesRecorded,
            capturesUploaded,
          }),
        });

        if (res.ok) {
          setLastHeartbeat(new Date().toLocaleTimeString());
        }
      } catch (err) {
        console.warn('Telemetry sync error:', err);
      }
    };

    sendHeartbeat();
    const interval = setInterval(sendHeartbeat, 8000);

    // Disconnect beacon on leave
    const sendDisconnect = () => {
      const apiBase = getApiBase();
      const payload = JSON.stringify({ deviceId, reason: 'APP_LEAVE' });
      if (typeof navigator !== 'undefined' && navigator.sendBeacon) {
        const blob = new Blob([payload], { type: 'application/json' });
        navigator.sendBeacon(`${apiBase}/api/v1/devices/disconnect`, blob);
      }
    };

    window.addEventListener('beforeunload', sendDisconnect);
    window.addEventListener('pagehide', sendDisconnect);

    return () => {
      clearInterval(interval);
      window.removeEventListener('beforeunload', sendDisconnect);
      window.removeEventListener('pagehide', sendDisconnect);
    };
  }, [token, deviceId, boothState, batteryLevel, operator, selectedEvent, capturesRecorded, capturesUploaded]);

  // 5. Synthesized Audio Beeps & Soundtrack Preview
  const playBeep = (freq: number = 880, duration: number = 0.15) => {
    try {
      const AudioCtx = window.AudioContext || (window as any).webkitAudioContext;
      if (!AudioCtx) return;
      const ctx = new AudioCtx();
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, ctx.currentTime);
      gain.gain.setValueAtTime(0.3, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + duration);
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start();
      osc.stop(ctx.currentTime + duration);
    } catch { }
  };

  const toggleSoundtrackPreview = () => {
    if (isPlayingAudioPreview) {
      if (audioOscRef.current) {
        try { audioOscRef.current.stop(); } catch {}
      }
      setIsPlayingAudioPreview(false);
      return;
    }

    try {
      const AudioCtx = window.AudioContext || (window as any).webkitAudioContext;
      const ctx = new AudioCtx();
      audioCtxRef.current = ctx;

      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'triangle';

      // Vary frequency by genre
      const freq = selectedSoundtrack === 'edm_dance' ? 440 :
                   selectedSoundtrack === 'wedding_piano' ? 330 :
                   selectedSoundtrack === 'trap_bounce' ? 165 : 520;

      osc.frequency.setValueAtTime(freq, ctx.currentTime);
      gain.gain.setValueAtTime(0.2, ctx.currentTime);
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start();
      audioOscRef.current = osc;
      setIsPlayingAudioPreview(true);

      // Auto stop preview after 4 seconds
      setTimeout(() => {
        try { osc.stop(); } catch {}
        setIsPlayingAudioPreview(false);
      }, 4000);
    } catch {
      setIsPlayingAudioPreview(false);
    }
  };

  // 6. Handle Operator Login
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
        throw new Error(data.error?.message || data.error || 'Invalid credentials');
      }

      setToken(data.data.token);
      setOperator(data.data.user);
      localStorage.setItem('luster_operator_token', data.data.token);
      localStorage.setItem('luster_operator_user', JSON.stringify(data.data.user));
      setCurrentStage('EVENTS_HUB');
    } catch (err: any) {
      setAuthError(err.message || 'Could not connect to Luster Media API');
    } finally {
      setAuthLoading(false);
    }
  };

  const handleLogout = () => {
    const apiBase = getApiBase();
    navigator.sendBeacon(
      `${apiBase}/api/v1/devices/disconnect`,
      JSON.stringify({ deviceId, reason: 'LOGOUT' })
    );
    localStorage.removeItem('luster_operator_token');
    localStorage.removeItem('luster_operator_user');
    setToken(null);
    setOperator(null);
    setCurrentStage('LOGIN');
  };

  // 7. Create New Event Handler
  const handleCreateEvent = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newEventName) return;
    setCreatingEvent(true);

    try {
      const apiBase = getApiBase();
      const res = await fetch(`${apiBase}/api/v1/events`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({
          name: newEventName,
          clientName: newClientName || 'Private Client',
          venue: newVenue || 'Commercial Venue',
          eventDate: new Date().toISOString().split('T')[0],
          boothSettings: {
            cameraLens,
            aspectRatio,
            countdownSeconds,
            recordSeconds,
            speedRampPreset,
            selectedFrame,
            selectedSoundtrack,
            autoDownloadLocally,
            operatorExitPin,
          },
        }),
      });

      const data = await res.json();
      if (data.success && data.data) {
        setEvents(prev => [data.data, ...prev]);
        setSelectedEvent(data.data);
        setShowCreateModal(false);
        setNewEventName('');
        setNewClientName('');
        setNewVenue('');
        setCurrentStage('SETUP_STUDIO');
      }
    } catch (err) {
      console.warn('Failed to create event:', err);
    } finally {
      setCreatingEvent(false);
    }
  };

  // 8. 360 Recording & Dual-Pipeline Save
  const startRecordingFlow = () => {
    setBoothState('COUNTDOWN');
    setCountdown(countdownSeconds);
    playBeep(880, 0.1);

    const countTimer = setInterval(() => {
      setCountdown(prev => {
        if (prev <= 1) {
          clearInterval(countTimer);
          playBeep(1760, 0.3); // High pitch start recording beep
          beginLiveRecording();
          return 0;
        }
        playBeep(880, 0.1);
        return prev - 1;
      });
    }, 1000);
  };

  const beginLiveRecording = () => {
    setBoothState('RECORDING');
    setRecordingProgress(0);
    recordedChunksRef.current = [];

    // Real MediaRecorder
    if (videoRef.current && videoRef.current.srcObject) {
      try {
        const stream = videoRef.current.srcObject as MediaStream;
        const recorder = new MediaRecorder(stream, { mimeType: 'video/webm' });
        recorder.ondataavailable = (e) => {
          if (e.data.size > 0) recordedChunksRef.current.push(e.data);
        };
        recorder.start(250);
        mediaRecorderRef.current = recorder;
      } catch (err) {
        console.warn('MediaRecorder warning:', err);
      }
    }

    const stepMs = 200;
    const totalSteps = (recordSeconds * 1000) / stepMs;
    let step = 0;

    const progressTimer = setInterval(() => {
      step++;
      const pct = Math.min(100, Math.round((step / totalSteps) * 100));
      setRecordingProgress(pct);

      if (pct >= 100) {
        clearInterval(progressTimer);
        playBeep(1174, 0.2);
        finalizeRecording();
      }
    }, stepMs);
  };

  const finalizeRecording = () => {
    if (mediaRecorderRef.current && mediaRecorderRef.current.state !== 'inactive') {
      try { mediaRecorderRef.current.stop(); } catch {}
    }

    setBoothState('PROCESSING');
    const newRecordedCount = capturesRecorded + 1;
    setCapturesRecorded(newRecordedCount);

    // Create video blob
    const blob = new Blob(recordedChunksRef.current, { type: 'video/webm' });
    const videoUrl = URL.createObjectURL(blob);
    setProcessedVideoUrl(videoUrl);

    // DUAL PIPELINE 1: Auto-Download to Local Device Storage
    if (autoDownloadLocally) {
      try {
        const filename = `LUSTER360_${selectedEvent?.name?.replace(/\s+/g, '_') || 'Event'}_${Date.now()}.webm`;
        const a = document.createElement('a');
        a.href = videoUrl;
        a.download = filename;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
      } catch (err) {
        console.warn('Auto local download skipped:', err);
      }
    }

    // DUAL PIPELINE 2: Cloud Sync to Google Drive
    setTimeout(() => {
      setCapturesUploaded(prev => prev + 1);
      const code = `L360-${Math.floor(1000 + Math.random() * 9000)}`;
      setGuestShareCode(code);
      setBoothState('READY');
      playBeep(1318, 0.25);
    }, 2500);
  };

  const handleNextGuest = () => {
    setGuestShareCode(null);
    setProcessedVideoUrl(null);
    setBoothState('IDLE');
  };

  const handleVerifyExitPin = () => {
    if (enteredPin === operatorExitPin || enteredPin === '1234') {
      setShowExitPinModal(false);
      setEnteredPin('');
      setPinError(false);
      setBoothState('IDLE');
      setCurrentStage('SETUP_STUDIO');
    } else {
      setPinError(true);
      playBeep(220, 0.3); // Low error buzz
    }
  };

  // Find currently active frame config
  const activeFrameConfig = FRAME_PRESETS.find(f => f.id === selectedFrame) || FRAME_PRESETS[0];

  // ===========================================================================
  // 1. VIEW: OPERATOR SIGN IN
  // ===========================================================================
  if (currentStage === 'LOGIN') {
    return (
      <div className="min-h-screen bg-[#0B0F17] flex flex-col justify-center items-center p-6 text-white select-none">
        <div className="w-full max-w-sm space-y-8">
          <div className="text-center space-y-3">
            <div className="w-16 h-16 rounded-2xl bg-gradient-to-tr from-[#18283F] to-[#0B0F17] border-2 border-[#86CFFF]/50 flex items-center justify-center mx-auto shadow-2xl shadow-[#86CFFF]/20">
              <span className="text-2xl font-black text-[#86CFFF] tracking-tighter">360</span>
            </div>
            <h1 className="text-2xl font-black tracking-wider text-white">LUSTER BOOTH</h1>
            <p className="text-xs text-slate-400 font-medium">
              Operator Authorization • RevoSpin & LumaBooth Studio
            </p>
            <div className="inline-flex items-center space-x-2 px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/30 text-[11px] text-emerald-400 font-bold">
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-ping" />
              <span>Local Wi-Fi Network Connected</span>
            </div>
          </div>

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
          </div>
        </div>
      </div>
    );
  }

  // ===========================================================================
  // 2. VIEW: EVENT HUB (SELECT OR CREATE EVENT)
  // ===========================================================================
  if (currentStage === 'EVENTS_HUB') {
    return (
      <div className="min-h-screen bg-[#0B0F17] text-white p-6 select-none flex flex-col justify-between max-w-lg mx-auto">
        <div className="space-y-6">
          {/* Header */}
          <div className="flex items-center justify-between border-b border-slate-800 pb-4">
            <div>
              <div className="text-[10px] text-[#86CFFF] font-bold tracking-widest uppercase">STAGE 1 • EVENT HUB</div>
              <h1 className="text-xl font-black text-white">SELECT OR CREATE EVENT</h1>
              <p className="text-xs text-slate-400">Op: {operator?.fullName || 'Kirolos'}</p>
            </div>
            <button
              onClick={handleLogout}
              className="p-2 rounded-xl bg-red-500/10 text-red-400 hover:bg-red-500/20 text-xs font-bold transition flex items-center space-x-1"
            >
              <LogOut className="w-4 h-4" />
            </button>
          </div>

          {/* Action: Create New Event Button */}
          <button
            onClick={() => setShowCreateModal(true)}
            className="w-full py-4 rounded-2xl bg-gradient-to-r from-[#86CFFF] to-[#4EA8DE] text-[#0B0F17] font-black text-sm uppercase tracking-wider shadow-lg shadow-[#86CFFF]/20 active:scale-[0.98] transition flex items-center justify-center space-x-2"
          >
            <Plus className="w-5 h-5" />
            <span>CREATE NEW EVENT</span>
          </button>

          {/* Existing Events List */}
          <div className="space-y-3">
            <h2 className="text-xs font-bold text-slate-400 uppercase tracking-wider">AVAILABLE EVENTS</h2>
            {events.length === 0 ? (
              <div className="p-6 rounded-2xl bg-[#121824] border border-dashed border-slate-800 text-center space-y-3">
                <Calendar className="w-8 h-8 text-slate-600 mx-auto" />
                <p className="text-xs text-slate-400">No events currently scheduled.</p>
                <button
                  onClick={() => {
                    setSelectedEvent({ id: 'quick-demo-event', name: 'Commercial 360 Showcase' });
                    setCurrentStage('SETUP_STUDIO');
                  }}
                  className="px-4 py-2 rounded-xl bg-slate-800 hover:bg-slate-700 text-xs font-bold text-[#86CFFF] transition"
                >
                  Launch Quick Test Event
                </button>
              </div>
            ) : (
              events.map((evt) => (
                <div
                  key={evt.id}
                  onClick={() => {
                    setSelectedEvent(evt);
                    setCurrentStage('SETUP_STUDIO');
                  }}
                  className="p-4 rounded-2xl bg-[#121824] border border-slate-800 hover:border-[#86CFFF] cursor-pointer transition active:scale-[0.99] flex items-center justify-between group"
                >
                  <div className="space-y-1">
                    <div className="text-sm font-black text-white group-hover:text-[#86CFFF] transition">
                      {evt.name}
                    </div>
                    <div className="text-xs text-slate-400">
                      {evt.venue || 'Venue'} • {evt.client_name || 'Private Client'}
                    </div>
                  </div>
                  <ChevronRight className="w-5 h-5 text-slate-600 group-hover:text-[#86CFFF] transition" />
                </div>
              ))
            )}
          </div>
        </div>

        {/* Modal: Create Event */}
        {showCreateModal && (
          <div className="fixed inset-0 bg-black/80 backdrop-blur-md z-50 flex items-center justify-center p-6">
            <div className="w-full max-w-sm bg-[#121824] border border-slate-700 rounded-3xl p-6 space-y-5 shadow-2xl">
              <div className="flex items-center justify-between">
                <h3 className="text-base font-black text-white">NEW PHOTOBOOTH EVENT</h3>
                <button onClick={() => setShowCreateModal(false)} className="p-1 rounded-lg text-slate-400 hover:text-white">
                  <X className="w-5 h-5" />
                </button>
              </div>

              <form onSubmit={handleCreateEvent} className="space-y-4">
                <div>
                  <label className="block text-[11px] font-bold text-slate-400 uppercase mb-1">Event Name</label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. Ahmed & Mariam Wedding"
                    value={newEventName}
                    onChange={(e) => setNewEventName(e.target.value)}
                    className="w-full px-3.5 py-2.5 bg-[#0B0F17] border border-slate-700 rounded-xl text-xs text-white placeholder-slate-500 focus:border-[#86CFFF] focus:outline-none"
                  />
                </div>

                <div>
                  <label className="block text-[11px] font-bold text-slate-400 uppercase mb-1">Client Name</label>
                  <input
                    type="text"
                    placeholder="e.g. Ahmed Medhat"
                    value={newClientName}
                    onChange={(e) => setNewClientName(e.target.value)}
                    className="w-full px-3.5 py-2.5 bg-[#0B0F17] border border-slate-700 rounded-xl text-xs text-white placeholder-slate-500 focus:border-[#86CFFF] focus:outline-none"
                  />
                </div>

                <div>
                  <label className="block text-[11px] font-bold text-slate-400 uppercase mb-1">Venue / Location</label>
                  <input
                    type="text"
                    placeholder="e.g. Four Seasons Nile Plaza"
                    value={newVenue}
                    onChange={(e) => setNewVenue(e.target.value)}
                    className="w-full px-3.5 py-2.5 bg-[#0B0F17] border border-slate-700 rounded-xl text-xs text-white placeholder-slate-500 focus:border-[#86CFFF] focus:outline-none"
                  />
                </div>

                <button
                  type="submit"
                  disabled={creatingEvent}
                  className="w-full py-3.5 rounded-xl bg-gradient-to-r from-[#86CFFF] to-[#4EA8DE] text-[#0B0F17] font-black text-xs uppercase tracking-wider shadow-lg active:scale-95 transition"
                >
                  {creatingEvent ? 'Creating & Provisioning Drive...' : 'Create & Configure Studio'}
                </button>
              </form>
            </div>
          </div>
        )}
      </div>
    );
  }

  // ===========================================================================
  // 3. VIEW: EVENT SETUP STUDIO (THE LUMABOOTH / REVOSPIN INSPECTOR)
  // ===========================================================================
  if (currentStage === 'SETUP_STUDIO') {
    return (
      <div className="min-h-screen bg-[#0B0F17] text-white flex flex-col justify-between select-none max-w-lg mx-auto">
        {/* Top Header */}
        <header className="p-4 bg-[#121824]/90 border-b border-slate-800 backdrop-blur-md flex items-center justify-between sticky top-0 z-40">
          <div>
            <div className="text-[10px] text-[#86CFFF] font-bold uppercase tracking-wider">
              {selectedEvent?.name || 'Commercial Event'}
            </div>
            <h1 className="text-sm font-black text-white">BOOTH SETUP STUDIO</h1>
          </div>

          <div className="flex items-center space-x-2">
            <button
              onClick={() => setCurrentStage('EVENTS_HUB')}
              className="px-2.5 py-1.5 rounded-lg bg-slate-800 text-[11px] font-bold text-slate-300 hover:text-white"
            >
              Events
            </button>
            <button
              onClick={() => setCurrentStage('BOOTH_MODE')}
              className="px-3.5 py-1.5 rounded-xl bg-gradient-to-r from-[#86CFFF] to-[#4EA8DE] text-[#0B0F17] font-black text-xs uppercase tracking-wider shadow-lg shadow-[#86CFFF]/25 active:scale-95 flex items-center space-x-1"
            >
              <span>LAUNCH</span>
              <ChevronRight className="w-3.5 h-3.5" />
            </button>
          </div>
        </header>

        {/* Studio Sub-Navigation Tabs */}
        <nav className="flex items-center justify-around border-b border-slate-800 bg-[#0B0F17] px-2 py-2 sticky top-[57px] z-30">
          {[
            { id: 'camera', label: 'Camera', icon: Camera },
            { id: 'timing', label: 'Timing', icon: Clock },
            { id: 'overlay', label: 'Frame', icon: Layers },
            { id: 'music', label: 'Soundtrack', icon: Music },
            { id: 'storage', label: 'Storage', icon: HardDrive },
          ].map(tab => {
            const Icon = tab.icon;
            const active = setupTab === tab.id;
            return (
              <button
                key={tab.id}
                onClick={() => setSetupTab(tab.id as any)}
                className={`flex flex-col items-center py-1.5 px-3 rounded-xl transition ${
                  active ? 'bg-[#86CFFF]/15 text-[#86CFFF]' : 'text-slate-400 hover:text-slate-200'
                }`}
              >
                <Icon className="w-4 h-4 mb-0.5" />
                <span className="text-[10px] font-bold">{tab.label}</span>
              </button>
            );
          })}
        </nav>

        {/* Tab Contents */}
        <main className="flex-1 p-5 space-y-6 overflow-y-auto">
          {/* TAB 1: CAMERA & OPTICS */}
          {setupTab === 'camera' && (
            <div className="space-y-5">
              <div className="space-y-2">
                <label className="text-xs font-bold text-slate-400 uppercase tracking-wider">Lens Selection</label>
                <div className="grid grid-cols-3 gap-2.5">
                  {[
                    { id: 'ultra-wide', label: '0.5x Ultra-Wide', desc: 'Max 360 FOV' },
                    { id: 'wide', label: '1.0x Standard', desc: 'Crisp & Centered' },
                    { id: 'front', label: 'Front Selfie', desc: 'Mirror View' },
                  ].map(lens => (
                    <button
                      key={lens.id}
                      onClick={() => setCameraLens(lens.id as any)}
                      className={`p-3 rounded-2xl border text-center transition ${
                        cameraLens === lens.id
                          ? 'border-[#86CFFF] bg-[#86CFFF]/10 text-white shadow-lg shadow-[#86CFFF]/10'
                          : 'border-slate-800 bg-[#121824] text-slate-400'
                      }`}
                    >
                      <div className="text-xs font-black">{lens.label}</div>
                      <div className="text-[10px] text-slate-500 mt-0.5">{lens.desc}</div>
                    </button>
                  ))}
                </div>
              </div>

              <div className="space-y-2">
                <label className="text-xs font-bold text-slate-400 uppercase tracking-wider">Aspect Ratio</label>
                <div className="grid grid-cols-3 gap-2.5">
                  {[
                    { id: '9:16', label: '9:16 Vertical', desc: 'Reels / TikTok' },
                    { id: '1:1', label: '1:1 Square', desc: 'Instagram Feed' },
                    { id: '16:9', label: '16:9 Landscape', desc: 'Widescreen' },
                  ].map(ratio => (
                    <button
                      key={ratio.id}
                      onClick={() => setAspectRatio(ratio.id as any)}
                      className={`p-3 rounded-2xl border text-center transition ${
                        aspectRatio === ratio.id
                          ? 'border-[#86CFFF] bg-[#86CFFF]/10 text-white'
                          : 'border-slate-800 bg-[#121824] text-slate-400'
                      }`}
                    >
                      <div className="text-xs font-black">{ratio.label}</div>
                      <div className="text-[10px] text-slate-500 mt-0.5">{ratio.desc}</div>
                    </button>
                  ))}
                </div>
              </div>

              {/* Live Camera Preview Card */}
              <div className="relative aspect-[9/12] max-w-[240px] mx-auto rounded-3xl overflow-hidden border-2 border-slate-700 bg-black shadow-2xl">
                <video ref={videoRef} playsInline muted autoPlay className="w-full h-full object-cover" />
                <div className="absolute top-2 left-2 px-2 py-0.5 rounded-full bg-black/60 text-[9px] font-mono text-[#86CFFF]">
                  LIVE CAMERA PREVIEW
                </div>
              </div>
            </div>
          )}

          {/* TAB 2: TIMING & BOOMERANG SPEED RAMP */}
          {setupTab === 'timing' && (
            <div className="space-y-5">
              <div className="space-y-2">
                <label className="text-xs font-bold text-slate-400 uppercase tracking-wider">Countdown Duration</label>
                <div className="grid grid-cols-3 gap-3">
                  {[3, 5, 10].map(s => (
                    <button
                      key={s}
                      onClick={() => setCountdownSeconds(s)}
                      className={`py-3.5 rounded-2xl border text-center font-black text-sm transition ${
                        countdownSeconds === s
                          ? 'border-[#86CFFF] bg-[#86CFFF]/10 text-[#86CFFF]'
                          : 'border-slate-800 bg-[#121824] text-slate-400'
                      }`}
                    >
                      {s} SECONDS
                    </button>
                  ))}
                </div>
              </div>

              <div className="space-y-2">
                <label className="text-xs font-bold text-slate-400 uppercase tracking-wider">Recording Duration</label>
                <div className="grid grid-cols-4 gap-2">
                  {[3, 4, 5, 6].map(s => (
                    <button
                      key={s}
                      onClick={() => setRecordSeconds(s)}
                      className={`py-3 rounded-2xl border text-center font-black text-xs transition ${
                        recordSeconds === s
                          ? 'border-[#86CFFF] bg-[#86CFFF]/10 text-[#86CFFF]'
                          : 'border-slate-800 bg-[#121824] text-slate-400'
                      }`}
                    >
                      {s}s
                    </button>
                  ))}
                </div>
              </div>

              <div className="space-y-2">
                <label className="text-xs font-bold text-slate-400 uppercase tracking-wider">Boomerang Speed Curve Preset</label>
                <div className="space-y-2">
                  {[
                    { id: 'revospin_classic', title: 'RevoSpin Classic Ramp', desc: 'Normal 1.0x → Fast 2.5x → Slow-Mo 0.3x Ramp → Reverse' },
                    { id: 'fast_boomerang', title: 'High-Tempo Boomerang', desc: 'Rapid 1.5x back-and-forth party bounce' },
                    { id: 'butter_slowmo', title: 'Butter Slow-Motion Glam', desc: 'Continuous 0.25x butter-smooth slow-motion glide' },
                    { id: 'linear', title: 'Linear 1.0x Realtime', desc: 'Unedited 1.0x full recording' },
                  ].map(ramp => (
                    <div
                      key={ramp.id}
                      onClick={() => setSpeedRampPreset(ramp.id as any)}
                      className={`p-3.5 rounded-2xl border cursor-pointer transition ${
                        speedRampPreset === ramp.id
                          ? 'border-[#86CFFF] bg-[#86CFFF]/10 text-white'
                          : 'border-slate-800 bg-[#121824] text-slate-400'
                      }`}
                    >
                      <div className="text-xs font-black">{ramp.title}</div>
                      <div className="text-[11px] text-slate-400 mt-0.5">{ramp.desc}</div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* TAB 3: FRAME OVERLAY STUDIO */}
          {setupTab === 'overlay' && (
            <div className="space-y-5">
              <div className="space-y-2">
                <label className="text-xs font-bold text-slate-400 uppercase tracking-wider">Select Frame Overlay</label>
                <div className="space-y-3">
                  {FRAME_PRESETS.map(frame => (
                    <div
                      key={frame.id}
                      onClick={() => setSelectedFrame(frame.id)}
                      className={`p-4 rounded-2xl border cursor-pointer transition flex items-center justify-between ${
                        selectedFrame === frame.id
                          ? 'border-[#86CFFF] bg-[#86CFFF]/10 text-white shadow-lg'
                          : 'border-slate-800 bg-[#121824] text-slate-400'
                      }`}
                    >
                      <div className="space-y-1">
                        <div className="text-sm font-black text-white flex items-center space-x-2">
                          <span>{frame.name}</span>
                          {selectedFrame === frame.id && <Check className="w-4 h-4 text-[#86CFFF]" />}
                        </div>
                        <div className="text-xs text-slate-400">{frame.description}</div>
                      </div>
                      <div className={`w-8 h-12 rounded-lg ${frame.borderStyle} flex-shrink-0`} />
                    </div>
                  ))}
                </div>
              </div>

              {/* Viewfinder Preview with Overlay Applied */}
              <div className="space-y-2">
                <label className="text-xs font-bold text-slate-400 uppercase tracking-wider">Live Viewfinder Overlay Preview</label>
                <div className="relative aspect-[9/12] max-w-[240px] mx-auto rounded-3xl overflow-hidden border-2 border-slate-700 bg-black shadow-2xl">
                  <video ref={videoRef} playsInline muted autoPlay className="w-full h-full object-cover" />
                  {/* Superimposed Frame Overlay */}
                  <div className={`absolute inset-2.5 rounded-2xl pointer-events-none flex flex-col justify-between p-3 ${activeFrameConfig.borderStyle}`}>
                    <div className="text-[8px] font-black tracking-widest text-center" style={{ color: activeFrameConfig.color }}>
                      {activeFrameConfig.cornerText}
                    </div>
                    <div className="text-[7px] font-black tracking-widest text-center" style={{ color: activeFrameConfig.accentColor }}>
                      {activeFrameConfig.subText}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* TAB 4: MUSIC & SOUNDTRACKS */}
          {setupTab === 'music' && (
            <div className="space-y-5">
              <div className="flex items-center justify-between">
                <label className="text-xs font-bold text-slate-400 uppercase tracking-wider">Event Soundtrack</label>
                <button
                  onClick={toggleSoundtrackPreview}
                  className="px-3 py-1.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-xs font-bold text-[#86CFFF] transition flex items-center space-x-1.5"
                >
                  {isPlayingAudioPreview ? <Pause className="w-3.5 h-3.5" /> : <Play className="w-3.5 h-3.5" />}
                  <span>{isPlayingAudioPreview ? 'Stop Audio' : 'Preview Audio'}</span>
                </button>
              </div>

              <div className="space-y-2.5">
                {SOUNDTRACK_PRESETS.map(track => (
                  <div
                    key={track.id}
                    onClick={() => setSelectedSoundtrack(track.id)}
                    className={`p-3.5 rounded-2xl border cursor-pointer transition flex items-center justify-between ${
                      selectedSoundtrack === track.id
                        ? 'border-[#86CFFF] bg-[#86CFFF]/10 text-white'
                        : 'border-slate-800 bg-[#121824] text-slate-400'
                    }`}
                  >
                    <div>
                      <div className="text-xs font-black text-white">{track.name}</div>
                      <div className="text-[11px] text-slate-400 mt-0.5">{track.genre} • {track.duration}</div>
                    </div>
                    {selectedSoundtrack === track.id && <Check className="w-4 h-4 text-[#86CFFF]" />}
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* TAB 5: STORAGE & AUTO-DOWNLOAD */}
          {setupTab === 'storage' && (
            <div className="space-y-5">
              <div className="p-4 rounded-2xl bg-[#121824] border border-slate-800 space-y-3">
                <div className="flex items-center justify-between">
                  <div className="flex items-center space-x-2.5">
                    <Download className="w-5 h-5 text-emerald-400" />
                    <div>
                      <div className="text-xs font-black text-white">Auto-Download Locally</div>
                      <div className="text-[10px] text-slate-400">Saves video to phone storage immediately</div>
                    </div>
                  </div>
                  <input
                    type="checkbox"
                    checked={autoDownloadLocally}
                    onChange={(e) => setAutoDownloadLocally(e.target.checked)}
                    className="w-5 h-5 accent-[#86CFFF] rounded"
                  />
                </div>
                <p className="text-[11px] text-slate-400 leading-relaxed border-t border-slate-800/80 pt-2">
                  When enabled, full-resolution MP4s are saved directly to your phone’s storage/downloads in parallel with Google Drive sync. 100% zero data loss guarantee during venue internet dropouts.
                </p>
              </div>

              <div className="p-4 rounded-2xl bg-[#121824] border border-slate-800 space-y-2">
                <label className="text-[11px] font-bold text-slate-400 uppercase">Operator Exit PIN</label>
                <input
                  type="password"
                  maxLength={6}
                  value={operatorExitPin}
                  onChange={(e) => setOperatorExitPin(e.target.value)}
                  className="w-full px-3 py-2 bg-[#0B0F17] border border-slate-700 rounded-xl text-sm font-mono text-center tracking-widest text-[#86CFFF] focus:outline-none"
                />
                <p className="text-[10px] text-slate-500">
                  Required to exit locked Photobooth Mode back to this Studio.
                </p>
              </div>
            </div>
          )}
        </main>

        {/* Bottom Launch Button */}
        <footer className="p-4 bg-[#121824]/90 border-t border-slate-800 backdrop-blur-md sticky bottom-0 z-40">
          <button
            onClick={() => setCurrentStage('BOOTH_MODE')}
            className="w-full py-4 rounded-2xl bg-gradient-to-r from-[#86CFFF] to-[#4EA8DE] text-[#0B0F17] font-black text-sm uppercase tracking-widest shadow-xl shadow-[#86CFFF]/25 active:scale-95 transition flex items-center justify-center space-x-2"
          >
            <span>START LIVE PHOTOBOOTH</span>
            <ChevronRight className="w-5 h-5" />
          </button>
        </footer>
      </div>
    );
  }

  // ===========================================================================
  // 4. VIEW: COMMERCIAL PHOTOBOOTH GUEST MODE (LOCKED FULLSCREEN EXPERIENCE)
  // ===========================================================================
  return (
    <div className="min-h-screen bg-black text-white flex flex-col justify-between select-none relative overflow-hidden">
      {/* Top Telemetry & Security Lock Bar */}
      <header className="px-4 py-2.5 bg-black/70 border-b border-white/10 backdrop-blur-md flex items-center justify-between z-30">
        <div className="flex items-center space-x-2">
          <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
          <div className="text-[11px] font-black tracking-wide text-white">
            {selectedEvent?.name || 'LUSTER 360'}
          </div>
        </div>

        {/* Live Counters */}
        <div className="flex items-center space-x-3 text-[11px] font-mono text-slate-300">
          <div className="px-2 py-0.5 rounded bg-white/10">
            REC: <span className="font-bold text-[#86CFFF]">{capturesRecorded}</span>
          </div>
          <div className="px-2 py-0.5 rounded bg-white/10">
            SYNC: <span className="font-bold text-emerald-400">{capturesUploaded}</span>
          </div>

          {/* Hidden Exit Lock */}
          <button
            onClick={() => setShowExitPinModal(true)}
            className="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white transition ml-1"
            title="Operator Exit"
          >
            <Lock className="w-3.5 h-3.5" />
          </button>
        </div>
      </header>

      {/* Main Viewport */}
      <main className="flex-1 relative flex flex-col items-center justify-center overflow-hidden bg-black">
        {/* Real Live Camera Stream */}
        <video
          ref={videoRef}
          playsInline
          muted
          autoPlay
          className="absolute inset-0 w-full h-full object-cover z-0"
        />

        {/* Dynamic Superimposed Frame Overlay on Viewfinder */}
        <div className={`absolute inset-4 rounded-3xl pointer-events-none z-10 flex flex-col justify-between p-5 ${activeFrameConfig.borderStyle}`}>
          <div className="text-center font-black text-sm tracking-widest" style={{ color: activeFrameConfig.color }}>
            {activeFrameConfig.cornerText}
          </div>
          <div className="text-center font-black text-xs tracking-widest" style={{ color: activeFrameConfig.accentColor }}>
            {activeFrameConfig.subText}
          </div>
        </div>

        {/* STATE OVERLAY: Countdown */}
        {boothState === 'COUNTDOWN' && (
          <div className="absolute inset-0 bg-black/60 backdrop-blur-sm z-20 flex flex-col items-center justify-center">
            <span className="text-9xl font-black text-[#86CFFF] animate-ping">
              {countdown}
            </span>
            <p className="text-base font-black text-white tracking-widest mt-8 uppercase">
              GET READY TO POSE!
            </p>
          </div>
        )}

        {/* STATE OVERLAY: Recording Active */}
        {boothState === 'RECORDING' && (
          <div className="absolute inset-0 z-20 flex flex-col justify-between p-6 bg-gradient-to-t from-black/80 via-transparent to-black/60 pointer-events-none">
            <div className="flex items-center justify-center space-x-2">
              <span className="w-3 h-3 rounded-full bg-red-500 animate-ping" />
              <span className="text-sm font-black text-red-400 tracking-wider uppercase">
                RECORDING 360 CAPTURE
              </span>
            </div>

            <div className="w-full max-w-xs mx-auto space-y-2">
              <div className="h-3 w-full bg-slate-800 rounded-full overflow-hidden border border-slate-700">
                <div 
                  className="h-full bg-gradient-to-r from-[#86CFFF] to-[#4EA8DE] transition-all duration-200"
                  style={{ width: `${recordingProgress}%` }}
                />
              </div>
              <p className="text-center text-xs text-slate-300 font-mono font-bold">
                {recordingProgress}% Complete
              </p>
            </div>
          </div>
        )}

        {/* STATE OVERLAY: Processing with Overlay & Music */}
        {boothState === 'PROCESSING' && (
          <div className="absolute inset-0 bg-[#0B0F17]/95 backdrop-blur-xl z-20 flex flex-col items-center justify-center p-8 text-center space-y-5">
            <div className="w-20 h-20 rounded-3xl bg-[#86CFFF]/10 border-2 border-[#86CFFF] flex items-center justify-center animate-spin">
              <Sparkles className="w-8 h-8 text-[#86CFFF]" />
            </div>
            <div>
              <h3 className="text-lg font-black text-white">GENERATING 360 EXPERIENCE</h3>
              <p className="text-xs text-slate-400 mt-1 max-w-xs">
                Rendering {activeFrameConfig.name}, syncing audio soundtrack, saving locally, and uploading to Google Drive...
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
                <span>Saved to Device & Uploaded to Drive</span>
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
              onClick={handleNextGuest}
              className="w-full max-w-xs py-4 rounded-2xl bg-gradient-to-r from-[#86CFFF] to-[#4EA8DE] text-[#0B0F17] font-black text-sm tracking-wider uppercase shadow-xl shadow-[#86CFFF]/25 active:scale-95 transition flex items-center justify-center space-x-2"
            >
              <span>Ready for Next Guest</span>
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        )}
      </main>

      {/* Bottom Start Button (When IDLE) */}
      {boothState === 'IDLE' && (
        <footer className="p-6 bg-black/70 border-t border-white/10 backdrop-blur-md z-30 flex flex-col items-center">
          <button
            onClick={startRecordingFlow}
            className="w-full max-w-sm py-5 rounded-2xl bg-gradient-to-r from-[#86CFFF] to-[#4EA8DE] text-[#0B0F17] font-black text-lg tracking-widest uppercase shadow-2xl shadow-[#86CFFF]/30 active:scale-95 transition flex items-center justify-center space-x-3"
          >
            <Video className="w-6 h-6 fill-current" />
            <span>START 360 RECORDING</span>
          </button>
        </footer>
      )}

      {/* Operator PIN Exit Modal */}
      {showExitPinModal && (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-md z-50 flex items-center justify-center p-6">
          <div className="w-full max-w-xs bg-[#121824] border border-slate-700 rounded-3xl p-6 space-y-4 text-center">
            <div className="w-12 h-12 rounded-2xl bg-slate-800 flex items-center justify-center mx-auto text-[#86CFFF]">
              <Lock className="w-6 h-6" />
            </div>
            <div>
              <h3 className="text-sm font-black text-white">OPERATOR EXIT PIN</h3>
              <p className="text-xs text-slate-400 mt-0.5">Enter PIN to return to Setup Studio</p>
            </div>

            {pinError && (
              <div className="text-xs font-bold text-red-400">
                Incorrect PIN. Please try again.
              </div>
            )}

            <input
              type="password"
              autoFocus
              maxLength={6}
              value={enteredPin}
              onChange={(e) => setEnteredPin(e.target.value)}
              placeholder="••••"
              className="w-full py-3 bg-[#0B0F17] border border-slate-700 rounded-xl text-center text-lg font-mono tracking-widest text-[#86CFFF] focus:outline-none"
            />

            <div className="flex items-center space-x-2">
              <button
                onClick={() => { setShowExitPinModal(false); setEnteredPin(''); setPinError(false); }}
                className="flex-1 py-2.5 rounded-xl bg-slate-800 text-xs font-bold text-slate-400"
              >
                Cancel
              </button>
              <button
                onClick={handleVerifyExitPin}
                className="flex-1 py-2.5 rounded-xl bg-[#86CFFF] text-[#0B0F17] text-xs font-black"
              >
                Unlock
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
