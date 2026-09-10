import dotenv from 'dotenv';
import path from 'path';
import fs from 'fs';

// Load environment variables from backend directory or project root
dotenv.config({ path: path.resolve(process.cwd(), '.env') });
dotenv.config({ path: path.resolve(process.cwd(), '../.env') });

// Auto-detect service-account.json file
let detectedSaEmail = process.env.GOOGLE_DRIVE_SERVICE_ACCOUNT_EMAIL;
let detectedSaKey = process.env.GOOGLE_DRIVE_SERVICE_ACCOUNT_PRIVATE_KEY?.replace(/\\n/g, '\n');

const saJsonPath = path.resolve(process.cwd(), 'service-account.json');
if (fs.existsSync(saJsonPath)) {
  try {
    const saData = JSON.parse(fs.readFileSync(saJsonPath, 'utf8'));
    if (saData.client_email && saData.private_key) {
      detectedSaEmail = saData.client_email;
      detectedSaKey = saData.private_key;
    }
  } catch {
    // Ignore file parse error
  }
}

export interface AppConfig {
  nodeEnv: string;
  port: number;
  apiPrefix: string;
  mediaApiSecret: string;
  
  // Supabase Configuration
  supabaseUrl: string;
  supabaseServiceRoleKey: string;
  
  // Storage Provider Configuration
  storageProvider: 'GOOGLE_DRIVE' | 'MOCK' | 'S3' | 'SUPABASE';
  
  // Google Drive Configuration (V1 Media Storage)
  googleDrive: {
    clientId?: string;
    clientSecret?: string;
    refreshToken?: string;
    rootFolderId?: string;
    serviceAccountEmail?: string;
    serviceAccountPrivateKey?: string;
  };

  // Public URLs
  publicGalleryUrl: string;
}

export const config: AppConfig = {
  nodeEnv: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT || '4000', 10),
  apiPrefix: process.env.API_PREFIX || '/api/v1',
  mediaApiSecret: process.env.MEDIA_API_SECRET || 'luster-360-dev-media-secret-key-change-in-prod',
  
  supabaseUrl: process.env.SUPABASE_URL || 'https://mock-supabase.luster-photobooth.com',
  supabaseServiceRoleKey: process.env.SUPABASE_SERVICE_ROLE_KEY || '',
  
  storageProvider: (process.env.STORAGE_PROVIDER as any) || (detectedSaEmail ? 'GOOGLE_DRIVE' : 'MOCK'),
  
  googleDrive: {
    clientId: process.env.GOOGLE_DRIVE_CLIENT_ID,
    clientSecret: process.env.GOOGLE_DRIVE_CLIENT_SECRET,
    refreshToken: process.env.GOOGLE_DRIVE_REFRESH_TOKEN,
    rootFolderId: process.env.GOOGLE_DRIVE_ROOT_FOLDER_ID,
    serviceAccountEmail: detectedSaEmail,
    serviceAccountPrivateKey: detectedSaKey,
  },

  publicGalleryUrl: process.env.PUBLIC_GALLERY_URL || 'https://events.luster-photobooth.com',
};
