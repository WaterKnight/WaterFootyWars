//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("ImprovedWhipLash")
    globals
        public constant integer RESEARCH_ID = 'R011'
    endglobals

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 800)
    endfunction
//! runtextmacro Endscope()