
'''******************************************************************************************************
'*		Library Name: 	QAP_GlobalFunctionLib															*
'*		Description:	Includes all the function related to application flow in various modules		*
'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
'''******************************************************************************************************


'''------------------------------------------------------------------------------------------------------

'''******************************************************************************************************
'*		Function Name: 	QAP_Launch_Login																*
'*		Description:	Launches and logins to the QAP application based on the Environment requirement	*
'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
'''******************************************************************************************************

Function QAP_Launch_Login (dtUserName,dtPassword)
	QAP_Invoke
	QAP_Login dtUserName,dtPassword
End Function

'''******************************************************************************************************
'*		Library Name: 	SetAppVars																		*
'*		Description:	Sets datarow for fetching Environment specific credentials						*
'*		Author:		Nachiketa.x.singh@Questdiagnostics.com												*
'''******************************************************************************************************	

Function SetAppVars()	
	nRowCountGlobal= DataTable.GlobalSheet.GetRowCount
	For i=1 To nRowCountGlobal
		DataTable.SetCurrentRow i
		EnvApp= DataTable.Value("Environment", Global)
		If StrComp(Trim(CStr(EnvApp)),Trim(CStr(gEnv)))=0 Then
			setDTRow i
			reporter.ReportEvent micDone, "Set Application Launch Variable Row", "Environment = "& gEnv		
			Exit For
		End If
		
		If i= nRowCountGlobal Then
			reporter.ReportEvent micFail, "Set Application Launch Variable Row; Exiting the Test",gEnv & "Environment not found"
			ExitTest 
		End If
	Next
End Function	


'''******************************************************************************************************
'*		Library Name: 	DT_UN																			*
'*		Description:	Fetches value in column DT_UN in Global sheet of datatable based on the env		*
'*		Author:		Nachiketa.x.singh@Questdiagnostics.com												*
'''******************************************************************************************************

Function DT_UN()
	DT_UN= DataTable.Value("DT_UN",Global)
End Function


'''******************************************************************************************************
'*		Function Name: 	DT_PW																			*
'*		Description:	Fetches value in column DT_PW in Global sheet of datatable based on the env		*
'*		Author:		Nachiketa.x.singh@Questdiagnostics.com												*
'''******************************************************************************************************


Function DT_PW()
	
	DT_PW= DataTable.Value("DT_PW",Global)

End Function


'''******************************************************************************************************
'*		Library Name: 	DT_ADMIN_UN																		*
'*		Description:	Fetches value in column DT_UN in Global sheet of datatable based on the env		*
'*		Author:		Nachiketa.x.singh@Questdiagnostics.com												*
'''******************************************************************************************************

Function DT_ADMIN_UN()
	
	
	DT_ADMIN_UN= DataTable.Value("DT_ADMIN_UN",Global)
	
End Function


'''******************************************************************************************************
'*		Function Name: 	DT_ADMIN_PW																		*
'*		Description:	Fetches value in column DT_ADMIN_PW in Global sheet of datatable based on the env*
'*		Author:		Nachiketa.x.singh@Questdiagnostics.com												*
'''******************************************************************************************************


Function DT_ADMIN_PW()
	
	DT_ADMIN_PW= DataTable.Value("DT_ADMIN_PW",Global)

End Function

'''******************************************************************************************************
'*		Function Name: 	DT_URL																			*
'*		Description:	Fetches value in column DT_URL in Global sheet of datatable based on the env	*
'*		Author:		Nachiketa.x.singh@Questdiagnostics.com												*
'''******************************************************************************************************

Function DT_URL()
	
	DT_URL= DataTable.Value("DT_URL",Global)

End Function

'''******************************************************************************************************
'*		Function Name: 	DT_ENV_ID																		*
'*		Description:	Fetches value in column DT_ENV_ID in Global sheet of datatable based on the env	*
'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
'''******************************************************************************************************



Function DT_ENV_ID()
	
	DT_ENV_ID= DataTable.Value("DT_ENV_ID",Global)

End Function	
	
'''******************************************************************************************************
'*		Function Name: 	QAP_Invoke																		*
'*		Description:	Invokes the Browser based on Browser type selected in framework					*
'*		Author:		Nachiketa.x.singh@Questdiagnostics.com												*
'''******************************************************************************************************
	
	
Function QAP_Invoke()
	Select Case gBrowser
		Case "Chrome"
			KillBrowser
			ChromeIncognito "chrome.exe",DT_URL

			WAIT_SYNC
			sslErrorFlag = Window("QAP").InsightObject("Advanced").Exist(0)
			UserNameAbsenceFlag=Not (Browser("QAP Main").Page("CAS – Central Authentication").WebEdit("username").Exist(0))
			
			If sslErrorFlag AND UserNameAbsenceFlag Then
				Do
					fnHandleSSLError "Proceed to"
					bLogInFlag= Browser("QAP Main").Page("CAS – Central Authentication").WebEdit("username").Exist
				Loop While bLogInFlag= False
			End If
		Case "ie"
			While Browser("creationtime:=0").Exist(0)
				Browser("creationtime:=0").close
			Wend
			SystemUtil.Run "iexplore", DT_URL
			If Browser("QAP Main").Page("title:=Certificate Error.*").Link("innertext:=Continue to this website.*").Exist(2) Then 
				Browser("QAP Main").Page("title:=Certificate Error.*").Link("innertext:=Continue to this website.*").Click
				Wait 3
			End If
		
	End Select
	

End Function


'''******************************************************************************************************
'*		Function Name: 	QAP_Login																		*
'*		Description:	Logs in to the QAP application in existing login page opened in QAP				*
'*		Author:		Nachiketa.x.singh@Questdiagnostics.com												*
'''******************************************************************************************************


Function QAP_Login(dtUserName, dtPassword)
	Wait_Sync
	Do
		Browser("QAP Main").Page("CAS – Central Authentication").WebEdit("username").Set dtUserName
		'Browser("QAP Login").Page("LoginPage").WebEdit("Username_txt").Set "singhn1"
		
		
		Browser("QAP Main").Page("CAS – Central Authentication").WebEdit("password").Set dtPassword
		'Browser("QAP Login").Page("LoginPage").WebEdit("Password_txt").Set "Quest123"
		wait 0,500
		Browser("QAP Main").Page("CAS – Central Authentication").WebButton("Login").Click
		'Browser("QAP Login").Page("LoginPage").WebButton("Login_btn").Click
		Wait_Sync
		
		
		If Browser("QAP Main").Page("CAS – Central Authentication").WebEdit("username").Exist Then
			'If Browser("QAP Login").Page("LoginPage").WebEdit("Username_txt").Exist Then
			bLogInFlag= Browser("QAP Main").Page("CAS – Central Authentication").WebEdit("username").Exist	
		End If
		
		
		
		If Browser("QAP Main").Page("CAS – Central Authentication").Link("Reset Password").Exist(0) Then
		'If Browser("QAP Login").Page("LoginPage").WebElement("Reset User Password").Exist(0) Then
		
			Browser("QAP Main").Close
			wait 2
			QAP_Invoke
			bLogInFlag= True
		
		End If

	Loop While bLogInFlag= True
End Function



'''******************************************************************************************************
'*		Function Name: 	QAP_Logout																		*
'*		Description:	Logs out of the QAP app and closes the browser									*
'*		Author:		Nachiketa.x.singh@Questdiagnostics.com												*
'''******************************************************************************************************


Function QAP_Logout()
If Browser("QAP Main").Page("title:=.*").WebElement("innertext:=Sign Out","html tag:=SPAN").Exist(0) Then
	Browser("QAP Main").Page("title:=.*").WebElement("innertext:=Sign Out","html tag:=SPAN").Click
	Wait_Sync
End If

	Browser("QAP Login").Close
End Function


'''******************************************************************************************************
'*		Function Name: 	ODI_Navigate																	*
'*		Description:	Navigates to the ODI app from QAP landing Page									*
'*		Author:		Nachiketa.x.singh@Questdiagnostics.com												*
'''******************************************************************************************************



Function ODI_Navigate
	Wait_Sync
	Select Case gEnv
			Case "QA"
					
				Browser("QAP Main").Page("QAP Landing Page").WebElement("On Demand Informatics_lnk").Click
				Wait 2
				Browser("QAP Main").Page("QAP Landing Page").WebElement("ODI_Launch Arrow_btn").Click
				Wait_Sync
				'App_Sync.ProgressbarWait
				SSLErrorHandlingOnODI
				
			Case "Staging"			
				Browser("Quannum Analytics Portal").Page("BI-Clinical Apps").WebElement("On Demand Informatics_Staging").Click
				Wait_Sync
				'App_Sync.ProgressbarWait
						
				SSLErrorHandlingOnODI
			
			Case "Prod"	
	End Select
End Function


'''******************************************************************************************************
'*		Function Name: 	SSLErrorHandlingOnODI														*
'*		Description:	Checks if Page is loaded to Report Builder in ODI if not, handles SSL Error								*
'*		Author:			Nachiketa.x.singh@Questdiagnostics.com												*
'''******************************************************************************************************




Function SSLErrorHandlingOnODI()
	
	If Not (Browser("QAP Main").Page("On Demand Informatics").Link("Report Builder").Exist(0)) Then
			Do
				fnHandleSSLError "Proceed to"			
				bLaunchFlag= Browser("QAP Main").Page("On Demand Informatics").Link("Report Builder").Exist
			Loop While bLaunchFlag= False
	End If
End Function

'''******************************************************************************************************
'*		Function Name: 	HEDIS_Lab_Report_Navigate														*
'*		Description:	Navigates to the HEDIS app from QAP landing Page								*
'*		Author:			Nachiketa.x.singh@Questdiagnostics.com												*
'''******************************************************************************************************



Function HEDIS_Lab_Report_Navigate
'	Browser("QAP Main").Page("QAP Landing Page").WebElement("HEDIS Lab Reporting_lnk").Click
'	wait 3
'	Browser("QAP Main").Page("QAP Landing Page").WebElement("HEDIS_Launch Arrow_btn").Click
'	App_Sync.ProgressbarWait
'	wait 3
'	If Browser("QAP Main").Page("Certificate Error").Link("Continue to this website_lnk").Exist(2) Then 
'		Browser("QAP Main").Page("Certificate Error").Link("Continue to this website_lnk").Click
'		wait 3
'	End If
End Function	


'''******************************************************************************************************
'*		Function Name: 	Lab_Util_Navigate																*
'*		Description:	Navigates to the LAB Util app from QAP landing Page								*
'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
'''******************************************************************************************************




Function Lab_Util_Navigate
	Wait_Sync	
	Select Case gEnv
		Case "QA"
			Browser("QAP Main").Page("QAP Landing Page").WebElement("Lab Utilization Insights_lnk").Click
			Wait 2
			Browser("QAP Main").Page("QAP Landing Page").WebElement("LabUtil_Launch Arrow_btn").Click
			Wait_Sync
			'App_Sync.ProgressbarWait
			SSLErrorHandlingOnLUI
			
		Case "Staging"
			Browser("Quannum Analytics Portal").Page("BI-Clinical Apps").WebElement("Lab Utilization Insights_Staging").Click
			Wait_Sync
			SSLErrorHandlingOnODI
		
		Case "Prod"
	End Select
End Function

'''******************************************************************************************************
'*		Function Name: 	SSLErrorHandlingOnLUI															*
'*		Description:	Handles the ssl error if available after launching LUI application					*
'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
'''******************************************************************************************************



Function SSLErrorHandlingOnLUI()
	
	If Not (Browser("QAP Main").Page("Lab Utilization Insights").Link("Utilization Details tab").Exist(0)) Then
		Do
			fnHandleSSLError "Proceed to"		
	
			bLaunchFlag= Browser("QAP Main").Page("Lab Utilization Insights").Link("Utilization Details tab").Exist
		
		Loop While bLaunchFlag= False
	
	End If
End Function

'''******************************************************************************************************
'*		Function Name: 	Population_Lab_Navigate															*
'*		Description:	Navigates to the Population app from QAP landing Page							*
'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
'''******************************************************************************************************



Function Population_Lab_Navigate	
	Browser("QAP Main").Page("QAP Landing Page").WebElement("Population Lab Insights_lnk").Click
	Wait 2
	Browser("QAP Main").Page("QAP Landing Page").WebElement("PopulationLab_Launch Arrow_btn").Click
	Wait_Sync
	
	
	fnHandleSSLError "Proceed to"
							
	
End Function


'''******************************************************************************************************
'*		Function Name: 	ODI_VerifyPage																	*
'*		Description:	Verifies the existance of ODI page after launching ODI from Landing Page		*
'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
'''******************************************************************************************************


Function ODI_VerifyPage
	Browser("QAP Main").Page("ODI Page").WebElement("Org Selection_dd").Check CheckPoint("All")
	wait 3
	Browser("QAP Main").Page("ODI Page").Link("Report Builder_tab").Click
	wait 3
	Browser("QAP Main").Page("ODI Page").WebList("exportFormat_dd").Check CheckPoint("exportFormat")
	wait 3
End Function


'''******************************************************************************************************
'*		Function Name: 	HEDIS_VerifyPage																*
'*		Description:	Verifies the existance of HEDIS page after launching  from Landing Page		*
'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
'''******************************************************************************************************

Function HEDIS_VerifyPage
'	wait 3
'	Browser("QAP Main").Page("HEDIS Lab Reporting").WebElement("Provider_dd").Check CheckPoint("HEDIS_Org_dd")
'	Browser("QAP Main").Page("HEDIS Lab Reporting").WebElement("Provider_dd").Check CheckPoint("Provider")
'	
'	Browser("QAP Main").Page("HEDIS Lab Reporting").WebButton("Filter_btn").Check CheckPoint("Filter")
'	Browser("QAP Main").Page("HEDIS Lab Reporting").Link("Diabetes Care_lnk").Check CheckPoint("Diabetes Care")
End Function


'''******************************************************************************************************
'*		Function Name: 	PupulationLabInsight_VerifyPage													*
'*		Description:	Verifies the existance of Population page after launching  from Landing Page	*
'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
'''******************************************************************************************************



Function PupulationLabInsight_VerifyPage()
	Set objSiteTitle= Browser("QAP Main").Page("Population Lab Insight").WebElement("SiteTitle")
	Set objChooseReport= Browser("QAP Main").Page("Population Lab Insight").WebElement("Choose Report")
	VerifyObjectPresence objSiteTitle,"Positive","QAP_Landing_Page_4 Population Lab Insight Page Title should be shown"
	VerifyObjectPresence objChooseReport,"Positive","QAP_Landing_Page_4 Population Lab Insight Choose Report Header should be shown"

End Function




'''******************************************************************************************************
'*		Function Name: 	Lab_Util_VerifyPage																*
'*		Description:	Verifies the existance of Lab Util page after launching ODI from Landing Page	*
'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
'''******************************************************************************************************

Function Lab_Util_VerifyPage
	wait 3
	Browser("QAP Main").Page("Lab Utilization Insights").Link("Utilization Details tab").Check CheckPoint("Utilization Details tab ck")
	Browser("QAP Main").Page("Lab Utilization Insights").WebList("View_UtilDetails_dd").Check CheckPoint("Util Details View ck")
	wait 3
	Browser("QAP Main").Page("Lab Utilization Insights").Link("Utilization Spend tab").Click
	wait 3
	Browser("QAP Main").Page("Lab Utilization Insights").WebElement("Utilization Spend Org_dd").Check CheckPoint("UtilDetails Org ck")
End Function


'''******************************************************************************************************
'*		Function Name: 	More_Info_Check																	*
'*		Description:	Verifies the existance of More Info expansion in Landing Page					*
'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
'''******************************************************************************************************



Function More_Info_Check
	Browser("QAP Main").Page("QAP Landing Page").WebElement("On Demand Informatics_lnk").Click
	wait 3
	Browser("QAP Main").Page("QAP Landing Page").WebElement("more info").Click
	wait 1	
	Browser("Quannum Analytics Portal").Page("Quannum Analytics Portal").Check CheckPoint("Quannum Analytics Portal by Quest Diagnostics")	
'	Browser("QAP Main").Page("QAP Landing Page").WebElement("HEDIS Lab Reporting_lnk").Click
'	wait 3
'	Browser("QAP Main").Page("QAP Landing Page").WebElement("more info_HEDIS").Click
'	wait 1
'	Browser("Quannum Analytics Portal").Page("Quannum Analytics Portal").Check CheckPoint("Quannum Analytics Portal by Quest Diagnostics_2")	
	
	Browser("QAP Main").Page("QAP Landing Page").WebElement("Lab Utilization Insights_lnk").Click
	wait 3
	Browser("QAP Main").Page("QAP Landing Page").WebElement("more info_LabUtil").Click
	wait 1
	Browser("Quannum Analytics Portal").Page("Quannum Analytics Portal").Check CheckPoint("Quannum Analytics Portal by Quest Diagnostics_3")
	
	Browser("QAP Main").Page("QAP Landing Page").WebElement("Population Lab Insights_lnk").Click
	wait 3
	
	Browser("QAP Main").Page("QAP Landing Page").WebElement("more info_PopLab").Click
	wait 1
	Browser("Quannum Analytics Portal").Page("Quannum Analytics Portal").Check CheckPoint("Quannum Analytics Portal by Quest Diagnostics_4")


End Function




'''******************************************************************************************************
'*		Function Name:  ClickVisibleText																*
'*		Description:	Calculates location of a parsed visible text on page and clicks on it			*
'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
'''******************************************************************************************************


Function ClickVisibleText(sText)
	l = -1
	t =  -1
	r =  -1
	b=  -1
	ClickVisibleText= 0
	Set GameRef=Window("QAP").WinObject("Chrome Legacy Window")
	If GameRef.Exist(0) Then
		result =GameRef.GetTextLocation(sText, l, t, r, b)
		If result Then
	   ' MsgBox "Text found. Coordinates:" & l & "," & t & "," & r & "," & b
			x = (l+r) / 2 
			y = (t+b) / 2
			GameRef.Click x,y,0
			ClickVisibleText= 1
		End If
	End If

End Function


'''******************************************************************************************************
'*		Function Name: 	fnHandleSSLError																*
'*		Description:	Searches for Advanced in page after SSL error and clicks on sURL				*
'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
'''******************************************************************************************************

Function fnHandleSSLError(sURL)
	If Window("QAP").InsightObject("Advanced").Exist Then
		wait 2 
		Window("QAP").InsightObject("Advanced").Click
		wait 2	
		Call ClickVisibleText(sURL)
	End If
	Wait_Sync
End Function


'''******************************************************************************************************
'*		Function Name: 	VerifyVisibleText																*
'*		Description:	Verifies existance of a parsed text in QAp app page								*
'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
'''******************************************************************************************************


Function VerifyVisibleText(sText)
	l = -1
	t =  -1
	r =  -1
	b=  -1
	VerifyVisibleText= 0
	Set GameRef=Window("QAP").WinObject("Chrome Legacy Window")
	If GameRef.Exist(0) Then
	'GameRef.highlight
		result =GameRef.GetTextLocation(sText, l, t, r, b)
		If result Then
			REPORTER.ReportEvent micPass,"Verifying Expected text on page", sText & " is found on page"
			VerifyVisibleText= 1
		Else
			REPORTER.ReportEvent micFail,"Verifying Expected text on page", sText & " is not found on page"
		End If
	End If

End Function



'''******************************************************************************************************
'*		Function Name: 	ValidateObjectAppearanceChange													*
'*		Description:	Verifies change in look of Filters after selection in Create report				*
'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
'''******************************************************************************************************



Function ValidateObjectAppearanceChange(obj,prop)
	objClass1=obj.getROProperty("class")

	obj.Click
	wait 0,800

	objClass2=obj.getROProperty("class")


	If StrComp(Trim(CStr(objClass1)),Trim(CStr(objClass2)))<> 0  Then
		reporter.ReportEvent micPass,"Parameter appearance change after selecting","Appearance of parameter changes after selection"
	Else
		reporter.ReportEvent micFail,"Parameter appearance change after selecting","Appearance of parameter doesnt change after selection"
		
	End If

End Function




'''******************************************************************************************************
'*		Function Name: 	ValidateColumnData																*
'*		Description:	verifies that each row in a parsed column (sColName) of action data sheet has 	*
'*						same parsed  data (sColValue)													*
'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
'''******************************************************************************************************




Function ValidateColumnData(sColName,sColValue)
	nRowCount=DataTable.GetSheet(Environment("ActionName")).GetRowCount

	If nRowCount=0 Then
		reporter.ReportEvent micFail,sColName & " Filter didn't return any value in the report !!!! All rows are blank","No value returned in the report and all the rows in generated report are blank"
		Exit Function
	End If


	bUnMatchingData=False	
	DataTable.SetCurrentRow(1)

	For i = 1 To nRowCount
		DataTable.SetCurrentRow(i)
		tempColValue= DataTable.Value(sColName,Environment("ActionName") )
		
		If StrComp(Trim(CStr(tempColValue)), sColValue)<> 0 Then
		
			reporter.ReportEvent micFail,"Data in column "& sColName & "is not as expected",tempColValue & "found instead of "& sColValue
			bUnMatchingData=True
			Exit Function
			
		End If
		
		
	Next

	If bUnMatchingData=False Then
		reporter.ReportEvent micPass,"***Excel Column Data Verification --Data in column "& sColName & " is  as expected",sColValue & " found"
	End If


End Function


'''******************************************************************************************************
'*		Function Name: 	ValidateDataPresenceInColumn													*
'*		Description:	To validate that a specific parsed data (sColValue) is present in parsed column
'*						(sColName) anywhere in the action data sheet												*
'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
'''******************************************************************************************************




Function ValidateDataPresenceInColumn(sColName,sColValue)
	nRowCount=DataTable.GetSheet(Environment("ActionName")).GetRowCount

	bMatchingData=False	
	DataTable.SetCurrentRow(1)

	For i = 1 To nRowCount
		DataTable.SetCurrentRow(i)
		tempColValue= DataTable.Value(sColName,Environment("ActionName") )
		
		If StrComp(Trim(CStr(tempColValue)), sColValue)= 0 Then			
			bMatchingData=True
			reporter.ReportEvent micPass,sColValue & " Data in column "& sColName & "is  Found",""
			Exit Function
			
		End If
				
	Next

	If bMatchingData=False Then
		reporter.ReportEvent micFail,sColValue & " Data in column "& sColName & "is  not Found",""
	End If


End Function










'''******************************************************************************************************
'*		Function Name: 	nExistingReports																*
'*		Description:	Returns Number of existing reports in the My Reports section					*
'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
'''******************************************************************************************************

Function nExistingReports()
	Set savedReportsLabel= Browser("QAP Main").Page("On Demand Informatics").WebElement("savedReportsLabel")
	If savedReportsLabel.Exist(0)=False Then
		nExistingReports= 0
		
	Else
		VerifyObjectPresence savedReportsLabel,"Positive","TC-MyReports-02"

		savedReportMessage= savedReportsLabel.GetROProperty("innertext")
		nSavedReport= CInt(Trim(Left(Split(savedReportMessage,"requested ")(1),2)))
		nExistingReports= nSavedReport
	End If

End Function
''''''''''''''----------------------------------------------------------------------------------------------
Class ODI_ReportBuilder
			
		Function Set_ODI_ReportName(sReportName)
			Browser("QAP Main").Page("On Demand Informatics").WebEdit("ReportName").Set sReportName
			'Browser("QAP Main").Page("On Demand Informatics").WebList("exportFormat").Select sReportFormat
		End Function

		
		Function Select_ODI_ReportFormat(sReportFormat)
			Select Case gEnv
				Case "QA"
					Browser("QAP Main").Page("On Demand Informatics").Link("ReportType").Click
					Browser("QAP Main").Page("On Demand Informatics").WebElement("class:=select2-result-label","innertext:=" & sReportFormat,"visible:=True").click
					Wait 0,800	
				Case "Staging"
					Browser("QAP Main").Page("On Demand Informatics").WebList("exportFormat").Select sReportFormat

			End Select
		End Function
		
		Function Select_ODI_OrgID()			
			Browser("QAP Main").Page("On Demand Informatics").Link("Organization_ODI").Click
			App_Sync.Wait_DrpDwnLoad
				Wait 1
				OrgIDs= Split(DataTable.Value("OrgIDs",Environment("ActionName")),"|")				
				For i=0 To UBound(OrgIDs)				
					Browser("QAP Main").Page("On Demand Informatics").WebElement("class:=filterItemText","innertext:=" & OrgIDs(i),"visible:=True").click 
					wait 0,500
				Next				
			Browser("QAP Main").Page("On Demand Informatics").Link("Organization_ODI").Click
			wait 1
		End Function

		Function SelectDateRange(DateRange)
			Select Case DateRange
				

				Case "Past7D"
				Case "CurrentM"
				Case "CurrentQ"
				Case "CurrentY"
				Case "Last12M"
					Browser("QAP Main").Page("On Demand Informatics").WebElement("lastTwelveMonths").Click
			End Select
		End Function

		Function SetQueryCriteria(FieldName,FieldValue)
			Select Case FieldName
			
				Case "Health Plan Member ID"
					Browser("QAP Main").Page("On Demand Informatics").WebEdit("memberId").Set FieldValue
				Case "Last Name"
						Browser("QAP Main").Page("On Demand Informatics").WebEdit("patientLastName").Set FieldValue
				Case "First Name"
						Browser("QAP Main").Page("On Demand Informatics").WebEdit("patientFirstName").Set FieldValue
				Case "Gender"
				Case "City"
				Case "State"
				Case "ZIP"
				Case "Phone"
				Case "DOB"
				Case "Age Range"
				
			End Select
		End Function

		Function Set_ODI_TestOrder_ResultData(FieldName,FieldValue)			
			Select Case FieldName
				Case "ICD9"
					Browser("QAP Main").Page("On Demand Informatics").WebEdit("diagCodeIn_ICD9").Set FieldValue
				Case "ICD10"
					Browser("QAP Main").Page("On Demand Informatics").WebEdit("diagCodeIn_ICD10").Set FieldValue
				Case "LOINC Code"
						Browser("QAP Main").Page("On Demand Informatics").WebEdit("loincCodeIn").Set FieldValue
				
			End Select
		End Function

		Function SelectODIFilters()
			filters= Split(DataTable.Value("sFilters",Environment("ActionName")),"|")
			
			For i=0 To UBound(filters)			
				Browser("QAP Main").Page("On Demand Informatics").WebElement("fltr_"& filters(i)).Click
				wait 0,500
			Next
			wait 1
		End Function




		'''******************************************************************************************************
		'*		Function Name: 	RunReport																		*
		'*		Description:	Clicks on Run Report and verifies if Report is successfully processed			*
		'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
		'''******************************************************************************************************


		Function RunReport(ReportNameEntered, TC)
			wait_Sync		
			Browser("QAP Main").Page("On Demand Informatics").WebButton("Run Report").Click
			App_Sync.WaitForConfirmPopup
			reporter.ReportEvent micDone, TC & " report should be created after clicking Run Report","Report should be created"
			ValidateChromeDialogText "Report has been scheduled successfully"
			Window("QAP").WinObject("Chrome Legacy Window").Type micReturn

			App_Sync.ProgressbarWait
			Wait_Sync
			App_Sync.Wait_ReportProcessLoad
			Set objReportProcessed= Browser("QAP Main").Page("On Demand Informatics").WebElement("class:=report","innertext:="& ReportNameEntered &"\(.*")
			TestProp objReportProcessed, "innertext", "SUCCESSFULLY PROCESSED",TC & " TC_Report_Builder_ODI_12 Report Progress should be shown"
		End Function




		'''******************************************************************************************************
		'*		Function Name: 	CreateReport																	*
		'*		Description:	Creates Report by Entering basic mandatory fields and calls Run Report Method	*
		'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
		'''******************************************************************************************************



		Sub CreateReport(iFormatIndex,TC)
			sReportName= Split(DataTable.Value("ReportName",Environment("ActionName")), "|")(iFormatIndex)
			sReportFormat=Split(DataTable.Value("ReportFormatSelectValue",Environment("ActionName")), "|")(iFormatIndex)
			Browser("QAP Main").Page("On Demand Informatics").Link("Report Builder").Click
			wait 1
			Set_ODI_ReportName sReportName
			Select_ODI_ReportFormat sReportFormat
			ProviderFlag= DataTable.Value("ProviderFlag",Environment("ActionName"))

			Select Case ProviderFlag
				
				Case "Y"
					Browser("QAP Main").Page("On Demand Informatics").WebElement("ProviderSpeciality_drpdwn").Click
					App_Sync.Wait_DrpDwnLoad
					Browser("QAP Main").Page("On Demand Informatics").WebElement("CARDIOLOGIST").Click
					Wait 3
					
			End Select

			SetQueryCriteria "Last Name", DataTable.Value("LastName",Environment("ActionName"))
			SetQueryCriteria "First Name", DataTable.Value("FirstName",Environment("ActionName"))
			SelectDateRange "Last12M"
			wait 2
			''Browser("QAP Main").Page("On Demand Informatics").WebRadioGroup("reportPeriod").Select "L12"


			Browser("QAP Main").Page("On Demand Informatics").WebElement("fltr_Name").Click
			wait 1

			RunReport sReportName,TC

		End Sub


End Class
''''''''''''''----------------------------------------------------------------------------------------------

Class UtilDetails_LUI

		Sub Click_UtilDetaisTab()
			Browser("QAP Main").Page("Lab Utilization Insights").Link("Utilization Details tab").Click
			Wait 1
		End Sub

		Sub Select_View()
			'''Browser("QAP Main").Page("Lab Utilization Insights").WebList("View_UtilDetails_dd").Select "Test Volume Report"
			Browser("QAP Main").Page("Lab Utilization Insights").Link("View_UtilDetails_dd").Click
			wait 1
			Browser("QAP Main").Page("Lab Utilization Insights").WebElement("View_UtilDetails_dd_Test Volume Report").Click
			wait 1
		End Sub

		Sub Select_OrgID()

			Browser("QAP Main").Page("Lab Utilization Insights").Link("Organizations_UtilDetails").Click

			App_Sync.Wait_DrpDwnLoad
				Wait 1
				OrgIDs= Split(DataTable.Value("OrgIDs",Environment("ActionName")),"|")				
				For i=0 To UBound(OrgIDs)				
					Browser("QAP Main").Page("Lab Utilization Insights").WebElement("class:=filterItemText","innertext:=" & OrgIDs(i),"visible:=True").click 
					wait 0,500
				Next				
			Browser("QAP Main").Page("Lab Utilization Insights").Link("Organizations_UtilDetails").Click

			wait 1

		End Sub

		Function SelectDateRange(DateRange)
			Select Case DateRange
				

				Case "Past7D"
				Case "CurrentM"
					Browser("QAP Main").Page("Lab Utilization Insights").WebElement("Current Month").Click
					wait 1
				Case "CurrentQ"
					Browser("QAP Main").Page("Lab Utilization Insights").WebElement("Current Quarter").Click
					wait 1
				Case "CurrentY"
				Case "Last12M"
					Browser("QAP Main").Page("Lab Utilization Insights").WebElement("Previous 12 Months").Click
					wait 1

			End Select
		End Function

		Sub ClickFilterBtn()

			Browser("QAP Main").Page("Lab Utilization Insights").WebElement("Filter_UtilDetailsBtn").Click
			App_Sync.ProgressbarWait 
		End Sub
			
	Function Click_TestCodeAggregation(BtnName)
	
	Select Case BtnName
		Case "LOINC Code"
			Browser("QAP Main").Page("Lab Utilization Insights").WebElement("TestCodeAgg_LOINC Code").Click
		Case "Order Code"
			Browser("QAP Main").Page("Lab Utilization Insights").WebElement("TestCodeAgg_Order Code").Click
		Case Else
			reporter.ReportEvent micFail,"Please write Valid Test Aggregation Criteria",""
			End Select
	End Function
		


	Function Select_SearchBy(selection)
	
		Browser("QAP Main").Page("Lab Utilization Insights").Link("SearchBy_Details_DD").Click
		Browser("QAP Main").Page("Lab Utilization Insights").WebElement("class:=select2-result-label","innertext:="& selection).click
		wait 1
		
	End Function


	Sub Click_Filter2
		Browser("QAP Main").Page("Lab Utilization Insights").Link("Filter_UD").Click
		App_Sync.ProgressbarWait
	End Sub
	
	
	Function Set_SearchByTestName_TestCode(sText)
		Browser("QAP Main").Page("Lab Utilization Insights").WebEdit("searchbyReportNameDetails").Set sText
	End Function

End Class

''''''''''''''----------------------------------------------------------------------------------------------
Class UtilSpends_LUI


	Function Click_UtilSpendTab()
	Browser("QAP Main").Page("Lab Utilization Insights").Link("Utilization Spend tab").Click
	wait 1
	End Function
	Function Select_OrgID()		
		Browser("QAP Main").Page("Lab Utilization Insights").Link("Organizations_LUI_UtilSpend").Click
		App_Sync.Wait_DrpDwnLoad
		Wait 1
		OrgIDs= Split(DataTable.Value("OrgIDs",Environment("ActionName")),"|")		
		For i=0 To UBound(OrgIDs)		
			Browser("QAP Main").Page("Lab Utilization Insights").WebElement("class:=filterItemText","innertext:=" & OrgIDs(i),"visible:=True").click 
			wait 0,500
		Next			
		Browser("QAP Main").Page("Lab Utilization Insights").Link("Organizations_LUI_UtilSpend").Click			
		wait 1
	End Function

	Function Select_View (selection)
		Browser("QAP Main").Page("Lab Utilization Insights").Link("Utilization Spend tab").Click
		wait 2
		Browser("QAP Main").Page("Lab Utilization Insights").WebList("View_Utilization Spend_dd").Select selection
	End Function

	Function Click_Filter1
		Browser("QAP Main").Page("Lab Utilization Insights").WebElement("Filter_UtilSpendTab_btn").Click
		App_Sync.ProgressbarWait
		Wait 3
	End Function

	Function Click_Filter2
		Browser("QAP Main").Page("Lab Utilization Insights").Link("Filter").Click
		App_Sync.ProgressbarWait
	End Function

	Function Select_TestName(selection)
'		Browser("QAP Main").Page("Lab Utilization Insights").WebList("TestName_fltr_UtilSpend_dd").Select selection
		Browser("QAP Main").Page("Lab Utilization Insights").Link("SearchBy_UtilSpends").Click
		Browser("QAP Main").Page("Lab Utilization Insights").WebElement("Test Name_SearchBy_UtilSpends").Click
		
		wait 1
	End Function

	Function Set_SearchBy(sText)
	
		Browser("QAP Main").Page("Lab Utilization Insights").WebEdit("searchbyReportNameSpends").Set sText
		
		Wait 0,500
	End Function
	Function Select_DateRange()
		Browser("QAP Main").Page("Lab Utilization Insights").Link("DateRange_UtilSpend").Click
		Browser("QAP Main").Page("Lab Utilization Insights").WebElement("Dec, 2015DatRangedd").Click
		wait 0,400
		Browser("QAP Main").Page("Lab Utilization Insights").WebElement("Feb, 2016DateRangedd").Click
		wait 0,400
		Browser("QAP Main").Page("Lab Utilization Insights").WebElement("Apr, 2016DateRangedd").Click
		wait 0,400
		Browser("QAP Main").Page("Lab Utilization Insights").Link("DateRange_UtilSpend").Click
		wait 0,400
	End Function


Function VerifyTable_SearchByFilter(sText)

	Set objResultTable= Browser("QAP Main").Page("Lab Utilization Insights").WebTable("Test Name_UtilSpendfltr_report")
	
	For i = 2 To objResultTable.GetROProperty("rows") 
		VerifyTable objResultTable, i,1,sText,""
	Next
End Function




		'''******************************************************************************************************
		'*		Function Name: 	ValidateReportExport															*
		'*		Description:	Verifies report export in various parsed formats, saves path and name of file   *
		'*						in respective Test case row of data sheet										*
		'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
		'''******************************************************************************************************


		Sub  ValidateReportExport(vFormat)
			Select Case vFormat					
				Case "xml"
					Wait 5
					
					xmltext= Browser("CreationTime:=1").Page("title:=Util.*").WebEdit("index:=0").GetROProperty("innertext")
					If InStr(xmltext,"xml")>0 Then
						reporter.ReportEvent micPass, "xml report generation","XML report generated successfully"
						Else
						reporter.ReportEvent micPass, "xml report generation","XML report not generated successfully"
					End If
					wait 2
					Browser("CreationTime:=1").close
					
				Case "html"
					Wait 5
					htmltext= Browser("CreationTime:=1").Page("title:=Util.*").GetROProperty("innertext")
					If InStr(htmltext,"Total No. of Records")>0 Then
						reporter.ReportEvent micPass, "html report generation","html report generated successfully"
						Else
						reporter.ReportEvent micPass, "html report generation","html report not generated successfully"
					End If
					wait 2
					Browser("title:=.* IBM Cognos Viewer").close
					wait 2
					
				Case Else
					If WaitForSaveDialog	Then
						sGeneratedReportFullName= Window("QAP_Reports").Dialog("Save As").WinEdit("File name:").GetROProperty("text")
						arrGeneratedReportFullName=Split(sGeneratedReportFullName,".")
						sGeneratedReportName=arrGeneratedReportFullName(0)
						sGeneratedReportExt=arrGeneratedReportFullName(UBound(arrGeneratedReportFullName))
						
						sGeneratedReportFullName= sGeneratedReportName & TimeStamp & "."& sGeneratedReportExt
						
						sReportLoc= QAP_Path  & "Results\Reports\" & sGeneratedReportFullName
						Window("QAP_Reports").Dialog("Save As").WinEdit("File name:").Set sReportLoc
						Window("QAP_Reports").Dialog("Save As").WinButton("Save").Click
						WaitDownload sReportLoc
						Browser("CreationTime:=1").close
								
						wait 2
						DataTable.Value("sReportFullName"& vFormat ,Environment("ActionName"))= sGeneratedReportFullName
						DataTable.Value("sReportLoc" & vFormat, Environment("ActionName"))= sReportLoc
					Else
						Browser("CreationTime:=1").close
						reporter.ReportEvent micFail, "Save dialog was not prompted",""
					End If
				

					
			End Select


		End Sub


		'''******************************************************************************************************
		'*		Function Name: 	ExportResult																	*
		'*		Description:	Exports report in parsed format in Lab UI app									*
		'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
		'''******************************************************************************************************

		Sub ExportResult(vFormat)			
			Browser("QAP Main").Page("Lab Utilization Insights").WebEdit("searchbyReportNameSpends").Set ""
			Browser("QAP Main").Page("Lab Utilization Insights").Link("Filter").Click
			wait 4
			App_Sync.ProgressbarWait
			Browser("QAP Main").Page("Lab Utilization Insights").WebElement("Export Report").Click
			wait 1
			Select Case vFormat
				Case "Excel_2007"
					'Browser("QAP Main").Page("Lab Utilization Insights").WebRadioGroup("dataFormatSpend").Select "Excel 2007 Format"
					Browser("QAP Main").Page("Lab Utilization Insights").WebRadioGroup("dataFormatSpend").Select "spreadsheetML"
					wait 1
					
				Case "Excel_2007_Data"
					'Browser("QAP Main").Page("Lab Utilization Insights").WebRadioGroup("dataFormatSpend").Select "Excel 2007 Data"
					Browser("QAP Main").Page("Lab Utilization Insights").WebRadioGroup("dataFormatSpend").Select "xlsxData"
					wait 1
					
				Case "CSV"
					Browser("QAP Main").Page("Lab Utilization Insights").WebRadioGroup("dataFormatSpend").Select "CSV"
					wait 1
					
				Case "PDF"
					Browser("QAP Main").Page("Lab Utilization Insights").WebRadioGroup("dataFormatSpend").Select "PDF"
					wait 1
					
				Case "xml"
					Browser("QAP Main").Page("Lab Utilization Insights").WebRadioGroup("dataFormatSpend").Select "XML"
					wait 1
					
				Case "html"
					Browser("QAP Main").Page("Lab Utilization Insights").WebRadioGroup("dataFormatSpend").Select "HTML"
					wait 1
					
			End Select


			Browser("QAP Main").Page("Lab Utilization Insights").WebCheckBox("ExportAllPagechkbx").Set "OFF"
			wait 1

			Browser("QAP Main").Page("Lab Utilization Insights").WebElement("Export").Click
			wait 2
			
		End Sub



End Class

Class MyReports_ODI
		'''******************************************************************************************************
		'*		Function Name: 	ReportProcessingValidation														*
		'*		Description:	Verifies if Report Processing is displayed										*
		'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
		'''******************************************************************************************************
		
		
		Function ReportProcessingValidation(TC)
			LoadFlag= Browser("QAP Main").Page("title:=.*").WebElement("class:=temp","name:=PROCESSING","text:=PROCESSING").Exist(0)
			If LoadFlag=True Then
				reporter.ReportEvent micPass, TC & " Report is being processed","Report Processing Verification"
			Else
				reporter.ReportEvent micPass, TC & " Report is not being processed","Report Processing Verification"
			End If
			CaptureScreenshot TC & " Report Processing validation"
		End Function



		'''******************************************************************************************************
		'*		Function Name: 	DeleteReport																	*
		'*		Description:	Deletes a parsed report and verifies it's absence from My reports				*
		'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
		'''******************************************************************************************************


		Function DeleteReport(ReportNameEntered,TC)
			Set ReportTodelete= Browser("QAP Main").Page("On Demand Informatics").WebElement("class:=myReportName","innertext:="&ReportNameEntered&"\(.*","visible:=True")
					
			If ReportTodelete.Exist(0) Then			
				Set objReportrow= Browser("QAP Main").Page("On Demand Informatics").WebElement("class:=report","innertext:="& ReportNameEntered &"\(.*")
				Set objDelLink= objReportrow.Link("innertext:=Delete","index:=0")
				objDelLink.Click
				wait 0,500
				Browser("QAP Main").HandleDialog micOK
				App_Sync.ProgressbarWait
				VerifyObjectPresence objReportrow,"Negative",TC
			Else
				reporter.ReportEvent micFail,ReportNameEntered & " Report is not found in report list", "report to delete not available"
				CaptureScreenshot TC & " Report validation"

			End If

		End Function



		'''******************************************************************************************************
		'*		Function Name: 	ValidateReportGeneration														*
		'*		Description:	Verifies Report generation by clicking Report Name in My Report and saves path  *
		'*						and name of file in respective Test case row of data sheet						*
		'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
		'''******************************************************************************************************


		Function ValidateReportGeneration(sReportName,vFormat,TC)
			Set objlink= Browser("QAP Main").Page("On Demand Informatics").Link("innertext:=" & sReportName, "index:=0")
			If objlink.Exist(5) Then
				objlink.highlight
				fnOpenInNewWindow objlink 
			Else
				reporter.ReportEvent micFail,sReportName & " Is not processed after waiting for 5 mins","Please Check Manually"
				ExitTest
			End If			

				Select Case vFormat							
					Case "XML"
						Wait_Sync
						Set xmlReportTab= Browser("title:="& sReportName &".*")
						If xmlReportTab.Exist(0) Then
							reporter.ReportEvent micPass,sReportName & " New Tab of xml report opened","New Tab of xml report opened"
						Else
							reporter.ReportEvent micFail,sReportName & " New Tab of xml report not opened","New Tab of xml report not opened"
						End If
						
						xmlLoadedData= Browser("QAP Login").Page("Report Page").WebEdit("xmlDataWebEdit").GetROProperty("default value")
						If InStr(xmlLoadedData,"Total No. of Records")>0 Then
							reporter.ReportEvent micPass,sReportName & " Xml is loaded successfully","Total No. of Records is found in xml"
						Else
							reporter.ReportEvent micFail,sReportName & " Xml is not loaded successfully","Total No. of Records is not found in xml"
						End If
						Browser("title:="& sReportName &".*").close
								
					Case "HTML"

						Wait_Sync
			
						Set htmlReportTab= Browser("title:="& sReportName &".*")
						If htmlReportTab.Exist(0) Then
							reporter.ReportEvent micPass,sReportName & " New Tab of html report opened","New Tab of html report opened"
						Else
							reporter.ReportEvent micFail,sReportName & " New Tab of html report not opened","New Tab of html report not opened"
						End If
						
						htmlLoadedData= Browser("QAP Login").Page("Report Page").Frame("Frame").WebElement("Total No. of Records :").GetROProperty("outertext")
						If InStr(htmlLoadedData,"Total No. of Records")>0 Then
							reporter.ReportEvent micPass,sReportName & " html is loaded successfully","Total No. of Records is found in html"
						Else
							reporter.ReportEvent micFail,sReportName & " html is not loaded successfully","Total No. of Records is not found in html"
						End If
						Browser("title:="& sReportName &".*").close


					Case "PDF"

						Wait_Sync			
						Set PDFReportTab= Browser("title:="& sReportName &".*")
						If PDFReportTab.Exist(0) Then
							reporter.ReportEvent micPass,sReportName & " New Tab of PDF report opened","New Tab of PDF report opened"
							Else
							reporter.ReportEvent micFail,sReportName & " New Tab of PDF report not opened","New Tab of PDF report not opened"
						End If
						Browser("title:="& sReportName &".*").close
								
					Case Else

						WaitForSaveDialog
						If WaitForSaveDialog	Then
							sGeneratedReportName= Window("QAP_Reports").Dialog("Save As").WinEdit("File name:").GetROProperty("text")
							sReportLoc= QAP_Path  & "Results\Reports\" & sGeneratedReportName
							Window("QAP_Reports").Dialog("Save As").WinEdit("File name:").Set sReportLoc
							Window("QAP_Reports").Dialog("Save As").WinButton("Save").Click
							WaitDownload sReportLoc
							Browser("CreationTime:=1").close
							DataTable.Value("sFullReportName",Environment("ActionName"))= sGeneratedReportName
							DataTable.Value("sReportPath", Environment("ActionName"))= sReportLoc
						Else
							Browser("CreationTime:=1").close
							reporter.ReportEvent micFail, "Save dialog was not prompted",""
						End If								
								
			End Select

		End Function
		'''******************************************************************************************************
		'*		Function Name: 	DeleteExistingReports															*
		'*		Description:	i) Deletes a pre-existing report  in My Reports if it has with same name as the *
		'*						Report name used in current test case	 										*
		'*						ii) deletes the topmost reports if 	theresn't enough space in My Reports for 	*
		'*						the reports of current test case												*
		'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
		'''******************************************************************************************************



		Function DeleteExistingReports()
			arrReportName= Split(DataTable("ReportName",Environment("ActionName")), "|")
			Browser("QAP Main").Page("On Demand Informatics").Link("My Reports").Click
			Wait_Sync
			For j=0 To UBound(arrReportName)
				
				Set objTodelete = Browser("QAP Main").Page("On Demand Informatics").WebElement("class:=myReportName","innertext:="&arrReportName(j)&"\(.*","visible:=True")
				If objTodelete.Exist(1) Then
					
					MyReports.DeleteReport arrReportName(j),""

				
				End If
				Set objTodelete=Nothing
			Next

			nExistingReportCount=nExistingReports
			NeededSpace=UBound(arrReportName)+1
			LeftSpace= 25- nExistingReportCount
			If LeftSpace <6 And NeededSpace<6 Then
				 NeededSpace= 5
			End If
			nReportToDelete= NeededSpace- LeftSpace
			If NeededSpace > LeftSpace Then
				reporter.ReportEvent micDone,LeftSpace & "Reports Space is left in My Reports", nReportToDelete & " Reports are being deleted for the test case"

				For u=nExistingReportCount To nExistingReportCount-NeededSpace+LeftSpace Step -1
					 Browser("QAP Main").Page("On Demand Informatics").Link("innertext:=Delete","index:=" & u-1).Click
					 App_Sync.WaitForConfirmPopup
					 Browser("QAP Main").HandleDialog micOK
					 App_Sync.ProgressbarWait
				Next

			End If

		End Function


		'''******************************************************************************************************
		'*		Function Name: 	DeleteAllReports																*
		'*		Description:	Deletes all the reports in My reports page										*
		'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
		'''******************************************************************************************************


		Sub DeleteAllReports
			Browser("QAP Main").Page("On Demand Informatics").Link("My Reports").Click
			Wait_Sync

			Set DeleteLink= AUT_Browser.Link("innertext:=Delete","index:=0")
			If DeleteLink.Exist(0) Then
				Do
					DeleteLink.click
					App_Sync.WaitForConfirmPopup
					Window("QAP").WinObject("Chrome Legacy Window").Type micReturn
					App_Sync.ProgressbarWait
					wait_sync				
				Loop While DeleteLink.Exist(0)=True
			End If
		End Sub

End Class

Class App_Sync_QAP
		'''******************************************************************************************************
		'*		Function Name: 	ProgressbarWait																	*
		'*		Description:	Waits till the progressbar (grey bar on the app) is loading in QAP app			*
		'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
		'''******************************************************************************************************

		Sub ProgressbarWait()
			Do
				Wait_Sync
				wait 0,500
				Set objDescProgressbar= Description.Create
				objDescProgressbar("micclass").value="WebElement"
				objDescProgressbar("class").value="ui-progressbar-value ui-widget-header ui-corner-left"
				Set Colpb= AUT_Browser.ChildObjects(objDescProgressbar)
				nPBCount= Colpb.count
				
				
			Loop While nPBCount>0
			
		End Sub


		'''******************************************************************************************************
		'*		Function Name: 	Wait_DrpDwnLoad																	*
		'*		Description:	Waits till the dropdown is fully loaded after clickin on the dropdown in QAP	*
		'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
		'''******************************************************************************************************


		Function Wait_DrpDwnLoad()
			
			Do
				wait 0,100
				LoadFlag= Browser("QAP Main").Page("title:=.*").WebElement("class:=select2-searching","innertext:=Searching\.\.\.","visible:=True").Exist(0)
				
			'	//DIV[@id="progressbar"]/DIV[1]
			Loop While LoadFlag= True
		End Function


		'''******************************************************************************************************
		'*		Function Name: 	Wait_ReportProcessLoad															*
		'*		Description:	Waits till the report in My reports is showing Processing on it					*
		'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
		'''******************************************************************************************************

		Function Wait_ReportProcessLoad()
			
			Do
				wait 0,100
				LoadFlag= Browser("QAP Main").Page("title:=.*").WebElement("class:=temp","name:=PROCESSING","text:=PROCESSING").Exist(0)
			
			Loop While LoadFlag= True
		End Function

		'''******************************************************************************************************
		'*		Function Name: 	Wait_ReportScheduleLoad															*
		'*		Description:	Waits till the report in My reports is showing Processing on it					*
		'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
		'''******************************************************************************************************

		Function Wait_ReportScheduleLoad()
			
			Do
				wait 0,100
				LoadFlag= Browser("QAP Main").Page("title:=.*").WebElement("class:=temp","name:=PROCESSING","text:=PROCESSING").Exist(0)
				
			'	//DIV[@id="progressbar"]/DIV[1]
			Loop Until LoadFlag= True
		End Function

		'''******************************************************************************************************
		'*		Function Name: 	Wait_ReportRowAdd																*
		'*		Description:	Waits till Report created in Report Builder is added in My reports 				*
		'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
		'''******************************************************************************************************

		Function Wait_ReportRowAdd(sReportName)
			
			Do
				wait 0,100
				LoadFlag= Browser("QAP Main").Page("title:=.*").WebElement("class:=report","innertext:="& sReportName &"\(.*").Exist(0)
				
			'	//DIV[@id="progressbar"]/DIV[1]
			Loop Until LoadFlag= True
		End Function

		Function WaitForConfirmPopup()
			DialogWaitCounter=1
			Do
				Wait 1	
				ChromeDialogExistFlag1= Window("QAP").InsightObject("btnChromeDialog_OK").Exist(0)
				ChromeDialogExistFlag2= Window("QAP_Reports").InsightObject("btnChromeDialog_OK").Exist(0)

				ChromeDialogExistFlag=ChromeDialogExistFlag1 OR ChromeDialogExistFlag2
				DialogWaitCounter=DialogWaitCounter+1
				If DialogWaitCounter=180 Then
					Exit Do
				End If
			Loop While ChromeDialogExistFlag=False

			Wait 2
			WaitForConfirmPopup=True
		End Function

		'''******************************************************************************************************
		'*		Function Name: 	BXLoaderWait																	*
		'*		Description:	Wait till the Loader (grey clock loader)is present in the page for Hylori Page	*
		'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
		'''******************************************************************************************************

		Sub BXLoaderWait()
			Do
				Wait_Sync
				wait 0,500
				BXLoaderLoad= Browser("QAP Main").Page("Lab Utilization Insights").Image("bx_loader").Exist(0)
			Loop While BXLoaderLoad= True
			
		End Sub

End Class


Class UtilInsights_LUI

Sub Click_UtilInsightsTab
	
	Browser("QAP Main").Page("Lab Utilization Insights").Link("Utilization Insights").Click
	App_Sync.ProgressbarWait

End Sub

Sub Click_HPylori
	
	Browser("QAP Main").Page("Lab Utilization Insights").Link("H. pylori").Click
	App_Sync.BXLoaderWait
End Sub

Function Verify_HPylori_PopupTable(sType,TC)
	''''clicks the first row of detected or not detected row and verify the column names

	Set odesc= Description.Create
	odesc("micclass").value= "WebElement"
	odesc("visible").value= True
	
	Select Case sType
		Case "Detected"
			odesc("class").value= "pyloriDetectedGraph"
		Case "Not Detected"
			odesc("class").value= "pyloriNotDetectedGraph"
		
		Case Else
			reporter.ReportEvent micFail,"***Type passed should be either Detected or Not Detected","Please enter a valid type"
	End Select
	
	CaptureScreenshot TC & " Detected and Not Detected rows existance on page"	
	
	set colobj= Browser("CreationTime:=0").Page("title:=.*").ChildObjects(odesc)
	If colobj.count>0 Then
		reporter.ReportEvent micPass, colobj.count & " rows of Data found in "&sType&" column ",""
		Else
		reporter.ReportEvent micFail, colobj.count & " rows of Data found in "&sType&" column ","No Rows assigned to User Account, Need to assign data to the user account"
		Exit Function
	End If
	
	colobj(0).click
	wait 2
	App_Sync.ProgressbarWait
	
	reporter.ReportEvent micDone,"First Row of "&sType&" column clicked",""
	CaptureScreenshot TC
	
	sExpectedColumns="Provider Last Name;Provider First Name;NPI;Patient Last Name;Patient First Name;Patient ID;DOB;Test Ordered;Result Name;Result Value;DOS"
	Set objExpTable= Browser("QAP Main").Page("Lab Utilization Insights").WebTable("column names:=" & sExpectedColumns)
	VerifyObjectPresence objExpTable,"Positive","TC_6560"
	
	CaptureScreenshot TC & " Verification of "	&sType& " popup Table"	
	
	
End Function


Sub CloseHPyloryTablePopup()
	
Browser("QAP Main").Page("Lab Utilization Insights").WebButton("close").Click
wait 2
End Sub
End Class
