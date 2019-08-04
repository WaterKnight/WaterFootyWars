//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("MassProduction")
    globals
        public constant integer RESEARCH_ID = 'R00O'

        private real array BONUS_RELATIVE_TIME
    endglobals

    public function ResearchFinish takes integer researchLevel, player researchingUnitOwner returns nothing
        local real bonusRelativeTime = BONUS_RELATIVE_TIME[researchLevel]
        local integer iteration = CountResearchTypeIdUnitTypes(RESEARCH_ID)
        local UnitType specificUnitType
        loop
            exitwhen ( iteration < 0 )
            set specificUnitType = GetResearchTypeIdUnitType(RESEARCH_ID, iteration)
            call AddUnitTypeSpawnTimeForPlayer( specificUnitType, researchingUnitOwner, GetUnitTypeSpawnTime( specificUnitType ) * bonusRelativeTime )
            set iteration = iteration - 1
        endloop
    endfunction

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 800)
        call SetResearchTypeGoldCost(d, 2, 800)

        set BONUS_RELATIVE_TIME[1] = -0.2
        set BONUS_RELATIVE_TIME[2] = -0.2
    endfunction
//! runtextmacro Endscope()