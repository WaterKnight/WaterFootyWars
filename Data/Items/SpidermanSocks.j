//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("SpidermanSocks")
    globals
        public constant integer ITEM_ID = 'I01D'

        private constant real BONUS_AGILITY = 7.
    endglobals

    public function Drop takes Unit caster returns nothing
        call AddHeroAgilityBonus( caster, caster.type, -BONUS_AGILITY )
    endfunction

    public function PickUp takes Unit caster returns nothing
        call AddHeroAgilityBonus( caster, caster.type, BONUS_AGILITY )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 420)
        call SetItemTypeMaxCharges(d, 2)
        call SetItemTypeRefreshInterval(d, 70)
    endfunction
//! runtextmacro Endscope()