@echo off

REM Checks
REM ------
tasmx 1>NUL 2>NUL
if errorlevel 9009 goto no_tasmx
if errorlevel 216 goto 64_bit

tlink >NUL
if errorlevel 9009 goto no_tlink
if errorlevel 216 goto 64_bit

REM Build
REM -----

tasmx /m /kh32768 /t MAKER40.ASM, MAKER40.OBJ
tasmx /m /kh32768 /t /zi MAKER40.ASM, MAKER40D.OBJ
tlink MAKER40.OBJ
tlink /v MAKER40D.OBJ
goto eof

REM Errors
REM ------
:64_bit
echo You're running a 64-bit OS. Run BUILD16B.BAT separately in DOSBox instead.
goto eof

:no_tasmx
echo Could not find TASMX.
goto tc5_bin
:no_tlink
echo Could not find TLINK.
goto tc5_bin
:tc5_bin
echo Please make sure that the BIN directory of Turbo Assembler 5.0 is in your PATH.
goto eof

:eof
