import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { config } from './env';
import { logger } from './logger';

let supabaseClient: SupabaseClient | null = null;

export function getSupabaseClient(): SupabaseClient {
  if (supabaseClient) {
    return supabaseClient;
  }

  if (!config.supabaseUrl || !config.supabaseServiceRoleKey) {
    logger.warn('Supabase URL or Service Role Key not set. Using local development fallback mode.');
  }

  supabaseClient = createClient(
    config.supabaseUrl,
    config.supabaseServiceRoleKey || 'dummy-key-for-dev'
  );

  return supabaseClient;
}
