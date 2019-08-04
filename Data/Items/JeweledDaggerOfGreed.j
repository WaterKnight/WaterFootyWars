//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("JeweledDaggerOfGreed")
    globals
        public constant integer ITEM_ID = 'I003'

        private constant real BONUS_DAMAGE = 12.
        private constant real BONUS_RELATIVE_DROP_BY_KILL = 0.35
    endglobals

    public function Drop takes Unit manipulatingUnit returns nothing
        call AddUnitDamageBonus( manipulatingUnit, -BONUS_DAMAGE )
        call AddUnitDropByKillRelativeBonus( manipulatingUnit, -BONUS_RELATIVE_DROP_BY_KILL )
    endfunction

    public function PickUp takes Unit manipulatingUnit returns nothing
        call AddUnitDamageBonus( manipulatingUnit, BONUS_DAMAGE )
        call AddUnitDropByKillRelativeBonus( manipulatingUnit, BONUS_RELATIVE_DROP_BY_KILL )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 650)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 50)
        call SetItemTypeRefreshIntervalStart(d, 150)
    endfunction
//! runtextmacro Endscope()