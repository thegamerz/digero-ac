using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Windows.Forms;

namespace LogWiz {
	class TextLogger : Logger {
		private const string LogsFolder = @"Logs\";
		private const int MaxBufferSize = 100;

		private bool mDisposed = false;

		private string mCharacterName;
		private string mServerName;
		private List<string> mLogBuffer = new List<string>();
		private Timer mSaveTimer = new Timer();
		private DateTime mLogLastModified = DateTime.MinValue;

		private bool mLogPerCharacter = false;
		private bool mTimestamp = true;

		public TextLogger(string characterName, string serverName, bool logPerCharacter, bool timestamp) {
			mCharacterName = characterName;
			mServerName = serverName;
			mLogPerCharacter = logPerCharacter;
			mTimestamp = timestamp;

			// Write log to disk every 1 minute
			mSaveTimer.Interval = 60000;
			mSaveTimer.Tick += new EventHandler(SaveTimer_Tick);
			mSaveTimer.Start();
		}

		public void Dispose() {
			if (mDisposed)
				return;

			if (mSaveTimer != null) {
				mSaveTimer.Stop();
				mSaveTimer.Tick -= SaveTimer_Tick;
				mSaveTimer.Dispose();
				mSaveTimer = null;
			}

			SaveLog();

			mDisposed = true;
		}

		public bool LogPerCharacter {
			get { return mLogPerCharacter; }
			set {
				if (mLogPerCharacter != value) {
					mLogPerCharacter = value;
					mLogLastModified = DateTime.MinValue;
				}
			}
		}

		public bool Timestamp {
			get { return mTimestamp; }
			set { mTimestamp = value; }
		}

		public string LogPath {
			get { return GenerateLogPath(); }
		}

		public LogTypeEnum LogType {
			get { return LogTypeEnum.Text; }
		}

		public void LogMessage(string message, int color) {
			if (Timestamp) {
				message = "[" + DateTime.Now.ToLongTimeString() + "] " + message;
			}
			mLogBuffer.Add(message);
			if (mLogBuffer.Count >= MaxBufferSize) {
				SaveLog();
			}
		}

		private void SaveTimer_Tick(object sender, EventArgs e) {
			try {
				SaveLog();
			}
			catch (Exception ex) { Util.HandleException(ex); }
		}

		private void SaveLog() {
			if (mLogBuffer.Count == 0)
				return;

			string logPath = GenerateLogPath();

			FileInfo logFile = new FileInfo(logPath);
			bool writeHeader = !logFile.Exists || logFile.LastWriteTime > mLogLastModified;
			
			using (StreamWriter logWriter = new StreamWriter(logPath, true)) {
				if (writeHeader) {
					if (logWriter.BaseStream.Position == 0) {
						logWriter.WriteLine("Asheron's Call log file created by " + Util.PluginNameVer);
						logWriter.WriteLine();
						logWriter.WriteLine(DateTime.Today.ToLongDateString());
					}
					logWriter.WriteLine();
					logWriter.WriteLine();
					logWriter.WriteLine();
					logWriter.WriteLine("*** Logging for " + mCharacterName + " on " + mServerName);
					logWriter.WriteLine("--------------------------------------------------------------------------------");
				}

				foreach (string logEntry in mLogBuffer) {
					logWriter.WriteLine(logEntry);
				}
				mLogBuffer.Clear();
			}

			mLogLastModified = File.GetLastWriteTime(logPath);
		}

		private string GenerateLogPath() {
			string prefix = LogsFolder;
			if (LogPerCharacter) {
				prefix += mCharacterName + " [" + mServerName + @"]\";
			}
			return Util.FullPath(prefix + DateTime.Today.ToLongDateString() + ".txt");
		}

		private string GenerateLogDescription() {
			string desc = DateTime.Today.ToShortDateString();
			if (LogPerCharacter) {
				desc += " for " + mCharacterName + " [" + mServerName + "]";
			}
			return desc;
		}
	}
}
