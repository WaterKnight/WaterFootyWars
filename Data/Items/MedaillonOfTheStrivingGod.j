//TESH.scrollpos=3
//TESH.alwaysfold=0
//! runtextmacro Scope("MedaillonOfTheStrivingGod")
    globals
        public constant integer ITEM_ID = 'I020'
        public constant integer SET_ITEM_ID = 'I029'

        private constant real BONUS_INTELLIGENCE = 7.
        private constant real BONUS_RELATIVE_MANA_REGENERATION = 0.8
        private constant real BONUS_STRENGTH = 4.
    endglobals

    public function Drop takes Unit manipulatingUnit, Item manipulatedItem returns nothing
        local integer manipulatedItemId = manipulatedItem.id
        local real bonusManaRegeneration = GetAttachedRealById(manipulatedItemId, MedaillonOfTheStrivingGod_SCOPE_ID)
        local UnitType manipulatingUnitType = manipulatingUnit.type
        call FlushAttachedRealById(manipulatedItemId, MedaillonOfTheStrivingGod_SCOPE_ID)
        call AddUnitManaRegenerationBonus( manipulatingUnit, -bonusManaRegeneration )
        call AddHeroIntelligenceBonus( manipulatingUnit, manipulatingUnitType, -BONUS_INTELLIGENCE )
        call AddHeroStrengthBonus( manipulatingUnit, manipulatingUnitType, -BONUS_STRENGTH )
    endfunction

    public function PickUp takes Unit manipulatingUnit, Item manipulatedItem returns nothing
        local real bonusManaRegeneration = GetUnitManaRegeneration(manipulatingUnit) * BONUS_RELATIVE_MANA_REGENERATION
        local UnitType manipulatingUnitType = manipulatingUnit.type
        call AttachRealById(manipulatedItem.id, MedaillonOfTheStrivingGod_SCOPE_ID, bonusManaRegeneration)
        call AddUnitManaRegenerationBonus( manipulatingUnit, bonusManaRegeneration )
        call AddHeroIntelligenceBonus( manipulatingUnit, manipulatingUnitType, BONUS_INTELLIGENCE )
        call AddHeroStrengthBonus( manipulatingUnit, manipulatingUnitType, BONUS_STRENGTH )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 750)

        set d = InitItemTypeEx(SET_ITEM_ID)
        call SetItemTypeGoldCost(d, 750)
        call SetItemTypeMaxCharges(d, 1)

        call CreateSetSimple(MedaillonOfTheStrivingGod_ITEM_ID, SET_ITEM_ID, ITEM_ID)
    endfunction
//! runtextmacro Endscope()