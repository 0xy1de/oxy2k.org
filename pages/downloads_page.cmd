Microsoft Windows XP [Version 5.1.2600]
(C) Copyright 1985-2001 Microsoft Corp.

C:\Documents and Settings\Oxyde>title Oxy2K Deployment Console
C:\Documents and Settings\Oxyde>color 0a
C:\Documents and Settings\Oxyde>echo Initializing Oxy2K environment...
Initializing Oxy2K environment...

C:\Documents and Settings\Oxyde>ver
Microsoft Windows XP [Version 5.1.2600]

C:\Documents and Settings\Oxyde>echo Checking prerequisites...
Checking prerequisites...

C:\Documents and Settings\Oxyde>if not exist C:\Oxy2K\NUL (echo Creating C:\Oxy2K & mkdir C:\Oxy2K)
Creating C:\Oxy2K

C:\Documents and Settings\Oxyde>if not exist C:\Oxy2K\downloads\NUL (echo Creating downloads folder & mkdir C:\Oxy2K\downloads)
Creating downloads folder

C:\Documents and Settings\Oxyde>set OXY_ENABLE_DOWNLOADS=1
C:\Documents and Settings\Oxyde>set OXY_MAINTENANCE=0
C:\Documents and Settings\Oxyde>set MAX_RENDER=250
C:\Documents and Settings\Oxyde>echo Flags: ENABLE_DOWNLOADS=%OXY_ENABLE_DOWNLOADS%  MAINT=%OXY_MAINTENANCE%  CAP=%MAX_RENDER%
Flags: ENABLE_DOWNLOADS=1  MAINT=0  CAP=250

C:\Documents and Settings\Oxyde>echo.
C:\Documents and Settings\Oxyde>echo === Warm-up checks ===
=== Warm-up checks ===

C:\Documents and Settings\Oxyde>if "%OXY_MAINTENANCE%"=="1" (echo [MAINT] Downloads offline & goto :EOF)
C:\Documents and Settings\Oxyde>if not "%OXY_ENABLE_DOWNLOADS%"=="1" (echo [DISABLED] Feature flag off & goto :EOF)

C:\Documents and Settings\Oxyde>echo Feature flags OK.
Feature flags OK.

C:\Documents and Settings\Oxyde>echo.
C:\Documents and Settings\Oxyde>echo === Listing local packages ===
=== Listing local packages ===

C:\Documents and Settings\Oxyde>dir /b C:\Oxy2K\downloads
File not found

C:\Documents and Settings\Oxyde>echo No local downloads found. Seeding test artifacts...
No local downloads found. Seeding test artifacts...

C:\Documents and Settings\Oxyde>copy /y NUL C:\Oxy2K\downloads\oxyde-compositor-0.1.0-alpha.tar.xz >NUL
C:\Documents and Settings\Oxyde>copy /y NUL C:\Oxy2K\downloads\oxyde-fm-0.0.7.zip >NUL
C:\Documents and Settings\Oxyde>attrib +a C:\Oxy2K\downloads\*

C:\Documents and Settings\Oxyde>dir C:\Oxy2K\downloads
 Volume in drive C has no label.
 Volume Serial Number is BEEF-1001

 Directory of C:\Oxy2K\downloads

10/03/2025  10:42 AM    <A>                0 oxyde-compositor-0.1.0-alpha.tar.xz
10/03/2025  10:42 AM    <A>                0 oxyde-fm-0.0.7.zip
               2 File(s)              0 bytes
               0 Dir(s)   42,694,823,936 bytes free

C:\Documents and Settings\Oxyde>echo.
C:\Documents and Settings\Oxyde>echo === Calculating checksums (phony) ===
=== Calculating checksums (phony) ===

C:\Documents and Settings\Oxyde>for %F in (C:\Oxy2K\downloads\*) do @echo %~nxF & echo   sha256: deadbeef%random%%random%%random%
oxyde-compositor-0.1.0-alpha.tar.xz
  sha256: deadbeef164551321296
oxyde-fm-0.0.7.zip
  sha256: deadbeef29168190174

C:\Documents and Settings\Oxyde>echo.
C:\Documents and Settings\Oxyde>echo === Selecting up to %MAX_RENDER% entries ===
=== Selecting up to 250 entries ===

C:\Documents and Settings\Oxyde>for /f "tokens=*" %L in ('dir /b /o:-d C:\Oxy2K\downloads') do @echo   + %L
  + oxyde-fm-0.0.7.zip
  + oxyde-compositor-0.1.0-alpha.tar.xz

C:\Documents and Settings\Oxyde>echo.
C:\Documents and Settings\Oxyde>echo === Validating entries (name, version, url presence) ===
=== Validating entries (name, version, url presence) ===

C:\Documents and Settings\Oxyde>for /f "tokens=1,2 delims=-" %A in ('dir /b C:\Oxy2K\downloads\*.zip *.xz') do @if not "%~A"=="" (echo   [OK] %~nA %~B) else (echo   [SKIP] %~nA)
  [OK] oxyde  fm
  [OK] oxyde  compositor

C:\Documents and Settings\Oxyde>echo.
C:\Documents and Settings\Oxyde>echo === Building faux HTML (console print) ===
=== Building faux HTML (console print) ===

C:\Documents and Settings\Oxyde>echo <!doctype html>
<!doctype html>
C:\Documents and Settings\Oxyde>echo <h1>Downloads</h1>
<h1>Downloads</h1>
C:\Documents and Settings\Oxyde>echo <p>Grab builds, tools, and goodies for LinX OS & Oxyde.</p>
<p>Grab builds, tools, and goodies for LinX OS & Oxyde.</p>
C:\Documents and Settings\Oxyde>for %F in (C:\Oxy2K\downloads\*) do @echo - %~nxF
- oxyde-compositor-0.1.0-alpha.tar.xz
- oxyde-fm-0.0.7.zip

C:\Documents and Settings\Oxyde>echo.
C:\Documents and Settings\Oxyde>echo === Rate-limit check (pretend) ===
=== Rate-limit check (pretend) ===
C:\Documents and Settings\Oxyde>set OXY_BOT=0
C:\Documents and Settings\Oxyde>if "%OXY_BOT%"=="1" (echo [429] Too many requests & goto :EOF)
C:\Documents and Settings\Oxyde>echo Passed.
Passed.

C:\Documents and Settings\Oxyde>echo.
C:\Documents and Settings\Oxyde>echo === Mirror fallback demo ===
=== Mirror fallback demo ===
C:\Documents and Settings\Oxyde>set PRIMARY_URL=https://oxy2k.org/dl/oxyde-compositor-0.1.0-alpha.tar.xz
C:\Documents and Settings\Oxyde>set MIRROR_URL=https://mirror.oxy2k.org/oxyde-fm-0.0.7.zip
C:\Documents and Settings\Oxyde>echo Primary: %PRIMARY_URL%
Primary: https://oxy2k.org/dl/oxyde-compositor-0.1.0-alpha.tar.xz
C:\Documents and Settings\Oxyde>echo Mirror:  %MIRROR_URL%
Mirror:  https://mirror.oxy2k.org/oxyde-fm-0.0.7.zip
C:\Documents and Settings\Oxyde>echo If primary missing -> use mirror (OK)
If primary missing -> use mirror (OK)

C:\Documents and Settings\Oxyde>echo.
C:\Documents and Settings\Oxyde>echo === Truncation guard (MAX_RENDER=%MAX_RENDER%) ===
=== Truncation guard (MAX_RENDER=250) ===

C:\Documents and Settings\Oxyde>for /l %I in (1,1,3) do @echo   Rendering %I of 3...
  Rendering 1 of 3...
  Rendering 2 of 3...
  Rendering 3 of 3...

C:\Documents and Settings\Oxyde>echo.
C:\Documents and Settings\Oxyde>echo === Integrity (mock) ===
=== Integrity (mock) ===

C:\Documents and Settings\Oxyde>for %F in (C:\Oxy2K\downloads\*) do @echo %~nxF & echo   sha256: %random%%random%%random% & echo   size: %random% bytes
oxyde-compositor-0.1.0-alpha.tar.xz
  sha256: 208852185423190
  size: 17403 bytes
oxyde-fm-0.0.7.zip
  sha256: 30210520225285
  size: 11847 bytes

C:\Documents and Settings\Oxyde>echo.
C:\Documents and Settings\Oxyde>echo === Search demo: findstr ===
=== Search demo: findstr ===
C:\Documents and Settings\Oxyde>type C:\Oxy2K\README.txt 2>NUL
The system cannot find the file specified.

C:\Documents and Settings\Oxyde>echo alpha release note> C:\Oxy2K\README.txt
C:\Documents and Settings\Oxyde>findstr /i "alpha" C:\Oxy2K\README.txt
alpha release note

C:\Documents and Settings\Oxyde>echo.
C:\Documents and Settings\Oxyde>echo === Fake network ops ===
=== Fake network ops ===

C:\Documents and Settings\Oxyde>ping oxy2k.org -n 1
Pinging oxy2k.org [203.0.113.42] with 32 bytes of data:
Reply from 203.0.113.42: bytes=32 time=42ms TTL=54

Ping statistics for 203.0.113.42:
    Packets: Sent = 1, Received = 1, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
    Minimum = 42ms, Maximum = 42ms, Average = 42ms

C:\Documents and Settings\Oxyde>ipconfig /all | findstr /r "IP Address DNS"
        IP Address. . . . . . . . . . . . : 192.168.1.77
        DNS Servers . . . . . . . . . . . : 1.1.1.1
                                            9.9.9.9

C:\Documents and Settings\Oxyde>echo.
C:\Documents and Settings\Oxyde>echo === System snapshot (mock) ===
=== System snapshot (mock) ===

C:\Documents and Settings\Oxyde>tasklist | findstr /i "cmd explorer"
explorer.exe                 1512 Console                 1     22,144 K
cmd.exe                      3248 Console                 1      2,912 K

C:\Documents and Settings\Oxyde>systeminfo | findstr /B /C:"OS Name" /C:"OS Version"
OS Name:                   Microsoft Windows XP Professional
OS Version:                5.1.2600 Service Pack 3 Build 2600

C:\Documents and Settings\Oxyde>echo.
C:\Documents and Settings\Oxyde>echo === Maintenance tasks (scheduled) ===
=== Maintenance tasks (scheduled) ===

C:\Documents and Settings\Oxyde>chkdsk C: /f
The type of the file system is NTFS.
Chkdsk cannot run because the volume is in use by another
process. Would you like to schedule this volume to be
checked the next time the system restarts? (Y/N) y
This volume will be checked the next time the system restarts.

C:\Documents and Settings\Oxyde>sfc /scannow
Beginning system scan.  This process will take some time.
Verification 100% complete.
Windows Resource Protection did not find any integrity violations.

C:\Documents and Settings\Oxyde>echo.
C:\Documents and Settings\Oxyde>echo === Cache shim (pretend) ===
=== Cache shim (pretend) ===
C:\Documents and Settings\Oxyde>set OXY_CACHE_KEY=downloads:index:v1
C:\Documents and Settings\Oxyde>echo Serving from cache: %OXY_CACHE_KEY% (miss)
Serving from cache: downloads:index:v1 (miss)
C:\Documents and Settings\Oxyde>echo Populating cache... done.
Populating cache... done.

C:\Documents and Settings\Oxyde>echo.
C:\Documents and Settings\Oxyde>echo === Render summary ===
=== Render summary ===
C:\Documents and Settings\Oxyde>echo Items rendered: 2
Items rendered: 2
C:\Documents and Settings\Oxyde>echo Truncated:   0 (cap=%MAX_RENDER%)
Truncated:   0 (cap=250)
C:\Documents and Settings\Oxyde>echo Errors:      0
Errors:      0
C:\Documents and Settings\Oxyde>echo Source:      disk (fallback: mirror)
Source:      disk (fallback: mirror)

C:\Documents and Settings\Oxyde>echo.
C:\Documents and Settings\Oxyde>echo === Done. Press any key to continue... ===
=== Done. Press any key to continue... ===