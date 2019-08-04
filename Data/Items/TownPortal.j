//TESH.scrollpos=7
//TESH.alwaysfold=0
//! runtextmacro Scope("TownPortal")
    globals
        public constant integer ITEM_ID = 'I000'
        public constant integer SPELL_ID = 'A042'
    endglobals

    public function EndCast takes Unit caster returns nothing
        call RemoveUnitInvulnerability(caster)
    endfunction

    private function EndCast_Event takes nothing returns nothing
        call EndCast( CASTER )
    endfunction

    public function Channel takes Unit caster returns nothing
        call AddUnitInvulnerability(caster)
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 200)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 80)
        call SetItemTypeRefreshIntervalStart(d, 200)

        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ENDCAST", "SPELL_ID", "UnitFinishesCasting_EVENT_KEY", "0", "function EndCast_Event" )
    endfunction
//! runtextmacro Endscope()