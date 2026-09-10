using System;
using System.Diagnostics;
using System.IO;
using System.Net.Sockets;
using System.Threading;
using System.Windows.Forms;

namespace Luster360 {
    static class Program {
        static bool IsPortOpen(string host, int port) {
            try {
                using (var client = new TcpClient()) {
                    var result = client.BeginConnect(host, port, null, null);
                    bool success = result.AsyncWaitHandle.WaitOne(600);
                    if (success && client.Connected) {
                        client.EndConnect(result);
                        return true;
                    }
                    return false;
                }
            } catch {
                return false;
            }
        }

        static Process StartBackgroundService(string workingDir, string fileName, string arguments) {
            var psi = new ProcessStartInfo {
                FileName = fileName,
                Arguments = arguments,
                WorkingDirectory = workingDir,
                UseShellExecute = false,
                CreateNoWindow = true,
                WindowStyle = ProcessWindowStyle.Hidden
            };
            return Process.Start(psi);
        }

        [STAThread]
        static void Main() {
            string baseDir = AppDomain.CurrentDomain.BaseDirectory;
            string backendDir = Path.Combine(baseDir, "backend");
            string commandCenterDir = Path.Combine(baseDir, "web", "apps", "command-center");

            // 1. Ensure Backend is running on port 4000
            if (!IsPortOpen("127.0.0.1", 4000) && Directory.Exists(backendDir)) {
                StartBackgroundService(backendDir, "cmd.exe", "/c npm run dev");
            }

            // 2. Ensure Command Center is running on port 3001
            if (!IsPortOpen("127.0.0.1", 3001) && Directory.Exists(commandCenterDir)) {
                StartBackgroundService(commandCenterDir, "cmd.exe", "/c npm run dev");
            }

            // Wait up to 15 seconds for Command Center to accept connections
            int attempts = 0;
            while (!IsPortOpen("127.0.0.1", 3001) && attempts < 30) {
                Thread.Sleep(500);
                attempts++;
            }

            // 3. Launch dedicated standalone desktop window
            string edgePath = @"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe";
            if (!File.Exists(edgePath)) {
                edgePath = @"C:\Program Files\Microsoft\Edge\Application\msedge.exe";
            }

            string userDataDir = Path.Combine(Path.GetTempPath(), "Luster360DashboardProfile");

            if (File.Exists(edgePath)) {
                var appPsi = new ProcessStartInfo {
                    FileName = edgePath,
                    Arguments = string.Format("--app=http://localhost:3001 --window-size=1440,900 --user-data-dir=\"{0}\"", userDataDir),
                    UseShellExecute = false
                };
                var appProcess = Process.Start(appPsi);
                appProcess.WaitForExit();
            } else {
                Process.Start("http://localhost:3001");
            }
        }
    }
}
