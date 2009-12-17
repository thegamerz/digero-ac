using System;
using System.Collections.Generic;
using System.Text;
using System.Drawing;

namespace LogWiz {
	static class Colors {
		public static Color ByType(int type) {
			if (type < 0 || type >= msColors.Length) {
				return msColors[msColors.Length - 1];
			}
			return msColors[type];
		}

		private static readonly Color[] msColors = {
			FromRgb(0x7FFF7E), // 0
			FromRgb(0x7FFF7E), // 1
			FromRgb(0xFFFFFF), // 2
			FromRgb(0xFFFF3E), // 3
			FromRgb(0xD2D263), // 4
			FromRgb(0xFF7EFF), // 5
			FromRgb(0xFF3E3E), // 6
			FromRgb(0x3EBEFF), // 7
			FromRgb(0xFF9595), // 8
			FromRgb(0xFF9595), // 9
			FromRgb(0xFFFF3E), // 10
			FromRgb(0xD2D263), // 11
			FromRgb(0xD2D2C7), // 12
			FromRgb(0x3EDCDC), // 13
			FromRgb(0xB4DCEF), // 14
			FromRgb(0xFF3E3E), // 15
			FromRgb(0x7FFF7E), // 16
			FromRgb(0x3EBEFF), // 17
			FromRgb(0xED921E), // 18
			FromRgb(0xFFFF3E), // 19
			FromRgb(0x7FFF7E), // 20
			FromRgb(0xFF3E3E), // 21
			FromRgb(0xF47571), // 22
			FromRgb(0x7FFF7E), // 23
			FromRgb(0x7FFF7E), // 24
			FromRgb(0x7FFF7E), // 25
			FromRgb(0xFF0000), // 26
			FromRgb(0xB4DCEF), // 27
			FromRgb(0xB4DCEF), // 28
			FromRgb(0xB4DCEF), // 29
			FromRgb(0xB4DCEF), // 30
			FromRgb(0xFFFF3E), // 31
			FromRgb(0xD2D2C7), // 32
		};

		private static Color FromRgb(uint rgb) {
			return Color.FromArgb(unchecked((int)(0xFF000000 | rgb)));
		}
	}
}
