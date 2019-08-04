//TESH.scrollpos=0
//TESH.alwaysfold=0
scope UnitCancelsResearching
    globals
        public trigger DUMMY_TRIGGER
        public boolean IGNORE_NEXT = false
        private constant real GOLD_RESTORATION_FACTOR = 1.
    endglobals

    private function Trig takes nothing returns nothing
        local integer goldCost
        local Unit researchingUnit
        local player researchingUnitOwner
        local ResearchType triggerResearchType
        local integer triggerResearchTypeId
        if ( IGNORE_NEXT ) then
            set IGNORE_NEXT = false
        else
            set researchingUnit = GetUnit(GetResearchingUnit())
            set researchingUnitOwner = researchingUnit.owner
            set triggerResearchTypeId = GetResearched()
            set triggerResearchType = GetResearchType(triggerResearchTypeId)
            set goldCost = GetPlayerGoldCost(GetResearchTypeGoldCost( triggerResearchType, GetPlayerTechCount(researchingUnitOwner, triggerResearchTypeId, true) + 1 ), researchingUnitOwner)

            call AddPlayerState( researchingUnitOwner, PLAYER_STATE_RESOURCE_GOLD, R2I( goldCost * GOLD_RESTORATION_FACTOR ) )

            set researchingUnitOwner = null
        endif
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope