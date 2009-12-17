using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace ACIconBrowser {
	public partial class PortalDatPathDialog : Form {

		public PortalDatPathDialog() {
			InitializeComponent();

			if (Settings.Default.datPath == "")
				defaultButton_Click(null, null);
			else
				portalDatPath = Settings.Default.datPath;
		}

		public string portalDatPath {
			get {
				return portalDatPathTextbox.Text;
			}
			set {
				openFileDialog.FileName = value;
				portalDatPathTextbox.Text = value;
			}
		}

		private void browseButton_Click(object sender, EventArgs e) {
			if (openFileDialog.ShowDialog() == DialogResult.OK) {
				portalDatPathTextbox.Text = openFileDialog.FileName;
			}
		}

		private void defaultButton_Click(object sender, EventArgs e) {
			try {
				portalDatPath = (string)
					Microsoft.Win32.Registry.LocalMachine
						.OpenSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\" +
									@"S-1-5-21-2052111302-823518204-725345543-1003\Products\" +
									@"ABE1051053CEF9F48898B33E645EAD31\InstallProperties", false)
						.GetValue("InstallSource") + @"client_portal.dat";
			}
			catch {
				portalDatPath = @"C:\Program Files\Turbine\Asheron's Call - Throne of Destiny\client_portal.dat";
			}
		}
	}
}