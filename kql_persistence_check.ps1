Connect-AzAccount
WorkspaceID = Read-Host 'Please enter Workspace ID'

$fPath = Read-Host 'Enter preferred directory to save files. If no location is specified, will save files in current working directory'

If (-not $fPath)
{
echo "Current working directory is $PWD"
}

function write2file {
  param (
    $kqlresult,
    $FileName,
    $FilePath
  )
  If (-not $FilePath)
  {
    $kqlresult.Results | ConvertTo-Csv | Out-File "$FileName"
  } else 
  {
    $kqlresult.Results | ConvertTo-Csv | Out-File "$FilePath\$FileName"
  }
}

function Scheduled_Task {

$DeviceEvents_Query = "
DeviceEvents  
| where ActionType == 'ScheduledTaskCreated' or ActionType == 'ScheduledTaskUpdated'
| where AdditionalFields.TaskName !contains 'Lenovo' and AdditionalFields.TaskName !contains 'Microsoft' and AdditionalFields.TaskName !contains 'Binalyze'
| project TimeGenerated=format_datetime(TimeGenerated, 'yyyy-MM-dd HH:mm:ss'), ActionType, TaskName=AdditionalFields.TaskName, TaskContent=AdditionalFields.TaskContent, DeviceName, InitiatingProcessAccountName
| order by TimeGenerated desc
"

$SecurityEvent_Query = "
SecurityEvent
| where EventID == '4698'
| project TimeGenerated=format_datetime(TimeGenerated, 'yyyy-MM-dd HH:mm:ss'), Activity, Computer, Channel, EventData
| order by TimeGenerated desc
"
$fName1= 'SchedTask_DeviceEvents.csv'
$fName2= 'SchedTask_SecurityEvents.csv'

$kqlQuery_1 = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceID -Query $DeviceEvents_Query
$kqlQuery_2 = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceID -Query $SecurityEvent_Query

write2file -kqlresult $kqlQuery_1 -FilePath $fPath -FileName $fName1
write2file -kqlresult $kqlQuery_2 -FilePath $fPath -FileName $fName2

}

function Run_RunOnce_WinLogon{

$DeviceRegistryEvents = "DeviceRegistryEvents 
| where RegistryKey contains 'CurrentVersion\\Run' or RegistryKey contains 'CurrentVersion\\Winlogon'
| where ActionType == 'RegistryValueSet' and InitiatingProcessFileName !contains 'Onedrive' and RegistryValueType !contains 'word'
| project Timestamp=format_datetime(Timestamp, 'yyyy-MM-dd HH:mm:ss'), DeviceName, InitiatingProcessFolderPath,RegistryKey, RegistryValueData
| order by Timestamp desc
"
$fName1= 'Run_RunOnce_Winlogon_DeviceRegistryEvents.csv'
$kqlQuery_1 = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceID -Query $DeviceRegistryEvents
write2file -kqlresult $kqlQuery_1 -FilePath $fPath -FileName $fName1

}

function service_installation{

$DeviceEvents = "
DeviceEvents
| where ActionType == 'ServiceInstalled' and AdditionalFields.ServiceName !contains 'Tactical' and AdditionalFields.ServiceName !contains 'Tdklib'and InitiatingProcessCommandLine !contains 'svchost.exe -k netsvcs -p -s UserManager' and AdditionalFields.ServiceName !contains 'Forti' and FileName !contains 'agentmon' and FileName !contains 'kaseya' and FolderPath !contains 'Packages\\Plugins\\Microsoft' and FileName !contains 'elevation_service.exe' and FolderPath !contains 'Google\\GoogleUpdater'
| project Timestamp=format_datetime(Timestamp, 'yyyy-MM-dd HH:mm:ss'), DeviceName, ServiceName=AdditionalFields.ServiceName, FileName, FolderPath, InitiatingProcessFolderPath
| order by Timestamp desc
"
$fName1= 'Service_Installation.csv'
$kqlQuery_1 = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceID -Query $DeviceEvents
write2file -kqlresult $kqlQuery_1 -FilePath $fPath -FileName $fName1

}

function User_manipulation{

$SecurityEvents = "
SecurityEvent 
| where EventID == '4720' or EventID == '4767' or EventID == '4722'
| project TimeGenerated=format_datetime(TimeGenerated, 'yyyy-MM-dd HH:mm:ss'), Activity, Computer, SubjectAccount, TargetAccount, TargetSid
| order by TimeGenerated desc
"
$fName1= 'User_Manipulation.csv'
$kqlQuery_1 = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceID -Query $SecurityEvents
write2file -kqlresult $kqlQuery_1 -FilePath $fPath -FileName $fName1

}

function Startup_folder{

$DeviceEvents = "
DeviceFileEvents  
| where FolderPath contains 'Programs\\Startup' and ActionType contains 'FileCreated' and FileName !contains 'OneNote'
| project Timestamp=format_datetime(Timestamp, 'yyyy-MM-dd HH:mm:ss'), ActionType, DeviceName, FileName=FolderPath, InitiatingProcessAccountName, InitiatingProcessFolderPath, InitiatingProcessSHA1
| order by Timestamp desc
"
$fName1= 'Startup_Folder.csv'
$kqlQuery_1 = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceID -Query $DeviceEvents
write2file -kqlresult $kqlQuery_1 -FilePath $fPath -FileName $fName1

}

function File_association{

$DeviceEvents = "
DeviceRegistryEvents 
| where RegistryKey contains 'shell\\open\\command' and ActionType contains 'RegistryValueSet'
| where InitiatingProcessVersionInfoProductName !contains 'OneDrive' and RegistryKey !contains 'Acrobat' and RegistryValueData !contains 'Acrobat' and RegistryValueData !contains 'Microsoft\\Edge' and InitiatingProcessVersionInfoProductName !contains 'Visual Studio' and InitiatingProcessCommandLine !contains 'svchost.exe -k wsappx -p -s AppXSvc'
| project Timestamp=format_datetime(Timestamp, 'yyyy-MM-dd HH:mm:ss'), ActionType, DeviceName, InitiatingProcessAccountName, InitiatingProcessFolderPath,  RegistryKey, RegistryValueData
| order by Timestamp desc
"
$fName1= 'File_Association.csv'
$kqlQuery_1 = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceID -Query $DeviceEvents
write2file -kqlresult $kqlQuery_1 -FilePath $fPath -FileName $fName1

}

function Wmi_Subscription{

$DeviceEvents = "
DeviceEvents
| where ActionType == 'WmiBindEventFilterToConsumer'
| project Timestamp=format_datetime(TimeGenerated, 'yyyy-MM-dd HH:mm:ss'), ActionType, AdditionalFields, DeviceName
| order by Timestamp desc
"
$fName1= 'Wmi_event_subscription.csv'
$kqlQuery_1 = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceID -Query $DeviceEvents
write2file -kqlresult $kqlQuery_1 -FilePath $fPath -FileName $fName1

}

function Group_Manipulation{

$SecurityEvent = "
SecurityEvent 
| where EventID == 4732 or EventID == 4728
| project TimeGenerated=format_datetime(TimeGenerated, 'yyyy-MM-dd HH:mm:ss'), Computer, Activity, SubjectAccount, TargetAccount,TargetSid, Account
| order by TimeGenerated desc
"
$fName1= 'Group_Manipulation.csv'
$kqlQuery_1 = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceID -Query $SecurityEvent
write2file -kqlresult $kqlQuery_1 -FilePath $fPath -FileName $fName1

}

Group_Manipulation
Wmi_Subscription
File_association
Startup_folder
user_manipulation
service_installation
Run_RunOnce_WinLogon
Scheduled_Task