//TESH.scrollpos=238
//TESH.alwaysfold=0
//! runtextmacro Scope("LittleThunderstorm")
    globals
        private constant integer ORDER_ID = 852587//OrderId( "forkedlightning" )
        public constant integer SPELL_ID = 'A00N'

        private constant string AREA_EFFECT_PATH = "Abilities\\Spells\\Other\\Monsoon\\MonsoonRain.mdl"
        private real array AREA_RANGE
        private real array DAMAGE_PER_INTERVAL
        private real array DAMAGE_PER_INTERVAL_PER_STRENGTH_POINT
        private real array DURATION
        private constant real INTERVAL = 1.25
        private constant integer LEVELS_AMOUNT = 5
        private integer array WAVES_AMOUNT
    endglobals

    private struct Data
        integer abilityLevel
        effect areaEffect
        Unit caster
        real damagePerIntervalAmount
        timer durationTimer
        timer intervalTimer
        real targetX
        real targetY
    endstruct

    private function Ending takes Unit caster, Data d returns nothing
        local effect areaEffect = d.areaEffect
        local timer durationTimer = d.durationTimer
        local timer intervalTimer = d.intervalTimer
        call d.destroy()
        call DestroyEffectWJ( areaEffect )
        set areaEffect = null
        call FlushAttachedIntegerById( caster.id, LittleThunderstorm_SCOPE_ID )
        call FlushAttachedInteger( durationTimer, LittleThunderstorm_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call FlushAttachedInteger( intervalTimer, LittleThunderstorm_SCOPE_ID )
        call DestroyTimerWJ( intervalTimer )
        set intervalTimer = null
    endfunction

    public function EndCast takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, LittleThunderstorm_SCOPE_ID)
        if ( d != NULL ) then
            call Ending( caster, d )
        endif
    endfunction

    private function EndCast_Event takes nothing returns nothing
        call EndCast( CASTER )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, LittleThunderstorm_SCOPE_ID)
        set durationTimer = null
        call IssueImmediateOrderById( d.caster.self, STOP_ORDER_ID )
    endfunction

    //! runtextmacro Scope("Lightning")
        globals
            private real array Lightning_AREA_RANGE
            private integer array Lightning_DEBRIS_AMOUNT
            private constant real Lightning_DELAY = 0.5
            private group Lightning_ENUM_GROUP
            private constant string Lightning_SPECIAL_EFFECT_PATH = "MonsoonBoltTarget.mdl"
            private real array Lightning_STUN_DURATION
            private real array Lightning_STUN_HERO_DURATION
            private boolexpr Lightning_TARGET_CONDITIONS
        endglobals

        private struct Lightning_Data
            integer abilityLevel
            Unit caster
            real damageAmount
            real targetX
            real targetY
        endstruct

        private function Lightning_TargetConditions takes nothing returns boolean
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
            set FILTER_UNIT = GetUnit(FILTER_UNIT_SELF)
            if ( GetUnitInvulnerability( FILTER_UNIT ) > 0 ) then
                return false
            endif
            if ( GetUnitMagicImmunity( FILTER_UNIT ) > 0 ) then
                return false
            endif
            return true
        endfunction

        private function Lightning_Ending takes nothing returns nothing
            local timer delayTimer = GetExpiredTimer()
            local Lightning_Data d = GetAttachedInteger(delayTimer, Lightning_SCOPE_ID)
            local integer abilityLevel = d.abilityLevel
            local Unit caster = d.caster
            local real damageAmount = d.damageAmount
            local Unit enumUnit
            local unit enumUnitSelf
            local real stunTime
            local real targetX = d.targetX
            local real targetY = d.targetY
            call FlushAttachedInteger( delayTimer, Lightning_SCOPE_ID )
            call DestroyTimerWJ( delayTimer )
            set delayTimer = null
            set TEMP_PLAYER = caster.owner
            call GroupEnumUnitsInRangeWithCollision( Lightning_ENUM_GROUP, targetX, targetY, Lightning_AREA_RANGE[abilityLevel], Lightning_TARGET_CONDITIONS )
            set enumUnitSelf = FirstOfGroup( Lightning_ENUM_GROUP )
            if (enumUnitSelf != null) then
                loop
                    set enumUnit = GetUnit(enumUnitSelf)
                    call GroupRemoveUnit( Lightning_ENUM_GROUP, enumUnitSelf )
                    if ( IsUnitType( enumUnitSelf, UNIT_TYPE_STRUCTURE ) == false ) then
                        if ( IsUnitType( enumUnitSelf, UNIT_TYPE_HERO ) ) then
                            set stunTime = Lightning_STUN_HERO_DURATION[abilityLevel]
                        else
                            set stunTime = Lightning_STUN_DURATION[abilityLevel]
                        endif
                        call SetUnitStunTimed( enumUnit, 1, stunTime )
                    endif
                    call UnitDamageUnitBySpell( caster, enumUnit, damageAmount )
                    set enumUnitSelf = FirstOfGroup( Lightning_ENUM_GROUP )
                    exitwhen ( enumUnitSelf == null )
                endloop
            endif
        endfunction

        public function Lightning_Start takes integer abilityLevel, Unit caster, real damageAmount, real targetX, real targetY returns nothing
            local real angle = GetRandomReal(0, 2 * PI)
            local real areaRange = AREA_RANGE[abilityLevel] - 50
            local Lightning_Data d = Lightning_Data.create()
            local integer debrisAmount = Lightning_DEBRIS_AMOUNT[abilityLevel]
            local real angleAdd = 2 * PI / debrisAmount
            local timer delayTimer = CreateTimerWJ()
            local integer iteration = debrisAmount
            local real length
            set d.abilityLevel = abilityLevel
            set d.caster = caster
            set d.damageAmount = damageAmount
            set d.targetX = targetX
            set d.targetY = targetY
            call AttachInteger( delayTimer, Lightning_SCOPE_ID, d )
            loop
                set length = GetRandomReal( 20, areaRange - 50 )
                call DestroyEffectWJ( AddSpecialEffectWJ( Lightning_SPECIAL_EFFECT_PATH, targetX + length * Cos( angle ), targetY + length * Sin( angle ) ) )
                set iteration = iteration - 1
                exitwhen ( iteration < 1 )
                set angle = angle + angleAdd
            endloop
            call TimerStart( delayTimer, Lightning_DELAY, false, function Lightning_Ending )
            set delayTimer = null
        endfunction

        public function Lightning_Init takes nothing returns nothing
            set Lightning_AREA_RANGE[1] = 200
            set Lightning_AREA_RANGE[2] = 250
            set Lightning_AREA_RANGE[3] = 275
            set Lightning_AREA_RANGE[4] = 290
            set Lightning_AREA_RANGE[5] = 310
            set Lightning_DEBRIS_AMOUNT[1] = 4
            set Lightning_DEBRIS_AMOUNT[2] = 4
            set Lightning_DEBRIS_AMOUNT[3] = 5
            set Lightning_DEBRIS_AMOUNT[4] = 5
            set Lightning_DEBRIS_AMOUNT[5] = 5
            set Lightning_ENUM_GROUP = CreateGroupWJ()
            set Lightning_STUN_DURATION[1] = 0.3
            set Lightning_STUN_DURATION[2] = 0.35
            set Lightning_STUN_DURATION[3] = 0.4
            set Lightning_STUN_DURATION[4] = 0.45
            set Lightning_STUN_DURATION[5] = 0.5
            set Lightning_STUN_HERO_DURATION[1] = 0.2
            set Lightning_STUN_HERO_DURATION[2] = 0.2
            set Lightning_STUN_HERO_DURATION[3] = 0.3
            set Lightning_STUN_HERO_DURATION[4] = 0.3
            set Lightning_STUN_HERO_DURATION[5] = 0.3
            set Lightning_TARGET_CONDITIONS = ConditionWJ( function Lightning_TargetConditions )
            call InitEffectType( Lightning_SPECIAL_EFFECT_PATH )
        endfunction
    //! runtextmacro Endscope()

    private function Interval takes nothing returns nothing
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, LittleThunderstorm_SCOPE_ID)
        set intervalTimer = null
        call Lightning_Lightning_Start( d.abilityLevel, d.caster, d.damagePerIntervalAmount, d.targetX, d.targetY )
    endfunction

    public function SpellEffect takes Unit caster, real targetX, real targetY returns nothing
        local integer abilityLevel = GetUnitAbilityLevel( caster.self, SPELL_ID )
        local Data d = Data.create()
        local real damagePerIntervalAmount = DAMAGE_PER_INTERVAL[abilityLevel] + GetHeroStrength(caster) * DAMAGE_PER_INTERVAL_PER_STRENGTH_POINT[abilityLevel]
        local timer durationTimer = CreateTimerWJ()
        local timer intervalTimer = CreateTimerWJ()
        set d.abilityLevel = abilityLevel
        set d.areaEffect = AddSpecialEffectWJ( AREA_EFFECT_PATH, targetX, targetY )
        set d.caster = caster
        set d.damagePerIntervalAmount = damagePerIntervalAmount
        set d.durationTimer = durationTimer
        set d.intervalTimer = intervalTimer
        set d.targetX = targetX
        set d.targetY = targetY
        call AttachIntegerById( caster.id, LittleThunderstorm_SCOPE_ID, d )
        call AttachInteger( intervalTimer, LittleThunderstorm_SCOPE_ID, d )
        call AttachInteger( durationTimer, LittleThunderstorm_SCOPE_ID, d )
        call TimerStart( intervalTimer, INTERVAL, true, function Interval )
        set intervalTimer = null
        call TimerStart( durationTimer, DURATION[abilityLevel], false, function EndingByTimer )
        set durationTimer = null
        call Lightning_Lightning_Start( abilityLevel, caster, damagePerIntervalAmount, targetX, targetY )
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_X, TARGET_Y )
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = LEVELS_AMOUNT
        set AREA_RANGE[1] = 200
        set AREA_RANGE[2] = 250
        set AREA_RANGE[3] = 275
        set AREA_RANGE[4] = 290
        set AREA_RANGE[5] = 310
        set DAMAGE_PER_INTERVAL[1] = 21
        set DAMAGE_PER_INTERVAL[2] = 23
        set DAMAGE_PER_INTERVAL[3] = 25
        set DAMAGE_PER_INTERVAL[4] = 27
        set DAMAGE_PER_INTERVAL[5] = 28
        set DAMAGE_PER_INTERVAL_PER_STRENGTH_POINT[1] = 0.375
        set DAMAGE_PER_INTERVAL_PER_STRENGTH_POINT[2] = 0.375
        set DAMAGE_PER_INTERVAL_PER_STRENGTH_POINT[3] = 0.375
        set DAMAGE_PER_INTERVAL_PER_STRENGTH_POINT[4] = 0.375
        set DAMAGE_PER_INTERVAL_PER_STRENGTH_POINT[5] = 0.375
        set WAVES_AMOUNT[1] = 4
        set WAVES_AMOUNT[2] = 5
        set WAVES_AMOUNT[3] = 6
        set WAVES_AMOUNT[4] = 7
        set WAVES_AMOUNT[5] = 8
        loop
            set DURATION[iteration] = WAVES_AMOUNT[iteration] * INTERVAL + 0.5
            set iteration = iteration - 1
            exitwhen (iteration < 1)
        endloop
        call InitEffectType( AREA_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ENDCAST", "SPELL_ID", "UnitFinishesCasting_EVENT_KEY", "0", "function EndCast_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call Lightning_Lightning_Init()
    endfunction
//! runtextmacro Endscope()