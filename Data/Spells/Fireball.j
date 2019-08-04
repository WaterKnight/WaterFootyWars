//TESH.scrollpos=252
//TESH.alwaysfold=0
//! runtextmacro Scope("Fireball")
    globals
        public constant integer ORDER_ID = 852132//OrderId( "autodispel" )
        public constant integer SPELL_ID = 'A08J'

        private real array DAMAGE
        private constant integer DUMMY_UNIT_ID = 'h014'
        private real array DURATION
        private constant real SPEED = 600.
        private constant real UPDATE_TIME = 0.035
        private SoundType array LAUNCH_EFFECT_SOUND_TYPES
        private constant real LENGTH = SPEED * UPDATE_TIME
    endglobals

    private struct Data
        integer abilityLevel
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

    private function Ending takes Data d, boolean isTargetNotNull, unit dummyUnit, timer moveTimer, Unit target returns nothing
        local integer targetId
        call d.destroy()
        call SetUnitAnimationByIndex( dummyUnit, 1 )
        call RemoveUnitTimed( dummyUnit, 2 )
        call FlushAttachedInteger( moveTimer, Fireball_SCOPE_ID )
        call DestroyTimerWJ( moveTimer )
        if ( isTargetNotNull ) then
            set targetId = target.id
            call RemoveIntegerFromTableById( targetId, Fireball_SCOPE_ID, d )
            if ( CountIntegersInTableById( targetId, Fireball_SCOPE_ID ) == TABLE_EMPTY ) then
                //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
            endif
        endif
    endfunction

    private function Death_ResetTarget takes Data d, Unit target, real targetX, real targetY, real targetZ returns nothing
        local integer targetId = target.id
        call RemoveIntegerFromTableById( targetId, Fireball_SCOPE_ID, d )
        set d.target = NULL
        if ( CountIntegersInTableById( targetId, Fireball_SCOPE_ID ) == TABLE_EMPTY ) then
            //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        endif
        set d.targetX = targetX
        set d.targetY = targetY
        set d.targetZ = targetZ
    endfunction

    public function Death takes Unit target, real targetX, real targetY, real targetZ returns nothing
        local Data d
        local integer targetId = target.id
        local integer iteration = CountIntegersInTableById( targetId, Fireball_SCOPE_ID )
        if ( iteration > TABLE_EMPTY ) then
            loop
                set d = GetIntegerFromTableById( targetId, Fireball_SCOPE_ID, iteration )
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
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_HERO ) ) then
            return ErrorStrings_NOT_HERO
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
        local integer abilityLevel
        local real angleLengthXYZ
        local real angleXY
        local Unit caster
        local real distanceX
        local real distanceY
        local real distanceZ
        local boolean isTargetNotNull
        local real lengthXY
        local timer moveTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(moveTimer, Fireball_SCOPE_ID)
        local unit dummyUnit = d.dummyUnit
        local real dummyUnitX = d.x
        local real dummyUnitY = d.y
        local real dummyUnitZ = d.z
        local boolean reachesTarget
        local Unit target = d.target
        local boolean isTargetNull = ( target == null )
        local unit targetSelf
        local real targetX
        local real targetY
        local real targetZ
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
        set reachesTarget = ( DistanceByCoordinatesWithZ( dummyUnitX, dummyUnitY, dummyUnitZ, targetX, targetY, targetZ ) <= LENGTH )
        if ( reachesTarget ) then
            set dummyUnitX = targetX
            set dummyUnitY = targetY
            set dummyUnitZ = targetZ
        else
            set distanceZ = targetZ - dummyUnitZ
            set angleLengthXYZ = Atan2( distanceZ, DistanceByCoordinates( dummyUnitX, dummyUnitY, targetX, targetY ) )
            set distanceX = targetX - dummyUnitX
            set distanceY = targetY - dummyUnitY
            set angleXY = Atan2( distanceY, distanceX )
            set lengthXY = LENGTH * Cos( angleLengthXYZ )
            set dummyUnitX = dummyUnitX + lengthXY * Cos( angleXY )
            set dummyUnitY = dummyUnitY + lengthXY * Sin( angleXY )
            set dummyUnitZ = dummyUnitZ + LENGTH * Sin( angleLengthXYZ )
            call SetUnitFacingWJ( dummyUnit, angleXY )
        endif
        call SetUnitX( dummyUnit, dummyUnitX )
        call SetUnitY( dummyUnit, dummyUnitY )
        call SetUnitZ( dummyUnit, dummyUnitX, dummyUnitY, dummyUnitZ )
        if ( reachesTarget ) then
            set isTargetNotNull = ( isTargetNull == false )
            if ( isTargetNotNull ) then
                set abilityLevel = d.abilityLevel
                set caster = d.caster
            endif
            call Ending( d, isTargetNotNull, dummyUnit, moveTimer, target )
            call PlaySoundFromTypeAtPosition( FIREBALL_IMPACT_SOUND_TYPE, dummyUnitX, dummyUnitY, dummyUnitZ )
            if ( isTargetNotNull ) then
                if ( TargetConditions( caster.owner, target ) == null ) then
                    call SetUnitStunTimed( target, 1, DURATION[abilityLevel] )
                    call UnitDamageUnitBySpell( caster, target, DAMAGE[abilityLevel] )
                endif
            endif
        else
            set d.x = dummyUnitX
            set d.y = dummyUnitY
            set d.z = dummyUnitZ
        endif
        set moveTimer = null
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local integer abilityLevel = 1 + GetPlayerTechCount( caster.owner, GreaterFireball_RESEARCH_ID, true )
        local unit casterSelf = caster.self
        local real casterX = GetUnitX(casterSelf)
        local real casterY = GetUnitY(casterSelf)
        local real casterZ = GetUnitZ( casterSelf, casterX, casterY ) + GetUnitOutpactZ(caster)
        local Data d = Data.create()
        local unit dummyUnit = CreateUnitWJ( caster.owner, DUMMY_UNIT_ID, casterX, casterY, GetUnitFacingWJ( casterSelf ) )
        local timer moveTimer = CreateTimer()
        local integer targetId = target.id
        set casterSelf = null
        set d.abilityLevel = abilityLevel
        set d.caster = caster
        set d.dummyUnit = dummyUnit
        set d.moveTimer = moveTimer
        set d.target = target
        set d.x = casterX
        set d.y = casterY
        set d.z = casterZ
        call AttachInteger( moveTimer, Fireball_SCOPE_ID, d )
        call AddIntegerToTableById( targetId, Fireball_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, Fireball_SCOPE_ID ) == TABLE_STARTED ) then
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
        endif
        call SetUnitZ( dummyUnit, casterX, casterY, casterZ )
        set dummyUnit = null
        call PlaySoundFromTypeAtPosition( LAUNCH_EFFECT_SOUND_TYPES[GetRandomInt(0, 2)], casterX, casterY, casterZ )
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
        set ERROR_MSG = Order( ORDERED_UNIT.owner, TARGET_UNIT )
    endfunction

    //! runtextmacro Scope("Automatic")
        globals
            public constant integer Automatic_ACTIVATION_ORDER_ID = 852133//OrderId( "autodispelon" )
            public constant integer Automatic_DEACTIVATION_ORDER_ID = 852134//OrderId( "autodispeloff" )

            private constant real Automatic_AREA_RANGE = 500.
            private group Automatic_ENUM_GROUP
            private boolexpr Automatic_TARGET_CONDITIONS
        endglobals

        private function Automatic_TargetConditions takes nothing returns boolean
            set FILTER_UNIT_SELF = GetFilterUnit()
            if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
                return false
            endif
            set FILTER_UNIT = GetUnit(FILTER_UNIT_SELF)
            if ( TargetConditions( TEMP_PLAYER, FILTER_UNIT ) != null ) then
                return false
            endif
            return true
        endfunction

        public function Automatic_TargetInRange takes Unit caster, player casterOwner returns nothing
            local unit enumUnit
            local unit casterSelf
            local real casterX
            local real casterY
            if ( GetUnitAutomaticAbility(caster) == SPELL_ID ) then
                set casterSelf = caster.self
                set casterX = GetUnitX( casterSelf )
                set casterY = GetUnitY( casterSelf )
                set casterSelf = null
                set TEMP_PLAYER = casterOwner
                call GroupEnumUnitsInRangeWithCollision( Automatic_ENUM_GROUP, casterX, casterY, Automatic_AREA_RANGE, Automatic_TARGET_CONDITIONS )
                set enumUnit = GetRandomUnit( Automatic_ENUM_GROUP )
                if ( enumUnit != null ) then
                    call IssueTargetOrderByIdTimed( caster, ORDER_ID, GetUnit(enumUnit), 0 )
                endif
            endif
        endfunction

        private function Automatic_TargetInRange_Event takes nothing returns nothing
            call Automatic_TargetInRange( TRIGGER_UNIT, TRIGGER_UNIT.owner )
        endfunction

        public function Automatic_Activation_Order takes Unit caster returns nothing
            //! runtextmacro AddEventById( "caster.id", "Automatic_EVENT_ACQUIRE" )
            call SetUnitAutomaticAbility(caster, SPELL_ID)
        endfunction

        private function Automatic_Activation_Order_Event takes nothing returns nothing
            call Automatic_Activation_Order( ORDERED_UNIT )
        endfunction

        public function Automatic_Deactivation_Order takes Unit caster returns nothing
            //! runtextmacro RemoveEventById( "caster.id", "Automatic_EVENT_ACQUIRE" )
            call SetUnitAutomaticAbility(caster, 0)
        endfunction

        private function Automatic_Deactivation_Order_Event takes nothing returns nothing
            call Automatic_Deactivation_Order( ORDERED_UNIT )
        endfunction

        public function Automatic_Init takes nothing returns nothing
            set Automatic_ENUM_GROUP = CreateGroupWJ()
            set Automatic_TARGET_CONDITIONS = ConditionWJ( function Automatic_TargetConditions )
            call AddOrderAbility( Automatic_ACTIVATION_ORDER_ID, SPELL_ID )
            call AddOrderAbility( Automatic_DEACTIVATION_ORDER_ID, SPELL_ID )
            //! runtextmacro CreateEvent( "Automatic_EVENT_ACQUIRE", "UnitAcquiresTarget_EVENT_KEY", "0", "function Automatic_TargetInRange_Event" )
            //! runtextmacro AddNewEventById( "Automatic_EVENT_ACTIVATION_ORDER", "GetAbilityOrderId( SPELL_ID, Automatic_ACTIVATION_ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Automatic_Activation_Order_Event" )
            //! runtextmacro AddNewEventById( "Automatic_EVENT_DEACTIVATION_ORDER", "GetAbilityOrderId( SPELL_ID, Automatic_DEACTIVATION_ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Automatic_Deactivation_Order_Event" )
        endfunction
    //! runtextmacro Endscope()

    public function Init takes nothing returns nothing
        set DAMAGE[1] = 20
        set DAMAGE[2] = 30
        set DAMAGE[3] = 40
        set DURATION[1] = 3
        set DURATION[2] = 3.5
        set DURATION[3] = 4
        set LAUNCH_EFFECT_SOUND_TYPES[0] = FIREBALL_LAUNCH_SOUND_TYPE
        set LAUNCH_EFFECT_SOUND_TYPES[1] = FIREBALL_LAUNCH2_SOUND_TYPE
        set LAUNCH_EFFECT_SOUND_TYPES[2] = FIREBALL_LAUNCH3_SOUND_TYPE
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call Automatic_Automatic_Init()
    endfunction
//! runtextmacro Endscope()