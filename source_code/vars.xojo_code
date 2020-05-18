#tag Module
Protected Module vars
	#tag Property, Flags = &h0
		nbed As String = "CD3_control.bed"
	#tag EndProperty

	#tag Property, Flags = &h0
		nvcf As String = "CD3_control.vcf"
	#tag EndProperty

	#tag Property, Flags = &h0
		reference As String = "37"
	#tag EndProperty

	#tag Property, Flags = &h0
		spath As String = "/home/vision/Skrivebord/CNAplot1/Sample files"
	#tag EndProperty

	#tag Property, Flags = &h0
		tbed As String = "T-ALL_relapse.bed"
	#tag EndProperty

	#tag Property, Flags = &h0
		testmode As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		tvcf As String = """T-ALL_relapse.vcf"""
	#tag EndProperty

	#tag Property, Flags = &h0
		ufont As String = "arialbi.ttf"
	#tag EndProperty

	#tag Property, Flags = &h0
		uname As String
	#tag EndProperty


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
		#tag ViewProperty
			Name="spath"
			Visible=false
			Group="Behavior"
			InitialValue="/Users/marcus/Desktop/TestData"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="testmode"
			Visible=false
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="tbed"
			Visible=false
			Group="Behavior"
			InitialValue="T-ALL_relapse.bed"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="nbed"
			Visible=false
			Group="Behavior"
			InitialValue="CD3_control.bed"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="tvcf"
			Visible=false
			Group="Behavior"
			InitialValue="T-ALL_relapse.vcf"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="nvcf"
			Visible=false
			Group="Behavior"
			InitialValue="CD3_control.vcf"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ufont"
			Visible=false
			Group="Behavior"
			InitialValue="arialbi.ttf"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="uname"
			Visible=false
			Group="Behavior"
			InitialValue="TWFyY3VzIEhhbnNlbg=="
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="reference"
			Visible=false
			Group="Behavior"
			InitialValue="37"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
