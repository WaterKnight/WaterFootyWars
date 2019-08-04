//TESH.scrollpos=252
//TESH.alwaysfold=0
//! runtextmacro Scope("HammerThrow")
    globals
        private constant integer ORDER_ID = 852095//OrderId( "thunderbolt" )
        public constant integer SPELL_ID = 'A06Y'

        private constant real DAMAGE = 50.
        private constant real DAMAGE_PER_STRENGTH_POINT = 3.
        private constant integer DUMMY_UNIT_ID = 'h00U'
        private constant real UPDATE_TIME = 0.035
        private constant real LENGTH = 600 * UPDATE_TIME
    endglobals

    private struct Data
        Unit caster
        real damageAmount
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
        local integer targetId
        call d.destroy()
        call SetUnitAnimationByIndex( dummyUnit, 1 )
        call RemoveUnitTimed( dummyUnit, 2 )
        if ( isTargetNotNull ) then
            set targetId = target.id
            call RemoveIntegerFromTableById( targetId, HammerThrow_SCOPE_ID, d )
            if ( CountIntegersInTableById( targetId, HammerThrow_SCOPE_ID ) == TABLE_EMPTY ) then
                //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
            endif
        endif
        call FlushAttachedInteger( moveTimer, HammerThrow_SCOPE_ID )
        call DestroyTimerWJ( moveTimer )
    endfunction

    private function ResetTarget takes Data d, Unit target, real targetX, real targetY, real targetZ returns nothing
        local integer targetId = target.id
        set d.target = NULL
        call RemoveIntegerFromTableById( targetId, HammerThrow_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, HammerThrow_SCOPE_ID ) == TABLE_EMPTY ) then
            //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        endif
        set d.targetX = targetX
        set d.targetY = targetY
        set d.targetZ = targetZ
    endfunction

    public function Death takes Unit target, real targetX, real targetY, real targetZ returns nothing
        local Data d
        local integer targetId = target.id
        local integer iteration = CountIntegersInTableById( targetId, HammerThrow_SCOPE_ID )
        if ( iteration > TABLE_EMPTY ) then
            loop
                set d = GetIntegerFromTableById( targetId, HammerThrow_SCOPE_ID, iteration )
                call ResetTarget( d, target, targetX, targetY, targetZ )
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
        if ( GetUnitInvulnerability( target ) > 0 ) then
            return ErrorStrings_TARGET_IS_INVULNERABLE
        endif
        if ( GetUnitInvulnerability( target ) > 0 ) then
            return ErrorStrings_TARGET_IS_MAGIC_IMMUNE
        endif
        return null
    endfunction

    private function Move takes nothing returns nothing
        local real angleLengthXYZ
        local real angleXY
        local Unit caster
        local real damageAmount
        local real distanceX
        local real distanceY
        local real distanceZ
        local boolean isTargetNotNull
        local real lengthXY
        local timer moveTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(moveTimer, HammerThrow_SCOPE_ID)
        local unit dummyUnit = d.dummyUnit
        local boolean reachesTarget
        local Unit target = d.target
        local boolean isTargetNull = ( target == NULL )
        local unit targetSelf
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
            set isTargetNotNull = ( isTargetNull == false )
            if ( isTargetNotNull ) then
                set damageAmount = d.damageAmount
            endif
            call Ending( d, dummyUnit, isTargetNotNull, moveTimer, target )
            if ( isTargetNotNull ) then
                if ( TargetConditions( caster.owner, target ) == null ) then
                    call UnitDamageUnitBySpell( caster, target, damageAmount )
                endif
            endif
        else
            set d.x = x
            set d.y = y
            set d.z = z
        endif
        set moveTimer = null
    endfunction

    //! runtextmacro Scope("Mana")
        globals
            private constant real Mana_DELAY = 2.
            private constant real Mana_RELATIVE_REFRESHED_MANA = 0.1
        endglobals

        private struct Mana_Data
            Unit caster
            timer delayTimer
        endstruct

        private function Mana_Ending takes Unit caster, Mana_Data d, timer delayTimer returns nothing
            local integer casterId = caster.id
            call RemoveIntegerFromTableById( casterId, Mana_SCOPE_ID, d )
            if ( CountIntegersInTableById( casterId, Mana_SCOPE_ID ) == TABLE_EMPTY ) then
                //! runtextmacro RemoveEventById( "casterId", "Mana_EVENT_DEATH" )
            endif
            call FlushAttachedInteger( delayTimer, Mana_SCOPE_ID )
            call DestroyTimerWJ( delayTimer )
        endfunction

        public function Mana_Death takes Unit caster returns nothing
            local integer casterId = caster.id
            local Mana_Data d
            local integer iteration = CountIntegersInTableById( casterId, Mana_SCOPE_ID )
            if ( iteration > TABLE_EMPTY ) then
                loop
                    set d = GetIntegerFromTableById( casterId, Mana_SCOPE_ID, iteration )
                    call Mana_Ending( caster, d, d.delayTimer )
                    set iteration = iteration - 1
                    exitwhen ( iteration < TABLE_STARTED )
                endloop
            endif
        endfunction

        private function Mana_Death_Event takes nothing returns nothing
            call Mana_Death( DYING_UNIT )
        endfunction

        private function Mana_EndingByTimer takes nothing returns nothing
            local timer delayTimer = GetExpiredTimer()
            local Mana_Data d = GetAttachedInteger(delayTimer, Mana_SCOPE_ID)
            local Unit caster = d.caster
            local unit casterSelf = caster.self
            local real casterX = GetUnitX( casterSelf )
            local real casterY = GetUnitY( casterSelf )
            local real refreshedMana = GetUnitState( casterSelf, UNIT_STATE_MAX_MANA ) * Mana_RELATIVE_REFRESHED_MANA
            call Mana_Ending( caster, d, delayTimer )
            set delayTimer = null
            call CreateRisingTextTag( "+" + I2S( R2I( refreshedMana ) ), 0.023, casterX, casterY, GetUnitZ( casterSelf, casterX, casterY ) + GetUnitImpactZ(caster), 80, 0, 0, 255, 255, 1, 4 )
            call AddUnitState( casterSelf, UNIT_STATE_MANA, refreshedMana )
            set casterSelf = null
        endfunction

        public function Mana_Start takes Unit caster returns nothing
            local integer casterId = caster.id
            local Mana_Data d = Mana_Data.create()
            local timer delayTimer = CreateTimerWJ()
            set d.caster = caster
            set d.delayTimer = delayTimer
            call AddIntegerToTableById( casterId, Mana_SCOPE_ID, d )
            if ( CountIntegersInTableById( casterId, Mana_SCOPE_ID ) == TABLE_STARTED ) then
                //! runtextmacro AddEventById( "casterId", "Mana_EVENT_DEATH" )
            endif
            call AttachInteger( delayTimer, Mana_SCOPE_ID, d )
            call TimerStart( delayTimer, Mana_DELAY, false, function Mana_EndingByTimer )
            set delayTimer = null
        endfunction

        public function Mana_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "Mana_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Mana_Death_Event" )
        endfunction
    //! runtextmacro Endscope()

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local unit casterSelf = caster.self
        local real casterX = GetUnitX(casterSelf)
        local real casterY = GetUnitY(casterSelf)
        local real casterZ = GetUnitZ( casterSelf, casterX, casterY ) + GetUnitOutpactZ(caster)
        local Data d = Data.create()
        local unit dummyUnit = CreateUnitWJ( caster.owner, DUMMY_UNIT_ID, casterX, casterY, GetUnitFacingWJ( casterSelf ) )
        local timer moveTimer = CreateTimerWJ()
        local integer targetId = target.id
        set casterSelf = null
        set d.caster = caster
        set d.damageAmount = DAMAGE + GetHeroStrengthTotal( caster ) * DAMAGE_PER_STRENGTH_POINT
        set d.dummyUnit = dummyUnit
        set d.target = target
        set d.x = casterX
        set d.y = casterY
        set d.z = casterZ
        call AttachInteger( moveTimer, HammerThrow_SCOPE_ID, d )
        call AddIntegerToTableById( targetId, HammerThrow_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, HammerThrow_SCOPE_ID ) == TABLE_STARTED ) then
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
        endif
        call SetUnitZ( dummyUnit, casterX, casterY, casterZ )
        set dummyUnit = null
        call TimerStart( moveTimer, UPDATE_TIME, true, function Move )
        set moveTimer = null
        call Mana_Mana_Start(caster)
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
        call Mana_Mana_Init()
    endfunction
//! runtextmacro Endscope()