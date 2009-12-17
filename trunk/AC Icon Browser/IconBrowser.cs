using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using Ciper.AC;
using System.Threading;
using System.Drawing.Imaging;
using System.IO;

namespace ACIconBrowser {
	public partial class IconBrowser : Form {

		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main() {
			System.Windows.Forms.Control.CheckForIllegalCrossThreadCalls = false;
			Application.EnableVisualStyles();
			Application.SetCompatibleTextRenderingDefault(false);
			Application.Run(new IconBrowser());
		}

		private DataLibrary library;
		private DataLibrary.FileEntry[] files;
		private string[] names;
		private Image[] images;
		private ListViewItem[] cachedListViewItems;

		private Thread preloadThread;

		private bool preloadingIcons = false;

		// Used to ensure that only one thread loads an image at a time
		private Semaphore loadSemaphore;

		public IconBrowser() {
			InitializeComponent();

			if (Settings.Default.datPath == "") {
				try {
					Settings.Default.datPath = (string)
						Microsoft.Win32.Registry.LocalMachine
						.OpenSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\" +
									@"S-1-5-21-2052111302-823518204-725345543-1003\Products\" +
									@"ABE1051053CEF9F48898B33E645EAD31\InstallProperties", false)
						.GetValue("InstallSource") + @"client_portal.dat";
				}
				catch {
					Settings.Default.datPath = @"C:\Program Files\Turbine\Asheron's Call - Throne of Destiny\client_portal.dat";
				}
			}

			prefetchIconsCheckbox.Checked = Settings.Default.prefetchIcons;

			largeIconsToolStripMenuItem.Checked = Settings.Default.viewLargeIcons;
			listToolStripMenuItem.Checked = !Settings.Default.viewLargeIcons;

			iconView.RetrieveVirtualItem += new RetrieveVirtualItemEventHandler(iconView_RetrieveVirtualItem);
			iconView.SearchForVirtualItem += new SearchForVirtualItemEventHandler(iconView_SearchForVirtualItem);
			loadSemaphore = new Semaphore(1, 1);

			if (load(false) && Settings.Default.prefetchIcons)
				preloadAllAsynch();
		}

		void iconView_RetrieveVirtualItem(object sender, RetrieveVirtualItemEventArgs e) {
			loadImage(e.ItemIndex);
			e.Item = cachedListViewItems[e.ItemIndex];
		}

		void iconView_SearchForVirtualItem(object sender, SearchForVirtualItemEventArgs e) {
			int i = 0;
			string text = e.Text.ToUpper();
			foreach (string s in names) {
				if (s.StartsWith(text)) {
					e.Index = i;
					return;
				}
				i++;
			}
		}

		// returns true on success
		private bool load(bool showMessageOnFail) {
			try {
				library = new DataLibrary(Settings.Default.datPath, true);

				iconView.Items.Clear();
				iconList.Images.Clear();

				List<DataLibrary.FileEntry> shownFilesList = new List<DataLibrary.FileEntry>();
				List<string> shownFileNamesList = new List<string>();

				System.Collections.ICollection entries = library.FileEntries;

				foreach (DataLibrary.FileEntry file in entries) {
					if ((file.Index & 0x7F000000) == 0x6000000 && file.Length == 4120) {
						shownFilesList.Add(file);
						shownFileNamesList.Add(string.Format("{0:X4}", file.Index & 0xFFFF));
					}
				}

				this.files = shownFilesList.ToArray();
				this.names = shownFileNamesList.ToArray();

				cachedListViewItems = new ListViewItem[files.Length];
				images = new Image[files.Length];
				iconView.VirtualListSize = files.Length;

				if (Settings.Default.viewLargeIcons)
					iconView.View = View.LargeIcon;
				else
					iconView.View = View.List;

				return true;
			}
			catch (IOException ex) {
				if (showMessageOnFail)
					MessageBox.Show(ex.Message, "Failed to open datafile", MessageBoxButtons.OK, MessageBoxIcon.Warning);
				return false;
			}
		}

		private void preloadAllAsynch() {
			if (preloadThread != null && preloadThread.IsAlive) {
				preloadThread.Abort();
			}

			preloadThread = new Thread(new ThreadStart(delegate {
				try {
					preloadingIcons = true;
					abortButton.Enabled = true;
					preloadProgress.Maximum = files.Length;
					preloadProgress.Value = 0;

					for (int i = 0; i < files.Length; i++) {
						loadImage(i);
						if ((i % 10) == 0) {
							preloadingIcons = true;
							preloadProgress.Value = i;
							preloadStatus.Text = "Prefetching icons (" + i + "/" + files.Length + ") ...";
						}
					}
					preloadStatus.Text = "Finished";
					preloadProgress.Value = 0;
					abortButton.Enabled = false;
				}
				catch {
					throw;
				}
				finally {
					preloadingIcons = false;
				}
			}));

			preloadThread.Priority = ThreadPriority.BelowNormal;
			preloadThread.Start();
		}

		private void exportAllAsynch() {
			ExportDialog exportDialog = new ExportDialog();
			exportDialog.exportSelectedEnabled = iconView.SelectedIndices.Count > 0;
			if (exportDialog.ShowDialog() != DialogResult.OK)
				return;
			exportDialog.saveSettings();

			try {
				DirectoryInfo folderInfo = new DirectoryInfo(exportDialog.exportFolder);
				if (!folderInfo.Exists)
					folderInfo.Create();
			}
			catch (IOException ex) {
				MessageBox.Show(ex.Message, "Failed to create directory", MessageBoxButtons.OK, MessageBoxIcon.Warning);
				return;
			}

			if (preloadThread != null && preloadThread.IsAlive) {
				preloadThread.Abort();
			}

			if (library == null && !load(true))
				return;

			preloadThread = new Thread(new ThreadStart(delegate {
				abortButton.Enabled = true;
				if (exportDialog.exportSelectedOnly) {
					preloadProgress.Maximum = iconView.SelectedIndices.Count;
				}
				else {
					preloadProgress.Maximum = files.Length;
				}
				preloadProgress.Value = 0;

				string nameFormat = exportDialog.nameFormat;
				ImageFormat imageFormat = exportDialog.imageFormat;
				string imageFormatExtension = exportDialog.imageFormatExtension;
				string exportFolder = exportDialog.exportFolder;
				if (exportFolder[exportFolder.Length - 1] != '\\')
					exportFolder += '\\';

				bool formatHexWordUC = nameFormat.Contains("$H");
				bool formatHexWordLC = nameFormat.Contains("$h");
				bool formatHexDwordUC = nameFormat.Contains("$L");
				bool formatHexDwordLC = nameFormat.Contains("$l");
				nameFormat = nameFormat.Replace("$d", "$D");
				nameFormat = nameFormat.Replace("$e", "$E");
				bool formatDecWord = nameFormat.Contains("$D");
				bool formatDecDword = nameFormat.Contains("$E");

				bool[] exportIndex = new bool[files.Length];
				if (exportDialog.exportSelectedOnly) {
					foreach (int i in iconView.SelectedIndices) {
						exportIndex[i] = true;
					}
				}
				else {
					for (int i = 0; i < exportIndex.Length; i++)
						exportIndex[i] = true;
				}

				int ct = 0;

				for (int i = 0; i < files.Length; i++) {
					if (exportIndex[i]) {
						loadImage(i);

						if (images[i] != null) {
							string fileName = nameFormat;

							if (formatHexWordUC)
								fileName = fileName.Replace("$H", string.Format("{0:X4}", files[i].Index & 0xFFFF));
							if (formatHexWordLC)
								fileName = fileName.Replace("$h", string.Format("{0:x4}", files[i].Index & 0xFFFF));
							if (formatHexDwordUC)
								fileName = fileName.Replace("$L", string.Format("{0:X8}", files[i].Index));
							if (formatHexDwordLC)
								fileName = fileName.Replace("$l", string.Format("{0:x8}", files[i].Index));
							if (formatDecWord)
								fileName = fileName.Replace("$D", ((int)(files[i].Index & 0xFFFF)).ToString("D"));
							if (formatDecDword)
								fileName = fileName.Replace("$E", files[i].Index.ToString("D"));

							fileName = exportFolder + fileName + "." + imageFormatExtension;

							try {
								images[i].Save(fileName, imageFormat);
							}
							catch (IOException ex) {
								MessageBox.Show(ex.Message, "Failed to save image", MessageBoxButtons.OK, MessageBoxIcon.Warning);
								break;
							}
						}
						if (exportDialog.exportSelectedOnly) {
							preloadProgress.Value = ct;
							preloadStatus.Text = "Exporting icons (" + ct + "/" + preloadProgress.Maximum + ") ...";
						}
						else if ((i % 10) == 0) {
							preloadProgress.Value = i;
							preloadStatus.Text = "Exporting icons (" + i + "/" + preloadProgress.Maximum + ") ...";
						}
						ct++;
					}
				}

				preloadStatus.Text = "Finished";
				preloadProgress.Value = 0;
				abortButton.Enabled = false;
			}));

			preloadThread.Start();
		}

		// Synchronized with a semaphore for multithreading
		private void loadImage(int i) {
			loadSemaphore.WaitOne();

			try {
				if (cachedListViewItems[i] == null) {
					string name = names[i];
					DataLibrary.FileEntry file = files[i];
					int imgIndex = -1;
					if (images[i] != null) {
						imgIndex = iconList.Images.Count;
						iconList.Images.Add(images[i]);
					}
					else {
						ByteCursor csr = library.LoadFile(file);
						int nForm = csr.GetDWORD(true);
						if (nForm == 10 || nForm == 6) {
							images[i] = (nForm == 10) ? csr.GetRGBImage(true) : csr.Get24BitImage(true);
							imgIndex = iconList.Images.Count;
							iconList.Images.Add(images[i]);
						}
					}
					cachedListViewItems[i] = new ListViewItem(name, imgIndex);
					cachedListViewItems[i].ToolTipText = "Hex: 0x" + string.Format("{0:X4}", file.Index & 0xFFFF) +
						"\r\nDecimal: " + ((int)file.Index & 0xFFFF).ToString();
				}
			}
			catch (ThreadAbortException) {
				throw;
			}
			finally {
				loadSemaphore.Release();
			}
		}

		private void largeIconsToolStripMenuItem_Click(object sender, EventArgs e) {
			largeIconsToolStripMenuItem.Checked = Settings.Default.viewLargeIcons = true;
			listToolStripMenuItem.Checked = false;
			Settings.Default.Save();

			iconView.View = View.LargeIcon;
		}

		private void listToolStripMenuItem_Click(object sender, EventArgs e) {
			largeIconsToolStripMenuItem.Checked = Settings.Default.viewLargeIcons = false;
			listToolStripMenuItem.Checked = true;
			Settings.Default.Save();

			iconView.View = View.List;
		}

		private void exitToolStripMenuItem_Click(object sender, EventArgs e) {
			Application.Exit();
		}

		private void choosePortaldatPathToolStripMenuItem_Click(object sender, EventArgs e) {
			PortalDatPathDialog pdpd = new PortalDatPathDialog();
			if (pdpd.ShowDialog() == DialogResult.OK) {
				Settings.Default.datPath = pdpd.portalDatPath;
				Settings.Default.Save();
				if (load(true) && Settings.Default.prefetchIcons)
					preloadAllAsynch();
			}
		}

		private void exportIconsMenuItem_Click(object sender, EventArgs e) {
			exportAllAsynch();
		}

		private void prefetchIconsCheckbox_Click(object sender, EventArgs e) {
			Settings.Default.prefetchIcons = prefetchIconsCheckbox.Checked;
			Settings.Default.Save();

			if (prefetchIconsCheckbox.Checked) {
				if (preloadThread == null || !preloadThread.IsAlive)
					preloadAllAsynch();
			}
			else if (preloadingIcons) {
				abortButton.PerformButtonClick();
				preloadStatus.Text = "Idle";
			}
		}

		private void abortButton_ButtonClick(object sender, EventArgs e) {
			if (preloadThread != null) {
				preloadThread.Abort();
				preloadThread.Join();
			}
			abortButton.Enabled = false;
			preloadProgress.Value = 0;
			preloadStatus.Text = "Aborted";
		}

		private void aboutToolStripMenuItem_Click(object sender, EventArgs e) {
			AboutBox ab = new AboutBox();
			ab.ShowDialog();
		}

		private void iconView_ItemMouseHover(object sender, ListViewItemMouseHoverEventArgs e) {
		}

		private void itemContextMenuItem_Click(object sender, EventArgs e) {
			Clipboard.SetText((string)((ToolStripMenuItem)sender).Tag);
		}

		private void itemContextMenu_Opening(object sender, CancelEventArgs e) {
			if (iconView.SelectedIndices.Count > 0) {
				DataLibrary.FileEntry file = files[iconView.SelectedIndices[0]];

				copyHexDWordToolStripMenuItem.Tag = string.Format("{0:X8}", file.Index);
				copyHexDWordToolStripMenuItem.Text = "Copy Hex \"" + copyHexDWordToolStripMenuItem.Tag + "\"";

				copyHexWordToolStripMenuItem.Tag = string.Format("{0:X4}", file.Index & 0xFFFF);
				copyHexWordToolStripMenuItem.Text = "Copy Hex \"" + copyHexWordToolStripMenuItem.Tag + "\"";

				copyDecimalDWordToolStripMenuItem.Tag = file.Index.ToString("D");
				copyDecimalDWordToolStripMenuItem.Text = "Copy Decimal \"" + copyDecimalDWordToolStripMenuItem.Tag + "\"";

				copyDecimalWordToolStripMenuItem.Tag = ((int)(file.Index & 0xFFFF)).ToString("D");
				copyDecimalWordToolStripMenuItem.Text = "Copy Decimal \"" + copyDecimalWordToolStripMenuItem.Tag + "\"";
			}
			else
				e.Cancel = true;
		}
	}
}