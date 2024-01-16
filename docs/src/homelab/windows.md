# Windows

## Overview

Windows configurations

## Disable Windows 11 Context Menu

https://www.reddit.com/r/Windows11/comments/pu5aa3/howto_disable_new_context_menu_explorer_command/

The command itself is below. Make sure to paste into a _command prompt_ window, and restart the file explorer task in task manager.

```
reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
```

## Battery Report (Laptops)

```powershell
powercfg /batteryreport /output "C:\battery-report. html"
```