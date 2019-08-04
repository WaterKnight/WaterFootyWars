//TESH.scrollpos=33
//TESH.alwaysfold=0
//! runtextmacro Scope("EarlyPromotion")
    globals
        private constant integer ORDER_ID = 852072//OrderId( "militia" )
        public constant integer SPELL_ID = 'A08G'

        private constant real AREA_RANGE = 250.
        private group ENUM_GROUP
        private constant integer MAX_TARGETS_AMOUNT = 3
        private constant string SPECIAL_EFFECT_PATH = "Abilities\\Spells\\Human\\Resurrect\\ResurrectCaster.mdl"
        private boolexpr TARGET_CONDITIONS
    endglobals

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) == false ) then
            return false
        endif
        set FILTER_UNIT = GetUnit(FILTER_UNIT_SELF)
        if (IsUnitIllusionWJ(FILTER_UNIT)) then
            return false
        endif
        if ( GetUnitRevaluation(FILTER_UNIT) > 0 ) then
            return false
        endif
        if ( IsUnitTypeSpawn(FILTER_UNIT.type) == false ) then
            return false
        endif
        return true
    endfunction

    public function SpellEffect takes Unit caster, real targetX, real targetY returns nothing
        local unit enumUnit
        local integer iteration = MAX_TARGETS_AMOUNT
        call DestroyEffect( AddSpecialEffect( SPECIAL_EFFECT_PATH, targetX, targetY ) )
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, targetX, targetY, AREA_RANGE, TARGET_CONDITIONS )
        loop
            set enumUnit = GetNearestUnit( ENUM_GROUP, targetX, targetY )
            exitwhen ( enumUnit == null )
            call GroupRemoveUnit( ENUM_GROUP, enumUnit )
            call SetUnitRevaluation(GetUnit(enumUnit), 1)
            call SetUnitState(enumUnit, UNIT_STATE_LIFE, GetUnitState(enumUnit, UNIT_STATE_MAX_LIFE))
            set iteration = iteration - 1
            exitwhen ( iteration < 1 )
        endloop
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_X, TARGET_Y )
    endfunction

    public function Order takes player casterOwner, real targetX, real targetY returns string
        set TEMP_PLAYER = casterOwner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, targetX, targetY, AREA_RANGE, TARGET_CONDITIONS )
        if ( FirstOfGroup( ENUM_GROUP ) == null ) then
            return ErrorStrings_EARLY_PROMOTION
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( ORDERED_UNIT.owner, TARGET_X, TARGET_Y )
    endfunction

    public function Init takes nothing returns nothing
        set ENUM_GROUP = CreateGroupWJ()
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( SPECIAL_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()