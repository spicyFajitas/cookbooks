# Windows

## Deployment Image Servicing and Management (DISM)

`DISM /Online /Cleanup-Image /RestoreHealth`

[Reference](https://www.windowscentral.com/how-use-dism-command-line-utility-repair-windows-10-image)

## System File Checker (SFC)

`sfc /scannow`

[Reference](https://www.lifewire.com/how-to-use-sfc-scannow-to-repair-windows-system-files-2626161)

## Chkdsk

```
To make CHKDSK fix the problems it finds, type chkdsk /f c: (for your C: drive).
To scan for bad sectors as well as errors, type chkdsk /r c:.
```

## Windows Terminal Themes

https://windowsterminalthemes.dev/

## Diskpart

I can't remember what this was for but I believe it was for adding space to a Windows partition when there was a recovery partition in between two larger partitions

```bat
C:\WINDOWS\system32>diskpart
Microsoft DiskPart version 10.0.17763.1
Copyright (C) Microsoft Corporation.
On computer: ComputerName
DISKPART> list disk
  Disk ###  Status         Size     Free     Dyn  Gpt
  --------  -------------  -------  -------  ---  ---
  Disk 0    Online          128 GB      0 B        *
  Disk 1    Online          100 GB  1024 KB        *
DISKPART> select disk 0
  Disk 0 is now the selected disk.
DISKPART> list partition
  Partition ###  Type              Size     Offset
  -------------  ----------------  -------  -------
  Partition 1    System             500 MB  1024 KB
  Partition 2    Reserved           128 MB   501 MB
  Partition 3    Primary            126 GB   629 MB
  Partition 4    Recovery          1306 MB   126 GB
DISKPART> select partition 4
  Partition 4 is now the selected partition.
 
DISKPART> delete partition override
  DiskPart successfully deleted the selected partition.
DISKPART> list partition
  Partition ###  Type              Size     Offset
  -------------  ----------------  -------  -------
  Partition 1    System             500 MB  1024 KB
  Partition 2    Reserved           128 MB   501 MB
  Partition 3    Primary            126 GB   629 MB
DISKPART> Exit
```
