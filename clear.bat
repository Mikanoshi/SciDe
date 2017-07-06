FOR /r %%R IN (*.~*) DO IF EXIST %%R (del /s /q "%%R")
FOR /r %%R IN (*.o) DO IF EXIST %%R (del /s /q "%%R")
FOR /r %%R IN (*.identcache) DO IF EXIST %%R (del /s /q "%%R")
FOR /r %%R IN (*.ddp) DO IF EXIST %%R (del /s /q "%%R")
FOR /r %%R IN (*.ppu) DO IF EXIST %%R (del /s /q "%%R")
FOR /r %%R IN (*.dcu) DO IF EXIST %%R (del /s /q "%%R")
FOR /r %%R IN (*.bak) DO IF EXIST %%R (del /s /q "%%R")
FOR /r %%R IN (*.hpp) DO IF EXIST %%R (del /s /q "%%R")
FOR /r %%R IN (*.dtx) DO IF EXIST %%R (del /s /q "%%R")

@IF EXIST "__history\*" rd /q /s __history\
