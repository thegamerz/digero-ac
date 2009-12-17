using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.IO;

namespace DecalViewCodeGenerator {
	public partial class GeneratedCodeOutput : Form {
		private static GeneratedCodeOutput staticInstance = new GeneratedCodeOutput();

		public static void Show(IWin32Window owner, string codeText, bool isRichText, string message, int language) {
			Point location = staticInstance.Location;
			Rectangle bounds = staticInstance.Bounds;
			staticInstance.Dispose();
			staticInstance = new GeneratedCodeOutput();
			staticInstance.StartPosition = FormStartPosition.Manual;
			staticInstance.Location = location;
			staticInstance.Bounds = bounds;

			if (isRichText)
				staticInstance.richCode.Rtf = codeText;
			else
				staticInstance.richCode.Text = codeText;

			staticInstance.messageLabel.Text = message;
			staticInstance.saveFileDialog.FilterIndex = language + 1;
			staticInstance.Show(owner);
		}

		private GeneratedCodeOutput() {
			InitializeComponent();
		}

		private void saveButton_Click(object sender, EventArgs e) {
			if (saveFileDialog.ShowDialog(this) == DialogResult.OK) {
				StreamWriter writer = new StreamWriter(saveFileDialog.FileName);
				writer.Write(richCode.Text);
				writer.Close();
			}
		}

		private void closeButton_Click(object sender, EventArgs e) {
			Dispose();
		}

		private void contextMenu_Opening(object sender, CancelEventArgs e) {
			copyToolStripMenuItem.Enabled = (richCode.SelectedText.Length > 0);
		}

		private void copyToolStripMenuItem_Click(object sender, EventArgs e) {
			Clipboard.SetText(richCode.SelectedText);
			Clipboard.SetData(DataFormats.Rtf, richCode.SelectedRtf);
		}

		private void selectAllToolStripMenuItem_Click(object sender, EventArgs e) {
			richCode.Focus();
			richCode.SelectAll();
		}
	}
}