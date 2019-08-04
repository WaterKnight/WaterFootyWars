//TESH.scrollpos=129
//TESH.alwaysfold=0
//! runtextmacro Scope("ElectroNet")
    globals
        public constant integer ITEM_ID = 'I02D'
        public constant integer SPELL_ID = 'A08H'

        private constant integer DUMMY_UNIT_ID = 'n033'
        private constant real SPEED = 600.
        private constant real UPDATE_TIME = 0.035
        private constant real LENGTH = SPEED * UPDATE_TIME
    endglobals

    private struct Data
        real angle
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
        call FlushAttachedInteger( moveTimer, ElectroNet_SCOPE_ID )
        call DestroyTimerWJ( moveTimer )
        if ( isTargetNotNull ) then
            set targetId = target.id
            call RemoveIntegerFromTableById( targetId, ElectroNet_SCOPE_ID, d )
            if ( CountIntegersInTableById( targetId, ElectroNet_SCOPE_ID ) == TABLE_EMPTY ) then
                //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
            endif
        endif
    endfunction

    private function Death_ResetTarget takes Data d, Unit target, real targetX, real targetY, real targetZ returns nothing
        local integer targetId = target.id
        set d.target = NULL
        call RemoveIntegerFromTableById( targetId, ElectroNet_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, ElectroNet_SCOPE_ID ) == TABLE_EMPTY ) then
            //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        endif
        set d.targetX = targetX
        set d.targetY = targetY
        set d.targetZ = targetZ
    endfunction

    public function Death takes Unit target, real targetX, real targetY, real targetZ returns nothing
        local Data d
        local integer targetId = target.id
        local integer iteration = CountIntegersInTableById( targetId, ElectroNet_SCOPE_ID )
        if (iteration > TABLE_EMPTY) then
            loop
                set d = GetIntegerFromTableById( targetId, ElectroNet_SCOPE_ID, iteration )
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

    //! runtextmacro Scope("Buff")
        globals
            private constant real Buff_DAMAGE_PER_INTERVAL = 30.
            private constant real Buff_DURATION_HIGH = 10.
            private constant real Buff_DURATION_MAX_LIFE = 1200.
            private constant real Buff_DURATION_LOW = 4.
            private constant real Buff_INTERVAL = 2.
            private constant string Buff_TARGET_EFFECT_PATH = "Abilities\\Weapons\\Bolt\\BoltImpact.mdl"
            private constant string Buff_TARGET_EFFECT_ATTACHMENT_POINT = "chest"
        endglobals

        private struct Buff_Data
            Unit caster
            timer durationTimer
            timer intervalTimer
            Unit target
        endstruct

        private function Buff_Ending takes Buff_Data d, timer durationTimer, Unit target returns nothing
            local timer intervalTimer = d.intervalTimer
            local integer targetId = target.id
            call d.destroy()
            call FlushAttachedInteger( durationTimer, Buff_SCOPE_ID )
            call DestroyTimerWJ( durationTimer )
            call FlushAttachedInteger( intervalTimer, Buff_SCOPE_ID )
            call DestroyTimerWJ( intervalTimer )
            set intervalTimer = null
            call FlushAttachedIntegerById( targetId, Buff_SCOPE_ID )
            //! runtextmacro RemoveEventById( "targetId", "Buff_EVENT_DEATH" )
            call RemoveUnitStun( target, 3 )
        endfunction

        public function Buff_Death takes Unit target returns nothing
            local Buff_Data d = GetAttachedIntegerById(target.id, Buff_SCOPE_ID)
            if (d != NULL) then
                call Buff_Ending(d, d.durationTimer, target)
            endif
        endfunction

        private function Buff_Death_Event takes nothing returns nothing
            call Buff_Death( DYING_UNIT )
        endfunction

        private function Buff_EndingByTimer takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Buff_Data d = GetAttachedInteger(durationTimer, Buff_SCOPE_ID)
            call Buff_Ending( d, durationTimer, d.target )
            set durationTimer = null
        endfunction

        private function Buff_Interval takes nothing returns nothing
            local timer intervalTimer = GetExpiredTimer()
            local Buff_Data d = GetAttachedInteger(intervalTimer, Buff_SCOPE_ID)
            local Unit target = d.target
            set intervalTimer = null
            call DestroyEffectWJ( AddSpecialEffectTargetWJ( Buff_TARGET_EFFECT_PATH, target.self, Buff_TARGET_EFFECT_ATTACHMENT_POINT ) )
            call UnitDamageUnitEx( d.caster, target, Buff_DAMAGE_PER_INTERVAL, null )
        endfunction

        public function Buff_Start takes Unit caster, Unit target returns nothing
            local timer durationTimer
            local timer intervalTimer
            local integer targetId = target.id
            local Buff_Data d = GetAttachedIntegerById( targetId, Buff_SCOPE_ID )
            local boolean isNew = ( d == NULL )
            local unit targetSelf = target.self
            local real duration = Buff_DURATION_LOW + (Buff_DURATION_HIGH - Buff_DURATION_LOW) * (1 - Min(GetUnitState(targetSelf, UNIT_STATE_MAX_LIFE) / Buff_DURATION_MAX_LIFE, 1))
            if ( d == NULL ) then
                set d = Buff_Data.create()
                set durationTimer = CreateTimerWJ()
                set intervalTimer = CreateTimerWJ()
                set d.caster = caster
                set d.durationTimer = durationTimer
                set d.intervalTimer = intervalTimer
                set d.target = target
                call AttachInteger( durationTimer, Buff_SCOPE_ID, d )
                call AttachInteger( intervalTimer, Buff_SCOPE_ID, d )
                call AttachIntegerById( targetId, Buff_SCOPE_ID, d )
                //! runtextmacro AddEventById( "targetId", "Buff_EVENT_DEATH" )
                call TimerStart( intervalTimer, Buff_INTERVAL, true, function Buff_Interval )
                call AddUnitStun( target, 3 )
            else
                set durationTimer = d.durationTimer
            endif
            set d.caster = caster
            call TimerStart( durationTimer, duration, false, function Buff_EndingByTimer )
            set durationTimer = null
            call DestroyEffectWJ( AddSpecialEffectTargetWJ( Buff_TARGET_EFFECT_PATH, targetSelf, Buff_TARGET_EFFECT_ATTACHMENT_POINT ) )
            set targetSelf = null
            call UnitDamageUnitEx( caster, target, Buff_DAMAGE_PER_INTERVAL, null )
        endfunction

        public function Buff_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "Buff_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Buff_Death_Event" )
            call InitEffectType( Buff_TARGET_EFFECT_PATH )
        endfunction
    //! runtextmacro Endscope()

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
        local Data d = GetAttachedInteger(moveTimer, ElectroNet_SCOPE_ID)
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
            call Ending( d, dummyUnit, isTargetNotNull, moveTimer, target )
            if ( isTargetNotNull ) then
                if ( TargetConditions( caster.owner, target ) == null ) then
                    call Buff_Buff_Start( caster, target )
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
            set moveTimer = CreateTimerWJ()
            set dummyUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, DUMMY_UNIT_ID, casterX, casterY, angle )
            set targetId = target.id
            set d.angle = angle
            set d.caster = caster
            set d.dummyUnit = dummyUnit
            set d.moveTimer = moveTimer
            set d.target = target
            set d.x = casterX
            set d.y = casterY
            set d.z = casterZ
            call AttachInteger( moveTimer, ElectroNet_SCOPE_ID, d )
            call AddIntegerToTableById( targetId, ElectroNet_SCOPE_ID, d )
            if ( CountIntegersInTableById( targetId, ElectroNet_SCOPE_ID ) == TABLE_STARTED ) then
                //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
            endif
            call SetUnitAnimationByIndex( dummyUnit, 0 )
            call SetUnitZ(dummyUnit, casterX, casterY, casterZ)
            set dummyUnit = null
            call TimerStart( moveTimer, UPDATE_TIME, true, function Move )
            set moveTimer = null
        else
            call Buff_Buff_Start( caster, target )
        endif
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 150)
        call SetItemTypeMaxCharges(d, 2)
        call SetItemTypeRefreshInterval(d, 70)
        call SetItemTypeRefreshIntervalStart(d, 70)

        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        call InitUnitType( DUMMY_UNIT_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )

        call Buff_Buff_Init()
    endfunction
//! runtextmacro Endscope()