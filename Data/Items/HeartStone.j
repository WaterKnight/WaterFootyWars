//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("HeartStone")
    globals
        public constant integer ITEM_ID = 'I00E'

        private constant real BONUS_MAX_LIFE = 220.
    endglobals

    public function Drop takes Unit manipulatingUnit returns nothing
        call RemoveUnitCriticalStrikeImmunity( manipulatingUnit )
        call AddUnitMaxLife( manipulatingUnit, -BONUS_MAX_LIFE )
    endfunction

    public function PickUp takes Unit manipulatingUnit returns nothing
        call AddUnitCriticalStrikeImmunity( manipulatingUnit )
        call AddUnitMaxLife( manipulatingUnit, BONUS_MAX_LIFE )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 600)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 50)
        call SetItemTypeRefreshIntervalStart(d, 150)
    endfunction
//! runtextmacro Endscope()