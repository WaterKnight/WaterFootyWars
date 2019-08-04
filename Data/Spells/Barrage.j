//TESH.scrollpos=249
//TESH.alwaysfold=0
//! runtextmacro Scope("Barrage")
    globals
        private constant integer ORDER_ID = 852089//OrderId( "blizzard" )
        public constant integer SPELL_ID = 'A01U'

        private real array DAMAGE
        private real array DAMAGE_PER_STRENGTH_POINT
        private real array DURATION
        private real array EXPLOSION_DAMAGE
        private real array INTERVAL
        private constant integer LEVELS_AMOUNT = 5
        private constant real MINIMUM_RANGE = 300.
        private integer array WAVES_AMOUNT
    endglobals

    private struct Data
        integer abilityLevel
        Unit caster
        real damageAmount
        timer durationTimer
        real explosionDamageAmount
        timer intervalTimer
        integer remainingArrowsAmount
        real targetX
        real targetY
    endstruct

    private function Ending takes Unit caster, Data d, timer intervalTimer returns nothing
        local timer durationTimer = d.durationTimer
        call d.destroy()
        call FlushAttachedIntegerById( caster.id, Barrage_SCOPE_ID )
        call FlushAttachedInteger( durationTimer, Barrage_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call FlushAttachedInteger( intervalTimer, Barrage_SCOPE_ID )
        call DestroyTimerWJ( intervalTimer )
        call SetUnitAnimationByIndex( caster.self, 0 )
    endfunction

    public function EndCast takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, Barrage_SCOPE_ID)
        local timer intervalTimer
        if ( d != NULL ) then
            set intervalTimer = d.intervalTimer
            call PauseTimer( intervalTimer )
            if ( d.remainingArrowsAmount == 0 ) then
                call Ending( caster, d, intervalTimer )
            endif
            set intervalTimer = null
        endif
    endfunction

    private function EndCast_Event takes nothing returns nothing
        call EndCast( CASTER )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, Barrage_SCOPE_ID)
        set durationTimer = null
        call IssueImmediateOrderById( d.caster.self, STOP_ORDER_ID )
    endfunction

    //! runtextmacro Scope("Explosion")
        globals
            private real array Explosion_AREA_RANGE
            private real array Explosion_DAMAGE_REDUCTION_FACTOR
            private constant string Explosion_SPECIAL_EFFECT_PATH = "Abilities\\Weapons\\SteamTank\\SteamTankImpact.mdl"
            private boolexpr Explosion_TARGET_CONDITIONS

            private Data Explosion_D = NULL
        endglobals

        private function Explosion_TargetConditions takes nothing returns boolean
            set FILTER_UNIT_SELF = GetFilterUnit()
            if ( FILTER_UNIT_SELF == TEMP_UNIT_SELF ) then
                return false
            endif
            if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
                return false
            endif
            if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) ) then
                return false
            endif
            if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_FLYING ) ) then
                return false
            endif
            if ( GetUnitInvulnerability( GetUnit(FILTER_UNIT_SELF) ) > 0 ) then
                return false
            endif
            return true
        endfunction

        public function Explosion_Ending takes nothing returns nothing
            set Explosion_D = NULL
        endfunction

        public function Explosion_Start takes Data d returns nothing
            set Explosion_D = d
        endfunction

        public function Explosion_BeforeDying takes Unit caster, Unit target returns nothing
            local integer abilityLevel
            local Data d
            local group enumGroup
            local unit enumUnit
            local unit targetSelf
            local real targetX
            local real targetY
            if ( Explosion_D != NULL ) then
                set d = Explosion_D
                set abilityLevel = d.abilityLevel
                set enumGroup = CreateGroupWJ()
                set targetSelf = target.self
                set targetX = GetUnitX( targetSelf )
                set targetY = GetUnitY( targetSelf )
                call DestroyEffectWJ( AddSpecialEffectWJ( Explosion_SPECIAL_EFFECT_PATH, targetX, targetY ) )
                set d.explosionDamageAmount = d.explosionDamageAmount * Explosion_DAMAGE_REDUCTION_FACTOR[abilityLevel]
                call AddUnitExplode( target )
                set TEMP_PLAYER = caster.owner
                set TEMP_UNIT_SELF = targetSelf
                set targetSelf = null
                call GroupEnumUnitsInRangeWithCollision( enumGroup, targetX, targetY, Explosion_AREA_RANGE[abilityLevel], Explosion_TARGET_CONDITIONS )
                set enumUnit = FirstOfGroup( enumGroup )
                if ( enumUnit != null ) then
                    loop
                        call GroupRemoveUnit( enumGroup, enumUnit )
                        call Explosion_Start(d)
                        call UnitDamageUnitEx( caster, GetUnit(enumUnit), d.explosionDamageAmount, null )
                        call Explosion_Ending()
                        set enumUnit = FirstOfGroup( enumGroup )
                        exitwhen ( enumUnit == null )
                    endloop
                endif
                call DestroyGroupWJ(enumGroup)
                set enumGroup = null
            endif
        endfunction

        public function Explosion_Init takes nothing returns nothing
            set Explosion_AREA_RANGE[1] = 150
            set Explosion_AREA_RANGE[2] = 150
            set Explosion_AREA_RANGE[3] = 150
            set Explosion_AREA_RANGE[4] = 150
            set Explosion_AREA_RANGE[5] = 150
            set Explosion_DAMAGE_REDUCTION_FACTOR[1] = 0.8
            set Explosion_DAMAGE_REDUCTION_FACTOR[2] = 0.8
            set Explosion_DAMAGE_REDUCTION_FACTOR[3] = 0.8
            set Explosion_DAMAGE_REDUCTION_FACTOR[4] = 0.8
            set Explosion_DAMAGE_REDUCTION_FACTOR[5] = 0.8
            call InitEffectType( Explosion_SPECIAL_EFFECT_PATH )
            set Explosion_TARGET_CONDITIONS = ConditionWJ( function Explosion_TargetConditions )
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro Scope("Arrow")
        globals
            private real array Arrow_AREA_RANGE
            private constant integer Arrow_DUMMY_UNIT_ID = 'h00H'
            private group Arrow_ENUM_GROUP
            private constant real HIT_RANGE = 120.
            private boolexpr Arrow_TARGET_CONDITIONS
            private constant string Arrow_TARGET_EFFECT_PATH = "Abilities\\Weapons\\LavaSpawnMissile\\LavaSpawnBirthMissile.mdl"
            private constant string Arrow_TARGET_EFFECT2_PATH = "Abilities\\Spells\\Human\\FlakCannons\\FlakTarget.mdl"
        endglobals

        private struct Arrow_Data
            Data d
            real targetX
            real targetY
        endstruct

        private function Arrow_TargetConditions takes nothing returns boolean
            set FILTER_UNIT_SELF = GetFilterUnit()
            if ( FILTER_UNIT_SELF == WORLD_CASTER ) then
                return false
            endif
            if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
                return false
            endif
            if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) ) then
                return false
            endif
            if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_FLYING ) ) then
                return false
            endif
            if ( GetUnitInvulnerability( GetUnit(FILTER_UNIT_SELF) ) > 0 ) then
                return false
            endif
            return true
        endfunction

        private function Arrow_ExplosionConditions takes Unit checkingUnit returns boolean
            set TEMP_UNIT_SELF = checkingUnit.self
            if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_HERO ) ) then
                return false
            endif
            if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
                return false
            endif
            if ( IsUnitWard( checkingUnit ) ) then
                return false
            endif
            return true
        endfunction

        private function Arrow_ImpactTrig takes nothing returns nothing
            local integer abilityLevel
            local Unit caster
            local Data d
            local Arrow_Data e
            local real damageAmount
            local unit dummyUnit = GetEventDamageSource()
            local Unit enumUnit
            local unit enumUnitSelf
            local real explosionDamageAmount
            local real explosionDamageAmountStart
            local real explosionDamageReductionFactor
            local integer remainingArrowsAmount
            local real targetX
            local real targetY
            if ( GetUnitTypeId( dummyUnit ) == Arrow_DUMMY_UNIT_ID ) then
                set e = GetAttachedInteger(dummyUnit, Arrow_SCOPE_ID)
                set d = e.d
                set abilityLevel = d.abilityLevel
                set caster = d.caster
                set damageAmount = d.damageAmount
                set explosionDamageAmountStart = d.explosionDamageAmount
                set explosionDamageAmount = explosionDamageAmountStart
                set remainingArrowsAmount = d.remainingArrowsAmount - 1
                set targetX = e.targetX
                set targetY = e.targetY
                call e.destroy()
                call FlushAttachedInteger( dummyUnit, Arrow_SCOPE_ID )
                call RemoveUnitWJ( dummyUnit )
                call DestroyEffectWJ( AddSpecialEffectWJ( Arrow_TARGET_EFFECT_PATH, targetX, targetY ) )
                call DestroyEffectWJ( AddSpecialEffectWJ( Arrow_TARGET_EFFECT2_PATH, targetX, targetY ) )
                set TEMP_PLAYER = caster.owner
                call GroupEnumUnitsInRangeWithCollision( Arrow_ENUM_GROUP, targetX, targetY, HIT_RANGE, Arrow_TARGET_CONDITIONS )
                set enumUnitSelf = FirstOfGroup( Arrow_ENUM_GROUP )
                if (enumUnitSelf != null) then
                    loop
                        set enumUnit = GetUnit(enumUnitSelf)
                        call GroupRemoveUnit( Arrow_ENUM_GROUP, enumUnitSelf )
                        if ( Arrow_ExplosionConditions( enumUnit ) ) then
                            call Explosion_Explosion_Start(d)
                            call UnitDamageUnitEx( caster, enumUnit, damageAmount, null )
                            call Explosion_Explosion_Ending()
                        endif
                        set enumUnitSelf = FirstOfGroup( Arrow_ENUM_GROUP )
                        exitwhen ( enumUnitSelf == null )
                    endloop
                endif
                set enumUnitSelf = null
                if ( remainingArrowsAmount == 0 ) then
                    call Ending( caster, d, d.intervalTimer )
                else
                    set d.remainingArrowsAmount = remainingArrowsAmount
                endif
            endif
        endfunction

        public function Arrow_Start takes integer abilityLevel, Unit caster, Data d, real targetX, real targetY returns nothing
            local real angle = GetRandomReal( 0, 2 * PI )
            local unit casterSelf = caster.self
            local real casterX = GetUnitX( casterSelf )
            local real casterY = GetUnitY( casterSelf )
            local unit dummyUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, Arrow_DUMMY_UNIT_ID, casterX, casterY, angle )
            local Arrow_Data e = Arrow_Data.create()
            local real length = GetRandomReal(0, Arrow_AREA_RANGE[abilityLevel])
            set targetX = targetX + length * Cos( angle )
            set targetY = targetY + length * Sin( angle )
            if ( ( casterX != targetX ) or ( casterY != targetY ) ) then
                set angle = Atan2( targetY - casterY, targetX - casterX )
            else
                set angle = GetUnitFacingWJ( casterSelf )
            endif
            set e.d = d
            set e.targetX = targetX
            set e.targetY = targetY
            call AttachInteger(dummyUnit, Arrow_SCOPE_ID, e)
            call SetUnitZ( dummyUnit, casterX, casterY, GetUnitZ( casterSelf, casterX, casterY ) + GetUnitOutpactZ(caster) )
            call IssuePointOrderById( dummyUnit, ATTACK_GROUND_ORDER_ID, targetX, targetY )
            set dummyUnit = null
            call SetUnitFacingWJ( casterSelf, angle )
            call SetUnitAnimationByIndex( casterSelf, 5 )
            set casterSelf = null
        endfunction

        public function Arrow_Init takes nothing returns nothing
            local trigger damageTrigger = CreateTriggerWJ()
            set Arrow_AREA_RANGE[1] = 175
            set Arrow_AREA_RANGE[2] = 250
            set Arrow_AREA_RANGE[3] = 250
            set Arrow_AREA_RANGE[4] = 250
            set Arrow_AREA_RANGE[5] = 250
            set Arrow_ENUM_GROUP = CreateGroupWJ()
            set Arrow_TARGET_CONDITIONS = ConditionWJ( function Arrow_TargetConditions )
            call AddTriggerCode( damageTrigger, function Arrow_ImpactTrig )
            call TriggerRegisterUnitEvent( damageTrigger, WORLD_CASTER, EVENT_UNIT_DAMAGED )
            set damageTrigger = null
            call InitUnitType( Arrow_DUMMY_UNIT_ID )
            call InitEffectType( Arrow_TARGET_EFFECT_PATH )
            call InitEffectType( Arrow_TARGET_EFFECT2_PATH )
        endfunction
    //! runtextmacro Endscope()

    private function NewTargetByTimer takes nothing returns nothing
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, Barrage_SCOPE_ID)
        set intervalTimer = null
        call Arrow_Arrow_Start( d.abilityLevel, d.caster, d, d.targetX, d.targetY )
    endfunction

    public function SpellEffect takes Unit caster, real targetX, real targetY returns nothing
        local integer abilityLevel = GetUnitAbilityLevel( caster.self, SPELL_ID )
        local Data d = Data.create()
        local timer durationTimer = CreateTimerWJ()
        local timer intervalTimer = CreateTimerWJ()
        set d.abilityLevel = abilityLevel
        set d.caster = caster
        set d.damageAmount = DAMAGE[abilityLevel] + GetHeroStrengthTotal( caster ) * DAMAGE_PER_STRENGTH_POINT[abilityLevel]
        set d.durationTimer = durationTimer
        set d.explosionDamageAmount = EXPLOSION_DAMAGE[abilityLevel]
        set d.intervalTimer = intervalTimer
        set d.remainingArrowsAmount = WAVES_AMOUNT[abilityLevel]
        set d.targetX = targetX
        set d.targetY = targetY
        call AttachIntegerById( caster.id, Barrage_SCOPE_ID, d )
        call AttachInteger( durationTimer, Barrage_SCOPE_ID, d )
        call AttachInteger( intervalTimer, Barrage_SCOPE_ID, d )
        call TimerStart( intervalTimer, INTERVAL[abilityLevel], true, function NewTargetByTimer )
        set intervalTimer = null
        call TimerStart( durationTimer, DURATION[abilityLevel], false, function EndingByTimer )
        set durationTimer = null
        call Arrow_Arrow_Start( abilityLevel, caster, d, targetX, targetY )
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_X, TARGET_Y )
    endfunction

    private function Order_CancelConditions takes Unit caster, real targetX, real targetY returns boolean
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        set casterSelf = null
        if ( DistanceByCoordinates( casterX, casterY, targetX, targetY ) > MINIMUM_RANGE ) then
            return false
        endif
        return true
    endfunction

    public function Order takes Unit caster, real targetX, real targetY returns string
        if ( Order_CancelConditions( caster, targetX, targetY ) ) then
            return ErrorStrings_TARGET_TOO_CLOSE
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( ORDERED_UNIT, TARGET_X, TARGET_Y )
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = LEVELS_AMOUNT
        set DAMAGE[1] = 10
        set DAMAGE[2] = 14
        set DAMAGE[3] = 18
        set DAMAGE[4] = 22
        set DAMAGE[5] = 25
        set DAMAGE_PER_STRENGTH_POINT[1] = 0.125
        set DAMAGE_PER_STRENGTH_POINT[2] = 0.125
        set DAMAGE_PER_STRENGTH_POINT[3] = 0.125
        set DAMAGE_PER_STRENGTH_POINT[4] = 0.125
        set DAMAGE_PER_STRENGTH_POINT[5] = 0.125
        set EXPLOSION_DAMAGE[1] = 40
        set EXPLOSION_DAMAGE[2] = 40
        set EXPLOSION_DAMAGE[3] = 40
        set EXPLOSION_DAMAGE[4] = 40
        set EXPLOSION_DAMAGE[5] = 40
        set INTERVAL[1] = 0.1
        set INTERVAL[2] = 0.1
        set INTERVAL[3] = 0.1
        set INTERVAL[4] = 0.1
        set INTERVAL[5] = 0.1
        set WAVES_AMOUNT[1] = 28
        set WAVES_AMOUNT[2] = 32
        set WAVES_AMOUNT[3] = 35
        set WAVES_AMOUNT[4] = 38
        set WAVES_AMOUNT[5] = 40
        loop
            set DURATION[iteration] = (WAVES_AMOUNT[iteration] - 1) * INTERVAL[iteration]
            set iteration = iteration - 1
            exitwhen (iteration < 1)
        endloop
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ENDCAST", "SPELL_ID", "UnitFinishesCasting_EVENT_KEY", "0", "function EndCast_Event" )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call Arrow_Arrow_Init()
        call Explosion_Explosion_Init()
    endfunction
//! runtextmacro Endscope()