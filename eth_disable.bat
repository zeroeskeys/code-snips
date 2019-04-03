Rem basic bat scripts to disable and enable ethernet adapters

Rem Disable
@echo off
:LOOP
echo "Disabling ethernet0 now ...."
netsh interface set interface Ethernet0 DISABLED
TIMEOUT /T 5 /nobreak

echo "ping testing to confirm disable operation"
ping 8.8.8.8
IF %ERRORLEVEL% EQU 1 goto PROCEED
IF %ERRORLEVEL% EQU 0 goto LOOP

:PROCEED
echo "Ethernet 0 is disabled"
echo "Run eth0 enable.bat when ready to resume normal operations"
echo "Press any key to exit"
pause >nul


Rem Enable
@echo off
:LOOP

echo "Enabling ethernet0 now ...."
netsh interface set interface Ethernet0 ENABLED
TIMEOUT /T 8 /nobreak

echo "ping testing to confirm enable operation"
ping 8.8.8.8
IF %ERRORLEVEL% EQU 0 goto PROCEED
IF %ERRORLEVEL% EQU 1 goto LOOP

:PROCEED
echo "Ethernet 0 is enabled"
echo "Press any key to exit"
pause >nul
