using System;
using System.Collections.Generic;
using System.Text;
using System.Drawing;

namespace LogWiz {
	delegate bool CheckMessageDelegate(string message, int color);

	class MessageHandler {
		private bool mEnabled;
		private string mDescription;
		private Color mDisplayColor;
		private CheckMessageDelegate mCheckDelegate;
		private int mColorId = -1;
		private bool mIsCustom = true;

		public MessageHandler(string description, Color displayColor, bool enabled, CheckMessageDelegate checkDelegate) {
			mDescription = description;
			mDisplayColor = displayColor;
			mEnabled = enabled;
			mCheckDelegate = checkDelegate;
		}

		public MessageHandler(string description, Color displayColor, bool enabled, int colorId) {
			mDescription = description;
			mDisplayColor = displayColor;
			mEnabled = enabled;
			mCheckDelegate = delegate(string message, int color) { return color == colorId; };
			mColorId = colorId;
			mIsCustom = false;
		}

		public bool Enabled {
			get { return mEnabled; }
			set { mEnabled = value; }
		}

		public bool IsCustom {
			get { return mIsCustom; }
		}

		public Color DisplayColor {
			get { return mDisplayColor; }
		}

		public int ColorId {
			get { return mColorId; }
		}

		public string Description {
			get { return mDescription; }
		}

		public bool CheckMessage(string message, int color) {
			return mCheckDelegate(message, color);
		}
	}
}
