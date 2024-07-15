@{
    Domain = "domain.local"
    
    DomainName = "DOMAIN"
    
    DomainOU = @{
        STANDARD = "OU=Users,DC=domain,DC=local"
        ADML1 = "OU=ADMINS,OU=L1,OU=_ACCOUNTS,DC=domain,DC=local"
        ADML2 = "OU=ADMINS,OU=L2,OU=_ACCOUNTS,DC=domain,DC=local"
        ADML3 = "OU=ADMINS,OU=L3,OU=_ACCOUNTS,DC=domain,DC=local"
        GROUPS = "OU=Groups,DC=domain,DC=local"
        COMPUTERS = "OU=Computers,DC=domain,DC=local"
    }

    Paths = @{
        CSVInventoryParentPath = "<INVENTORY-PATH>\"
        CSVManualInventoryName = "\Manual\Manual_<DOMAIN>UserInventory_"
        CSVAutoInventoryName = "<DOMAIN>UserInventory.csv"
    }
    
}
