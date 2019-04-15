
## ---------------
# Parameters
$prmExecutionPolicy = "Unrestricted"
$prmMicrosoftPowerBIMgmt = "MicrosoftPowerBIMgmt"
$prmOnPremisesDataGatewayHAMgmtName = "OnPremisesDataGatewayHAMgmt"
$prmOnPremisesDataGatewayHAMgmtPath = "C:\Program Files\On-premises data gateway\OnPremisesDataGatewayHAMgmt.psm1"

# Variables
$varStartingLocation = Get-Location

# ExecutionPolicy Unrestricted check
If ((Get-ExecutionPolicy) -ne $prmExecutionPolicy) # check if ExecutionPolicy is set to Unrestricted
{
    Set-ExecutionPolicy -ExecutionPolicy $prmExecutionPolicy -Force
}

# OnPremisesDataGatewayHAMgmt import check
If (!(Get-Module -Name $prmOnPremisesDataGatewayHAMgmtName)) # check if OnPremisesDataGatewayHAMgmt imported
{
    # import OnPremisesDataGatewayHAMgmt
    Import-Module $prmOnPremisesDataGatewayHAMgmtPath
}

# Login to Azure using EmailAddress
Login-OnPremisesDataGateway -EmailAddress christopher.small@asmr.com # Current backend is:  https://wabi-us-east2-redirect.analysis.windows.net/

# Get the list of gateway clusters and save to .csv
$allGatewayClusters = Get-OnPremisesDataGatewayClusters
$unpackedGateways = @()
foreach($cluster in $allGatewayClusters)
{
    foreach($gateway in $cluster.gateways | ConvertFrom-Json) 
    {
        foreach($property in $cluster.PSObject.Properties)
        {
            if($property.Name -ne "gateways" -and $property.Name -ne "expiryDate") 
            {
                $gateway | Add-Member -MemberType NoteProperty -Name $property.Name -Value $property.Value
            }
        }

        $unpackedGateways += $gateway

    }
    
}


$unpackedGateways | Export-Csv -Path $HOME\Documents\PowerShellResults\GatewayClusters.csv -Delimiter ";" -NoTypeInformation

# Get the list of gateways within each cluster and save to .csv
Write-Host "Write gateways for each cluster"
$allClusterGateways = @()

foreach($cluster in $allGatewayClusters)
{
    # 
    $gateways = Get-OnPremisesDataClusterGateways -ClusterObjectId $cluster.objectId
    # 
	$gateways | ForEach-Object{
		$_ | Add-Member -MemberType NoteProperty -Name "Cluster ObjectId" -Value $cluster.objectId
    }
    # 
	$gateways | ForEach-Object{
		$_ | Add-Member -MemberType NoteProperty -Name "Cluster Name" -Value $cluster.name
    }
    # 
	$allClusterGateways = $allClusterGateways + $gateways
}
# 
$allClusterGateways | Export-Csv -Path $HOME\Documents\PowerShellResults\ClusterGateways.csv -Delimiter ";" -NoTypeInformation

# 

# Count
Write-Host $allGatewayClusters.Count "GatewayClusters exported to .csv"
Write-Host $allClusterGateways.Count "ClusterGateways exported to .csv"
# 
Write-Host "Complete"