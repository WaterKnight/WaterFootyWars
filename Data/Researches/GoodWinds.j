//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("GoodWinds")
    globals
        public constant integer RESEARCH_ID = 'R00Q'
    endglobals

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 800)
        call SetResearchTypeGoldCost(d, 2, 800)
    endfunction
//! runtextmacro Endscope()