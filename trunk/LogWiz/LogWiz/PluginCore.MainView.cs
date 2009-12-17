using System;

using Decal.Adapter;
using Decal.Adapter.Wrappers;
using System.Drawing;

namespace LogWiz {
	public partial class PluginCore : PluginBase {
		private const int LabelId = int.MaxValue;

		private ViewWrapper MainView;

		#region Control References
		private PushButtonWrapper btnStartStop;
		private CheckBoxWrapper chkLogByDefault;
		private static class LogThisCharChoice {
			public const int Always = 0, Never = 1, Default = 2;
		}
		private ChoiceWrapper choLogForThisChar;
		private StaticWrapper txtLogForThisChar;
		private CheckBoxWrapper chkLogPerChar;
		private CheckBoxWrapper chkOutputXml;
		private CheckBoxWrapper chkOutputText;
		private CheckBoxWrapper chkTimestamp;
		private CheckBoxWrapper chkStealthMode;
		private PushButtonWrapper btnStealthModeHelp;
		private CheckBoxWrapper chkShowStatus;
		private PushButtonWrapper btnShowStatus;
		private StaticWrapper txtLogStatus;
		private static class MessageList {
			public const int Enabled = 0, Number = 1, Description = 2, Index = 3;
		}
		private ListWrapper lstMessageTypes;
		#endregion

		private Point mViewPosition = new Point(25, 50);
		private int mViewLoadCt = 0;

		private void InitMainViewBeforeSettings() {
			if (MainView != null)
				return;

			string viewName = "LogWizMainView" + (mViewLoadCt++);
			LoadView(viewName, "LogWiz.Properties.LogWiz.xml");
			MainView = GetView(viewName);

			btnStartStop = (PushButtonWrapper)MainView.Controls["btnStartStop"];
			chkLogByDefault = (CheckBoxWrapper)MainView.Controls["chkLogByDefault"];
			choLogForThisChar = (ChoiceWrapper)MainView.Controls["choLogForThisChar"];
			txtLogForThisChar = (StaticWrapper)MainView.Controls["txtLogForThisChar"];
			chkLogPerChar = (CheckBoxWrapper)MainView.Controls["chkLogPerChar"];
			chkOutputXml = (CheckBoxWrapper)MainView.Controls["chkOutputXml"];
			chkOutputText = (CheckBoxWrapper)MainView.Controls["chkOutputText"];
			chkTimestamp = (CheckBoxWrapper)MainView.Controls["chkTimestamp"];
			chkStealthMode = (CheckBoxWrapper)MainView.Controls["chkStealthMode"];
			btnStealthModeHelp = (PushButtonWrapper)MainView.Controls["btnStealthModeHelp"];
			chkShowStatus = (CheckBoxWrapper)MainView.Controls["chkShowStatus"];
			btnShowStatus = (PushButtonWrapper)MainView.Controls["btnShowStatus"];
			txtLogStatus = (StaticWrapper)MainView.Controls["txtLogStatus"];
			lstMessageTypes = (ListWrapper)MainView.Controls["lstMessageTypes"];

			btnStartStop.Click += new EventHandler<ControlEventArgs>(btnStartStop_Click);
			chkLogByDefault.Change += new EventHandler<CheckBoxChangeEventArgs>(chkLogByDefault_Change);
			choLogForThisChar.Change += new EventHandler<IndexChangeEventArgs>(choLogForThisChar_Change);
			chkLogPerChar.Change += new EventHandler<CheckBoxChangeEventArgs>(chkLogPerChar_Change);
			chkOutputXml.Change += new EventHandler<CheckBoxChangeEventArgs>(chkOutputXml_Change);
			chkOutputText.Change += new EventHandler<CheckBoxChangeEventArgs>(chkOutputText_Change);
			chkTimestamp.Change += new EventHandler<CheckBoxChangeEventArgs>(chkTimestamp_Change);
			chkStealthMode.Change += new EventHandler<CheckBoxChangeEventArgs>(chkStealthMode_Change);
			btnStealthModeHelp.Click += new EventHandler<ControlEventArgs>(btnStealthModeHelp_Click);
			chkShowStatus.Change += new EventHandler<CheckBoxChangeEventArgs>(chkShowStatus_Change);
			btnShowStatus.Click += new EventHandler<ControlEventArgs>(btnShowStatus_Click);
			lstMessageTypes.Selected += new EventHandler<ListSelectEventArgs>(lstMessageTypes_Selected);
		}

		private void InitMainViewAfterSettings() {
			if (MainView == null)
				return;

			btnStartStop.Text = mLoggingEnabled ? "Stop Logging" : "Start Logging";

			chkLogByDefault.Checked = LogByDefault;

			switch (LogForThisCharacter) {
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

			chkLogPerChar.Checked = LogPerCharacter;

			switch (LogType) {
				case LogTypeEnum.Xml:
					chkOutputXml.Checked = true;
					chkOutputText.Checked = false;
					break;
				case LogTypeEnum.Text:
					chkOutputXml.Checked = false;
					chkOutputText.Checked = true;
					break;
			}

			chkTimestamp.Checked = Timestamp;

			chkStealthMode.Checked = StealthMode;

			lstMessageTypes.Clear();

			for (int i = 0; i < mHandlers.Length; i++) {
				if (mHandlers[i].Description != UnknownUnused) {
					AddHandlerToList(mHandlers[i], i);
				}
			}

			AddLabelToList("Special message types");
			for (int i = 0; i < mCustomHandlers.Length; i++) {
				AddHandlerToList(mCustomHandlers[i], ~i);
			}

			AddLabelToList("Unknown message types");
			for (int i = 0; i < mHandlers.Length; i++) {
				if (mHandlers[i].Description == UnknownUnused) {
					AddHandlerToList(mHandlers[i], i);
				}
			}
		}

		private void DisposeMainView() {
			if (MainView == null)
				return;

			mViewPosition = MainView.Position.Location;

			btnStartStop.Click -= btnStartStop_Click;
			chkLogByDefault.Change -= chkLogByDefault_Change;
			choLogForThisChar.Change -= choLogForThisChar_Change;
			chkLogPerChar.Change -= chkLogPerChar_Change;
			chkOutputXml.Change -= chkOutputXml_Change;
			chkOutputText.Change -= chkOutputText_Change;
			chkTimestamp.Change -= chkTimestamp_Change;
			chkStealthMode.Change -= chkStealthMode_Change;
			btnStealthModeHelp.Click -= btnStealthModeHelp_Click;
			chkShowStatus.Change -= chkShowStatus_Change;
			btnShowStatus.Click -= btnShowStatus_Click;
			lstMessageTypes.Selected -= lstMessageTypes_Selected;

			MainView.Dispose();
			MainView = null;
		}

		private void AddHandlerToList(MessageHandler mh, int index) {
			ListRow row = lstMessageTypes.Add();
			row[MessageList.Enabled][0] = mh.Enabled;
			if (!mh.IsCustom) {
				row[MessageList.Number][0] = mh.ColorId.ToString();
				row[MessageList.Number].Color = mh.DisplayColor;
			}
			row[MessageList.Description][0] = mh.Description;
			row[MessageList.Description].Color = mh.DisplayColor;

			row[MessageList.Index][0] = index.ToString();
		}

		private void AddLabelToList(string text) {
			ListRow row = lstMessageTypes.Add();
			row[MessageList.Enabled][0] = false;
			row[MessageList.Number][0] = "--";
			row[MessageList.Description][0] = text + " ----------------------------------------------";
			row[MessageList.Index][0] = LabelId.ToString();
		}

		private Point ViewPosition {
			get {
				if (MainView != null) {
					return MainView.Position.Location;
				}
				return mViewPosition;
			}
			set {
				mViewPosition = value;
				if (MainView != null) {
					MainView.Position = new Rectangle(value, MainView.Position.Size);
				}
			}
		}

		private void btnStartStop_Click(object sender, ControlEventArgs e) {
			try {
				StartStopLogging(!mLoggingEnabled, true);
			}
			catch (Exception ex) { Util.HandleException(ex); }
		}

		private void chkLogByDefault_Change(object sender, CheckBoxChangeEventArgs e) {
			try {
				LogByDefault = e.Checked;
			}
			catch (Exception ex) { Util.HandleException(ex); }
		}

		private void choLogForThisChar_Change(object sender, IndexChangeEventArgs e) {
			try {
				switch (e.Index) {
					case LogThisCharChoice.Always:
						LogForThisCharacter = LogThisCharEnum.Always;
						break;
					case LogThisCharChoice.Never:
						LogForThisCharacter = LogThisCharEnum.Never;
						break;
					case LogThisCharChoice.Default:
						LogForThisCharacter = LogThisCharEnum.Default;
						break;
				}
			}
			catch (Exception ex) { Util.HandleException(ex); }
		}

		private void chkLogPerChar_Change(object sender, CheckBoxChangeEventArgs e) {
			try {
				LogPerCharacter = e.Checked;
			}
			catch (Exception ex) { Util.HandleException(ex); }
		}

		private void chkOutputXml_Change(object sender, CheckBoxChangeEventArgs e) {
			try {
				chkOutputText.Checked = !e.Checked;
				LogType = e.Checked ? LogTypeEnum.Xml : LogTypeEnum.Text;
			}
			catch (Exception ex) { Util.HandleException(ex); }
		}

		private void chkOutputText_Change(object sender, CheckBoxChangeEventArgs e) {
			try {
				chkOutputXml.Checked = !e.Checked;
				LogType = e.Checked ? LogTypeEnum.Text : LogTypeEnum.Xml;
			}
			catch (Exception ex) { Util.HandleException(ex); }
		}

		private void chkTimestamp_Change(object sender, CheckBoxChangeEventArgs e) {
			try {
				Timestamp = e.Checked;
			}
			catch (Exception ex) { Util.HandleException(ex); }
		}

		private void chkStealthMode_Change(object sender, CheckBoxChangeEventArgs e) {
			try {
				if (!Util.IsControlDown()) {
					if (!StealthMode) {
						Util.Warning("Warning: Stealth Mode will disable the " + Util.PluginName
							+ " window. Hold down the CTRL key while clicking to enable stealth mode.");
					}
					StealthMode = false;
					chkStealthMode.Checked = false;
				}
				else {
					if (e.Checked) {
						Util.Message("Enabling stealth mode... Type \"/logwiz stealth off\" to disable.");
					}
					StealthMode = e.Checked;
				}
			}
			catch (Exception ex) { Util.HandleException(ex); }
		}

		private void ShowStealthModeHelp() {
			Util.Message("Stealth mode disables the " + Util.PluginName
				+ " window and all messages from the plugin.  You can still interact with "
				+ "it through chat commands (/logwiz).  Type \"/logwiz stealth off\" to "
				+ "disable stealth mode.");
		}

		private void btnStealthModeHelp_Click(object sender, ControlEventArgs e) {
			try {
				ShowStealthModeHelp();
			}
			catch (Exception ex) { Util.HandleException(ex); }
		}

		private void chkShowStatus_Change(object sender, CheckBoxChangeEventArgs e) {
			try {
				Util.Message(GetStatus(false));
			}
			catch (Exception ex) { Util.HandleException(ex); }
		}

		private void btnShowStatus_Click(object sender, ControlEventArgs e) {
			try {
				Util.Message(GetStatus(false));
			}
			catch (Exception ex) { Util.HandleException(ex); }
		}

		private void lstMessageTypes_Selected(object sender, ListSelectEventArgs e) {
			try {
				int index = int.Parse((string)lstMessageTypes[e.Row][MessageList.Index][0]);
				if (index == LabelId) {
					lstMessageTypes[e.Row][MessageList.Enabled][0] = false;
				}
				else {
					if (e.Column != MessageList.Enabled) {
						lstMessageTypes[e.Row][MessageList.Enabled][0] =
							!((bool)lstMessageTypes[e.Row][MessageList.Enabled][0]);
					}
					if (index < 0) {
						mCustomHandlers[~index].Enabled = (bool)lstMessageTypes[e.Row][MessageList.Enabled][0];
					}
					else {
						mHandlers[index].Enabled = (bool)lstMessageTypes[e.Row][MessageList.Enabled][0];
					}
				}
			}
			catch (Exception ex) { Util.HandleException(ex); }
		}
	}
}