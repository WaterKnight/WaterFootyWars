//TESH.scrollpos=186
//TESH.alwaysfold=0
//! runtextmacro Scope("FrostBolt")
    globals
        private constant integer ORDER_ID = 852600//OrderId("channel")
        public constant integer SPELL_ID = 'A07K'

        private constant real DAMAGE = 250.
        private constant integer DUMMY_UNIT_ID = 'h00X'
        private constant real DURATION = 5.
        private constant real HERO_DAMAGE = 75.
        private constant real HERO_DURATION = 2.
        private constant real UPDATE_TIME = 0.035
        private constant real LENGTH = 600 * UPDATE_TIME
    endglobals

    private struct Data
        Unit caster
        unit dummyUnit
        timer moveTimer
        Unit target
        real targetX
        real targetY
        real targetZ
        real x
        real y
        real z
    endstruct

    private function Ending takes Data d, unit dummyUnit, boolean isTargetNotNull, timer moveTimer, Unit target returns nothing
        local integer targetId = target.id
        call d.destroy()
        call SetUnitAnimationByIndex( dummyUnit, 2 )
        call RemoveUnitTimed( dummyUnit, 2 )
        call FlushAttachedInteger( moveTimer, FrostBolt_SCOPE_ID )
        call DestroyTimerWJ( moveTimer )
        if ( isTargetNotNull ) then
            call RemoveIntegerFromTableById( targetId, FrostBolt_SCOPE_ID, d )
            if ( CountIntegersInTableById( targetId, FrostBolt_SCOPE_ID ) == TABLE_EMPTY ) then
                //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
            endif
        endif
    endfunction

    private function Death_ResetTarget takes Data d, Unit target, real targetX, real targetY, real targetZ returns nothing
        local integer targetId = target.id
        set d.target = NULL
        call RemoveIntegerFromTableById( targetId, FrostBolt_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, FrostBolt_SCOPE_ID ) == TABLE_EMPTY ) then
            //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        endif
        set d.targetX = targetX
        set d.targetY = targetY
        set d.targetZ = targetZ
    endfunction

    public function Death takes Unit target, real targetX, real targetY, real targetZ returns nothing
        local Data d
        local integer targetId = target.id
        local integer iteration = CountIntegersInTableById( targetId, FrostBolt_SCOPE_ID )
        if ( iteration > TABLE_EMPTY ) then
            loop
                set d = GetIntegerFromTableById( targetId, FrostBolt_SCOPE_ID, iteration )
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

    private function TargetConditions takes player casterOwner, Unit target returns string
        set TEMP_UNIT_SELF = target.self
        if ( IsUnitAlly( TEMP_UNIT_SELF, casterOwner ) ) then
            return ErrorStrings_NOT_ALLY
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return ErrorStrings_ONLY_ORGANIC
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return ErrorStrings_NOT_STRUCTURE
        endif
        if ( GetUnitInvulnerability( target ) > 0 ) then
            return ErrorStrings_TARGET_IS_INVULNERABLE
        endif
        if ( GetUnitMagicImmunity( target ) > 0 ) then
            return ErrorStrings_TARGET_IS_MAGIC_IMMUNE
        endif
        return null
    endfunction

    private function Move takes nothing returns nothing
        local real angleLengthXYZ
        local real angleXY
        local real damageAmount
        local real distanceX
        local real distanceY
        local real distanceZ
        local boolean isTargetNotNull
        local real lengthXY
        local timer moveTimer = GetExpiredTimer()
        local Unit caster
        local Data d = GetAttachedInteger(moveTimer, FrostBolt_SCOPE_ID)
        local unit dummyUnit = d.dummyUnit
        local boolean reachesTarget
        local real stunTime
        local Unit target = d.target
        local unit targetSelf
        local boolean isTargetNull = ( target == null )
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
            set isTargetNotNull = ( isTargetNull == false )
            call Ending( d, dummyUnit, isTargetNotNull, moveTimer, target )
            if ( isTargetNotNull ) then
                if ( TargetConditions( caster.owner, target ) == null ) then
                    if ( IsUnitType( targetSelf, UNIT_TYPE_HERO ) ) then
                        set damageAmount = HERO_DAMAGE
                        set stunTime = HERO_DURATION
                    else
                        set damageAmount = DAMAGE
                        set stunTime = DURATION
                    endif
                    call SetUnitStunTimed( target, 1, stunTime )
                    call UnitDamageUnitBySpell( caster, target, damageAmount )
                endif
            endif
        else
            set d.x = x
            set d.y = y
            set d.z = z
        endif
        set dummyUnit = null
        set moveTimer = null
        set targetSelf = null
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local unit casterSelf = caster.self
        local real casterX = GetUnitX(casterSelf)
        local real casterY = GetUnitY(casterSelf)
        local Data d = Data.create()
        local unit dummyUnit = CreateUnitWJ( caster.owner, DUMMY_UNIT_ID, casterX, casterY, GetUnitFacingWJ( casterSelf ) )
        local timer moveTimer = CreateTimerWJ()
        local integer targetId = target.id
        set d.caster = caster
        set d.dummyUnit = dummyUnit
        set d.moveTimer = moveTimer
        set d.target = target
        set d.x = casterX
        set d.y = casterY
        call AttachInteger( moveTimer, FrostBolt_SCOPE_ID, d )
        call AddIntegerToTableById( targetId, FrostBolt_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, FrostBolt_SCOPE_ID ) == TABLE_STARTED ) then
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
        endif
        call SetUnitZ( dummyUnit, casterX, casterY, GetUnitZ( casterSelf, casterX, casterY ) + GetUnitOutpactZ(caster) )
        set casterSelf = null
        set dummyUnit = null
        call TimerStart( moveTimer, UPDATE_TIME, true, function Move )
        set moveTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    public function Order takes player casterOwner, Unit target returns string
        return TargetConditions( casterOwner, target )
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order(ORDERED_UNIT.owner, TARGET_UNIT)
    endfunction

    public function Init takes nothing returns nothing
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        call InitUnitType( DUMMY_UNIT_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()