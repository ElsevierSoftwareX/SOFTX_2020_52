#tag Class
Protected Class C
	#tag Method, Flags = &h0
		Function Binomial(n As Double, k As Double) As Double
		  Dim r As Double
		  r = Factorial(n)/(Factorial(k)*Factorial(n-k))
		  
		  If Str(r)="NaN" OR Str(r) = "Inf" Then
		    Return 0
		  Else 
		    Return r
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Chi2Test(s1 As Integer, s2 As Integer, c1 As Integer, c2 As Integer) As Double
		  Dim SumRow1 As Double = s1+s2
		  Dim SumRow2 As Double = c1+c2
		  Dim SumColumn1 As Double = s1+c1
		  Dim SumColumn2 As Double = s2+c2
		  Dim SumSumCol As Double = SumColumn1+SumColumn2
		  Dim SumSumRow As Double = SumRow1+SumRow2
		  
		  Dim hs1 As Double = (SumRow1/SumSumCol)*SumColumn1
		  Dim hs2 As Double = (SumRow1/SumSumCol)*SumColumn2
		  
		  Dim hc1 As Double = (SumRow2/SumSumCol)*SumColumn1
		  Dim hc2 As Double = (SumRow2/SumSumCol)*SumColumn2
		  
		  Dim X2 As Double =((s1-hs1)^2)/hs1+((s2-hs2)^2)/hs2+((c1-hc1)^2)/hc1+((c2-hc2)^2)/hc2
		  
		  Select Case X2
		  Case Is > 32.84125335146885
		    Return 0.00000001
		  Case Is > 28.373987362798125
		    Return 0.0000001
		  Case Is > 23.92812697687947
		    Return 0.000001
		  Case Is > 19.511420964666264
		    Return 0.00001
		  Case Is > 15.136705226623604
		    Return 0.0001
		  Case Is > 10.827566170662731
		    Return 0.001
		  Case Is > 3.841458820694125
		    Return 0.01
		  Case Is > 6.634896601021214
		    Return 0.05
		  Else
		    Return 0.1
		  End Select
		  
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CreateCBtable()
		  Var lines(), line() As String
		  Var str,sql As String
		  
		  If reference = "37" Then
		    str = Window3.TFchromo37.Value
		  Else 
		    str = Window3.TFchromo38.Value
		  End If
		  
		  If TargetLinux Then
		    lines = str.Split(EndOfLine)
		  Else
		    lines = str.Split(Chr(13))
		  End If
		  
		  
		  App.pDB.SQLExecute("CREATE TABLE chromoband (chrom VARCHAR(5), chromStart INTEGER, chromEnd INTEGER, "_
		  +"name VARCHAR(255), gieStain VARCHAR(255))")
		  
		  App.pDB.SQLExecute("CREATE INDEX ichromoband ON chromoband ( `CHROM` ASC, `chromStart` ASC, `chromEnd` ASC );")
		  
		  App.pDB.SQLExecute("BEGIN TRANSACTION")
		  For i As Integer = lines.FirstRowIndex To lines.LastRowIndex
		    line = lines(i).Split(Chr(9))
		    sql="INSERT INTO chromoband VALUES ("""+line(0)+""","""+line(1)+""","""+line(2)+""","""+Line(3)+""","""+Line(4)+""")"
		    App.pDB.SQLExecute(sql)
		    
		    
		  Next
		  App.pDB.Commit()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Factorial(n As Double) As Double
		  Dim r As Double = 1.0
		  For i As Integer = n DownTo 1
		    r = r*i
		  Next
		  
		  Return r
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FishersExact(a1 As Double, a2 As Double, b1 As Double, b2 As Double) As Double
		  
		  Dim p As Double
		  
		  If a1 < 1.0 Then a1 = a1+1
		  If a2 < 1.0 Then a2 = a2+1
		  If b1 < 1.0 Then b1 = b1+1
		  If b2 < 1.0 Then b2 = b2+1
		  
		  Dim n As Double = (a1+a2+b1+b2)
		  
		  
		  p = Binomial(a1+b1,a1)*Binomial(a2+b2,a2)/Binomial(n,a1+a2)
		  
		  Return p
		  
		  
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoadData(p As String, BED As String, BEDctrl As String, VCF As String, VCFctrl As String)
		  
		  
		  
		  Dim inMDB As New SQLiteDatabase
		  
		  If inMDB.Connect Then
		    App.pDB = inMDB
		  End If
		  
		  Dim cfu As New C
		  
		  ' Generate CytoBand table
		  cfu.CreateCBtable()
		  
		  
		  
		  p = p+"/"
		  Dim fun As New ImportFunction
		  
		  Dim f As FolderItem = New FolderItem(p+BED,FolderItem.PathTypeShell)
		  fun.ImportFile1(f, "Sample")
		  ImportWindow.ProgressBar1.Value = 2
		  ImportWindow.ProgressBar1.Invalidate
		  
		  Dim f2 As FolderItem = New FolderItem(p+BEDctrl,FolderItem.PathTypeShell)
		  fun.ImportFile1(f2, "Control")
		  ImportWindow.ProgressBar1.Value = 3
		  ImportWindow.ProgressBar1.Invalidate
		  
		  Dim f3 As FolderItem = New FolderItem(p+VCF,FolderItem.PathTypeShell)
		  fun.ImportVCF(f3, "Sample")
		  ImportWindow.ProgressBar1.Value = 4
		  ImportWindow.ProgressBar1.Invalidate
		  
		  Dim f4 As FolderItem = New FolderItem(p+VCFctrl,FolderItem.PathTypeShell)
		  ImportWindow.ProgressBar1.Value = 5
		  ImportWindow.ProgressBar1.Invalidate
		  fun.ImportVCF(f4, "Control")
		  Dim sql As String
		  sql =  "DROP TABLE IF EXISTS VAFdiff;"
		  sql = sql + "CREATE TABLE VAFdiff AS SELECT DISTINCT SampleVCF_ext2.CHROM AS CHROM, SampleVCF_ext2.POS AS POS, SampleVCF_ext2.ALT AS ALT, SampleVCF_ext2.VAF AS tVAF,ControlVCF_ext2.VAF AS nVAF, ROUND((SampleVCF_ext2.VAF-ControlVCF_ext2.VAF),2) AS VAFdiff, ROUND((ControlVCF_ext2.VAF/SampleVCF_ext2.VAF),4) AS VAFratio, SampleVCF_ext2.REFDP AS tREFDP, SampleVCF_ext2.ALT_DP AS tALTDP, ControlVCF_ext2.REFDP AS nREFDP, ControlVCF_ext2.ALT_DP AS nALTDP,"+_
		  "ROUND((CAST(SampleVCF_ext2.cov AS DOUBLE)/CAST(ControlVCF_ext2.cov AS DOUBLE)),4) AS DPratio,"+_
		  "SampleVCF_ext2.cov AS tcov, ControlVCF_ext2.cov AS ncov,"+_
		  "SampleVCF_ext2.name AS gene FROM 'SampleVCF_ext2' INNER JOIN 'ControlVCF_ext2' ON ('SampleVCF_ext2'.CHROM='ControlVCF_ext2'.CHROM AND 'SampleVCF_ext2'.POS='ControlVCF_ext2'.POS) WHERE (SampleVCF_ext2.cov > 100 AND ControlVCF_ext2.cov > 100);"
		  sql = sql + "CREATE INDEX iVAFdiff ON VAFdiff ( `CHROM` ASC, `POS` ASC, `ALT` );"
		  App.pDB.SQLExecute(sql)
		  ImportWindow.ProgressBar1.Value = 6
		  ImportWindow.ProgressBar1.Invalidate
		  sql =  "DROP TABLE IF EXISTS DPratio;"
		  sql = sql + "CREATE TABLE DPratio AS SELECT DISTINCT 'sampleBED'.chrom AS chrom, 'sampleBED'.chromStart As chromStart, 'sampleBED'.chromEnd AS chromEnd, 'sampleBED'.cov AS tgeneDP, 'controlBED'.cov AS ngeneDP, ROUND(CAST('sampleBED'.cov AS DOUBLE)/CAST((SELECT SUM('sampleBED'.cov) FROM 'sampleBED') AS DOUBLE)*1000000,4) AS tngeneDP, ROUND(CAST('controlBED'.cov AS DOUBLE)/CAST((SELECT SUM('controlBED'.cov) FROM 'controlBED') AS DOUBLE)*1000000,4) AS nngeneDP, ROUND(CAST('sampleBED'.cov AS DOUBLE)/CAST((SELECT SUM('sampleBED'.cov) FROM 'sampleBED') AS DOUBLE)*1000000,4)/ROUND(CAST('controlBED'.cov AS DOUBLE)/CAST((SELECT SUM('controlBED'.cov) FROM 'controlBED') AS DOUBLE)*1000000,4) AS DPratio, CAST((SELECT SUM('controlBED'.cov) FROM 'controlBED' ) AS DOUBLE)/CAST((SELECT SUM('sampleBED'.cov) FROM 'sampleBED') AS DOUBLE) AS factor FROM 'sampleBED' INNER JOIN 'controlBED' ON ('sampleBED'.chrom = 'controlBED'.chrom AND 'sampleBED'.chromStart = 'controlBED'.chromStart AND 'sampleBED'.chromEnd= 'controlBED'.chromEnd AND 'sampleBED'.name= 'controlBED'.name) WHERE ('sampleBED'.cov > 100 AND 'controlBED'.cov> 100) ORDER BY chrom, chromStart;"
		  sql = sql + "CREATE INDEX iDPratio ON DPratio ( `chrom` ASC, `chromStart` ASC, `chromEnd` ASC );"
		  App.pDB.SQLExecute(sql)
		  ImportWindow.ProgressBar1.Value = 7
		  ImportWindow.ProgressBar1.Invalidate
		  
		  Dim func As New C
		  func.LoadPlot(0, Val(Window1.SubTF.Text), False, Val(Window1.PopupP.Text))
		  ImportWindow.ProgressBar1.Value = 8
		  
		  Window1.Slider1.Enabled = True
		  Window1.CheckBox1.Enabled = True
		  Window1.PopupP.Enabled = True
		  Window1.SubTF.Enabled = True
		  Window1.PushButton1.Enabled = True
		  
		  Dim rs AS RecordSet
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoadPlot(chr As Integer, subtract As Double, Fisher As Boolean, pval As Double)
		  
		  
		  Dim f As New C
		  Dim sql, chromosome As String
		  
		  Dim dub, vaf As Double
		  
		  
		  dim i, m AS Integer
		  dim dataX0(-1), dataY0(-1), dataX1(-1), dataY1(-1), dataX2(-1), dataY2(-1), dataX3(-1), dataY3(-1), dataY3b(-1), dataYChi2(-1), dataYFish(-1), dataXFish(-1) as double
		  dim chromlist(-1) as Integer
		  chromlist.Append(0)
		  Dim thischr As String = ""
		  Dim compound As Double = 1.0
		  Dim lowestcompound As Double = 1.0
		  Dim rsdata, rsp, rsq As RecordSet
		  Dim centromerp, centromerq, centromerS, centromerE As Integer
		  i = 0
		  
		  If chr = 0 Then 
		    sql = "SELECT * FROM DPratio WHERE nngeneDP > 10 OR tngeneDP > 10"
		  Else
		    If chr = 23 Then 
		      chromosome = Str(chr)
		    Else
		      chromosome = Str(chr)
		      rsp= App.pDB.SQLSelect("SELECT * FROM chromoband WHERE chrom ='"+chromosome+"' AND  gieStain = 'acen' ORDER BY chromstart ASC")
		      If rsp.RecordCount >1 Then
		        centromerp=rsp.Field("chromStart").IntegerValue
		        rsp.MoveNext
		        centromerq=rsp.Field("chromEnd").IntegerValue
		        centromerS = 0
		        centromerE=0
		        
		      End If
		    End If
		    
		    
		    
		    sql = "SELECT * FROM DPratio WHERE (nngeneDP > 10 OR tngeneDP > 10) AND chrom='"+chromosome+"'"
		  End If
		  rsdata = App.pDB.SQLSelect(sql)
		  
		  If Not App.pDB.Error AND rsdata.RecordCount > 0 Then
		    
		    
		    Dim n,u, w As Integer
		    
		    
		    Dim rsdata2 As RecordSet
		    Dim SelChrom As String
		    Dim Chi As Double = 1
		    Dim Fish As Double = 1
		    If chr <> 0 AND chr <> 23 Then
		      SelChrom = " AND DPratio.CHROM = '"+Str(chr)+"'"
		    ElseIf chr = 23 Then
		      SelChrom = " AND DPratio.CHROM = '"+Str(chr)+"'"
		    Else
		      SelChrom = ""
		    End If
		    
		    
		    sql="SELECT DISTINCT VAFdiff.POS, VAFdiff.tVAF,VAFdiff.nVAF,VAFdiff.tREFDP,VAFdiff.tALTDP,VAFdiff.nREFDP,VAFdiff.nALTDP,DPratio.DPratio, DPratio.chrom FROM VAFdiff INNER JOIN DPratio ON (VAFdiff.POS >= DPratio.chromStart AND VAFdiff.POS <= DPratio.chromEnd) AND DPratio.chrom = VAFdiff.CHROM WHERE ((DPratio.nngeneDP > 10 OR DPratio.tngeneDP > 10) AND DPratio.DPratio <3)"+SelChrom+" ORDER BY CAST(DPratio.CHROM As Integer), CAST(DPratio.chromStart As Integer)"
		    
		    rsdata2 = App.pDB.SQLSelect(sql)
		    i=0
		    If Not App.pDB.Error AND rsdata2.RecordCount > 0 Then
		      While Not rsdata2.EOF
		        
		        if thischr<>rsdata2.Field("chrom").StringValue Then
		          thischr=rsdata2.Field("chrom").StringValue 
		          chromlist.Append(i)
		        End If
		        
		        vaf = Val(rsdata2.Field("tVAF").StringValue)*-1
		        dataY2.Append(vaf)
		        dataY3.Append(Val(rsdata2.Field("DPratio").StringValue)-subtract)
		        dataX2.Append(i)
		        Chi = f.Chi2Test(rsdata2.Field("tREFDP").IntegerValue,rsdata2.Field("tALTDP").IntegerValue,rsdata2.Field("nREFDP").IntegerValue,rsdata2.Field("nALTDP").IntegerValue)
		        
		        If rsdata2.Field("POS").IntegerValue > centromerp AND centromerS =0 then
		          centromerS = i
		        End If
		        
		        If rsdata2.Field("POS").IntegerValue > centromerq AND centromerE =0 then
		          centromerE = i
		        End If
		        
		        
		        If Chi <= pval Then
		          dataYChi2.Append(Chi)
		          compound = compound*pval 
		          If compound < lowestcompound Then lowestcompound = compound
		          
		          If chr > 0 AND Fisher = True Then
		            
		            Fish = f.FishersExact(rsdata2.Field("tREFDP").DoubleValue,rsdata2.Field("tALTDP").DoubleValue,rsdata2.Field("nREFDP").DoubleValue,rsdata2.Field("nALTDP").DoubleValue)
		            If Fish <=pval Then
		              dataYFish.Append(Fish)
		            Else
		              dataYFish.Append(-50)
		            End If
		            
		          End If
		        Else
		          dataYChi2.Append(-50)
		          dataYFish.Append(-50)
		          compound = 1.0
		          
		        End If
		        
		        
		        rsdata2.MoveNext
		        i = i +1 
		      Wend
		      chromlist.Append(i)
		    End If
		    dim xMark1, centromark, centromark2 as CDMarkMBS
		    
		    dim c as new CDXYChartMBS(Window1.Canvas1.Width, Window1.Canvas1.Height)
		    
		    If TargetLinux Then
		      c.setDefaultFonts(ufont,ufont,ufont,ufont)
		    End If
		    
		    Dim co As Integer = &hffcc66
		    For n=1 To chromlist.Ubound
		      If co = &hbcbcbc Then co = &hffffff Else co = &hbcbcbc
		      c.xAxis.addZone(chromlist(n-1), chromlist(n), co)
		      If chr = 0 Then 
		        If n=23 Then
		          xMark1 = c.xAxis.addMark(chromlist(n), &h000000, "", ufont, 10)
		        Else
		          xMark1 = c.xAxis.addMark(chromlist(n), &h000000, "Chr"+Str(n), ufont, 10)
		        End If
		        xMark1.setAlignment(CDXYChartMBS.kRight)
		        xMark1.setPos(3,-100)
		        xMark1.setFontAngle(45)
		      End If
		      
		    Next
		    
		    If chr> 0 Then
		      centromark = c.xAxis.addMark(centromerS, &h000000, "CENTROMER", ufont, 10)
		      centromark = c.xAxis.addMark(centromerE, &h000000, "", ufont, 10)
		    End If
		    
		    
		    Dim sum As Double
		    u = 0
		    w=0
		    
		    
		    For n=0 To dataY3.Ubound
		      sum=sum+dataY3(n)
		      u=u+1
		      If u=20 Then 
		        sum=(Round((sum/21)*100)/100)
		        
		        
		        While m < u
		          dataY3b.Append(sum)
		          m=m+1
		        Wend
		        m=0
		        w=w
		        u=0
		      End If
		    Next
		    
		    
		    
		    
		    call c.setPlotArea(65, 65, Window1.Canvas1.Width, Window1.Canvas1.height-150, -1, -1, &hc0c0c0, &hc0c0c0, -1)
		    
		    c.addLegend(50, 30, false, ufont, 13).setBackground(c.kTransparent)
		    
		    Dim titchr As String = " (All autosomes)"
		    If chr <> 0 Then titchr = " (chromosome "+Str(chr)+")"
		    
		    call c.addTitle("Copy number alteration plot"+titchr, ufont, 18)
		    
		    call c.yAxis.setTitle("Variant allele frequencies (VAF)            Read depth (DP) ratios", ufont, 12)
		    
		    call c.xAxis.setTitle("VAF/Ratio position and chromosome", ufont, 12)
		    
		    c.xAxis.setWidth(3)
		    c.yAxis.setWidth(3)
		    call c.addLineLayer(dataY3b)
		    Dim siz As Integer
		    If chr = 0 Then 
		      siz = 5
		    Else
		      siz = 8 
		    End If
		    
		    call c.addScatterLayer(dataX2, dataY3, "DPcase/DPcontrol", c.kCircleSymbol,siz,&h70990000, &h70990000)
		    call c.addScatterLayer(dataX2, dataY2, " -VAF", c.kCircleSymbol, siz,&h70000000, &h70000000)
		    If Fisher = True Then 
		      call c.addScatterLayer(dataX2, dataYFish, "Fishers Exact (VAF)", c.kSquareSymbol, siz,&h7000ffff, &h7000ffff)
		    End If
		    call c.addScatterLayer(dataX2, dataYChi2, "χ^2 (VAF)", c.kDiamondSymbol, siz,&h700000ff, &h700000ff)
		    
		    If lowestcompound < 1.0 Then
		      call c.addScatterLayer(dataX2, dataYChi2, "Lowest compound probability "+Str(lowestcompound), c.kDiamondSymbol, siz,&h700000ff, &h700000ff)
		    End If
		    
		    c.yAxis.setlinearscale(-1,2.5,0.5)
		    Window1.Canvas1.Backdrop =c.makeChartPicture
		    
		  Else
		    MsgBox("The database couldn't be opened. Error: " + App.pDB.ErrorMessage)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoadU(bin As Integer = 100)
		  Dim f As New C
		  'Dim bin As Integer = 100
		  Dim n As Integer = 1
		  Dim U, pos As String
		  
		  Dim rsdata, rsdataband As RecordSet
		  
		  
		  Window2.Listbox1.DeleteAllRows()
		  
		  If Str(Window1.Slider1.Value) = "0" OR Str(Window1.Slider1.Value) = "" Then
		    rsdata = App.pDB.SQLSelect("SELECT COUNT(*) AS Num FROM DPratio ORDER BY chrom, chromStart")
		  Else
		    rsdata = App.pDB.SQLSelect("SELECT COUNT(*) AS Num FROM DPratio WHERE chrom ='"+Str(Window1.Slider1.Value)+"'")
		    
		  End If
		  
		  While n < Ceil(rsdata.Field("Num").DoubleValue/bin)
		    
		    
		    U = Str(f.MannWhitneyU(Str(Window1.Slider1.Value), (n*bin)-bin+1, n*bin))
		    pos = Str(f.ReturnPos(Str(Window1.Slider1.Value), (n*bin)-bin+1, n*bin))
		    
		    If Str(U) <> "" AND Str(U) <> "NaN" AND pos <> "" Then
		      rsdataband = App.pDB.SQLSelect("SELECT name, gieStain FROM chromoband WHERE (chrom ='"+Str(Window1.Slider1.Value)+"' AND chromStart < '"+pos+"' AND chromEnd > '"+pos+"')  ORDER BY chromStart LIMIT 1")
		      
		      Window2.Listbox1.AddRow(Str(Window1.Slider1.Value))
		      Window2.Listbox1.Cell(Window2.Listbox1.LastIndex, 1) = pos
		      
		      Window2.Listbox1.Cell(Window2.Listbox1.LastIndex, 2) = Str(U)
		      Window2.Listbox1.Cell(Window2.Listbox1.LastIndex, 3) = c.z2p(Val(U))
		      If App.pDB.Error = False Then
		        Window2.Listbox1.Cell(Window2.Listbox1.LastIndex, 4) = rsdataband.Field("name").StringValue
		      End If
		      
		    End If
		    n=n+1
		  Wend
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MannWhitneyU(chrom As String, limitstart As Integer, limitend As Integer) As Double
		  Dim rsdata As RecordSet
		  Dim sql As String
		  Dim i As Integer = 0
		  Dim U, Wrank As Double
		  Dim Num As Double
		  Dim f As New C
		  Dim Wminus, Wplus, Wmu, Wsd, z, nNpos, nNneg As Double
		  
		  
		  App.pDB.SQLExecute("DROP TABLE IF EXISTS DPratioC")
		  App.pDB.SQLExecute("DROP TABLE IF EXISTS MannWhitneyU")
		  
		  If chrom = "" or chrom = "0" Then 
		    
		    sql= "CREATE TABLE DPratioC AS SELECT nngeneDP AS reads, 'control' AS type, * FROM DPratio WHERE  (nngeneDP > 10 OR tngeneDP > 10) LIMIT "+Str(limitstart)+", "+Str(limitend) //LIMIT 100
		    App.pDB.SQLExecute(sql)
		    
		    sql= "INSERT INTO DPratioC SELECT (tngeneDP+"+Window1.SubTF.Text+"*nngeneDP) AS reads, 'sample' AS type,* FROM DPratio WHERE (nngeneDP > 10 OR tngeneDP > 10)  LIMIT "+Str(limitstart)+", "+Str(limitend)  //LIMIT 100
		    App.pDB.SQLExecute(sql)
		  Else
		    
		    
		    sql= "CREATE TABLE DPratioC AS SELECT nngeneDP AS reads, 'control' AS type, * FROM DPratio WHERE chrom='"+chrom+"' AND (nngeneDP > 10 OR tngeneDP > 10) LIMIT "+Str(limitstart)+", "+Str(limitend) //LIMIT 100
		    App.pDB.SQLExecute(sql)
		    
		    sql= "INSERT INTO DPratioC SELECT (tngeneDP+"+Window1.SubTF.Text+"*nngeneDP) AS reads, 'sample' AS type,* FROM DPratio WHERE chrom='"+chrom+"' AND (nngeneDP > 10 OR tngeneDP > 10)  LIMIT "+Str(limitstart)+", "+Str(limitend)  //LIMIT 100
		    App.pDB.SQLExecute(sql)
		    
		  End If
		  
		  
		  
		  sql= "ALTER TABLE DPratioC ADD rank INT AUTO_INCREMENT"
		  App.pDB.SQLExecute(sql)
		  
		  
		  sql= "CREATE TABLE MannWhitneyU AS SELECT *,  ROW_NUMBER() OVER (ORDER BY reads ASC) AS Wrank FROM DPratioC"
		  rsdata = App.pDB.SQLSelect(sql)
		  
		  
		  rsdata = App.pDB.SQLSelect("SELECT COUNT(Wrank) As Num FROM MannWhitneyU WHERE type='sample'")
		  Num = rsdata.Field("Num").DoubleValue
		  
		  
		  rsdata = App.pDB.SQLSelect("SELECT SUM(Wrank) As Wsum1 FROM MannWhitneyU WHERE type='sample'")
		  U = rsdata.Field("Wsum1").DoubleValue
		  
		  
		  U = Num*Num+Num*(Num+1)/2-U
		  
		  
		  z = f.z(U, f.mu(Num),f.sd(Num))
		  
		  Return z
		  
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function mu(n As Double) As Double
		  Return n*n/2
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ReturnPos(chrom As String, limitstart As Integer, limitend As Integer) As String
		  Dim rsdata As RecordSet
		  Dim First, Last As String
		  
		  rsdata = App.pDB.SQLSelect("SELECT * FROM DPratio WHERE chrom='"+chrom+"' AND (nngeneDP > 10 AND tngeneDP > 10) ORDER BY chromStart LIMIT "+Str(limitstart)+", "+Str(limitend))
		  First = rsdata.Field("chromStart").StringValue
		  Return First
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function sd(n As Double) As Double
		  Return Sqrt((n*n*(n+n+1))/12)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function z(U As Double, mu As Double, sd As Double) As Double
		  Return Abs((U-mu)/sd)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function z2p(z As Double) As String
		  If Abs(z) > 5.73073 Then 
		    Return "p<10^-8"
		  ElseIf Abs(z) > 5.32672 Then 
		    Return "p<10^-7"
		  ElseIf Abs(z) > 4.89164 Then 
		    Return "p<10^-6"
		  ElseIf Abs(z) > 4.41717 Then 
		    Return"p<10^-5"
		  ElseIf Abs(z) > 3.89059 Then 
		    Return "p<10^-4"
		  ElseIf Abs(z) > 3.29053 Then 
		    Return "p<0.001"
		  ElseIf  Abs(z) > 2.57583 Then 
		    Return "p<0.01"
		  ElseIf  Abs(z) > 1.95996 Then 
		    Return "p<0.001"
		  Else
		    Return "Not significant"
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
