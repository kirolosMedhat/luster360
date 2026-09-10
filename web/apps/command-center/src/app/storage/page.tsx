import { HardDrive, CheckCircle2, AlertTriangle, RefreshCw, ArrowUpRight } from 'lucide-react';

export default function StorageHealthPage() {
  const recentUploads = [
    { id: 'vid-127', number: 127, shortCode: '8F3K2A', render: true, thumb: true, drive: true, status: 'READY', time: '2 mins ago' },
    { id: 'vid-126', number: 126, shortCode: '9X7L4Q', render: true, thumb: true, drive: true, status: 'READY', time: '5 mins ago' },
    { id: 'vid-125', number: 125, shortCode: '4M9T1Z', render: true, thumb: true, drive: true, status: 'READY', time: '8 mins ago' },
    { id: 'vid-124', number: 124, shortCode: '2P8W5K', render: true, thumb: true, drive: true, status: 'READY', time: '12 mins ago' },
    { id: 'vid-123', number: 123, shortCode: '7N3R9B', render: true, thumb: true, drive: false, status: 'QUEUED', time: 'Just now' },
  ];

  return (
    <div className="p-8 space-y-8">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-black tracking-tight text-luster-text">STORAGE & CLOUD HEALTH</h1>
          <p className="text-xs text-luster-textMuted mt-1">Provider status, Google Drive folder verification, and resumable upload queues</p>
        </div>
      </div>

      {/* Provider Status Card */}
      <div className="p-6 rounded-2xl bg-luster-panel border border-luster-border shadow-lg">
        <div className="flex items-center justify-between pb-4 border-b border-luster-border">
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 rounded-xl bg-luster-header border border-luster-border flex items-center justify-center text-luster-accent">
              <HardDrive className="w-5 h-5" />
            </div>
            <div>
              <span className="text-[10px] font-bold text-luster-textDark uppercase">PRIMARY STORAGE PROVIDER</span>
              <h2 className="text-lg font-bold text-luster-text">Google Drive V1 Integration</h2>
            </div>
          </div>
          <div className="flex items-center space-x-2 px-3 py-1 rounded-full bg-luster-success/20 text-luster-success text-xs font-bold">
            <span className="w-2 h-2 rounded-full bg-luster-success animate-pulse" />
            <span>CONNECTED & RESPONSIVE</span>
          </div>
        </div>

        <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mt-4">
          <div>
            <span className="text-[10px] font-bold text-luster-textDark uppercase">ROOT FOLDER</span>
            <div className="text-xs font-mono font-bold text-luster-text mt-0.5">LUSTER 360</div>
          </div>
          <div>
            <span className="text-[10px] font-bold text-luster-textDark uppercase">LAST UPLOAD</span>
            <div className="text-xs font-bold text-luster-success mt-0.5">2 minutes ago</div>
          </div>
          <div>
            <span className="text-[10px] font-bold text-luster-textDark uppercase">PENDING QUEUE</span>
            <div className="text-xs font-bold text-luster-warning mt-0.5">1 video uploading</div>
          </div>
          <div>
            <span className="text-[10px] font-bold text-luster-textDark uppercase">FAILED UPLOADS</span>
            <div className="text-xs font-bold text-luster-textMuted mt-0.5">0 (Clean Queue)</div>
          </div>
        </div>
      </div>

      {/* Upload Pipeline Verification Table */}
      <div className="p-6 rounded-2xl bg-luster-panel border border-luster-border">
        <h3 className="text-sm font-bold tracking-wider text-luster-text uppercase mb-4">
          Recent Uploads & Verification Pipeline
        </h3>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead>
              <tr className="border-b border-luster-border text-luster-textMuted font-bold uppercase">
                <th className="pb-3">Video</th>
                <th className="pb-3">Short Code</th>
                <th className="pb-3 text-center">Render</th>
                <th className="pb-3 text-center">Thumbnail</th>
                <th className="pb-3 text-center">Drive Upload</th>
                <th className="pb-3 text-right">Gallery Status</th>
                <th className="pb-3 text-right">Time</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-luster-border/60">
              {recentUploads.map((u) => (
                <tr key={u.id} className="hover:bg-luster-surface/50 transition">
                  <td className="py-3 font-bold text-luster-text">Spin #{u.number}</td>
                  <td className="py-3 font-mono text-luster-accent font-semibold">{u.shortCode}</td>
                  <td className="py-3 text-center text-luster-success font-bold">✓</td>
                  <td className="py-3 text-center text-luster-success font-bold">✓</td>
                  <td className="py-3 text-center font-bold">
                    {u.drive ? <span className="text-luster-success">✓</span> : <span className="text-luster-warning">UPLOADING...</span>}
                  </td>
                  <td className="py-3 text-right">
                    <span
                      className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                        u.status === 'READY' ? 'bg-luster-success/20 text-luster-success' : 'bg-luster-warning/20 text-luster-warning'
                      }`}
                    >
                      {u.status}
                    </span>
                  </td>
                  <td className="py-3 text-right text-luster-textMuted">{u.time}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
