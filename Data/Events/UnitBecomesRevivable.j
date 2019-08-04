//TESH.scrollpos=0
//TESH.alwaysfold=0
scope UnitBecomesRevivable
    globals
        public trigger DUMMY_TRIGGER
    endglobals

    private function TriggerEvents takes Unit triggerUnit returns nothing
        call AutomaticRevival_Revivable(triggerUnit)
    endfunction

    private function Trig takes nothing returns nothing
        local unit triggerUnitSelf = GetRevivableUnit()
        local Unit triggerUnit = GetUnit(triggerUnitSelf)

        call TriggerEvents(triggerUnit)

        set triggerUnitSelf = null
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope