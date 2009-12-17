namespace ACIconBrowser {
	partial class ExportDialog {
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
			this.okButton = new System.Windows.Forms.Button();
			this.cancelButton = new System.Windows.Forms.Button();
			this.folderBrowserDialog = new System.Windows.Forms.FolderBrowserDialog();
			this.panel1 = new System.Windows.Forms.Panel();
			this.exportSelected = new System.Windows.Forms.RadioButton();
			this.exportAll = new System.Windows.Forms.RadioButton();
			this.exportFolderTextbox = new System.Windows.Forms.TextBox();
			this.label1 = new System.Windows.Forms.Label();
			this.browseButton = new System.Windows.Forms.Button();
			this.fileFormatCombo = new System.Windows.Forms.ComboBox();
			this.label2 = new System.Windows.Forms.Label();
			this.label3 = new System.Windows.Forms.Label();
			this.nameFormatTextbox = new System.Windows.Forms.TextBox();
			this.panel2 = new System.Windows.Forms.Panel();
			this.label8 = new System.Windows.Forms.Label();
			this.label4 = new System.Windows.Forms.Label();
			this.label5 = new System.Windows.Forms.Label();
			this.panel1.SuspendLayout();
			this.panel2.SuspendLayout();
			this.SuspendLayout();
			// 
			// okButton
			// 
			this.okButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
			this.okButton.DialogResult = System.Windows.Forms.DialogResult.OK;
			this.okButton.Location = new System.Drawing.Point(290, 189);
			this.okButton.Name = "okButton";
			this.okButton.Size = new System.Drawing.Size(72, 24);
			this.okButton.TabIndex = 0;
			this.okButton.Text = "&Export";
			this.okButton.UseVisualStyleBackColor = true;
			// 
			// cancelButton
			// 
			this.cancelButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
			this.cancelButton.CausesValidation = false;
			this.cancelButton.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.cancelButton.Location = new System.Drawing.Point(368, 189);
			this.cancelButton.Name = "cancelButton";
			this.cancelButton.Size = new System.Drawing.Size(74, 24);
			this.cancelButton.TabIndex = 1;
			this.cancelButton.Text = "&Cancel";
			this.cancelButton.UseVisualStyleBackColor = true;
			// 
			// folderBrowserDialog
			// 
			this.folderBrowserDialog.Description = "Select the export folder";
			// 
			// panel1
			// 
			this.panel1.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
			this.panel1.Controls.Add(this.exportSelected);
			this.panel1.Controls.Add(this.exportAll);
			this.panel1.Location = new System.Drawing.Point(306, 101);
			this.panel1.Name = "panel1";
			this.panel1.Size = new System.Drawing.Size(116, 54);
			this.panel1.TabIndex = 2;
			// 
			// exportSelected
			// 
			this.exportSelected.AutoSize = true;
			this.exportSelected.Location = new System.Drawing.Point(3, 26);
			this.exportSelected.Name = "exportSelected";
			this.exportSelected.Size = new System.Drawing.Size(98, 17);
			this.exportSelected.TabIndex = 1;
			this.exportSelected.Text = "Export selected";
			this.exportSelected.UseVisualStyleBackColor = true;
			// 
			// exportAll
			// 
			this.exportAll.AutoSize = true;
			this.exportAll.Checked = true;
			this.exportAll.Location = new System.Drawing.Point(3, 3);
			this.exportAll.Name = "exportAll";
			this.exportAll.Size = new System.Drawing.Size(68, 17);
			this.exportAll.TabIndex = 0;
			this.exportAll.TabStop = true;
			this.exportAll.Text = "Export all";
			this.exportAll.UseVisualStyleBackColor = true;
			// 
			// exportFolderTextbox
			// 
			this.exportFolderTextbox.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
						| System.Windows.Forms.AnchorStyles.Right)));
			this.exportFolderTextbox.Location = new System.Drawing.Point(12, 25);
			this.exportFolderTextbox.Name = "exportFolderTextbox";
			this.exportFolderTextbox.Size = new System.Drawing.Size(366, 20);
			this.exportFolderTextbox.TabIndex = 3;
			// 
			// label1
			// 
			this.label1.AutoSize = true;
			this.label1.Location = new System.Drawing.Point(12, 9);
			this.label1.Name = "label1";
			this.label1.Size = new System.Drawing.Size(66, 13);
			this.label1.TabIndex = 4;
			this.label1.Text = "Export folder";
			// 
			// browseButton
			// 
			this.browseButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
			this.browseButton.Location = new System.Drawing.Point(384, 25);
			this.browseButton.Name = "browseButton";
			this.browseButton.Size = new System.Drawing.Size(58, 20);
			this.browseButton.TabIndex = 5;
			this.browseButton.Text = "Browse...";
			this.browseButton.UseVisualStyleBackColor = true;
			this.browseButton.Click += new System.EventHandler(this.browseButton_Click);
			// 
			// fileFormatCombo
			// 
			this.fileFormatCombo.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
			this.fileFormatCombo.FormattingEnabled = true;
			this.fileFormatCombo.Items.AddRange(new object[] {
            "Bitmap (.bmp)",
            "GIF (.gif)",
            "JPEG (.jpg)",
            "PNG (.png)"});
			this.fileFormatCombo.Location = new System.Drawing.Point(306, 74);
			this.fileFormatCombo.Name = "fileFormatCombo";
			this.fileFormatCombo.Size = new System.Drawing.Size(136, 21);
			this.fileFormatCombo.TabIndex = 6;
			this.fileFormatCombo.Text = "GIF (.gif)";
			// 
			// label2
			// 
			this.label2.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
			this.label2.AutoSize = true;
			this.label2.Location = new System.Drawing.Point(303, 58);
			this.label2.Name = "label2";
			this.label2.Size = new System.Drawing.Size(55, 13);
			this.label2.TabIndex = 7;
			this.label2.Text = "File format";
			// 
			// label3
			// 
			this.label3.AutoSize = true;
			this.label3.Location = new System.Drawing.Point(12, 59);
			this.label3.Name = "label3";
			this.label3.Size = new System.Drawing.Size(158, 13);
			this.label3.TabIndex = 8;
			this.label3.Text = "Name format (without extension)";
			// 
			// nameFormatTextbox
			// 
			this.nameFormatTextbox.Location = new System.Drawing.Point(12, 75);
			this.nameFormatTextbox.Name = "nameFormatTextbox";
			this.nameFormatTextbox.Size = new System.Drawing.Size(201, 20);
			this.nameFormatTextbox.TabIndex = 9;
			this.nameFormatTextbox.Text = "$H";
			this.nameFormatTextbox.Enter += new System.EventHandler(this.nameFormatTextbox_Enter);
			this.nameFormatTextbox.Leave += new System.EventHandler(this.nameFormatTextbox_Leave);
			this.nameFormatTextbox.Validating += new System.ComponentModel.CancelEventHandler(this.nameFormatTextbox_Validating);
			// 
			// panel2
			// 
			this.panel2.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
						| System.Windows.Forms.AnchorStyles.Right)));
			this.panel2.Controls.Add(this.label5);
			this.panel2.Controls.Add(this.label8);
			this.panel2.Controls.Add(this.label4);
			this.panel2.Location = new System.Drawing.Point(12, 101);
			this.panel2.Name = "panel2";
			this.panel2.Size = new System.Drawing.Size(272, 85);
			this.panel2.TabIndex = 10;
			// 
			// label8
			// 
			this.label8.AutoSize = true;
			this.label8.Location = new System.Drawing.Point(3, 15);
			this.label8.Name = "label8";
			this.label8.Size = new System.Drawing.Size(177, 52);
			this.label8.TabIndex = 4;
			this.label8.Text = "$H Hex word  (e.g. 4F13)\r\n$L Hex dword (e.g. 06004F13)\r\n$D Decimal word (e.g. 202" +
				"43)\r\n$E Decimal dword (e.g. 100683539)";
			// 
			// label4
			// 
			this.label4.AutoSize = true;
			this.label4.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Underline, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.label4.Location = new System.Drawing.Point(3, 2);
			this.label4.Name = "label4";
			this.label4.Size = new System.Drawing.Size(54, 13);
			this.label4.TabIndex = 0;
			this.label4.Text = "Wildcards";
			// 
			// label5
			// 
			this.label5.AutoSize = true;
			this.label5.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Italic, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.label5.Location = new System.Drawing.Point(3, 67);
			this.label5.Name = "label5";
			this.label5.Size = new System.Drawing.Size(240, 13);
			this.label5.TabIndex = 5;
			this.label5.Text = "Use lower case $h or $l for lower case hex output";
			// 
			// ExportDialog
			// 
			this.AcceptButton = this.okButton;
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.CancelButton = this.cancelButton;
			this.ClientSize = new System.Drawing.Size(454, 225);
			this.Controls.Add(this.exportFolderTextbox);
			this.Controls.Add(this.fileFormatCombo);
			this.Controls.Add(this.nameFormatTextbox);
			this.Controls.Add(this.panel2);
			this.Controls.Add(this.label3);
			this.Controls.Add(this.label2);
			this.Controls.Add(this.browseButton);
			this.Controls.Add(this.label1);
			this.Controls.Add(this.panel1);
			this.Controls.Add(this.cancelButton);
			this.Controls.Add(this.okButton);
			this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
			this.MaximizeBox = false;
			this.MinimizeBox = false;
			this.Name = "ExportDialog";
			this.ShowInTaskbar = false;
			this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
			this.Text = "Export icons to files...";
			this.panel1.ResumeLayout(false);
			this.panel1.PerformLayout();
			this.panel2.ResumeLayout(false);
			this.panel2.PerformLayout();
			this.ResumeLayout(false);
			this.PerformLayout();

		}

		#endregion

		private System.Windows.Forms.Button okButton;
		private System.Windows.Forms.Button cancelButton;
		private System.Windows.Forms.FolderBrowserDialog folderBrowserDialog;
		private System.Windows.Forms.Panel panel1;
		private System.Windows.Forms.RadioButton exportSelected;
		private System.Windows.Forms.RadioButton exportAll;
		private System.Windows.Forms.TextBox exportFolderTextbox;
		private System.Windows.Forms.Label label1;
		private System.Windows.Forms.Button browseButton;
		private System.Windows.Forms.ComboBox fileFormatCombo;
		private System.Windows.Forms.Label label2;
		private System.Windows.Forms.Label label3;
		private System.Windows.Forms.TextBox nameFormatTextbox;
		private System.Windows.Forms.Panel panel2;
		private System.Windows.Forms.Label label4;
		private System.Windows.Forms.Label label8;
		private System.Windows.Forms.Label label5;
	}
}