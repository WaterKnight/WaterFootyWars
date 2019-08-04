//TESH.scrollpos=0
//TESH.alwaysfold=0
scope PlayerLeaves
    globals
        private trigger DUMMY_TRIGGER
    endglobals

    private function Trig takes nothing returns nothing
        local player triggerPlayer = GetTriggerPlayer()
    local string s = Memory_Bug_discmarker_lastString
        call DisplayTextTimedWJ( GetPlayerColorString(triggerPlayer) + GetPlayerName( triggerPlayer ) + ColorStrings_RESET + " has left the game.", 10, GetLocalPlayer() )
        call KillPlayer( triggerPlayer )
        call ClearSelectionWJ( triggerPlayer )
    set Memory_Bug_discmarker_lastString = s
    set Memory_Bug_discmarker_lastLeaver = triggerPlayer
        set triggerPlayer = null
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = MAX_PLAYER_INDEX
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
        loop
            call TriggerRegisterPlayerEvent( DUMMY_TRIGGER, PlayerWJ( iteration ), EVENT_PLAYER_LEAVE )
            set iteration = iteration - 1
            exitwhen ( iteration < 0 )
        endloop
    endfunction
endscope