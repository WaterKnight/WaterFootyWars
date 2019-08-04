//TESH.scrollpos=8
//TESH.alwaysfold=0
//! runtextmacro Scope("Lollipop")
    globals
        public constant integer ITEM_ID = 'I01O'
        public constant integer MANUFACTURED_ITEM_ID = 'I02A'

        private constant real BONUS_LIFE_REGENERATION = 1.5 * REGENERATION_INTERVAL
        private constant real BONUS_MANA_REGENERATION = 1.5 * REGENERATION_INTERVAL
    endglobals

    public function Drop takes Unit manipulatingUnit returns nothing
        call AddUnitLifeRegenerationBonus(manipulatingUnit, -BONUS_LIFE_REGENERATION)
        call AddUnitManaRegenerationBonus(manipulatingUnit, -BONUS_MANA_REGENERATION)
    endfunction

    public function PickUp takes Unit manipulatingUnit returns nothing
        call AddUnitLifeRegenerationBonus(manipulatingUnit, BONUS_LIFE_REGENERATION)
        call AddUnitManaRegenerationBonus(manipulatingUnit, BONUS_MANA_REGENERATION)
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 300)

        set d = InitItemTypeEx(MANUFACTURED_ITEM_ID)
        call SetItemTypeGoldCost(d, 300)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 30)
        call SetItemTypeRefreshIntervalStart(d, 90)
    endfunction
//! runtextmacro Endscope()