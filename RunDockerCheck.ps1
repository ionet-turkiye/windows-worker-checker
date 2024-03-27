# Initial check for ionet-worker-connect.txt
if (Test-Path "./ionet-worker-connect.txt") {
    $useExisting = Read-Host "ionet-worker-connect.txt exists. Use it? (Y/N)"
    if ($useExisting -notmatch "^[yY]([eE][sS])?$") {
        # Get new input and attempt to overwrite the existing file
        $newCommand = Read-Host "Please enter the new IONet worker connect command"
        try {
            $newCommand | Out-File -FilePath "./ionet-worker-connect.txt" -ErrorAction Stop
            Write-Host "File updated successfully." -ForegroundColor Green
        } catch {
            Write-Host "Failed to update ionet-worker-connect.txt. Error: $_" -ForegroundColor Red
        }
    }
} else {
    # File doesn't exist, prompt for input and attempt to create the file
    $newCommand = Read-Host "Please enter the IONet worker connect command"
    try {
        $newCommand | Out-File -FilePath "./ionet-worker-connect.txt" -ErrorAction Stop
        Write-Host "File created successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to create ionet-worker-connect.txt. Error: $_" -ForegroundColor Red
    }
}


function Show-Menu {
    param (
        [string]$Title = 'Main Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Health Check"
    Write-Host "2: Re Install IONet"
    Write-Host "3: AutoPilot Setup"
    Write-Host "4: More Options"
    Write-Host "5: Quit"
}

function Show-MoreOptions {
    param (
        [string]$Title = 'More Options'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: DriverCheck"
    Write-Host "2: Cuda Check"
    Write-Host "3: Check Virtualization"
    Write-Host "4: Return to Main Menu"
}

function Health-Check {
    Write-Host "Performing Health Check..."
    
    $containerCount = (docker ps -a --format "{{.Image}}" | Where-Object { $_ -match "ionetcontainers" }).Count
    $imageCount = (docker images --format "{{.Repository}}" | Select-String "ionetcontainers").Count

    if ($containerCount -eq 2 -and $imageCount -eq 3) {
        Write-Host "All systems operational." -ForegroundColor Green
    } else {
        Write-Host "Health check failed. System not operational." -ForegroundColor Red
    }
}

function Remove-AllDeployment {
    try {
        Stop-DockerContainersWithIonet
        Remove-DockerResources
        ReInstall-IONet
    } catch {
        Write-Host "An error occurred during deployment removal or IONet reinstallation." -ForegroundColor Red
    }
}

function AutoPilot-Setup {
    Write-Host "Setting up AutoPilot..."
}

function DriverCheck {
    if (Get-Command "nvidia-smi" -ErrorAction SilentlyContinue) {
        & "nvidia-smi"
    } else {
        Write-Host "NVIDIA driver is not installed."
    }
}

function CudaCheck {
    if (Get-Command "nvcc" -ErrorAction SilentlyContinue) {
        & "nvcc" --version
    } else {
        Write-Host "CUDA is not installed."
    }
}

function MoreOptions {
    do {
        Show-MoreOptions
        $input = Read-Host "Please select an option"
        switch ($input) {
            '1' {
                DriverCheck
            }
            '2' {
                CudaCheck
            }
            '3' {
                Check-VirtualizationAndEnable
            }
            '4' {
                Disable-PowerOptions
            }
            '5' {
                return
            }
            default {
                Write-Host "Invalid option, please try again."
            }
        }
        pause
    } while ($input -ne '3')
}

function Stop-DockerContainersWithIonet {
    try {
        Write-Host "Stopping Docker containers with images containing 'ionet'..." -ForegroundColor Cyan
        docker ps --format "{{.ID}} {{.Image}}" | Where-Object {$_ -match "ionet"} | ForEach-Object {
            $containerId = ($_ -split ' ')[0]
            docker stop $containerId
        }
        Write-Host "Docker containers stopped successfully." -ForegroundColor Green
    } catch {
        Write-Host "An error occurred while stopping containers." -ForegroundColor Red
    }
}


function Remove-DockerResources {
    try {
        Write-Host "Removing Docker containers containing 'ionet'..." -ForegroundColor Cyan
        docker ps -a --format "{{.Names}}" | Where-Object {$_ -match "ionet"} | ForEach-Object {
            docker rm -f $_
        }
        Write-Host "Docker containers removed successfully." -ForegroundColor Green

        Write-Host "Removing Docker images containing 'ionet'..." -ForegroundColor Cyan
        docker images --format "{{.Repository}} {{.ID}}" | Where-Object {$_ -match "ionet"} | ForEach-Object {
            $parts = $_ -split ' '
            $imageId = $parts[1]
            docker rmi -f $imageId
        }
        Write-Host "Docker images removed successfully." -ForegroundColor Green

        Write-Host "Removing Docker volumes containing 'ionet'..." -ForegroundColor Cyan
        docker volume ls --format "{{.Name}}" | Where-Object {$_ -match "ionet"} | ForEach-Object {
            docker volume rm $_
        }
        Write-Host "Docker volumes removed successfully." -ForegroundColor Green

        Write-Host "Removing Docker networks containing 'ionet'..." -ForegroundColor Cyan
        docker network ls --format "{{.Name}}" | Where-Object {$_ -match "ionet"} | ForEach-Object {
            docker network rm $_
        }
        Write-Host "Docker networks removed successfully." -ForegroundColor Green
    } catch {
        Write-Host "An error occurred during the operation." -ForegroundColor Red
    }
}


function ReInstall-IONet {
    Write-Host "Reinstalling IONet..."
    
    # Check if the command file exists to handle the case where it might be deleted or moved.
    if (Test-Path "./ionet-worker-connect.txt") {
        $commandToRun = Get-Content -Path "./ionet-worker-connect.txt" -ErrorAction Stop
        try {
            Invoke-Expression $commandToRun
            Write-Host "IONet Worker Connect command executed successfully." -ForegroundColor Green
        } catch {
            Write-Host "Failed to execute IONet Worker Connect command. Error: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Command file 'ionet-worker-connect.txt' not found." -ForegroundColor Red
    }
}

function Check-VirtualizationAndEnable {
    $hyperVInfo = Get-ComputerInfo -property "HyperV*"
    if ($hyperVInfo.HyperVisorPresent -ne $true) {
        Write-Host "Virtualization support is not enabled on this system. Attempting to enable..." -ForegroundColor Yellow
        
        try {
            Write-Host "Enabling Microsoft Hyper-V..." -ForegroundColor Cyan
            dism.exe /online /enable-feature /featurename:Microsoft-Hyper-V-All /all /norestart | Out-Null

            Write-Host "Enabling Windows Subsystem for Linux..." -ForegroundColor Cyan
            dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart | Out-Null

            Write-Host "Enabling Virtual Machine Platform..." -ForegroundColor Cyan
            dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart | Out-Null

            Write-Host "Setting WSL default version to 2..." -ForegroundColor Cyan
            wsl --set-default-version 2 | Out-Null
            
            Write-Host "Features enabled successfully. Please restart your computer for the changes to take effect." -ForegroundColor Green
        } catch {
            Write-Host "Failed to enable required features. Error: $_" -ForegroundColor Red
            Write-Host "Please run this script as Administrator or manually run the commands." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Virtualization support is enabled on this system." -ForegroundColor Green
    }
}
function Show-AutoPilotOptions {
    param (
        [string]$Title = 'AutoPilot Setup'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1 - Schedule AutoPilot (30minute)"
    Write-Host "2 - List AutoPilot Schedule"
    Write-Host "3 - Delete AutoPilot Schedule"
    Write-Host "4 - Back to Main Menu"

    # Prompt the user for input
    $option = Read-Host "Select an option"

    # Process the user's choice
    switch ($option) {
        '1' {
            Schedule-AutoPilot
            pause
            Show-AutoPilotOptions
        }
        '2' {
            List-AutoPilotSchedule
            pause
            Show-AutoPilotOptions
        }
        '3' {
            Delete-AutoPilotSchedule
            pause
            Show-AutoPilotOptions
        }
        '4' {
            # Return to the main menu
            Show-Menu
        }
        default {
            Write-Host "Invalid option. Please try again." -ForegroundColor Red
            pause
            Show-AutoPilotOptions
        }
    }
}
function Schedule-AutoPilot {
    # Check if the task already exists
    $taskExists = Get-ScheduledTask -TaskName "IONetAutoPilot" -ErrorAction SilentlyContinue
    if ($taskExists) {
        Write-Host "AutoPilot task already exists. Skipping scheduling." -ForegroundColor Yellow
        return
    }

    # Define the action to execute the AutoPilot script
    $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -WindowStyle Hidden -File ""$PSScriptRoot\AutoPilotTasks.ps1"""

    # Create a trigger to run every 30 minutes
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date.AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 30) -RepetitionDuration (New-TimeSpan -Days 365)

    # Register the scheduled task
    Register-ScheduledTask -TaskName "IONetAutoPilot" -Action $action -Trigger $trigger -Description "AutoPilot Health Check and Deployment"
    Write-Host "AutoPilot scheduled successfully." -ForegroundColor Green
}






function List-AutoPilotSchedule {
    Write-Host "Listing AutoPilot Schedule..."
    $tasks = Get-ScheduledTask | Where-Object { $_.TaskName -like "IONet*" }
    if ($tasks) {
        $tasks | Format-Table TaskName, NextRunTime, LastRunTime, State -AutoSize
    } else {
        Write-Host "No AutoPilot schedules found." -ForegroundColor Yellow
    }
}

function Delete-AutoPilotSchedule {
    Write-Host "Deleting AutoPilot Schedule..."
    $taskNamePattern = "IONet*"
    $tasks = Get-ScheduledTask | Where-Object { $_.TaskName -like $taskNamePattern }
    if ($tasks) {
        $tasks | ForEach-Object {
            Unregister-ScheduledTask -TaskName $_.TaskName -Confirm:$false
            Write-Host "Deleted AutoPilot schedule: $($_.TaskName)" -ForegroundColor Green
        }
    } else {
        Write-Host "No AutoPilot schedules found to delete." -ForegroundColor Yellow
    }
}
function Disable-PowerOptions {
    try {
        Write-Host "Disabling power options to prevent sleeping..." -ForegroundColor Cyan
        
        # Disable sleep idle timer
        powercfg.exe -change -standby-timeout-ac 0
        powercfg.exe -change -standby-timeout-dc 0
        
        # Disable hybrid sleep
        powercfg.exe -change -hibernate-timeout-ac 0
        powercfg.exe -change -hibernate-timeout-dc 0
        
        # Disable system sleep
        powercfg.exe -change -monitor-timeout-ac 0
        powercfg.exe -change -monitor-timeout-dc 0
        
        Write-Host "Power options disabled successfully." -ForegroundColor Green
    } catch {
        Write-Host "An error occurred while disabling power options." -ForegroundColor Red
    }
}


do {
    Show-Menu
    $input = Read-Host "Please select an option"
    switch ($input) {
        '1' {
            Health-Check
        }
        '2' {
            Remove-AllDeployment
        }
        '3' {
            Show-AutoPilotOptions
        }
        '4' {
            MoreOptions
        }
        '5' {
            Write-Host "Quitting..." -ForegroundColor Yellow
            break
        }
        default {
            Write-Host "Invalid option, please try again." -ForegroundColor Red
        }
    }
    # Optionally, add a pause here if you want the script to wait before clearing the screen or showing the menu again
    # pause
} while ($input -ne '6')
