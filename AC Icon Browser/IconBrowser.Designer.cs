namespace ACIconBrowser {
	partial class IconBrowser {
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
		protected override void Dispose(bool disposing) {
			if (disposing && (preloadThread != null)) {
				preloadThread.Abort();
			}
			if (disposing && (components != null)) {
				components.Dispose();
			}
			base.Dispose(disposing);
		}

		#region Windows Form Designer generated code

		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent() {
			this.components = new System.ComponentModel.Container();
			System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(IconBrowser));
			this.iconList = new System.Windows.Forms.ImageList(this.components);
			this.iconView = new System.Windows.Forms.ListView();
			this.statusStrip1 = new System.Windows.Forms.StatusStrip();
			this.preloadProgress = new System.Windows.Forms.ToolStripProgressBar();
			this.preloadStatus = new System.Windows.Forms.ToolStripStatusLabel();
			this.toolStripStatusLabel1 = new System.Windows.Forms.ToolStripStatusLabel();
			this.abortButton = new System.Windows.Forms.ToolStripSplitButton();
			this.menuStrip1 = new System.Windows.Forms.MenuStrip();
			this.fileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
			this.choosePortaldatPathToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
			this.exportIconsMenuItem = new System.Windows.Forms.ToolStripMenuItem();
			this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
			this.exitToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
			this.viewToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
			this.prefetchIconsCheckbox = new System.Windows.Forms.ToolStripMenuItem();
			this.toolStripSeparator2 = new System.Windows.Forms.ToolStripSeparator();
			this.largeIconsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
			this.listToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
			this.helpToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
			this.aboutToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
			this.itemContextMenu = new System.Windows.Forms.ContextMenuStrip(this.components);
			this.copyHexDWordToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
			this.copyHexWordToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
			this.copyDecimalDWordToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
			this.copyDecimalWordToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
			this.toolStripSeparator3 = new System.Windows.Forms.ToolStripSeparator();
			this.statusStrip1.SuspendLayout();
			this.menuStrip1.SuspendLayout();
			this.itemContextMenu.SuspendLayout();
			this.SuspendLayout();
			// 
			// iconList
			// 
			this.iconList.ColorDepth = System.Windows.Forms.ColorDepth.Depth24Bit;
			this.iconList.ImageSize = new System.Drawing.Size(32, 32);
			this.iconList.TransparentColor = System.Drawing.Color.Transparent;
			// 
			// iconView
			// 
			this.iconView.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
						| System.Windows.Forms.AnchorStyles.Left)
						| System.Windows.Forms.AnchorStyles.Right)));
			this.iconView.LargeImageList = this.iconList;
			this.iconView.Location = new System.Drawing.Point(0, 24);
			this.iconView.Margin = new System.Windows.Forms.Padding(3, 0, 3, 3);
			this.iconView.Name = "iconView";
			this.iconView.ShowItemToolTips = true;
			this.iconView.Size = new System.Drawing.Size(552, 384);
			this.iconView.SmallImageList = this.iconList;
			this.iconView.TabIndex = 0;
			this.iconView.UseCompatibleStateImageBehavior = false;
			this.iconView.VirtualMode = true;
			this.iconView.ItemMouseHover += new System.Windows.Forms.ListViewItemMouseHoverEventHandler(this.iconView_ItemMouseHover);
			// 
			// statusStrip1
			// 
			this.statusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.preloadProgress,
            this.preloadStatus,
            this.toolStripStatusLabel1,
            this.abortButton});
			this.statusStrip1.Location = new System.Drawing.Point(0, 408);
			this.statusStrip1.Name = "statusStrip1";
			this.statusStrip1.Size = new System.Drawing.Size(552, 22);
			this.statusStrip1.TabIndex = 6;
			this.statusStrip1.Text = "statusStrip1";
			// 
			// preloadProgress
			// 
			this.preloadProgress.Name = "preloadProgress";
			this.preloadProgress.Size = new System.Drawing.Size(150, 16);
			// 
			// preloadStatus
			// 
			this.preloadStatus.Name = "preloadStatus";
			this.preloadStatus.Size = new System.Drawing.Size(25, 17);
			this.preloadStatus.Text = "Idle";
			// 
			// toolStripStatusLabel1
			// 
			this.toolStripStatusLabel1.Name = "toolStripStatusLabel1";
			this.toolStripStatusLabel1.Size = new System.Drawing.Size(310, 17);
			this.toolStripStatusLabel1.Spring = true;
			// 
			// abortButton
			// 
			this.abortButton.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Text;
			this.abortButton.Image = ((System.Drawing.Image)(resources.GetObject("abortButton.Image")));
			this.abortButton.ImageTransparentColor = System.Drawing.Color.Magenta;
			this.abortButton.Name = "abortButton";
			this.abortButton.Size = new System.Drawing.Size(50, 20);
			this.abortButton.Text = "Abort";
			this.abortButton.ToolTipText = "Abort Loading";
			this.abortButton.ButtonClick += new System.EventHandler(this.abortButton_ButtonClick);
			// 
			// menuStrip1
			// 
			this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileToolStripMenuItem,
            this.viewToolStripMenuItem,
            this.helpToolStripMenuItem});
			this.menuStrip1.Location = new System.Drawing.Point(0, 0);
			this.menuStrip1.Name = "menuStrip1";
			this.menuStrip1.Size = new System.Drawing.Size(552, 24);
			this.menuStrip1.TabIndex = 7;
			this.menuStrip1.Text = "menuStrip1";
			// 
			// fileToolStripMenuItem
			// 
			this.fileToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.choosePortaldatPathToolStripMenuItem,
            this.exportIconsMenuItem,
            this.toolStripSeparator1,
            this.exitToolStripMenuItem});
			this.fileToolStripMenuItem.Name = "fileToolStripMenuItem";
			this.fileToolStripMenuItem.Size = new System.Drawing.Size(35, 20);
			this.fileToolStripMenuItem.Text = "&File";
			// 
			// choosePortaldatPathToolStripMenuItem
			// 
			this.choosePortaldatPathToolStripMenuItem.Name = "choosePortaldatPathToolStripMenuItem";
			this.choosePortaldatPathToolStripMenuItem.Size = new System.Drawing.Size(202, 22);
			this.choosePortaldatPathToolStripMenuItem.Text = "Load client_portal.dat...";
			this.choosePortaldatPathToolStripMenuItem.Click += new System.EventHandler(this.choosePortaldatPathToolStripMenuItem_Click);
			// 
			// exportIconsMenuItem
			// 
			this.exportIconsMenuItem.Name = "exportIconsMenuItem";
			this.exportIconsMenuItem.Size = new System.Drawing.Size(202, 22);
			this.exportIconsMenuItem.Text = "Export icons...";
			this.exportIconsMenuItem.Click += new System.EventHandler(this.exportIconsMenuItem_Click);
			// 
			// toolStripSeparator1
			// 
			this.toolStripSeparator1.Name = "toolStripSeparator1";
			this.toolStripSeparator1.Size = new System.Drawing.Size(199, 6);
			// 
			// exitToolStripMenuItem
			// 
			this.exitToolStripMenuItem.Name = "exitToolStripMenuItem";
			this.exitToolStripMenuItem.Size = new System.Drawing.Size(202, 22);
			this.exitToolStripMenuItem.Text = "Exit";
			this.exitToolStripMenuItem.Click += new System.EventHandler(this.exitToolStripMenuItem_Click);
			// 
			// viewToolStripMenuItem
			// 
			this.viewToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.prefetchIconsCheckbox,
            this.toolStripSeparator2,
            this.largeIconsToolStripMenuItem,
            this.listToolStripMenuItem});
			this.viewToolStripMenuItem.Name = "viewToolStripMenuItem";
			this.viewToolStripMenuItem.Size = new System.Drawing.Size(41, 20);
			this.viewToolStripMenuItem.Text = "&View";
			// 
			// prefetchIconsCheckbox
			// 
			this.prefetchIconsCheckbox.Checked = true;
			this.prefetchIconsCheckbox.CheckOnClick = true;
			this.prefetchIconsCheckbox.CheckState = System.Windows.Forms.CheckState.Checked;
			this.prefetchIconsCheckbox.Name = "prefetchIconsCheckbox";
			this.prefetchIconsCheckbox.Size = new System.Drawing.Size(155, 22);
			this.prefetchIconsCheckbox.Text = "Prefetch Icons";
			this.prefetchIconsCheckbox.ToolTipText = "Prefetches the icons for faster browsing";
			this.prefetchIconsCheckbox.Click += new System.EventHandler(this.prefetchIconsCheckbox_Click);
			// 
			// toolStripSeparator2
			// 
			this.toolStripSeparator2.Name = "toolStripSeparator2";
			this.toolStripSeparator2.Size = new System.Drawing.Size(152, 6);
			// 
			// largeIconsToolStripMenuItem
			// 
			this.largeIconsToolStripMenuItem.Checked = true;
			this.largeIconsToolStripMenuItem.CheckOnClick = true;
			this.largeIconsToolStripMenuItem.CheckState = System.Windows.Forms.CheckState.Checked;
			this.largeIconsToolStripMenuItem.Name = "largeIconsToolStripMenuItem";
			this.largeIconsToolStripMenuItem.Size = new System.Drawing.Size(155, 22);
			this.largeIconsToolStripMenuItem.Text = "Large Icons";
			this.largeIconsToolStripMenuItem.Click += new System.EventHandler(this.largeIconsToolStripMenuItem_Click);
			// 
			// listToolStripMenuItem
			// 
			this.listToolStripMenuItem.CheckOnClick = true;
			this.listToolStripMenuItem.Name = "listToolStripMenuItem";
			this.listToolStripMenuItem.Size = new System.Drawing.Size(155, 22);
			this.listToolStripMenuItem.Text = "List";
			this.listToolStripMenuItem.Click += new System.EventHandler(this.listToolStripMenuItem_Click);
			// 
			// helpToolStripMenuItem
			// 
			this.helpToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.aboutToolStripMenuItem});
			this.helpToolStripMenuItem.Name = "helpToolStripMenuItem";
			this.helpToolStripMenuItem.Size = new System.Drawing.Size(40, 20);
			this.helpToolStripMenuItem.Text = "&Help";
			// 
			// aboutToolStripMenuItem
			// 
			this.aboutToolStripMenuItem.Name = "aboutToolStripMenuItem";
			this.aboutToolStripMenuItem.Size = new System.Drawing.Size(114, 22);
			this.aboutToolStripMenuItem.Text = "&About";
			this.aboutToolStripMenuItem.Click += new System.EventHandler(this.aboutToolStripMenuItem_Click);
			// 
			// itemContextMenu
			// 
			this.itemContextMenu.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.copyHexWordToolStripMenuItem,
            this.copyHexDWordToolStripMenuItem,
            this.toolStripSeparator3,
            this.copyDecimalWordToolStripMenuItem,
            this.copyDecimalDWordToolStripMenuItem});
			this.itemContextMenu.Name = "itemContextMenu";
			this.itemContextMenu.Size = new System.Drawing.Size(186, 120);
			this.itemContextMenu.Opening += new System.ComponentModel.CancelEventHandler(this.itemContextMenu_Opening);
			// 
			// copyHexDWordToolStripMenuItem
			// 
			this.copyHexDWordToolStripMenuItem.Name = "copyHexDWordToolStripMenuItem";
			this.copyHexDWordToolStripMenuItem.Size = new System.Drawing.Size(185, 22);
			this.copyHexDWordToolStripMenuItem.Text = "Copy Hex DWord";
			this.copyHexDWordToolStripMenuItem.Click += new System.EventHandler(this.itemContextMenuItem_Click);
			// 
			// copyHexWordToolStripMenuItem
			// 
			this.copyHexWordToolStripMenuItem.Name = "copyHexWordToolStripMenuItem";
			this.copyHexWordToolStripMenuItem.Size = new System.Drawing.Size(185, 22);
			this.copyHexWordToolStripMenuItem.Text = "Copy Hex Word";
			this.copyHexWordToolStripMenuItem.Click += new System.EventHandler(this.itemContextMenuItem_Click);
			// 
			// copyDecimalDWordToolStripMenuItem
			// 
			this.copyDecimalDWordToolStripMenuItem.Name = "copyDecimalDWordToolStripMenuItem";
			this.copyDecimalDWordToolStripMenuItem.Size = new System.Drawing.Size(185, 22);
			this.copyDecimalDWordToolStripMenuItem.Text = "Copy Decimal DWord";
			this.copyDecimalDWordToolStripMenuItem.Click += new System.EventHandler(this.itemContextMenuItem_Click);
			// 
			// copyDecimalWordToolStripMenuItem
			// 
			this.copyDecimalWordToolStripMenuItem.Name = "copyDecimalWordToolStripMenuItem";
			this.copyDecimalWordToolStripMenuItem.Size = new System.Drawing.Size(185, 22);
			this.copyDecimalWordToolStripMenuItem.Text = "Copy Decimal Word";
			this.copyDecimalWordToolStripMenuItem.Click += new System.EventHandler(this.itemContextMenuItem_Click);
			// 
			// toolStripSeparator3
			// 
			this.toolStripSeparator3.Name = "toolStripSeparator3";
			this.toolStripSeparator3.Size = new System.Drawing.Size(182, 6);
			// 
			// IconBrowser
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size(552, 430);
			this.ContextMenuStrip = this.itemContextMenu;
			this.Controls.Add(this.iconView);
			this.Controls.Add(this.statusStrip1);
			this.Controls.Add(this.menuStrip1);
			this.DoubleBuffered = true;
			this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
			this.MainMenuStrip = this.menuStrip1;
			this.Name = "IconBrowser";
			this.SizeGripStyle = System.Windows.Forms.SizeGripStyle.Show;
			this.Text = "AC Icon Browser";
			this.statusStrip1.ResumeLayout(false);
			this.statusStrip1.PerformLayout();
			this.menuStrip1.ResumeLayout(false);
			this.menuStrip1.PerformLayout();
			this.itemContextMenu.ResumeLayout(false);
			this.ResumeLayout(false);
			this.PerformLayout();

		}

		#endregion

		private System.Windows.Forms.ImageList iconList;
		private System.Windows.Forms.ListView iconView;
		private System.Windows.Forms.StatusStrip statusStrip1;
		private System.Windows.Forms.ToolStripProgressBar preloadProgress;
		private System.Windows.Forms.ToolStripStatusLabel preloadStatus;
		private System.Windows.Forms.MenuStrip menuStrip1;
		private System.Windows.Forms.ToolStripMenuItem fileToolStripMenuItem;
		private System.Windows.Forms.ToolStripMenuItem exitToolStripMenuItem;
		private System.Windows.Forms.ToolStripMenuItem viewToolStripMenuItem;
		private System.Windows.Forms.ToolStripMenuItem largeIconsToolStripMenuItem;
		private System.Windows.Forms.ToolStripMenuItem listToolStripMenuItem;
		private System.Windows.Forms.ToolStripMenuItem choosePortaldatPathToolStripMenuItem;
		private System.Windows.Forms.ToolStripSeparator toolStripSeparator1;
		private System.Windows.Forms.ToolStripMenuItem exportIconsMenuItem;
		private System.Windows.Forms.ToolStripSeparator toolStripSeparator2;
		private System.Windows.Forms.ToolStripMenuItem prefetchIconsCheckbox;
		private System.Windows.Forms.ToolStripSplitButton abortButton;
		private System.Windows.Forms.ToolStripStatusLabel toolStripStatusLabel1;
		private System.Windows.Forms.ToolStripMenuItem helpToolStripMenuItem;
		private System.Windows.Forms.ToolStripMenuItem aboutToolStripMenuItem;
		private System.Windows.Forms.ContextMenuStrip itemContextMenu;
		private System.Windows.Forms.ToolStripMenuItem copyHexDWordToolStripMenuItem;
		private System.Windows.Forms.ToolStripMenuItem copyHexWordToolStripMenuItem;
		private System.Windows.Forms.ToolStripMenuItem copyDecimalDWordToolStripMenuItem;
		private System.Windows.Forms.ToolStripMenuItem copyDecimalWordToolStripMenuItem;
		private System.Windows.Forms.ToolStripSeparator toolStripSeparator3;
	}
}