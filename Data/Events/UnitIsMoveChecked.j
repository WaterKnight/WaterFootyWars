//TESH.scrollpos=0
//TESH.alwaysfold=0
scope UnitIsMoveChecked
    globals
        public trigger DUMMY_TRIGGER

        public real X
        public real Y
        public real Z
    endglobals

    private function TriggerEvents_Static takes Unit triggerUnit, real x, real y, real z returns nothing
        call KittyJump_MoveCheck( triggerUnit, x, y, z )
    endfunction

    private function Trig takes nothing returns nothing
        local Unit triggerUnit = TRIGGER_UNIT
        local real x = X
        local real y = Y
        local real z = Z
        call TriggerEvents_Static(triggerUnit, x, y, z)
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope