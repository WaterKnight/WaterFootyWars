//TESH.scrollpos=0
//TESH.alwaysfold=0
scope UnitIsBeforeDying
    globals
        public trigger DUMMY_TRIGGER
    endglobals

    private function TriggerEvents_Static takes Unit dyingUnit, Unit killingUnit returns nothing
        call Barrage_Explosion_Explosion_BeforeDying( killingUnit, dyingUnit )
        call FleshBomb_BeforeDying( dyingUnit )
        if (Reincarnation_BeforeDying( dyingUnit )) then
            call UnitDies_BeforeDying(dyingUnit, killingUnit)
        endif
    endfunction

    private function Trig takes nothing returns nothing
        local Unit dyingUnit = GetUnit(GetTriggerUnit())
        local Unit killingUnit = TRIGGER_UNIT
        if ( IsUnitDead(dyingUnit) == false ) then
            call TriggerEvents_Static(dyingUnit, killingUnit)
        endif
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope