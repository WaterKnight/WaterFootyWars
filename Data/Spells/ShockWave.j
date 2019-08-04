//TESH.scrollpos=123
//TESH.alwaysfold=0
//! runtextmacro Scope("ShockWave")
    globals
        private constant integer ORDER_ID = 852125//OrderId( "shockwave" )
        public constant integer SPELL_ID = 'A077'

        private constant real AREA_RANGE = 150
        private constant real DAMAGE = 140
        private constant integer DUMMY_UNIT_ID = 'n02P'
        private group ENUM_GROUP
        private constant real MAX_LENGTH = 700
        private constant real SPEED = 1000
        private constant real DURATION = MAX_LENGTH / SPEED
        private constant real UPDATE_TIME = 0.035
        private constant real LENGTH = SPEED * UPDATE_TIME
        private boolexpr TARGET_CONDITIONS
    endglobals

    private struct Data
        Unit caster
        unit dummyUnit
        timer durationTimer
        real lengthX
        real lengthY
        timer intervalTimer
        group targetGroup
    endstruct

    private function Ending takes Data d, unit dummyUnit, timer durationTimer, timer intervalTimer, group targetGroup returns nothing
        call d.destroy()
        call SetUnitAnimationByIndex( dummyUnit, 2 )
        call RemoveUnitTimed( dummyUnit, 0.5 )
        call FlushAttachedInteger( durationTimer, ShockWave_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        call FlushAttachedInteger( intervalTimer, ShockWave_SCOPE_ID )
        call DestroyTimerWJ( intervalTimer )
        call DestroyGroupWJ( targetGroup )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, ShockWave_SCOPE_ID)
        call Ending( d, d.dummyUnit, durationTimer, d.intervalTimer, d.targetGroup )
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
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_FLYING ) ) then
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

    private function Move takes nothing returns nothing
        local unit enumUnit
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, ShockWave_SCOPE_ID)
        local Unit caster = d.caster
        local unit dummyUnit = d.dummyUnit
        local real newX = GetUnitX( dummyUnit ) + d.lengthX
        local real newY = GetUnitY( dummyUnit ) + d.lengthY
        local boolean isEnding = IsTerrainPathable( newX, newY, PATHING_TYPE_WALKABILITY )
        local group targetGroup = d.targetGroup
        if ( isEnding == false ) then
            call SetUnitXWJ( dummyUnit, newX )
            call SetUnitYWJ( dummyUnit, newY )
        endif
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, newX, newY, AREA_RANGE, TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit != null ) then
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                if ( IsUnitInGroup( enumUnit, targetGroup ) == false ) then
                    call GroupAddUnit( targetGroup, enumUnit )
                    call UnitDamageUnitBySpell( caster, GetUnit(enumUnit), DAMAGE )
                endif
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
        if ( isEnding ) then
            call Ending( d, dummyUnit, d.durationTimer, intervalTimer, targetGroup )
        endif
        set dummyUnit = null
        set intervalTimer = null
        set targetGroup = null
    endfunction

    public function SpellEffect takes Unit caster, real targetX, real targetY returns nothing
        local real angle
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local Data d = Data.create()
        local unit dummyUnit
        local timer durationTimer = CreateTimerWJ()
        local timer intervalTimer = CreateTimerWJ()
        if ( ( casterX != targetX ) or ( casterY != targetY ) ) then
            set angle = Atan2( targetY - casterY, targetX - casterX )
        else
            set angle = GetUnitFacingWJ( casterSelf )
        endif
        set casterSelf = null
        set d.caster = caster
        set d.dummyUnit = CreateUnitWJ( caster.owner, DUMMY_UNIT_ID, casterX, casterY, angle )
        set d.durationTimer = durationTimer
        set d.intervalTimer = intervalTimer
        set d.lengthX = LENGTH * Cos(angle)
        set d.lengthY = LENGTH * Sin(angle)
        set d.targetGroup = CreateGroupWJ()
        call AttachInteger( durationTimer, ShockWave_SCOPE_ID, d )
        call AttachInteger( intervalTimer, ShockWave_SCOPE_ID, d )
        call TimerStart( intervalTimer, UPDATE_TIME, true, function Move )
        set intervalTimer = null
        call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_X, TARGET_Y )
    endfunction

    public function Init takes nothing returns nothing
        set ENUM_GROUP = CreateGroupWJ()
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitUnitType( DUMMY_UNIT_ID )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()