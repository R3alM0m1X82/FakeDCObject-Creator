# FakeDCObject-Creator.ps1

## 📝 Description

**FakeDCObject-Creator** is a PowerShell script designed for Red Team labs to automate the creation of a fake computer object with `SERVER_TRUST_ACCOUNT` privileges. This allows advanced Active Directory persistence.

The script:

- Creates a fake computer account in Active Directory.
- Moves it to the domain's `LostAndFound` container.
- Modifies its `userAccountControl` attribute to `8192` (SERVER_TRUST_ACCOUNT) and `primaryGroupID` to `516`, granting DCSync-like privileges.

---

## ⚠️ Usage Warning

This script is intended **only for educational and authorized environments**. Do **not** use for evil purposes.

---

## 🔧 Requirements
DA Privileges

- **Modules and tools**:
  - [Powermad.ps1](https://github.com/Kevin-Robertson/Powermad)
  - PowerView.ps1
  - ADModule-master (Microsoft.ActiveDirectory.Management.dll)
- **Permissions**:
  - Domain user with sufficient rights to create computer accounts.

---

## 🚀 Usage

```powershell
# Import the script
. C:\Tools\FakeDCObject-Creator.ps1

# Run the function with mandatory parameters
Invoke-FakeDCObjectCreation -MachineAccount FakeDCWS01 -Password P@ssw0rd! -Verbose
