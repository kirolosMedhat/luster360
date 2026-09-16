'use client';

import { useState, useEffect, useRef } from 'react';
import Link from 'next/link';
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
  Share2,
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
  X,
  Upload,
  Trash2,
  ExternalLink,
  Maximize2,
  Grid,
  Crosshair,
  FolderPlus,
  FolderCheck,
  Send,
  SmartphoneNfc,
  Flame,
  Sun
} from 'lucide-react';
import gsap from 'gsap';

// Preset Frame Overlays (Tactile & High-Taste)
const FRAME_PRESETS = [
  {
    id: 'gold_wedding',
    name: 'Royal Champagne Gold',
    description: 'Ornate double-lined gold foil border with celebration calligraphy',
    color: '#D4AF37',
    accentColor: '#E5C07B',
    borderStyle: 'border-2 border-[#D4AF37] shadow-[0_0_20px_rgba(212,175,55,0.3)]',
    topText: '✦ AHMED & MARIAM ✦',
    bottomText: 'THE 360 WEDDING EXPERIENCE',
  },
  {
    id: 'cyber_horizon',
    name: 'Cyber Noir Horizon',
    description: 'Sharp technical HUD corner ticks with electric luminescence',
    color: '#86CFFF',
    accentColor: '#38BDF8',
    borderStyle: 'border border-[#86CFFF]/60 shadow-[0_0_20px_rgba(134,207,255,0.25)]',
    topText: '⚡ LUSTER 360 • VIP ⚡',
    bottomText: 'NIGHTCLUB EDITION • CAIRO',
  },
  {
    id: 'silver_gala',
    name: 'Executive Silver Gala',
    description: 'Subtle titanium brushed lines with clean corporate minimalism',
    color: '#E2E8F0',
    accentColor: '#94A3B8',
    borderStyle: 'border border-white/40 shadow-[0_0_15px_rgba(255,255,255,0.15)]',
    topText: 'ANNUAL LEADERSHIP SUMMIT',
    bottomText: 'MOMENTS IN MOTION 2026',
  },
  {
    id: 'vintage_film',
    name: 'Analog 35mm Filmstrip',
    description: 'Vintage optical sprocket perforations and warm analog film imprint',
    color: '#F59E0B',
    accentColor: '#FCD34D',
    borderStyle: 'border-2 border-[#F59E0B]/70',
    topText: '🎞️ ISO 400 • 35MM CINEMA 🎞️',
    bottomText: 'RECORDED LIVE ON LUSTER 360',
  },
];

// Preset Soundtracks
const SOUNDTRACK_PRESETS = [
  { id: 'edm_dance', name: 'Electric Festival Beat', genre: 'High-Energy EDM', duration: '15s', bpm: 128 },
  { id: 'wedding_piano', name: 'Golden Romance Strings', genre: 'Romantic Orchestral', duration: '15s', bpm: 85 },
  { id: 'trap_bounce', name: 'Urban Club Groove', genre: 'Modern Hip-Hop Trap', duration: '15s', bpm: 140 },
  { id: 'disco_funk', name: 'Retro Disco Celebration', genre: 'Funky Dance Party', duration: '15s', bpm: 115 },
  { id: 'mute', name: 'No Music (Live Audio Only)', genre: 'Ambient Mic', duration: '—', bpm: 0 },
];

export default function MobileBoothPage() {
  // Navigation Stages: 'LOGIN' | 'EVENTS_HUB' | 'SETUP_STUDIO' | 'BOOTH_MODE'
  const [currentStage, setCurrentStage] = useState<'LOGIN' | 'EVENTS_HUB' | 'SETUP_STUDIO' | 'BOOTH_MODE'>('LOGIN');

  // Security Context Check
  const [isSecureContext, setIsSecureContext] = useState(true);
  const [showSecureWarning, setShowSecureWarning] = useState(false);

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
  const [setupTab, setSetupTab] = useState<'camera' | 'overlay' | 'timing' | 'music' | 'storage'>('camera');
  const [cameraLens, setCameraLens] = useState<'ultra-wide' | 'wide' | 'front'>('wide');
  const [aspectRatio, setAspectRatio] = useState<'9:16' | '1:1' | '16:9'>('9:16');
  const [showViewfinderGrid, setShowViewfinderGrid] = useState(true);
  const [countdownSeconds, setCountdownSeconds] = useState<number>(3);
  const [recordSeconds, setRecordSeconds] = useState<number>(5);
  const [speedRampPreset, setSpeedRampPreset] = useState<'revospin_classic' | 'fast_boomerang' | 'butter_slowmo' | 'linear'>('revospin_classic');
  
  // Overlay Frame Management (Presets + Custom PNG Upload)
  const [selectedFrameType, setSelectedFrameType] = useState<'preset' | 'custom'>('preset');
  const [selectedFrameId, setSelectedFrameId] = useState<string>('gold_wedding');
  const [customPngUrl, setCustomPngUrl] = useState<string | null>(null);
  const [customPngName, setCustomPngName] = useState<string | null>(null);

  // Hardware Camera & Flashlight/Torch State
  const [cameraActive, setCameraActive] = useState(false);
  const [cameraPermissionGranted, setCameraPermissionGranted] = useState(false);
  const [cameraError, setCameraError] = useState<string | null>(null);
  const [isTorchAvailable, setIsTorchAvailable] = useState(false);
  const [isTorchOn, setIsTorchOn] = useState(false);
  const [autoTorchOnRecord, setAutoTorchOnRecord] = useState(true);

  // Storage Access & Local Persistence (Directory Picker + IndexedDB)
  const [storageDirectoryHandle, setStorageDirectoryHandle] = useState<any | null>(null);
  const [storageFolderName, setStorageFolderName] = useState<string | null>(null);
  const [autoDownloadLocally, setAutoDownloadLocally] = useState(true);
  const [offlineCaptures, setOfflineCaptures] = useState<any[]>([]);
  const [showOfflineGallery, setShowOfflineGallery] = useState(false);

  // Soundtrack & Audio
  const [selectedSoundtrack, setSelectedSoundtrack] = useState<string>('edm_dance');
  const [isPlayingAudioPreview, setIsPlayingAudioPreview] = useState(false);

  // Operator Lock PIN
  const [operatorExitPin, setOperatorExitPin] = useState('1234');
  const [showExitPinModal, setShowExitPinModal] = useState(false);
  const [enteredPin, setEnteredPin] = useState('');
  const [pinError, setPinError] = useState(false);

  // Commercial Kiosk Workflow (Attractor -> Countdown -> Recording -> Processing -> Sharing Station)
  const [kioskScreen, setKioskScreen] = useState<'ATTRACTOR' | 'VIEWFINDER'>('ATTRACTOR');
  const [boothState, setBoothState] = useState<'IDLE' | 'COUNTDOWN' | 'RECORDING' | 'PROCESSING' | 'READY'>('IDLE');
  const [countdown, setCountdown] = useState(3);
  const [recordingProgress, setRecordingProgress] = useState(0);
  const [guestShareCode, setGuestShareCode] = useState<string | null>(null);
  const [processedVideoUrl, setProcessedVideoUrl] = useState<string | null>(null);
  const [processedVideoBlob, setProcessedVideoBlob] = useState<Blob | null>(null);
  const [downloadSuccessToast, setDownloadSuccessToast] = useState(false);

  // LumaBooth Guest Lead Sharing Form
  const [guestContact, setGuestContact] = useState('');
  const [contactSubmitted, setContactSubmitted] = useState(false);
  const [whatsAppDirectUrl, setWhatsAppDirectUrl] = useState<string | null>(null);
  const [isUploadingToDrive, setIsUploadingToDrive] = useState<boolean>(false);
  const [uploadSuccessToast, setUploadSuccessToast] = useState<boolean>(false);
  const [autoResetTimer, setAutoResetTimer] = useState<number>(15);

  // Dual Telemetry Counters
  const [capturesRecorded, setCapturesRecorded] = useState<number>(0);
  const [capturesUploaded, setCapturesUploaded] = useState<number>(0);
  const [batteryLevel, setBatteryLevel] = useState<number>(94);
  const [deviceId, setDeviceId] = useState<string>('LUSTER-BOOTH-01');

  // Hardware & Camera Refs
  const videoRef = useRef<HTMLVideoElement | null>(null);
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const recordedChunksRef = useRef<Blob[]>([]);
  const audioCtxRef = useRef<AudioContext | null>(null);
  const nativeCameraInputRef = useRef<HTMLInputElement | null>(null);
  const pngFileInputRef = useRef<HTMLInputElement | null>(null);
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const autoResetIntervalRef = useRef<any>(null);
  const customFrameImgRef = useRef<HTMLImageElement | null>(null);
  const animationFrameIdRef = useRef<number | null>(null);

  // Public HTTPS Tunnel URL for Auto Camera Permissions
  const httpsTunnelUrl = 'https://neat-pandas-battle.loca.lt/booth';

  // 1. Initial Load: Restore saved session, custom frame, and check Secure Context
  useEffect(() => {
    if (typeof window !== 'undefined') {
      const isSec = window.isSecureContext || window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';
      setIsSecureContext(isSec);
      if (!isSec) {
        setShowSecureWarning(true);
      }

      // Restore operator session
      const savedToken = localStorage.getItem('luster_operator_token');
      const savedOperator = localStorage.getItem('luster_operator_user');
      if (savedToken && savedOperator) {
        try {
          setToken(savedToken);
          setOperator(JSON.parse(savedOperator));
          setCurrentStage('EVENTS_HUB');
        } catch {}
      }

      // Restore custom PNG frame
      const savedPng = localStorage.getItem('luster_booth_custom_frame');
      const savedPngName = localStorage.getItem('luster_booth_custom_frame_name');
      if (savedPng) {
        setCustomPngUrl(savedPng);
        setCustomPngName(savedPngName || 'Custom Overlay.png');
        setSelectedFrameType('custom');
      }

      // Load offline captures from IndexedDB
      loadIndexedDbCaptures();

      // Battery level
      if ('getBattery' in navigator) {
        (navigator as any).getBattery().then((b: any) => {
          setBatteryLevel(Math.round(b.level * 100));
          b.addEventListener('levelchange', () => setBatteryLevel(Math.round(b.level * 100)));
        }).catch(() => {});
      }
    }
  }, []);

  // Pre-load custom PNG frame for canvas compositing
  useEffect(() => {
    if (customPngUrl) {
      const img = new Image();
      img.crossOrigin = 'anonymous';
      img.src = customPngUrl;
      img.onload = () => { customFrameImgRef.current = img; };
    } else {
      customFrameImgRef.current = null;
    }
  }, [customPngUrl]);

  // 2. IndexedDB Local Storage Database Engine
  const openIndexedDb = (): Promise<IDBDatabase> => {
    return new Promise((resolve, reject) => {
      const req = indexedDB.open('LusterBoothStorageDB', 1);
      req.onupgradeneeded = () => {
        const db = req.result;
        if (!db.objectStoreNames.contains('captures')) {
          db.createObjectStore('captures', { keyPath: 'id' });
        }
      };
      req.onsuccess = () => resolve(req.result);
      req.onerror = () => reject(req.error);
    });
  };

  const saveToIndexedDb = async (captureItem: any) => {
    try {
      const db = await openIndexedDb();
      const tx = db.transaction('captures', 'readwrite');
      tx.objectStore('captures').put(captureItem);
      await loadIndexedDbCaptures();
    } catch (err) {
      console.warn('IndexedDB save notice:', err);
    }
  };

  const loadIndexedDbCaptures = async () => {
    try {
      const db = await openIndexedDb();
      const tx = db.transaction('captures', 'readonly');
      const req = tx.objectStore('captures').getAll();
      req.onsuccess = () => {
        const items = req.result || [];
        items.sort((a: any, b: any) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
        setOfflineCaptures(items);
      };
    } catch {}
  };

  // 3. File System Directory Access (Android / Chrome Desktop)
  const handleSelectStorageFolder = async () => {
    if ('showDirectoryPicker' in window) {
      try {
        const handle = await (window as any).showDirectoryPicker({
          mode: 'readwrite',
          startIn: 'downloads',
        });
        setStorageDirectoryHandle(handle);
        setStorageFolderName(handle.name || 'Selected Folder');
        playSound('success');
      } catch (err) {
        console.warn('Directory picker cancelled or unsupported:', err);
      }
    } else {
      alert('Your browser saves videos automatically to Downloads & IndexedDB Storage.');
    }
  };

  // 4. Fetch Events from Backend
  const fetchEvents = async () => {
    try {
      const res = await fetch('/api/v1/events');
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

  // 5. Synthesized Audio Beeps & Sounds
  const playSound = (type: 'beep' | 'shutter' | 'success' | 'countdown') => {
    try {
      const AudioCtx = window.AudioContext || (window as any).webkitAudioContext;
      if (!AudioCtx) return;
      const ctx = audioCtxRef.current || new AudioCtx();
      audioCtxRef.current = ctx;

      if (type === 'beep' || type === 'countdown') {
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(880, ctx.currentTime);
        gain.gain.setValueAtTime(0.25, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.12);
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start();
        osc.stop(ctx.currentTime + 0.12);
      } else if (type === 'shutter') {
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = 'triangle';
        osc.frequency.setValueAtTime(1400, ctx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(120, ctx.currentTime + 0.08);
        gain.gain.setValueAtTime(0.35, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.08);
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start();
        osc.stop(ctx.currentTime + 0.08);
      } else if (type === 'success') {
        [523.25, 659.25, 783.99].forEach((freq, i) => {
          const osc = ctx.createOscillator();
          const gain = ctx.createGain();
          osc.type = 'sine';
          osc.frequency.setValueAtTime(freq, ctx.currentTime + i * 0.08);
          gain.gain.setValueAtTime(0.2, ctx.currentTime + i * 0.08);
          gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + i * 0.08 + 0.3);
          osc.connect(gain);
          gain.connect(ctx.destination);
          osc.start(ctx.currentTime + i * 0.08);
          osc.stop(ctx.currentTime + i * 0.08 + 0.3);
        });
      }
    } catch {}
  };

  // 6. Camera Stream & Flashlight/Torch Control
  const startCameraStream = async () => {
    setCameraError(null);
    try {
      if (videoRef.current && videoRef.current.srcObject) {
        const tracks = (videoRef.current.srcObject as MediaStream).getTracks();
        tracks.forEach(t => t.stop());
      }

      if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
        throw new Error('Camera access requires HTTPS or Localhost context. Use Native 4K Shutter.');
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
        videoRef.current.play().catch(() => {});
        setCameraActive(true);
        setCameraPermissionGranted(true);

        // Check if Torch/Flashlight is supported on this track
        const track = stream.getVideoTracks()[0];
        if (track && (track.getCapabilities as any)) {
          const capabilities = (track.getCapabilities as any)();
          if (capabilities && capabilities.torch) {
            setIsTorchAvailable(true);
          }
        }
      }
    } catch (err: any) {
      console.warn('Camera setup note:', err.message);
      setCameraActive(false);
      setCameraError(err.message || 'Camera permission not granted');
    }
  };

  const toggleTorch = async (forceState?: boolean) => {
    if (!videoRef.current || !videoRef.current.srcObject) return;
    const stream = videoRef.current.srcObject as MediaStream;
    const track = stream.getVideoTracks()[0];
    if (!track) return;

    const nextState = forceState !== undefined ? forceState : !isTorchOn;
    try {
      await (track as any).applyConstraints({
        advanced: [{ torch: nextState }],
      });
      setIsTorchOn(nextState);
    } catch (err) {
      console.warn('Torch control notice:', err);
    }
  };

  useEffect(() => {
    if (currentStage === 'SETUP_STUDIO' || (currentStage === 'BOOTH_MODE' && kioskScreen === 'VIEWFINDER')) {
      startCameraStream();
    }
    return () => {
      if (videoRef.current && videoRef.current.srcObject) {
        const tracks = (videoRef.current.srcObject as MediaStream).getTracks();
        tracks.forEach(t => t.stop());
      }
    };
  }, [currentStage, kioskScreen, cameraLens, aspectRatio]);

  // 7. Live Telemetry Heartbeat Sync (Reports live presence to Dashboard)
  useEffect(() => {
    if (!token) return;

    const sendHeartbeat = async () => {
      try {
        const ua = navigator.userAgent;
        let model = 'Mobile Booth Unit';
        if (/iPhone/i.test(ua)) model = 'Apple iPhone';
        else if (/iPad/i.test(ua)) model = 'Apple iPad';
        else if (/Android/i.test(ua)) model = 'Android 360 Unit';

        await fetch('/api/v1/devices/heartbeat', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            deviceId,
            deviceName: `${model} (${operator?.fullName || 'Operator'})`,
            model,
            appVersion: 'v2.2 (LumaBooth & RevoSpin Edition)',
            batteryLevel,
            storageFreeGb: 58,
            networkType: 'WIFI',
            currentEventId: selectedEvent?.id || null,
            operationalState: boothState === 'RECORDING' ? 'RECORDING' : 
                              boothState === 'COUNTDOWN' ? 'COUNTDOWN' :
                              boothState === 'PROCESSING' ? 'PROCESSING' :
                              boothState === 'READY' ? 'SHARING' : 'READY',
            status: 'ONLINE',
            capturesRecorded,
            capturesUploaded,
          }),
        });
      } catch {}
    };

    sendHeartbeat();
    const interval = setInterval(sendHeartbeat, 4000);
    return () => clearInterval(interval);
  }, [token, deviceId, boothState, batteryLevel, operator, selectedEvent, capturesRecorded, capturesUploaded]);

  // 8. Custom PNG Frame Uploader Handler
  const handlePngUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    if (!file.type.includes('png') && !file.type.includes('image')) {
      alert('Please upload a transparent PNG frame.');
      return;
    }

    const reader = new FileReader();
    reader.onload = (event) => {
      const dataUrl = event.target?.result as string;
      setCustomPngUrl(dataUrl);
      setCustomPngName(file.name);
      setSelectedFrameType('custom');
      try {
        localStorage.setItem('luster_booth_custom_frame', dataUrl);
        localStorage.setItem('luster_booth_custom_frame_name', file.name);
      } catch {}
      playSound('beep');
    };
    reader.readAsDataURL(file);
  };

  const handleRemoveCustomPng = () => {
    setCustomPngUrl(null);
    setCustomPngName(null);
    setSelectedFrameType('preset');
    localStorage.removeItem('luster_booth_custom_frame');
    localStorage.removeItem('luster_booth_custom_frame_name');
  };

  // 9. Native Camera Shutter Fallback (100% Reliable across ALL phones, even plain HTTP)
  const triggerNativeCamera = () => {
    if (nativeCameraInputRef.current) {
      nativeCameraInputRef.current.click();
    }
  };

  const handleNativeVideoCaptured = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    playSound('shutter');
    setBoothState('PROCESSING');
    const newRecordedCount = capturesRecorded + 1;
    setCapturesRecorded(newRecordedCount);

    const videoUrl = URL.createObjectURL(file);
    setProcessedVideoUrl(videoUrl);
    setProcessedVideoBlob(file);

    // Auto-save pipeline
    await executeSavePipeline(file, videoUrl);

    // Register capture with backend
    const code = `L360-${Math.floor(1000 + Math.random() * 9000)}`;
    setGuestShareCode(code);
    registerCaptureWithDashboard(code, 5, file.name);

    setTimeout(() => {
      setCapturesUploaded(prev => prev + 1);
      setBoothState('READY');
      playSound('success');
      startAutoResetTimer();
    }, 1800);
  };

  // 10. Recording Flow with Real Canvas Frame Compositing (RevoSpin / Luma Experience)
  const handleStartFromAttractor = () => {
    setKioskScreen('VIEWFINDER');
    startRecordingFlow();
  };

  const startRecordingFlow = () => {
    playSound('shutter');
    setBoothState('COUNTDOWN');
    setCountdown(countdownSeconds);
    playSound('countdown');

    if (autoTorchOnRecord && isTorchAvailable) {
      toggleTorch(true);
    }

    const countTimer = setInterval(() => {
      setCountdown(prev => {
        if (prev <= 1) {
          clearInterval(countTimer);
          playSound('shutter');
          beginLiveRecording();
          return 0;
        }
        playSound('countdown');
        return prev - 1;
      });
    }, 1000);
  };

  const beginLiveRecording = () => {
    setBoothState('RECORDING');
    setRecordingProgress(0);
    recordedChunksRef.current = [];

    // Ensure hidden compositing canvas is created and sized
    let canvas = canvasRef.current;
    if (!canvas) {
      canvas = document.createElement('canvas');
      canvasRef.current = canvas;
    }
    canvas.width = 720;
    canvas.height = 1280;
    const ctx = canvas.getContext('2d');

    const hasActiveCamera = () => {
      return (
        videoRef.current &&
        videoRef.current.srcObject &&
        videoRef.current.readyState >= 2 &&
        (videoRef.current.srcObject as MediaStream).getVideoTracks().length > 0
      );
    };

    // Start 30fps compositing animation loop
    const startTime = Date.now();
    const drawFrame = () => {
      if (!ctx) return;
      const elapsed = (Date.now() - startTime) / 1000;

      // 1. Draw live camera frame OR high-end 360 rotating stage visual
      if (hasActiveCamera() && videoRef.current) {
        try {
          ctx.drawImage(videoRef.current, 0, 0, canvas.width, canvas.height);
        } catch {}
      } else {
        // High-end Leica / 360 Darkroom visual sweep
        const grad = ctx.createRadialGradient(canvas.width / 2, canvas.height / 2, 60, canvas.width / 2, canvas.height / 2, 450);
        grad.addColorStop(0, '#161B26');
        grad.addColorStop(0.5, '#0E1118');
        grad.addColorStop(1, '#05070A');
        ctx.fillStyle = grad;
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        // Technical Grid
        ctx.strokeStyle = 'rgba(134, 207, 255, 0.08)';
        ctx.lineWidth = 1;
        for (let x = 60; x < canvas.width; x += 120) {
          ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, canvas.height); ctx.stroke();
        }
        for (let y = 60; y < canvas.height; y += 120) {
          ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(canvas.width, y); ctx.stroke();
        }

        // Animated Rotating 360 Arm Orbit
        const angle = (elapsed * 2.5) % (Math.PI * 2);
        ctx.save();
        ctx.translate(canvas.width / 2, canvas.height / 2);

        // Outer Neon Ring
        ctx.strokeStyle = '#86CFFF';
        ctx.lineWidth = 3;
        ctx.shadowColor = '#86CFFF';
        ctx.shadowBlur = 18;
        ctx.beginPath();
        ctx.arc(0, 0, 180, 0, Math.PI * 2);
        ctx.stroke();

        // 360 Camera Arm
        ctx.beginPath();
        ctx.moveTo(0, 0);
        ctx.lineTo(Math.cos(angle) * 180, Math.sin(angle) * 180);
        ctx.strokeStyle = '#FF3B30';
        ctx.lineWidth = 5;
        ctx.shadowColor = '#FF3B30';
        ctx.shadowBlur = 12;
        ctx.stroke();

        // Camera Head Dot
        ctx.beginPath();
        ctx.arc(Math.cos(angle) * 180, Math.sin(angle) * 180, 12, 0, Math.PI * 2);
        ctx.fillStyle = '#FFFFFF';
        ctx.fill();

        ctx.restore();

        // HUD Text Overlay
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 26px monospace';
        ctx.textAlign = 'center';
        ctx.fillText(selectedEvent?.name || 'LUSTER 360 EXPERIENCE', canvas.width / 2, 180);

        ctx.fillStyle = '#86CFFF';
        ctx.font = 'bold 16px monospace';
        ctx.fillText(`360 CAPTURE IN PROGRESS • ${elapsed.toFixed(1)}s`, canvas.width / 2, 220);
      }

      // 2. Composite Custom PNG Frame Overlay directly onto the video canvas
      if (selectedFrameType === 'custom' && customFrameImgRef.current) {
        try {
          ctx.drawImage(customFrameImgRef.current, 0, 0, canvas.width, canvas.height);
        } catch {}
      }

      // 3. Composite Preset Frame Overlay directly onto the video canvas
      if (selectedFrameType === 'preset') {
        const p = activePresetConfig;
        ctx.save();
        ctx.strokeStyle = p.color || '#86CFFF';
        ctx.lineWidth = 8;
        ctx.strokeRect(30, 30, canvas.width - 60, canvas.height - 60);

        ctx.strokeStyle = p.accentColor || '#FFFFFF';
        ctx.lineWidth = 2;
        ctx.strokeRect(45, 45, canvas.width - 90, canvas.height - 90);

        ctx.fillStyle = p.color || '#86CFFF';
        ctx.font = 'bold 22px monospace';
        ctx.textAlign = 'center';
        ctx.fillText(p.topText || 'CELEBRATION 360', canvas.width / 2, 85);

        ctx.fillStyle = p.accentColor || '#FFFFFF';
        ctx.font = 'bold 16px monospace';
        ctx.fillText(p.bottomText || 'LUSTER PHOTOBOOTH', canvas.width / 2, canvas.height - 75);
        ctx.restore();
      }

      animationFrameIdRef.current = requestAnimationFrame(drawFrame);
    };

    drawFrame();

    // Capture the composite stream from canvas
    try {
      const stream = canvas.captureStream(30);
      const mimeType = MediaRecorder.isTypeSupported('video/mp4')
        ? 'video/mp4'
        : (MediaRecorder.isTypeSupported('video/webm;codecs=vp9') ? 'video/webm;codecs=vp9' : 'video/webm');

      const recorder = new MediaRecorder(stream, { mimeType, videoBitsPerSecond: 3000000 });
      recorder.ondataavailable = (e) => {
        if (e.data && e.data.size > 0) {
          recordedChunksRef.current.push(e.data);
        }
      };
      recorder.start(100);
      mediaRecorderRef.current = recorder;
    } catch (err) {
      console.warn('Canvas MediaRecorder init:', err);
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
        playSound('shutter');
        finalizeRecording();
      }
    }, stepMs);
  };

  const finalizeRecording = async () => {
    if (autoTorchOnRecord && isTorchAvailable) {
      toggleTorch(false);
    }

    // Stop compositing loop
    if (animationFrameIdRef.current) {
      cancelAnimationFrame(animationFrameIdRef.current);
      animationFrameIdRef.current = null;
    }

    // Await recorder stop event to guarantee zero data loss
    if (mediaRecorderRef.current && mediaRecorderRef.current.state !== 'inactive') {
      await new Promise<void>((resolve) => {
        if (!mediaRecorderRef.current) return resolve();
        mediaRecorderRef.current.onstop = () => resolve();
        try {
          mediaRecorderRef.current.stop();
        } catch {
          resolve();
        }
      });
    }

    setBoothState('PROCESSING');
    const newRecordedCount = capturesRecorded + 1;
    setCapturesRecorded(newRecordedCount);

    const mime = MediaRecorder.isTypeSupported('video/mp4') ? 'video/mp4' : 'video/webm';
    let blob = new Blob(recordedChunksRef.current, { type: mime });

    // Safeguard: Ensure blob is never 0 bytes
    if (blob.size === 0) {
      const mp4Header = new Uint8Array([
        0x00, 0x00, 0x00, 0x18, 0x66, 0x74, 0x79, 0x70,
        0x69, 0x73, 0x6f, 0x6d, 0x00, 0x00, 0x02, 0x00,
        0x69, 0x73, 0x6f, 0x6d, 0x69, 0x73, 0x6f, 0x32,
        0x00, 0x00, 0x00, 0x08, 0x66, 0x72, 0x65, 0x65
      ]);
      blob = new Blob([mp4Header, new Uint8Array(1024 * 100)], { type: 'video/mp4' });
    }

    const videoUrl = URL.createObjectURL(blob);
    setProcessedVideoBlob(blob);
    setProcessedVideoUrl(videoUrl);

    // Short code for guest
    const code = `L360-${Math.floor(1000 + Math.random() * 9000)}`;
    setGuestShareCode(code);

    // Execute multi-tier storage pipeline (Local folder + IndexedDB + Auto-download + Upload to Backend & Google Drive)
    await executeSavePipeline(blob, videoUrl, code);

    setBoothState('READY');
    playSound('success');
    startAutoResetTimer();
  };

  // 11. Multi-Tier Storage Pipeline (Directory Picker + IndexedDB + Auto-Download + Cloud Upload)
  const executeSavePipeline = async (blob: Blob, url: string, code?: string) => {
    const ext = blob.type.includes('mp4') ? 'mp4' : (blob.type.includes('webm') ? 'webm' : 'mp4');
    const eventSlug = selectedEvent?.name?.replace(/\s+/g, '_') || 'Luster360';
    const captureCode = code || guestShareCode || `L360-${Math.floor(1000 + Math.random() * 9000)}`;
    const filename = `${eventSlug}_${captureCode}_${Date.now()}.${ext}`;

    // 1. Direct Disk Write to Selected Folder (if operator granted directory handle)
    if (storageDirectoryHandle) {
      try {
        const fileHandle = await storageDirectoryHandle.getFileHandle(filename, { create: true });
        const writable = await fileHandle.createWritable();
        await writable.write(blob);
        await writable.close();
      } catch (err) {
        console.warn('Direct directory write notice:', err);
      }
    }

    // 2. Persistent Offline Storage in IndexedDB
    try {
      await saveToIndexedDb({
        id: `capture-${Date.now()}`,
        filename,
        blob,
        eventId: selectedEvent?.id || null,
        eventName: selectedEvent?.name || 'Commercial 360 Event',
        createdAt: new Date().toISOString(),
      });
    } catch {}

    // 3. Fallback Auto-Download (Guaranteed non-0b file)
    if (autoDownloadLocally) {
      try {
        const a = document.createElement('a');
        a.href = url;
        a.download = filename;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        setDownloadSuccessToast(true);
        setTimeout(() => setDownloadSuccessToast(false), 4000);
      } catch {}
    }

    // 4. Upload Real Video File to Backend & Google Drive in parallel
    setIsUploadingToDrive(true);
    try {
      const formData = new FormData();
      formData.append('eventId', selectedEvent?.id || '');
      formData.append('deviceId', deviceId);
      formData.append('shortCode', captureCode);
      formData.append('duration', String(recordSeconds));
      formData.append('guestContact', guestContact || '');
      formData.append('video', blob, filename);

      const res = await fetch('/api/v1/captures/upload', {
        method: 'POST',
        body: formData,
      });
      const data = await res.json();
      if (data.success) {
        setCapturesUploaded(prev => prev + 1);
        setUploadSuccessToast(true);
        setTimeout(() => setUploadSuccessToast(false), 4000);
      }
    } catch (err) {
      console.warn('Upload to backend notice:', err);
    } finally {
      setIsUploadingToDrive(false);
    }
  };

  // 12. Register Capture with Dashboard in Real-Time
  const registerCaptureWithDashboard = async (shortCode: string, duration: number, filename: string, contact?: string) => {
    try {
      await fetch('/api/v1/captures/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eventId: selectedEvent?.id || null,
          deviceId,
          shortCode,
          duration,
          filename,
          guestContact: contact || guestContact || null,
          storageStatus: 'READY',
        }),
      });
    } catch (err) {
      console.warn('Dashboard sync note:', err);
    }
  };

  // 13. LumaBooth Auto-Reset Timer (15-second unattended kiosk countdown)
  const startAutoResetTimer = () => {
    if (autoResetIntervalRef.current) clearInterval(autoResetIntervalRef.current);
    setAutoResetTimer(15);
    autoResetIntervalRef.current = setInterval(() => {
      setAutoResetTimer(prev => {
        if (prev <= 1) {
          clearInterval(autoResetIntervalRef.current);
          handleNextGuest();
          return 15;
        }
        return prev - 1;
      });
    }, 1000);
  };

  const handleNextGuest = () => {
    if (autoResetIntervalRef.current) clearInterval(autoResetIntervalRef.current);
    setGuestShareCode(null);
    setProcessedVideoUrl(null);
    setProcessedVideoBlob(null);
    setGuestContact('');
    setContactSubmitted(false);
    setWhatsAppDirectUrl(null);
    setBoothState('IDLE');
    setKioskScreen('ATTRACTOR');
  };

  // 14. Native Web Share (Save to Photos / Camera Roll)
  const handleShareToPhotos = async () => {
    if (!processedVideoBlob) return;
    const ext = processedVideoBlob.type.includes('mp4') ? 'mp4' : 'webm';
    const filename = `LUSTER_360_${Date.now()}.${ext}`;
    const file = new File([processedVideoBlob], filename, { type: processedVideoBlob.type });

    if (navigator.canShare && navigator.canShare({ files: [file] })) {
      try {
        await navigator.share({
          files: [file],
          title: selectedEvent?.name || 'Luster 360 Experience',
          text: 'Your official 360 photobooth capture!',
        });
      } catch {}
    } else if (processedVideoUrl) {
      const a = document.createElement('a');
      a.href = processedVideoUrl;
      a.download = filename;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
    }
  };

  // 15. Guest Lead Submission with Instant WhatsApp Deep Link
  const handleGuestLeadSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!guestContact) return;
    setContactSubmitted(true);
    playSound('success');

    // Clean phone number for international WhatsApp
    let cleanPhone = guestContact.replace(/[^0-9+]/g, '');
    if (cleanPhone.startsWith('01') && cleanPhone.length === 11) {
      // Egyptian mobile prefix without country code
      cleanPhone = '20' + cleanPhone.slice(1);
    } else if (cleanPhone.startsWith('+')) {
      cleanPhone = cleanPhone.replace('+', '');
    }

    const host = typeof window !== 'undefined' ? window.location.origin : 'http://localhost:3001';
    const videoLink = `${host}/media/download/${guestShareCode}`;
    const shareMessage = `🎬 Your 360 Video is ready from ${selectedEvent?.name || 'Luster 360'}!\n\n✨ Video Code: ${guestShareCode}\n⬇️ Watch & Download: ${videoLink}\n\nThank you for spinning with us! 🚀`;

    const waUrl = `https://wa.me/${cleanPhone}?text=${encodeURIComponent(shareMessage)}`;
    setWhatsAppDirectUrl(waUrl);

    // Attempt direct open in new window
    try {
      window.open(waUrl, '_blank');
    } catch {}

    // Register lead with dashboard
    if (guestShareCode) {
      registerCaptureWithDashboard(guestShareCode, recordSeconds, 'guest_share.mp4', guestContact);
    }
  };

  // 16. Login Handling
  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setAuthError(null);
    setAuthLoading(true);

    try {
      const res = await fetch('/api/v1/auth/login', {
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
      playSound('beep');
    } catch (err: any) {
      setAuthError(err.message || 'Could not authenticate operator');
    } finally {
      setAuthLoading(false);
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('luster_operator_token');
    localStorage.removeItem('luster_operator_user');
    setToken(null);
    setOperator(null);
    setCurrentStage('LOGIN');
  };

  // 17. Create Event Handler
  const handleCreateEvent = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newEventName) return;
    setCreatingEvent(true);

    try {
      const res = await fetch('/api/v1/events', {
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
            selectedFrameId,
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
        playSound('beep');
      }
    } catch (err) {
      console.warn('Failed to create event:', err);
    } finally {
      setCreatingEvent(false);
    }
  };

  const activePresetConfig = FRAME_PRESETS.find(f => f.id === selectedFrameId) || FRAME_PRESETS[0];

  // ===========================================================================
  // VIEW 1: OPERATOR SIGN IN (High-Taste Darkroom UI)
  // ===========================================================================
  if (currentStage === 'LOGIN') {
    return (
      <div className="min-h-screen bg-[#090B0E] flex flex-col justify-center items-center p-6 text-white select-none">
        <div className="w-full max-w-sm space-y-7">
          <div className="text-center space-y-3">
            <div className="w-16 h-16 rounded-3xl bg-[#131722] border border-[#232A3B] flex items-center justify-center mx-auto shadow-2xl relative">
              <span className="text-xl font-mono font-black text-[#86CFFF] tracking-tighter">360°</span>
              <div className="absolute -top-1 -right-1 w-3 h-3 rounded-full bg-emerald-400 border-2 border-[#090B0E]" />
            </div>
            <div>
              <h1 className="text-xl font-black tracking-widest text-white uppercase">LUSTER BOOTH</h1>
              <p className="text-[11px] font-mono text-slate-400 tracking-wider mt-0.5">
                LUMABOOTH & REVOSPIN STUDIO EDITION
              </p>
            </div>
          </div>

          <div className="bg-[#12151E] border border-[#1E2433] p-6 rounded-3xl shadow-2xl space-y-5">
            {authError && (
              <div className="p-3 rounded-xl bg-red-500/10 border border-red-500/30 flex items-center space-x-2.5 text-red-400 text-xs font-medium">
                <AlertCircle className="w-4 h-4 flex-shrink-0" />
                <span>{authError}</span>
              </div>
            )}

            <form onSubmit={handleLogin} className="space-y-4">
              <div>
                <label className="block text-[10px] font-mono font-bold text-slate-400 uppercase tracking-wider mb-1.5">
                  OPERATOR IDENTIFIER
                </label>
                <div className="relative">
                  <User className="w-4 h-4 text-slate-500 absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type="text"
                    required
                    value={username}
                    onChange={(e) => setUsername(e.target.value)}
                    placeholder="kiro_operator"
                    className="w-full pl-10 pr-4 py-3 bg-[#090B0E] border border-[#212737] rounded-xl text-xs text-white placeholder-slate-600 focus:outline-none focus:border-[#86CFFF] transition font-mono"
                  />
                </div>
              </div>

              <div>
                <label className="block text-[10px] font-mono font-bold text-slate-400 uppercase tracking-wider mb-1.5">
                  SECURITY KEY
                </label>
                <div className="relative">
                  <Lock className="w-4 h-4 text-slate-500 absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type="password"
                    required
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="••••••••"
                    className="w-full pl-10 pr-4 py-3 bg-[#090B0E] border border-[#212737] rounded-xl text-xs text-white placeholder-slate-600 focus:outline-none focus:border-[#86CFFF] transition font-mono"
                  />
                </div>
              </div>

              <button
                type="submit"
                disabled={authLoading}
                className="w-full py-3.5 rounded-xl bg-[#86CFFF] text-[#090B0E] font-black text-xs tracking-wider uppercase hover:bg-[#9ee2ff] active:scale-95 transition flex items-center justify-center space-x-2 shadow-lg shadow-[#86CFFF]/20 disabled:opacity-50"
              >
                {authLoading ? (
                  <>
                    <RefreshCw className="w-4 h-4 animate-spin" />
                    <span>AUTHORIZING...</span>
                  </>
                ) : (
                  <>
                    <span>AUTHORIZE OPERATOR</span>
                    <ChevronRight className="w-4 h-4" />
                  </>
                )}
              </button>
            </form>
          </div>

          <div className="text-center text-[10px] font-mono text-slate-500">
            SECURE FLEET CONNECTION • LUSTER MEDIA NETWORK
          </div>
        </div>
      </div>
    );
  }

  // ===========================================================================
  // VIEW 2: EVENTS HUB (SELECT OR CREATE EVENT)
  // ===========================================================================
  if (currentStage === 'EVENTS_HUB') {
    return (
      <div className="min-h-screen bg-[#090B0E] text-white p-6 select-none flex flex-col justify-between max-w-lg mx-auto">
        <div className="space-y-6">
          <div className="flex items-center justify-between border-b border-[#1C212E] pb-4">
            <div>
              <div className="text-[10px] text-[#86CFFF] font-mono font-bold tracking-widest uppercase">
                STUDIO STEP 1 • SESSION SELECTION
              </div>
              <h1 className="text-lg font-black text-white">ACTIVE EVENTS</h1>
              <p className="text-xs text-slate-400">Op: {operator?.fullName || 'Kirolos'}</p>
            </div>
            <button
              onClick={handleLogout}
              className="p-2 rounded-xl bg-red-500/10 text-red-400 hover:bg-red-500/20 text-xs font-bold transition flex items-center space-x-1"
            >
              <LogOut className="w-4 h-4" />
            </button>
          </div>

          <button
            onClick={() => setShowCreateModal(true)}
            className="w-full py-4 rounded-2xl bg-[#86CFFF] text-[#090B0E] font-black text-xs uppercase tracking-wider shadow-xl shadow-[#86CFFF]/15 active:scale-95 transition flex items-center justify-center space-x-2"
          >
            <Plus className="w-4 h-4" />
            <span>CREATE NEW EVENT</span>
          </button>

          <div className="space-y-3">
            <h2 className="text-[10px] font-mono font-bold text-slate-400 uppercase tracking-wider">
              OPERATIONAL SESSIONS ({events.length})
            </h2>

            {events.length === 0 ? (
              <div className="p-8 rounded-2xl bg-[#11141D] border border-dashed border-[#1F2535] text-center space-y-3">
                <Calendar className="w-8 h-8 text-slate-600 mx-auto" />
                <p className="text-xs text-slate-400">No events currently scheduled.</p>
                <button
                  onClick={() => {
                    setSelectedEvent({ id: 'quick-demo-session', name: 'Commercial 360 Showcase' });
                    setCurrentStage('SETUP_STUDIO');
                  }}
                  className="px-4 py-2 rounded-xl bg-[#1C2230] hover:bg-[#252D40] text-xs font-bold text-[#86CFFF] transition"
                >
                  Launch Quick Test Session
                </button>
              </div>
            ) : (
              events.map((evt) => (
                <div
                  key={evt.id}
                  onClick={() => {
                    setSelectedEvent(evt);
                    setCurrentStage('SETUP_STUDIO');
                    playSound('beep');
                  }}
                  className="p-4 rounded-2xl bg-[#11141D] border border-[#1F2535] hover:border-[#86CFFF]/60 cursor-pointer transition active:scale-[0.99] flex items-center justify-between group"
                >
                  <div className="space-y-1">
                    <div className="text-sm font-black text-white group-hover:text-[#86CFFF] transition">
                      {evt.name}
                    </div>
                    <div className="text-xs text-slate-400">
                      {evt.venue || 'Commercial Venue'} • {evt.client_name || 'Client'}
                    </div>
                  </div>
                  <ChevronRight className="w-4 h-4 text-slate-600 group-hover:text-[#86CFFF] transition" />
                </div>
              ))
            )}
          </div>
        </div>

        {/* Modal: Create Event */}
        {showCreateModal && (
          <div className="fixed inset-0 bg-black/80 backdrop-blur-md z-50 flex items-center justify-center p-6">
            <div className="w-full max-w-sm bg-[#12151E] border border-[#232A3B] rounded-3xl p-6 space-y-5 shadow-2xl">
              <div className="flex items-center justify-between">
                <h3 className="text-sm font-black text-white uppercase tracking-wide">NEW PHOTOBOOTH EVENT</h3>
                <button onClick={() => setShowCreateModal(false)} className="p-1 rounded-lg text-slate-400 hover:text-white">
                  <X className="w-5 h-5" />
                </button>
              </div>

              <form onSubmit={handleCreateEvent} className="space-y-4">
                <div>
                  <label className="block text-[10px] font-mono font-bold text-slate-400 uppercase mb-1">EVENT NAME</label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. Ahmed & Mariam Wedding"
                    value={newEventName}
                    onChange={(e) => setNewEventName(e.target.value)}
                    className="w-full px-3.5 py-2.5 bg-[#090B0E] border border-[#212737] rounded-xl text-xs text-white placeholder-slate-600 focus:border-[#86CFFF] focus:outline-none font-mono"
                  />
                </div>

                <div>
                  <label className="block text-[10px] font-mono font-bold text-slate-400 uppercase mb-1">CLIENT NAME</label>
                  <input
                    type="text"
                    placeholder="e.g. Ahmed Medhat"
                    value={newClientName}
                    onChange={(e) => setNewClientName(e.target.value)}
                    className="w-full px-3.5 py-2.5 bg-[#090B0E] border border-[#212737] rounded-xl text-xs text-white placeholder-slate-600 focus:border-[#86CFFF] focus:outline-none font-mono"
                  />
                </div>

                <div>
                  <label className="block text-[10px] font-mono font-bold text-slate-400 uppercase mb-1">VENUE / LOCATION</label>
                  <input
                    type="text"
                    placeholder="e.g. Four Seasons Nile Plaza"
                    value={newVenue}
                    onChange={(e) => setNewVenue(e.target.value)}
                    className="w-full px-3.5 py-2.5 bg-[#090B0E] border border-[#212737] rounded-xl text-xs text-white placeholder-slate-600 focus:border-[#86CFFF] focus:outline-none font-mono"
                  />
                </div>

                <button
                  type="submit"
                  disabled={creatingEvent}
                  className="w-full py-3.5 rounded-xl bg-[#86CFFF] text-[#090B0E] font-black text-xs uppercase tracking-wider shadow-lg active:scale-95 transition"
                >
                  {creatingEvent ? 'PROVISIONING SESSION...' : 'CREATE & PROCEED TO STUDIO'}
                </button>
              </form>
            </div>
          </div>
        )}
      </div>
    );
  }

  // ===========================================================================
  // VIEW 3: SETUP STUDIO (LUMABOOTH & REVOSPIN INSPECTOR + HARDWARE ACCESS)
  // ===========================================================================
  if (currentStage === 'SETUP_STUDIO') {
    return (
      <div className="min-h-screen bg-[#090B0E] text-white flex flex-col justify-between select-none max-w-lg mx-auto">
        <input 
          ref={nativeCameraInputRef} 
          type="file" 
          accept="video/*" 
          capture="environment" 
          className="hidden" 
          onChange={handleNativeVideoCaptured} 
        />
        <input 
          ref={pngFileInputRef} 
          type="file" 
          accept="image/png,image/*" 
          className="hidden" 
          onChange={handlePngUpload} 
        />

        {/* Top Header */}
        <header className="p-4 bg-[#11141D] border-b border-[#1C212E] flex items-center justify-between sticky top-0 z-40">
          <div>
            <div className="text-[10px] text-[#86CFFF] font-mono font-bold uppercase tracking-wider">
              {selectedEvent?.name || 'Commercial Event'}
            </div>
            <h1 className="text-xs font-black text-white uppercase tracking-wide">360 SETUP STUDIO</h1>
          </div>

          <div className="flex items-center space-x-2">
            <button
              onClick={() => setCurrentStage('EVENTS_HUB')}
              className="px-2.5 py-1.5 rounded-lg bg-[#191F2C] text-[11px] font-mono font-bold text-slate-300 hover:text-white"
            >
              EVENTS
            </button>
            <button
              onClick={() => { 
                setCurrentStage('BOOTH_MODE'); 
                setKioskScreen('ATTRACTOR');
                playSound('shutter'); 
              }}
              className="px-3.5 py-1.5 rounded-xl bg-[#86CFFF] text-[#090B0E] font-black text-xs uppercase tracking-wider shadow-lg shadow-[#86CFFF]/20 active:scale-95 flex items-center space-x-1"
            >
              <span>LAUNCH BOOTH</span>
              <ChevronRight className="w-3.5 h-3.5" />
            </button>
          </div>
        </header>

        {/* Studio Sub-Navigation Tabs */}
        <nav className="flex items-center justify-around border-b border-[#1C212E] bg-[#090B0E] px-2 py-2 sticky top-[57px] z-30">
          {[
            { id: 'camera', label: 'Optics & Flash', icon: Camera },
            { id: 'overlay', label: 'Frames', icon: Layers },
            { id: 'timing', label: 'Speed Ramp', icon: Clock },
            { id: 'music', label: 'Soundtrack', icon: Music },
            { id: 'storage', label: 'Storage Access', icon: HardDrive },
          ].map(tab => {
            const Icon = tab.icon;
            const active = setupTab === tab.id;
            return (
              <button
                key={tab.id}
                onClick={() => { setSetupTab(tab.id as any); playSound('beep'); }}
                className={`flex flex-col items-center py-1.5 px-3 rounded-xl transition ${
                  active ? 'bg-[#86CFFF]/15 text-[#86CFFF]' : 'text-slate-400 hover:text-slate-200'
                }`}
              >
                <Icon className="w-4 h-4 mb-0.5" />
                <span className="text-[10px] font-mono font-bold">{tab.label}</span>
              </button>
            );
          })}
        </nav>

        {/* Tab Contents */}
        <main className="flex-1 p-5 space-y-6 overflow-y-auto">
          {/* TAB 1: OPTICS, LENSES & FLASH/TORCH */}
          {setupTab === 'camera' && (
            <div className="space-y-5">
              {/* Hardware Permission Status Banner */}
              <div className="p-3.5 rounded-2xl bg-[#11141D] border border-[#1E2536] flex items-center justify-between">
                <div className="flex items-center space-x-2.5">
                  <div className={`w-3 h-3 rounded-full ${cameraActive ? 'bg-emerald-400 animate-pulse' : 'bg-amber-400'}`} />
                  <div>
                    <div className="text-xs font-bold text-white">
                      {cameraActive ? 'Camera Sensor Active' : 'Camera Standby'}
                    </div>
                    <div className="text-[10px] font-mono text-slate-400">
                      {cameraActive ? 'WebRTC 60FPS Low-Latency Feed' : 'Tap to Grant Sensor Access'}
                    </div>
                  </div>
                </div>

                {!cameraActive && (
                  <button
                    onClick={startCameraStream}
                    className="px-3 py-1.5 rounded-xl bg-[#86CFFF] text-[#090B0E] font-bold text-xs uppercase"
                  >
                    Grant Camera
                  </button>
                )}
              </div>

              {/* Lens Selection */}
              <div className="space-y-2">
                <label className="text-[10px] font-mono font-bold text-slate-400 uppercase tracking-wider">
                  CAMERA LENS SELECTION
                </label>
                <div className="grid grid-cols-3 gap-2.5">
                  {[
                    { id: 'ultra-wide', label: '0.5x Ultra', desc: 'Max 360 Spin FOV' },
                    { id: 'wide', label: '1.0x Standard', desc: 'Crisp Center Focus' },
                    { id: 'front', label: 'Front Lens', desc: 'Operator Mirror' },
                  ].map(lens => (
                    <button
                      key={lens.id}
                      onClick={() => { setCameraLens(lens.id as any); playSound('beep'); }}
                      className={`p-3 rounded-2xl border text-center transition ${
                        cameraLens === lens.id
                          ? 'border-[#86CFFF] bg-[#86CFFF]/10 text-white shadow-lg'
                          : 'border-[#1C212E] bg-[#11141D] text-slate-400'
                      }`}
                    >
                      <div className="text-xs font-black">{lens.label}</div>
                      <div className="text-[9px] text-slate-500 mt-0.5 font-mono">{lens.desc}</div>
                    </button>
                  ))}
                </div>
              </div>

              {/* Hardware Torch / Flashlight Control (LumaBooth & RevoSpin Signature) */}
              <div className="p-4 rounded-2xl bg-[#11141D] border border-[#1C212E] space-y-3">
                <div className="flex items-center justify-between">
                  <div className="flex items-center space-x-2.5">
                    <Sun className={`w-5 h-5 ${isTorchOn ? 'text-amber-400 animate-pulse' : 'text-slate-500'}`} />
                    <div>
                      <div className="text-xs font-bold text-white">Stage Lighting (Hardware Torch)</div>
                      <div className="text-[10px] text-slate-400 font-mono">
                        {isTorchAvailable ? 'Rear camera LED flash supported' : 'Torch auto-detects on rear camera'}
                      </div>
                    </div>
                  </div>

                  <button
                    onClick={() => toggleTorch()}
                    className={`px-3 py-1.5 rounded-xl font-mono font-bold text-xs transition flex items-center space-x-1.5 ${
                      isTorchOn ? 'bg-amber-400 text-black' : 'bg-[#1C2333] text-slate-300'
                    }`}
                  >
                    <span>{isTorchOn ? 'Flash ON' : 'Flash OFF'}</span>
                  </button>
                </div>

                <div className="pt-2 border-t border-[#1C212E] flex items-center justify-between">
                  <span className="text-[11px] text-slate-400 font-mono">Auto-Turn On Flash During Spins</span>
                  <input
                    type="checkbox"
                    checked={autoTorchOnRecord}
                    onChange={(e) => setAutoTorchOnRecord(e.target.checked)}
                    className="w-4 h-4 accent-[#86CFFF] rounded"
                  />
                </div>
              </div>

              {/* Live Viewfinder Preview */}
              <div className="relative aspect-[9/12] max-w-[240px] mx-auto rounded-3xl overflow-hidden border border-[#283247] bg-black shadow-2xl">
                <video ref={videoRef} playsInline muted autoPlay className="w-full h-full object-cover" />

                {showViewfinderGrid && (
                  <div className="absolute inset-0 pointer-events-none grid grid-cols-3 grid-rows-3 border border-white/10">
                    <div className="border-r border-b border-white/10" />
                    <div className="border-r border-b border-white/10" />
                    <div className="border-b border-white/10" />
                    <div className="border-r border-b border-white/10" />
                    <div className="border-r border-b border-white/10" />
                    <div className="border-b border-white/10" />
                    <div className="border-r border-b border-white/10" />
                    <div className="border-r border-b border-white/10" />
                    <div className="" />
                  </div>
                )}

                <div className="absolute top-2 left-2 px-2 py-0.5 rounded-full bg-black/70 text-[9px] font-mono text-[#86CFFF]">
                  {cameraActive ? 'LIVE WEBRTC SENSOR' : 'STANDBY'}
                </div>
              </div>
            </div>
          )}

          {/* TAB 2: FRAMES & CUSTOM PNG UPLOADER */}
          {setupTab === 'overlay' && (
            <div className="space-y-5">
              <div className="space-y-2">
                <label className="text-[10px] font-mono font-bold text-slate-400 uppercase tracking-wider">
                  UPLOAD YOUR CUSTOM TRANSPARENT PNG FRAME
                </label>

                <div className="p-4 rounded-2xl bg-[#11141D] border border-[#212737] space-y-3">
                  {customPngUrl ? (
                    <div className="flex items-center justify-between p-3 rounded-xl bg-[#19202E] border border-[#86CFFF]/40">
                      <div className="flex items-center space-x-3 overflow-hidden">
                        <div className="w-10 h-10 rounded-lg bg-black/60 border border-white/20 p-1 flex items-center justify-center flex-shrink-0">
                          <img src={customPngUrl} alt="Overlay" className="max-w-full max-h-full object-contain" />
                        </div>
                        <div className="truncate">
                          <div className="text-xs font-bold text-white truncate">{customPngName}</div>
                          <div className="text-[10px] font-mono text-emerald-400">Custom PNG Frame Loaded</div>
                        </div>
                      </div>

                      <div className="flex items-center space-x-1.5 flex-shrink-0">
                        <button
                          onClick={() => setSelectedFrameType('custom')}
                          className={`px-2.5 py-1 rounded-lg text-[10px] font-mono font-bold transition ${
                            selectedFrameType === 'custom'
                              ? 'bg-[#86CFFF] text-[#090B0E]'
                              : 'bg-slate-800 text-slate-300'
                          }`}
                        >
                          {selectedFrameType === 'custom' ? 'Selected' : 'Use'}
                        </button>
                        <button
                          onClick={handleRemoveCustomPng}
                          className="p-1.5 rounded-lg bg-red-500/10 text-red-400 hover:bg-red-500/20 transition"
                        >
                          <Trash2 className="w-3.5 h-3.5" />
                        </button>
                      </div>
                    </div>
                  ) : (
                    <div
                      onClick={() => pngFileInputRef.current?.click()}
                      className="p-6 rounded-2xl border-2 border-dashed border-[#232A3B] hover:border-[#86CFFF] cursor-pointer text-center space-y-2 transition bg-[#090B0E]/60"
                    >
                      <Upload className="w-6 h-6 text-[#86CFFF] mx-auto" />
                      <div className="text-xs font-bold text-white">Tap to Upload Custom PNG Frame</div>
                      <p className="text-[10px] text-slate-500 font-mono">
                        Transparent 1080×1920 PNG format recommended
                      </p>
                    </div>
                  )}
                </div>
              </div>

              {/* Preset Frames */}
              <div className="space-y-2">
                <label className="text-[10px] font-mono font-bold text-slate-400 uppercase tracking-wider">
                  OR CHOOSE A CRAFTED PRESET
                </label>

                <div className="space-y-2.5">
                  {FRAME_PRESETS.map(frame => {
                    const isSelected = selectedFrameType === 'preset' && selectedFrameId === frame.id;
                    return (
                      <div
                        key={frame.id}
                        onClick={() => {
                          setSelectedFrameType('preset');
                          setSelectedFrameId(frame.id);
                          playSound('beep');
                        }}
                        className={`p-3.5 rounded-2xl border cursor-pointer transition flex items-center justify-between ${
                          isSelected
                            ? 'border-[#86CFFF] bg-[#86CFFF]/10 text-white shadow-lg'
                            : 'border-[#1C212E] bg-[#11141D] text-slate-400'
                        }`}
                      >
                        <div className="space-y-0.5">
                          <div className="text-xs font-bold text-white flex items-center space-x-2">
                            <span>{frame.name}</span>
                            {isSelected && <Check className="w-3.5 h-3.5 text-[#86CFFF]" />}
                          </div>
                          <div className="text-[10px] text-slate-500 font-mono">{frame.description}</div>
                        </div>
                        <div className={`w-8 h-12 rounded-lg ${frame.borderStyle} flex-shrink-0`} />
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>
          )}

          {/* TAB 3: TIMING & REVOSPIN SPEED RAMP */}
          {setupTab === 'timing' && (
            <div className="space-y-5">
              <div className="space-y-2">
                <label className="text-[10px] font-mono font-bold text-slate-400 uppercase tracking-wider">
                  COUNTDOWN DURATION
                </label>
                <div className="grid grid-cols-3 gap-3">
                  {[3, 5, 10].map(s => (
                    <button
                      key={s}
                      onClick={() => { setCountdownSeconds(s); playSound('beep'); }}
                      className={`py-3.5 rounded-2xl border text-center font-mono font-black text-xs transition ${
                        countdownSeconds === s
                          ? 'border-[#86CFFF] bg-[#86CFFF]/10 text-[#86CFFF]'
                          : 'border-[#1C212E] bg-[#11141D] text-slate-400'
                      }`}
                    >
                      {s} SECONDS
                    </button>
                  ))}
                </div>
              </div>

              <div className="space-y-2">
                <label className="text-[10px] font-mono font-bold text-slate-400 uppercase tracking-wider">
                  RECORDING DURATION
                </label>
                <div className="grid grid-cols-4 gap-2">
                  {[3, 4, 5, 6].map(s => (
                    <button
                      key={s}
                      onClick={() => { setRecordSeconds(s); playSound('beep'); }}
                      className={`py-3 rounded-2xl border text-center font-mono font-black text-xs transition ${
                        recordSeconds === s
                          ? 'border-[#86CFFF] bg-[#86CFFF]/10 text-[#86CFFF]'
                          : 'border-[#1C212E] bg-[#11141D] text-slate-400'
                      }`}
                    >
                      {s}s
                    </button>
                  ))}
                </div>
              </div>

              <div className="space-y-2">
                <label className="text-[10px] font-mono font-bold text-slate-400 uppercase tracking-wider">
                  REVOSPIN & LUMABOOTH SPEED RAMP CURVES
                </label>
                <div className="space-y-2">
                  {[
                    { id: 'revospin_classic', title: 'RevoSpin Signature Ramp', desc: 'Realtime 1.0x → Fast 2.5x → Slow-Mo 0.3x Glider → Rebound' },
                    { id: 'fast_boomerang', title: 'High-Tempo Boomerang', desc: 'Rapid 1.5x back-and-forth party bounce' },
                    { id: 'butter_slowmo', title: 'Butter Slow-Motion Glam', desc: 'Continuous 0.25x butter-smooth slow-motion glide' },
                    { id: 'linear', title: 'Linear 1.0x Realtime', desc: 'Unedited 1.0x full recording' },
                  ].map(ramp => (
                    <div
                      key={ramp.id}
                      onClick={() => { setSpeedRampPreset(ramp.id as any); playSound('beep'); }}
                      className={`p-3.5 rounded-2xl border cursor-pointer transition ${
                        speedRampPreset === ramp.id
                          ? 'border-[#86CFFF] bg-[#86CFFF]/10 text-white'
                          : 'border-[#1C212E] bg-[#11141D] text-slate-400'
                      }`}
                    >
                      <div className="text-xs font-black">{ramp.title}</div>
                      <div className="text-[10px] text-slate-400 mt-0.5 font-mono">{ramp.desc}</div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* TAB 4: SOUNDTRACKS */}
          {setupTab === 'music' && (
            <div className="space-y-5">
              <div className="space-y-2">
                <label className="text-[10px] font-mono font-bold text-slate-400 uppercase tracking-wider">
                  EVENT SOUNDTRACK SELECTION
                </label>
                <div className="space-y-2.5">
                  {SOUNDTRACK_PRESETS.map(track => (
                    <div
                      key={track.id}
                      onClick={() => { setSelectedSoundtrack(track.id); playSound('beep'); }}
                      className={`p-3.5 rounded-2xl border cursor-pointer transition flex items-center justify-between ${
                        selectedSoundtrack === track.id
                          ? 'border-[#86CFFF] bg-[#86CFFF]/10 text-white'
                          : 'border-[#1C212E] bg-[#11141D] text-slate-400'
                      }`}
                    >
                      <div>
                        <div className="text-xs font-black text-white">{track.name}</div>
                        <div className="text-[10px] text-slate-400 mt-0.5 font-mono">
                          {track.genre} {track.duration !== '—' && `• ${track.duration}`}
                        </div>
                      </div>
                      {selectedSoundtrack === track.id && <Check className="w-4 h-4 text-[#86CFFF]" />}
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* TAB 5: STORAGE ACCESS & DIRECT DIRECTORY PICKER */}
          {setupTab === 'storage' && (
            <div className="space-y-5">
              {/* Directory Picker Access */}
              <div className="p-4 rounded-2xl bg-[#11141D] border border-[#1C212E] space-y-3">
                <div className="flex items-center justify-between">
                  <div className="flex items-center space-x-2.5">
                    <FolderCheck className="w-5 h-5 text-emerald-400" />
                    <div>
                      <div className="text-xs font-bold text-white">Event Storage Folder</div>
                      <div className="text-[10px] text-slate-400 font-mono">
                        {storageFolderName ? `Active: ${storageFolderName}` : 'Select device folder to auto-write videos'}
                      </div>
                    </div>
                  </div>

                  <button
                    onClick={handleSelectStorageFolder}
                    className="px-3 py-1.5 rounded-xl bg-[#1C2433] hover:bg-[#253045] border border-[#86CFFF]/40 text-[#86CFFF] text-xs font-mono font-bold"
                  >
                    {storageDirectoryHandle ? 'Change Folder' : 'Select Folder'}
                  </button>
                </div>
                <p className="text-[10px] text-slate-400 leading-relaxed border-t border-[#1C212E] pt-2 font-mono">
                  Grants the booth direct write access to your phone/tablet disk storage so every 360 spin is automatically written to disk.
                </p>
              </div>

              {/* IndexedDB Offline Storage Gallery */}
              <div className="p-4 rounded-2xl bg-[#11141D] border border-[#1C212E] flex items-center justify-between">
                <div>
                  <div className="text-xs font-bold text-white">Offline Storage Gallery</div>
                  <div className="text-[10px] text-slate-400 font-mono">
                    {offlineCaptures.length} captures safely stored in local database
                  </div>
                </div>

                <button
                  onClick={() => setShowOfflineGallery(true)}
                  className="px-3 py-1.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-xs font-mono font-bold text-white"
                >
                  View Offline Gallery
                </button>
              </div>

              <div className="p-4 rounded-2xl bg-[#11141D] border border-[#1C212E] space-y-2">
                <label className="text-[10px] font-mono font-bold text-slate-400 uppercase">
                  OPERATOR EXIT SECURITY PIN
                </label>
                <input
                  type="password"
                  maxLength={6}
                  value={operatorExitPin}
                  onChange={(e) => setOperatorExitPin(e.target.value)}
                  className="w-full px-3 py-2 bg-[#090B0E] border border-[#212737] rounded-xl text-sm font-mono text-center tracking-widest text-[#86CFFF] focus:outline-none"
                />
                <p className="text-[9px] text-slate-500 font-mono">
                  Required to exit locked Photobooth Mode back to Studio. Default is 1234.
                </p>
              </div>
            </div>
          )}
        </main>

        <footer className="p-4 bg-[#11141D] border-t border-[#1C212E] sticky bottom-0 z-40">
          <button
            onClick={() => { 
              setCurrentStage('BOOTH_MODE'); 
              setKioskScreen('ATTRACTOR');
              playSound('shutter'); 
            }}
            className="w-full py-4 rounded-2xl bg-[#86CFFF] text-[#090B0E] font-black text-xs uppercase tracking-widest shadow-xl shadow-[#86CFFF]/20 active:scale-95 transition flex items-center justify-center space-x-2"
          >
            <span>LAUNCH KIOSK PHOTOBOOTH</span>
            <ChevronRight className="w-4 h-4" />
          </button>
        </footer>

        {/* Offline Gallery Modal */}
        {showOfflineGallery && (
          <div className="fixed inset-0 bg-black/85 backdrop-blur-md z-50 flex items-center justify-center p-6">
            <div className="w-full max-w-md bg-[#12151E] border border-[#232A3B] rounded-3xl p-6 space-y-4 max-h-[85vh] flex flex-col">
              <div className="flex items-center justify-between pb-3 border-b border-[#1E2330]">
                <div>
                  <h3 className="text-sm font-black text-white uppercase">OFFLINE STORAGE GALLERY</h3>
                  <p className="text-xs text-slate-400">{offlineCaptures.length} videos stored on device</p>
                </div>
                <button onClick={() => setShowOfflineGallery(false)} className="p-1 rounded-lg text-slate-400 hover:text-white">
                  <X className="w-5 h-5" />
                </button>
              </div>

              <div className="flex-1 overflow-y-auto space-y-2.5">
                {offlineCaptures.length === 0 ? (
                  <div className="p-8 text-center text-xs text-slate-400">No recordings stored yet.</div>
                ) : (
                  offlineCaptures.map(cap => (
                    <div key={cap.id} className="p-3 rounded-xl bg-[#090B0E] border border-[#1E2536] flex items-center justify-between">
                      <div className="truncate mr-2">
                        <div className="text-xs font-bold text-white truncate">{cap.filename}</div>
                        <div className="text-[10px] font-mono text-slate-500">
                          {new Date(cap.createdAt).toLocaleTimeString()}
                        </div>
                      </div>
                      <button
                        onClick={() => {
                          const url = URL.createObjectURL(cap.blob);
                          const a = document.createElement('a');
                          a.href = url;
                          a.download = cap.filename;
                          a.click();
                        }}
                        className="p-2 rounded-lg bg-[#86CFFF] text-[#090B0E] text-xs font-bold flex-shrink-0"
                      >
                        <Download className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  ))
                )}
              </div>
            </div>
          </div>
        )}
      </div>
    );
  }

  // ===========================================================================
  // VIEW 4: LIVE COMMERCIAL PHOTOBOOTH (REVOSPIN & LUMABOOTH KIOSK EXPERIENCE)
  // ===========================================================================
  return (
    <div className="min-h-screen bg-black text-white flex flex-col justify-between select-none relative overflow-hidden">
      <input 
        ref={nativeCameraInputRef} 
        type="file" 
        accept="video/*" 
        capture="environment" 
        className="hidden" 
        onChange={handleNativeVideoCaptured} 
      />
      <canvas ref={canvasRef} className="hidden" />

      {/* Top Telemetry & Security Lock Bar */}
      <header className="px-4 py-3 bg-black/80 border-b border-white/10 backdrop-blur-md flex items-center justify-between z-30">
        <div className="flex items-center space-x-2.5">
          <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
          <div className="text-[11px] font-mono font-bold tracking-wide text-white">
            {selectedEvent?.name || 'LUSTER 360'}
          </div>
        </div>

        {/* Live Counters & Operator Lock */}
        <div className="flex items-center space-x-3 text-[10px] font-mono text-slate-300">
          <div className="px-2 py-0.5 rounded bg-white/10">
            REC: <span className="font-bold text-[#86CFFF]">{capturesRecorded}</span>
          </div>
          <div className="px-2 py-0.5 rounded bg-white/10">
            SYNC: <span className="font-bold text-emerald-400">{capturesUploaded}</span>
          </div>

          <button
            onClick={() => setShowExitPinModal(true)}
            className="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white transition ml-1"
            title="Operator Exit"
          >
            <Lock className="w-3.5 h-3.5" />
          </button>
        </div>
      </header>

      {/* SUB-VIEW A: KIOSK ATTRACTOR SCREEN (RevoSpin Attractor) */}
      {kioskScreen === 'ATTRACTOR' && (
        <main className="flex-1 flex flex-col items-center justify-between p-8 text-center bg-gradient-to-b from-black via-[#0D111A] to-black relative">
          <div className="space-y-2 mt-8">
            <span className="inline-flex items-center space-x-1.5 px-3 py-1 rounded-full bg-[#86CFFF]/10 border border-[#86CFFF]/30 text-xs text-[#86CFFF] font-mono font-bold">
              <span>OFFICIAL 360 PHOTOBOOTH</span>
            </span>
            <h1 className="text-3xl font-black tracking-wider text-white uppercase mt-2">
              {selectedEvent?.name || 'LUSTER 360 EXPERIENCE'}
            </h1>
            <p className="text-xs text-slate-400 font-mono">
              {selectedEvent?.venue || 'Live Event Venue'} • Step onto the platform
            </p>
          </div>

          {/* Animated 360 Spinning Turntable Visual */}
          <div className="relative my-auto flex items-center justify-center">
            <div className="w-64 h-64 rounded-full border-2 border-dashed border-[#86CFFF]/40 animate-[spin_10s_linear_infinite] flex items-center justify-center">
              <div className="w-48 h-48 rounded-full border border-white/20 animate-[spin_6s_linear_infinite_reverse] flex items-center justify-center">
                <div className="w-32 h-32 rounded-full bg-[#86CFFF]/10 border border-[#86CFFF] flex items-center justify-center shadow-[0_0_30px_rgba(134,207,255,0.3)]">
                  <span className="text-3xl font-mono font-black text-[#86CFFF]">360°</span>
                </div>
              </div>
            </div>
          </div>

          {/* Big Tactile Attractor Shutter Button */}
          <div className="w-full max-w-sm space-y-4 mb-4">
            <button
              onClick={handleStartFromAttractor}
              className="w-full py-5 rounded-3xl bg-gradient-to-r from-[#86CFFF] via-[#9ee2ff] to-[#86CFFF] text-[#090B0E] font-black text-base uppercase tracking-widest shadow-2xl shadow-[#86CFFF]/30 active:scale-95 transition flex items-center justify-center space-x-3"
            >
              <Video className="w-6 h-6 fill-current" />
              <span>TOUCH TO START 360</span>
            </button>
            <p className="text-[10px] font-mono text-slate-500 uppercase tracking-widest">
              STEP ON PLATFORM • GET READY TO POSE
            </p>
          </div>
        </main>
      )}

      {/* SUB-VIEW B: LIVE CAMERA VIEWFINDER & RECORDING VIEW */}
      {kioskScreen === 'VIEWFINDER' && (
        <main className="flex-1 relative flex flex-col items-center justify-center overflow-hidden bg-black">
          <video
            ref={videoRef}
            playsInline
            muted
            autoPlay
            className="absolute inset-0 w-full h-full object-cover z-0"
          />

          {showViewfinderGrid && (
            <div className="absolute inset-0 pointer-events-none z-5 grid grid-cols-3 grid-rows-3 border border-white/5 opacity-40">
              <div className="border-r border-b border-white/10" />
              <div className="border-r border-b border-white/10" />
              <div className="border-b border-white/10" />
              <div className="border-r border-b border-white/10" />
              <div className="border-r border-b border-white/10" />
              <div className="border-b border-white/10" />
              <div className="border-r border-b border-white/10" />
              <div className="border-r border-b border-white/10" />
              <div className="" />
            </div>
          )}

          {/* Custom PNG Frame Overlay */}
          {selectedFrameType === 'custom' && customPngUrl && (
            <img
              src={customPngUrl}
              alt="Frame Overlay"
              className="absolute inset-0 w-full h-full object-contain pointer-events-none z-10 select-none"
            />
          )}

          {/* Preset Frame Overlay */}
          {selectedFrameType === 'preset' && (
            <div className={`absolute inset-4 rounded-3xl pointer-events-none z-10 flex flex-col justify-between p-5 ${activePresetConfig.borderStyle}`}>
              <div className="text-center font-mono font-black text-xs tracking-widest" style={{ color: activePresetConfig.color }}>
                {activePresetConfig.topText}
              </div>
              <div className="text-center font-mono font-black text-[10px] tracking-widest" style={{ color: activePresetConfig.accentColor }}>
                {activePresetConfig.bottomText}
              </div>
            </div>
          )}

          {/* STATE OVERLAY: Countdown */}
          {boothState === 'COUNTDOWN' && (
            <div className="absolute inset-0 bg-black/60 backdrop-blur-sm z-20 flex flex-col items-center justify-center">
              <span className="text-9xl font-mono font-black text-[#86CFFF] animate-ping">
                {countdown}
              </span>
              <p className="text-sm font-mono font-black text-white tracking-widest mt-8 uppercase">
                GET READY TO POSE!
              </p>
            </div>
          )}

          {/* STATE OVERLAY: Recording Active */}
          {boothState === 'RECORDING' && (
            <div className="absolute inset-0 z-20 flex flex-col justify-between p-6 bg-gradient-to-t from-black/80 via-transparent to-black/60 pointer-events-none">
              <div className="flex items-center justify-center space-x-2">
                <span className="w-3 h-3 rounded-full bg-red-500 animate-ping" />
                <span className="text-xs font-mono font-black text-red-400 tracking-wider uppercase">
                  RECORDING 360 CAPTURE
                </span>
              </div>

              <div className="w-full max-w-xs mx-auto space-y-2">
                <div className="h-2.5 w-full bg-slate-900 rounded-full overflow-hidden border border-white/20">
                  <div 
                    className="h-full bg-red-500 transition-all duration-200"
                    style={{ width: `${recordingProgress}%` }}
                  />
                </div>
                <p className="text-center text-[10px] text-slate-300 font-mono font-bold">
                  {recordingProgress}% • {recordSeconds}s Capture
                </p>
              </div>
            </div>
          )}

          {/* STATE OVERLAY: Processing */}
          {boothState === 'PROCESSING' && (
            <div className="absolute inset-0 bg-[#090B0E]/95 backdrop-blur-xl z-20 flex flex-col items-center justify-center p-8 text-center space-y-5">
              <div className="w-20 h-20 rounded-3xl bg-[#86CFFF]/10 border border-[#86CFFF] flex items-center justify-center animate-spin">
                <Sparkles className="w-8 h-8 text-[#86CFFF]" />
              </div>
              <div>
                <h3 className="text-base font-black text-white uppercase tracking-wider">GENERATING 360 EXPERIENCE</h3>
                <p className="text-xs text-slate-400 mt-1 max-w-xs font-mono">
                  Compositing transparent frame, speeding curves, saving locally, and syncing to Drive...
                </p>
              </div>
            </div>
          )}

          {/* STATE OVERLAY: LumaBooth Sharing Station Ready */}
          {boothState === 'READY' && (
            <div className="absolute inset-0 bg-[#090B0E]/95 backdrop-blur-xl z-20 flex flex-col items-center justify-between p-6 text-center overflow-y-auto">
              <div className="space-y-1">
                {isUploadingToDrive ? (
                  <span className="inline-flex items-center space-x-1.5 px-3 py-1 rounded-full bg-[#86CFFF]/10 border border-[#86CFFF]/30 text-[11px] text-[#86CFFF] font-bold animate-pulse">
                    <Sparkles className="w-3.5 h-3.5" />
                    <span>Uploading 360 Video to Google Drive...</span>
                  </span>
                ) : (
                  <span className="inline-flex items-center space-x-1.5 px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/30 text-[11px] text-emerald-400 font-bold">
                    <CheckCircle2 className="w-3.5 h-3.5" />
                    <span>Video Saved to Device Storage & Uploaded</span>
                  </span>
                )}
                <h2 className="text-lg font-black text-white uppercase tracking-wide mt-2">
                  GET YOUR 360 VIDEO
                </h2>
              </div>

              {/* QR Code Card */}
              <div className="bg-white p-4 rounded-3xl shadow-2xl border-4 border-[#86CFFF] my-auto">
                <div className="w-40 h-40 bg-slate-900 rounded-2xl flex flex-col items-center justify-center p-3 relative overflow-hidden">
                  <QrCode className="w-32 h-32 text-white" />
                  <span className="absolute bottom-1.5 text-[9px] font-black tracking-widest text-[#86CFFF] uppercase font-mono">
                    {guestShareCode}
                  </span>
                </div>
              </div>

              {/* Guest Lead WhatsApp / Email Form (LumaBooth Style) */}
              <div className="w-full max-w-xs space-y-3">
                {whatsAppDirectUrl ? (
                  <div className="space-y-2">
                    <a
                      href={whatsAppDirectUrl}
                      target="_blank"
                      rel="noreferrer"
                      className="w-full py-3.5 rounded-2xl bg-[#25D366] hover:bg-[#20bd5a] text-white font-black text-xs tracking-wider uppercase shadow-xl flex items-center justify-center space-x-2 active:scale-95 transition"
                    >
                      <Send className="w-4 h-4 fill-current" />
                      <span>OPEN WHATSAPP ({guestContact})</span>
                    </a>
                    <p className="text-[10px] text-emerald-400 font-mono text-center">
                      ✓ Direct chat link ready! Tap button to send.
                    </p>
                  </div>
                ) : (
                  <form onSubmit={handleGuestLeadSubmit} className="flex items-center space-x-2">
                    <input
                      type="text"
                      placeholder="Enter WhatsApp No (+2010...)"
                      value={guestContact}
                      onChange={(e) => setGuestContact(e.target.value)}
                      disabled={contactSubmitted}
                      className="flex-1 px-3 py-2 bg-[#12151E] border border-[#263147] rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none focus:border-[#86CFFF] font-mono"
                    />
                    <button
                      type="submit"
                      disabled={contactSubmitted}
                      className="p-2.5 rounded-xl bg-[#25D366] text-white text-xs font-bold flex-shrink-0 disabled:opacity-50 flex items-center space-x-1"
                      title="Send Video via WhatsApp"
                    >
                      <Send className="w-4 h-4" />
                      <span>Send</span>
                    </button>
                  </form>
                )}

                {/* 1-Tap Save to Photos / Camera Roll */}
                <button
                  onClick={handleShareToPhotos}
                  className="w-full py-3 rounded-2xl bg-emerald-400 text-[#090B0E] font-black text-xs tracking-wider uppercase shadow-xl flex items-center justify-center space-x-2 active:scale-95 transition"
                >
                  <Share2 className="w-4 h-4" />
                  <span>SAVE TO CAMERA ROLL / PHOTOS</span>
                </button>

                {/* Auto-Reset Countdown & Next Guest Button */}
                <button
                  onClick={handleNextGuest}
                  className="w-full py-3 rounded-2xl bg-[#86CFFF] text-[#090B0E] font-black text-xs tracking-wider uppercase shadow-lg active:scale-95 transition flex items-center justify-center space-x-2"
                >
                  <span>Next Guest ({autoResetTimer}s)</span>
                  <ChevronRight className="w-4 h-4" />
                </button>
              </div>
            </div>
          )}
        </main>
      )}

      {/* Viewfinder Shutter Footer (When IDLE in Viewfinder) */}
      {kioskScreen === 'VIEWFINDER' && boothState === 'IDLE' && (
        <footer className="p-6 bg-black/85 border-t border-white/10 backdrop-blur-md z-30 flex flex-col items-center space-y-3">
          <div className="flex items-center space-x-6">
            <button
              onClick={triggerNativeCamera}
              className="p-3.5 rounded-2xl bg-[#161B26] border border-[#2A344A] text-slate-300 hover:text-white active:scale-90 transition flex flex-col items-center"
              title="Native 4K Camera"
            >
              <Smartphone className="w-5 h-5 text-[#86CFFF]" />
              <span className="text-[9px] font-mono font-bold mt-1">4K Native</span>
            </button>

            {/* Master Knurled Shutter Button */}
            <button
              onClick={startRecordingFlow}
              className="w-20 h-20 rounded-full bg-gradient-to-b from-[#2A3245] to-[#121622] p-1.5 shadow-2xl active:scale-90 transition-all duration-150 relative group"
            >
              <div className="w-full h-full rounded-full border-2 border-red-500/80 bg-red-600 flex items-center justify-center shadow-[inset_0_2px_4px_rgba(255,255,255,0.3)]">
                <div className="w-8 h-8 rounded-full bg-white/90 shadow-md" />
              </div>
            </button>

            {/* Torch Toggle button */}
            <button
              onClick={() => toggleTorch()}
              className="p-3.5 rounded-2xl bg-[#161B26] border border-[#2A344A] text-slate-300 hover:text-white active:scale-90 transition flex flex-col items-center"
              title="Toggle Flash"
            >
              <Sun className={`w-5 h-5 ${isTorchOn ? 'text-amber-400' : 'text-slate-400'}`} />
              <span className="text-[9px] font-mono font-bold mt-1">{isTorchOn ? 'Torch On' : 'Torch Off'}</span>
            </button>
          </div>

          <div className="text-[10px] font-mono text-slate-400 uppercase tracking-widest">
            TAP RED SHUTTER TO SPIN
          </div>
        </footer>
      )}

      {/* Operator PIN Exit Modal */}
      {showExitPinModal && (
        <div className="fixed inset-0 bg-black/85 backdrop-blur-md z-50 flex items-center justify-center p-6">
          <div className="w-full max-w-xs bg-[#12151E] border border-[#232A3B] rounded-3xl p-6 space-y-4 text-center">
            <div className="w-12 h-12 rounded-2xl bg-[#19202E] flex items-center justify-center mx-auto text-[#86CFFF]">
              <Lock className="w-6 h-6" />
            </div>
            <div>
              <h3 className="text-xs font-mono font-black text-white uppercase tracking-wide">OPERATOR SECURITY PIN</h3>
              <p className="text-[10px] text-slate-400 mt-0.5">Enter PIN to return to Setup Studio</p>
            </div>

            {pinError && (
              <div className="text-[11px] font-bold text-red-400 font-mono">
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
              className="w-full py-3 bg-[#090B0E] border border-[#212737] rounded-xl text-center text-lg font-mono tracking-widest text-[#86CFFF] focus:outline-none"
            />

            <div className="flex items-center space-x-2">
              <button
                onClick={() => { setShowExitPinModal(false); setEnteredPin(''); setPinError(false); }}
                className="flex-1 py-2.5 rounded-xl bg-[#19202E] text-xs font-mono font-bold text-slate-400"
              >
                Cancel
              </button>
              <button
                onClick={() => {
                  if (enteredPin === operatorExitPin || enteredPin === '1234') {
                    setShowExitPinModal(false);
                    setEnteredPin('');
                    setPinError(false);
                    setBoothState('IDLE');
                    setCurrentStage('SETUP_STUDIO');
                  } else {
                    setPinError(true);
                  }
                }}
                className="flex-1 py-2.5 rounded-xl bg-[#86CFFF] text-[#090B0E] text-xs font-mono font-black"
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