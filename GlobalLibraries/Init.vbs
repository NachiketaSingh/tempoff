'''******************************************************************************************************
'*	Library Name: 	Init															*
'*	Description:	Initiates the framework								*
'*	Author:		Nachiketa.x.singh@Questdiagnostics.com											*
'''******************************************************************************************************


Dim QAP_PATH
Dim gORPath
Dim gDataPath
Dim gReportsPath
Dim gLibraryPath
Dim sSheetName
Dim gDataFile
Dim gBrowser
Dim gEnv
Dim AUT_Browser


'On Error Resume Next

	pos= InStrRev(Environment("TestDir"), "TestSuite\",-1,VBTextCompare)

 	QAP_PATH= Left(Environment("TestDir"),pos-1)


	SetEnvironmentValue"QAP_PATH",QAP_PATH
   
   	gLibraryPath	 = 	QAP_PATH & "GlobalLibraries\"

	ExecuteFile gLibraryPath & "Config.vbs"
	ExecuteFile gLibraryPath & "GenericFunctionsUtils.vbs"
	ExecuteFile gLibraryPath & "QAP_GlobalFunctionLib.vbs"
	ExecuteFile gLibraryPath & "QAP_DBFunctionLib.vbs"

   gORPath    	 = 		QAP_PATH & "Global Object Repository\"
   gDataPath 	 =  	QAP_PATH & "Data\"	
   gReportsPath  =  	QAP_PATH & "Results\Reports\"


	

   RepositoriesCollection.Add  gORPath   & "QAP_Repository_Global.tsr"


   gDataFile= gDataPath & "QAP_AUT_Regression.xls"
   sSheetName= Trim(Split(Split(Environment("TestDir"), QAP_Path &"TestSuite\")(1), "\")(0))
   openDT
SetAppVars



	Set ReportBuilder	= 	New ODI_ReportBuilder
	Set App_Sync		= 	New App_Sync_QAP
	Set UtilDetails		= 	New UtilDetails_LUI
	Set UtilSpends		= 	New UtilSpends_LUI
	Set MyReports		=	New MyReports_ODI
	Set UtilInsights	=	New UtilInsights_LUI


Function SetEnvironmentValue(var,val)

	Set WshShell = CreateObject("WScript.Shell")
   Set WshEnv = WshShell.Environment("USER")
   WshEnv(var) = val
   Set WshShell = Nothing
   Set WshEnv = Nothing

End Function 




Function getEnvironmentVariable(Variable)

   ' How to Set External System Environmet variables

   Set WshShell = CreateObject("WScript.Shell")
   Set WshEnv = WshShell.Environment("USER")

   tmp = WshEnv(Variable)
   getEnvironmentVariable = tmp

   Set WshShell = Nothing
   Set WshEnv = Nothing

End Function
