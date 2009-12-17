using DecalViewCodeGenerator.Properties;

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Forms;
using System.Xml;
using System.Xml.Xsl;
using System.Xml.XPath;
using System.IO;

namespace DecalViewCodeGenerator {
	public partial class MainForm : Form {
		private const string NO_NAME = "<No Name>";
		private const string NO_TAB_NAME = "<None>";
		private readonly Font BOLD;
		private readonly Font ITALIC;
		private readonly Font BOLD_ITALIC;
		private readonly Point MAX_POINT = new Point(int.MaxValue, int.MaxValue);
		private Graphics g;

		public struct LanguageChoices {
			public const int CSharp = 0;
			public const int VB2005 = 1;
			public const int VB6 = 2;
		}

		private string currentlyLoadedView = null;
		private Dictionary<string, int> tabSortOrder = new Dictionary<string, int>();
		private Dictionary<string, Point> controlPosition = new Dictionary<string, Point>();
		private List<DataGridViewRow> removedRows = new List<DataGridViewRow>();

		public MainForm() : this(null) { }

		public MainForm(string viewName) {
			InitializeComponent();
			BOLD = new Font(itemGrid.Font, FontStyle.Bold);
			ITALIC = new Font(itemGrid.Font, FontStyle.Italic);
			BOLD_ITALIC = new Font(itemGrid.Font, FontStyle.Bold | FontStyle.Italic);
			g = Graphics.FromHwnd(Handle);

			setColWidths();
			if (viewName != null) {
				viewXmlPath.Text = viewName;
			}
			else {
				string fileName = Settings.Default.viewXmlPath;
				bool validPath;
				try { validPath = new FileInfo(fileName).Exists; }
				catch { validPath = Uri.IsWellFormedUriString(fileName, UriKind.Absolute); }
				if (validPath)
					viewXmlPath.Text = fileName;
				else
					viewXmlPath.Text = "";
			}

			exportLanguage.SelectedIndex = Settings.Default.exportLanguage;
			embeddedXmlPath.Text = Settings.Default.embeddedXmlPath;
			className.Text = Settings.Default.className;
			compactCode.Checked = Settings.Default.compactCode;
			chkHideDefaultNames.Checked = Settings.Default.hideDefaultNames;

			loadAutoComplete();
		}

		private void MainForm_Load(object sender, EventArgs e) {
			Rectangle windowBounds = Settings.Default.windowBounds;
			if (windowBounds.Width >= MinimumSize.Width && windowBounds.Height >= MinimumSize.Height) {
				Rectangle screen = Screen.GetWorkingArea(this);
				if (windowBounds.X < 0)
					windowBounds.X = 0;
				if (windowBounds.Y < 0)
					windowBounds.Y = 0;
				if (windowBounds.Width > screen.Width)
					windowBounds.Width = screen.Width;
				if (windowBounds.Height > screen.Height)
					windowBounds.Height = screen.Height;
				if (windowBounds.Right > screen.Right)
					windowBounds.X = screen.Width - windowBounds.Width;
				if (windowBounds.Bottom > screen.Bottom)
					windowBounds.Y = screen.Height - windowBounds.Height;
				Bounds = windowBounds;
			}
			WindowState = Settings.Default.windowState;
		}

		private void MainForm_FormClosing(object sender, FormClosingEventArgs e) {
			saveCurrentExportConfig();
			Settings.Default.compactCode = compactCode.Checked;
			Settings.Default.exportLanguage = exportLanguage.SelectedIndex;
			Settings.Default.hideDefaultNames = chkHideDefaultNames.Checked;
			switch (WindowState) {
				case FormWindowState.Normal:
					Settings.Default.windowBounds = Bounds;
					Settings.Default.windowState = WindowState;
					break;
				case FormWindowState.Minimized:
					Settings.Default.windowBounds = RestoreBounds;
					Settings.Default.windowState = FormWindowState.Normal;
					break;
				case FormWindowState.Maximized:
					Settings.Default.windowBounds = RestoreBounds;
					Settings.Default.windowState = WindowState;
					break;
			}
			Settings.Default.Save();
			g.Dispose();
		}

		private void browseButton_Click(object sender, EventArgs e) {
			if (openFileDialog.ShowDialog() == DialogResult.OK) {
				viewXmlPath.Text = openFileDialog.FileName;
				loadViewXml(true);
			}
		}

		private void loadButton_Click(object sender, EventArgs e) {
			loadViewXml(true);
		}

		private void itemGrid_Resize(object sender, EventArgs e) {
			setColWidths();
		}

		private void itemGrid_ColumnWidthChanged(object sender, DataGridViewColumnEventArgs e) {
			setColWidths();
		}

		private void setColWidths() {
			int sizeLeft = itemGrid.Width - 19;
			foreach (DataGridViewColumn col in itemGrid.Columns) {
				if (col != colName)
					sizeLeft -= col.Width;
			}
			if (sizeLeft < 175) { sizeLeft = 175; }
			colName.Width = sizeLeft;
		}

		private void loadViewXml(bool showErrors) {
			XmlDocument viewDoc = new XmlDocument();
			try {
				viewDoc.Load(viewXmlPath.Text);
			}
			catch (Exception ex) {
				if (showErrors)
					MessageBox.Show(ex.Message, "Failed to load view XML",
						MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
				return;
			}
			if (viewDoc.DocumentElement.Name != "view") {
				if (showErrors)
					MessageBox.Show("File is not a valid Decal View XML", "Failed to load view XML",
						MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
				return;
			}

			saveCurrentExportConfig();
			loadAutoComplete();

			XmlDocument exportConfigs = Settings.Default.exportConfigs;

			XmlElement loadViewNode = null;
			foreach (XmlElement ele in exportConfigs.DocumentElement.GetElementsByTagName("config")) {
				if (ele.GetAttribute("viewXmlPath").ToLower() == viewXmlPath.Text.ToLower()) {
					loadViewNode = ele;
					break;
				}
			}

			if (loadViewNode != null) {
				embeddedXmlPath.Text = loadViewNode.GetAttribute("embeddedXmlPath");
				className.Text = loadViewNode.GetAttribute("className");
				exportLanguage.SelectedIndex = Convert.ToInt32(loadViewNode.GetAttribute("exportLanguage"));
			}

			currentlyLoadedView = null;
			itemGrid.Rows.Clear();
			tabSortOrder.Clear();
			removedRows.Clear();
			controlPosition.Clear();
			tabSortOrder[NO_TAB_NAME] = 0;
			controlPosition[NO_NAME] = MAX_POINT;
			loadNodesRecursive(viewDoc.DocumentElement, NO_TAB_NAME, loadViewNode, 0, 0);
			itemGrid.Sort(colTabName, ListSortDirection.Ascending);
			currentlyLoadedView = viewXmlPath.Text;

			Settings.Default.viewXmlPath = viewXmlPath.Text;
			Settings.Default.Save();
			addRemoveDefaultRows(chkHideDefaultNames.Checked);
			setColWidths();
		}

		private void loadAutoComplete() {
			viewXmlPath.Items.Clear();
			XmlDocument exportConfigs = Settings.Default.exportConfigs;
			List<XmlElement> elementsToRemove = new List<XmlElement>();
			foreach (XmlElement config in exportConfigs.DocumentElement.GetElementsByTagName("config")) {
				string fileName = config.GetAttribute("viewXmlPath");
				bool keep;

				try { keep = new FileInfo(fileName).Exists; }
				catch { keep = Uri.IsWellFormedUriString(fileName, UriKind.Absolute); }

				if (keep)
					viewXmlPath.Items.Add(fileName);
				else
					elementsToRemove.Add(config);
			}
			foreach (XmlElement ele in elementsToRemove)
				ele.ParentNode.RemoveChild(ele);

			int maxWidth = 0;
			foreach (string p in viewXmlPath.Items) {
				int width = (int)Math.Ceiling(g.MeasureString(p, viewXmlPath.Font).Width);
				if (width > maxWidth)
					maxWidth = width;
			}
			if (maxWidth > 0)
				viewXmlPath.DropDownWidth = maxWidth;
		}

		private void saveCurrentExportConfig() {
			if (currentlyLoadedView == null)
				return;

			addRemoveDefaultRows(false);

			XmlDocument exportConfigs = Settings.Default.exportConfigs;
			XmlElement curView = null;
			foreach (XmlElement ele in exportConfigs.DocumentElement.GetElementsByTagName("config")) {
				if (ele.GetAttribute("viewXmlPath").ToLower() == currentlyLoadedView.ToLower()) {
					curView = ele;
					break;
				}
			}

			if (curView == null) {
				curView = (XmlElement)exportConfigs.DocumentElement.AppendChild(
					exportConfigs.CreateElement("config"));
			}
			curView.RemoveAll(); // Removes child nodes AND attributes
			curView.SetAttribute("viewXmlPath", currentlyLoadedView);
			curView.SetAttribute("embeddedXmlPath", embeddedXmlPath.Text);
			curView.SetAttribute("className", className.Text);
			curView.SetAttribute("exportLanguage", exportLanguage.SelectedIndex.ToString());

			foreach (DataGridViewRow row in itemGrid.Rows) {
				if ((string)row.Cells[colName.Index].Value != NO_NAME) {
					XmlElement curVar = (XmlElement)curView.AppendChild(exportConfigs.CreateElement("control"));
					curVar.SetAttribute("createVariable", row.Cells[colCreateVariable.Index].Value.ToString());
					curVar.SetAttribute("createEvent", row.Cells[colCreateEvent.Index].Value.ToString());
					curVar.SetAttribute("name", (string)row.Cells[colName.Index].Value);
				}
			}
		}

		private void loadNodesRecursive(XmlElement curEle, string curTab, XmlElement loadViewNode, int xOffset, int yOffset) {
			foreach (XmlElement ele in curEle.ChildNodes) {
				if (ele.Name == "control") {
					string controlType = ele.GetAttribute("progid");
					controlType = controlType.Substring(controlType.LastIndexOf('.') + 1);
					if (controlType == "FixedLayout" || controlType == "BorderLayout") {
						int xPlus = 0, yPlus = 0;
						if (ele.HasAttribute("left") && ele.HasAttribute("top")) {
							xPlus = Convert.ToInt32(ele.GetAttribute("left"));
							yPlus = Convert.ToInt32(ele.GetAttribute("top"));
						}
						loadNodesRecursive(ele, curTab, loadViewNode, xOffset + xPlus, yOffset + yPlus);
						continue;
					}
					string name = ele.HasAttribute("name") ? ele.GetAttribute("name") : "";
					if (name != "") {
						bool isNew, createVariable, createEvent;
						isNew = !loadPropertyInfo(controlType, name, loadViewNode,
							out createVariable, out createEvent);

						int newRowIndex = itemGrid.Rows.Add(isNew ? "*" : "", createVariable, createEvent,
							getResourceImage(controlType), controlType, ele.GetAttribute("name"), curTab);
						itemGrid[colTypeName.Index, newRowIndex].Style.Font = BOLD;
						if (isNew)
							itemGrid[colNew.Index, newRowIndex].ToolTipText =
								"This control is new since the last time you loaded this view XML";
						if (controlType == "StaticText") {
							itemGrid[colCreateEvent.Index, newRowIndex].Value = false;
							itemGrid[colCreateEvent.Index, newRowIndex].ReadOnly = true;
							itemGrid[colCreateEvent.Index, newRowIndex].ToolTipText =
								"StaticText controls have no useful events";
						}
						else if (controlType == "PushButton" || controlType == "Button") {
							itemGrid[colCreateVariable.Index, newRowIndex].Value = false;
						}

						if (ele.HasAttribute("left") && ele.HasAttribute("top")) {
							controlPosition[name] = new Point(
								Convert.ToInt32(ele.GetAttribute("left")) + xOffset,
								Convert.ToInt32(ele.GetAttribute("top")) + yOffset);
						}
						else {
							controlPosition[name] = MAX_POINT;
						}
					}
					else {
						int newRowIndex = itemGrid.Rows.Add("", false, false, getResourceImage(controlType),
							controlType, NO_NAME, curTab);

						itemGrid[colCreateVariable.Index, newRowIndex].ReadOnly = true;
						itemGrid[colCreateEvent.Index, newRowIndex].ReadOnly = true;

						itemGrid[colTypeName.Index, newRowIndex].Style.Font = ITALIC;
						itemGrid[colTabName.Index, newRowIndex].Style.Font = ITALIC;
						itemGrid[colName.Index, newRowIndex].Style.Font = ITALIC;
						for (int i = 0; i < itemGrid.Columns.Count; i++) {
							itemGrid[i, newRowIndex].ToolTipText =
								"This control cannot be exported because it has no name";
						}
						itemGrid.Rows[newRowIndex].DefaultCellStyle.ForeColor = Color.DarkGray;
					}
					loadNodesRecursive(ele, curTab, loadViewNode, xOffset, yOffset);
				}
				else if (ele.Name == "page") {
					string nextTab;
					if (curTab == NO_TAB_NAME)
						nextTab = ele.GetAttribute("label");
					else
						nextTab = curTab + " > " + ele.GetAttribute("label");

					tabSortOrder[nextTab] = tabSortOrder.Count;
					loadNodesRecursive(ele, nextTab, loadViewNode, 0, 0);
				}
				else {
					loadNodesRecursive(ele, curTab, loadViewNode, xOffset, yOffset);
				}
			}
		}

		private Image getResourceImage(string imageName) {
			switch (imageName) {
				case "Button":
					return Resources.Button;
				case "Checkbox":
					return Resources.Checkbox;
				case "Choice":
					return Resources.Choice;
				case "Edit":
					return Resources.Edit;
				case "Layout":
				case "FixedLayout":
				case "BorderLayout":
					return Resources.Layout;
				case "List":
					return Resources.List;
				case "Notebook":
					return Resources.Notebook;
				case "Progress":
					return Resources.Progress;
				case "PushButton":
					return Resources.PushButton;
				case "Slider":
					return Resources.Slider;
				case "StaticText":
					return Resources.StaticText;
				case "View":
					return Resources.View;
			}
			return null;
		}

		private bool loadPropertyInfo(string controlType, string name, XmlElement loadViewNode,
				out bool createVariable, out bool createEvent) {

			if (loadViewNode != null) {
				XmlElement control = loadViewNode.SelectSingleNode("control[@name=\"" + name + "\"]") as XmlElement;
				if (control != null) {
					createVariable = Convert.ToBoolean(control.GetAttribute("createVariable"));
					createEvent = Convert.ToBoolean(control.GetAttribute("createEvent"));
					return true;
				}
			}
			/*
			 * If it's not been saved, check if it matches one of the default names in 
			 * Visual Decal, and return false if so.
			 */
			createVariable = createEvent = !hasDefaultName(controlType, name);
			return false;
		}

		private bool hasDefaultName(string controlType, string name) {
			string defaultBaseName;
			switch (controlType) {
				case "Button":
				case "Checkbox":
				case "Notebook":
				case "Progress":
				case "Slider":
					defaultBaseName = controlType;
					break;
				case "Choice":
					defaultBaseName = "Combo";
					break;
				case "Edit":
					defaultBaseName = "Textbox";
					break;
				case "List":
					defaultBaseName = "Listbox";
					break;
				case "PushButton":
					defaultBaseName = "Command";
					break;
				case "StaticText":
					defaultBaseName = "Label";
					break;
				default:
					return true;
			}
			return Regex.IsMatch(name, defaultBaseName + @"\d+");
		}

		private void chkHideDefaultNames_CheckedChanged(object sender, EventArgs e) {
			addRemoveDefaultRows(chkHideDefaultNames.Checked);
			Settings.Default.hideDefaultNames = chkHideDefaultNames.Checked;
		}

		private void addRemoveDefaultRows(bool hideDefaultNames) {
			if (hideDefaultNames) {
				for (int i = 0; i < itemGrid.Rows.Count; ) {
					DataGridViewRow row = itemGrid.Rows[i];
					string name = (string)itemGrid[colName.Index, row.Index].Value;
					string typeName = (string)itemGrid[colTypeName.Index, row.Index].Value;
					if (hasDefaultName(typeName, name)) {
						itemGrid.Rows.Remove(row);
						removedRows.Add(row);
					}
					else {
						i++;
					}
				}
			}
			else {
				foreach (DataGridViewRow row in removedRows)
					itemGrid.Rows.Add(row);
				removedRows.Clear();

				if (itemGrid.SortOrder == SortOrder.Ascending)
					itemGrid.Sort(itemGrid.SortedColumn, ListSortDirection.Ascending);
				else if (itemGrid.SortOrder == SortOrder.Descending)
					itemGrid.Sort(itemGrid.SortedColumn, ListSortDirection.Descending);
			}
			setColWidths();
		}

		private void generateButton_Click(object sender, EventArgs e) {
			int numFixedVariables = 0;

			string classAndNamespace = className.Text;
			int d = classAndNamespace.LastIndexOf('.');
			if (d < 0) {
				string msg = "You must fill in the Namespace and Classname for the generated code in the form:\n"
						+ "Namespace.Classname\n"
						+ "\n"
						+ "Press OK to use the default value: 'MyPlugin.PluginCore'";
				DialogResult result = MessageBox.Show(msg, "Invalid Namespace/Classname",
					MessageBoxButtons.OKCancel, MessageBoxIcon.Warning, MessageBoxDefaultButton.Button2);
				if (result != DialogResult.OK)
					return;
				classAndNamespace = "MyPlugin.PluginCore";
				d = "MyPlugin.PluginCore".LastIndexOf('.');
			}

			string namespaze = classAndNamespace.Substring(0, d);
			if (!isValidIdentifier(namespaze, true)) {
				string msg = "'" + namespaze + "' is not a valid namespace identifier\n"
						+ "\n"
						+ "Press OK to use the default value: 'MyPlugin'";
				DialogResult result = MessageBox.Show(msg, "Invalid Namespace",
					MessageBoxButtons.OKCancel, MessageBoxIcon.Warning, MessageBoxDefaultButton.Button2);
				if (result != DialogResult.OK)
					return;
				namespaze = "MyPlugin";
			}
			string preNamespaze = namespaze;
			namespaze = createValidVarName(namespaze, exportLanguage.SelectedIndex);
			if (preNamespaze != namespaze) {
				numFixedVariables++;
				namespaze = @"\cf2\b " + namespaze + @"\cf0\b0 ";
			}

			string clazz = classAndNamespace.Substring(d + 1);
			if (!isValidIdentifier(clazz, true)) {
				string msg = "'" + clazz + "' is not a valid class name\n"
						+ "\n"
						+ "Press OK to use the default value: 'PluginCore'";
				DialogResult result = MessageBox.Show(msg, "Invalid Classname",
					MessageBoxButtons.OKCancel, MessageBoxIcon.Warning, MessageBoxDefaultButton.Button2);
				if (result != DialogResult.OK)
					return;
				clazz = "PluginCore";
			}
			string preClazz = clazz;
			clazz = createValidVarName(clazz, exportLanguage.SelectedIndex);
			if (preClazz != clazz) {
				numFixedVariables++;
				clazz = @"\cf2\b " + clazz + @"\cf0\b0 ";
			}

			StringBuilder gen = new StringBuilder();

			bool cSharp = (exportLanguage.SelectedIndex == LanguageChoices.CSharp);

			// Rich Text Format Colors
			string rtfColors = @"{\colortbl ;"		// \cf0: Black
				+ @"\red0\green0\blue255;"			// \cf1: Blue (identifiers)
				+ @"\red255\green0\blue0;"			// \cf2: Bright Red (errors)
				+ @"\red163\green21\blue21;"		// \cf3: Dark Red (strings)
				+ @"\red43\green145\blue175;"		// \cf4: Cyan (C# Classes)
				+ @"\red0\green128\blue0;"			// \cf5: Green (comments)
				+ @"\red128\green128\blue128;}";	// \cf6: Gray (documentation)

			if (cSharp) {
				gen.Append(
@"\cf1 using\cf0  System;

\cf1 using\cf0  Decal.Adapter;
\cf1 using\cf0  Decal.Adapter.Wrappers;

\cf1 namespace\cf0  " + namespaze);
				if (compactCode.Checked) {
					gen.AppendLine(" {");
				}
				else {
					gen.AppendLine();
					gen.AppendLine("{");
				}
				gen.Append(
@"	\cf6 /// <summary>
	\cf6 /// \cf5 This is a partial class definition for the plugin's main class, which 
	\cf6 /// \cf5 will be responsible for handling the view. This partial definition 
	\cf6 /// \cf5 must have the same name as the rest of the class. Also be sure that 
	\cf6 /// \cf5 all parts of this class are defined as partial classes.
	\cf6 /// </summary>\cf0 
	[\cf4 View\cf0 (\cf3 """ + embeddedXmlPath.Text + @"""\cf0 )]
	[\cf4 WireUpControlEvents\cf0 ]
	\cf1 public partial class \cf4 " + clazz + @" \cf0 : \cf4 PluginBase\cf0 ");

				if (compactCode.Checked) {
					gen.AppendLine(" {");
				}
				else {
					gen.AppendLine();
					gen.AppendLine("\t{");
				}
			}
			else { // if VB.NET
				gen.AppendLine(
@"\cf1 Imports\cf0  System

\cf1 Imports\cf0  Decal.Adapter
\cf1 Imports\cf0  Decal.Adapter.Wrappers

\cf1 Namespace\cf0  " + namespaze + @"
    \cf6 ''' <summary>
    \cf6 ''' \cf5 This is a partial class definition for the plugin's main class, which 
    \cf6 ''' \cf5 will be responsible for handling the view. This partial definition 
    \cf6 ''' \cf5 must have the same name as the rest of the class. Also be sure that 
    \cf6 ''' \cf5 all parts of this class are defined as partial classes.
    \cf6 ''' </summary>\cf0 
    <WireUpControlEvents(), View(\cf3 """ + embeddedXmlPath.Text + @"""\cf0 )> _
    \cf1 Partial Public Class \cf0 " + clazz + @"
        \cf1 Inherits \cf0 PluginBase
");
			}
			bool nbkSorted = (itemGrid.SortedColumn == colTabName);

			//
			// Variables
			//

			// For aligning definitions
			int maxCtrlNameLength = 0, maxTypeNameLength = 0;
			foreach (DataGridViewRow row in itemGrid.Rows) {
				if (((bool)row.Cells[colCreateVariable.Index].Value) == true) {
					int len;
					len = ((string)row.Cells[colName.Index].Value).Length;
					if (len > maxCtrlNameLength)
						maxCtrlNameLength = len;
					len = wrapperName((string)row.Cells[colTypeName.Index].Value).Length;
					if (len > maxTypeNameLength)
						maxTypeNameLength = len;
				}
			}
			if (maxCtrlNameLength > 22)
				maxCtrlNameLength = 22;

			string lastTabName = NO_TAB_NAME;
			string comment = cSharp ? "//" : "'";

			foreach (DataGridViewRow row in itemGrid.Rows) {
				if (((bool)row.Cells[colCreateVariable.Index].Value) == true) {

					if (nbkSorted) {
						string curTabName = (string)row.Cells[colTabName.Index].Value;
						if (curTabName != lastTabName) {
							lastTabName = curTabName;
							gen.AppendLine();
							gen.AppendLine("\\cf5 \t\t" + comment);
							gen.AppendLine("\t\t" + comment + " " + curTabName + " Tab");
							gen.AppendLine("\t\t" + comment + @"\cf0 ");
						}
					}

					string ctrlName = (string)row.Cells[colName.Index].Value;
					string varName = createValidVarName(ctrlName, exportLanguage.SelectedIndex);
					int varNameLength = varName.Length;
					if (varName != ctrlName) {
						varName = @"\cf2\b " + varName + @"\cf0\b0 ";
						numFixedVariables++;
					}
					string typeName = wrapperName((string)row.Cells[colTypeName.Index].Value);
					string paddingA, paddingB;

					string rtfCtrlRef, rtfDeclaration;
					if (cSharp) {
						rtfCtrlRef = @"[\cf4 ControlReference\cf0 (\cf3 """ + ctrlName + @"""\cf0 )]";
						rtfDeclaration = @"\cf1 private \cf4 " + typeName + @"\cf0 ";
					}
					else { // if VB.NET
						rtfCtrlRef = @"<ControlReference(\cf3 """ + ctrlName + @"""\cf0 )>";
						rtfDeclaration = @"\cf1 Private \cf0 " + varName + @" \cf1 As\cf0  " + typeName;
					}


					if (compactCode.Checked) {
						if (maxCtrlNameLength >= ctrlName.Length) {
							paddingA = new string(' ', maxCtrlNameLength - ctrlName.Length + 1);
							paddingB = new string(' ', maxTypeNameLength - typeName.Length + 1);
						}
						else {
							paddingA = " ";
							paddingB = new string(' ', Math.Max(1, maxTypeNameLength - typeName.Length
								+ maxCtrlNameLength - varNameLength + 1));
						}

						if (cSharp) {
							gen.AppendLine("\t\t" + rtfCtrlRef + paddingA + rtfDeclaration
								+ paddingB + varName + ";");
						}
						else { // if VB.NET
							gen.AppendLine("\t\t" + rtfCtrlRef + paddingA + rtfDeclaration);
						}
					}
					else {
						if (cSharp) {
							paddingA = new string(' ', Math.Max(0, maxTypeNameLength - 10));
							paddingB = new string(' ', maxTypeNameLength - typeName.Length + 1);
							gen.AppendLine("\t\t" + rtfCtrlRef);
							gen.AppendLine("\t\t" + rtfDeclaration + " " + varName + ";");
						}
						else { // if VB.NET
							gen.AppendLine("\t\t" + rtfCtrlRef + " _");
							gen.AppendLine("\t\t" + rtfDeclaration);
						}
						gen.AppendLine();
					}
				}
			}

			//
			// Events
			//

			lastTabName = NO_TAB_NAME;
			if (compactCode.Checked)
				gen.AppendLine();

			foreach (DataGridViewRow row in itemGrid.Rows) {
				if (((bool)row.Cells[colCreateEvent.Index].Value) == true) {

					if (nbkSorted) {
						string curTabName = (string)row.Cells[colTabName.Index].Value;
						if (curTabName != lastTabName) {
							lastTabName = curTabName;
							gen.AppendLine("\\cf5 \t\t" + comment);
							gen.AppendLine("\t\t" + comment + " " + curTabName + " Tab");
							gen.AppendLine("\t\t" + comment + @"\cf0 ");
						}
					}

					string ctrlName = (string)row.Cells[colName.Index].Value;
					string varName = createValidVarName(ctrlName);
					string eventName, argTypeName;
					bool hasEvent = eventInfo((string)row.Cells[colTypeName.Index].Value,
						out eventName, out argTypeName);

					if (hasEvent) {
						if (cSharp) {
							gen.AppendLine("\t\t" + @"[\cf4 ControlEvent\cf0 (\cf3 """
								+ ctrlName + @"""\cf0 , \cf3 """ + eventName + @"""\cf0 )]");
							gen.Append("\t\t" + @"\cf1 private void \cf0 " + varName + "_" + eventName
								+ @"(\cf1 object\cf0  sender, \cf4 " + argTypeName + @"\cf0  e)");
							if (compactCode.Checked) {
								gen.AppendLine(" {");
							}
							else {
								gen.AppendLine();
								gen.AppendLine("\t\t{");
							}
							gen.AppendLine("\t\t\t");
							gen.AppendLine("\t\t}");
						}
						else { // if VB.NET
							gen.AppendLine("\t\t" + @"<ControlEvent(\cf3 """
								+ ctrlName + @"""\cf0 , \cf3 """ + eventName + @"""\cf0 )> _");
							gen.AppendLine("\t\t" + @"\cf1 Private Sub \cf0 " + varName + "_" + eventName
								+ @"(\cf1 ByVal\cf0  sender \cf1 As Object\cf0 , "
								+ @"\cf1 ByVal\cf0  e \cf1 As\cf0  " + argTypeName + ")");
							gen.AppendLine("\t\t\t");
							gen.AppendLine("\t\t" + @"\cf1 End Sub\cf0 ");
						}
						gen.AppendLine();
					}
				}
			}

			if (cSharp) {
				gen.AppendLine("\t}");
				gen.Append("}");
			}
			else { // if VB.NET
				gen.AppendLine("\t\\cf1 End Class");
				gen.AppendLine("End Namespace\\cf0 ");
			}

			string message = "";
			if (numFixedVariables == 1) {
				message = "Warning: There was 1 identifier with a name that is not a valid variable name in "
					+ exportLanguage.SelectedItem.ToString()
					+ ". It was renamed to avoid compile errors, and has been written in bold red.";
			}
			else if (numFixedVariables > 1) {
				message = "Warning: There were " + numFixedVariables
					+ " identifier with names that are not valid variable names in "
					+ exportLanguage.SelectedItem.ToString()
					+ ". They were renamed to avoid compile errors, and has been written in bold red.";
			}

			gen.Replace("\t", "    ");

			// RTF Formatting
			gen.Replace("\r\n", "\\par \r\n");
			string codeText = gen.ToString();
			codeText = Regex.Replace(codeText, @"([\\{}])(?!((b0?)|(cf\d)[ \\])|(par) )", @"\$1");

			codeText = @"{\rtf1 " + rtfColors + codeText + "}";

			GeneratedCodeOutput.Show(this, codeText, true, message, exportLanguage.SelectedIndex);
		}

		private bool isValidIdentifier(string var, bool includePeriod) {
			if (var.Length == 0 || var.EndsWith(".") || var.Contains(".."))
				return false;
			string pattern = includePeriod ? @"[a-zA-Z_][\.a-zA-Z_0-9]*" : @"[a-zA-Z_][a-zA-Z_0-9]*";
			return (var == Regex.Match(var, pattern).Value);
		}

		private string createValidVarName(string var) { return createValidVarName(var, -1); }

		private string createValidVarName(string var, int language) {
			if (char.IsDigit(var[0]))
				var = "_" + var;
			var = Regex.Replace(var, @"[^a-zA-Z_0-9]", "_");

			if (language == LanguageChoices.CSharp) {
				foreach (string keyword in cSharpReservedWords) {
					if (var == keyword)
						return "@" + var;
				}
			}
			else if (language == LanguageChoices.VB2005) {
				string v = var.ToLower();
				foreach (string keyword in vb2005ReservedWords) {
					if (v == keyword)
						return "[" + var + "]";
				}
			}
			return var;
		}

		private string wrapperName(string typeName) {
			switch (typeName) {
				case "Edit":
					return "TextBoxWrapper";
				case "Checkbox":
					return "CheckBoxWrapper";
				case "StaticText":
					return "StaticWrapper";
				default:
					return typeName + "Wrapper";
			}
		}

		private bool eventInfo(string typeName, out string eventName, out string argTypeName) {
			switch (typeName) {
				case "Edit":
					eventName = "End";
					argTypeName = "TextBoxEndEventArgs";
					return true;
				case "Button":
				case "PushButton":
					eventName = "Click";
					argTypeName = "ControlEventArgs";
					return true;
				case "Checkbox":
					eventName = "Change";
					argTypeName = "CheckBoxChangeEventArgs";
					return true;
				case "Choice":
				case "Notebook":
				case "Slider":
					eventName = "Change";
					argTypeName = "IndexChangeEventArgs";
					return true;
				case "List":
					eventName = "Selected";
					argTypeName = "ListSelectEventArgs";
					return true;
				default:
					eventName = "";
					argTypeName = "";
					return false;
			}
		}

		private readonly string[] cSharpReservedWords = {
			"abstract", "as", "base", "bool", "break", "byte", "case", "catch",
			"char", "checked", "class", "const", "continue", "decimal",
			"default", "delegate", "do", "double", "else", "enum", "event",
			"explicit", "extern", "false", "finally", "fixed", "float", "for",
			"foreach", "goto", "if", "implicit", "in", "int", "interface",
			"internal", "is", "lock", "long", "namespace", "new", "null",
			"object", "operator", "out", "override", "params", "private",
			"protected", "public", "readonly", "ref", "return", "sbyte",
			"sealed", "short", "sizeof", "stackalloc", "static", "string",
			"struct", "switch", "this", "throw", "true", "try", "typeof",
			"uint", "ulong", "unchecked", "unsafe", "ushort", "using",
			"virtual", "void", "volatile", "while"};

		private readonly string[] vb2005ReservedWords = {
			"alias", "addhandler", "ansi", "as", "assembly", "auto", "binary", 
			"byref", "byval", "case", "catch", "class", "custom", "default", 
			"directcast", "each", "else", "elseif", "end", "error", "false", 
			"finally", "for", "friend", "global", "handles", "implements", 
			"in", "is", "lib", "loop", "me", "module", "mustinherit", 
			"mustoverride", "mybase", "myclass", "namespace", "narrowing", 
			"new", "next", "nothing", "notinheritable", "notoverridable", "of", 
			"off", "on", "option", "optional", "overloads", "overridable", 
			"overrides", "paramarray", "partial", "preserve", "private", 
			"protected", "public", "raiseevent", "readonly", "resume", 
			"shadows", "shared", "static", "step", "structure", "text", "then", 
			"to", "true", "trycast", "unicode", "until", "when", "while", 
			"widening", "withevents", "writeonly"};


		private void setCheckboxes(System.Collections.ICollection rowsToSet, int colToSet,
				bool check, bool nonDefaultNamesOnly) {
			foreach (DataGridViewRow row in rowsToSet) {
				if (!itemGrid[colToSet, row.Index].ReadOnly) {
					if (itemGrid[colToSet, row.Index].IsInEditMode)
						generateButton.Focus();
					if (nonDefaultNamesOnly) {
						string typeName = (string)itemGrid[colTypeName.Index, row.Index].Value;
						if (colToSet == colCreateVariable.Index
								&& (typeName == "PushButton" || typeName == "Button")) {
							itemGrid[colToSet, row.Index].Value = false;
						}
						else {
							itemGrid[colToSet, row.Index].Value = !hasDefaultName(typeName,
									(string)itemGrid[colName.Index, row.Index].Value);
						}
					}
					else {
						itemGrid[colToSet, row.Index].Value = check;
					}
				}
			}
		}

		private void enableSelectedVariables_Click(object sender, EventArgs e) {
			setCheckboxes(itemGrid.SelectedRows, colCreateVariable.Index, true, false);
		}

		private void disableSelectedVariables_Click(object sender, EventArgs e) {
			setCheckboxes(itemGrid.SelectedRows, colCreateVariable.Index, false, false);
		}

		private void enableSelectedEvents_Click(object sender, EventArgs e) {
			setCheckboxes(itemGrid.SelectedRows, colCreateEvent.Index, true, false);
		}

		private void disableSelectedEvents_Click(object sender, EventArgs e) {
			setCheckboxes(itemGrid.SelectedRows, colCreateEvent.Index, false, false);
		}

		private void enableAllVariables_Click(object sender, EventArgs e) {
			setCheckboxes(itemGrid.Rows, colCreateVariable.Index, true, false);
		}

		private void disableAllVariables_Click(object sender, EventArgs e) {
			setCheckboxes(itemGrid.Rows, colCreateVariable.Index, false, false);
		}

		private void enableAllEvents_Click(object sender, EventArgs e) {
			setCheckboxes(itemGrid.Rows, colCreateEvent.Index, true, false);
		}

		private void disableAllEvents_Click(object sender, EventArgs e) {
			setCheckboxes(itemGrid.Rows, colCreateEvent.Index, false, false);
		}

		private void resetToDefaultToolStripMenuItem_Click(object sender, EventArgs e) {
			setCheckboxes(itemGrid.Rows, colCreateVariable.Index, true, true);
			setCheckboxes(itemGrid.Rows, colCreateEvent.Index, true, true);
		}

		private void itemGrid_SortCompare(object sender, DataGridViewSortCompareEventArgs e) {
			if (e.Column == colTabName) {
				e.SortResult = tabSortOrder[(string)e.CellValue1] - tabSortOrder[(string)e.CellValue2];
				if (e.SortResult == 0) {
					string n1 = (string)itemGrid[colName.Index, e.RowIndex1].Value;
					string n2 = (string)itemGrid[colName.Index, e.RowIndex2].Value;
					Point p1 = controlPosition[n1], p2 = controlPosition[n2];
					if (p1.Y != p2.Y) {
						e.SortResult = p1.Y - p2.Y;
					}
					else {
						e.SortResult = p1.X - p2.X;
					}
					if (e.SortResult == 0) {
						e.SortResult = StringComparer.OrdinalIgnoreCase.Compare(n1, n2);
					}
				}
				e.Handled = true;
			}
		}

		private void exitToolStripMenuItem_Click(object sender, EventArgs e) {
			Application.Exit();
		}

		private void aboutToolStripMenuItem_Click(object sender, EventArgs e) {
			new AboutBox().ShowDialog();
		}

		private void launchOnlineHelpToolStripMenuItem_Click(object sender, EventArgs e) {
			System.Diagnostics.Process.Start("http://decal.acasylum.com/view_gen.php");
		}
	}
}