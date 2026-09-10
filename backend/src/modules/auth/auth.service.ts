import { getSupabaseClient } from '../../config/supabase';
import { logger } from '../../config/logger';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { config } from '../../config/env';

export interface OperatorUser {
  id: string;
  email: string;
  fullName: string;
  role: 'ADMIN' | 'OPERATOR';
  isActive: boolean;
  createdAt: string;
}

// In-memory fallback if needed
const localUsers = new Map<string, any>();

export class AuthService {
  private supabase = getSupabaseClient();

  async login(identifier: string, password: string): Promise<{ token: string; user: OperatorUser } | null> {
    const email = identifier.includes('@') ? identifier : `${identifier.toLowerCase().trim()}@luster360.local`;

    try {
      // 1. Try Supabase Auth
      const { data: authData, error: authError } = await this.supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (!authError && authData.user) {
        const { data: profile } = await this.supabase
          .from('profiles')
          .select('*')
          .eq('id', authData.user.id)
          .single();

        const token = authData.session?.access_token || this.generateToken(authData.user.id, email);
        return {
          token,
          user: {
            id: authData.user.id,
            email,
            fullName: profile?.full_name || authData.user.user_metadata?.full_name || 'Booth Operator',
            role: (profile?.role as any) || 'OPERATOR',
            isActive: profile?.is_active ?? true,
            createdAt: authData.user.created_at,
          },
        };
      }
    } catch (err: any) {
      logger.warn('Supabase auth sign in failed, checking local users fallback', { error: err.message });
    }

    // 2. Check local fallback
    const local = Array.from(localUsers.values()).find(
      u => u.email.toLowerCase() === email.toLowerCase() || u.username?.toLowerCase() === identifier.toLowerCase()
    );

    if (local && bcrypt.compareSync(password, local.passwordHash)) {
      const token = this.generateToken(local.id, local.email);
      return {
        token,
        user: {
          id: local.id,
          email: local.email,
          fullName: local.fullName,
          role: local.role,
          isActive: true,
          createdAt: local.createdAt,
        },
      };
    }

    return null;
  }

  async listUsers(): Promise<OperatorUser[]> {
    try {
      const { data: profiles, error } = await this.supabase
        .from('profiles')
        .select('*')
        .order('created_at', { ascending: false });

      if (!error && profiles && profiles.length > 0) {
        return profiles.map(p => ({
          id: p.id,
          email: p.email,
          fullName: p.full_name,
          role: p.role,
          isActive: p.is_active,
          createdAt: p.created_at,
        }));
      }
    } catch (err: any) {
      logger.error('Failed to list profiles from Supabase', { error: err.message });
    }

    return Array.from(localUsers.values()).map(u => ({
      id: u.id,
      email: u.email,
      fullName: u.fullName,
      role: u.role,
      isActive: true,
      createdAt: u.createdAt,
    }));
  }

  async createUser(params: {
    username: string;
    email?: string;
    password: string;
    fullName: string;
    role?: 'ADMIN' | 'OPERATOR';
  }): Promise<OperatorUser> {
    const email = params.email || (params.username.includes('@') ? params.username : `${params.username.toLowerCase().trim()}@luster360.local`);
    const role = params.role || 'OPERATOR';

    try {
      // 1. Create user in Supabase Auth Admin
      const { data: authUser, error: createError } = await this.supabase.auth.admin.createUser({
        email,
        password: params.password,
        email_confirm: true,
        user_metadata: {
          full_name: params.fullName,
          username: params.username,
          role,
        },
      });

      if (!createError && authUser.user) {
        // 2. Upsert profile in Supabase
        await this.supabase.from('profiles').upsert({
          id: authUser.user.id,
          email,
          full_name: params.fullName,
          role,
          is_active: true,
        });

        logger.info('Created operator user in Supabase', { email, userId: authUser.user.id });

        return {
          id: authUser.user.id,
          email,
          fullName: params.fullName,
          role,
          isActive: true,
          createdAt: authUser.user.created_at,
        };
      }
      if (createError) {
        logger.warn('Supabase admin createUser returned error, using fallback', { error: createError.message });
      }
    } catch (err: any) {
      logger.error('Error creating user in Supabase admin', { error: err.message });
    }

    // Fallback store
    const id = `usr_${Date.now()}`;
    const salt = bcrypt.genSaltSync(10);
    const passwordHash = bcrypt.hashSync(params.password, salt);
    const userRecord = {
      id,
      email,
      username: params.username,
      fullName: params.fullName,
      role,
      passwordHash,
      createdAt: new Date().toISOString(),
    };
    localUsers.set(id, userRecord);

    return {
      id,
      email,
      fullName: params.fullName,
      role,
      isActive: true,
      createdAt: userRecord.createdAt,
    };
  }

  async deleteUser(userId: string): Promise<boolean> {
    try {
      await this.supabase.auth.admin.deleteUser(userId);
      await this.supabase.from('profiles').delete().eq('id', userId);
      localUsers.delete(userId);
      return true;
    } catch {
      localUsers.delete(userId);
      return true;
    }
  }

  private generateToken(userId: string, email: string): string {
    return jwt.sign(
      { sub: userId, email, role: 'OPERATOR' },
      config.mediaApiSecret,
      { expiresIn: '30d' }
    );
  }
}

export const authService = new AuthService();
