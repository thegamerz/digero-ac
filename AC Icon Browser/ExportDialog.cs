using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Drawing.Imaging;

namespace ACIconBrowser {
	public partial class ExportDialog : Form {

		private string nameFormatOrigText;
		private bool ignoreNameFormatEnter = false;

		public ExportDialog() {
			InitializeComponent();

			if (Settings.Default.exportFolder == "") {
				String appPath = System.Reflection.Assembly.GetExecutingAssembly().Location.ToString();
				int slash = appPath.LastIndexOf('\\');
				if (slash > 0)
					appPath = appPath.Substring(0, slash + 1);
				exportFolderTextbox.Text = appPath;
			}
			else
				exportFolderTextbox.Text = Settings.Default.exportFolder;

			folderBrowserDialog.SelectedPath = exportFolderTextbox.Text;

			nameFormatTextbox.Text = Settings.Default.exportNameFormat;
			nameFormatOrigText = nameFormatTextbox.Text;

			if (fileFormatCombo.Items.Contains(Settings.Default.exportFormat))
				fileFormatCombo.SelectedItem = Settings.Default.exportFormat;
		}

		public void saveSettings() {
			Settings.Default.exportFolder = exportFolderTextbox.Text;
			Settings.Default.exportNameFormat = nameFormatTextbox.Text;
			Settings.Default.exportFormat = (string)fileFormatCombo.SelectedItem;
			Settings.Default.Save();
		}

		public bool exportSelectedEnabled {
			get {
				return exportSelected.Enabled;
			}
			set {
				exportSelected.Enabled = value;
				if (value == false) {
					exportSelected.Checked = false;
					exportAll.Checked = true;
				}
			}
		}

		public bool exportSelectedOnly {
			get {
				return exportSelected.Checked;
			}
			set {
				if (exportSelected.Enabled)
					exportSelected.Checked = value;
			}
		}

		public ImageFormat imageFormat {
			get {
				switch (imageFormatExtension) {
					case "gif":
						return ImageFormat.Gif;
					case "jpg":
						return ImageFormat.Jpeg;
					case "png":
						return ImageFormat.Png;
					case "tiff":
						return ImageFormat.Tiff;
					default:
						return ImageFormat.Bmp;
				}
			}
		}

		public string imageFormatExtension {
			get {
				string t = fileFormatCombo.Text.ToLower();
				if (t.Contains("gif"))
					return "gif";
				if (t.Contains("jpg"))
					return "jpg";
				if (t.Contains("png"))
					return "png";
				if (t.Contains("tiff"))
					return "tiff";
				return "bmp";
			}
		}


		public string nameFormat {
			get {
				return nameFormatTextbox.Text;
			}
			set {
				string t = value.ToUpper();
				if (!t.Contains("$H") && !t.Contains("$L") && !t.Contains("$D") && !t.Contains("$E")
						|| value.IndexOfAny(new char[] { '\\', '/', ':', '*', '?', '"', '<', '>', '|' }) >= 0)
					throw new ArgumentException();

				nameFormatTextbox.Text = value;
			}
		}

		public string exportFolder {
			get {
				return exportFolderTextbox.Text;
			}
			set {
				exportFolderTextbox.Text = value;
				folderBrowserDialog.SelectedPath = value;
			}
		}

		private void nameFormatTextbox_Enter(object sender, EventArgs e) {
			if (!ignoreNameFormatEnter)
				nameFormatOrigText = nameFormatTextbox.Text;
		}

		private void nameFormatTextbox_Leave(object sender, EventArgs e) {
			ignoreNameFormatEnter = false;
		}

		private void nameFormatTextbox_Validating(object sender, CancelEventArgs e) {
			string invalidMessage = null;
			string t = nameFormatTextbox.Text.ToUpper();
			if (!t.Contains("$H") && !t.Contains("$L") && !t.Contains("$D") && !t.Contains("$E")) {
				invalidMessage = "Name format must contain at least one wildcard";
			}
			else if (t.IndexOfAny(new char[] { '\\', '/', ':', '*', '?', '"', '<', '>', '|' }) >= 0) {
				invalidMessage = "Name cannot contain any of the following characters: \r\n" +
					"\\ / : * ? \" < > |";
			}

			if (invalidMessage != null) {
				if (MessageBox.Show(invalidMessage, "Invalid name", MessageBoxButtons.OKCancel, MessageBoxIcon.Warning) == DialogResult.OK) {
					e.Cancel = true;
					ignoreNameFormatEnter = true;
					nameFormatTextbox.SelectAll();
				}
				else {
					ignoreNameFormatEnter = false;
					nameFormatTextbox.Text = nameFormatOrigText;
				}
			}
		}

		private void browseButton_Click(object sender, EventArgs e) {
			folderBrowserDialog.ShowDialog();
			exportFolderTextbox.Text = folderBrowserDialog.SelectedPath;
		}
	}
}