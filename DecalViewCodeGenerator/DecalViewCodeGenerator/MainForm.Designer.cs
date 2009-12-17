namespace DecalViewCodeGenerator {
	partial class MainForm {
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
		protected override void Dispose(bool disposing) {
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
			DecalViewCodeGenerator.DoubleBuffered.Label label4;
			DecalViewCodeGenerator.DoubleBuffered.Label label3;
			DecalViewCodeGenerator.DoubleBuffered.Label label2;
			DecalViewCodeGenerator.DoubleBuffered.Label label1;
			DecalViewCodeGenerator.DoubleBuffered.Label label5;
			System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MainForm));
			System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
			System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
			this.openFileDialog = new System.Windows.Forms.OpenFileDialog();
			this.itemGridContextMenu = new System.Windows.Forms.ContextMenuStrip(this.components);
			this.enableSelectedVariables = new System.Windows.Forms.ToolStripMenuItem();
			this.disableSelectedVariables = new System.Windows.Forms.ToolStripMenuItem();
			this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
			this.enableSelectedEvents = new System.Windows.Forms.ToolStripMenuItem();
			this.disableSelectedEvents = new System.Windows.Forms.ToolStripMenuItem();
			this.toolStripSeparator2 = new System.Windows.Forms.ToolStripSeparator();
			this.allToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
			this.enableAllVariables = new System.Windows.Forms.ToolStripMenuItem();
			this.disableAllVariables = new System.Windows.Forms.ToolStripMenuItem();
			this.toolStripSeparator5 = new System.Windows.Forms.ToolStripSeparator();
			this.enableAllEvents = new System.Windows.Forms.ToolStripMenuItem();
			this.disableAllEvents = new System.Windows.Forms.ToolStripMenuItem();
			this.toolStripSeparator3 = new System.Windows.Forms.ToolStripSeparator();
			this.resetToDefaultToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
			this.dataGridViewImageColumn1 = new System.Windows.Forms.DataGridViewImageColumn();
			this.toolStripContainer1 = new System.Windows.Forms.ToolStripContainer();
			this.statusStrip1 = new System.Windows.Forms.StatusStrip();
			this.toolStripStatusLabel1 = new System.Windows.Forms.ToolStripStatusLabel();
			this.chkHideDefaultNames = new System.Windows.Forms.CheckBox();
			this.viewXmlPath = new System.Windows.Forms.ComboBox();
			this.itemGrid = new DecalViewCodeGenerator.DoubleBuffered.DataGridView();
			this.colNew = new System.Windows.Forms.DataGridViewTextBoxColumn();
			this.colCreateVariable = new System.Windows.Forms.DataGridViewCheckBoxColumn();
			this.colCreateEvent = new System.Windows.Forms.DataGridViewCheckBoxColumn();
			this.colIcon = new System.Windows.Forms.DataGridViewImageColumn();
			this.colTypeName = new System.Windows.Forms.DataGridViewTextBoxColumn();
			this.colName = new System.Windows.Forms.DataGridViewTextBoxColumn();
			this.colTabName = new System.Windows.Forms.DataGridViewTextBoxColumn();
			this.compactCode = new System.Windows.Forms.CheckBox();
			this.loadButton = new DecalViewCodeGenerator.DoubleBuffered.Button();
			this.className = new DecalViewCodeGenerator.DoubleBuffered.TextBox();
			this.embeddedXmlPath = new DecalViewCodeGenerator.DoubleBuffered.TextBox();
			this.browseButton = new DecalViewCodeGenerator.DoubleBuffered.Button();
			this.exportLanguage = new DecalViewCodeGenerator.DoubleBuffered.ComboBox();
			this.generateButton = new DecalViewCodeGenerator.DoubleBuffered.Button();
			this.mainMenuStrip = new System.Windows.Forms.MenuStrip();
			this.fileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
			this.exitToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
			this.helpToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
			this.launchOnlineHelpToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
			this.aboutToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
			label4 = new DecalViewCodeGenerator.DoubleBuffered.Label();
			label3 = new DecalViewCodeGenerator.DoubleBuffered.Label();
			label2 = new DecalViewCodeGenerator.DoubleBuffered.Label();
			label1 = new DecalViewCodeGenerator.DoubleBuffered.Label();
			label5 = new DecalViewCodeGenerator.DoubleBuffered.Label();
			this.itemGridContextMenu.SuspendLayout();
			this.toolStripContainer1.BottomToolStripPanel.SuspendLayout();
			this.toolStripContainer1.ContentPanel.SuspendLayout();
			this.toolStripContainer1.TopToolStripPanel.SuspendLayout();
			this.toolStripContainer1.SuspendLayout();
			this.statusStrip1.SuspendLayout();
			((System.ComponentModel.ISupportInitialize)(this.itemGrid)).BeginInit();
			this.mainMenuStrip.SuspendLayout();
			this.SuspendLayout();
			// 
			// label4
			// 
			label4.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
			label4.AutoSize = true;
			label4.Location = new System.Drawing.Point(463, 401);
			label4.Name = "label4";
			label4.Size = new System.Drawing.Size(55, 13);
			label4.TabIndex = 28;
			label4.Text = "Language";
			// 
			// label3
			// 
			label3.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
			label3.AutoSize = true;
			label3.Location = new System.Drawing.Point(11, 401);
			label3.Name = "label3";
			label3.Size = new System.Drawing.Size(108, 13);
			label3.TabIndex = 27;
			label3.Text = "Embedded view XML";
			// 
			// label2
			// 
			label2.AutoSize = true;
			label2.Location = new System.Drawing.Point(12, 49);
			label2.Name = "label2";
			label2.Size = new System.Drawing.Size(236, 13);
			label2.TabIndex = 22;
			label2.Text = "Select controls to include in the generated code:";
			// 
			// label1
			// 
			label1.AutoSize = true;
			label1.Location = new System.Drawing.Point(11, 5);
			label1.Name = "label1";
			label1.Size = new System.Drawing.Size(95, 13);
			label1.TabIndex = 18;
			label1.Text = "View XML location";
			// 
			// label5
			// 
			label5.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
			label5.AutoSize = true;
			label5.Location = new System.Drawing.Point(299, 401);
			label5.Name = "label5";
			label5.Size = new System.Drawing.Size(118, 13);
			label5.TabIndex = 29;
			label5.Text = "Namespace.Classname";
			// 
			// openFileDialog
			// 
			this.openFileDialog.Filter = "XML Files|*.xml|All files|*.*";
			// 
			// itemGridContextMenu
			// 
			this.itemGridContextMenu.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.enableSelectedVariables,
            this.disableSelectedVariables,
            this.toolStripSeparator1,
            this.enableSelectedEvents,
            this.disableSelectedEvents,
            this.toolStripSeparator2,
            this.allToolStripMenuItem});
			this.itemGridContextMenu.Name = "contextMenuStrip1";
			this.itemGridContextMenu.Size = new System.Drawing.Size(210, 126);
			// 
			// enableSelectedVariables
			// 
			this.enableSelectedVariables.Name = "enableSelectedVariables";
			this.enableSelectedVariables.Size = new System.Drawing.Size(209, 22);
			this.enableSelectedVariables.Text = "Enable Selected &Variables";
			this.enableSelectedVariables.ToolTipText = "Enable creation of variables for selected controls";
			this.enableSelectedVariables.Click += new System.EventHandler(this.enableSelectedVariables_Click);
			// 
			// disableSelectedVariables
			// 
			this.disableSelectedVariables.Name = "disableSelectedVariables";
			this.disableSelectedVariables.Size = new System.Drawing.Size(209, 22);
			this.disableSelectedVariables.Text = "&Disable Selected Variables";
			this.disableSelectedVariables.ToolTipText = "Disable creation of variables for selected controls";
			this.disableSelectedVariables.Click += new System.EventHandler(this.disableSelectedVariables_Click);
			// 
			// toolStripSeparator1
			// 
			this.toolStripSeparator1.Name = "toolStripSeparator1";
			this.toolStripSeparator1.Size = new System.Drawing.Size(206, 6);
			// 
			// enableSelectedEvents
			// 
			this.enableSelectedEvents.Name = "enableSelectedEvents";
			this.enableSelectedEvents.Size = new System.Drawing.Size(209, 22);
			this.enableSelectedEvents.Text = "Enable Selected &Events";
			this.enableSelectedEvents.ToolTipText = "Enable creation of events for selected controls";
			this.enableSelectedEvents.Click += new System.EventHandler(this.enableSelectedEvents_Click);
			// 
			// disableSelectedEvents
			// 
			this.disableSelectedEvents.Name = "disableSelectedEvents";
			this.disableSelectedEvents.Size = new System.Drawing.Size(209, 22);
			this.disableSelectedEvents.Text = "Di&sable Selected Events";
			this.disableSelectedEvents.ToolTipText = "Disable creation of events for selected controls";
			this.disableSelectedEvents.Click += new System.EventHandler(this.disableSelectedEvents_Click);
			// 
			// toolStripSeparator2
			// 
			this.toolStripSeparator2.Name = "toolStripSeparator2";
			this.toolStripSeparator2.Size = new System.Drawing.Size(206, 6);
			// 
			// allToolStripMenuItem
			// 
			this.allToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.enableAllVariables,
            this.disableAllVariables,
            this.toolStripSeparator5,
            this.enableAllEvents,
            this.disableAllEvents,
            this.toolStripSeparator3,
            this.resetToDefaultToolStripMenuItem});
			this.allToolStripMenuItem.Name = "allToolStripMenuItem";
			this.allToolStripMenuItem.Size = new System.Drawing.Size(209, 22);
			this.allToolStripMenuItem.Text = "&All";
			// 
			// enableAllVariables
			// 
			this.enableAllVariables.Name = "enableAllVariables";
			this.enableAllVariables.Size = new System.Drawing.Size(165, 22);
			this.enableAllVariables.Text = "Enable &Variables";
			this.enableAllVariables.ToolTipText = "Enable creation of variables for all controls that have names";
			this.enableAllVariables.Click += new System.EventHandler(this.enableAllVariables_Click);
			// 
			// disableAllVariables
			// 
			this.disableAllVariables.Name = "disableAllVariables";
			this.disableAllVariables.Size = new System.Drawing.Size(165, 22);
			this.disableAllVariables.Text = "&Disable Variables";
			this.disableAllVariables.ToolTipText = "Disable creation of variables for all controls";
			this.disableAllVariables.Click += new System.EventHandler(this.disableAllVariables_Click);
			// 
			// toolStripSeparator5
			// 
			this.toolStripSeparator5.Name = "toolStripSeparator5";
			this.toolStripSeparator5.Size = new System.Drawing.Size(162, 6);
			// 
			// enableAllEvents
			// 
			this.enableAllEvents.Name = "enableAllEvents";
			this.enableAllEvents.Size = new System.Drawing.Size(165, 22);
			this.enableAllEvents.Text = "Enable &Events";
			this.enableAllEvents.ToolTipText = "Enable creation of events for all controls that have names";
			this.enableAllEvents.Click += new System.EventHandler(this.enableAllEvents_Click);
			// 
			// disableAllEvents
			// 
			this.disableAllEvents.Name = "disableAllEvents";
			this.disableAllEvents.Size = new System.Drawing.Size(165, 22);
			this.disableAllEvents.Text = "Di&sable Events";
			this.disableAllEvents.ToolTipText = "Disable creation of events for all controls";
			this.disableAllEvents.Click += new System.EventHandler(this.disableAllEvents_Click);
			// 
			// toolStripSeparator3
			// 
			this.toolStripSeparator3.Name = "toolStripSeparator3";
			this.toolStripSeparator3.Size = new System.Drawing.Size(162, 6);
			// 
			// resetToDefaultToolStripMenuItem
			// 
			this.resetToDefaultToolStripMenuItem.Name = "resetToDefaultToolStripMenuItem";
			this.resetToDefaultToolStripMenuItem.Size = new System.Drawing.Size(165, 22);
			this.resetToDefaultToolStripMenuItem.Text = "&Reset to Default";
			this.resetToDefaultToolStripMenuItem.ToolTipText = "Enables only controls with names that are not the default in Visual Decal (e.g. n" +
				"ot \"Label6\")";
			this.resetToDefaultToolStripMenuItem.Click += new System.EventHandler(this.resetToDefaultToolStripMenuItem_Click);
			// 
			// dataGridViewImageColumn1
			// 
			this.dataGridViewImageColumn1.HeaderText = "";
			this.dataGridViewImageColumn1.Image = ((System.Drawing.Image)(resources.GetObject("dataGridViewImageColumn1.Image")));
			this.dataGridViewImageColumn1.MinimumWidth = 20;
			this.dataGridViewImageColumn1.Name = "dataGridViewImageColumn1";
			this.dataGridViewImageColumn1.ReadOnly = true;
			this.dataGridViewImageColumn1.Resizable = System.Windows.Forms.DataGridViewTriState.False;
			this.dataGridViewImageColumn1.Width = 20;
			// 
			// toolStripContainer1
			// 
			// 
			// toolStripContainer1.BottomToolStripPanel
			// 
			this.toolStripContainer1.BottomToolStripPanel.Controls.Add(this.statusStrip1);
			// 
			// toolStripContainer1.ContentPanel
			// 
			this.toolStripContainer1.ContentPanel.Controls.Add(this.chkHideDefaultNames);
			this.toolStripContainer1.ContentPanel.Controls.Add(this.viewXmlPath);
			this.toolStripContainer1.ContentPanel.Controls.Add(this.itemGrid);
			this.toolStripContainer1.ContentPanel.Controls.Add(this.compactCode);
			this.toolStripContainer1.ContentPanel.Controls.Add(this.loadButton);
			this.toolStripContainer1.ContentPanel.Controls.Add(this.className);
			this.toolStripContainer1.ContentPanel.Controls.Add(this.embeddedXmlPath);
			this.toolStripContainer1.ContentPanel.Controls.Add(label4);
			this.toolStripContainer1.ContentPanel.Controls.Add(this.browseButton);
			this.toolStripContainer1.ContentPanel.Controls.Add(label3);
			this.toolStripContainer1.ContentPanel.Controls.Add(label2);
			this.toolStripContainer1.ContentPanel.Controls.Add(this.exportLanguage);
			this.toolStripContainer1.ContentPanel.Controls.Add(this.generateButton);
			this.toolStripContainer1.ContentPanel.Controls.Add(label1);
			this.toolStripContainer1.ContentPanel.Controls.Add(label5);
			this.toolStripContainer1.ContentPanel.Size = new System.Drawing.Size(655, 446);
			this.toolStripContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
			this.toolStripContainer1.Location = new System.Drawing.Point(0, 0);
			this.toolStripContainer1.Name = "toolStripContainer1";
			this.toolStripContainer1.Size = new System.Drawing.Size(655, 492);
			this.toolStripContainer1.TabIndex = 1;
			this.toolStripContainer1.Text = "toolStripContainer1";
			// 
			// toolStripContainer1.TopToolStripPanel
			// 
			this.toolStripContainer1.TopToolStripPanel.Controls.Add(this.mainMenuStrip);
			// 
			// statusStrip1
			// 
			this.statusStrip1.Dock = System.Windows.Forms.DockStyle.None;
			this.statusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripStatusLabel1});
			this.statusStrip1.Location = new System.Drawing.Point(0, 0);
			this.statusStrip1.Name = "statusStrip1";
			this.statusStrip1.Size = new System.Drawing.Size(655, 22);
			this.statusStrip1.TabIndex = 0;
			// 
			// toolStripStatusLabel1
			// 
			this.toolStripStatusLabel1.Name = "toolStripStatusLabel1";
			this.toolStripStatusLabel1.Size = new System.Drawing.Size(416, 17);
			this.toolStripStatusLabel1.Text = "Tip: The order of the variables in the list determines the order in the generated" +
				" code.";
			// 
			// chkHideDefaultNames
			// 
			this.chkHideDefaultNames.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
			this.chkHideDefaultNames.AutoSize = true;
			this.chkHideDefaultNames.Location = new System.Drawing.Point(464, 48);
			this.chkHideDefaultNames.Name = "chkHideDefaultNames";
			this.chkHideDefaultNames.Size = new System.Drawing.Size(179, 17);
			this.chkHideDefaultNames.TabIndex = 30;
			this.chkHideDefaultNames.Text = "Hide controls with default names";
			this.chkHideDefaultNames.UseVisualStyleBackColor = true;
			this.chkHideDefaultNames.CheckedChanged += new System.EventHandler(this.chkHideDefaultNames_CheckedChanged);
			// 
			// viewXmlPath
			// 
			this.viewXmlPath.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
						| System.Windows.Forms.AnchorStyles.Right)));
			this.viewXmlPath.AutoCompleteMode = System.Windows.Forms.AutoCompleteMode.Suggest;
			this.viewXmlPath.AutoCompleteSource = System.Windows.Forms.AutoCompleteSource.ListItems;
			this.viewXmlPath.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
			this.viewXmlPath.FormattingEnabled = true;
			this.viewXmlPath.Location = new System.Drawing.Point(14, 21);
			this.viewXmlPath.Name = "viewXmlPath";
			this.viewXmlPath.Size = new System.Drawing.Size(488, 21);
			this.viewXmlPath.TabIndex = 1;
			// 
			// itemGrid
			// 
			this.itemGrid.AllowUserToAddRows = false;
			this.itemGrid.AllowUserToDeleteRows = false;
			this.itemGrid.AllowUserToResizeRows = false;
			this.itemGrid.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
						| System.Windows.Forms.AnchorStyles.Left)
						| System.Windows.Forms.AnchorStyles.Right)));
			this.itemGrid.BackgroundColor = System.Drawing.SystemColors.Window;
			this.itemGrid.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
			this.itemGrid.CellBorderStyle = System.Windows.Forms.DataGridViewCellBorderStyle.None;
			this.itemGrid.ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.None;
			this.itemGrid.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
			this.itemGrid.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.colNew,
            this.colCreateVariable,
            this.colCreateEvent,
            this.colIcon,
            this.colTypeName,
            this.colName,
            this.colTabName});
			this.itemGrid.ContextMenuStrip = this.itemGridContextMenu;
			this.itemGrid.Location = new System.Drawing.Point(14, 65);
			this.itemGrid.Name = "itemGrid";
			this.itemGrid.RowHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.Single;
			this.itemGrid.RowHeadersVisible = false;
			this.itemGrid.RowHeadersWidthSizeMode = System.Windows.Forms.DataGridViewRowHeadersWidthSizeMode.DisableResizing;
			this.itemGrid.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
			this.itemGrid.Size = new System.Drawing.Size(632, 333);
			this.itemGrid.TabIndex = 26;
			this.itemGrid.SortCompare += new System.Windows.Forms.DataGridViewSortCompareEventHandler(this.itemGrid_SortCompare);
			this.itemGrid.Resize += new System.EventHandler(this.itemGrid_Resize);
			// 
			// colNew
			// 
			this.colNew.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.None;
			dataGridViewCellStyle1.Font = new System.Drawing.Font("Courier New", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.colNew.DefaultCellStyle = dataGridViewCellStyle1;
			this.colNew.HeaderText = "*";
			this.colNew.Name = "colNew";
			this.colNew.ReadOnly = true;
			this.colNew.Resizable = System.Windows.Forms.DataGridViewTriState.False;
			this.colNew.ToolTipText = "Indicates that the control is new since the last time you loaded this view";
			this.colNew.Width = 18;
			// 
			// colCreateVariable
			// 
			dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
			dataGridViewCellStyle2.NullValue = false;
			this.colCreateVariable.DefaultCellStyle = dataGridViewCellStyle2;
			this.colCreateVariable.HeaderText = "Var";
			this.colCreateVariable.IndeterminateValue = "";
			this.colCreateVariable.MinimumWidth = 20;
			this.colCreateVariable.Name = "colCreateVariable";
			this.colCreateVariable.Resizable = System.Windows.Forms.DataGridViewTriState.True;
			this.colCreateVariable.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.Automatic;
			this.colCreateVariable.ToolTipText = "Check to generate a variable reference for this control";
			this.colCreateVariable.Width = 26;
			// 
			// colCreateEvent
			// 
			this.colCreateEvent.HeaderText = "Event";
			this.colCreateEvent.MinimumWidth = 20;
			this.colCreateEvent.Name = "colCreateEvent";
			this.colCreateEvent.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.Automatic;
			this.colCreateEvent.ToolTipText = "Check to create the default event handler for this control (e.g. Click for PushBu" +
				"ttons)";
			this.colCreateEvent.Width = 38;
			// 
			// colIcon
			// 
			this.colIcon.HeaderText = "";
			this.colIcon.Image = ((System.Drawing.Image)(resources.GetObject("colIcon.Image")));
			this.colIcon.MinimumWidth = 20;
			this.colIcon.Name = "colIcon";
			this.colIcon.ReadOnly = true;
			this.colIcon.Resizable = System.Windows.Forms.DataGridViewTriState.False;
			this.colIcon.Width = 20;
			// 
			// colTypeName
			// 
			this.colTypeName.HeaderText = "Type";
			this.colTypeName.Name = "colTypeName";
			this.colTypeName.ReadOnly = true;
			// 
			// colName
			// 
			this.colName.HeaderText = "Name";
			this.colName.MinimumWidth = 35;
			this.colName.Name = "colName";
			this.colName.ReadOnly = true;
			this.colName.Resizable = System.Windows.Forms.DataGridViewTriState.False;
			this.colName.Width = 250;
			// 
			// colTabName
			// 
			this.colTabName.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
			this.colTabName.HeaderText = "Tab";
			this.colTabName.Name = "colTabName";
			this.colTabName.ReadOnly = true;
			this.colTabName.Width = 51;
			// 
			// compactCode
			// 
			this.compactCode.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
			this.compactCode.AutoSize = true;
			this.compactCode.Location = new System.Drawing.Point(547, 400);
			this.compactCode.Name = "compactCode";
			this.compactCode.Size = new System.Drawing.Size(96, 17);
			this.compactCode.TabIndex = 25;
			this.compactCode.Text = "Compact Code";
			this.compactCode.UseVisualStyleBackColor = true;
			// 
			// loadButton
			// 
			this.loadButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
			this.loadButton.Location = new System.Drawing.Point(581, 20);
			this.loadButton.Name = "loadButton";
			this.loadButton.Size = new System.Drawing.Size(65, 21);
			this.loadButton.TabIndex = 19;
			this.loadButton.Text = "Load";
			this.loadButton.UseVisualStyleBackColor = true;
			this.loadButton.Click += new System.EventHandler(this.loadButton_Click);
			// 
			// className
			// 
			this.className.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
			this.className.Location = new System.Drawing.Point(302, 417);
			this.className.Name = "className";
			this.className.Size = new System.Drawing.Size(158, 20);
			this.className.TabIndex = 21;
			// 
			// embeddedXmlPath
			// 
			this.embeddedXmlPath.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)
						| System.Windows.Forms.AnchorStyles.Right)));
			this.embeddedXmlPath.Location = new System.Drawing.Point(14, 417);
			this.embeddedXmlPath.Name = "embeddedXmlPath";
			this.embeddedXmlPath.Size = new System.Drawing.Size(282, 20);
			this.embeddedXmlPath.TabIndex = 20;
			// 
			// browseButton
			// 
			this.browseButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
			this.browseButton.Location = new System.Drawing.Point(508, 20);
			this.browseButton.Name = "browseButton";
			this.browseButton.Size = new System.Drawing.Size(67, 20);
			this.browseButton.TabIndex = 17;
			this.browseButton.Text = "Browse...";
			this.browseButton.UseVisualStyleBackColor = true;
			this.browseButton.Click += new System.EventHandler(this.browseButton_Click);
			// 
			// exportLanguage
			// 
			this.exportLanguage.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
			this.exportLanguage.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
			this.exportLanguage.FormattingEnabled = true;
			this.exportLanguage.Items.AddRange(new object[] {
            "C#",
            "VB.NET"});
			this.exportLanguage.Location = new System.Drawing.Point(466, 417);
			this.exportLanguage.Name = "exportLanguage";
			this.exportLanguage.Size = new System.Drawing.Size(69, 21);
			this.exportLanguage.TabIndex = 23;
			// 
			// generateButton
			// 
			this.generateButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
			this.generateButton.Location = new System.Drawing.Point(541, 417);
			this.generateButton.Name = "generateButton";
			this.generateButton.Size = new System.Drawing.Size(105, 21);
			this.generateButton.TabIndex = 24;
			this.generateButton.Text = "Generate Code";
			this.generateButton.UseVisualStyleBackColor = true;
			this.generateButton.Click += new System.EventHandler(this.generateButton_Click);
			// 
			// mainMenuStrip
			// 
			this.mainMenuStrip.Dock = System.Windows.Forms.DockStyle.None;
			this.mainMenuStrip.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileToolStripMenuItem,
            this.helpToolStripMenuItem});
			this.mainMenuStrip.Location = new System.Drawing.Point(0, 0);
			this.mainMenuStrip.Name = "mainMenuStrip";
			this.mainMenuStrip.Size = new System.Drawing.Size(655, 24);
			this.mainMenuStrip.TabIndex = 0;
			this.mainMenuStrip.Text = "menuStrip1";
			// 
			// fileToolStripMenuItem
			// 
			this.fileToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.exitToolStripMenuItem});
			this.fileToolStripMenuItem.Name = "fileToolStripMenuItem";
			this.fileToolStripMenuItem.Size = new System.Drawing.Size(35, 20);
			this.fileToolStripMenuItem.Text = "&File";
			// 
			// exitToolStripMenuItem
			// 
			this.exitToolStripMenuItem.Name = "exitToolStripMenuItem";
			this.exitToolStripMenuItem.ShortcutKeyDisplayString = "Alt+F4";
			this.exitToolStripMenuItem.Size = new System.Drawing.Size(143, 22);
			this.exitToolStripMenuItem.Text = "E&xit";
			this.exitToolStripMenuItem.Click += new System.EventHandler(this.exitToolStripMenuItem_Click);
			// 
			// helpToolStripMenuItem
			// 
			this.helpToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.launchOnlineHelpToolStripMenuItem,
            this.aboutToolStripMenuItem});
			this.helpToolStripMenuItem.Name = "helpToolStripMenuItem";
			this.helpToolStripMenuItem.Size = new System.Drawing.Size(40, 20);
			this.helpToolStripMenuItem.Text = "&Help";
			// 
			// launchOnlineHelpToolStripMenuItem
			// 
			this.launchOnlineHelpToolStripMenuItem.Name = "launchOnlineHelpToolStripMenuItem";
			this.launchOnlineHelpToolStripMenuItem.Size = new System.Drawing.Size(188, 22);
			this.launchOnlineHelpToolStripMenuItem.Text = "Launch Online Help...";
			this.launchOnlineHelpToolStripMenuItem.Click += new System.EventHandler(this.launchOnlineHelpToolStripMenuItem_Click);
			// 
			// aboutToolStripMenuItem
			// 
			this.aboutToolStripMenuItem.Name = "aboutToolStripMenuItem";
			this.aboutToolStripMenuItem.Size = new System.Drawing.Size(188, 22);
			this.aboutToolStripMenuItem.Text = "&About";
			this.aboutToolStripMenuItem.Click += new System.EventHandler(this.aboutToolStripMenuItem_Click);
			// 
			// MainForm
			// 
			this.AcceptButton = this.loadButton;
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size(655, 492);
			this.Controls.Add(this.toolStripContainer1);
			this.DoubleBuffered = true;
			this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
			this.MainMenuStrip = this.mainMenuStrip;
			this.MinimumSize = new System.Drawing.Size(465, 225);
			this.Name = "MainForm";
			this.SizeGripStyle = System.Windows.Forms.SizeGripStyle.Show;
			this.Text = "Decal View Code Generator";
			this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.MainForm_FormClosing);
			this.Load += new System.EventHandler(this.MainForm_Load);
			this.itemGridContextMenu.ResumeLayout(false);
			this.toolStripContainer1.BottomToolStripPanel.ResumeLayout(false);
			this.toolStripContainer1.BottomToolStripPanel.PerformLayout();
			this.toolStripContainer1.ContentPanel.ResumeLayout(false);
			this.toolStripContainer1.ContentPanel.PerformLayout();
			this.toolStripContainer1.TopToolStripPanel.ResumeLayout(false);
			this.toolStripContainer1.TopToolStripPanel.PerformLayout();
			this.toolStripContainer1.ResumeLayout(false);
			this.toolStripContainer1.PerformLayout();
			this.statusStrip1.ResumeLayout(false);
			this.statusStrip1.PerformLayout();
			((System.ComponentModel.ISupportInitialize)(this.itemGrid)).EndInit();
			this.mainMenuStrip.ResumeLayout(false);
			this.mainMenuStrip.PerformLayout();
			this.ResumeLayout(false);

		}

		#endregion

		private System.Windows.Forms.OpenFileDialog openFileDialog;
		private System.Windows.Forms.DataGridViewImageColumn dataGridViewImageColumn1;
		private System.Windows.Forms.ContextMenuStrip itemGridContextMenu;
		private System.Windows.Forms.ToolStripMenuItem enableSelectedVariables;
		private System.Windows.Forms.ToolStripMenuItem disableSelectedVariables;
		private System.Windows.Forms.ToolStripSeparator toolStripSeparator1;
		private System.Windows.Forms.ToolStripMenuItem enableSelectedEvents;
		private System.Windows.Forms.ToolStripMenuItem disableSelectedEvents;
		private System.Windows.Forms.ToolStripSeparator toolStripSeparator2;
		private System.Windows.Forms.ToolStripMenuItem allToolStripMenuItem;
		private System.Windows.Forms.ToolStripMenuItem enableAllVariables;
		private System.Windows.Forms.ToolStripMenuItem disableAllVariables;
		private System.Windows.Forms.ToolStripSeparator toolStripSeparator5;
		private System.Windows.Forms.ToolStripMenuItem enableAllEvents;
		private System.Windows.Forms.ToolStripMenuItem disableAllEvents;
		private System.Windows.Forms.ToolStripContainer toolStripContainer1;
		private DecalViewCodeGenerator.DoubleBuffered.DataGridView itemGrid;
		private System.Windows.Forms.DataGridViewTextBoxColumn colNew;
		private System.Windows.Forms.DataGridViewCheckBoxColumn colCreateVariable;
		private System.Windows.Forms.DataGridViewCheckBoxColumn colCreateEvent;
		private System.Windows.Forms.DataGridViewImageColumn colIcon;
		private System.Windows.Forms.DataGridViewTextBoxColumn colTypeName;
		private System.Windows.Forms.DataGridViewTextBoxColumn colName;
		private System.Windows.Forms.DataGridViewTextBoxColumn colTabName;
		private System.Windows.Forms.CheckBox compactCode;
		private DecalViewCodeGenerator.DoubleBuffered.Button loadButton;
		private DecalViewCodeGenerator.DoubleBuffered.TextBox className;
		private DecalViewCodeGenerator.DoubleBuffered.TextBox embeddedXmlPath;
		private DecalViewCodeGenerator.DoubleBuffered.Button browseButton;
		private DecalViewCodeGenerator.DoubleBuffered.ComboBox exportLanguage;
		private DecalViewCodeGenerator.DoubleBuffered.Button generateButton;
		private System.Windows.Forms.StatusStrip statusStrip1;
		private System.Windows.Forms.ToolStripStatusLabel toolStripStatusLabel1;
		private System.Windows.Forms.MenuStrip mainMenuStrip;
		private System.Windows.Forms.ComboBox viewXmlPath;
		private System.Windows.Forms.ToolStripMenuItem fileToolStripMenuItem;
		private System.Windows.Forms.ToolStripMenuItem exitToolStripMenuItem;
		private System.Windows.Forms.ToolStripMenuItem helpToolStripMenuItem;
		private System.Windows.Forms.ToolStripMenuItem launchOnlineHelpToolStripMenuItem;
		private System.Windows.Forms.ToolStripMenuItem aboutToolStripMenuItem;
		private System.Windows.Forms.ToolStripSeparator toolStripSeparator3;
		private System.Windows.Forms.ToolStripMenuItem resetToDefaultToolStripMenuItem;
		private System.Windows.Forms.CheckBox chkHideDefaultNames;
	}
}

