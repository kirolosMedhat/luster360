import Link from 'next/link';
import { Calendar, Clock, Film, CheckCircle, Clock3, ArrowUpRight, FolderGit2 } from 'lucide-react';

export default function EventsPage() {
  const events = [
    {
      id: 'e0000001-0000-0000-0000-000000000001',
      name: 'Ahmed & Mariam Wedding',
      client: 'Ahmed Hassan',
      venue: 'Four Seasons Nile Plaza, Cairo',
      date: '10 September 2026',
      startedAt: '18:00',
      duration: '04h 42m',
      status: 'ACTIVE',
      device: 'LUSTER-360-001',
      videosTotal: 127,
      videosUploaded: 119,
      videosPending: 8,
      videosFailed: 0,
      slug: 'ahmed-mariam',
      driveRootFolderId: 'drive_folder_root_ahmed_mariam',
      driveVideosFolderId: 'drive_folder_videos_ahmed_mariam',
    },
    {
      id: 'e0000002-0000-0000-0000-000000000002',
      name: 'Vodafone Annual Gala 2026',
      client: 'Vodafone Egypt Events',
      venue: 'JW Marriott Cairo',
      date: '15 September 2026',
      startedAt: 'Upcoming',
      duration: '00h 00m',
      status: 'DRAFT',
      device: 'LUSTER-360-002',
      videosTotal: 0,
      videosUploaded: 0,
      videosPending: 0,
      videosFailed: 0,
      slug: 'vodafone-gala-2026',
      driveRootFolderId: 'drive_folder_root_vodafone_2026',
      driveVideosFolderId: 'drive_folder_videos_vodafone_2026',
    },
  ];

  return (
    <div className="p-8 space-y-8">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-black tracking-tight text-luster-text">EVENT MONITORING</h1>
          <p className="text-xs text-luster-textMuted mt-1">Live event sessions, duration tracking, and Google Drive folder associations</p>
        </div>
      </div>

      <div className="space-y-5">
        {events.map((e) => (
          <div
            key={e.id}
            className={`p-6 rounded-2xl bg-luster-panel border ${
              e.status === 'ACTIVE' ? 'border-luster-accent/50' : 'border-luster-border'
            }`}
          >
            <div className="flex flex-col md:flex-row md:items-center justify-between pb-4 border-b border-luster-border gap-4">
              <div>
                <div className="flex items-center space-x-3">
                  <h2 className="text-xl font-bold text-luster-text">{e.name}</h2>
                  <span
                    className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${
                      e.status === 'ACTIVE' ? 'bg-luster-success/20 text-luster-success' : 'bg-luster-surface text-luster-textMuted'
                    }`}
                  >
                    {e.status}
                  </span>
                </div>
                <p className="text-xs text-luster-textMuted mt-1">
                  Client: <span className="text-luster-text font-semibold">{e.client}</span> • Venue: {e.venue}
                </p>
              </div>

              <div className="flex items-center space-x-4">
                <Link
                  href={`http://localhost:3000/event/${e.slug}`}
                  target="_blank"
                  className="flex items-center space-x-2 px-3 py-1.5 rounded-lg bg-luster-surface border border-luster-border text-xs font-bold text-luster-accent hover:border-luster-accent transition"
                >
                  <span>Public Gallery</span>
                  <ArrowUpRight className="w-3.5 h-3.5" />
                </Link>
              </div>
            </div>

            {/* Metrics & Drive Mappings */}
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mt-4">
              <div className="p-3 rounded-xl bg-luster-surface">
                <span className="text-[10px] font-bold text-luster-textDark uppercase">CURRENT DURATION</span>
                <div className="text-lg font-black font-mono text-luster-accent mt-0.5">{e.duration}</div>
              </div>
              <div className="p-3 rounded-xl bg-luster-surface">
                <span className="text-[10px] font-bold text-luster-textDark uppercase">ASSIGNED BOOTH</span>
                <div className="text-sm font-bold text-luster-text mt-0.5">{e.device}</div>
              </div>
              <div className="p-3 rounded-xl bg-luster-surface">
                <span className="text-[10px] font-bold text-luster-textDark uppercase">UPLOAD PROGRESS</span>
                <div className="text-sm font-bold text-luster-success mt-0.5">
                  {e.videosUploaded} / {e.videosTotal} ({e.videosPending} pending)
                </div>
              </div>
              <div className="p-3 rounded-xl bg-luster-surface">
                <span className="text-[10px] font-bold text-luster-textDark uppercase">DRIVE FOLDER ID</span>
                <div className="text-xs font-mono text-luster-textMuted truncate mt-0.5">{e.driveVideosFolderId}</div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
