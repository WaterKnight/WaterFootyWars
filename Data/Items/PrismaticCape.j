//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("PrismaticCape")
    globals
        public constant integer ITEM_ID = 'I004'
        public constant integer SET_ITEM_ID = 'I021'

        private constant real BONUS_AGILITY = 8.
        private constant real BONUS_RELATIVE_EVADE_CHANCE = 0.15
        private constant real BONUS_INTELLIGENCE = 8.
        private constant real BONUS_STRENGTH = 8.
    endglobals

    private struct Data
        real bonusEvadeChance
    endstruct

    public function Drop takes Item manipulatedItem, Unit manipulatingUnit returns nothing
        local integer manipulatedItemId = manipulatedItem.id
        local Data d = GetAttachedIntegerById(manipulatedItemId, PrismaticCape_SCOPE_ID)
        local real bonusEvadeChance = -d.bonusEvadeChance
        local UnitType manipulatingUnitType = manipulatingUnit.type
        call d.destroy()
        call FlushAttachedIntegerById( manipulatedItemId, PrismaticCape_SCOPE_ID )
        call AddHeroAgilityBonus( manipulatingUnit, manipulatingUnitType, -BONUS_AGILITY )
        call AddUnitEvasionChance( manipulatingUnit, bonusEvadeChance )
        call AddHeroIntelligenceBonus( manipulatingUnit, manipulatingUnitType, -BONUS_INTELLIGENCE )
        call AddHeroStrengthBonus( manipulatingUnit, manipulatingUnitType, -BONUS_STRENGTH )
    endfunction

    public function PickUp takes Item manipulatedItem, Unit manipulatingUnit returns nothing
        local Data d = Data.create()
        local real bonusEvadeChance = ( 1 - GetUnitEvasionChance( manipulatingUnit ) ) * BONUS_RELATIVE_EVADE_CHANCE
        local UnitType manipulatingUnitType = manipulatingUnit.type
        set d.bonusEvadeChance = bonusEvadeChance
        call AttachIntegerById( manipulatedItem.id, PrismaticCape_SCOPE_ID, d )
        call AddHeroAgilityBonus( manipulatingUnit, manipulatingUnitType, BONUS_AGILITY )
        call AddUnitEvasionChance( manipulatingUnit, bonusEvadeChance )
        call AddHeroIntelligenceBonus( manipulatingUnit, manipulatingUnitType, BONUS_INTELLIGENCE )
        call AddHeroStrengthBonus( manipulatingUnit, manipulatingUnitType, BONUS_STRENGTH )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 1300)

        set d = InitItemTypeEx(SET_ITEM_ID)
        call SetItemTypeGoldCost(d, 1300)
        call SetItemTypeMaxCharges(d, 1)

        call CreateSetSimple3(BeltOfTheCelt_ITEM_ID, SpidermanSocks_ITEM_ID, RobeOfThePope_ITEM_ID, SET_ITEM_ID, ITEM_ID)
    endfunction
//! runtextmacro Endscope()