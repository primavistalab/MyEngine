@echo off
echo Continue? This file deleted file by mask - *.~*,  *.CFG, *.DSK, *.DDP   !!!
pause
echo Right now?!
pause
del *.~* /s
del *.dsk /s
del *.cfg /s
del *.ddp /s
pause