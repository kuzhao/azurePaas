using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

function convertFrom-base36
{
    [CmdletBinding()]
    param ([parameter(valuefrompipeline=$true, HelpMessage="Alphadecimal string to convert")][string]$base36Num="")
    $alphabet = "0123456789abcdefghijklmnopqrstuvwxyz"
    $inputarray = $base36Num.tolower().tochararray()
    [array]::reverse($inputarray)
    [long]$decNum=0
    $pos=0

    foreach ($c in $inputarray)
    {
        $decNum += $alphabet.IndexOf($c) * [long][Math]::Pow(36, $pos)
        $pos++
    }
    $decNum
}
# Write to the Azure Functions log stream.
Write-Host "AKS MC RG: $env:AKSRG"

# Interact with query parameters or the body of the request.
$vmname = $Request.Query.Name
$Action = $Request.Query.Action
if (-not $vmname -Or -not $Action) {
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::NotAcceptable
        Body = 'Node name or action not given'
    })
    Exit
} 

# VM interaction logic starts here
Connect-AzAccount -Identity
$machineID = ($vmname | Select-String -Pattern '\d+$').Matches.Value
$vmssName = ($vmname | Select-String -Pattern '^.+vmss').Matches.Value
if (-not $machineID -Or -not $vmssName) {
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::NotAcceptable
        Body = 'Node name invalid. An AKS node name should look like "aks-xxxx-vmss00xxxx"'
    })
    Exit
} 
$vmssInstanceID = convertFrom-base36($machineID)

switch ($Action)
{
    'reboot' {
        Restart-AzVmss -ResourceGroupName $env:AKSRG -VMScaleSetName $vmssName -InstanceId $vmssInstanceID -AsJob
    }
    'reimage' {
        Set-AzVmssVM -ResourceGroupName $env:AKSRG -VMScaleSetName $vmssName -InstanceId $vmssInstanceID -Reimage -AsJob
    }
    Default {
        $body = 'Invalid action.'
        $status = [HttpStatusCode]::NotAcceptable
    }
}
if ($body -ne 'Invalid action.') {
    if ($?) {
        $body = "The action $Action was proceeded successfully."
        $status = [HttpStatusCode]::OK
    } else {
        $body = "$Action failed, please try again after 5min."
        $status = [HttpStatusCode]::InternalServerError
    }
}
# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $status
    Body = $body
})
