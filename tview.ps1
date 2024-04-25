$fqdn = $env:userdnsdomain
$parts = $fqdn.split('.')
$full = "DC=" + ($parts -join ",DC=")

# Function to retrieve Domain Admins
function Get-DomainAdmins {
    # Retrieve Domain Admins group members
    $domainAdmins = ([adsisearcher]"(memberof=cn=Domain Admins,cn=Users,$full)").FindAll().GetDirectoryEntry() | Select-Object -ExpandProperty samaccountname

    # Output Domain Admins
    Write-Output "Domain Admins"
    Write-Output "--------------"
    $domainAdmins
}

# Function to retrieve Domain Users
function Get-DomainUsers {
    # Retrieve all domain users
    $domainUsers = ([adsisearcher]"(&(objectClass=user)(objectCategory=person))").FindAll().GetDirectoryEntry() | Select-Object -ExpandProperty samaccountname

    # Output Domain Users
    Write-Output "Domain Users"
    Write-Output "--------------"
    $domainUsers
}

function Get-DomainControllers {
    $DCs = ([ADSISearcher] "(&(objectCategory=computer)(objectClass=computer))").FindAll().GetDirectoryEntry() | Where-Object -Property primarygroupID -match 516
    
    foreach ($dc in $DCs) {
        $DChostname = $dc.Properties["dnshostname"].Value
        $DCoperatingsystem = $dc.Properties["operatingsystem"].Value
        
        if ($DCoperatingsystem -is [Array]) {
            foreach ($os in $DCoperatingsystem) {
                Write-Output "DC Hostname: $DChostname Operating System: $os"
            }
        } else {
            Write-Output "DC Hostname: $DChostname Operating System: $DCoperatingsystem"
        }
    }
}

function Get-Kerberoasting {
    $kerbs = ([adsisearcher]'(&(samAccountType=805306368)(servicePrincipalName=*)(!samAccountName=krbtgt)(!(UserAccountControl:1.2.840.113556.1.4.803:=2)))').FindAll().GetDirectoryEntry()| Select-Object -ExpandProperty samaccountname
    Write-Output "Kerberoastable Users"
    Write-Output "--------------"
    $kerbs
}

function Get-ASREProasting {
	$asrep = ([adsisearcher]'(&(samAccountType=805306368)(userAccountControl:1.2.840.113556.1.4.803:=4194304))').findall().getdirectoryentry() | select-object -ExpandProperty samaccountname
	Write-Output "ASREP-roastable Users"
    Write-Output "--------------"
    $asrep
}

function Get-Unconstrained {
	$unconstrained = ([adsisearcher]'(&(userAccountControl:1.2.840.113556.1.4.803:=524288)(!primarygroupID=516))').findall().getdirectoryentry()|Select-Object -expandProperty dnshostname
	Write-Output "Computers configured with Unconstrained delegation"
    Write-Output "--------------"
    $unconstrained
}

function Get-Constrained {
    $constrained = ([adsisearcher]'(msds-allowedtodelegateto=*)').FindAll().GetDirectoryEntry()
    Write-Output "Computers configured with constrained delegation"
    Write-Output "--------------"

    foreach ($entry in $constrained) {
        $hostname = $entry.Properties["dnshostname"].Value
        $services = $entry.Properties["msDS-AllowedToDelegateTo"].Value

        if ($services -is [Array]) {
            foreach ($service in $services) {
                Write-Output "$hostname Service: $service"
            }
        } else {
            Write-Output "$hostname Service: $services"
        }
    }
}

Write-Host -foregroundcolor green "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
Write-Host -foregroundcolor green -nonewline "++++++++++++++++++++"
Write-Host -foregroundcolor red -nonewline "Domain Admins"
Write-Host -foregroundcolor green "++++++++++++++++++++++"
Write-Host -foregroundcolor green "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
Write-Host""
Get-DomainAdmins
Write-Host ""
Write-Host -foregroundcolor green "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
Write-Host -foregroundcolor green -nonewline "+++++++++++++++++++++"
Write-Host -foregroundcolor red -nonewline "Domain Users"
Write-Host -foregroundcolor green "++++++++++++++++++++++"
Write-Host -foregroundcolor green "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
Write-Host ""
Get-DomainUsers
Write-Host ""
Write-Host -foregroundcolor green "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
Write-Host -foregroundcolor green -nonewline "+++++++++++++++++"
Write-Host -foregroundcolor red -nonewline "Kerberoastable SPNs"
Write-Host -foregroundcolor green "+++++++++++++++++++"
Write-Host -foregroundcolor green "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
Write-Host ""
Get-Kerberoasting
Write-Host ""
Write-Host -foregroundcolor green "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
Write-Host -foregroundcolor green -nonewline "++++++++++++++++"
Write-Host -foregroundcolor red -nonewline "ASREP-roastable users"
Write-Host -foregroundcolor green "++++++++++++++++++"
Write-Host -foregroundcolor green "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
Write-Host ""
Get-ASREProasting
Write-Host ""
Write-Host -foregroundcolor green "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
Write-Host -foregroundcolor green -nonewline "+++++++"
Write-Host -foregroundcolor red -nonewline "Computers with unconstrained delegation"
Write-Host -foregroundcolor green "+++++++++"
Write-Host -foregroundcolor green "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
Write-Host ""
Get-Unconstrained
Write-Host ""
Write-Host -foregroundcolor green "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
Write-Host -foregroundcolor green -nonewline "++++++++"
Write-Host -foregroundcolor red -nonewline "Computers with constrained delegation"
Write-Host -foregroundcolor green "++++++++++"
Write-Host -foregroundcolor green "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
Write-Host ""
Get-Constrained
Write-Host ""
Write-Host -foregroundcolor green "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
Write-Host -foregroundcolor green -nonewline "++++++++++++++++++"
Write-Host -foregroundcolor red -nonewline "Domain Controllers"
Write-Host -foregroundcolor green "+++++++++++++++++++"
Write-Host -foregroundcolor green "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
Write-Host ""
Get-DomainControllers
