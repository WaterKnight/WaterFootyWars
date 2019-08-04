//TESH.scrollpos=0
//TESH.alwaysfold=0
scope UnitIsRevaluated
    globals
        public trigger DUMMY_TRIGGER

        public integer LEVEL
        public integer OLD_LEVEL
    endglobals

    private function TriggerEvents_Static takes Unit triggerUnit, integer level returns nothing
        call UnitRevaluation_Revaluate( triggerUnit, level )
    endfunction

    private function Trig takes nothing returns nothing
        local integer level = LEVEL
        local integer oldLevel = OLD_LEVEL
        local Unit triggerUnit = TRIGGER_UNIT

        call TriggerEvents_Static(triggerUnit, level)
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope