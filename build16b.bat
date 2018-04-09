@echo off

REM Checks
REM ------
tasmx 1>NUL 2>NUL
if errorlevel 9009 goto no_tasmx
if errorlevel 216 goto 64_bit

bcc >NUL
if errorlevel 9009 goto no_bcc
if errorlevel 216 goto 64_bit

REM Build
REM -----

REM TASM under DOSBox seems to need that, because for some reason it can't
REM write to those once they exist -.-
del MAKER40.OBJ
del MAKER40D.OBJ

tasmx /m /mx /kh32768 /t MAKER40.ASM, MAKER40.OBJ
tasmx /m /mx /kh32768 /t /zi MAKER40.ASM, MAKER40D.OBJ
bcc -mc -ls MAKER40.OBJ
bcc -mc -ls -v MAKER40D.OBJ
goto eof

REM Errors
REM ------
:64_bit
echo You're running a 64-bit OS. Run BUILD16B.BAT separately in DOSBox instead.
goto eof

:no_tasmx
echo Could not find TASMX.
echo Please make sure that the BIN directory of Turbo Assembler 5.0 is in your PATH.
goto eof
:no_bcc
echo Could not find BCC.
echo Please make sure that the BIN directory of Borland C++ 5.01 is in your PATH.
goto eof

:eof
