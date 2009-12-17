using System;
using System.Collections.Generic;
using System.Text;

namespace LogWiz {
	public enum LogTypeEnum { Xml, Text }

	interface Logger : IDisposable {
		bool LogPerCharacter { get; set; }
		bool Timestamp { get; set; }
		string LogPath { get; }
		LogTypeEnum LogType { get; }

		void LogMessage(string message, int color);
	}
}
