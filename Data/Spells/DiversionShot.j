//TESH.scrollpos=134
//TESH.alwaysfold=0
//! runtextmacro Scope("DiversionShot")
    globals
        public constant integer SPELL_ID = 'A043'

        private constant real AREA_RANGE = 260.
        private constant string AREA_EFFECT_PATH = "Abilities\\Spells\\Other\\Volcano\\VolcanoDeath.mdl"
        private group ENUM_GROUP
        private constant real INTERVAL = 0.035
        private constant real DURATION = 0.5
        private constant real DAMAGE = 100. / DURATION * INTERVAL
        private constant real SPEED = 550.
        private constant real LENGTH = SPEED * INTERVAL
        private boolexpr TARGET_CONDITIONS
    endglobals

    private struct Data
        Unit caster
        timer durationTimer
        timer intervalTimer
        real targetX
        real targetY
    endstruct

    public function DecayEnd takes Unit caster returns nothing
        local integer casterId = caster.id
        if (GetAttachedBooleanById( casterId, DiversionShot_SCOPE_ID )) then
            call FlushAttachedBooleanById( casterId, DiversionShot_SCOPE_ID )
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DAMAGE" )
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DECAY_END" )
        endif
    endfunction

    private function DecayEnd_Event takes nothing returns nothing
        call DecayEnd( TRIGGER_UNIT )
    endfunction

    private function Ending takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, DiversionShot_SCOPE_ID)
        local Unit caster = d.caster
        local timer intervalTimer = d.intervalTimer
        call d.destroy()
        call RemoveUnitRemainingReference( caster )
        call FlushAttachedInteger( durationTimer, DiversionShot_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call FlushAttachedInteger( intervalTimer, DiversionShot_SCOPE_ID )
        call DestroyTimerWJ( intervalTimer )
        set intervalTimer = null
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
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        if ( GetUnitInvulnerability( GetUnit(FILTER_UNIT_SELF) ) > 0 ) then
            return false
        endif
        return true
    endfunction

    private function Interval takes nothing returns nothing
        local Unit enumUnit
        local unit enumUnitSelf
        local real enumUnitX
        local real enumUnitY
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, DiversionShot_SCOPE_ID)
        local Unit caster = d.caster
        local real targetEnumUnitAngle
        local real targetX = d.targetX
        local real targetY = d.targetY
        set intervalTimer = null
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, targetX, targetY, AREA_RANGE, TARGET_CONDITIONS )
        set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
        if ( enumUnitSelf != null ) then
            loop
                set enumUnitX = GetUnitX( enumUnitSelf )
                set enumUnitY = GetUnitY( enumUnitSelf )
                call GroupRemoveUnit( ENUM_GROUP, enumUnitSelf )
                if ( ( enumUnitX != targetX ) or ( enumUnitY != targetY ) ) then
                    set targetEnumUnitAngle = Atan2( enumUnitY - targetY, enumUnitX - targetX )
                else
                    set targetEnumUnitAngle = GetUnitFacingWJ( enumUnitSelf ) + PI
                endif
                call SetUnitXYIfNotBlocked( enumUnitSelf, enumUnitX, enumUnitY, enumUnitX + LENGTH * Cos( targetEnumUnitAngle ), enumUnitY + LENGTH * Sin( targetEnumUnitAngle ) )
                call UnitDamageUnitEx( caster, enumUnit, ( 1 - DistanceByCoordinates( enumUnitX, enumUnitY, targetX, targetY ) / AREA_RANGE ) * DAMAGE, null )
                set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnitSelf == null )
            endloop
        endif
    endfunction

    public function Damage takes Unit caster, real targetX, real targetY returns nothing
        local Data d
        local timer durationTimer
        local timer intervalTimer
        if ( GetAttachedBooleanById( caster.id, DiversionShot_SCOPE_ID ) ) then
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set intervalTimer = CreateTimerWJ()
            set d.caster = caster
            set d.durationTimer = durationTimer
            set d.intervalTimer = intervalTimer
            set d.targetX = targetX
            set d.targetY = targetY
            call AttachInteger( durationTimer, DiversionShot_SCOPE_ID, d )
            call AttachInteger( intervalTimer, DiversionShot_SCOPE_ID, d )
            call AddUnitRemainingReference(caster)
            call DestroyEffectTimed( AddSpecialEffectWJ( AREA_EFFECT_PATH, targetX, targetY ), DURATION )
            call TimerStart( intervalTimer, INTERVAL, true, function Interval )
            set intervalTimer = null
            call TimerStart( durationTimer, DURATION, false, function Ending )
            set durationTimer = null
        endif
    endfunction

    private function Damage_Event takes nothing returns nothing
        call Damage( DAMAGE_SOURCE, TARGET_X, TARGET_Y )
    endfunction

    public function Learn takes Unit caster returns nothing
        local integer casterId = caster.id
        call AttachBooleanById( casterId, DiversionShot_SCOPE_ID, true )
        //! runtextmacro AddEventById( "casterId", "EVENT_DAMAGE" )
        //! runtextmacro AddEventById( "casterId", "EVENT_DECAY_END" )
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY", "0", "function Damage_Event" )
        //! runtextmacro CreateEvent( "EVENT_DECAY_END", "UnitFinishesDecaying_End_End_EVENT_KEY", "0", "function DecayEnd_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( AREA_EFFECT_PATH )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
    endfunction
//! runtextmacro Endscope()