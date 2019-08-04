//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("DoubleHead")
    globals
        public constant integer RESEARCH_ID = 'R010'
    endglobals

    public function ResearchFinish takes player researchingUnitOwner returns nothing
        call CreateAltar( researchingUnitOwner )
    endfunction

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 2000)
    endfunction
//! runtextmacro Endscope()