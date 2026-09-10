export interface LusterEvent {
  id: string;
  name: string;
  eventDate: string;
  startTime?: string;
  endTime?: string;
  timezone: string;
  venue?: string;
  clientName: string;
  status: 'DRAFT' | 'UPCOMING' | 'ACTIVE' | 'PAUSED' | 'COMPLETED' | 'ARCHIVED';
  startedAt?: string;
  endedAt?: string;
  duration?: string;
  durationSeconds?: number;
  gallerySlug: string;
  galleryVisibility: 'PUBLIC' | 'PRIVATE' | 'PASSWORD_PROTECTED' | 'EXPIRED' | 'DISABLED';
  brandPrimaryColor: string;
  brandSecondaryColor: string;
  coverImageUrl?: string;
  logoUrl?: string;
  isDownloadEnabled: boolean;
  isSharingEnabled: boolean;
  customTitle?: string;
  customFooterMessage?: string;
  videoStats?: {
    total: number;
    uploaded: number;
    pending: number;
    failed: number;
  };
}

export interface LusterVideo {
  id: string;
  shortCode: string;
  filename: string;
  duration?: number;
  width: number;
  height: number;
  fileSize?: number;
  viewCount: number;
  downloadCount: number;
  thumbnailUrl: string;
  streamUrl: string;
  downloadUrl: string;
  shareUrl: string;
  createdAt: string;
}

export interface LusterDevice {
  id: string;
  device_identifier: string;
  device_name: string;
  platform: string;
  app_version: string;
  calculatedStatus: 'ONLINE' | 'OFFLINE';
  currentState: 'IDLE' | 'READY' | 'COUNTDOWN' | 'RECORDING' | 'PROCESSING' | 'RENDERING' | 'UPLOADING' | 'ERROR' | 'OFFLINE';
  battery_level?: number;
  is_charging?: boolean;
  storage_free_bytes?: number;
  storage_total_bytes?: number;
  last_heartbeat?: string;
  secondsSinceHeartbeat?: number;
}

export interface StorageHealth {
  provider: string;
  status: 'CONNECTED' | 'DEGRADED' | 'DISCONNECTED' | 'CONFIGURATION_REQUIRED';
  lastSuccessfulUpload?: string;
  details?: string;
}
