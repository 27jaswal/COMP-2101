# Get a collection of network adapter configuration objects and filter enabled adapters
$adapters = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled }

# Create an array to hold the adapter information
$adapterInfo = @()

# Function to get network profile for an adapter
function Get-NetworkProfile {
    param (
        [string]$Caption
    )
    $networkProfile = Get-NetConnectionProfile | Where-Object { $_.InterfaceAlias -eq $Caption }
    if ($networkProfile) {
        return $networkProfile.NetworkCategory
    } else {
        return "Unknown"
    }
}

# Iterate through each adapter and gather required information
foreach ($adapter in $adapters) {
    $dnsServers = $adapter.DNSServerSearchOrder -join ', '
    $ipAddresses = $adapter.IPAddress -join ', '
    $subnets = $adapter.IPSubnet -join ', '

    $info = [PSCustomObject]@{
        AdapterDescription = $adapter.Description
        Index = $adapter.Index
        IPAddress = $ipAddresses
        SubnetMask = $subnets
        DNSDomain = $adapter.DNSDomain
        DNSServers = $dnsServers
        DefaultGateway = $adapter.DefaultIPGateway -join ', '
        MACAddress = $adapter.MACAddress
        DHCPEnabled = $adapter.DHCPEnabled
        NetworkProfile = Get-NetworkProfile -Caption $adapter.Caption
    }

    # Add the adapter information to the array
    $adapterInfo += $info
}

# Display the report output in a table format
$adapterInfo | Format-Table -AutoSize
