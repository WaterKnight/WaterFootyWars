//TESH.scrollpos=192
//TESH.alwaysfold=0
//! runtextmacro Scope("ChainLightning")
    private struct Data
        Unit caster
        timer delayTimer
        integer jumpsAmount
        Unit target
        group targetGroup
    endstruct

    globals
        private constant integer ORDER_ID = 852119//OrderId( "chainlightning" )
        public constant integer SPELL_ID = 'A071'

        private constant real AREA_RANGE = 700.
        private constant real DAMAGE_START = 200.
        private constant real DAMAGE_REDUCTION_PER_JUMP_FACTOR = 0.1
        private trigger CHOOSE_TRIGGER
        private constant real EFFECT_LIGHTNING_DURATION = 0.3
        private constant string EFFECT_LIGHTNING_PATH = "CLPB"
        private constant string EFFECT_LIGHTNING2_PATH = "CLSB"
        private group ENUM_GROUP
        private constant real JUMP_DELAY = 0.175
        private constant integer MAX_TARGETS_AMOUNT = 8
        private boolexpr TARGET_CONDITIONS
        private constant string TARGET_EFFECT_PATH = "Abilities\\Weapons\\Bolt\\BoltImpact.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "chest"

        private Data CHOOSE_TRIGGER_D
        private Unit CHOOSE_TRIGGER_SOURCE
    endglobals

    private function Ending_Target takes Data d, Unit target returns nothing
        local integer targetId = target.id
        call RemoveIntegerFromTableById(targetId, ChainLightning_SCOPE_ID, d)
        if (CountIntegersInTableById(targetId, ChainLightning_SCOPE_ID) == TABLE_EMPTY) then
            //! runtextmacro RemoveEventById( "targetId", "EVENT_DECAY" )
        endif
    endfunction

    private function Ending takes Unit caster, Data d, timer delayTimer, boolean isTargetNotNull, Unit target, group targetGroup returns nothing
        call d.destroy()
        call RemoveUnitRemainingReference( caster )
        call FlushAttachedInteger( delayTimer, ChainLightning_SCOPE_ID )
        call DestroyTimerWJ( delayTimer )
        if ( isTargetNotNull ) then
            call Ending_Target(d, target)
        endif
        call DestroyGroupWJ( targetGroup )
    endfunction

    private function TargetConditions_Single takes player casterOwner, Unit checkingUnit returns boolean
        set TEMP_UNIT_SELF = checkingUnit.self
        if ( GetUnitState( TEMP_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( TEMP_UNIT_SELF, casterOwner ) ) then
            return false
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_HERO ) ) then
            return false
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        if ( GetUnitMagicImmunity( checkingUnit ) > 0 ) then
            return false
        endif
        if ( GetUnitInvulnerability( checkingUnit ) > 0 ) then
            return false
        endif
        if ( IsUnitWard( checkingUnit ) ) then
            return false
        endif
        return true
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( IsUnitInGroup( FILTER_UNIT_SELF, TEMP_GROUP ) ) then
            return false
        endif
        if ( TargetConditions_Single( TEMP_PLAYER, GetUnit(FILTER_UNIT_SELF) ) == false ) then
            return false
        endif
        return true
    endfunction

    private function Impact takes nothing returns nothing
        local timer delayTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(delayTimer, ChainLightning_SCOPE_ID)
        local Unit caster = d.caster
        local integer jumpsAmount
        local Unit target = d.target
        call Ending_Target(d, target)
        if ( target == NULL ) then
            call Ending( caster, d, delayTimer, false, NULL, d.targetGroup )
        else
            call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, target.self, TARGET_EFFECT_ATTACHMENT_POINT ) )
            if ( TargetConditions_Single( caster.owner, target ) ) then
                set jumpsAmount = d.jumpsAmount + 1
                if ( jumpsAmount < MAX_TARGETS_AMOUNT ) then
                    set CHOOSE_TRIGGER_D = d
                    set CHOOSE_TRIGGER_SOURCE = target
                    set d.jumpsAmount = jumpsAmount
                    call RunTrigger(CHOOSE_TRIGGER)
                else
                    call Ending( caster, d, delayTimer, true, target, d.targetGroup )
                endif
                call UnitDamageUnitBySpell( caster, target, DAMAGE_START * ( 1 - ( jumpsAmount - 1 ) * DAMAGE_REDUCTION_PER_JUMP_FACTOR ) )
            else
                call Ending( caster, d, delayTimer, true, target, d.targetGroup )
            endif
        endif
        set delayTimer = null
    endfunction

    public function Decay takes Unit target returns nothing
        local Data d
        local integer targetId = target.id
        local integer iteration = CountIntegersInTableById(targetId, ChainLightning_SCOPE_ID)
        if ( iteration > TABLE_EMPTY ) then
            loop
                set d = GetIntegerFromTableById(targetId, ChainLightning_SCOPE_ID, iteration)
                call Ending_Target(d, target)
                set d.target = NULL
                set iteration = iteration - 1
                exitwhen (iteration < TABLE_STARTED)
            endloop
        endif
    endfunction

    private function Decay_Event takes nothing returns nothing
        call Decay(TRIGGER_UNIT)
    endfunction

    public function Jump takes Data d, timer delayTimer, Unit source, Unit target, group targetGroup, string whichLightningTypeId returns nothing
        local integer targetId = target.id
        call DestroyLightningTimedEx( AddLightningBetweenUnits( whichLightningTypeId, source, target ), EFFECT_LIGHTNING_DURATION )
        set d.target = target
        call AddIntegerToTableById(targetId, ChainLightning_SCOPE_ID, d)
        if (CountIntegersInTableById(targetId, ChainLightning_SCOPE_ID) == TABLE_STARTED) then
            //! runtextmacro AddEventById( "targetId", "EVENT_DECAY" )
        endif
        call GroupAddUnit( targetGroup, target.self )
        call TimerStart( delayTimer, JUMP_DELAY, false, function Impact )
    endfunction

    private function ChooseTrig takes nothing returns nothing
        local Data d = CHOOSE_TRIGGER_D
        local Unit caster = d.caster
        local unit enumUnit
        local Unit source = CHOOSE_TRIGGER_SOURCE
        local unit sourceSelf = source.self
        local real sourceX = GetUnitX( sourceSelf )
        local real sourceY = GetUnitY( sourceSelf )
        local group targetGroup = d.targetGroup
        set sourceSelf = null
        set TEMP_GROUP = targetGroup
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, sourceX, sourceY, AREA_RANGE, TARGET_CONDITIONS )
        set enumUnit = GetNearestUnit( ENUM_GROUP, sourceX, sourceY )
        if ( enumUnit == null ) then
            call Ending( caster, d, d.delayTimer, false, GetUnit(enumUnit), targetGroup )
        else
            call Jump( d, d.delayTimer, source, GetUnit(enumUnit), targetGroup, EFFECT_LIGHTNING2_PATH )
            set enumUnit = null
        endif
        set targetGroup = null
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local Data d = Data.create()
        local timer delayTimer = CreateTimerWJ()
        local group targetGroup = CreateGroupWJ()
        set d.caster = caster
        set d.delayTimer = delayTimer
        set d.jumpsAmount = 0
        set d.targetGroup = targetGroup
        call AddUnitRemainingReference( caster )
        call AttachInteger( delayTimer, ChainLightning_SCOPE_ID, d )
        call Jump( d, delayTimer, caster, target, targetGroup, EFFECT_LIGHTNING_PATH )
        set delayTimer = null
        set targetGroup = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    public function Order takes player casterOwner, Unit target returns string
        set TEMP_UNIT_SELF = target.self
        if ( IsUnitAlly( TEMP_UNIT_SELF, casterOwner ) ) then
            return ErrorStrings_NOT_ALLY
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_HERO ) ) then
            return ErrorStrings_NOT_HERO
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return ErrorStrings_ONLY_ORGANIC
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return ErrorStrings_NOT_STRUCTURE
        endif
        if ( GetUnitMagicImmunity( target ) > 0 ) then
            return ErrorStrings_TARGET_IS_MAGIC_IMMUNE
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( ORDERED_UNIT.owner, TARGET_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        set CHOOSE_TRIGGER = CreateTriggerWJ()
        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DECAY", "UnitFinishesDecaying_EVENT_KEY", "0", "function Decay_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call AddTriggerCode(CHOOSE_TRIGGER, function ChooseTrig)
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call InitEffectType( TARGET_EFFECT_PATH )
    endfunction
//! runtextmacro Endscope()