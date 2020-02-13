---
layout: post
title: WinExe Forensics
date: '2019-09-08 15:00:00'
---

WinExe is a utility that allows linux hosts to remotely execute commands on a Windows machine. The functionality is very similar to PsExec.

Recently, an antivirus alert fired for the C:\Windows\winexesvc.exe executable. It is classified as Riskware or as a Hacktool when searching the hash on VirusTotal. Googling around, it appears that WinExe was being used by APT28 (Fancy Bear) as a lateral movement tool. However, since it can be used for legitimate management purposes, it is unwise to jump to conclusions before getting more context. This post outlines the artifacts left on the system after it has been used, specifically in Windows Event Viewer so that others facing this alert can create a timeline and find relevant information.

To investigate WinExe, I spun up a lab environment in Virtualbox consisting of Parrot OS and Windows 7.

The first hurdle I encountered was hitting the following error when trying to run WinExe on Parrot against the Windows 7 machine:

```
ERROR: Failed to install service winexesvc - NT_STATUS_ACCESS_DENIED
```

To fix this issue, I had to run a registry fix on the Windows 7 host inside of an Administrator command prompt:

```
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\system" /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f

```

After running that registry fix, WinExe now functions normally:

![WinExe in Terminal](/assets/media/winexe-img1.png)

The three screenshots below outline the forensic artifacts left behind in Windows Event Viewer. As you can see, not a whole lot of useful information is retained. For example, there are no events created for commands run through WinExe.

![Windows Event Log Event ID 7045](/assets/media/winexe-img2.png)
*System Event ID 7045 fired during the winexesvc service creation.*

![Windows Event Log Event ID 4624](/assets/media/winexe-img3.png)
*Security Event ID 4624 fired for the WinExe authentication event.*

![Windows Event Log Event ID 7036](/assets/media/winexe-img4.png)
*System Event ID 7036 fires for the winexesvc service stopping and starting.*
