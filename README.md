# ADUserMgt

ADUserMgt is a Powershell script used to manage Active Directory users.

All possible actions are listed in the menu. You just have to choose the action you want to do and fill in the fields that appear.
The script can be used to Create, Edit, Delete, Reset, Enable, Disable user account(s).

It's also possible to administrate MS LAPS with the script.

## Installation

### Installation via Github

Open PowerShell console as administrator.

```bash
git clone https://github.com/Kyube5/ADUserMgt.git
cd ADUserMgt
./setup.ps1
```

### Manual installation 

Download the zip file and put it in your scripts repository on the server.

Add the repository to the Path variable environment

Open PowerShell console as administrator.

```bash
# For the current user only :
setx Path "%Path%;<script_repository>\ADUserMgt"

# For all users :
setx /M Path "%Path%;<script_repository>\ADUserMgt"
```


Edit the configuration file path on the script : ``ADUserMgt.ps1``

```powershell
$CONFIG = Import-PowerShellDataFile -Path '<script_repository>\config.psd1' -ErrorAction Stop
```

## Configuration
Edit the configuration file : ``config.psd1``

```powershell
@{
    Domain = "domain.local"
    
    DomainName = "DOMAIN-NAME"
    
    DomainOU = @{
        STANDARD = "OU=Users,DC=Domain,DC=local"
        ADML1 = "OU=Admins,DC=Domain,DC=local"
        ADML2 = "OU=Admins,DC=Domain,DC=local"
        ADML3 = "OU=Admins,DC=Domain,DC=local"
        GROUPS = "OU=Groups,DC=Domain,DC=local"
        COMPUTERS = "OU=Computers,DC=Domain,DC=local"
    }

    Paths = @{
        CSVInventoryParentPath = "<inventory_repository>"
        CSVManualInventoryName = "\Manual\Manual_<domain>_Inventory_"
        CSVAutoInventoryName = "<domain>_Inventory.csv"
    }
    
}
```
## Usage
Run a Powershell prompt as Administrator and type 

```bash
ADUserMgt
```

Choose your action on the list and follow the instructions.

```Powershell
************************** DC Administration **************************

1 - Create a domain user
2 - Reset the domain user password
3 - Add a user to group(s)
4 - Update user informations
5 - Update multiple users informations
6 - Enable a domain user
7 - Disable a domain user
8 - Delete a domain user
9 - Get domain user inventory

************************** LAPS Administration ************************

10 - Get LAPS information of a domain computer
11 - Get LAPS information of all domain computers
12 - Reset the Administrator password of a domain computer

***********************************************************************
0 - Exit
***********************************************************************

Action:
```

