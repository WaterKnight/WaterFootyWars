//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("ChaosSword")
    globals
        public constant integer ITEM_ID = 'I01T'
        public constant integer SET_ITEM_ID = 'I01W'

        private constant real BONUS_AGILITY = 3.
        private constant real BONUS_ARMOR_BREAK_RELATIVE = 1.
        private constant real BONUS_INTELLIGENCE = 3.
        private constant real BONUS_STRENGTH = 3.
    endglobals

    public function Drop takes Unit manipulatingUnit returns nothing
        local UnitType manipulatingUnitType = manipulatingUnit.type
        call AddHeroAgilityBonus( manipulatingUnit, manipulatingUnitType, -BONUS_AGILITY )
        call AddUnitArmorBreakRelativeBonus( manipulatingUnit, -BONUS_ARMOR_BREAK_RELATIVE )
        call AddHeroIntelligenceBonus( manipulatingUnit, manipulatingUnitType, -BONUS_INTELLIGENCE )
        call AddHeroStrengthBonus( manipulatingUnit, manipulatingUnitType, -BONUS_STRENGTH )
    endfunction

    public function PickUp takes Unit manipulatingUnit returns nothing
        local UnitType manipulatingUnitType = manipulatingUnit.type
        call AddHeroAgilityBonus( manipulatingUnit, manipulatingUnitType, BONUS_AGILITY )
        call AddUnitArmorBreakRelativeBonus( manipulatingUnit, BONUS_ARMOR_BREAK_RELATIVE )
        call AddHeroIntelligenceBonus( manipulatingUnit, manipulatingUnitType, BONUS_INTELLIGENCE )
        call AddHeroStrengthBonus( manipulatingUnit, manipulatingUnitType, BONUS_STRENGTH )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 1350)

        set d = InitItemTypeEx(SET_ITEM_ID)
        call SetItemTypeGoldCost(d, 1350)
        call SetItemTypeMaxCharges(d, 1)

        call CreateSetSimple2(AstralGauntlets_ITEM_ID, Lollipop_ITEM_ID, SET_ITEM_ID, ITEM_ID)
    endfunction
//! runtextmacro Endscope()