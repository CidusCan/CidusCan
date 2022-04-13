@echo off
setlocal enabledelayedexpansion 
set a=2 & echo a= %STAR%

echo  !a!
set a=1
echo  !a!

set a=2&echo  !a!

pause

@echo off 
setlocal enabledelayedexpansion 
set a=4 
set a=5&echo !a! 
pause