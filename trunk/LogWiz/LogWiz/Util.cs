using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;
using System.Xml;
using System.Threading;

using Decal.Adapter;
using Decal.Adapter.Wrappers;
using DecalTimer = Decal.Interop.Input.TimerClass;
using System.Text;

namespace LogWiz {
	static class Util {
		public const int MainChat = 1;

		[DllImport("user32")]
		private static extern short GetAsyncKeyState(int vKey);
		private const int VK_SHIFT = 0x10, VK_CTRL = 0x11, VK_ALT = 0x12;

		private static string mPluginName = "";
		private static string mBasePath = null;
		private static HooksWrapper mHooks = null;
		private static int mDefaultTargetWindow = MainChat;
		private static bool mWriteErrorsToMainChat = true;
		private static int mNumExceptionsWritten = 0;
		private static Thread mMainPluginThread = null;
		private static DecalTimer mHeartbeatTimer = null;
		private static bool mDisableAllMessages = false;


		public static event EventHandler<ChatTextEventArgs> ChatText;

		private struct ChatMessage {
			public string Message;
			public int Color;
			public int TargetWindow;

			public ChatMessage(string message, int color, int targetWindow) {
				this.Message = message;
				this.Color = color;
				this.TargetWindow = targetWindow;
			}
		}
		private static volatile Queue<ChatMessage> mOtherThreadChatMessages = new Queue<ChatMessage>();

		public static void Initialize(string pluginName, HooksWrapper hooks, string basePath, bool useInternalHeartbeat) {
			mPluginName = pluginName;
			mHooks = hooks;
			mBasePath = basePath;
			mMainPluginThread = Thread.CurrentThread;

			if (useInternalHeartbeat && mHeartbeatTimer == null) {
				mHeartbeatTimer = new DecalTimer();
				mHeartbeatTimer.Timeout += new Decal.Interop.Input.ITimerEvents_TimeoutEventHandler(HeartbeatTimer_Timeout);
				mHeartbeatTimer.Start(100);
			}
		}

		public static void Dispose() {
			mHooks = null;
			mMainPluginThread = null;

			if (mHeartbeatTimer != null) {
				mHeartbeatTimer.Stop();
				mHeartbeatTimer.Timeout -= HeartbeatTimer_Timeout;
				mHeartbeatTimer = null;
			}

#if DEBUG
			if (mDebugWriter != null) {
				mDebugWriter.Dispose();
				mDebugWriter = null;
			}
#endif
		}

		public static string PluginName {
			get { return mPluginName; }
		}

		public static string PluginVer {
			get { return System.Reflection.Assembly.GetExecutingAssembly().GetName().Version.ToString(4); }
		}

		public static string PluginNameVer {
			get { return PluginName + " v" + PluginVer; }
		}

		public static HooksWrapper Hooks {
			get { return mHooks; }
			set { mHooks = value; }
		}

		public static string BasePath {
			get {
				if (mBasePath == null) {
					mBasePath = System.Reflection.Assembly.GetExecutingAssembly().Location.ToString();
					int slash = mBasePath.LastIndexOf('\\');
					if (slash > 0)
						mBasePath = mBasePath.Substring(0, slash + 1);
				}
				return mBasePath;
			}
			set {
				if (value.EndsWith("\\"))
					mBasePath = value;
				else
					mBasePath = value + "\\";
			}
		}

		public static Thread MainPluginThread {
			get { return mMainPluginThread; }
			set { mMainPluginThread = value; }
		}

		public static int DefaultTargetWindow {
			get { return mDefaultTargetWindow; }
			set { mDefaultTargetWindow = value; }
		}

		public static bool WriteErrorsToMainChat {
			get { return mWriteErrorsToMainChat; }
			set { mWriteErrorsToMainChat = value; }
		}

		public static bool DisableAllMessages {
			get { return mDisableAllMessages; }
			set { mDisableAllMessages = value; }
		}

		public static bool IsControlDown() {
			return GetAsyncKeyState(VK_CTRL) != 0;
		}

		public static bool IsShiftDown() {
			return GetAsyncKeyState(VK_SHIFT) != 0;
		}

		public static void Message(string msg) {
			Message(msg, DefaultTargetWindow);
		}

		public static void Message(string msg, int targetWindow) {
			//wtcw("«17»<{ «2»" + PluginName + "«17» }> «d»" + msg, 13, targetWindow);
			AddChatText("<{ " + PluginName + " }> " + StripColorTags(msg), 13, targetWindow);
		}

		public static void Warning(string msg) {
			Warning(msg, DefaultTargetWindow);
		}

		public static void Warning(string msg, int targetWindow) {
			//wtcw("«3»<{ «2»" + PluginName + "«3» }> «d»" + msg, 3, targetWindow);
			AddChatText("<{ " + PluginName + " }> " + StripColorTags(msg), 3, targetWindow);
		}

		public static void Error(string msg) {
			Error(msg, false, DefaultTargetWindow);
		}

		public static void Error(string msg, bool includePluginVersion) {
			Error(msg, includePluginVersion, DefaultTargetWindow);
		}

		public static void Error(string msg, bool includePluginVersion, int targetWindow) {
			string nameVer = includePluginVersion ? PluginNameVer : PluginName;
			//wtcw("«6»<{ «2»" + nameVer + "«6» }> «d»" + msg, 8, targetWindow);
			AddChatText("<{ " + nameVer + " }> " + StripColorTags(msg), 8, targetWindow);
			if (WriteErrorsToMainChat && targetWindow != MainChat) {
				Error(msg, includePluginVersion, MainChat);
			}
		}

		public static void SevereError(string msg) {
			SevereError(msg, DefaultTargetWindow);
		}

		public static void SevereError(string msg, int targetWindow) {
			AddChatText("<{ " + PluginNameVer + " }> " + StripColorTags(msg), 6, targetWindow);
			if (targetWindow != MainChat) {
				SevereError(msg, MainChat);
			}
		}

		public static void Debug(string msg) {
			Debug(msg, DefaultTargetWindow);
		}

		public static void Debug(string msg, int targetWindow) {
			//wtcw("«17»<{ «2»" + PluginName + "«17» }> «d»" + msg, 14, targetWindow);
			AddChatText("<{ " + PluginName + " Debug }> " + StripColorTags(msg), 12, targetWindow);
		}

		public static void AddChatText(string msg, int color) {
			AddChatText(msg, color, DefaultTargetWindow);
		}

		public static void AddChatText(string msg, int color, int targetWindow) {
			if (ChatText != null) {
				try {
					ChatText(null, new ChatTextEventArgs(msg, color));
				}
				catch { /* Ignore */ }
			}
			if (mHooks != null && !DisableAllMessages) {
				if (Thread.CurrentThread == MainPluginThread || MainPluginThread == null) {
					mHooks.AddChatText(msg, color, targetWindow);
				}
				else {
					// Queue the message to be sent in the main plugin thread
					mOtherThreadChatMessages.Enqueue(new ChatMessage(msg, color, targetWindow));
				}
			}
			else {
				FileInfo messagesFile = new FileInfo(FullPath("messages.txt"));
				// Delete and recreate the file if it's over 1MB in size or over 7 days old.
				if (messagesFile.Exists && (messagesFile.Length > 1024 * 1024 ||
						DateTime.Now.Subtract(messagesFile.LastWriteTime).Days > 7)) {
					messagesFile.Delete();
				}
				LogLine("messages.txt", msg);
			}
		}

		private static void HeartbeatTimer_Timeout(Decal.Interop.Input.Timer Source) {
			WriteOtherThreadMessages();
		}

		/// <summary>
		/// This method needs to be called frequently from the main plugin 
		/// thread to be sure that chat messages from other threads are 
		/// written promptly.
		/// </summary>
		public static void WriteOtherThreadMessages() {
			if (mHooks != null && (Thread.CurrentThread == MainPluginThread || MainPluginThread == null)) {
				while (mOtherThreadChatMessages.Count > 0) {
					ChatMessage msg = mOtherThreadChatMessages.Dequeue();
					mHooks.AddChatText(msg.Message, msg.Color, msg.TargetWindow);
				}
			}
		}

		public static void HandleException(Exception ex) {
			HandleException(ex, "Error", false);
		}

		public static void HandleException(Exception ex, string messagePrefix, bool severe) {
			try {
				Exception fileWriteException = null;
				try {
					LogException(ex);
				}
				catch (Exception fwe) { fileWriteException = fwe; }

				string errMsg = messagePrefix + " [" + ex.GetType().Name + "]";
				if (ex.Message.Length < 100)
					errMsg += ": " + ex.Message;
				if (fileWriteException == null) {
					errMsg += " See errors.txt in the " + PluginName + " folder for more info.";
				}
				else {
					errMsg += "\nAlso, an error occured while trying to write to errors.txt ["
						+ fileWriteException.GetType().Name + "]: " + fileWriteException.Message;
				}
				if (mNumExceptionsWritten < 20) {
					if (severe)
						SevereError(errMsg);
					else
						Error(errMsg, true);
				}
				if (mNumExceptionsWritten == 20) {
					SevereError("Over 20 errors encountered; further error messages suppressed. "
						+ "Error messages will continue to be written to errors.txt in the "
						+ PluginName + " folder, which may cause lag. It is highly recommended "
						+ "that you log off and either fix or disable " + PluginName + ".");
				}
				mNumExceptionsWritten++;
			}
			catch { /* Ignore... */ }
		}

		public static void LogException(Exception ex) {
			try {
				FileInfo errorFile = new FileInfo(FullPath("errors.txt"));
				// Delete and recreate the file if it's over 1MB in size or over 7 days old.
				if (errorFile.Exists && (errorFile.Length > 1024 * 1024 ||
						DateTime.Now.Subtract(errorFile.LastWriteTime).Days > 7))
					errorFile.Delete();

				using (StreamWriter sw = new StreamWriter(FullPath("errors.txt"), true)) {
					sw.WriteLine();
					sw.WriteLine("===[ " + System.DateTime.Now.ToString() + " - "
						+ PluginNameVer + " ]========================");
					sw.WriteLine(ex.GetType().ToString() + ": " + ex.Message);
					if (ex.StackTrace != null) {
						sw.WriteLine(StripFullPaths(ex.StackTrace));
					}
					if (ex.InnerException != null) {
						Exception iex = ex.InnerException;
						sw.WriteLine("[Inner Exception] " + iex.GetType().ToString() + ": " + iex.Message);
						if (iex.StackTrace != null)
							sw.WriteLine(StripFullPaths(iex.StackTrace));
					}
				}
			}
			catch { /* Ignore... */ }
		}

		public static void LogLine(string fileName, string message) { LogLine(fileName, message, true); }
		public static void LogLine(string fileName, string message, bool includeDateTime) {
			FileInfo logFile = new FileInfo(FullPath(fileName));
			// Delete and recreate the file if it's over 1MB in size or over 30 days old.
			if (logFile.Exists && (logFile.Length > 1024 * 1024 ||
					DateTime.Now.Subtract(logFile.LastWriteTime).Days > 30)) {
				logFile.Delete();
			}

			using (StreamWriter sw = new StreamWriter(FullPath(fileName), true)) {
				if (includeDateTime)
					message = "[" + System.DateTime.Now.ToString() + "] " + message;
				sw.WriteLine(message);
			}
		}

#if DEBUG
		private static StreamWriter mDebugWriter;
		public static void DebugLog(string message) {
			if (mDebugWriter == null) {
				FileInfo logFile = new FileInfo(FullPath("debug.log"));
				// Delete and recreate the file if it's over 4MB in size or over 2 days old.
				if (logFile.Exists && (logFile.Length > 4 * 1024 * 1024 || DateTime.Now.Subtract(logFile.LastWriteTime).Days > 2)) {
					logFile.Delete();
				}

				mDebugWriter = new StreamWriter(FullPath("debug.log"), true);
				mDebugWriter.WriteLine();
				mDebugWriter.WriteLine();
				mDebugWriter.WriteLine("############## Debugging started ##############");
			}
			mDebugWriter.WriteLine("[" + System.DateTime.Now.ToString() + "] " + message);
			mDebugWriter.Flush();
		}
#endif

		public static string FullPath(string fileName) {
			return System.IO.Path.Combine(BasePath, fileName);
		}

		public static void SaveXml(XmlDocument doc, string filePath) {
			XmlWriterSettings writerSettings = new XmlWriterSettings();
			writerSettings.Indent = true;
			writerSettings.IndentChars = "\t";
			using (XmlWriter writer = XmlWriter.Create(filePath, writerSettings)) {
				doc.Save(writer);
			}
		}

		public static string BaseN(long num, uint radix) {
			return BaseN(unchecked((ulong)num), radix);
		}

		public static string BaseN(ulong num, uint radix) {
			if (radix < 2 || radix > 62) {
				throw new ArgumentException("Radix must be between 2 and 62.");
			}
			StringBuilder builder = new StringBuilder();
			do {
				int x = (int)(num % radix);
				if (x < 10) {
					builder.Insert(0, (char)('0' + x));
				}
				else if (x < 36) {
					builder.Insert(0, (char)('a' + x - 10));
				}
				else {
					builder.Insert(0, (char)('A' + x - 36));
				}
				num /= radix;
			} while (num != 0);

			return builder.ToString();
		}

		public static bool TryParseBase(string parse, uint radix, out ulong value) {
			if (radix < 2 || radix > 62) {
				throw new ArgumentException("Radix must be between 2 and 62.");
			}

			value = 0;

			char maxInt, maxLAlpha, maxUAlpha;
			if (radix < 10) {
				maxInt = (char)('0' + radix - 1);
				maxLAlpha = maxUAlpha = '\0';
			}
			else if (radix < 36) {
				maxInt = '9';
				maxLAlpha = (char)('a' + radix - 11);
				maxUAlpha = '\0';
			}
			else {
				maxInt = '9';
				maxLAlpha = 'z';
				maxUAlpha = (char)('A' + radix - 37);
			}

			for (int i = 0; i < parse.Length; i++) {
				value *= radix;
				if (parse[i] >= '0' && parse[i] <= maxInt) {
					value += (ulong)(parse[i] - '0');
				}
				else if (parse[i] >= 'a' && parse[i] <= maxLAlpha) {
					value += (ulong)(parse[i] - 'a' + 10);
				}
				else if (parse[i] >= 'A' && parse[i] <= maxUAlpha) {
					value += (ulong)(parse[i] - 'A' + 36);
				}
				else {
					return false;
				}
			}
			return true;
		}

		public static ulong ParseBase(string parse, uint radix) {
			ulong ret;
			if (!TryParseBase(parse, radix, out ret)) {
				throw new FormatException();
			}
			return ret;
		}

		/*** Private Methods ***/
		private static string StripFullPaths(string stackTrace) {
			try {
				string[] lines = stackTrace.Split('\n');
				for (int i = 0; i < lines.Length; i++) {
					int inPos = lines[i].IndexOf(" in ");
					if (inPos > 0 && lines[i].IndexOf(".cs:line") > inPos) {
						int slashPos = lines[i].LastIndexOf('\\');
						if (slashPos > inPos) {
							lines[i] = lines[i].Substring(0, inPos + 4) + lines[i].Substring(slashPos + 1);
						}
					}
				}
				return string.Join("\n", lines);
			}
			catch { return stackTrace; }
		}

		private static string StripColorTags(string msg) {
			if (!msg.Contains("«"))
				return msg;
			return Regex.Replace(msg, "«([0-9]{1,2}|d)»", "");
		}

#if FALSE
		private static void WriteToChat(string msg, int defaultColor, int chatTextTarget) {
			if (mHooks == null)
				return;

			msg = msg.Replace("«d»", "«" + defaultColor + "»");

			if (!msg.EndsWith("\r"))
				msg += "\r";

			string[] pieces = msg.Split(new char[] { '«' }, StringSplitOptions.RemoveEmptyEntries);
			int[] colors = new int[pieces.Length];

			for (int i = 0; i < pieces.Length; i++) {
				string[] colorAndText = pieces[i].Split(new char[] { '»' }, 2);
				try {
					colors[i] = int.Parse(colorAndText[0]);
					pieces[i] = colorAndText[1];
				}
				catch {
					mHooks.AddChatTextRaw(PluginName +
						" Error - Malformatted string specified to print to screen ::\r" + msg, 8, chatTextTarget);
					return;
				}
			}

			for (int i = 0; i < pieces.Length; i++) {
				if (pieces[i] != "")
					mHooks.AddChatTextRaw(pieces[i], colors[i], chatTextTarget);
			}
		}
#endif
	}

	class ChatTextEventArgs : EventArgs {
		string mMessage;
		int mColor;

		public ChatTextEventArgs(string message, int color) {
			mMessage = message;
			mColor = color;
		}

		public string Message { get { return mMessage; } }
		public int Color { get { return mColor; } }
	}
}
