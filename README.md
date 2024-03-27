# IONet Worker Management Script

This script offers a comprehensive solution for managing IONet Workers on Windows, focusing on ease of use and automation. It includes functionalities such as health checks, binary reinstallation, Docker cleanup, energy-saving adjustments, Rosetta 2 installation, and an AutoPilot setup for routine maintenance.

## Features

- **Health Check**: Verifies the operational status of IONet Workers.
- **ReInstall IONet Binary**: Downloads and sets up the latest IONet Binary.
- **ReInstall IONet Worker**: Cleans existing Docker components and reinstalls the IONet Worker.
- **Remove ALL Deployment**: Clears all Docker components, including containers, images, volumes, and networks.
- **Check Virtualization**: Ensures virtualization support is enabled on the system.
- **AutoPilot Setup**: Schedules routine operations to ensure IONet Workers remain operational.

## Prerequisites

Before running the script, ensure that the following prerequisites are met:

- PowerShell version 5.1 or later
- Windows Subsystem for Linux (WSL) enabled
- Docker Desktop installed and configured
- NVIDIA drivers and CUDA toolkit (if required by your application)

## Setting Execution Policy

Before running the script, set the execution policy by running the following command in PowerShell:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

## Usage

1. **Health Check**: Perform a health check of the IONet Workers.
2. **ReInstall IONet Binary**: Update the IONet Binary to the latest version.
3. **ReInstall IONet Worker**: Clean Docker components and reinstall the IONet Worker.
4. **Remove ALL Deployment**: Clean all Docker resources related to IONet.
5. **Check Virtualization**: Ensure virtualization support is enabled on the system.
6. **AutoPilot Setup**: Schedule routine operations for automated maintenance.

