//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("SelfHealResearch")
    globals
        public constant integer RESEARCH_ID = 'R00R'
    endglobals

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 350)
        call SetResearchTypeGoldCost(d, 2, 350)
    endfunction
//! runtextmacro Endscope()