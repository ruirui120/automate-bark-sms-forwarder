param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [Parameter(Mandatory = $true)]
    [string]$Search,

    [Parameter(Mandatory = $true)]
    [string]$Replacement
)

$searchBytes = [System.Text.Encoding]::UTF8.GetBytes($Search)
$replacementBytes = [System.Text.Encoding]::UTF8.GetBytes($Replacement)

if ($searchBytes.Length -ne $replacementBytes.Length) {
    throw "Search and replacement must have the same UTF-8 byte length."
}

$inputFile = (Resolve-Path -LiteralPath $InputPath).Path
$bytes = [System.IO.File]::ReadAllBytes($inputFile)
$matches = 0

for ($i = 0; $i -le $bytes.Length - $searchBytes.Length; $i++) {
    $matched = $true
    for ($j = 0; $j -lt $searchBytes.Length; $j++) {
        if ($bytes[$i + $j] -ne $searchBytes[$j]) {
            $matched = $false
            break
        }
    }

    if (-not $matched) {
        continue
    }

    [System.Array]::Copy($replacementBytes, 0, $bytes, $i, $replacementBytes.Length)
    $matches++
    $i += $searchBytes.Length - 1
}

if ($matches -ne 1) {
    throw "Expected exactly one match, found $matches. Output was not written."
}

$outputFile = [System.IO.Path]::GetFullPath($OutputPath)
$outputDirectory = [System.IO.Path]::GetDirectoryName($outputFile)
[System.IO.Directory]::CreateDirectory($outputDirectory) | Out-Null
[System.IO.File]::WriteAllBytes($outputFile, $bytes)

Write-Output "Created sanitized flow: $outputFile"

