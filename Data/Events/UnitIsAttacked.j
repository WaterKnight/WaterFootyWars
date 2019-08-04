//TESH.scrollpos=0
//TESH.alwaysfold=0
scope UnitIsAttacked
    globals
        public trigger DUMMY_TRIGGER
    endglobals

    private function TriggerEvents_Static takes Unit attacker, Unit triggerUnit returns nothing
        local unit triggerUnitSelf = triggerUnit.self
        call ReleaseUnitShredder_Attack( attacker, triggerUnit )
        call SilverSpores_Attack( attacker )
        call Whirlwind_Attack( attacker, triggerUnitSelf )
        set triggerUnitSelf = null
    endfunction

    private function Trig takes nothing returns nothing
        local Unit attacker = GetUnit(GetAttacker())
        local Unit triggerUnit = GetUnit(GetTriggerUnit())

        call TriggerEvents_Static(attacker, triggerUnit)
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope