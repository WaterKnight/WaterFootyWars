//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("AstralGauntlets")
    globals
        public constant integer ITEM_ID = 'I01H'

        private constant real BONUS_INTELLIGENCE = 2.
        private constant real BONUS_STRENGTH = 2.
        private constant real BONUS_SUMMON_DAMAGE = 15.
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Human\\Feedback\\ArcaneTowerAttack.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "origin"
    endglobals

    private struct Data
        integer amount = 1
    endstruct

    public function Drop takes Unit manipulatingUnit returns nothing
        local integer manipulatingUnitId = manipulatingUnit.id
        local Data d = GetAttachedIntegerById(manipulatingUnitId, AstralGauntlets_SCOPE_ID)
        local integer amount = d.amount - 1
        local UnitType manipulatingUnitType = manipulatingUnit.type
        if (amount == 0) then
            call d.destroy()
            call FlushAttachedIntegerById(manipulatingUnitId, AstralGauntlets_SCOPE_ID)
            //! runtextmacro RemoveEventById( "manipulatingUnitId", "EVENT_DAMAGE" )
        else
            set d.amount = amount
        endif
        call AddHeroIntelligenceBonus( manipulatingUnit, manipulatingUnitType, -BONUS_INTELLIGENCE )
        call AddHeroStrengthBonus( manipulatingUnit, manipulatingUnitType, -BONUS_STRENGTH )
    endfunction

    private function Damage_Conditions takes unit target returns boolean
        if ( IsUnitType( target, UNIT_TYPE_SUMMONED ) == false ) then
            return false
        endif
        return true
    endfunction

    public function Damage takes Unit manipulatingUnit, real damageAmount, Unit target returns real
        local Data d = GetAttachedIntegerById(manipulatingUnit.id, AstralGauntlets_SCOPE_ID)
        local unit targetSelf
        if (d != NULL) then
            set targetSelf = target.self
            if ( Damage_Conditions( targetSelf ) ) then
                set damageAmount = damageAmount + d.amount * BONUS_SUMMON_DAMAGE
                call DestroyEffectWJ(AddSpecialEffectTargetWJ(TARGET_EFFECT_PATH, targetSelf, TARGET_EFFECT_ATTACHMENT_POINT))
            endif
            set targetSelf = null
        endif
        return damageAmount
    endfunction

    private function Damage_Event takes nothing returns nothing
        set DAMAGE_AMOUNT = Damage( DAMAGE_SOURCE, DAMAGE_AMOUNT, TRIGGER_UNIT )
    endfunction

    public function PickUp takes Unit manipulatingUnit returns nothing
        local integer manipulatingUnitId = manipulatingUnit.id
        local Data d = GetAttachedIntegerById(manipulatingUnitId, AstralGauntlets_SCOPE_ID)
        local UnitType manipulatingUnitType = manipulatingUnit.type
        if (d == NULL) then
            set d = Data.create()
            call AttachIntegerById(manipulatingUnitId, AstralGauntlets_SCOPE_ID, d)
            //! runtextmacro AddEventById( "manipulatingUnitId", "EVENT_DAMAGE" )
        else
            set d.amount = d.amount + 1
        endif
        call AddHeroIntelligenceBonus( manipulatingUnit, manipulatingUnitType, BONUS_INTELLIGENCE )
        call AddHeroStrengthBonus( manipulatingUnit, manipulatingUnitType, BONUS_STRENGTH )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 275)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 50)
        call SetItemTypeRefreshIntervalStart(d, 140)

        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY_FOR_UNBLOCKABLE_AS_DAMAGE_SOURCE", "0", "function Damage_Event" )
    endfunction
//! runtextmacro Endscope()