$moduleRaw = Get-Content ./.gitmodules
$moduleGit = (git config -f ./.gitmodules -l)
$subModules = @()


foreach ($a in $moduleRaw) {
    if ($a.Contains('[') -and $a.Contains(']')){
        #Write-Output "$a"
        $name = $a.Trim('[',']').Split(' ')[1].Trim('"')
        $subModules += [PSCustomObject]@{
            Name = $name
        }
    }
}
Write-Output $env:TOKEN

foreach ($a in $moduleGit) {
    $aa = $a -replace '\Asubmodule.', ''
    $bb = $aa -split '(^[^.]+).' | Select-Object -Skip 1
    if ($subModules.Name -contains $bb[0]) {
        Write-Output "Found submodule"
        $i = $subModules.Name.IndexOf($bb[0])
        foreach ($item in $bb) {
            if ($item -match "path") {
                Write-Host "PATH FOUND"
                $subModules[$i] | Add-Member -NotePropertyName "path" -NotePropertyValue ($item.Split('=')[1])
            }
            elseif ($item -match "url") {
            Write-Host "URL FOUND"
            $subModules[$i] | Add-Member -NotePropertyName "url" -NotePropertyValue ($item.Split('=')[1])
            }
        }
    }
}

foreach ($module in $subModules) {
    if ((Test-Path $module.Path) -eq $true) {
        Write-Host "path exisist"
        # git clone $module.url $module.path
        Remove-Item $module.path -Recurse -Force
        if ((Test-Path $module.Path) -eq $false) {
            New-Item -Path . -Name $module.path -ItemType Directory
        }
    }
    else {
        Write-Host "path does not exist, creating new"
        New-Item -Path . -Name $module.path -ItemType Directory
    }
    # git clone $module.url $module.path
}
Get-Location
exit



# foreach ($a in $i[5]) {
#     # Write-Output "Raw: $a"
#     $aa = $a -replace '\Asubmodule.', ''
#     write-output "Trimmed: $aa"
#     $aa -split '^(.+?)'
# }


# foreach ($a in $i[5]) {
#     Write-Output $a
#     $aa = $a -replace '\Asubmodule.', ''
#     $aa -split '^\.'
# }