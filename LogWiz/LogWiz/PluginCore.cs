using System;
using System.Collections.Generic;
using System.Text;
using IOPath = System.IO.Path;

using Decal.Adapter;
using Decal.Adapter.Wrappers;
using System.Text.RegularExpressions;

namespace LogWiz {
	enum LogThisCharEnum { Never, Always, Default }

	[WireUpBaseEvents]
	[FriendlyName("LogWiz")]
	public partial class PluginCore : PluginBase {
		private const string ChatCommand = "logwiz"; // Must be lower case

		private static readonly Regex TellLink = new Regex(@"<Tell:IIDString:[^>]+>([^<]*)<\\Tell>");

		#region Message Handlers
		private const string UnknownUnused = "Unknown/Unused";
		private static readonly Regex EnterLeaveChannel = new Regex(
			@"You have (entered|left) the (Allegiance|Roleplay|LFG|Trade|General) channel.");

		private MessageHandler[] mHandlers = {
			new MessageHandler("Most Green Text", Colors.ByType(0), true, 0),
			new MessageHandler(UnknownUnused, Colors.ByType(1), true, 1),
			new MessageHandler("Local Chat", Colors.ByType(2), true, 2),
			new MessageHandler("Tell Receive", Colors.ByType(3), true, 3),
			new MessageHandler("Tell Send", Colors.ByType(4), true, 4),
			new MessageHandler("Rare Discover/House Maintenance", Colors.ByType(5), true, 5),
			new MessageHandler("Impact Damage", Colors.ByType(6), false, 6),
			new MessageHandler("Spells/Burn/Fizzle (not spell words)", Colors.ByType(7), false, 7),
			new MessageHandler(UnknownUnused, Colors.ByType(8), true, 8),
			new MessageHandler(UnknownUnused, Colors.ByType(9), true, 9),
			new MessageHandler("From Fellow/Patron/Vassal", Colors.ByType(10), true, 10),
			new MessageHandler("To Fellow/Patron/Vassal", Colors.ByType(11), true, 11),
			new MessageHandler("Emote", Colors.ByType(12), true, 12),
			new MessageHandler("Level Up, Skill/Stat Increase", Colors.ByType(13), true, 13),
			new MessageHandler(UnknownUnused, Colors.ByType(14), true, 14),
			new MessageHandler(UnknownUnused, Colors.ByType(15), true, 15),
			new MessageHandler("Failed Assess", Colors.ByType(16), false, 16),
			new MessageHandler("Spell Words (Shurov Thiloi)", Colors.ByType(17), false, 17),
			new MessageHandler("Allegiance Chat", Colors.ByType(18), true, 18),
			new MessageHandler(UnknownUnused, Colors.ByType(19), true, 19),
			new MessageHandler(UnknownUnused, Colors.ByType(20), true, 20),
			new MessageHandler("Damage Received", Colors.ByType(21), false, 21),
			new MessageHandler("Damage Dealt", Colors.ByType(22), false, 22),
			new MessageHandler("Recalls", Colors.ByType(23), false, 23),
			new MessageHandler("Tinkering", Colors.ByType(24), true, 24),
			new MessageHandler(UnknownUnused, Colors.ByType(25), true, 25),
			new MessageHandler(UnknownUnused, Colors.ByType(26), true, 26),
			new MessageHandler("General Channel", Colors.ByType(27), true, 27),
			new MessageHandler("Trade Channel", Colors.ByType(28), true, 28),
			new MessageHandler("LFG Channel", Colors.ByType(29), true, 29),
			new MessageHandler("Roleplay Channel", Colors.ByType(30), true, 30),
			new MessageHandler(UnknownUnused, Colors.ByType(31), true, 31),
			new MessageHandler(UnknownUnused, Colors.ByType(32), true, 32),
		};

		private MessageHandler[] mCustomHandlers = {
			new MessageHandler("Bots (<t>, -b-)", Colors.ByType(2), false, 
				delegate(string msg, int color) { 
					return (color == 2 || color == 12) && (msg.Contains("<t>") || msg.Contains("-b-")); 
				}),
			new MessageHandler("Chat channel enter/leave messages", Colors.ByType(0), false,
				delegate(string msg, int color) {
					return (color == 0) && EnterLeaveChannel.IsMatch(msg.Trim());
				}),
		};
		#endregion

		private bool mLoggedIn = false;

		private Logger mLogger;
		private bool mLoggingEnabled = false;

		private bool mLogByDefault = false;
		private LogThisCharEnum mLogForThisCharacter = LogThisCharEnum.Default;
		private bool mLogPerCharacter = false;
		private LogTypeEnum mLogType = LogTypeEnum.Xml;
		private bool mTimestamp = true;
		private bool mStealthMode = false;

		private string mCharName = "Unknown";
		private string mServer = "Unknown";

		protected override void Startup() {
			try {
				Util.Initialize("LogWiz", Host.Actions, base.Path, true);

				Core.CharacterFilter.Login += new EventHandler<LoginEventArgs>(CharacterFilter_Login);

				LoadGeneralSettings();
				if (!StealthMode) {
					InitMainViewBeforeSettings();
				}

				Util.ChatText += new EventHandler<ChatTextEventArgs>(Util_ChatText);
			}
			catch (Exception ex) { Util.HandleException(ex); }
		}

		private void CharacterFilter_Login(object sender, LoginEventArgs e) {
			try {
				mCharName = Core.CharacterFilter.Name;
				mServer = Core.CharacterFilter.Server;
				mLoggedIn = true;
				LoadCharacterSettings();

				mLoggingEnabled = CalcLoggingEnabled();

				if (mLoggingEnabled) {
					StartLogging(false);
				}

				if (!StealthMode) {
					InitMainViewAfterSettings();
				}

				Core.CharacterFilter.Login -= CharacterFilter_Login;
			}
			catch (Exception ex) { Util.HandleException(ex); }
		}

		protected override void Shutdown() {
			try {
				SaveSettings();

				Core.CharacterFilter.Login -= CharacterFilter_Login;
				mLoggedIn = false;

				DisposeMainView();

				if (mLogger != null) {
					mLogger.Dispose();
					mLogger = null;
				}

				Util.Dispose();
			}
			catch (Exception ex) { Util.HandleException(ex); }
		}

		private void ShowHelp() {
			const string cmd = "    /" + ChatCommand;
			string msg = "You're using " + Util.PluginNameVer + ". Here are the commands available:\n"
				+ cmd + " status  -  Show the logging and stealth status of the plugin.\n"
				+ cmd + " start/stop  -  Start or stop logging.\n"
				+ cmd + " stealth [on|off]  -  Enable or disable stealth mode.\n"
				+ cmd + " help  -  Show this help message.\n";
			Util.AddChatText(msg, 0);
		}

		[BaseEvent("CommandLineText")]
		private void PluginCore_CommandLineText(object sender, ChatParserInterceptEventArgs e) {
			bool isChatDisabled = Util.DisableAllMessages;
			Util.DisableAllMessages = false;

			try {
				string text = e.Text.ToLower();

				if (text.StartsWith("@" + ChatCommand) || text.StartsWith("/" + ChatCommand)) {
					if (text.Length == 1 + ChatCommand.Length) {
						e.Eat = true;
						ShowHelp();
						return;
					}

					if (!char.IsWhiteSpace(text[1 + ChatCommand.Length]))
						return;

					e.Eat = true;
					text = text.Substring(1 + ChatCommand.Length).Trim();
					string arg = "";
					int idx = text.IndexOf(' ');
					if (idx > 0) {
						arg = text.Substring(idx).Trim();
						text = text.Substring(0, idx).Trim();
					}

					switch (text) {
						case "":
						case "help":
							if (arg == "stealth") {
								ShowStealthModeHelp();
							}
							else {
								ShowHelp();
							}
							break;

						case "on/off":
						case "start/stop":
							StartStopLogging(!mLoggingEnabled, true);
							break;

						case "on":
						case "start":
							StartStopLogging(true, true);
							break;

						case "off":
						case "stop":
							StartStopLogging(false, true);
							break;

						case "status":
							Util.Message(GetStatus(false));
							if (StealthMode) {
								Util.Message("Stealth mode is enabled.");
							}
							break;

						case "stealth":
							if (arg == "") {
								Util.Message("Stealth mode is " + (StealthMode ? "enabled" : "disabled"));
							}
							else if (arg == "on" || arg == "enable") {
								if (StealthMode) {
									Util.Message("Stealth mode is already enabled");
								}
								else {
									Util.Message("Stealth mode enabled.");
									StealthMode = true;
									isChatDisabled = Util.DisableAllMessages;
									Util.DisableAllMessages = false;
								}
							}
							else if (arg == "off" || arg == "disable") {
								if (!StealthMode) {
									Util.Message("Stealth mode is already disabled.");
								}
								else {
									Util.Message("Stealth mode disabled.");
									StealthMode = false;
									isChatDisabled = Util.DisableAllMessages;
									Util.DisableAllMessages = false;
								}
							}
							else {
								Util.Error("Specify either 'on' or 'off' for stealth mode.");
							}
							break;

						default:
							Util.Error("Invalid command: " + text + ". "
								+ "Type /" + ChatCommand + " help for a list of available commands");
							break;
					}
				}
			}
			catch (Exception ex) {
				Util.HandleException(ex);
			}
			finally {
				Util.DisableAllMessages = isChatDisabled;
			}
		}

		private string GetStatus(bool concise) {
			if (mLoggingEnabled) {
				string path = mLogger.LogPath.Replace('/', '\\');
				if (concise) {
					int logIndex = path.LastIndexOf(@"\Logs\");
					if (logIndex >= 0) {
						int parentIndex = path.LastIndexOf(@"\", logIndex - 1);
						if (parentIndex >= 0) {
							path = IOPath.GetPathRoot(path) + "..." + path.Substring(parentIndex);
						}
					}
				}
				return "Logging to: " + path;
			}
			else {
				return "Currently not logging.";
			}
		}

		private bool LogByDefault {
			get { return mLogByDefault; }
			set {
				if (mLogByDefault != value) {
					mLogByDefault = value;
					if (CalcLoggingEnabled() != mLoggingEnabled) {
						StartStopLogging(!mLoggingEnabled, false);
					}
					if (MainView != null) {
						chkLogByDefault.Checked = value;
					}
				}
			}
		}

		private LogThisCharEnum LogForThisCharacter {
			get { return mLogForThisCharacter; }
			set {
				if (mLogForThisCharacter != value) {
					mLogForThisCharacter = value;
					if (CalcLoggingEnabled() != mLoggingEnabled) {
						StartStopLogging(!mLoggingEnabled, false);
					}
					if (MainView != null) {
						switch (mLogForThisCharacter) {
							case LogThisCharEnum.Never:
								choLogForThisChar.Selected = LogThisCharChoice.Never;
								break;
							case LogThisCharEnum.Always:
								choLogForThisChar.Selected = LogThisCharChoice.Always;
								break;
							case LogThisCharEnum.Default:
								choLogForThisChar.Selected = LogThisCharChoice.Default;
								break;
						}
					}
				}
			}
		}

		private bool LogPerCharacter {
			get { return mLogPerCharacter; }
			set {
				if (mLogPerCharacter != value) {
					mLogPerCharacter = value;
					if (mLogger != null) {
						mLogger.LogPerCharacter = mLogPerCharacter;
					}
					if (MainView != null) {
						chkLogPerChar.Checked = value;
						txtLogStatus.Text = GetStatus(true);
					}
				}
			}
		}

		private LogTypeEnum LogType {
			get { return mLogType; }
			set {
				if (mLogger == null || mLogType != value) {
					if (mLogType != value && MainView != null) {
						switch (value) {
							case LogTypeEnum.Xml:
								chkOutputXml.Checked = true;
								chkOutputText.Checked = false;
								break;
							case LogTypeEnum.Text:
								chkOutputXml.Checked = false;
								chkOutputText.Checked = true;
								break;
						}
						txtLogStatus.Text = GetStatus(true);
					}
					mLogType = value;
					StopLogging(false);
					StartLogging(false);
				}
			}
		}

		private bool Timestamp {
			get { return mTimestamp; }
			set {
				if (mTimestamp != value) {
					mTimestamp = value;
					if (mLogger != null) {
						mLogger.Timestamp = value;
					}
				}
			}
		}

		private bool StealthMode {
			get { return mStealthMode; }
			set {
				if (mStealthMode != value) {
					mStealthMode = value;

					Util.DisableAllMessages = mStealthMode;
					if (mStealthMode) {
						DisposeMainView();
					}
					else {
						if (MainView == null) {
							InitMainViewBeforeSettings();
							if (mCharacterSettingsLoaded) {
								InitMainViewAfterSettings();
							}
						}
					}

					if (MainView != null) {
						chkStealthMode.Checked = mStealthMode;
					}
				}
			}
		}

		private bool CalcLoggingEnabled() {
			return (mLogForThisCharacter == LogThisCharEnum.Always)
				|| (mLogForThisCharacter == LogThisCharEnum.Default && mLogByDefault);
		}

		private void StartStopLogging(bool start, bool verbose) {
			if (mLoggingEnabled != start) {
				if (start)
					StartLogging(verbose);
				else
					StopLogging(verbose);
			}
			else if (verbose) {
				Util.Warning(Util.PluginName + " is already " + (start ? "logging!" : "stopped!"));
			}
		}

		private void StartLogging(bool verbose) {
			if (!mLoggedIn)
				return;

			mLoggingEnabled = true;

			if (mLogger != null && mLogger.LogType != mLogType) {
				mLogger.Dispose();
				mLogger = null;
			}

			if (mLogger == null) {
				switch (LogType) {
					case LogTypeEnum.Xml:
						mLogger = new XmlLogger(mCharName, mServer, mLogPerCharacter, mTimestamp);
						break;
					case LogTypeEnum.Text:
						mLogger = new TextLogger(mCharName, mServer, mLogPerCharacter, mTimestamp);
						break;
					default:
						Util.Error("Unknown log type: " + mLogType);
						break;
				}
			}

			if (verbose) {
				Util.Message("Logging started.");
			}

			if (MainView != null) {
				btnStartStop.Text = "Stop Logging";
				txtLogStatus.Text = GetStatus(true);
			}
		}

		private void StopLogging(bool verbose) {
			mLoggingEnabled = false;

			if (verbose) {
				Util.Message("Logging stopped.");
			}

			if (MainView != null) {
				btnStartStop.Text = "Start Logging";
				txtLogStatus.Text = GetStatus(true);
			}
		}

		[BaseEvent("ChatBoxMessage")]
		private void PluginCore_ChatBoxMessage(object sender, ChatTextInterceptEventArgs e) {
			try {
				if (mLoggingEnabled && mLogger != null) {
					string text = TellLink.Replace(e.Text.TrimEnd(), "$1");

					bool handled = false;
					int c = e.Color;
					foreach (MessageHandler mh in mCustomHandlers) {
						if (mh.CheckMessage(text, c)) {
							if (mh.Enabled) {
								mLogger.LogMessage(text, c);
							}
							handled = true;
							break;
						}
					}
					if (!handled && c >= 0 && c < mHandlers.Length && mHandlers[c].Enabled
							&& mHandlers[c].CheckMessage(text, c)) {
						mLogger.LogMessage(text, c);
					}
				}
			}
			catch (Exception ex) { Util.HandleException(ex); }
		}

		private void Util_ChatText(object sender, ChatTextEventArgs e) {
			if (mLoggingEnabled && mLogger != null) {
				mLogger.LogMessage(e.Message, e.Color);
			}
		}
	}
}
