# Recovering the current path
$CurrentRepo = Get-Location

# Recovering the script installation path. If no value is entered, it will be installed in the current folder.
$ScriptRepo = Read-Host "Repository to install the script (current: $CurrentRepo)"
if (-not $ScriptRepo) {
    $ScriptRepo = $CurrentRepo
}
else {
    $ScriptRepo = "$ScriptRepo\ADUserMgt"
    Write-Host -ForegroundColor Blue "Installation of the script in the repository: $ScriptRepo"
    $ParentPath = Split-Path $ScriptRepo
    # Create the ADUserMgt directory and copy scripts into it.
    New-Item -Path $ParentPath -Name "ADUserMgt" -ItemType Directory | Out-Null
    Copy-Item -Path "$CurrentRepo\*" -Destination "$ScriptRepo\" -Force
}

$OldValue = "<script_repository>"
$NewValue = $ScriptRepo
$Path = "$ScriptRepo\ADUserMgt.ps1"

Write-Host -ForegroundColor Blue "Add the path to the configuration file in the script"
# Modifying the path to the configuration file in the script 
(Get-Content -Path $Path) -replace $OldValue, $NewValue | Set-Content -Path $Path -Force

$CONTINUE = $true
while ($CONTINUE) {
    $PathChoice = Read-Host "Edit the Path variable for all users (y/n)"
    switch ($PathChoice) {
        y {
            # Edit the Path variable for all users
            Write-Host -ForegroundColor Blue "Edit the Path variable environment for all users"
            setx /M Path "%Path%;$ScriptRepo\ADUserMgt"
            Write-Host -ForegroundColor Blue "Path edit for all users"
            $CONTINUE = $false
        }
        n {
            # Edit the Path variable for current user
            Write-Host -ForegroundColor Blue "Edit the Path variable environment for the current user"
            setx Path "%Path%;$ScriptRepo\ADUserMgt"
            Write-Host "Path edit only for current user"
            $CONTINUE = $false
        }
        Default { 
            Write-Host -ForegroundColor Red "Wrong choice... The Path variable has not been modified." 
        }
    }
}
Write-Host 
Write-Host -ForegroundColor Green "The script has been installed in $ScriptRepo"
Write-Host -ForegroundColor Yellow "To use the script correctly, you have to configure the configuration file : $ScriptRepo\config.psd1"
