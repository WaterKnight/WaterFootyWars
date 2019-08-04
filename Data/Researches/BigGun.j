//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("BigGun")
    globals
        public constant integer RESEARCH_ID = 'R014'
        public constant integer SPELL_ID = 'A087'
    endglobals

    public function ResearchFinish takes player researchingUnitOwner returns nothing
        local integer iteration = CountResearchTypeIdUnitTypes( RESEARCH_ID )
        local UnitType specificUnitType
        loop
            exitwhen ( iteration < 0 )
            set specificUnitType = GetResearchTypeIdUnitType(RESEARCH_ID, iteration )
            call SetUnitTypeSplashForPlayer( specificUnitType, researchingUnitOwner )
            set iteration = iteration - 1
        endloop
    endfunction

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType(RESEARCH_ID)
        call SetResearchTypeGoldCost(d, 1, 300)
    endfunction
//! runtextmacro Endscope()