//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("OrbOfWisdom")
    globals
        public constant integer ITEM_ID = 'I01U'

        private constant real BONUS_RELATIVE_MANA_REGENERATION = 0.5
    endglobals

    public function Drop takes Unit manipulatingUnit, Item manipulatedItem returns nothing
        local integer manipulatedItemId = manipulatedItem.id
        local real bonusManaRegeneration = GetAttachedRealById(manipulatedItemId, OrbOfWisdom_SCOPE_ID)
        call FlushAttachedRealById(manipulatedItemId, OrbOfWisdom_SCOPE_ID)
        call AddUnitManaRegenerationBonus( manipulatingUnit, -bonusManaRegeneration )
    endfunction

    public function PickUp takes Unit manipulatingUnit, Item manipulatedItem returns nothing
        local real bonusManaRegeneration = GetUnitManaRegeneration(manipulatingUnit) * BONUS_RELATIVE_MANA_REGENERATION
        call AttachRealById(manipulatedItem.id, OrbOfWisdom_SCOPE_ID, bonusManaRegeneration)
        call AddUnitManaRegenerationBonus( manipulatingUnit, bonusManaRegeneration )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 750)
        call SetItemTypeMaxCharges(d, 2)
        call SetItemTypeRefreshInterval(d, 30)
    endfunction
//! runtextmacro Endscope()