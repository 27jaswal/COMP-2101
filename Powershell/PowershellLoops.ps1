function Get-SystemInfo {
    # Function to get system hardware description
    function Get-HardwareInfo {
        $hardware = Get-CimInstance Win32_ComputerSystem
        $manufacturer = $hardware.Manufacturer
        $model = $hardware.Model
        $totalMemory = "{0:N0}" -f ($hardware.TotalPhysicalMemory / 1GB)
        $info = "Manufacturer: $manufacturer", "Model: $model", "Total Memory: ${totalMemory} GB"
        return $info
    }

    # Function to get operating system name and version
    function Get-OSInfo {
        $os = Get-CimInstance Win32_OperatingSystem
        $osName = $os.Caption
        $osVersion = $os.Version
        $info = "OS Name: $osName", "Version: $osVersion"
        return $info
    }

    # Function to get processor description with cache information
    function Get-ProcessorInfo {
        $processor = Get-CimInstance Win32_Processor
        $description = $processor.Caption
        $speed = "{0:N2}" -f ($processor.MaxClockSpeed / 1000)
        $cores = $processor.NumberOfCores
        $l1Cache = "{0:N0}" -f ($processor.L2CacheSize / 1KB)
        $l2Cache = "{0:N0}" -f ($processor.L2CacheSize / 1KB)
        $l3Cache = "{0:N0}" -f ($processor.L3CacheSize / 1KB)
        $info = "Description: $description", "Speed: ${speed} GHz", "Cores: $cores",
                "L1 Cache: ${l1Cache} KB", "L2 Cache: ${l2Cache} KB", "L3 Cache: ${l3Cache} KB"
        return $info
    }

    # Function to get RAM information
    function Get-RAMInfo {
        $ram = Get-CimInstance Win32_PhysicalMemory
        $table = @()
        $totalMemory = 0

        foreach ($dim in $ram) {
            $vendor = $dim.Manufacturer
            $description = $dim.Caption
            $size = "{0:N0}" -f ($dim.Capacity / 1GB)
            $bank = $dim.BankLabel
            $slot = $dim.DeviceLocator

            $totalMemory += $dim.Capacity

            $tableRow = [PSCustomObject]@{
                Vendor = $vendor
                Description = $description
                Size = "${size} GB"
                Bank = $bank
                Slot = $slot
            }
            $table += $tableRow
        }

        $totalMemoryGB = "{0:N0}" -f ($totalMemory / 1GB)
        $table | Format-Table -AutoSize
        Write-Host "Total Installed RAM: ${totalMemoryGB} GB"
    }

    # Function to get disk information
    function Get-DiskInfo {
        $diskDrives = Get-CimInstance CIM_DiskDrive
        $table = @()

        foreach ($disk in $diskDrives) {
            $partitions = $disk | Get-CimAssociatedInstance -ResultClassName CIM_DiskPartition

            foreach ($partition in $partitions) {
                $logicalDisks = $partition | Get-CimAssociatedInstance -ResultClassName CIM_LogicalDisk

                foreach ($logicalDisk in $logicalDisks) {
                    $vendor = $disk.Manufacturer
                    $model = $disk.Model
                    $sizeGB = "{0:N0}" -f ($logicalDisk.Size / 1GB)
                    $freeSpaceGB = "{0:N0}" -f ($logicalDisk.FreeSpace / 1GB)
                    $percentageFree = "{0:N2}%" -f (($logicalDisk.FreeSpace / $logicalDisk.Size) * 100)

                    $tableRow = [PSCustomObject]@{
                        Vendor = $vendor
                        Model = $model
                        Size = "${sizeGB} GB"
                        'Free Space' = "${freeSpaceGB} GB"
                        'Free Space (%)' = $percentageFree
                    }
                    $table += $tableRow
                }
            }
        }

        $table | Format-Table -AutoSize
    }

    # Function to get network adapter configuration
    function Get-NetworkInfo {
        $adapters = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled }
        $adapterInfo = @()

        foreach ($adapter in $adapters) {
            $dnsServers = $adapter.DNSServerSearchOrder -join ', '
            $ipAddresses = $adapter.IPAddress -join ', '
            $subnets = $adapter.IPSubnet -join ', '

            $info = [PSCustomObject]@{
                'Adapter Description' = $adapter.Description
                Index = $adapter.Index
                'IP Address(es)' = $ipAddresses
                'Subnet Mask(s)' = $subnets
                'DNS Domain' = $adapter.DNSDomain
                'DNS Servers' = $dnsServers
                'Default Gateway' = $adapter.DefaultIPGateway -join ', '
            }

            $adapterInfo += $info
        }

        $adapterInfo | Format-Table -AutoSize
    }

    # Function to get video card information
    function Get-VideoCardInfo {
        $videoCard = Get-CimInstance Win32_VideoController
        $vendor = $videoCard.Manufacturer
        $description = $videoCard.Caption
        $resolution = $videoCard.CurrentHorizontalResolution.ToString() + ' x ' + $videoCard.CurrentVerticalResolution.ToString()

        $info = "Vendor: $vendor", "Description: $description", "Current Resolution: $resolution"
        return $info
    }

    Write-Host "===== System Hardware Description ====="
    Get-HardwareInfo

    Write-Host "`n===== Operating System Information ====="
    Get-OSInfo

    Write-Host "`n===== Processor Information ====="
    Get-ProcessorInfo

    Write-Host "`n===== RAM Information ====="
    Get-RAMInfo

    Write-Host "`n===== Disk Information ====="
    Get-DiskInfo

    Write-Host "`n===== Network Adapter Configuration ====="
    Get-NetworkInfo

    Write-Host "`n===== Video Card Information ====="
    Get-VideoCardInfo
}

# Call the Get-SystemInfo function to generate the system information report
Get-SystemInfo
