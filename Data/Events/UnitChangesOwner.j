//TESH.scrollpos=0
//TESH.alwaysfold=0
scope UnitChangesOwner
    globals
        public trigger DUMMY_TRIGGER
    endglobals

    private function TriggerEvents_Static takes Unit changingUnit, integer changingUnitTeam returns nothing
        call DivineShield_Activate( changingUnit, changingUnitTeam )
    endfunction

    private function Trig takes nothing returns nothing
        local Unit changingUnit = GetUnit(GetChangingUnit())
        local player changingUnitOwner = GetOwningPlayer(changingUnit.self)
        local integer changingUnitTeam = GetPlayerTeam( changingUnitOwner )

        set changingUnit.owner = changingUnitOwner

        call TriggerEvents_Static(changingUnit, changingUnitTeam)

        set changingUnitOwner = null
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope