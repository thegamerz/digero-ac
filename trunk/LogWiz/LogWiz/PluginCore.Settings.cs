using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Xml;
using System.Drawing;

using Decal.Adapter;
using Decal.Adapter.Wrappers;

namespace LogWiz {
	public partial class PluginCore {
		private const int SettingsVersion = 1;

#pragma warning disable 414 // Variable's value not used
		private bool mGeneralSettingsLoaded = false;
		private bool mCharacterSettingsLoaded = false;
#pragma warning restore 414

		private void LoadGeneralSettings() {
			string settingsPath = Util.FullPath("settings.xml");
			try {
				if (!File.Exists(settingsPath)) {
					return;
				}

				int fileVer = 0;

				XmlDocument doc = new XmlDocument();
				doc.Load(settingsPath);

				if (doc.DocumentElement.HasAttribute("version")) {
					int.TryParse(doc.DocumentElement.GetAttribute("version"), out fileVer);
				}

				string val;
				bool boolVal;
				Point ptVal;

				foreach (XmlElement ele in doc.DocumentElement.SelectNodes("setting")) {
					val = ele.GetAttribute("value");

					switch (ele.GetAttribute("name")) {
						case "ViewPosition":
							if (TryParsePoint(val, out ptVal)) { ViewPosition = ptVal; }
							break;

						case "LogByDefault":
							if (bool.TryParse(val, out boolVal)) { LogByDefault = boolVal; }
							break;

						case "LogType": {
								LogTypeEnum e;
								if (TryParseEnum<LogTypeEnum>(val, true, out e)) {
									LogType = e;
								}
							}
							break;

						case "LogPerCharacter":
							if (bool.TryParse(val, out boolVal)) { LogPerCharacter = boolVal; }
							break;

						case "Timestamp":
							if (bool.TryParse(val, out boolVal)) { Timestamp = boolVal; }
							break;

						case "StealthMode":
							if (bool.TryParse(val, out boolVal)) { StealthMode = boolVal; }
							break;
					}
				}

				foreach (XmlElement type in doc.DocumentElement.SelectNodes("messageTypes/type")) {
					int index;
					bool enabled;
					if (int.TryParse(type.GetAttribute("color"), out index)
							&& bool.TryParse(type.GetAttribute("enabled"), out enabled)) {
						if (index < 0) {
							index = ~index;
							if (index <= mCustomHandlers.Length) {
								mCustomHandlers[index].Enabled = enabled;
							}
						}
						else {
							if (index <= mHandlers.Length) {
								mHandlers[index].Enabled = enabled;
							}
						}
					}
				}
			}
			catch (Exception ex) {
				Util.HandleException(ex, "Error encountered while loading settings.xml file", true);
				string errorPath = Util.FullPath("settings_error.xml");

				if (File.Exists(settingsPath)) {
					if (File.Exists(errorPath)) {
						File.Delete(errorPath);
					}
					File.Move(settingsPath, errorPath);
					Util.SevereError("The old settings.xml file has been renamed to settings_error.xml "
						+ "and a new settings.xml will be created with the defaults");
				}
			}
			finally {
				mGeneralSettingsLoaded = true;
			}
		}

		private void LoadCharacterSettings() {
			string settingsPath = Util.FullPath("settings.xml");
			try {
				if (!File.Exists(settingsPath)) {
					return;
				}

				int fileVer = 0;

				XmlDocument doc = new XmlDocument();
				doc.Load(settingsPath);

				if (doc.DocumentElement.HasAttribute("version")) {
					int.TryParse(doc.DocumentElement.GetAttribute("version"), out fileVer);
				}

				string val;

				string xpath = "character[@name=\"" + mCharName + "\" and @server=\"" + mServer + "\"]/setting";

				foreach (XmlElement ele in doc.DocumentElement.SelectNodes(xpath)) {
					val = ele.GetAttribute("value");

					switch (ele.GetAttribute("name")) {
						case "LogForThisCharacter": {
								LogThisCharEnum e;
								if (TryParseEnum<LogThisCharEnum>(val, true, out e)) {
									LogForThisCharacter = e;
								}
							}
							break;
					}
				}
			}
			catch (Exception ex) {
				Util.HandleException(ex, "Error encountered while loading settings.xml file", true);
				string errorPath = Util.FullPath("settings_error.xml");

				if (File.Exists(settingsPath)) {
					if (File.Exists(errorPath)) {
						File.Delete(errorPath);
					}
					File.Move(settingsPath, errorPath);
					Util.SevereError("The old settings.xml file has been renamed to settings_error.xml "
						+ "and a new settings.xml will be created with the defaults");
				}
			}
			finally {
				mCharacterSettingsLoaded = true;
			}
		}

		private void SaveSettings() {
			string settingsPath = Util.FullPath("settings.xml");
			try {
				XmlDocument doc = new XmlDocument();
				doc.AppendChild(doc.CreateElement("settings"));
				doc.DocumentElement.SetAttribute("version", SettingsVersion.ToString());
				XmlNode docEle = doc.DocumentElement;

				AddSetting(doc, docEle, "ViewPosition", ViewPosition);
				AddSetting(doc, docEle, "LogByDefault", LogByDefault);
				AddSetting(doc, docEle, "LogType", LogType.ToString());
				AddSetting(doc, docEle, "LogPerCharacter", LogPerCharacter);
				AddSetting(doc, docEle, "Timestamp", Timestamp);
				AddSetting(doc, docEle, "StealthMode", StealthMode);

				XmlElement charEle = (XmlElement)docEle.AppendChild(doc.CreateElement("character"));
				charEle.SetAttribute("name", mCharName);
				charEle.SetAttribute("server", mServer);

				AddSetting(doc, charEle, "LogForThisCharacter", LogForThisCharacter.ToString());

				// Retain all of the settings from the other characters
				if (File.Exists(settingsPath)) {
					try {
						XmlDocument oldSettings = new XmlDocument();
						oldSettings.Load(settingsPath);

						string xpath = "character[not(@name=\"" + mCharName + "\" and @server=\"" + mServer + "\")]";
						foreach (XmlNode n in oldSettings.DocumentElement.SelectNodes(xpath)) {
							XmlNode node = doc.ImportNode(n, true);
							doc.DocumentElement.AppendChild(node);
						}
					}
					catch (Exception ex) { Util.HandleException(ex); }
				}

				XmlElement messageTypes = (XmlElement)docEle.AppendChild(doc.CreateElement("messageTypes"));
				for (int i = 0; i < mCustomHandlers.Length; i++) {
					AddHandlerSetting(doc, messageTypes, ~i, mCustomHandlers[i]);
				}
				for (int i = 0; i < mHandlers.Length; i++) {
					AddHandlerSetting(doc, messageTypes, i, mHandlers[i]);
				}

				Util.SaveXml(doc, settingsPath);
			}
			catch (Exception ex) { Util.HandleException(ex); }
		}

		private void AddSetting(XmlDocument doc, XmlNode addUnder, string name, string value) {
			XmlElement ele = (XmlElement)addUnder.AppendChild(doc.CreateElement("setting"));
			ele.SetAttribute("name", name);
			ele.SetAttribute("value", value);
		}
		private void AddSetting(XmlDocument doc, XmlNode addUnder, string name, bool value) { AddSetting(doc, addUnder, name, value.ToString()); }
		private void AddSetting(XmlDocument doc, XmlNode addUnder, string name, int value) { AddSetting(doc, addUnder, name, value.ToString()); }
		private void AddSetting(XmlDocument doc, XmlNode addUnder, string name, double value) { AddSetting(doc, addUnder, name, value.ToString()); }
		private void AddSetting(XmlDocument doc, XmlNode addUnder, string name, Point value) { AddSetting(doc, addUnder, name, PointToString(value)); }
		private void AddSetting(XmlDocument doc, XmlNode addUnder, string name, Rectangle value) { AddSetting(doc, addUnder, name, RectangleToString(value)); }

		private void AddHandlerSetting(XmlDocument doc, XmlNode addUnder, int color, MessageHandler mh) {
			XmlElement ele = (XmlElement)addUnder.AppendChild(doc.CreateElement("type"));
			ele.SetAttribute("color", color.ToString());
			ele.SetAttribute("enabled", mh.Enabled.ToString());
			ele.SetAttribute("description", mh.Description);
		}

		private bool TryParseEnum<T>(string s, out T result) {
			return TryParseEnum<T>(s, false, out result);
		}

		private bool TryParseEnum<T>(string s, bool ignoreCase, out T result) {
			try {
				result = (T)Enum.Parse(typeof(T), s, true);
				return true;
			}
			catch {
				result = default(T);
				return false;
			}
		}

		private string PointToString(Point pt) {
			return pt.X + "," + pt.Y;
		}

		private bool TryParsePoint(string val, out Point pt) {
			string[] xy = val.Split(',');
			int x, y;
			if (xy.Length == 2
					&& int.TryParse(xy[0], out x) && x >= 0
					&& int.TryParse(xy[1], out y) && y >= 0) {
				pt = new Point(x, y);
				return true;
			}
			pt = new Point();
			return false;
		}

		private string RectangleToString(Rectangle r) {
			return r.X + "," + r.Y + ";" + r.Width + "," + r.Height;
		}

		private bool TryParseRectangle(string val, out Rectangle r) {
			string[] pt_sz = val.Split(';');
			Point pt, sz;
			if (pt_sz.Length == 2 && TryParsePoint(pt_sz[0], out pt) && TryParsePoint(pt_sz[1], out sz)) {
				r = new Rectangle(pt, (Size)sz);
				return true;
			}
			r = new Rectangle();
			return false;
		}
	}
}
