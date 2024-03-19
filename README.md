# windows-worker-checker

This script will check your IONet Workers for each 10 min and if not healthy it will deploy ionet workers again.

Enjoy.

### Guide

1 - Add your own docker run command block to line 26, otherwise it wont be worked!
2 - If you want to schedule it follow this steps.

### COMMAND-LINE
# Run cmd as admin
 To do this, type "cmd" in the Start menu, right-click "Command Prompt" and select "Run as administrator."

# Create Scheduled Task
You can create a task with the following command. This command creates a new task that will run your specified PowerShell script (C:\path\to\your\script.ps1) every 10 minutes. Remember to modify the command with the actual location of your script.

`schtasks /create /tn "RunDockerCheck" /tr "powershell -ExecutionPolicy Bypass -File YOUR_SCRIPT_PATH" /sc minute /mo 10 /ru SYSTEM`

Components of this command:

/create: Creates a new task.
/tn "MyDockerTask": The name of the task is set to MyDockerTask.
/tr: The task to run. Here, it directly calls a PowerShell script.
/sc minute /mo 10: Schedules the task to run every 10 minutes.
/ru SYSTEM: Runs the task as the SYSTEM user, which ensures it runs with elevated privileges.
Checkin

# Check Scheduled Task
If you wish to check the task you've created, you can use the following command:

`schtasks /query | findstr "RunDockerCheck"`

# Delete Scheduled Task
If you wish to delete the task you've created, you can use the following command:

`schtasks /delete /tn "RunDockerCheck" /f`

### TASK SCHEDULER

To schedule a PowerShell script to run automatically every 10 minutes using the Windows Task Scheduler interface without using the command line, follow these steps:

#Open Task Scheduler
Press Windows + R to open the Run dialog, type taskschd.msc, and press Enter. This will open the Task Scheduler.
Create a New Task
In the Task Scheduler, navigate to the Action menu and select Create Task....

#General Tab
Under the General tab, give your task a meaningful name, such as "MyDockerTask". You can also provide a description.
Choose the Run whether user is logged on or not option for the task to run regardless of the user's session. Optionally, select Run with highest privileges to ensure the task has the necessary permissions to execute.

#Triggers Tab
Go to the Triggers tab and click New... to set when the task should start.
Select the Daily schedule, and then under Advanced settings, select Repeat task every: and choose 10 minutes from the dropdown. Set the duration to Indefinitely to keep the task running regularly.
Click OK to save the trigger settings.

#Actions Tab
Navigate to the Actions tab and click New.... This defines what the task actually does.
In the Action field, select Start a program. In the Program/script field, type powershell. In the Add arguments (optional) field, input -ExecutionPolicy Bypass -File "C:\path\to\your\script.ps1". Replace C:\path\to\your\script.ps1 with the actual path to your PowerShell script.
Click OK to save the action.

#Conditions and Settings Tabs
(Optional) Configure any additional options under the Conditions and Settings tabs as per your requirement. For instance, under Settings, you might want to ensure the task is stopped if it runs longer than expected by selecting Stop the task if it runs longer than: and choosing an appropriate time.

#Save and Test
Once you've configured all settings, click OK to save the task. You might be prompted to enter your Windows credentials to authorize the task.
To test the task, right-click on the task you just created in the Task Scheduler library and select Run. This will execute the task immediately.
By following these steps, you've successfully scheduled your PowerShell script to run automatically every 10 minutes using Windows Task Scheduler's graphical interface. This method allows for flexible scheduling without needing to use command-line commands.
