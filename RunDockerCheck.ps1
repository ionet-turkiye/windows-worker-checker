function Check-Conditions {
    $imageCount = (docker image ls | Select-String 'ionet').Count
    $containerCount = (docker ps | Select-String 'ionet').Count

    if ($imageCount -eq 3 -and $containerCount -eq 2) {
        Write-Host "IONET Worker OK"
        return $true
    } else {
        return $false
    }
}

function Reset-Docker {
    Write-Host "IONET Workers are pausing."
    docker ps -a | Where-Object { $_ -match "ionet" } | ForEach-Object {
        $containerId = $_.Split(" ", [StringSplitOptions]::RemoveEmptyEntries)[0]
        docker stop $containerId
        docker rm $containerId
    }
}


    Write-Host "IONet Docker is installing."
    #### Change this line with 2. Copy and run the below command on docker section on your worker, otherwise it wont be worked !!
    docker run -d -v /var/run/docker.sock:/var/run/docker.sock -e DEVICE_NAME="XXX" -e DEVICE_ID=XXX -e USER_ID=XXX -e OPERATING_SYSTEM="Windows" -e USEGPUS=true --pull always ionetcontainers/io-launch:v0.1

    # wait 10 sec for start
    Start-Sleep -Seconds 10
}

# main loop
do {
    $conditionsOk = Check-Conditions
    if (-not $conditionsOk) {
        Reset-Docker
    }
} while (-not $conditionsOk)
