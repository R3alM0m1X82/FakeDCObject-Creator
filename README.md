# FakeDCObject-Creator.ps1

## Overview

**FakeDCObject-Creator.ps1** is a PowerShell function designed for **red teaming labs and Active Directory persistence**.  
It creates a **fake computer object in Active Directory**, modifies its attributes to appear as a **Domain Controller** (SERVER_TRUST_ACCOUNT + primaryGroupID 516), and thus grants **DCSync privileges** to perform replication attacks.
Need DA privileges on AD.

> ⚠️ **For education use only. Do not use for evil scopes.**

---

## Features

- Creates a computer object with custom name and password.
- Sets **userAccountControl to SERVER_TRUST_ACCOUNT (8192)**.
- Sets **primaryGroupID to 516 (Domain Controllers)**.
- Moves object to **LostAndFound container** for stealth.
- Supports **domain auto-detection** on joined machines.
- Verbose output for **training and demo clarity**.
- Function-based script for easy integration in toolkits.

---

## Requirements

- PowerShell 5.1+
- **Modules:**
  - [Powermad](https://github.com/Kevin-Robertson/Powermad)
  - Microsoft.ActiveDirectory.Management.dll
  - [PowerView](https://github.com/PowerShellMafia/PowerSploit/tree/master/Recon)

> Ensure modules are accessible in **C:\Tools\\** as per script paths, or edit accordingly.

---

## Usage

```powershell
# Import script
. C:\Tools\FakeDCObject-Creator.ps1

# Run function with mandatory parameter -MachineAccount
Invoke-FakeDCObjectCreation -MachineAccount FakeDCWS01 -Verbose

# Run from workgroup
Invoke-FakeDCObjectCreation -MachineAccount FakeDCWS01 -Domain contoso.corp -DC dc.contoso.corp -Password P@ssw0rd! -Verbose

