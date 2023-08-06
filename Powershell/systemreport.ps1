param (
    [switch]$System,
    [switch]$Disks,
    [switch]$Network
)

# Copy the functions from lab1.ps1

if ($System) {
    Write-Host "System Hardware Description:"
    Show-List (Get-SystemHardwareDescription)

    Write-Host "`nOperating System Information:"
    Show-List (Get-OperatingSystemInfo)

    Write-Host "`nProcessor Information:"
    Show-List (Get-ProcessorInfo)

    Write-Host "`nMemory Information:"
    $ramInfo, $totalRamGB = Get-MemoryInfo
    Show-Table $ramInfo
    Write-Host "Total RAM Installed (GB): $totalRamGB"

    Write-Host "`nVideo Card Information:"
    $videoInfo = Get-VideoInfo
    Show-List $videoInfo
}
elseif ($Disks) {
    Write-Host "`nDisk Drive Information:"
    $diskInfo = Get-DiskInfo
    Show-Table $diskInfo
}
elseif ($Network) {
    Write-Host "`nNetwork Adapter Configuration:"
    $networkInfo = Get-NetworkInfo
    Show-Table $networkInfo
}
else {
    Write-Host "System Hardware Description:"
    Show-List (Get-SystemHardwareDescription)

    Write-Host "`nOperating System Information:"
    Show-List (Get-OperatingSystemInfo)

    Write-Host "`nProcessor Information:"
    Show-List (Get-ProcessorInfo)

    Write-Host "`nMemory Information:"
    $ramInfo, $totalRamGB = Get-MemoryInfo
    Show-Table $ramInfo
    Write-Host "Total RAM Installed (GB): $totalRamGB"

    Write-Host "`nDisk Drive Information:"
    $diskInfo = Get-DiskInfo
    Show-Table $diskInfo

    Write-Host "`nNetwork Adapter Configuration:"
    $networkInfo = Get-NetworkInfo
    Show-Table $networkInfo

    Write-Host "`nVideo Card Information:"
    $videoInfo = Get-VideoInfo
    Show-List $videoInfo
}
