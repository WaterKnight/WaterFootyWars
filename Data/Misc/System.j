//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("System")
    globals
        public force SHIP
    endglobals

    public function Chat takes string chatMessage, player whichPlayer returns nothing
        set chatMessage = StringCase( chatMessage, false )
        if ( chatMessage == "-system" ) then
            if ( IsPlayerInForce( whichPlayer, SHIP ) ) then
                call DisplayTextTimedWJ("|cffff0000You are no longer displayed debug messages.|r", HINT_TEXT_DURATION, whichPlayer)
                call ForceRemovePlayer( SHIP, whichPlayer )
            else
                call DisplayTextTimedWJ("|cff00ff00You are now displayed debug messages.|r", HINT_TEXT_DURATION, whichPlayer)
                call ForceAddPlayer( SHIP, whichPlayer )
            endif
        endif
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = MAX_PLAYER_INDEX
        set SHIP = CreateForceWJ()
        loop
            exitwhen (GetPlayerName(PlayerWJ(iteration)) == "WaterKnight")
            set iteration = iteration - 1
            exitwhen (iteration < 0)
        endloop
        if (iteration > -1) then
            call ForceAddPlayer( SHIP, PlayerWJ(iteration) )
        endif
    endfunction
//! runtextmacro Endscope()