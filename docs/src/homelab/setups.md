# Setups

## Overview

This page serves as the documentation for various personal preferences about my laptop and desktop setups.

## Disable Windows 11 Context Menu

https://www.reddit.com/r/Windows11/comments/pu5aa3/howto_disable_new_context_menu_explorer_command/

The command itself is below. Make sure to paste into a _command prompt_ window, and restart the file explorer task in task manager.

```
reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
```

## Chrome Window Color Profile

Disable this: chrome://flags/#customize-chrome-color-extraction
