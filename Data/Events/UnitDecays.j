//TESH.scrollpos=0
//TESH.alwaysfold=0
scope UnitDecays
    globals
        public trigger DUMMY_TRIGGER
    endglobals

    private function Trig takes nothing returns nothing
        local unit decayingUnitSelf = GetDecayingUnit()
        local Unit decayingUnit = GetUnit(decayingUnitSelf)
        local real decayTime = GetUnitDecayTime(decayingUnit)
        call UnitSuspendDecay( decayingUnitSelf, true )
        if (decayTime > 0) then
            call SetUnitTimeScale( decayingUnitSelf, 120 / decayTime )
        endif
        set decayingUnitSelf = null
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope