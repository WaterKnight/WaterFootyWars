//TESH.scrollpos=0
//TESH.alwaysfold=0
scope UnitBeginsResearching
    globals
        public trigger DUMMY_TRIGGER
    endglobals

    private function Trig takes nothing returns nothing
        local string errorMsg = null
        local Unit researchingUnit = GetUnit(GetResearchingUnit())
        local player researchingUnitOwner = researchingUnit.owner
        local integer triggerResearchTypeId = GetResearched()
        local ResearchType triggerResearchType = GetResearchType(triggerResearchTypeId)
        local integer goldCost = GetPlayerGoldCost(GetResearchTypeGoldCost( triggerResearchType, GetPlayerTechCount(researchingUnitOwner, triggerResearchTypeId, true ) + 1 ), researchingUnitOwner)
        if ( goldCost > GetPlayerState( researchingUnitOwner, PLAYER_STATE_RESOURCE_GOLD ) ) then
            set errorMsg = ErrorStrings_TOO_LESS_GOLD
        endif
        if ( errorMsg == null ) then
            call AddPlayerState( researchingUnitOwner, PLAYER_STATE_RESOURCE_GOLD, -goldCost )
        else
            set UnitCancelsResearching_IGNORE_NEXT = true
            call StopUnit( researchingUnit )
            call Error( researchingUnitOwner, errorMsg )
        endif
        set researchingUnitOwner = null
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope