//TESH.scrollpos=57
//TESH.alwaysfold=0
//! runtextmacro Scope("GiantAxe")
    globals
        public constant integer ITEM_ID = 'I01R'

        private constant real AREA_RANGE = 125.
        private constant real BONUS_DAMAGE = 10.
        private constant real BONUS_STRENGTH = 6.
        private group ENUM_GROUP
        private constant real SPLASH_FACTOR = 0.3
        private boolexpr TARGET_CONDITIONS
        private constant string VICTIM_EFFECT_PATH = "Abilities\\Spells\\Undead\\VampiricAura\\VampiricAuraTarget.mdl"
        private constant string VICTIM_EFFECT_ATTACHMENT_POINT = "origin"
    endglobals

    private struct Data
        integer amount
    endstruct

    private function TargetConditions takes nothing returns boolean
        if (IsUnitEnemy(FILTER_UNIT_SELF, TEMP_PLAYER) == false) then
            return false
        endif
        return true
    endfunction

    public function Damage takes real damageAmount, Unit manipulatingUnit, Unit target returns nothing
        local Data d = GetAttachedIntegerById( manipulatingUnit.id, GiantAxe_SCOPE_ID )
        local unit enumUnit
        local unit targetSelf
        if (d != NULL) then
            set damageAmount = damageAmount * SPLASH_FACTOR
            set targetSelf = target.self
            set TEMP_PLAYER = manipulatingUnit.owner
            call GroupEnumUnitsInRangeWithCollision(ENUM_GROUP, GetUnitX(targetSelf), GetUnitY(targetSelf), AREA_RANGE, TARGET_CONDITIONS)
            set targetSelf = null
            set enumUnit = FirstOfGroup(ENUM_GROUP)
            if (enumUnit != null) then
                loop
                    call GroupRemoveUnit(ENUM_GROUP, enumUnit)
                    call DestroyEffectWJ( AddSpecialEffectTargetWJ( VICTIM_EFFECT_PATH, enumUnit, VICTIM_EFFECT_ATTACHMENT_POINT ) )
                    call UnitDamageUnitEx( manipulatingUnit, GetUnit(enumUnit), damageAmount, null )
                    set enumUnit = FirstOfGroup(ENUM_GROUP)
                    exitwhen (enumUnit == null)
                endloop
            endif
        endif
    endfunction

    private function Damage_Event takes nothing returns nothing
        call Damage( DAMAGE_AMOUNT, DAMAGE_SOURCE, TRIGGER_UNIT )
    endfunction

    public function Drop takes Unit manipulatingUnit returns nothing
        local integer manipulatingUnitId = manipulatingUnit.id
        local Data d = GetAttachedIntegerById(manipulatingUnitId, GiantAxe_SCOPE_ID)
        local integer amount = d.amount - 1
        if (amount == NULL) then
            call d.destroy()
            call FlushAttachedIntegerById( manipulatingUnitId, GiantAxe_SCOPE_ID )
            //! runtextmacro RemoveEventById( "manipulatingUnitId", "EVENT_DAMAGE" )
        else
            set d.amount = amount
        endif
        call AddUnitDamageBonus( manipulatingUnit, -BONUS_DAMAGE )
        call AddHeroStrengthBonus( manipulatingUnit, manipulatingUnit.type, -BONUS_STRENGTH )
    endfunction

    public function PickUp takes Unit manipulatingUnit returns nothing
        local integer manipulatingUnitId = manipulatingUnit.id
        local Data d = GetAttachedIntegerById(manipulatingUnitId, GiantAxe_SCOPE_ID)
        if (d == NULL) then
            set d = Data.create()
            set d.amount = 1
            call AttachIntegerById( manipulatingUnitId, GiantAxe_SCOPE_ID, d )
            //! runtextmacro AddEventById( "manipulatingUnitId", "EVENT_DAMAGE" )
        else
            set d.amount = d.amount + 1
        endif
        call AddUnitDamageBonus( manipulatingUnit, BONUS_DAMAGE )
        call AddHeroStrengthBonus( manipulatingUnit, manipulatingUnit.type, BONUS_STRENGTH )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 850)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 240)
        call SetItemTypeRefreshIntervalStart(d, 240)

        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY_AS_DAMAGE_SOURCE", "0", "function Damage_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
    endfunction
//! runtextmacro Endscope()