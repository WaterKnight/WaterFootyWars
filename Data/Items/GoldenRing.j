//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("GoldenRing")
    globals
        public constant integer ITEM_ID = 'I01G'

        private constant real BONUS_LIFE_REGENERATION = 2. * REGENERATION_INTERVAL
        private constant real BONUS_STRENGTH = 3.
    endglobals

    public function Drop takes Unit manipulatingUnit returns nothing
        call AddUnitLifeRegenerationBonus(manipulatingUnit, -BONUS_LIFE_REGENERATION)
        call AddHeroStrengthBonus( manipulatingUnit, manipulatingUnit.type, -BONUS_STRENGTH )
    endfunction

    public function PickUp takes Unit manipulatingUnit returns nothing
        call AddUnitLifeRegenerationBonus(manipulatingUnit, BONUS_LIFE_REGENERATION)
        call AddHeroStrengthBonus( manipulatingUnit, manipulatingUnit.type, BONUS_STRENGTH )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 200)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 30)
        call SetItemTypeRefreshIntervalStart(d, 120)
    endfunction
//! runtextmacro Endscope()