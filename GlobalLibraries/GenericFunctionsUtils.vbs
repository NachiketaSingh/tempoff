
'''******************************************************************************************************
'*		Library Name: 	GenericFunctionsUtils															*
'*		Description:	Includes all the function related to application flow in various modules		*
'*		Author:			Nachiketa.x.singh@Questdiagnostics.com											*
'''******************************************************************************************************





'''******************************************************************************************************
'Function Name: ChromeIncognito
'Description:	Launches Chrome incognito mode with given URL
'Arguements:	ChromePath= (chrome.exe), URL=(Url of application)
'''******************************************************************************************************
	
Function ChromeIncognito(ChromePath, URL) 'Chrome path need to be chrome.exe
Set oShell = CreateObject("wScript.shell")
oShell.AppActivate("chrome.exe")
varChrome = ChromePath &" "& "-incognito " & URL
oShell.Run varChrome

End Function


'''******************************************************************************************************
'Function Name: TimeStamp
'Description:	Returns time stamp of current time to use in string for record
'Arguements:	-NA
'''******************************************************************************************************

Function TimeStamp()
	sTimeStamp= Month(Now)&"_"&Day(Now)&"_"& Year(Now)&"_"&Hour(Time)&"_"&Minute(Time)
	TimeStamp= sTimeStamp
End Function


'''******************************************************************************************************
'Function Name: WaitDownload
'Description:	Makes the script execution wait till a file specified by the fileNamespec is downloaded completely
'Arguements:	fileNameSpec= (Full path with name extension)
'''******************************************************************************************************



Function WaitDownload(fileNameSpec)
WaitCounter=1
Dim fso
Set fso= CreateObject("Scripting.FileSystemObject")
Do
Wait 1	
WaitCounter=WaitCounter+1
If WaitCounter=300 Then
	reporter.ReportEvent micFail,"Download file not successful","File not downloaded even after waiting for 5 minutes"
	CaptureScreenshot fileNameSpec & "_file download fail"
	Set fso= Nothing
	Exit Function
End If

Loop While fso.FileExists(fileNameSpec)=False

Set fso= Nothing
reporter.ReportEvent micPass,fileNameSpec & "_ file download check","File downloaded successfully"


End Function


'''******************************************************************************************************
'Function Name: MoveReport
'Description:	Moves the downloaded report or any other file from a place to another place
'Arguements:	sFromPath= (Frome path with file name complete spec ),sToPath= (To path complete spec)
'''******************************************************************************************************





Function MoveReport(sFromPath,sToPath)
Dim fso
Set fso= CreateObject("Scripting.FileSystemObject")

If fso.FileExists(sFromPath) Then
	fso.MoveFile sFromPath,sToPath
	Set fso= Nothing
Else
	reporter.ReportEvent micFail,"There is no file available to move into destination location",""
	Set fso= Nothing
	Exit Function
End If
	
reporter.ReportEvent micDone,"Move file operation on " & sFromPath,"File moved from " & sFromPath & "---***To***--- " & sToPath


 End Function


'''******************************************************************************************************
'Function Name: CaptureScreenShot
'Description:	Captures screenshot and saves at report filder with time stamp
'Arguements:	TC= (Test case name number anything to attach with file name)
'''******************************************************************************************************


Function CaptureScreenShot(TC)

   Dim sPath
   Dim sDay
   Dim sMon
   Dim sYear
   Dim sMin
   Dim sHour
   Dim sSec
   
   ' Generate a unique number


		   Dim sLocation, sFileName

		   sLocation =  Environment.Value("ResultDir") 

		   TC= Replace( TC,"?","")
		   TC= Replace( TC,")","")
		   TC= Replace( TC,"(","")
		   TC= Replace(Replace(TC,"/","_"),"\","_")

		sFileName = TC + "_" + TimeStamp
		sPath = sLocation + sFileName + ".png"
		Desktop.CaptureBitmap sPath,True
		Reporter.ReportEvent micDone, TC & " Screenshot " , "Please Refer to below screen shot ", sPath   
			    
End Function

Function Browser_Count()
	  	wait 1
        dim objShell
        dim objShellWindows

        
		  Set descBrowser= Description.Create()
		  descBrowser("micclass").value="Browser"
		  descBrowser("application version").value="Chrome.*"
		  Set ColChildBrowser= desktop.ChildObjects(descBrowser)
		  
		  Browser_Count=descBrowser.Count
		  
End Function


Function Wait_Sync()
nBrowser_Count=Browser_Count

If nBrowser_Count>0 Then

intStartTime= 0

Do 
 		
	On Error Resume Next
	
	
	Wait 0,500
	waitCounter=0

	Do
		
		wait 0,300
		waitCounter=waitCounter+1

		If (waitCounter=1000) Then
			Exit Do
		End If
		bPageExistFlag= Browser("CreationTime:="& nBrowser_Count-1).Page("index:=0").Exist
	Loop While bPageExistFlag=  False
		

	ReadyState_Val= Browser("CreationTime:="& nBrowser_Count-1).Page("index:=0").Object.ReadyState
	sReadyState_Val=CStr(ReadyState_Val)

	    
	If   intStartTime = 600  Then
		'Print intStartTime
		Exit Do
	End If
	intStartTime= intStartTime+1
	iFinalVal= Eval(Instr(sReadyState_Val,4)>0 or Instr(sReadyState_Val,"complete")>0)

Loop  Until iFinalVal="True"


End If

Set AUT_Browser= Browser("CreationTime:="& nBrowser_Count-1)

End Function




Function VerifyObjectPresence(object,Scenario,TC)
On Error Resume Next
Select Case Scenario
	Case "Positive"
			If object.exist(0) Then
			reporter.ReportEvent micPass, TC & " Validation of object presence on page",object.ToString() & " is available on Page"
			object.highlight
			VerifyObjectPresence=1
			else
			reporter.ReportEvent micFail, TC & " Validation of object presence on page",object.ToString() & " is not available on Page"
			End If
	Case "Negative"
			If object.exist(0) Then
			reporter.ReportEvent micFail, TC & " Validation of object absence on page",object.ToString() & " is  available on Page"
			object.highlight
			
			else
			reporter.ReportEvent micPass, TC & " Validation of object absence on page",object.ToString() & " is  not available on Page"
			VerifyObjectPresence=1
End If
	
	
	
End Select
CaptureScreenshot(TC)

End Function




Function VerifyTable(objTable,nrow,ncol,skeyword,TC)
If IsObject(objTable) Then

If Instr(UCASE(objTable.getCelldata(nrow,ncol)),UCASE(skeyword))>0 Then
	reporter.ReportEvent micPass,TC & " "& nrow & " "& ncol & " cell Value validation against " & skeyword, "Value at Table= "& objTable.getCelldata(nrow,ncol)
	else
	reporter.ReportEvent micFail,TC & " "& nrow & " "& ncol & " cell Value validation against " & skeyword, "Value at Table= "& objTable.getCelldata(nrow,ncol)
	
End If
Else
Reporter.ReportEvent micFail, "Table not found on the page Please check",""
CaptureScreenshot(TC)
End If

End Function


Function ValueFromExcel(sFileNameSpec,nRow,nColumn)

Dim appExcel, objWorkBook, objSheet, columncount, rowcount

'Create the application object for excel
Set fso= CreateObject("Scripting.FileSystemObject")

If fso.FileExists(sFileNameSpec) Then
	Set appExcel = CreateObject("Excel.Application")
	'Set the workbook object by opening
	Set objWorkBook = appExcel.Workbooks.open(sFileNameSpec)
	
	'Set the Worksheet object
	Set objSheet = appExcel.ActiveWorkbook.Worksheets(1)
	
	ValueFromExcel =objSheet.cells(nRow,nColumn)
	
	
	objWorkBook.Close
	appExcel.Quit
	
else
	reporter.ReportEvent micFail,"There is no file available to open",sFileNameSpec

End If


End Function

Function ValidateValuefromExcel(sFileNameSpec,nRow,nColumn,sKeyWord)
If Not (len(sFileNameSpec)= 0) Then
	
If Instr(ValueFromExcel(sFileNameSpec,nRow,nColumn),sKeyWord)>0 Then
	reporter.ReportEvent micPass,"Validation of Value from file "& Split(sFileNameSpec,"\")(UBOUND(split(sFileNameSpec,"\"))),"Value from File= " & ValueFromExcel(sFileNameSpec,nRow,nColumn) & "_Expected value= " & sKeyWord
else
	reporter.ReportEvent micFail,"Validation of Value from file "& Split(sFileNameSpec,"\")(UBOUND(split(sFileNameSpec,"\"))),"Value from File= " & ValueFromExcel(sFileNameSpec,nRow,nColumn) & "_Expected value= " & sKeyWord
End If
	
End If	
End Function



Public Function setGlobal (par_name, par_value)
     ' Pupose: Store parameters  variable 
			
	gDATAFOLDER= QAP_Path &"Data\"
 	gPARFILENAME = gDATAFOLDER  & "QAP_Parameters.ini"

		 Dim rc
		 Extern.Declare micInteger,"WritePrivateProfileStringA", "kernel32.dll","WritePrivateProfileStringA", micString, micString, micString, micString 
		 rc = Extern.WritePrivateProfileStringA("PARAMS",par_name,par_value, gPARFILENAME ) 
		 FnReadGlobalFile
End function
		
		
Public Function  FnReadGlobalFile
   ' Pupose: To Reterive the data's from data sheet dyanmically	
		

	gDATAFOLDER= QAP_Path &"Data\"
	gPARFILENAME = gDATAFOLDER  & "QAP_Parameters.ini"

	
	Dim fArrFileLines()
	i = 0
	Set fObjFSO = CreateObject("Scripting.FileSystemObject")
	If (fObjFSO.FolderExists(gDATAFOLDER) = False) Then
		fObjFSO.CreateFolder(gDATAFOLDER)
	End If
	If fObjFSO.FileExists(gPARFILENAME)=False Then
		Exit Function
	End If
	Set fObjFile = fObjFSO.OpenTextFile(gPARFILENAME, 1)

	Do Until fObjFile.AtEndOfStream
		 Redim Preserve fArrFileLines(i)
		 fArrFileLines(i) = fObjFile.ReadLine
		 i = i + 1
	Loop
	fObjFile.Close
	For l = Ubound(fArrFileLines) to 1  Step -1
		fTempstr=split (fArrFileLines(l),"=")
		fvar= fTempstr(0)
		fval=fTempstr(1)  
		Execute fVar & "=fVal"
	Next
	
	Set fObjFSO=Nothing
End Function


Function StrngComp(Strng,SubStr,TC)
	If Instr(Strng,SubStr)>0 Then
		reporter.ReportEvent micPass,TC & " **Comparision of " & SubStr &" with " & Strng,SubStr & " matches in "& Strng
		else
		reporter.ReportEvent micFail,TC & " **Comparision of " & SubStr &" with " & Strng,SubStr & " doesn't match in "& Strng
	End If
End Function

Function TestProp(objweb,PropType,baseProp,TC)

   If IsObject(objweb) Then

	
	sActProp= Replace(objWeb.getROProperty(PropType),vbcrlf,"")

	baseProp= Replace(baseProp,chr(10),"")


	If Instr(Trim(sActProp),Trim(baseProp))>0 or strComp(Trim(sActProp),Trim(baseProp))=0 Then
		
		reporter.ReportEvent micPass, TC & "- Validation of "& PropType & "- property in  " & objType , "Application Value= " & sActProp & vbcrlf &"Expected Value = " & baseProp 
		CaptureScreenShot(TC)
	else
		reporter.ReportEvent micFail, TC & "- Validation of " & PropType & "- property in  " & objType , "Application Value= " & sActProp & vbcrlf &"Expected Value = " & baseProp
	
		CaptureScreenShot(TC)
	End If
	


	Else
	reporter.reportEvent micFail, "Object not found on the page for "& PropType &"-" & baseProp,""
	CaptureScreenShot(TC)
   End If
End Function

Function GetFullFileNamefromPart(sPartFileName,spath)
	bFileFound= False
	Set fso= CreateObject("Scripting.FileSystemObject")
		
	Set objFolder= fso.GetFolder(spath)
	Set colFiles= objFolder.Files
	
	For Each objfile in colFiles		
	If Instr(objfile.Name,sPartFileName)>0 Then
		GetFullFileNamefromPart=objfile.Name
		bFileFound= True
		Exit For
	End If
	Next
	If bFileFound=False Then
		reporter.ReportEvent micFail,"File with partName " & sPartFileName & " not found in location " &  spath,""
	End If
	
End Function
	
	

Function WaitDownloadPartFileName(spath,sPartFileName)
WaitCounter=1
Dim fso
Set fso= CreateObject("Scripting.FileSystemObject")
Do
Wait 1	
WaitCounter=WaitCounter+1
If WaitCounter=300 Then
	reporter.ReportEvent micFail,"Download file not successful","File not downloaded even after waiting for 5 minutes"
	CaptureScreenshot sPartFileName & "_file download fail"
	reporter.ReportEvent micFail,"File with partName " & sPartFileName & " not found in location " &  spath,""
	Set fso= Nothing
	Exit Function
End If

	Set objFolder= fso.GetFolder(spath)
	Set colFiles= objFolder.Files
	
	For Each objfile in colFiles		
		If Instr(objfile.Name,sPartFileName)>0 AND Not(Instr(objfile.Name,"crdownload")>0) Then
			bFileFound= True
			sFileName= objfile.Name
			Exit For
		End If
	Next

Loop until bFileFound= True

Set fso= Nothing
reporter.ReportEvent micPass,spath &sFileName& "_ file download check","File downloaded successfully"

End Function	



Sub PDFLoadWait()
	
Set WshShell = CreateObject("WScript.shell")
time_counter = 1

Do

time_counter = time_counter+1

Wait(3)
bPDF= Browser("title:=.*").GetROProperty("hwnd")

Window("hwnd:="&bPDF).activate         
   
WshShell.SendKeys "^a"                              
WshShell.SendKeys "^c"  
                             
Set clip = CreateObject("Mercury.Clipboard" )
strText = clip.GetText
clip.Clear

                  
Loop While strText <> "" OR time_counter <=10



if Instr( strText ,"Report Name:") <> 0 then

msgbox "string found"
else
msgbox "string not found"
end if

Set WshShell = Nothing
Set clip = Nothing
End Sub



Function VerifyDialogText(Text,TC)
	sVisibletext= Window("QAP").GetVisibleText
	If Instr(sVisibletext,Text)>0 Then
		
		reporter.ReportEvent micPass,TC & " Expected Text present on the dialog",Text & " available on dialog"
	
	else
		reporter.ReportEvent micFail,TC & " Expected Text present on the dialog",Text & " not available on dialog"
	End If
	
	CaptureScreenshot TC
End Function



Function openDT()

'   on error resume next

   DataTable.Import gDataFile
   DataTable.ImportSheet gDataFile, sSheetName, Environment("ActionName")
   reporter.ReportEvent micDone,"Datatable Import","Datatable Import was successful"



End Function


Sub setDTRow(RowNumber)
     
   DataTable.SetCurrentRow(RowNumber)
   reporter.ReportEvent micDone, "setDTRow","setDTRow to  = " & RowNumber
End Sub

Function SetTestDataRow(TCNum)


			nRowCountLocal= DataTable.LocalSheet.GetRowCount
			For i=1 To nRowCountLocal
			DataTable.SetCurrentRow i
			TCSheet= DataTable.Value("TC",Environment("ActionName"))

				If CInt(TCSheet)=CInt(TCNum) Then
					setDTRow i
					reporter.ReportEvent micDone, "TestCase " & TCNum &" is present at row number " & i, "In DataTable, Row number set to= " & i
			
					Exit For
				End If
			
				If i= nRowCountLocal Then
					reporter.ReportEvent micFail, "TestCase " & TCNum &" is not found in the sheet ","TestCase " & TCNum &" is not found in the sheet "& sSheetName
					setDTRow 100
				End If
			Next



End Function


Sub saveDT()

  on error resume next

'   DataTable.Export(gDataFile)
	DataTable.ExportSheet gDataFile, Environment("ActionName"), sSheetName


End Sub



Sub setDTVal(field, val)

   on error resume next
   
   If field = "" Then
     Exit Sub
   End If
   
    DataTable.Value(field, Environment("ActionName")) = val
    dim r

   If  Err.Number = -2147220907 Then ' column does not exist
      r = DataTable.localSheet.AddParameter(field, val).name
      Err.Clear   ' Clear the error.
   elseif Err.Number > 0 then
      
      Err.Clear   ' Clear the error.
   End If

   DataTable.Export(gDataFile)
   if err.number = 53 then
     
      Err.Clear   ' Clear the error.
   end If

End Sub




Function getMostRepeatedValueFromExcel(ExcelPath,sSheetName,nRowStart,nCol)

Dim objexcel, objWorkbook, objDriverSheet, columncount, rowcount
set objexcel = Createobject("Excel.Application")
Set objWorkbook = objExcel.WorkBooks.Open(ExcelPath)
Set objDriverSheet = objWorkbook.Worksheets(sSheetName)
'columncount = objDriverSheet.usedrange.columns.count
rowcount = objDriverSheet.UsedRange.SpecialCells(11).Row

if rowcount > 100 Then
rowcount=100
End If


Set dictValues = CreateObject("Scripting.Dictionary")

Dim MostKey
intHighest = -1

for i=nRowStart to rowcount
    sKey= objDriversheet.cells(i,nCol)
    
        if dictValues.Exists(sKey) Then
            dictValues.Item(sKey) = cStr(cInt(dictValues.Item(sKey)) + 1)
        else
            dictValues.Add sKey, "1"
        end if
        if cInt(dictValues.Item(sKey)) > intHighest Then
            intHighest = CInt(dictValues.Item(sKey))
            MostKey = sKey
        end if
   
Next

objWorkbook.Save
objWorkbook.Close
objExcel.Quit
Set objExcel = Nothing

getMostRepeatedValueFromExcel= MostKey

End Function





Function CheckEmail(sReportName)
bFolderFound= False
bMailFound=False
Set olApp=CreateObject("Outlook.Application") 
Set olns=olApp.GetNameSpace("MAPI") 

Set objFolderCol=olns.Folders
nFolderCount= objFolderCol.Count

For i = 1 To nFolderCount

	 If Instr(objFolderCol(i).Name, "@questdiagnostics")>0 Then
	 	Set EmailAccountFolder= objFolderCol(i)
	 	Exit For
	 End If
Next

Set objEmailAccountSubFolder= EmailAccountFolder.Folders
nEmailAccountSubFolderCount= objEmailAccountSubFolder.Count

For j = 1 To nEmailAccountSubFolderCount
'msgbox objEmailAccountSubFolder(j).name
	 If Instr(objEmailAccountSubFolder(j).Name, "QAP Reports")>0 Then
	 	Set QAPReportFolder= objEmailAccountSubFolder(j)
	 		bFolderFound= True
	 		reporter.ReportEvent micDone, "QAP Repprts folder found in outlook",""
	 	Exit For
	 End If

Next
If bFolderFound=False Then
	reporter.ReportEvent micWarning, "QAP Reports folder under Quest Email Account is not found", "Please check manually"
	Exit FUnction
End If

For each item1 in QAPReportFolder.Items 

  
          sSubject = item1.subject 
          If Instr(sSubject,"Report Status Update") Then
          		objBody= item1.Body 
          		If Instr(objBody,sReportName) Then
          			reporter.ReportEvent micPass,"verification of Email notification for report generation", "Email triggered with report link"
					bMailFound=True
          		End If
          End If
          


Next 

If bMailFound=False Then
	reporter.ReportEvent micFail,"verification of Email notification for report generation", "Email was not triggered with report link"
End If
End Function


Function ValidateChromeDialogText(sExpectedText)

Set MyClipboard = CreateObject("Mercury.Clipboard")
MyClipboard.Clear
If Window("QAP").WinObject("Chrome Legacy Window").Exist(0) Then
	Window("QAP").WinObject("Chrome Legacy Window").highlight

ElseIf Window("QAP_Reports").WinObject("Chrome Legacy Window").Exist(0) Then
	Window("QAP_Reports").WinObject("Chrome Legacy Window").highlight
End IF


Set oShell= CreateObject("Wscript.Shell")
Wait 1
oShell.SendKeys "^(a)"
Wait 1
oShell.SendKeys "^(c)"
Wait 1
sActText=  MyClipboard.GetText

If Instr(sActText,sExpectedText) Then
	reporter.ReportEvent micPass,"Chrome dialog Text verification", "Expected Text= "& sExpectedText & "Actual Text= " & sActText
else
	reporter.ReportEvent micFail,"Chrome dialog Text verification", "Expected Text= "& sExpectedText & "Actual Text= " & sActText

End If
MyClipboard.Clear


CaptureScreenshot "ChromedialogText Validation"

End Function





Function WaitForSaveDialog()
DialogWaitCounter=0

Do
	Wait 1
	
	bDialogExists= Window("QAP_Reports").Dialog("Save As").Exist(1)	
	DialogWaitCounter= DialogWaitCounter+1
	
	If DialogWaitCounter=200 Then
		reporter.ReportEvent micFail, "Save dialog was not displayed",""
		CaptureScreenshot "Save dialog not displayed"
		Exit Do
	End If

Loop While bDialogExists= False

WaitForSaveDialog= bDialogExists

End Function



Function fnValidateScrollBar(objScroll,TC)
	
ncH1= objScroll.getROProperty("clientHeight")

nsH1= objScroll.getROProperty("scrollHeight")


If strcomp(ncH1,"")=0 Then
ncH1= objScroll.Object.clientHeight

nsH1= objScroll.Object.scrollHeight

End If
If nsH1>ncH1 Then
	reporter.ReportEvent micPass, TC & " ScrollBar validation",TC & "ScrollBar is enabled"
	else
	reporter.ReportEvent micFail, TC & " ScrollBar validation",TC & "ScrollBar is disabled"
End If
'CaptureScreenShot TC
		
End Function




Function DataTableImportXLSX(dFileName,dSourceSheetName,dDestinationSheetName)

  Dim ExcelApp
  Dim ExcelFile
  Dim ExcelSheet
 
  Dim sColumnCount

  Dim sColumnIndex
  Dim sColumnValue

  Set ExcelApp=CreateObject("Excel.Application")
     Set ExcelFile=ExcelApp.WorkBooks.Open (dFileName)
     Set ExcelSheet = ExcelApp.WorkSheets(dSourceSheetName)



  sColumnCount= ExcelSheet.UsedRange.Columns.Count


  For sColumnIndex=1 to sColumnCount

    sColumnValue=ExcelSheet.Cells(1,sColumnIndex)
    sColumnValue=Replace(sColumnValue," ","_")
	sColumnValue=Replace(sColumnValue,".","")
    If sColumnValue="" Then
     sColumnValue="NoColumn"&sColumnIndex
    End If


  Next

   ExcelFile.Save
   ExcelFile.Close
   ExcelApp.Quit


DataTable.ImportSheet dFileName, dSourceSheetName, Environment("ActionName")
End Function


Function fnOpenInNewWindow(objLink)
	wait 1
	
	Setting.WebPackage("ReplayType")=2
	
	objLink.RightClick
	Setting.WebPackage("ReplayType")=1
	wait 1
	
	Set DeviceReplay = CreateObject("Mercury.DeviceReplay")
	
	DeviceReplay.PressKey 208
	DeviceReplay.PressKey 208
	DeviceReplay.PressKey 28
End Function


Function KillBrowser()


Dim WshShell, oExec
Set WshShell = CreateObject("WScript.Shell")

Set oExec = WshShell.Exec("taskkill.exe /F /IM chrome.exe /T")

Do While oExec.Status = 0
     wait 0,100
Loop
wait 3

Set oExec=Nothing
Set WshShell=Nothing


End FUnction

Public Function FnRandomNumber(fnlowlimit,fnuplimit)
    	 'Pupose: Generates Random number
		 Randomize
		 upperbound=fnuplimit
		 lowerbound=fnlowlimit
         num1=Int((upperbound - lowerbound + 1) * Rnd + lowerbound)
		 FnRandomNumber=num1
End Function
