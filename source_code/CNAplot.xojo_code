#tag Class
Protected Class CNAplot
Inherits Application
	#tag Event
		Sub Open()
		  If TargetLinux Then
		    CDBaseChartMBS.SetFontSearchPath "/usr/share/fonts/truetype/ubuntu"
		    ufont = "Ubuntu-R.ttf"
		  End If
		  
		  
		  
		  
		  
		End Sub
	#tag EndEvent


	#tag MenuHandler
		Function About() As Boolean Handles About.Action
			WindowAbout.Show
			Return True
			
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function FileOpenFolder() As Boolean Handles FileOpenFolder.Action
			Dim dlg As New SelectFolderDialog
			
			dlg.ActionButtonCaption = "Select"
			dlg.Title = "Select folder with paired VCF and BED files (4 in total)"
			dlg.PromptText = "Select folder with paired VCF and BED files"
			dlg.InitialDirectory = SpecialFolder.Documents
			
			Dim folder As FolderItem
			folder = dlg.ShowModal
			If folder <> Nil Then
			
			Dim count As Integer  = folder.Count
			App.fPath = folder.ShellPath
			For i As Integer = 1 To count
			Dim f As FolderItem = folder.Item(i)
			ImportWindow.SampleListBox.ColumnCount= 2
			If f <> Nil Then
			If (Instr(f.Name,".vcf") > 0 OR Instr(f.Name,".bed") > 0) AND Instr(1,f.Name,".") <> 1 Then
			ImportWindow.SampleListBox.AddRow(f.Name)
			If Instr(f.Name,"control") = 0 AND Instr(f.Name,"ctrl") = 0 Then ImportWindow.SampleListBox.Selected(ImportWindow.SampleListBox.LastIndex) = True
			
			ImportWindow.SampleListBox.ColumnType(1) = ImportWindow.SampleListBox.TypeCheckbox
			If count = 4 Then
			ImportWindow.SampleListBox.CellCheck(ImportWindow.SampleListBox.LastIndex, 1) = True
			End If
			
			End If
			End If
			Next
			
			
			Return True
			
			Else
			Return False
			End If
			
			
			
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function PrintPlot() As Boolean Handles PrintPlot.Action
			'
			'dim g as graphics
			'g = openPrinterDialog(pageSetup)
			'if not (g = nil) then
			'drawToGraphics(g)
			'end if
			'
			'Return True
			
			
			Dim pic As New Picture(Window1.Canvas1.Width, Window1.Canvas1.Height, 32)
			
			Dim f As FolderItem = GetSaveFolderItem("", "file.png")
			If f <> Nil Then
			
			Window1.Canvas1.DrawInto(pic.Graphics, 0, 0)
			pic.Save(f, Picture.SaveAsPNG)
			End If
			
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function StatisticsItem() As Boolean Handles StatisticsItem.Action
			
			Return True
			
		End Function
	#tag EndMenuHandler


	#tag Property, Flags = &h0
		fPath As String
	#tag EndProperty

	#tag Property, Flags = &h0
		pDB As SQLiteDatabase
	#tag EndProperty


	#tag Constant, Name = kEditClear, Type = String, Dynamic = False, Default = \"&Delete", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"&Delete"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"&Delete"
	#tag EndConstant

	#tag Constant, Name = kFileQuit, Type = String, Dynamic = False, Default = \"&Quit", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"E&xit"
	#tag EndConstant

	#tag Constant, Name = kFileQuitShortcut, Type = String, Dynamic = False, Default = \"", Scope = Public
		#Tag Instance, Platform = Mac OS, Language = Default, Definition  = \"Cmd+Q"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"Ctrl+Q"
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="fPath"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
