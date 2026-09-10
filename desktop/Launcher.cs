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
                string backendCmd = File.Exists(Path.Combine(backendDir, "dist", "server.js"))
                    ? "/c npm start"
                    : "/c npm run dev";
                StartBackgroundService(backendDir, "cmd.exe", backendCmd);
            }

            // 2. Ensure Command Center is running in production mode on port 3001
            if (!IsPortOpen("127.0.0.1", 3001) && Directory.Exists(commandCenterDir)) {
                string webCmd = Directory.Exists(Path.Combine(commandCenterDir, ".next"))
                    ? "/c npm start"
                    : "/c npm run dev";
                StartBackgroundService(commandCenterDir, "cmd.exe", webCmd);
            }

            // Wait up to 25 seconds for Command Center to accept connections
            int attempts = 0;
            while (!IsPortOpen("127.0.0.1", 3001) && attempts < 50) {
                Thread.Sleep(500);
                attempts++;
            }

            // 3. Locate browser executable (Edge or Chrome)
            string browserPath = @"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe";
            if (!File.Exists(browserPath)) {
                browserPath = @"C:\Program Files\Microsoft\Edge\Application\msedge.exe";
            }
            if (!File.Exists(browserPath)) {
                browserPath = @"C:\Program Files\Google\Chrome\Application\chrome.exe";
            }
            if (!File.Exists(browserPath)) {
                browserPath = @"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe";
            }

            string userDataDir = Path.Combine(Path.GetTempPath(), "Luster360DashboardProfile");

            // Clean stale browser cache directory so old broken styles never persist
            try {
                string cacheDir = Path.Combine(userDataDir, "Default", "Cache");
                if (Directory.Exists(cacheDir)) {
                    Directory.Delete(cacheDir, true);
                }
            } catch { }

            if (File.Exists(browserPath)) {
                var appPsi = new ProcessStartInfo {
                    FileName = browserPath,
                    Arguments = string.Format("--app=http://localhost:3001 --window-size=1440,900 --user-data-dir=\"{0}\" --disable-http-cache --no-first-run", userDataDir),
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
