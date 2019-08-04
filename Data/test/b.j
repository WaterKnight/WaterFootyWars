//TESH.scrollpos=0
//TESH.alwaysfold=0
function Trig_b_Actions takes nothing returns nothing
    local string s = GetEventPlayerChatString()
    local integer amount
    local integer iteration = 10
    local Unit newUnit
    local player whichPlayer
    local integer whichType
    local real x = 0
    local real y = 0
    loop
        exitwhen ( SubStringBJ( s, iteration, iteration ) == " " )
        set iteration = iteration + 1
    endloop
    set amount = S2I( SubStringBJ( s, 9, iteration - 1 ) )
    set whichPlayer = GetTriggerPlayer()
    set whichType = GetSavedInteger( "UnitTypes", SubStringBJ( s, iteration + 1, StringLength( s ) ) )
    set iteration = 1
    loop
        exitwhen ( iteration > amount )
        set newUnit = CreateUnitEx( whichPlayer, whichType, x, y, 0 )
//        call KillUnit( newUnit )
        set iteration = iteration + 1
    endloop
    set whichPlayer = null
    call WriteBug( I2S( iteration ) )
endfunction

function InitTrig_b takes nothing returns nothing
    local integer iteration = 0
    set gg_trg_b = CreateTrigger()
    loop
        exitwhen ( iteration > 11 )
        call TriggerRegisterPlayerChatEvent( gg_trg_b, Player( iteration ), "-create ", false )
        set iteration = iteration + 1
    endloop
    call TriggerAddAction( gg_trg_b, function Trig_b_Actions )
endfunction