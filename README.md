# projects
My personal automation projects.

1. kql_persistence_check.ps1:
Runs a series of kql queries of different types of persistence that can be used on a compromised host. Uses the Az cmdlets and saves it to a csv file. Allows an option to enter known compromised user/s, will only query devices the user/s logged into.

3. siem-udp.yaml:
Deploy and create an EC2 instance hosted in RHEL using Cloud Formation. It hosts logs and detections from a security solution called Cloud One. This instance can be used as a log forwarder to a SIEM.

4. automated_report.py:
Automated integrity monitoring and log inspection reports through python.Integrity Monitoring and Log Inspection are features available in Deep Security. They monitor changes and logs within your Server/Workstation that indicate a compromise.
