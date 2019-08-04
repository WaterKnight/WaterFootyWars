//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("ShadowMeld")
    globals
        public constant integer RESEARCH_ID = 'R01F'
        public constant integer SPELL_ID = 'A07L'
    endglobals

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 300)
    endfunction
//! runtextmacro Endscope()