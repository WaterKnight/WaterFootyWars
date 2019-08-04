//TESH.scrollpos=76
//TESH.alwaysfold=0
//! runtextmacro Scope("Net")
    globals
        private constant integer ORDER_ID = 852106//OrderId( "ensnare" )
        public constant integer SPELL_ID = 'A03H'

        private constant integer DUMMY_UNIT_ID = 'n01M'
        private constant real MAX_DURATION = 1.
        private constant real SPEED = 600.
        private constant real STUN_DURATION = 10.
        private constant real STUN_HERO_DURATION = 3.
        private constant real UPDATE_TIME = 0.035
        private constant real LENGTH = SPEED * UPDATE_TIME
    endglobals

    private struct Data
        real angle
        Unit caster
        unit dummyUnit
        timer durationTimer
        timer moveTimer
        Unit target
        real targetX
        real targetY
        real targetZ
        real x
        real y
        real z
    endstruct

    private function Ending takes Data d, unit dummyUnit, timer durationTimer, boolean isTargetNotNull, timer moveTimer, Unit target returns nothing
        local integer targetId = target.id
        call d.destroy()
        call SetUnitAnimationByIndex( dummyUnit, 2 )
        call RemoveUnitTimed( dummyUnit, 2 )
        call FlushAttachedInteger( durationTimer, Net_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        call FlushAttachedInteger( moveTimer, Net_SCOPE_ID )
        call DestroyTimerWJ( moveTimer )
        if ( isTargetNotNull ) then
            set targetId = target.id
            call RemoveIntegerFromTableById( targetId, Net_SCOPE_ID, d )
            if ( CountIntegersInTableById( targetId, Net_SCOPE_ID ) == TABLE_EMPTY ) then
                //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
            endif
        endif
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, Net_SCOPE_ID)
        local Unit target = d.target
        call Ending( d, d.dummyUnit, durationTimer, (target != NULL), d.moveTimer, target )
        set durationTimer = null
    endfunction

    private function Death_ResetTarget takes Data d, Unit target, real targetX, real targetY, real targetZ returns nothing
        local integer targetId = target.id
        set d.target = NULL
        call RemoveIntegerFromTableById( targetId, Net_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, Net_SCOPE_ID ) == TABLE_EMPTY ) then
            //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        endif
        set d.targetX = targetX
        set d.targetY = targetY
        set d.targetZ = targetZ
    endfunction

    public function Death takes Unit target, real targetX, real targetY, real targetZ returns nothing
        local Data d
        local integer targetId = target.id
        local integer iteration = CountIntegersInTableById( targetId, Net_SCOPE_ID )
        if (iteration > TABLE_EMPTY) then
            loop
                set d = GetIntegerFromTableById( targetId, Net_SCOPE_ID, iteration )
                call Death_ResetTarget( d, target, targetX, targetY, targetZ )
                set iteration = iteration - 1
                exitwhen ( iteration < TABLE_STARTED )
            endloop
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        local unit dyingUnitSelf = DYING_UNIT.self
        local real dyingUnitX = GetUnitX(dyingUnitSelf)
        local real dyingUnitY = GetUnitY(dyingUnitSelf)
        call Death( DYING_UNIT, dyingUnitX, dyingUnitY, GetUnitZ(dyingUnitSelf, dyingUnitX, dyingUnitY) )
        set dyingUnitSelf = null
    endfunction

    private function Impact takes Unit target returns nothing
        local real stunTime
        if ( IsUnitType( target.self, UNIT_TYPE_HERO ) ) then
            set stunTime = STUN_HERO_DURATION
        else
            set stunTime = STUN_DURATION
        endif
        call SetUnitStunTimed( target, 3, stunTime )
    endfunction

    private function TargetConditions takes player casterOwner, Unit target returns string
        set TEMP_UNIT_SELF = target.self
        if ( IsUnitAlly( TEMP_UNIT_SELF, casterOwner ) ) then
            return ErrorStrings_NOT_ALLY
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return ErrorStrings_NOT_STRUCTURE
        endif
        if ( GetUnitInvulnerability( target ) > 0 ) then
            return ErrorStrings_TARGET_IS_INVULNERABLE
        endif
        return null
    endfunction

    private function Move takes nothing returns nothing
        local real angleLengthXYZ
        local real angleXY
        local Unit caster
        local real distanceX
        local real distanceY
        local real distanceZ
        local boolean isTargetNotNull
        local real lengthXY
        local timer moveTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(moveTimer, Net_SCOPE_ID)
        local unit dummyUnit = d.dummyUnit
        local boolean reachesTarget
        local Unit target = d.target
        local unit targetSelf = target.self
        local boolean isTargetNull = ( target == NULL )
        local real targetX
        local real targetY
        local real targetZ
        local real x = d.x
        local real y = d.y
        local real z = d.z
        if ( isTargetNull ) then
            set targetX = d.targetX
            set targetY = d.targetY
            set targetZ = d.targetZ
        else
            set targetSelf = target.self
            set targetX = GetUnitX( targetSelf )
            set targetY = GetUnitY( targetSelf )
            set targetZ = GetUnitZ( targetSelf, targetX, targetY ) + GetUnitImpactZ(target)
            set targetSelf = null
        endif
        set reachesTarget = ( DistanceByCoordinatesWithZ( x, y, z, targetX, targetY, targetZ ) <= LENGTH )
        if ( reachesTarget ) then
            set x = targetX
            set y = targetY
            set z = targetZ
        else
            set distanceZ = targetZ - z
            set angleLengthXYZ = Atan2( distanceZ, DistanceByCoordinates( x, y, targetX, targetY ) )
            set distanceX = targetX - x
            set distanceY = targetY - y
            set angleXY = Atan2( distanceY, distanceX )
            set lengthXY = LENGTH * Cos( angleLengthXYZ )
            set x = x + lengthXY * Cos( angleXY )
            set y = y + lengthXY * Sin( angleXY )
            set z = z + LENGTH * Sin( angleLengthXYZ )
            call SetUnitFacingWJ( dummyUnit, angleXY )
        endif
        call SetUnitX( dummyUnit, x )
        call SetUnitY( dummyUnit, y )
        call SetUnitZ( dummyUnit, x, y, z )
        if ( reachesTarget ) then
            set caster = d.caster
            set isTargetNotNull = (isTargetNull == false)
            call Ending( d, dummyUnit, d.durationTimer, isTargetNotNull, moveTimer, target )
            if ( isTargetNotNull ) then
                if ( TargetConditions( caster.owner, target ) == null ) then
                    call Impact( target )
                endif
            endif
        else
            set d.x = x
            set d.y = y
            set d.z = z
        endif
        set dummyUnit = null
        set moveTimer = null
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local real angle
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local real casterZ = GetUnitZ(casterSelf, casterX, casterY)
        local Data d
        local unit dummyUnit
        local timer durationTimer
        local timer moveTimer
        local integer targetId
        local unit targetSelf = target.self
        local real targetX = GetUnitX( targetSelf )
        local real targetY = GetUnitY( targetSelf )
        local real targetZ = GetUnitZ(targetSelf, targetX, targetY)
        set casterSelf = null
        set targetSelf = null
        if ( ( casterX != targetX ) or ( casterY != targetY ) or (casterZ != targetZ) ) then
            set angle = Atan2( targetY - casterY, targetX - casterX )
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set moveTimer = CreateTimerWJ()
            set dummyUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, DUMMY_UNIT_ID, casterX, casterY, angle )
            set targetId = target.id
            set d.angle = angle
            set d.caster = caster
            set d.dummyUnit = dummyUnit
            set d.durationTimer = durationTimer
            set d.moveTimer = moveTimer
            set d.target = target
            set d.x = casterX
            set d.y = casterY
            set d.z = casterZ
            call AttachInteger( durationTimer, Net_SCOPE_ID, d )
            call AttachInteger( moveTimer, Net_SCOPE_ID, d )
            call AddIntegerToTableById( targetId, Net_SCOPE_ID, d )
            if ( CountIntegersInTableById( targetId, Net_SCOPE_ID ) == TABLE_STARTED ) then
                //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
            endif
            call SetUnitAnimationByIndex( dummyUnit, 0 )
            call SetUnitZ(dummyUnit, casterX, casterY, casterZ)
            set dummyUnit = null
            call TimerStart( moveTimer, UPDATE_TIME, true, function Move )
            set moveTimer = null
            call TimerStart( durationTimer, MAX_DURATION, false, function EndingByTimer )
            set durationTimer = null
        else
            call Impact( target )
        endif
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    public function Order takes player casterOwner, Unit target returns string
        return TargetConditions( casterOwner, target )
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( ORDERED_UNIT.owner, TARGET_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        call InitUnitType( DUMMY_UNIT_ID )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()