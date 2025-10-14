set oLocator = CreateObject("WbemScripting.SWbemLocator")
set oServices = oLocator.ConnectServer(".","root\wmi")
set oResults = oServices.ExecQuery("select * from batteryfullchargedcapacity")
for each oResult in oResults
   iFull = oResult.FullChargedCapacity
next

RepeatTimeInSec = 2 ' For flashing notification
VBRepeatTimeInSec = RepeatTimeInSec + 1

FullHealthPercent = 85
LowHealthPercent = 22

while (1)
  set oResults = oServices.ExecQuery("select * from batterystatus")
  for each oResult in oResults
    iRemaining = oResult.RemainingCapacity
    bCharging = oResult.Charging
  next
  iPercent = ((iRemaining / iFull) * 100) mod 100
  
  Set shell = CreateObject("WScript.Shell")

	Set objFSO = CreateObject("Scripting.FileSystemObject")

	' Get the folder where this VBScript is located
	scriptFolder = objFSO.GetParentFolderName(WScript.ScriptFullName)
  
  if bCharging and (iPercent >= FullHealthPercent) Then ' Run PowerShell Script to Show Battery fully charged remove charger notification banner 
	
	' Build the full path to the PowerShell script
	ps1File = scriptFolder & "\FullHealthUI.ps1"
	
    ' Build PowerShell command to run notify.ps1 with parameters
    psCommand = "powershell -NoProfile -ExecutionPolicy Bypass -File """ & ps1File & """ " & RepeatTimeInSec & " " & iPercent
	
    ' Run PowerShell silently (0 = hidden window, False = no wait)
    shell.Run psCommand, 0, False
  end if
  
  if (bCharging = False) and (iPercent <= LowHealthPercent) Then ' Run PowerShell Script to Show Battery Low Connect charger notification banner 

	' Build the full path to the PowerShell script
	ps1File = scriptFolder & "\LowHealthUI.ps1"
	
    ' Build PowerShell command to run notify.ps1 with parameters
    psCommand = "powershell -NoProfile -ExecutionPolicy Bypass -File """ & ps1File & """ " & RepeatTimeInSec & " " & iPercent
	
    ' Run PowerShell silently (0 = hidden window, False = no wait)
    shell.Run psCommand, 0, False
  end if
  
  wscript.sleep VBRepeatTimeInSec*1000 ' milliseconds

wend

