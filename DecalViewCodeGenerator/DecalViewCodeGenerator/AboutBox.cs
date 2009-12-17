using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace DecalViewCodeGenerator {
	public partial class AboutBox : Form {
		public AboutBox() {
			InitializeComponent();
			iconBox.Image = Properties.Resources.app.ToBitmap();
			label1.Text = "Decal View Code Generator v" + System.Reflection.Assembly.GetExecutingAssembly().GetName().Version.ToString(2);
		}

		private void AboutBox_Load(object sender, EventArgs e) {
			exitButton.Focus();
		}

		private void linkLabel1_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e) {
			System.Diagnostics.Process.Start(linkLabel1.Text);
		}
	}
}