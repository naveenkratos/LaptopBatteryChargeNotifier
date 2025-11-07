' Battery Monitor Script
' Shows notifications via PowerShell when battery is full or low

Option Explicit
On Error Resume Next

' --- WMI Setup ---
Dim oLocator, oServices, oResults, oResult
Set oLocator = CreateObject("WbemScripting.SWbemLocator")
Set oServices = oLocator.ConnectServer(".", "root\wmi")

If Err.Number <> 0 Then
    WScript.Echo "Error: Unable to connect to WMI."
    WScript.Quit
End If
On Error GoTo 0

' --- Get Full Charge Capacity ---
Set oResults = oServices.ExecQuery("SELECT * FROM BatteryFullChargedCapacity")
Dim iFull
iFull = 0

For Each oResult In oResults
    iFull = oResult.FullChargedCapacity
Next

If iFull = 0 Then iFull = 1 ' Prevent divide by zero

' --- Configurations ---
Dim RepeatTimeInSec, VBRepeatTimeInSec, FullHealthPercent, LowHealthPercent
RepeatTimeInSec = 2
VBRepeatTimeInSec = RepeatTimeInSec + 1
FullHealthPercent = 90
LowHealthPercent = 22

' --- Setup Variables ---
Dim iRemaining, bCharging, iPercent
Dim shell, objFSO, scriptFolder
Dim ps1File, psCommand

Set shell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
scriptFolder = objFSO.GetParentFolderName(WScript.ScriptFullName)

' --- Infinite Monitoring Loop ---
Do While True

    ' --- Read Battery Status ---
    On Error Resume Next
    Set oResults = oServices.ExecQuery("SELECT * FROM BatteryStatus")
    If Err.Number <> 0 Then
        Err.Clear
        WScript.Sleep VBRepeatTimeInSec * 1000
    Else
    
		On Error GoTo 0

		For Each oResult In oResults
			iRemaining = oResult.RemainingCapacity
			bCharging = oResult.PowerOnline
		Next

		If iFull > 0 Then
			iPercent = Round((iRemaining / iFull) * 100)
		Else
			iPercent = 0
		End If

		' --- Prevent invalid values ---
		If iPercent < 0 Then iPercent = 0
		If iPercent > 100 Then iPercent = 100

		' --- Check for "Fully Charged" Condition ---
		If bCharging And (iPercent >= FullHealthPercent) Then  ' 
			ps1File = scriptFolder & "\FullHealthUI.ps1"
			If objFSO.FileExists(ps1File) Then
				psCommand = "powershell -NoProfile -ExecutionPolicy Bypass -File """ & ps1File & """ " & RepeatTimeInSec & " " & iPercent
				shell.Run psCommand, 0, False
			End If
		
		' --- Check for "Low Battery" Condition ---
		ElseIf (Not bCharging) And (iPercent <= LowHealthPercent) Then  ' 
			ps1File = scriptFolder & "\LowHealthUI.ps1"
			If objFSO.FileExists(ps1File) Then
				psCommand = "powershell -NoProfile -ExecutionPolicy Bypass -File """ & ps1File & """ " & RepeatTimeInSec & " " & iPercent
				shell.Run psCommand, 0, False
			End If
		End If

		' --- Optional Exit Mechanism (create stop.txt to quit) ---
		If objFSO.FileExists(scriptFolder & "\stop.txt") Then
			WScript.Quit
		End If

		' --- Wait before next check ---
		WScript.Sleep VBRepeatTimeInSec * 1000
	
	End If

Loop
