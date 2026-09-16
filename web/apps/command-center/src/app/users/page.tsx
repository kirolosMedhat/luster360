'use client';

import { useState, useEffect } from 'react';
import { Users, UserPlus, Shield, Key, Trash2, CheckCircle2, AlertCircle, RefreshCw } from 'lucide-react';

interface Operator {
  id: string;
  email: string;
  fullName: string;
  role: 'ADMIN' | 'OPERATOR';
  isActive: boolean;
  createdAt: string;
}

export default function UsersPage() {
  const [users, setUsers] = useState<Operator[]>([]);
  const [loading, setLoading] = useState(true);
  const [creating, setCreating] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  // Form State
  const [username, setUsername] = useState('');
  const [fullName, setFullName] = useState('');
  const [password, setPassword] = useState('');
  const [role, setRole] = useState<'OPERATOR' | 'ADMIN'>('OPERATOR');

  // Relative URL routes through Next.js rewrites to backend port 4000 seamlessly
  const apiUrl = '';

  const fetchUsers = async () => {
    try {
      setLoading(true);
      setError(null);
      const res = await fetch(`${apiUrl}/api/v1/auth/users`);
      const data = await res.json();
      if (data.success) {
        setUsers(data.data);
      }
    } catch (err: any) {
      setError('Could not connect to Luster Media API to fetch users.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const handleCreateUser = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSuccess(null);
    setCreating(true);

    try {
      const res = await fetch(`${apiUrl}/api/v1/auth/users`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          username,
          fullName,
          password,
          role,
        }),
      });

      const data = await res.json();
      if (data.success) {
        setSuccess(`User "${username}" created successfully! They can now log in on mobile.`);
        setUsername('');
        setFullName('');
        setPassword('');
        fetchUsers();
      } else {
        setError(data.error?.message || 'Failed to create user');
      }
    } catch (err: any) {
      setError('Network error: ' + err.message);
    } finally {
      setCreating(false);
    }
  };

  const handleDeleteUser = async (id: string, name: string) => {
    if (!confirm(`Are you sure you want to remove ${name}? They will lose mobile booth access.`)) return;

    try {
      const res = await fetch(`${apiUrl}/api/v1/auth/users/${id}`, {
        method: 'DELETE',
      });
      if (res.ok) {
        setUsers(prev => prev.filter(u => u.id !== id));
        setSuccess(`Operator ${name} removed.`);
      }
    } catch (err: any) {
      setError('Failed to delete user: ' + err.message);
    }
  };

  return (
    <div className="p-8 space-y-8">
      {/* 1. Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-black tracking-tight text-luster-text">OPERATOR & USER MANAGEMENT</h1>
          <p className="text-xs text-luster-textMuted mt-1">
            Create and manage authorized staff credentials for mobile booth access
          </p>
        </div>
        <button
          onClick={fetchUsers}
          className="p-2 rounded-xl bg-luster-panel border border-luster-border hover:border-luster-borderLight text-luster-textMuted hover:text-luster-text transition"
        >
          <RefreshCw className="w-4 h-4" />
        </button>
      </div>

      {/* Notifications */}
      {error && (
        <div className="p-4 rounded-xl bg-red-500/10 border border-red-500/30 flex items-center space-x-3 text-red-400 text-xs">
          <AlertCircle className="w-4 h-4 shrink-0" />
          <span>{error}</span>
        </div>
      )}
      {success && (
        <div className="p-4 rounded-xl bg-green-500/10 border border-green-500/30 flex items-center space-x-3 text-green-400 text-xs">
          <CheckCircle2 className="w-4 h-4 shrink-0" />
          <span>{success}</span>
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* 2. Create User Form (Left Col) */}
        <div className="p-6 rounded-2xl bg-luster-panel border border-luster-border h-fit">
          <div className="flex items-center space-x-3 mb-6 pb-4 border-b border-luster-border">
            <div className="w-10 h-10 rounded-xl bg-luster-header border border-luster-accent/30 flex items-center justify-center text-luster-accent">
              <UserPlus className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-sm font-bold text-luster-text">Create Booth Operator</h2>
              <p className="text-[11px] text-luster-textDark">Credentials used to unlock booth app</p>
            </div>
          </div>

          <form onSubmit={handleCreateUser} className="space-y-4">
            <div>
              <label className="block text-[11px] font-bold text-luster-textMuted uppercase mb-1.5">
                Username / Login ID
              </label>
              <input
                type="text"
                required
                placeholder="e.g. cairo_operator_1"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                className="w-full px-3.5 py-2.5 rounded-xl bg-luster-header border border-luster-border text-xs text-luster-text placeholder-luster-textDark focus:outline-none focus:border-luster-accent"
              />
            </div>

            <div>
              <label className="block text-[11px] font-bold text-luster-textMuted uppercase mb-1.5">
                Operator Full Name
              </label>
              <input
                type="text"
                required
                placeholder="e.g. Tamer Hosny"
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
                className="w-full px-3.5 py-2.5 rounded-xl bg-luster-header border border-luster-border text-xs text-luster-text placeholder-luster-textDark focus:outline-none focus:border-luster-accent"
              />
            </div>

            <div>
              <label className="block text-[11px] font-bold text-luster-textMuted uppercase mb-1.5">
                Password
              </label>
              <input
                type="password"
                required
                placeholder="At least 6 characters"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full px-3.5 py-2.5 rounded-xl bg-luster-header border border-luster-border text-xs text-luster-text placeholder-luster-textDark focus:outline-none focus:border-luster-accent"
              />
            </div>

            <div>
              <label className="block text-[11px] font-bold text-luster-textMuted uppercase mb-1.5">
                Permission Role
              </label>
              <select
                value={role}
                onChange={(e) => setRole(e.target.value as any)}
                className="w-full px-3.5 py-2.5 rounded-xl bg-luster-header border border-luster-border text-xs text-luster-text focus:outline-none focus:border-luster-accent"
              >
                <option value="OPERATOR">Booth Operator (Standard)</option>
                <option value="ADMIN">Fleet Administrator (Full)</option>
              </select>
            </div>

            <button
              type="submit"
              disabled={creating}
              className="w-full py-3 rounded-xl bg-luster-accent text-luster-header font-black text-xs uppercase tracking-wider hover:bg-white transition flex items-center justify-center space-x-2 disabled:opacity-50 mt-4"
            >
              {creating ? (
                <span>Creating Account...</span>
              ) : (
                <>
                  <Key className="w-4 h-4" />
                  <span>Create Operator Credentials</span>
                </>
              )}
            </button>
          </form>
        </div>

        {/* 3. Operator Users Table (Right Col) */}
        <div className="lg:col-span-2 p-6 rounded-2xl bg-luster-panel border border-luster-border">
          <div className="flex items-center justify-between mb-6 pb-4 border-b border-luster-border">
            <div className="flex items-center space-x-3">
              <Users className="w-5 h-5 text-luster-accent" />
              <div>
                <h2 className="text-sm font-bold text-luster-text">Authorized Booth Staff</h2>
                <p className="text-[11px] text-luster-textDark">Users permitted to unlock mobile hardware</p>
              </div>
            </div>
            <span className="text-xs font-mono font-bold text-luster-accent">
              {users.length} Active {users.length === 1 ? 'User' : 'Users'}
            </span>
          </div>

          {loading ? (
            <div className="p-12 text-center text-xs text-luster-textMuted">Loading authorized operators...</div>
          ) : users.length === 0 ? (
            <div className="p-12 text-center text-xs text-luster-textDark border border-dashed border-luster-border rounded-xl">
              No operators registered yet. Use the form on the left to create your first booth user.
            </div>
          ) : (
            <div className="space-y-3">
              {users.map((u) => (
                <div
                  key={u.id}
                  className="p-4 rounded-xl bg-luster-header border border-luster-border flex items-center justify-between hover:border-luster-borderLight transition"
                >
                  <div className="flex items-center space-x-3.5">
                    <div className="w-9 h-9 rounded-full bg-luster-panel border border-luster-border flex items-center justify-center text-xs font-bold text-luster-accent">
                      {u.fullName.charAt(0).toUpperCase()}
                    </div>
                    <div>
                      <div className="flex items-center space-x-2">
                        <span className="text-xs font-bold text-luster-text">{u.fullName}</span>
                        <span
                          className={`text-[9px] font-black uppercase px-2 py-0.5 rounded-full ${
                            u.role === 'ADMIN'
                              ? 'bg-purple-500/20 text-purple-400 border border-purple-500/30'
                              : 'bg-luster-accentMuted text-luster-accent'
                          }`}
                        >
                          {u.role}
                        </span>
                      </div>
                      <p className="text-[11px] text-luster-textDark mt-0.5 font-mono">{u.email}</p>
                    </div>
                  </div>

                  <div className="flex items-center space-x-3">
                    <button
                      onClick={() => handleDeleteUser(u.id, u.fullName)}
                      className="p-2 rounded-lg text-luster-textDark hover:text-red-400 hover:bg-red-500/10 transition"
                      title="Delete user"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
