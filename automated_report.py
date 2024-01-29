import requests
import json
import time

#URL
url = "https://workload.<replace with region>.cloudone.trendmicro.com/api/scheduledtasks"

#Headers
headers = {
      'api-version': 'v1',
      'Authorization': 'ApiKey <replace this with api key',
      'Content-Type': 'application/json',
    }

#Payload+ApiAction Function
def payload(reportname, reportID):
    payload = json.dumps({
      "name": reportname,
      "type": "generate-report",
      "scheduleDetails": {
        "recurrenceType": "none",
        "recurrenceCount": 0,
        "onceOnlyScheduleParameters": {
          "startTime": 0
        }
      },
      "enabled": True,
      "lastRunTime": 0,
      "nextRunTime": 0,
      "runNow": True,
      "generateReportTaskParameters": {
        "reportTemplateID": reportID,
        "format": "pdf",
        "classification": "blank",
        "recipients": {
          "contactIDs": [
            <replace with contact ID>
          ]
        },
        "timeRange": {
          "units": "week",
          "value": 1
        },
        "tagFilter": {},
        "computerFilter": {
          "type": "computer",
          "computerID": <replace with computer name>
        }
      }
    })
    response = requests.request("POST", url, headers=headers, data=payload)
    return(response.text)

#Function to delete created scheduled tasks
def deleteAPI(ID):
    deleteURL=url+'/'+ID
    deleteAPIheader= {
      'api-version': 'v1',
      'Authorization': 'ApiKey <replace with apikey>',
      'Content-Type': 'application/json',
    }
    response = requests.delete(deleteURL, headers=deleteAPIheader)


#Code starts here
print("Creating Reports...")
IMreport=payload("Eugene_IntegrityMonitoringReport", 10)
LIreport=payload("Eugene_LogInspectionReport", 1)
print("Done running APIs")

#Get the Scheduled task ID
IMreportJSON=json.loads(IMreport)
LIreportJSON=json.loads(LIreport)
IMschedID=IMreportJSON['ID']
LIschedID=LIreportJSON['ID']
IMidentifier=str(IMschedID)
LIidentifier=str(LIschedID)

#Delete scheduled tasks
time.sleep(3)
deleteAPI(IMidentifier)
deleteAPI(LIidentifier)