Dim objConnection 
Dim objRecordSet 
Dim DBQuery 

Function OpenDB(DB)
	
	
'Set Adodb Connection Object
Set objConnection = CreateObject("ADODB.Connection")     


'Create RecordSet Object
Set objRecordSet = CreateObject("ADODB.Recordset")     
 'Connecting using SQL OLEDB Driver
 Select Case DB
 	Case "HCDMQA"
 			objConnection.Open "Driver={NetezzaSQL};servername=netezza_wdc_dev.us.qdx.com;port=5480;database=HCDMQA;username=bicadmin;password=Qu3st_113;"
 	Case "BICQA"
 			objConnection.Open "Driver={NetezzaSQL};servername=netezza_wdc_dev.us.qdx.com;port=5480;database=BICQA;username=bicadmin;password=Qu3st_113;"
 End Select


 
End Function

Function ValuefromDB(sQuery)

If IsObject(objRecordSet) then

'Query to be Executed
'DBQuery = "Select * from LAB_RSLT_FCT"
DBQuery = sQuery
objRecordSet.Open DBQuery,objConnection

'Return the Result Set
Value = objRecordSet.fields.item(0)				
ValuefromDB= Value
'msgbox Value

else

	reporter.ReportEvent micFail,"objConnection and RecordSet is not object","Open Connection is not successfull Please check"

End if
objRecordSet.Close 
End Function


Function CloseDB()

If IsObject(objRecordSet) then
	' Release the Resources
	       
	objConnection.Close		
	
	Set objConnection = Nothing
	Set objRecordSet = Nothing

else

	reporter.ReportEvent micFail,"objConnection and RecordSet is not object","Open Connection is not successfull Please check"


End if

End Function




