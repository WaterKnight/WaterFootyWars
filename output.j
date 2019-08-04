
globals
constant integer LOADING_PARTS = 0
hashtable FUNCS_TABLE
endglobals
struct InitFuncs
static method onInit takes nothing returns nothing
local ObjThread t = ObjThread.Create("InitFuncs")
set FUNCS_TABLE = InitHashtable()
call t.Destroy()
endmethod
endstruct