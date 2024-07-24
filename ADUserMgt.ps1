<#

.SYNOPSIS
    This script is design to consolidate and simplify the processing of Active Directory users.

.DESCRIPTION
    All treatments are listed in the menu. You just have to choose the action you want to do and fill in the fields that appear.
    The possible treatments are Create/Edit/Delete/Reset/Enable/Disable user account(s).
    It's also possible to administrate MS LAPS with the script.
    
.NOTES
    NAME:       ADUserMgt.ps1
    AUTHOR:     BELKACEM Quentin
    EMAIL:      quentin.belkacem@gmail.com
    OWNER:      

    VERSION HISTORY:
    1.0  2023.11.15  Initial Version
    2.0  2024.02.19  Include config file

#>

Write-Host -ForegroundColor DarkCyan @"

    .oPYo. 8PYYo. 8    8                 8oYoYo. .oPYo. OPYPO
    8    8 8    8 8    8 oOOo 8ooo 8PYo  8  8  8 8        8
    8oooo8 8    8 8    8 'O,  8oo  8oo'  8  8  8 8  ooO   8
    8    8 8PYYP' 'PYYP' oooO 8ooo 8  8  8  8  8 'YooP'   8

oOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOo0oOoOoOoO


"@

$CONFIG = Import-PowerShellDataFile -Path '<script_repository>\config.psd1' -ErrorAction Stop

$CSVPATH = $CONFIG.Paths.CSVInventoryParentPath
$CSVAUTOPATH = $CONFIG.Paths.CSVInventoryParentPath + $CONFIG.Paths.CSVAutoInventoryName
$CONTINUE = $true

while ($CONTINUE) {
    Write-Host
    Write-Host
    Write-Host "************************** DC Administration **************************"
    Write-Host
    Write-Host "1 - Create a domain user"
    Write-Host "2 - Reset the domain user password"
    Write-Host "3 - Add a user to group(s)"
    Write-Host "4 - Update user informations"
    Write-Host "5 - Update multiple users informations"
    Write-Host "6 - Enable a domain user"
    Write-Host "7 - Disable a domain user"
    Write-Host "8 - Delete a domain user"
    Write-Host "9 - Get domain user inventory"
    Write-Host
    Write-Host "************************** LAPS Administration ************************"
    Write-Host
    Write-Host "10 - Get LAPS information of a domain computer"
    Write-Host "11 - Get LAPS information of all domain computers"
    Write-Host "12 - Reset the Administrator password of a domain computer"
    Write-Host
    Write-Host "***********************************************************************"
    Write-Host "0 - Exit"
    Write-Host "***********************************************************************"
    Write-Host

    $choice = Read-Host "Action"
    switch ($choice) {
### 1 - Create a domain user ###
        1 {
            Write-Host -ForegroundColor Blue "[i] Create a user in the $((Get-ADDomain).DNSRoot) domain`n"
            Write-Host -ForegroundColor Blue "[i] Please fill in the following fields`n"
            $UserFirstname = Read-Host -Prompt "Firstname" 
            $UserName = Read-Host -Prompt "Name"
            $WhileTest = 0
            while ($WhileTest -eq 0) {
                $UserPassword = Read-Host -Prompt "Password" -AsSecureString
                $UserCheckPassword = Read-Host -Prompt "Password check" -AsSecureString
                $UserPasswordClr = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($UserPassword))
                $UserCheckPasswordClr = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($UserCheckPassword))
                if ($UserPasswordClr -ceq $UserCheckPasswordClr) {
                    $WhileTest = 1
                    $UserPasswordClr = ""
                    $UserCheckPasswordClr = ""
                }
                else {
                    Write-Warning "[!] The passwords doesn't match"
                }
            }
            $UserEmail = Read-Host -Prompt "Email address" 
            $UserEmployeeID = Read-Host -Prompt "Employee ID"
            
            $Again = $true
            While ($Again) {
                $UserDescription = Read-Host -Prompt "Role :
    0) Standard user
    1) L1 Administrator (Computers administrators)
    2) L2 Administrator (Servers administrators)
    3) L3 Administrator (Domain administrators)
Choice"
                switch ($UserDescription) {
                    0 {
                        $UserOU = $CONFIG.DomainOU.STANDARD
                        $p = $UserFirstname.Substring(0, 1)
                        $UserLogin = $p + $UserName
                        $UserLogin = $UserLogin.ToLower()
                        $UserDescription = "Standard domain user"
                        $UserDisplayName = $UserFirstname + " " + $UserName
                        $Again = $false
                    }
                    1 {
                        $UserOU = $CONFIG.DomainOU.ADML1
                        $p = $UserFirstname.Substring(0, 1)
                        $UserLogin = "adm-l1c-" + $p + $UserName
                        $UserLogin = $UserLogin.ToLower()
                        $UserDescription = "L1 - Computers Administrator"
                        $UserDisplayName = $UserFirstname + " " + $UserName + " L1"
                        $Again = $false
                    }
                    2 {
                        $UserOU = $CONFIG.DomainOU.ADML2
                        $p = $UserFirstname.Substring(0, 1)
                        $UserLogin = "adm-l2c-" + $p + $UserName
                        $UserLogin = $UserLogin.ToLower()
                        $UserDescription = "L2 - Servers Administrator"
                        $UserDisplayName = $UserFirstname + " " + $UserName + " L2"
                        $Again = $false
                    }
                    3 {
                        $UserOU = $CONFIG.DomainOU.ADML3
                        $p = $UserFirstname.Substring(0, 1)
                        $UserLogin = "adm-l3c-" + $p + $UserName
                        $UserLogin = $UserLogin.ToLower()
                        $UserDescription = "L3 - Domain Administrator"
                        $UserDisplayName = $UserFirstname + " " + $UserName + " L3"
                        $Again = $false
                    }
                    Default { 
                        Write-Host -ForegroundColor Red "Wrong choice" 
                    }
                }
            }
            $UserGroups = (Get-ADGroup -Filter * -SearchBase $CONFIG.DomainOU.GROUPS).Name | Out-GridView -Title "Choose one or more groups for the user" -PassThru
            Write-Host -ForegroundColor Blue "`n[i] Creating of the user account in the domain...`n"

            # Test if the login already exists
            if (Get-ADUser -Filter { SamAccountName -eq $UserLogin }) {
                Write-Warning "[!] The login $UserLogin already exits in the domain"
            }
            else {
                try {
                    New-ADUser -Name $UserDisplayName `
                        -DisplayName $UserDisplayName `
                        -GivenName $UserFirstname `
                        -Surname $UserName `
                        -SamAccountName $UserLogin `
                        -UserPrincipalName "$UserLogin@$((Get-ADDomain).DNSRoot)" `
                        -EmailAddress $UserEmail `
                        -EmployeeNumber $UserEmployeeID `
                        -Description $UserDescription `
                        -Path $UserOU `
                        -AccountPassword $UserPassword `
                        -ChangePasswordAtLogon $true `
                        -Enabled $true
                }
                catch {
                    Write-Warning "$($_.Exception.Message)"
                }
            }

            # Adding in the groups
            Foreach ($Groupe in $UserGroups) {
                try {
                    Write-Host -ForegroundColor Blue "[i] The user $UserLogin will be add to the group: $Groupe"
                    Add-ADGroupMember -Identity $Groupe -Members $UserLogin
                }
                catch {
                    Write-Warning "$($_.Exception.Message)"
                }
            }
            Get-ADUser -Filter * -Properties Surname, GivenName, SamAccountName, Enabled, EmailAddress, EmployeeNumber, Description, DistinguishedName | 
            Select-Object Surname, GivenName, SamAccountName, Enabled, EmailAddress, EmployeeNumber, Description, DistinguishedName | 
            Sort-Object -Property Surname |
            Export-Csv -Encoding UTF8 -NoTypeInformation -Delimiter ";" -Path $CSVAUTOPATH
            Write-Host -ForegroundColor Green "[+] The user account has been successfully created"
        }

### 2 - Reset the domain user password ###
        
        2 {
            $UserLogin = Read-Host -Prompt "User login"
            if (Get-ADUser -Filter { SamAccountName -eq $UserLogin }) {
                Write-Host
                Write-Host -ForegroundColor Blue "[i] Reset the $UserLogin password"
                Write-Host
                $WhileTest = 0
                $WhileTest = 0
            while ($WhileTest -eq 0) {
                $UserPassword = Read-Host -Prompt "Password" -AsSecureString
                $UserCheckPassword = Read-Host -Prompt "Password check" -AsSecureString
                $UserPasswordClr = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($UserPassword))
                $UserCheckPasswordClr = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($UserCheckPassword))
                if ($UserPasswordClr -ceq $UserCheckPasswordClr) {
                    $WhileTest = 1
                    $UserPasswordClr = ""
                    $UserCheckPasswordClr = ""
                }
                else {
                    Write-Warning "[!] The passwords doesn't match"
                }
            }
                try {
                    Set-ADAccountPassword -Identity $UserLogin -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $UserPassword -Force)
                    Write-Host -ForegroundColor Green "[+] Password reset with success"
                }
                catch {
                    Write-Warning "$($_.Exception.Message)"
                }
            }
            else {
                Write-Warning "[!] The login $UserLogin doesn't exits in the domain"
            }
        }

### 3 - Add a user to group(s) ###
        
        3 {
            $UserLogin = Read-Host -Prompt "User login"
            
            if (Get-ADUser -Filter { SamAccountName -eq $UserLogin }) {
                $UserGroups = (Get-ADGroup -Filter * -SearchBase $CONFIG.DomainOU.GROUPS).Name | Out-GridView -Title "Choose one or more groups for the user" -PassThru
                try {
                    Foreach ($Groupe in $UserGroups) {
                        try {
                            Write-Host -ForegroundColor Blue "[i] The user $UserLogin will be add to the group: $Groupe"
                            Add-ADGroupMember -Identity $Groupe -Members $UserLogin
                        }
                        catch {
                            Write-Warning "$($_.Exception.Message)"
                        }
                    }
                }
                catch {
                    Write-Warning "$($_.Exception.Message)"
                }
            }
            else {
                Write-Warning "[!] The login $UserLogin doesn't exits in the domain"
            }
        }

### 4 - Update user informations ###
        
        4 {
            $UserLogin = Read-Host -Prompt "User login"
            if (Get-ADUser -Filter { SamAccountName -eq $UserLogin }) {
                $InfoList = @"
    1 - Name
    2 - Firstname
    3 - Email address
    4 - Description (Role)
    5 - Employee ID
"@
                Write-Host          
                Write-Host $InfoList
                $UserInfo = Read-Host -Prompt "`nWhat information do you want to update"
                Write-Host
                switch ($UserInfo) {
                    1 {
                        $NewValue = Read-Host -Prompt "Enter the name"
                        Set-ADUser -Identity $UserLogin -Surname $NewValue
                        Write-Host -ForegroundColor Green "[+] The name of $UserLogin has been updated by the value $NewValue."
                    }
                    2 {
                        $NewValue = Read-Host -Prompt "Enter the firstname"
                        Set-ADUser -Identity $UserLogin -GivenName $NewValue
                        Write-Host -ForegroundColor Green "[+] The firstname of $UserLogin has been updated by the value $NewValue."
                    }
                    3 {
                        $NewValue = Read-Host -Prompt "Enter the email address"
                        Set-ADUser -Identity $UserLogin -EmailAddress $NewValue
                        Write-Host -ForegroundColor Green "[+] The email address of $UserLogin has been updated by the value $NewValue."
                    }
                    4 {
                        $NewValue = Read-Host -Prompt "Enter the description"
                        Set-ADUser -Identity $UserLogin -Description $NewValue
                        Write-Host -ForegroundColor Green "[+] The description of $UserLogin has been updated by the value $NewValue."
                    }
                    5 {
                        $NewValue = Read-Host -Prompt "Enter the Employee ID"
                        Set-ADUser -Identity $UserLogin -EmployeeNumber $NewValue
                        Write-Host -ForegroundColor Green "[+] The Employee ID of $UserLogin has been updated by the value $NewValue."
                    }
                    Default { 
                        Write-Host -ForegroundColor Red "Wrong choice" 
                    }
                }
            }
            else {
                Write-Warning "[!] The login $UserLogin doesn't exits in the domain"
            }            
            Get-ADUser -Filter * -Properties Surname, GivenName, SamAccountName, Enabled, EmailAddress, EmployeeNumber, Description, DistinguishedName | 
            Select-Object Surname, GivenName, SamAccountName, Enabled, EmailAddress, EmployeeNumber, Description, DistinguishedName | 
            Sort-Object -Property Surname |
            Export-Csv -Encoding UTF8 -NoTypeInformation -Delimiter ";" -Path $CSVAUTOPATH
        }

### 5 - Update multiple users informations ###
        
        5 {
            $CsvFile = Read-Host -Prompt "Enter the path of your CSV file"
            $CsvDatas = Import-Csv -Path $CsvFile -Delimiter ";" -Encoding UTF8

            foreach ($User in $CsvDatas) {
                $UserLogin = $User.SamAccountName 
                if (Get-ADUser -Identity $UserLogin) {
                    Write-Host -ForegroundColor Blue "The user exists, it will be update."
                    Set-ADUser -Identity $UserLogin -Replace @{description = $User.Description }
                    Set-ADUser -Identity $UserLogin -Replace @{employeeNumber = $User.EmployeeNumber }
                    Set-ADUser -Identity $UserLogin -Replace @{mail = $User.EmailAddress }
                }
            }
        }

### 6 - Enable a domain user ###
        
        6 {
            $UserLogin = Read-Host -Prompt "User login"
            if (Get-ADUser -Filter { SamAccountName -eq $UserLogin }) {
                Write-Host
                try {
                    Set-ADUser -Identity $UserLogin -Enabled $true
                    Get-ADUser -Filter * -Properties Surname, GivenName, SamAccountName, Enabled, EmailAddress, EmployeeNumber, Description, DistinguishedName | 
                    Select-Object Surname, GivenName, SamAccountName, Enabled, EmailAddress, EmployeeNumber, Description, DistinguishedName | 
                    Sort-Object -Property Surname |
                    Export-Csv -Encoding UTF8 -NoTypeInformation -Delimiter ";" -Path $CSVAUTOPATH
                    Write-Host -ForegroundColor Green "[+] The user account has been successfully enabled"
                }
                catch {
                    Write-Warning "$($_.Exception.Message)"
                }
            }
            else {
                Write-Warning "[!] The login $UserLogin doesn't exits in the domain"
            } 
        }

### 7 - Disable a domain user ###
        
        7 {
            $UserLogin = Read-Host -Prompt "User login"
            if (Get-ADUser -Filter { SamAccountName -eq $UserLogin }) {
                Write-Host
                try {
                    Set-ADUser -Identity $UserLogin -Enabled $false
                    Get-ADUser -Filter * -Properties Surname, GivenName, SamAccountName, Enabled, EmailAddress, EmployeeNumber, Description, DistinguishedName | 
                    Select-Object Surname, GivenName, SamAccountName, Enabled, EmailAddress, EmployeeNumber, Description, DistinguishedName | 
                    Sort-Object -Property Surname |
                    Export-Csv -Encoding UTF8 -NoTypeInformation -Delimiter ";" -Path $CSVAUTOPATH
                    Write-Host -ForegroundColor Green "[+] The user account has been successfully disabled"
                }
                catch {
                    Write-Warning "$($_.Exception.Message)"
                }
            }
            else {
                Write-Warning "[!] The login $UserLogin doesn't exits in the domain"
            } 
        }

### 8 - Delete a domain user ###
        
        8 {
            $UserLogin = Read-Host -Prompt "User login"
            if (Get-ADUser -Filter { SamAccountName -eq $UserLogin }) {
                Write-Host
                Write-Warning "[!] Do you want to remove the user $UserLogin of the domain ?"
                $DeleteUser = Read-Host -Prompt "Enter the user login to confirm"
                Write-Host
                switch ($DeleteUser) {
                    $UserLogin {
                        Write-Host
                        Write-Host -ForegroundColor Blue "[i] Removing of the $UserLogin user..."
                        Write-Host
                        Remove-ADUser -Identity $UserLogin
                    }
                    Default { 
                        Write-Host -ForegroundColor Red "The logins doesn't match" 
                    }
                    try {
                        Set-ADAccountPassword -Identity $UserLogin -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $NewPassword -Force)
                        Write-Host -ForegroundColor Green "[+] User removed with success"
                    }
                    catch {
                        Write-Warning "$($_.Exception.Message)"
                    }
                }
            }
            else {
                Write-Warning "[!] The login $UserLogin doesn't exits in the domain"
            }            
            Get-ADUser -Filter * -Properties Surname, GivenName, SamAccountName, Enabled, EmailAddress, EmployeeNumber, Description, DistinguishedName | 
            Select-Object Surname, GivenName, SamAccountName, Enabled, EmailAddress, EmployeeNumber, Description, DistinguishedName | 
            Sort-Object -Property Surname |
            Export-Csv -Encoding UTF8 -NoTypeInformation -Delimiter ";" -Path $CSVAUTOPATH
        }

### 9 - Get domain user inventory ###
        
        9 {
            $DateExport = Get-Date -Format "yyyyMMdd"
            $CSVMANUALPATH = $CSVPATH + $CONFIG.Paths.CSVManualInventoryName + $DateExport + ".csv"
            Get-ADUser -Filter * -Properties Surname, GivenName, SamAccountName, EmailAddress, EmployeeNumber, Description, DistinguishedName | 
            Select-Object Surname, GivenName, SamAccountName, Enabled, EmailAddress, EmployeeNumber, Description, DistinguishedName | 
            Sort-Object -Property Surname |
            Export-Csv -Encoding UTF8 -NoTypeInformation -Delimiter ";" -Path $CSVMANUALPATH
            Invoke-Item $CSVMANUALPATH
        }

### 10 - Get LAPS information of a domain computer ###
        
        10 { 
            $ComputerName = Read-Host -Prompt "Computer name"
            Write-Host
            Write-Host -ForegroundColor Blue "[i] Administrator account informations of the $ComputerName computer: "
            Write-Host
            Get-AdmPwdPassword -ComputerName $ComputerName
        }

### 11 - Get LAPS information of all domain computers ###
        
        11 { 
            Write-Host
            Write-Host -ForegroundColor Blue "[i] Administrator account informations of all domain computers:"
            Write-Host
            Get-ADComputer -Filter * -SearchBase $CONFIG.DomainOU.COMPUTERS | Get-AdmPwdPassword
        }

### 12 - Reset the Administrator password of a domain computer ###
        
        12 { 
            $ComputerName = Read-Host -Prompt "Computer name"
            $ResetNow = Read-Host "Instant reset (y/n)"
            switch ($ResetNow) {
                "y" {
                    Write-Host
                    Write-Host -ForegroundColor Blue "[i] Reset of the $ComputerName administrator account"
                    Write-Host
                    Reset-AdmPwdPassword -ComputerName $ComputerName
                }
                "n" {
                    $DateReset = Read-Host -Prompt "Reset date (MM.dd.yyyy hh:mm)"
                    Write-Host
                    Write-Host -ForegroundColor Blue "[i] Reset of the $ComputerName administrator account"
                    Write-Host
                    Reset-AdmPwdPassword -ComputerName $ComputerName -WhenEffective $DateReset
                }
                Default { 
                    Write-Host -ForegroundColor Red "Wrong choice" 
                }
            }
        }

### 0 - Exit ###
        
        0 { 
            $CONTINUE = $false 
        }
        Default { 
            Write-Host -ForegroundColor Red "Wrong choice" 
        }
    }
}
