//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("BeltOfTheCelt")
    globals
        public constant integer ITEM_ID = 'I01C'

        private constant real BONUS_STRENGTH = 5.
    endglobals

    public function Drop takes Unit manipulatingUnit returns nothing
        call AddHeroStrengthBonus( manipulatingUnit, manipulatingUnit.type, -BONUS_STRENGTH )
    endfunction

    public function PickUp takes Unit manipulatingUnit returns nothing
        call AddHeroStrengthBonus( manipulatingUnit, manipulatingUnit.type, BONUS_STRENGTH )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 350)
        call SetItemTypeMaxCharges(d, 2)
        call SetItemTypeRefreshInterval(d, 30)
    endfunction
//! runtextmacro Endscope()