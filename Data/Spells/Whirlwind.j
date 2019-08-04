//TESH.scrollpos=240
//TESH.alwaysfold=0
//! runtextmacro Scope("Whirlwind")
    globals
        private constant integer ORDER_ID = 852129//OrderId("windwalk")
        public constant integer SPELL_ID = 'A00F'

        private real array AREA_RANGE
        private real array BONUS_ARMOR
        private constant real BONUS_RELATIVE_SPEED = -0.4
        private constant string CASTER_EFFECT_PATH = "Abilities\\Spells\\Other\\Stampede\\StampedeMissile.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "weapon"
        private real array DAMAGE_PER_INTERVAL_PER_STRENGTH_POINT
        private real array DURATION
        private real array DURATION_PER_AGILITY_POINT
        private constant real EFFECT_INTERVAL = 0.75
        private group ENUM_GROUP
        private constant real INTERVAL = 0.25
        private constant real EFFECT_CHANCE = INTERVAL / EFFECT_INTERVAL
        private constant integer LEVELS_AMOUNT = 5
        private real array MAX_DAMAGE_PER_INTERVAL
        private real array MIN_DAMAGE_PER_INTERVAL
        private boolexpr TARGET_CONDITIONS
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "chest"
        private integer array WAVES_AMOUNT
    endglobals

    private struct Data
        integer abilityLevel
        unit attackTarget
        real bonusSpeed
        Unit caster
        effect casterEffect
        real damagePerIntervalHighAmount
        real damagePerIntervalLowAmount
        timer damageTimer
        timer durationTimer
    endstruct

    private function Ending takes Unit caster, Data d, timer durationTimer returns nothing
        local integer abilityLevel = d.abilityLevel
        local unit attackTarget = d.attackTarget
        local real bonusSpeed = -d.bonusSpeed
        local effect casterEffect = d.casterEffect
        local integer casterId = caster.id
        local unit casterSelf = caster.self
        local timer damageTimer = d.damageTimer
        call d.destroy()
        call FlushAttachedIntegerById( casterId, Whirlwind_SCOPE_ID )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_ORDER_EXECUTE2" )
        call DestroyEffectWJ( casterEffect )
        set casterEffect = null
        call FlushAttachedInteger( damageTimer, Whirlwind_SCOPE_ID )
        call DestroyTimerWJ( damageTimer )
        set damageTimer = null
        call FlushAttachedInteger( durationTimer, Whirlwind_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        call AddUnitAnimationProperties( casterSelf, "attack", false )
        call AddUnitArmorBonus( caster, -BONUS_ARMOR[abilityLevel] )
        call SetUnitBlendTime( casterSelf, 0.15 )
        call AddUnitSpeedBonus( caster, bonusSpeed )
        call AddUnitPathing( caster )
        if ( attackTarget != null ) then
            call IssueTargetOrderById( casterSelf, ATTACK_ORDER_ID, attackTarget )
        endif
        set casterSelf = null
    endfunction

    public function Death takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById( caster.id, Whirlwind_SCOPE_ID )
        if ( d != NULL ) then
            call Ending( caster, d, d.durationTimer )
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, Whirlwind_SCOPE_ID)
        call Ending( d.caster, d, durationTimer )
        set durationTimer = null
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        if ( GetUnitInvulnerability( GetUnit(FILTER_UNIT_SELF) ) > 0 ) then
            return false
        endif
        return true
    endfunction

    private function DealDamage takes nothing returns nothing
        local real attackDifferenceX
        local real attackDifferenceY
        local real casterZ
        local real damageAmount
        local real damageAmountHigh
        local real damageAmountLow
        local timer damageTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(damageTimer, Whirlwind_SCOPE_ID)
        local integer abilityLevel = d.abilityLevel
        local Unit caster = d.caster
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local Unit enumUnit
        local unit enumUnitSelf
        set damageTimer = null
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, casterX, casterY, AREA_RANGE[abilityLevel] * GetUnitScale( caster ), TARGET_CONDITIONS )
        set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
        if ( enumUnitSelf != null ) then
            set casterZ = GetUnitZ( casterSelf, casterX, casterY )
            set damageAmountHigh = d.damagePerIntervalHighAmount
            set damageAmountLow = d.damagePerIntervalLowAmount
            loop
                set damageAmount = GetRandomReal( damageAmountLow, damageAmountHigh )
                set enumUnit = GetUnit(enumUnitSelf)
                call GroupRemoveUnit( ENUM_GROUP, enumUnitSelf )
                if ( GetRandomReal( 0.01, 1 ) <= EFFECT_CHANCE ) then
                    call DestroyEffectWJ( AddSpecialEffectTargetWJ( GetUnitBlood( enumUnit ), enumUnitSelf, TARGET_EFFECT_ATTACHMENT_POINT ) )
                endif
                if ( ( GetRandomReal( 0.01, 1 ) <= GetUnitCriticalStrike( caster ) - GetUnitCriticalStrikeDefense( enumUnit ) ) and ( GetUnitCriticalStrikeImmunity( enumUnit ) == 0 ) ) then
                    set attackDifferenceX = GetUnitX( enumUnitSelf ) - casterX
                    set attackDifferenceY = GetUnitY( enumUnitSelf ) - casterY
                    set damageAmount = damageAmount * CRITICAL_STRIKE_DAMAGE_FACTOR
                    call CreateMovingTextTag( I2S( R2I( damageAmount ) ) + "!", 0.02, casterX, casterY, casterZ, attackDifferenceX, attackDifferenceY, 150, 255, 0, 0, 255, 0, 1 )
                endif
                call UnitDamageUnitEx( caster, enumUnit, damageAmount, WEAPON_TYPE_METAL_LIGHT_SLICE )
                set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnitSelf == null )
            endloop
        endif
        set casterSelf = null
    endfunction

    public function Attack takes Unit caster, unit target returns nothing
        local Data d = GetAttachedIntegerById(caster.id, Whirlwind_SCOPE_ID)
        if ( d != NULL ) then
            call IssueTargetOrderById( caster.self, MOVE_ORDER_ID, target )
            set d.attackTarget = target
        endif
    endfunction

    public function OrderExecute2 takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, Whirlwind_SCOPE_ID)
        if (d != NULL) then
            set d.attackTarget = null
        endif
    endfunction

    private function OrderExecute2_Event takes nothing returns nothing
        call OrderExecute2( ORDERED_UNIT )
    endfunction

    public function OrderExecute takes Unit caster returns nothing
        local real bonusSpeed = GetUnitSpeed( caster ) * BONUS_RELATIVE_SPEED
        local integer casterId = caster.id
        local unit casterSelf = caster.self
        local integer abilityLevel = GetUnitAbilityLevel( casterSelf, SPELL_ID )
        local integer currentOrder
        local widget currentTarget
        local Data d = GetAttachedIntegerById(casterId, Whirlwind_SCOPE_ID)
        local real damageAmountPerIntervalByStrengthPoints = GetHeroStrengthTotal( caster ) * DAMAGE_PER_INTERVAL_PER_STRENGTH_POINT[abilityLevel]
        local timer damageTimer
        local real duration = DURATION[abilityLevel] + GetHeroAgilityTotal( caster ) * DURATION_PER_AGILITY_POINT[abilityLevel]
        local timer durationTimer
        local boolean isNew = ( d == NULL )
        local integer oldAbilityLevel
        local real oldBonusSpeed
        set Meditation_WHIRLWIND_CASTER = caster
        call RunTrigger( Meditation_WHIRLWIND_TRIGGER )
        if ( isNew ) then
            set currentOrder = GetUnitCurrentOrder( casterSelf )
            set currentTarget = GetUnitCurrentTarget( caster )
            set d = Data.create()
            set damageTimer = CreateTimerWJ()
            set durationTimer = CreateTimerWJ()
            set d.attackTarget = null
            set d.caster = caster
            set d.casterEffect = AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, casterSelf, CASTER_EFFECT_ATTACHMENT_POINT )
            set d.damageTimer = damageTimer
            set d.durationTimer = durationTimer
            call AttachIntegerById( casterId, Whirlwind_SCOPE_ID, d )
            //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
            //! runtextmacro AddEventById( "casterId", "EVENT_ORDER_EXECUTE2" )
            call AttachInteger( damageTimer, Whirlwind_SCOPE_ID, d )
            call AttachInteger( durationTimer, Whirlwind_SCOPE_ID, d )
        else
            set oldAbilityLevel = d.abilityLevel
            set oldBonusSpeed = d.bonusSpeed
        endif
        set d.abilityLevel = abilityLevel
        set d.bonusSpeed = bonusSpeed
        set d.damagePerIntervalHighAmount = MAX_DAMAGE_PER_INTERVAL[abilityLevel] + damageAmountPerIntervalByStrengthPoints
        set d.damagePerIntervalLowAmount = MIN_DAMAGE_PER_INTERVAL[abilityLevel] + damageAmountPerIntervalByStrengthPoints
        if ( isNew ) then
            call AddUnitAnimationProperties( casterSelf, "attack", true )
            call AddUnitArmorBonus( caster, BONUS_ARMOR[abilityLevel] )
            call SetUnitBlendTime( casterSelf, 0 )
            call RemoveUnitPathing( caster )
            call AddUnitSpeedBonus( caster, bonusSpeed )
            call TimerStart( damageTimer, INTERVAL, true, function DealDamage )
            set damageTimer = null
        else
            call AddUnitArmorBonus( caster, BONUS_ARMOR[abilityLevel] - BONUS_ARMOR[oldAbilityLevel] )
            call AddUnitSpeedBonus( caster, bonusSpeed - oldBonusSpeed )
        endif
        if ( duration > TimerGetRemaining( durationTimer ) ) then
            call TimerStart( durationTimer, duration, false, function EndingByTimer )
        endif
        set durationTimer = null
        if (isNew) then
            if ( currentTarget != null ) then
                call StopUnit( caster )
                call IssueTargetOrderById( casterSelf, currentOrder, currentTarget )
                set currentTarget = null
            endif
        endif
        set casterSelf = null
    endfunction

    private function OrderExecute_Event takes nothing returns nothing
        call OrderExecute( ORDERED_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = LEVELS_AMOUNT
        set AREA_RANGE[1] = 230
        set AREA_RANGE[2] = 230
        set AREA_RANGE[3] = 230
        set AREA_RANGE[4] = 230
        set AREA_RANGE[5] = 230
        set BONUS_ARMOR[1] = 4
        set BONUS_ARMOR[2] = 4
        set BONUS_ARMOR[3] = 4
        set BONUS_ARMOR[4] = 4
        set BONUS_ARMOR[5] = 4
        set DAMAGE_PER_INTERVAL_PER_STRENGTH_POINT[1] = 1
        set DAMAGE_PER_INTERVAL_PER_STRENGTH_POINT[2] = 1
        set DAMAGE_PER_INTERVAL_PER_STRENGTH_POINT[3] = 1
        set DAMAGE_PER_INTERVAL_PER_STRENGTH_POINT[4] = 1
        set DAMAGE_PER_INTERVAL_PER_STRENGTH_POINT[5] = 1
        set DURATION[1] = 3
        set DURATION[2] = 3
        set DURATION[3] = 3.5
        set DURATION[4] = 3.5
        set DURATION[5] = 4
        set DURATION_PER_AGILITY_POINT[1] = 0
        set DURATION_PER_AGILITY_POINT[2] = 0
        set DURATION_PER_AGILITY_POINT[3] = 0
        set DURATION_PER_AGILITY_POINT[4] = 0
        set DURATION_PER_AGILITY_POINT[5] = 0
        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_ORDER_EXECUTE2", "UnitGetsOrder_Executed_Executed_EVENT_KEY", "0", "function OrderExecute2_Event" )
        set MAX_DAMAGE_PER_INTERVAL[1] = 112
        set MAX_DAMAGE_PER_INTERVAL[2] = 144
        set MAX_DAMAGE_PER_INTERVAL[3] = 171
        set MAX_DAMAGE_PER_INTERVAL[4] = 195
        set MAX_DAMAGE_PER_INTERVAL[5] = 226
        set MIN_DAMAGE_PER_INTERVAL[1] = 40
        set MIN_DAMAGE_PER_INTERVAL[2] = 56
        set MIN_DAMAGE_PER_INTERVAL[3] = 70
        set MIN_DAMAGE_PER_INTERVAL[4] = 81
        set MIN_DAMAGE_PER_INTERVAL[5] = 93
        loop
            set WAVES_AMOUNT[iteration] = R2I( DURATION[iteration] / INTERVAL )
            set DAMAGE_PER_INTERVAL_PER_STRENGTH_POINT[iteration] = DAMAGE_PER_INTERVAL_PER_STRENGTH_POINT[iteration] / WAVES_AMOUNT[iteration]
            set MAX_DAMAGE_PER_INTERVAL[iteration] = MAX_DAMAGE_PER_INTERVAL[iteration] / WAVES_AMOUNT[iteration]
            set MIN_DAMAGE_PER_INTERVAL[iteration] = MIN_DAMAGE_PER_INTERVAL[iteration] / WAVES_AMOUNT[iteration]
            set iteration = iteration - 1
            exitwhen (iteration < 1)
        endloop
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType(CASTER_EFFECT_PATH)
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER_EXECUTE", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_Executed_Executed_EVENT_KEY", "0", "function OrderExecute_Event" )
    endfunction
//! runtextmacro Endscope()