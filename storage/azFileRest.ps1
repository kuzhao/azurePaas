Function GetTokenStringToSign
{
    [CmdletBinding()]     
    param
    (
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('GET','PUT','DELETE')]
        [string]$Verb="GET",
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName = $true)]
        [System.Uri]$Resource,
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [long]$ContentLength,
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [String]$ContentLanguage,
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [String]$ContentEncoding,
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [String]$ContentType,
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [String]$ContentMD5,
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [long]$RangeStart,
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [long]$RangeEnd,[Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
        [System.Collections.IDictionary]$Headers
    )

    $ResourceBase=($Resource.Host.Split('.') | Select-Object -First 1).TrimEnd("`0")
    $ResourcePath=$Resource.LocalPath.TrimStart('/').TrimEnd("`0")
    $LengthString=[String]::Empty
    $Range=[String]::Empty
    if($ContentLength -gt 0){$LengthString="$ContentLength"}
    if($RangeEnd -gt 0){$Range="bytes=$($RangeStart)-$($RangeEnd-1)"}

    $SigningPieces = @($Verb, $ContentEncoding,$ContentLanguage, $LengthString,$ContentMD5, $ContentType, [String]::Empty, [String]::Empty, [String]::Empty, [String]::Empty, [String]::Empty, $Range)
    foreach ($item in $Headers.Keys)
    {
        $SigningPieces+="$($item):$($Headers[$item])"
    }
    $SigningPieces+="/$ResourceBase/$ResourcePath"

    if ([String]::IsNullOrEmpty($Resource.Query) -eq $false)
    {
        $QueryResources=@{}
        $QueryParams=$Resource.Query.Substring(1).Split('&')
        foreach ($QueryParam in $QueryParams)
        {
            $ItemPieces=$QueryParam.Split('=')
            $ItemKey = ($ItemPieces|Select-Object -First 1).TrimEnd("`0")
            $ItemValue = ($ItemPieces|Select-Object -Last 1).TrimEnd("`0")
            if($QueryResources.ContainsKey($ItemKey))
            { 
                $QueryResources[$ItemKey] = "$($QueryResources[$ItemKey]),$ItemValue"    
            }
            else
            {
                $QueryResources.Add($ItemKey, $ItemValue)
            }
        }
        $Sorted=$QueryResources.Keys|Sort-Object
        foreach ($QueryKey in $Sorted)
        {
            $SigningPieces += "$($QueryKey):$($QueryResources[$QueryKey])"
        }
    }

    $StringToSign = [String]::Join("`n",$SigningPieces)
    Write-Output $StringToSign 
}

Function EncodeStorageRequest
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String[]]$StringToSign,
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$SigningKey
    )
    PROCESS
    {         
        foreach ($item in $StringToSign)
        {
            $KeyBytes = [System.Convert]::FromBase64String($SigningKey)
            $HMAC = New-Object System.Security.Cryptography.HMACSHA256
            $HMAC.Key = $KeyBytes
            $UnsignedBytes = [System.Text.Encoding]::UTF8.GetBytes($item)
            $KeyHash = $HMAC.ComputeHash($UnsignedBytes)
            $SignedString=[System.Convert]::ToBase64String($KeyHash)
            Write-Output $SignedString 
        }     
    }
}

$StorageAccountName='vtkmnck123'
$ShareName='vmtkndi348c20'
$AccessKey="p+v3lAkMYs+TnXupRw94iRg1/aQOmtHo6vChvONLU8Pm40aZq23hzxfSvGMu2OPU3K3D1w1BO03Km4fkvqp9AQ=="
$BlobContainerUri="https://$StorageAccountName.file.core.windows.net/$ShareName/site?comp=listhandles"
$BlobHeaders= @{
    "x-ms-date"=[DateTime]::UtcNow.ToString('R');
     "x-ms-version"='2018-11-09'; 
}
$UnsignedSignature=GetTokenStringToSign -Verb GET -Resource $BlobContainerUri -AccessKey $AccessKey -Headers $BlobHeaders
$StorageSignature=EncodeStorageRequest -StringToSign $UnsignedSignature -SigningKey $SigningKey 