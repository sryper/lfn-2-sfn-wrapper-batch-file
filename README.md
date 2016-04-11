# lfn-2-sfn-wrapper-batch-file 
# 
# Convert Long file name to SFN arguments for legacy programs
#
# Operating System Supported: WIN NT4,2K,XP or higher (XP tested ok)

::
::  Usage:
::     vi_wrapper ["file-path-argument"] ...
::  
::  Returns:
::    exit code of %pgm%
::
::  Environment Vars:
::    ZOPT  sets path to vi.ini if needed
::
::  Notes:
::    . Arguments passed are converted to short file name as well as path
::    . Set SHOW var to turn on trace info
::    . Set PGM var to software program
::    . This fixes corruption in "%sfA" when file is < 8 chars with 2 "." 
::      periods eg f.1.txt
::    . Sets inifile to pgm.ini (will search in PATH var if required)