//TESH.scrollpos=106
//TESH.alwaysfold=0
//! runtextmacro Scope("RequestReinforcements")
    globals
        private constant integer ORDER_ID = 852079//OrderId( "tankdroppilot" )
        public constant integer SPELL_ID = 'A037'

        private constant integer DUMMY_UNIT_ID = 'n020'
        private constant real HEIGHT = 400.
        private integer array SPAWNS_AMOUNT
        private constant real SPEED = 400.
        private constant real UPDATE_TIME = 0.035
        private constant real LENGTH = SPEED * UPDATE_TIME
    endglobals

    private struct Data
        player casterOwner
        unit dummyUnit
        timer durationTimer
        real lengthX
        real lengthY
        timer moveTimer
        real targetX
        real targetY
        Race whichRace
        real x
        real y
    endstruct

    private function Ending takes player casterOwner, Data d, timer durationTimer returns nothing
        local unit dummyUnit = d.dummyUnit
        local timer moveTimer = d.moveTimer
        call d.destroy()
        call RemoveIntegerFromTable( casterOwner, RequestReinforcements_SCOPE_ID, d )
        call SetUnitAnimationByIndex( dummyUnit, 6 )
        call RemoveUnitTimed( dummyUnit, 1.667 )
        call FlushAttachedInteger( durationTimer, RequestReinforcements_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        call FlushAttachedInteger( moveTimer, RequestReinforcements_SCOPE_ID )
        call DestroyTimerWJ( moveTimer )
        set moveTimer = null
    endfunction

    public function Death takes player casterOwner returns nothing
        local Data d
        local integer iteration = CountIntegersInTable( casterOwner, RequestReinforcements_SCOPE_ID )
        if (iteration > TABLE_EMPTY) then
            loop
                set d = GetIntegerFromTable( casterOwner, RequestReinforcements_SCOPE_ID, iteration )
                call Ending( casterOwner, d, d.durationTimer )
                set iteration = iteration - 1
                exitwhen ( iteration < TABLE_STARTED )
            endloop
        endif
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, RequestReinforcements_SCOPE_ID)
        local player casterOwner = d.casterOwner
        local integer iteration2
        local integer spawnTypeId
        local real targetX = d.targetX
        local real targetY = d.targetY
        local Race whichRace = d.whichRace
        local integer iteration = CountRaceTownHalls(whichRace)
        call Ending( casterOwner, d, durationTimer )
        set durationTimer = null
        loop
            exitwhen ( iteration < 0 )
            set spawnTypeId = GetUnitTypeSpawnTypeId(GetRaceTownHall(whichRace, iteration))
            set iteration2 = SPAWNS_AMOUNT[iteration] * (1 + GetUnitTypeSpawnBonus(spawnTypeId))
            loop
                exitwhen ( iteration2 < 1 )
                call CreateUnitEx( casterOwner, spawnTypeId, targetX, targetY, STANDARD_ANGLE )
                set iteration2 = iteration2 - 1
            endloop
            set iteration = iteration - 1
        endloop
        set casterOwner = null
    endfunction

    private function Move takes nothing returns nothing
        local timer moveTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(moveTimer, RequestReinforcements_SCOPE_ID)
        local unit dummyUnit = d.dummyUnit
        local real x = d.x + d.lengthX
        local real y = d.y + d.lengthY
        set moveTimer = null
        set d.x = x
        set d.y = y
        call SetUnitX( dummyUnit, x )
        call SetUnitY( dummyUnit, y )
        call SetUnitZ( dummyUnit, x, y, HEIGHT )
        set dummyUnit = null
    endfunction

    public function SpellEffect takes Unit caster, real targetX, real targetY returns nothing
        local unit casterSelf = caster.self
        local player casterOwner = caster.owner
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local real angle = Atan2( targetY - casterY, targetX - casterX )
        local Data d = Data.create()
        local real distanceX = targetX - casterX
        local real distanceY = targetY - casterY
        local real distance = SquareRoot( distanceX * distanceX + distanceY * distanceY )
        local unit dummyUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, DUMMY_UNIT_ID, casterX, casterY, angle )
        local timer durationTimer = CreateTimerWJ()
        local timer moveTimer = CreateTimerWJ()
        set casterSelf = null
        set d.casterOwner = casterOwner
        set d.dummyUnit = dummyUnit
        set d.durationTimer = durationTimer
        set d.lengthX = LENGTH * Cos( angle )
        set d.lengthY = LENGTH * Sin( angle )
        set d.moveTimer = moveTimer
        set d.targetX = targetX
        set d.targetY = targetY
        set d.whichRace = GetPlayerRaceWJ(casterOwner)
        set d.x = casterX
        set d.y = casterY
        call AddIntegerToTable( casterOwner, RequestReinforcements_SCOPE_ID, d )
        call AttachInteger( durationTimer, RequestReinforcements_SCOPE_ID, d )
        call AttachInteger( moveTimer, RequestReinforcements_SCOPE_ID, d )
        call SetUnitColor( dummyUnit, GetPlayerColor( casterOwner ) )
        set casterOwner = null
        call SetUnitZ(dummyUnit, casterX, casterY, HEIGHT)
        call PlaySoundFromTypeOnUnit( REQUEST_REINFORCEMENTS_LAUNCH_SOUND_TYPE, dummyUnit )
        set dummyUnit = null
        call TimerStart( moveTimer, UPDATE_TIME, true, function Move )
        set moveTimer = null
        call TimerStart( durationTimer, distance / SPEED, false, function EndingByTimer )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_X, TARGET_Y )
    endfunction

    public function Order takes Unit caster, player casterOwner, real targetX, real targetY returns string
        if ( GetPlayerRaceWJ(casterOwner) == NULL ) then
            return ErrorStrings_NEEDS_RACE
        endif
        if (IsPointInPlayRegion(targetX, targetY) == false) then
            return ErrorStrings_INVALID_TARGET
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( ORDERED_UNIT, ORDERED_UNIT.owner, TARGET_X, TARGET_Y )
    endfunction

    public function Init takes nothing returns nothing
        set SPAWNS_AMOUNT[0] = 2
        set SPAWNS_AMOUNT[1] = 1
        set SPAWNS_AMOUNT[2] = 1
        set SPAWNS_AMOUNT[3] = 1
        call InitUnitType( DUMMY_UNIT_ID )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()