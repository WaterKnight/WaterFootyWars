//TESH.scrollpos=0
//TESH.alwaysfold=0
scope Dawn
    globals
        boolean dawn = false
        private trigger DUMMY_TRIGGER
    endglobals

    private function Trig takes nothing returns nothing
        call TimeOfDay_Dawn()
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
        call TriggerRegisterGameStateEvent( DUMMY_TRIGGER, GAME_STATE_TIME_OF_DAY, EQUAL, 18 )
    endfunction
endscope