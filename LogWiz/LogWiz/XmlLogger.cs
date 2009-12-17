using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using Timer = System.Windows.Forms.Timer;
using System.IO;

namespace LogWiz {
	public class XmlLogger : Logger {
		private const int LogFileVer = 1;
		private const string LogsFolder = @"Logs\";
		private const string LogFilesFolder = LogsFolder + @"_files\";
		private readonly string LogFilesPath;
		private readonly string XsltPath, BkgdPath;
		private readonly char[] NewLineChars = new char[] { '\r', '\n' };

		private bool mDisposed = false;

		private XmlDocument mLog = null;
		private DateTime mLogLastModified = DateTime.MinValue;
		private XmlElement mSession = null;
		private string mSessionId;
		private bool mLogChanged = false;
		private string mCurrentLogPath, mCurrentLogDescription;
		private Timer mSaveTimer = new Timer();

		private string mCharacterName, mServerName;
		private bool mLogPerCharacter = false;
		private bool mTimestamp = true;

		public XmlLogger(string characterName, string serverName, bool logPerCharacter, bool timestamp) {
			mCharacterName = characterName;
			mServerName = serverName;
			mLogPerCharacter = logPerCharacter;
			mTimestamp = timestamp;

			LogFilesPath = Util.FullPath(LogFilesFolder);
			XsltPath = Path.Combine(LogFilesPath, "logwiz.xslt");
			BkgdPath = Path.Combine(LogFilesPath, "bkgd.gif");

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

			CloseLog();

			mDisposed = true;
		}

		public bool IsLogOpen {
			get { return mLog != null && mSession != null; }
		}

		public bool LogPerCharacter {
			get { return mLogPerCharacter; }
			set { mLogPerCharacter = value; }
		}

		public bool Timestamp {
			get { return mTimestamp; }
			set { mTimestamp = value; }
		}

		public string LogPath {
			get { return GenerateLogPath(); }
		}

		public LogTypeEnum LogType {
			get { return LogTypeEnum.Xml; }
		}

		public void LogMessage(string message, int color) {
			// Replace multiple spaces with non-breaking spaces
			message = message.Replace("  ", "\xA0 ");
			if (message.StartsWith(" ")) {
				message = "\xA0" + message.Substring(1);
			}

			string[] lines = message.Split(NewLineChars, StringSplitOptions.RemoveEmptyEntries);
			if (lines.Length == 0)
				return;

			// Calling ReopenLog() here will do two things:
			// 1) Ensure that the log is open.
			// 2) Open a new log if the log path has changed.
			ReopenLog(true);

			XmlElement msgEle = (XmlElement)mSession.AppendChild(mLog.CreateElement("m"));
			msgEle.SetAttribute("c", color.ToString());
			if (Timestamp) {
				msgEle.SetAttribute("t", DateTime.Now.ToLongTimeString());
			}

			msgEle.AppendChild(mLog.CreateTextNode(lines[0]));
			for (int i = 1; i < lines.Length; i++) {
				msgEle.AppendChild(mLog.CreateElement("br"));
				msgEle.AppendChild(mLog.CreateTextNode(lines[i]));
			}

			mLogChanged = true;
		}

		public void OpenLog() {
			OpenLog(null, null);
		}

		public void OpenLog(string continueFromHref, string continueFromText) {
			if (!IsLogOpen) {
				mLog = new XmlDocument();

				mCurrentLogPath = GenerateLogPath();
				mCurrentLogDescription = GenerateLogDescription();

				if (File.Exists(mCurrentLogPath)) {
					mLog.Load(mCurrentLogPath);
					mLogLastModified = File.GetLastWriteTime(mCurrentLogPath);
				}
				else {
					mLog.AppendChild(mLog.CreateProcessingInstruction(
						"xml-stylesheet", "type=\"text/xsl\" href=\"" + RelativeUri(mCurrentLogPath, XsltPath) + "\""));

					XmlElement logEle = (XmlElement)mLog.AppendChild(mLog.CreateElement("log"));
					logEle.SetAttribute("date", DateTime.Today.ToLongDateString());
					logEle.SetAttribute("generator", Util.PluginNameVer);
					logEle.SetAttribute("bkgd", RelativeUri(mCurrentLogPath, BkgdPath));
					logEle.SetAttribute("fileVer", LogFileVer.ToString());

					mLogLastModified = DateTime.MinValue;
				}

				mSessionId = Util.BaseN(DateTime.Now.Ticks - DateTime.Today.Ticks, 62);
				mSession = (XmlElement)mLog.DocumentElement.AppendChild(mLog.CreateElement("session"));
				mSession.SetAttribute("character", mCharacterName);
				mSession.SetAttribute("server", mServerName);
				mSession.SetAttribute("id", mSessionId);

				if (continueFromHref != null) {
					XmlElement continueEle = (XmlElement)mSession.AppendChild(mLog.CreateElement("continueFrom"));
					continueEle.SetAttribute("href", continueFromHref);
					if (continueFromText != null) {
						continueEle.SetAttribute("text", continueFromText);
					}
				}

				// If nothing further is added to the log before it is closed, then 
				// setting mLogChanged = false here will prevent a blank log session
				mLogChanged = false;
			}
		}

		public void ReopenLog(bool createLink) {
			// If the log isn't currently open, just open it
			if (!IsLogOpen) {
				OpenLog();
				return;
			}

			string oldPath = mCurrentLogPath;
			string newPath = GenerateLogPath();

			if (oldPath == newPath) {
				// Nothing to do
				return;
			}

			if (createLink) {
				string oldDesc = mCurrentLogDescription;
				string newDesc = GenerateLogDescription();

				CloseLog(RelativeUri(oldPath, newPath), newDesc);
				OpenLog(RelativeUri(newPath, oldPath), oldDesc);
			}
			else {
				CloseLog();
				OpenLog();
			}
		}

		private void SaveTimer_Tick(object sender, EventArgs e) {
			try {
				if (mLogChanged) {
					SaveLog();
				}
			}
			catch (Exception ex) { Util.HandleException(ex); }
		}

		public void SaveLog() {
			if (!IsLogOpen)
				return;

			if (!Directory.Exists(Path.GetDirectoryName(mCurrentLogPath))) {
				Directory.CreateDirectory(Path.GetDirectoryName(mCurrentLogPath));
			}

			// Ensure xslt and bmp files exist
			if (!Directory.Exists(LogFilesPath)) {
				Directory.CreateDirectory(LogFilesPath);
			}

			if (!File.Exists(XsltPath)) {
				File.WriteAllText(XsltPath, Properties.Resources.logwiz_xslt);
			}

			if (!File.Exists(BkgdPath)) {
				File.WriteAllBytes(BkgdPath, Properties.Resources.bkgd_gif);
			}

			FileInfo logFile = new FileInfo(mCurrentLogPath);
			if (logFile.Exists && mLogLastModified != logFile.LastWriteTime) {
				// Modified out-of-process; reload xml and import current session
				mLog.Load(mCurrentLogPath);
				mSession = (XmlElement)mLog.ImportNode(mSession, true);

				// Remove the old copy of this session
				XmlNode loadedSession = mLog.DocumentElement.SelectSingleNode("session[@id=\"" + mSessionId + "\"]");
				if (loadedSession != null) {
					mLog.DocumentElement.RemoveChild(loadedSession);
				}
				mLog.DocumentElement.AppendChild(mSession);
			}

			Util.SaveXml(mLog, mCurrentLogPath);

			mLogLastModified = File.GetLastWriteTime(mCurrentLogPath);

			mLogChanged = false;
		}

		public void CloseLog() {
			CloseLog(null, null);
		}

		public void CloseLog(string continueToHref, string continueToText) {
			if (IsLogOpen) {
				if (continueToHref != null) {
					XmlElement continueEle = (XmlElement)mSession.AppendChild(mLog.CreateElement("continueTo"));
					continueEle.SetAttribute("href", continueToHref);
					if (continueToText != null) {
						continueEle.SetAttribute("text", continueToText);
					}

					mLogChanged = true;
				}

				if (mLogChanged) {
					SaveLog();
				}
			}
			mLog = null;
			mSession = null;
		}

		private string GenerateLogPath() {
			string prefix = LogsFolder;
			if (LogPerCharacter) {
				prefix += mCharacterName + " [" + mServerName + @"]\";
			}
			return Util.FullPath(prefix + DateTime.Today.ToLongDateString() + ".xml");
		}

		private string GenerateLogDescription() {
			string desc = DateTime.Today.ToShortDateString();
			if (LogPerCharacter) {
				desc += " for " + mCharacterName + " [" + mServerName + "]";
			}
			return desc;
		}

		private string RelativeUri(string fromPath, string toPath) {
			Uri source = new Uri(fromPath, UriKind.Absolute);
			Uri dest = new Uri(toPath, UriKind.Absolute);

			return source.MakeRelativeUri(dest).ToString();
		}
	}
}
