//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("GexxoSlippers")
    globals
        public constant integer ITEM_ID = 'I01F'

        private constant real BONUS_AGILITY = 1.
        private constant real BONUS_INTELLIGENCE = 1.
        private constant real BONUS_SPEED = 15.
        private constant string MANIPULATING_UNIT_EFFECT_PATH = "Units\\Critters\\Skink\\Skink.mdl"
        private constant string MANIPULATING_UNIT_EFFECT_ATTACHMENT_POINT = "foot left"
        private constant string MANIPULATING_UNIT_EFFECT_ATTACHMENT_POINT2 = "foot right"
    endglobals

    private struct Data
        integer amount = 1
        effect manipulatingUnitEffect
        effect manipulatingUnitEffect2
    endstruct

    public function Drop takes Unit manipulatingUnit returns nothing
        local effect manipulatingUnitEffect
        local effect manipulatingUnitEffect2
        local integer manipulatingUnitId = manipulatingUnit.id
        local Data d = GetAttachedIntegerById(manipulatingUnitId, GexxoSlippers_SCOPE_ID)
        local integer amount = d.amount - 1
        local integer manipulatingUnitType = manipulatingUnit.type
        if (amount == 0) then
            set manipulatingUnitEffect = d.manipulatingUnitEffect
            set manipulatingUnitEffect2 = d.manipulatingUnitEffect2
            call d.destroy()
            call FlushAttachedIntegerById(manipulatingUnitId, GexxoSlippers_SCOPE_ID)
            call DestroyEffectWJ(manipulatingUnitEffect)
            set manipulatingUnitEffect = null
            call DestroyEffectWJ(manipulatingUnitEffect2)
            set manipulatingUnitEffect2 = null
        else
            set d.amount = amount
        endif
        call AddHeroAgilityBonus( manipulatingUnit, manipulatingUnitType, -BONUS_AGILITY )
        call AddHeroIntelligenceBonus( manipulatingUnit, manipulatingUnitType, -BONUS_INTELLIGENCE )
        call AddUnitSpeedBonus(manipulatingUnit, -BONUS_SPEED)
    endfunction

    public function PickUp takes Unit manipulatingUnit returns nothing
        local integer manipulatingUnitId = manipulatingUnit.id
        local Data d = GetAttachedIntegerById(manipulatingUnitId, GexxoSlippers_SCOPE_ID)
        local unit manipulatingUnitSelf
        local UnitType manipulatingUnitType = manipulatingUnit.type
        if (d == NULL) then
            set d = Data.create()
            set manipulatingUnitSelf = manipulatingUnit.self
            set d.manipulatingUnitEffect = AddSpecialEffectTargetWJ(MANIPULATING_UNIT_EFFECT_PATH, manipulatingUnitSelf, MANIPULATING_UNIT_EFFECT_ATTACHMENT_POINT)
            set d.manipulatingUnitEffect2 = AddSpecialEffectTargetWJ(MANIPULATING_UNIT_EFFECT_PATH, manipulatingUnitSelf, MANIPULATING_UNIT_EFFECT_ATTACHMENT_POINT2)
            set manipulatingUnitSelf = null
            call AttachIntegerById(manipulatingUnitId, GexxoSlippers_SCOPE_ID, d)
        else
            set d.amount = d.amount + 1
        endif
        call AddHeroAgilityBonus( manipulatingUnit, manipulatingUnitType, BONUS_AGILITY )
        call AddHeroIntelligenceBonus( manipulatingUnit, manipulatingUnitType, BONUS_INTELLIGENCE )
        call AddUnitSpeedBonus(manipulatingUnit, BONUS_SPEED)
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 135)
        call SetItemTypeMaxCharges(d, 2)
        call SetItemTypeRefreshInterval(d, 30)
        call SetItemTypeRefreshIntervalStart(d, 120)
    endfunction
//! runtextmacro Endscope()