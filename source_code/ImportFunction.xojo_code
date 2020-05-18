#tag Class
Protected Class ImportFunction
	#tag Method, Flags = &h0
		Sub ImportFile1(f As FolderItem, name As String)
		  
		  
		  Dim txt As TextInputStream =TextInputStream.Open(f)
		  
		  Dim Line(), sql As String
		  txt.Encoding=Encodings.UTF8
		  'If App.pDB.Connect Then
		  name = name + "BED"
		  App.pDB.SQLExecute("CREATE TABLE "+name+" (chrom VARCHAR(5), chromStart INTEGER, chromEnd INTEGER, name VARCHAR(255), cov INTEGER)")
		  
		  
		  App.pDB.SQLExecute("BEGIN TRANSACTION")
		  While Not txt.EOF
		    Line = txt.ReadLine.Split(Chr(9))
		    sql = "INSERT INTO "+name+" VALUES ("""+ReplaceAll(Line(0),"chr","")+""","+Line(1)+","+Line(2)+","""+Line(3)+""","+Line(4)+")"
		    
		    App.pDB.SQLExecute(sql)
		  Wend
		  App.pDB.Commit()
		  
		  
		  App.pDB.SQLExecute("DELETE FROM "+name+" WHERE rowid NOT IN (SELECT MIN(rowid) FROM "+name+" GROUP BY name)")
		  
		  
		  'App.pDB = inMDB
		  'SaveDB(inMDB)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ImportVCF(f As FolderItem, m As String)
		  
		  
		  Dim txt As TextInputStream =TextInputStream.Open(f)
		  
		  Dim Line(), sql, name As String
		  name = m+"VCF"
		  txt.Encoding=Encodings.UTF8
		  'If App.pDB.Connect Then
		  App.pDB.SQLExecute("CREATE TABLE "+name+" (CHROM VARCHAR(5), POS INTEGER, ID VARCHAR(255), REF VARCHAR(255), ALT VARCHAR(255), QUAL VARCHAR(255), FILTER VARCHAR(255), INFO VARCHAR(255), FORMAT VARCHAR(255), SAMPLE VARCHAR(255))")
		  'MsgBox App.pDB.ErrorMessage
		  
		  App.pDB.SQLExecute("BEGIN TRANSACTION")
		  While Not txt.EOF
		    Line = txt.ReadLine.Split(Chr(9))
		    If Line.Ubound > 8 Then
		      sql = "INSERT INTO "+name+" VALUES ("""+ReplaceAll(Line(0),"chr","")+""","""+Line(1)+""","""+Line(2)+""","""+Line(3)+""","""+Line(4)+""","""+Line(5)+""","""+Line(6)+""","""+Line(7)+""","""+Line(8)+""","""+Line(9)+""")"
		      
		      App.pDB.SQLExecute(sql)
		    End If
		  Wend
		  App.pDB.Commit()
		  
		  
		  sql = "DROP TABLE IF EXISTS "+name+"_ext;"
		  sql = sql + "CREATE TABLE "+name+"_ext AS SELECT *, substr(AlleleDP,0,instr(AlleleDP,',')) as REFDP, substr(AlleleDP,instr(AlleleDP,',')+1) as ALT_DP, (substr(AlleleDP,instr(AlleleDP,',')+1)+substr(AlleleDP,0,instr(AlleleDP,','))) AS DP, ROUND(CAST(CAST(substr(AlleleDP,instr(AlleleDP,',')+1) AS DOUBLE)/CAST((substr(AlleleDP,instr(AlleleDP,',')+1)+substr(AlleleDP,0,instr(AlleleDP,','))) AS DOUBLE) AS DOUBLE),2) AS VAF FROM (SELECT *, substr(SAMPLE,instr(SAMPLE,':')+1,Instr(substr(SAMPLE,instr(SAMPLE,':')+1),':')-1) AS AlleleDP FROM '"+name+"' ORDER BY CHROM, POS);"
		  sql = sql + "CREATE INDEX i"+name+"_ext ON "+name+" ( `CHROM` ASC, `POS` ASC, `ALT` );"
		  App.pDB.SQLExecute(sql)
		  
		  sql = "DROP TABLE IF EXISTS "+name+"_ext2;"
		  sql = sql + "CREATE TABLE "+name+"_ext2 AS SELECT * FROM '"+name+"_ext' INNER JOIN '"+m+"BED' ON ('"+name+"_ext'.CHROM = '"+m+"BED'.chrom AND '"+name+"_ext'.POS>='"+m+"BED'.chromStart AND  '"+name+"_ext'.POS<='"+m+"BED'.chromEnd);"
		  sql = sql + "CREATE INDEX i"+name+"_ext2 ON "+name+"_ext2 ( `CHROM` ASC, `POS` ASC, `ALT` );"
		  App.pDB.SQLExecute(sql)
		  
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SaveDB(db As SQLiteDatabase)
		  
		  
		  Dim backupDBFile As FolderItem = GetSaveFolderItem("", "backup.sqlite")
		  If backupDBFile <> Nil Then
		    Dim backupDB As New SQLiteDatabase
		    backupDB.DatabaseFile = backupDBFile
		    If backupDB.CreateDatabaseFile Then
		      
		      db.Backup(backupDB, Nil, -1)
		      MsgBox("Backup finished!")
		    End If
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SaveFolderItem() As Boolean
		  
		  Dim f As FolderItem = GetOpenFolderItem("text/plain")
		  If f <> Nil Then
		    Dim txt As TextInputStream =TextInputStream.Open(f)
		    txt.Encoding=Encodings.UTF8
		    
		    MsgBox txt.ReadAll
		    txt.Close
		    Return True
		  Else
		    MsgBox "Open failed"
		    Return False
		  End If
		End Function
	#tag EndMethod


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
