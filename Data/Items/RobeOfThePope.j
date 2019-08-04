//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("RobeOfThePope")
    globals
        public constant integer ITEM_ID = 'I01E'

        private constant real BONUS_ARMOR = 3.
        private constant real BONUS_INTELLIGENCE = 8.
    endglobals

    public function Drop takes Unit manipulatingUnit returns nothing
        call AddUnitArmorBonus( manipulatingUnit, -BONUS_ARMOR )
        call AddHeroIntelligenceBonus( manipulatingUnit, manipulatingUnit.type, -BONUS_INTELLIGENCE )
    endfunction

    public function PickUp takes Unit manipulatingUnit returns nothing
        call AddUnitArmorBonus( manipulatingUnit, BONUS_ARMOR )
        call AddHeroIntelligenceBonus( manipulatingUnit, manipulatingUnit.type, BONUS_INTELLIGENCE )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 560)
        call SetItemTypeMaxCharges(d, 2)
        call SetItemTypeRefreshInterval(d, 30)
    endfunction
//! runtextmacro Endscope()