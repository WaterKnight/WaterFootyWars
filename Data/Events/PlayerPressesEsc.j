//TESH.scrollpos=0
//TESH.alwaysfold=0
scope PlayerPressesEsc
    globals
        private trigger DUMMY_TRIGGER
    endglobals

    private function Trig takes nothing returns nothing
        local player triggerPlayer = GetTriggerPlayer()
        set triggerPlayer = null
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = MAX_PLAYER_INDEX
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
        loop
            call TriggerRegisterPlayerEvent( DUMMY_TRIGGER, PlayerWJ( iteration ), EVENT_PLAYER_END_CINEMATIC )
            set iteration = iteration - 1
            exitwhen ( iteration < 0 )
        endloop
    endfunction
endscope