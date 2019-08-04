//TESH.scrollpos=179
//TESH.alwaysfold=0
//! runtextmacro Scope("SummonInfernal")
    globals
        private constant integer ORDER_ID = 852489//OrderId( "summonphoenix" )
        public constant integer SPELL_ID = 'A007'

        private constant integer DUMMY_UNIT_ID = 'n006'
        private real array DURATION
        private real array DURATION_PER_STRENGTH_POINT
        private constant integer LEVELS_AMOUNT = 2
        private constant real RELEASE_TIME = 1.7
        private integer array SPAWN_UNIT_ID
    endglobals

    private struct Data
        integer abilityLevel
        real duration
        Unit infernal
    endstruct

    //! runtextmacro Scope("Fire")
        globals
            private real array Fire_AREA_RANGE
            private real array Fire_DAMAGE_PER_INTERVAL
            private real array Fire_DURATION
            private constant integer Fire_DUMMY_UNIT_ID = 'n02Y'
            private group Fire_ENUM_GROUP
            private constant real Fire_INTERVAL = 0.5
            private boolexpr Fire_TARGET_CONDITIONS
        endglobals

        private struct Fire_Data
            integer abilityLevel
            Unit caster
            unit dummyUnit
            timer intervalTimer
            real targetX
            real targetY
        endstruct

        private function Fire_Ending takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Fire_Data d = GetAttachedInteger(durationTimer, Fire_SCOPE_ID)
            local unit dummyUnit = d.dummyUnit
            local timer intervalTimer = d.intervalTimer
            call d.destroy()
            call SetUnitAnimationByIndex( dummyUnit, 2 )
            call RemoveUnitTimed( dummyUnit, 2 )
            set dummyUnit = null
            call FlushAttachedInteger( durationTimer, Fire_SCOPE_ID )
            call DestroyTimerWJ( durationTimer )
            set durationTimer = null
            call FlushAttachedInteger( intervalTimer, Fire_SCOPE_ID )
            call DestroyTimerWJ( intervalTimer )
            set intervalTimer = null
        endfunction

        private function Fire_TargetConditions takes nothing returns boolean
            set FILTER_UNIT_SELF = GetFilterUnit()
            if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) ) then
                return false
            endif
            if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
                return false
            endif
            set FILTER_UNIT = GetUnit(FILTER_UNIT_SELF)
            if ( GetUnitInvulnerability( FILTER_UNIT ) > 0 ) then
                return false
            endif
            if ( GetUnitMagicImmunity( FILTER_UNIT ) > 0 ) then
                return false
            endif
            return true
        endfunction

        private function Fire_Interval takes nothing returns nothing
            local real damageAmount
            local unit enumUnit
            local timer intervalTimer = GetExpiredTimer()
            local Fire_Data d = GetAttachedInteger(intervalTimer, Fire_SCOPE_ID)
            local integer abilityLevel = d.abilityLevel
            local Unit caster = d.caster
            local real targetX = d.targetX
            local real targetY = d.targetY
            set TEMP_PLAYER = caster.owner
            call GroupEnumUnitsInRangeWithCollision( Fire_ENUM_GROUP, targetX, targetY, Fire_AREA_RANGE[abilityLevel], Fire_TARGET_CONDITIONS )
            set enumUnit = FirstOfGroup( Fire_ENUM_GROUP )
            if ( enumUnit != null ) then
                set damageAmount = Fire_DAMAGE_PER_INTERVAL[abilityLevel]
                loop
                    call GroupRemoveUnit( Fire_ENUM_GROUP, enumUnit )
                    call UnitDamageUnitBySpell( caster, GetUnit(enumUnit), damageAmount )
                    set enumUnit = FirstOfGroup( Fire_ENUM_GROUP )
                    exitwhen ( enumUnit == null )
                endloop
            endif
        endfunction

        public function Fire_Start takes integer abilityLevel, Unit caster, real targetX, real targetY returns nothing
            local Fire_Data d = Fire_Data.create()
            local unit dummyUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, Fire_DUMMY_UNIT_ID, targetX, targetY, GetRandomReal( 0, 2 * PI ) )
            local real dummyUnitScale = Fire_AREA_RANGE[abilityLevel] / 200
            local timer durationTimer = CreateTimerWJ()
            local timer intervalTimer = CreateTimerWJ()
            set d.abilityLevel = abilityLevel
            set d.caster = caster
            set d.dummyUnit = dummyUnit
            set d.intervalTimer = intervalTimer
            set d.targetX = targetX
            set d.targetY = targetY
            call AttachInteger( durationTimer, Fire_SCOPE_ID, d )
            call AttachInteger( intervalTimer, Fire_SCOPE_ID, d )
            call SetUnitAnimationByIndex( dummyUnit, 0 )
            call SetUnitScale( dummyUnit, dummyUnitScale, dummyUnitScale, dummyUnitScale )
            set dummyUnit = null
            call TimerStart( intervalTimer, Fire_INTERVAL, true, function Fire_Interval )
            set intervalTimer = null
            call TimerStart( durationTimer, Fire_DURATION[abilityLevel], true, function Fire_Ending )
            set durationTimer = null
        endfunction

        public function Fire_Init takes nothing returns nothing
            local integer iteration = LEVELS_AMOUNT
            set Fire_AREA_RANGE[1] = 350
            set Fire_AREA_RANGE[2] = 350
            set Fire_DAMAGE_PER_INTERVAL[1] = 225.
            set Fire_DAMAGE_PER_INTERVAL[2] = 225.
            set Fire_DURATION[1] = 5
            set Fire_DURATION[2] = 5
            loop
                set Fire_DAMAGE_PER_INTERVAL[iteration] = Fire_DAMAGE_PER_INTERVAL[iteration] / R2I(Fire_DURATION[iteration] / Fire_INTERVAL)
                set iteration = iteration - 1
                exitwhen (iteration < 1)
            endloop
            set Fire_ENUM_GROUP = CreateGroupWJ()
            set Fire_TARGET_CONDITIONS = ConditionWJ( function Fire_TargetConditions )
            call InitUnitType( Fire_DUMMY_UNIT_ID )
        endfunction
    //! runtextmacro Endscope()

    private function Release takes nothing returns nothing
        local timer releaseTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(releaseTimer, SummonInfernal_SCOPE_ID)
        local integer abilityLevel = d.abilityLevel
        local Unit infernal = d.infernal
        local unit infernalSelf = infernal.self
        call d.destroy()
        call FlushAttachedInteger( releaseTimer, SummonInfernal_SCOPE_ID )
        call DestroyTimerWJ( releaseTimer )
        set releaseTimer = null
        call SetUnitTimeScale( infernalSelf, 1 )
        call SetUnitBlendTime( infernalSelf, 0.15 )
        call SetUnitAnimationByIndex( infernalSelf, 0 )
        call PauseUnit( infernalSelf, false )
        call SetUnitInvulnerable( infernalSelf, false )
        call UnitApplyTimedLifeWJ( infernalSelf, DURATION[abilityLevel] )
        set infernalSelf = null
    endfunction

    public function SpellEffect takes Unit caster, real targetX, real targetY returns nothing
        local integer abilityLevel = GetUnitAbilityLevel( caster.self, SPELL_ID )
        local player casterOwner = caster.owner
        local Data d = Data.create()
        local unit dummyUnit = CreateUnitWJ( casterOwner, DUMMY_UNIT_ID, targetX, targetY, STANDARD_ANGLE )
        local Unit infernal = CreateUnitEx( casterOwner, SPAWN_UNIT_ID[abilityLevel], 0, 0, GetRandomReal( 0, 2 * PI ) )
        local unit infernalSelf = infernal.self
        local timer releaseTimer = CreateTimerWJ()
        set casterOwner = null
        call RemoveUnitTimed( dummyUnit, 2 )
        set dummyUnit = null
        set d.abilityLevel = abilityLevel
        set d.duration = DURATION[abilityLevel] + GetHeroStrengthTotal(caster) * DURATION_PER_STRENGTH_POINT[abilityLevel]
        set d.infernal = infernal
        call AttachInteger( releaseTimer, SummonInfernal_SCOPE_ID, d )
        call SetUnitBlendTime( infernalSelf, 0 )
        call SetUnitTimeScale( infernalSelf, 1.4 )
        call SetUnitAnimationByIndex( infernalSelf, 7 )
        call PauseUnit( infernalSelf, true )
        call SetUnitInvulnerable( infernalSelf, true )
        call SetUnitX( infernalSelf, targetX )
        call SetUnitY( infernalSelf, targetY )
        set infernalSelf = null
        call TimerStart( releaseTimer, RELEASE_TIME, false, function Release )
        set releaseTimer = null
        call Fire_Fire_Start(abilityLevel, caster, targetX, targetY)
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_X, TARGET_Y )
    endfunction

    public function Order takes real targetX, real targetY returns string
        if (IsPointInPlayRegion(targetX, targetY) == false) then
            return ErrorStrings_INVALID_TARGET
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( TARGET_X, TARGET_Y )
    endfunction

    public function Init takes nothing returns nothing
        set DURATION[1] = 40
        set DURATION[2] = 40
        set DURATION_PER_STRENGTH_POINT[1] = 1.5
        set DURATION_PER_STRENGTH_POINT[2] = 1.5
        set SPAWN_UNIT_ID[1] = INFERNAL_UNIT_ID
        set SPAWN_UNIT_ID[2] = MONSTROUS_INFERNAL_UNIT_ID
        call InitUnitType( DUMMY_UNIT_ID )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call Fire_Fire_Init()
    endfunction
//! runtextmacro Endscope()