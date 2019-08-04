//TESH.scrollpos=128
//TESH.alwaysfold=0
//! runtextmacro Scope("RefillMana")
    globals
        private constant integer ORDER_ID = 852548//OrderId( "replenishmana" )
        public constant integer SPELL_ID = 'A03K'

        private constant real DURATION = 10.
        private constant real INTERVAL = 1.
        private constant real MAX_RANGE = 800.
        private constant real REFRESHED_MANA_PER_INTERVAL = 100 / DURATION * INTERVAL
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Items\\AIma\\AImaTarget.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        private constant real UPDATE_TIME = 1.
    endglobals

    private struct Data
        Unit caster
        timer distanceTimer
        timer durationTimer
        timer intervalTimer
        Unit target
    endstruct

    private function Ending takes Unit caster, Data d returns nothing
        local timer distanceTimer = d.distanceTimer
        local timer durationTimer = d.durationTimer
        local timer intervalTimer = d.intervalTimer
        local Unit target = d.target
        local integer targetId = target.id
        call d.destroy()
        call FlushAttachedIntegerById( caster.id, RefillMana_SCOPE_ID_BASIC )
        call FlushAttachedInteger( distanceTimer, RefillMana_SCOPE_ID )
        call DestroyTimerWJ( distanceTimer )
        set distanceTimer = null
        call FlushAttachedInteger( durationTimer, RefillMana_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call FlushAttachedInteger( intervalTimer, RefillMana_SCOPE_ID )
        call DestroyTimerWJ( intervalTimer )
        set intervalTimer = null
        call RemoveIntegerFromTableById( targetId, RefillMana_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, RefillMana_SCOPE_ID ) == TABLE_EMPTY ) then
            //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        endif
    endfunction

    public function Death takes Unit target returns nothing
        local Data d
        local integer targetId = target.id
        local integer iteration = CountIntegersInTableById( targetId, RefillMana_SCOPE_ID )
        if (iteration > TABLE_EMPTY) then
            loop
                set d = GetIntegerFromTableById( targetId, RefillMana_SCOPE_ID, iteration )
                call IssueImmediateOrderById( d.caster.self, STOP_ORDER_ID )
                set iteration = iteration - 1
                exitwhen ( iteration < TABLE_STARTED )
            endloop
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    public function EndCast takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById( caster.id, RefillMana_SCOPE_ID_BASIC )
        if ( d != NULL ) then
            call Ending( caster, d )
        endif
    endfunction

    private function EndCast_Event takes nothing returns nothing
        call EndCast( CASTER )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, RefillMana_SCOPE_ID)
        set durationTimer = null
        call IssueImmediateOrderById( d.caster.self, STOP_ORDER_ID )
    endfunction

    private function Drain takes nothing returns nothing
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, RefillMana_SCOPE_ID)
        local Unit target = d.target
        local unit targetSelf = target.self
        set intervalTimer = null
        call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, targetSelf, TARGET_EFFECT_ATTACHMENT_POINT ) )
        call PlaySoundFromTypeOnUnit( REFRESH_MANA_SOUND_TYPE, targetSelf )
        call AddUnitState( targetSelf, UNIT_STATE_MANA, REFRESHED_MANA_PER_INTERVAL )
        set targetSelf = null
    endfunction

    private function CheckDistance takes nothing returns nothing
        local timer distanceTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(distanceTimer, RefillMana_SCOPE_ID)
        local Unit caster = d.caster
        local unit casterSelf = caster.self
        local Unit target = d.target
        local unit targetSelf = target.self
        if ( DistanceByCoordinates( GetUnitX(casterSelf), GetUnitY(casterSelf), GetUnitX(targetSelf), GetUnitY(targetSelf) ) > MAX_RANGE ) then
            call IssueImmediateOrderById( casterSelf, STOP_ORDER_ID )
        endif
        set casterSelf = null
        set targetSelf = null
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local Data d = Data.create()
        local timer distanceTimer = CreateTimerWJ()
        local timer durationTimer = CreateTimerWJ()
        local timer intervalTimer = CreateTimerWJ()
        local integer targetId = target.id
        set d.caster = caster
        set d.distanceTimer = distanceTimer
        set d.durationTimer = durationTimer
        set d.intervalTimer = intervalTimer
        set d.target = target
        call AttachIntegerById( caster.id, RefillMana_SCOPE_ID_BASIC, d )
        call AttachInteger( distanceTimer, RefillMana_SCOPE_ID, d )
        call AttachInteger( durationTimer, RefillMana_SCOPE_ID, d )
        call AttachInteger( intervalTimer, RefillMana_SCOPE_ID, d )
        call AddIntegerToTableById( targetId, RefillMana_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, RefillMana_SCOPE_ID ) == TABLE_STARTED ) then
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
        endif
        call TimerStart( distanceTimer, UPDATE_TIME, true, function CheckDistance )
        set distanceTimer = null
        call TimerStart( intervalTimer, INTERVAL, true, function Drain )
        set intervalTimer = null
        call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    public function Order takes Unit caster, player casterOwner, Unit target returns string
        local real targetMaxMana
        if ( caster == target ) then
            return ErrorStrings_NOT_SELF
        endif
        set TEMP_UNIT_SELF = target.self
        if ( IsUnitAlly( TEMP_UNIT_SELF, casterOwner ) == false ) then
            return ErrorStrings_ONLY_ALLY
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return ErrorStrings_NOT_MECHANICAL
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return ErrorStrings_NOT_STRUCTURE
        endif
        set targetMaxMana = GetUnitState( TEMP_UNIT_SELF, UNIT_STATE_MAX_MANA )
        if ( targetMaxMana <= 0 ) then
            return ErrorStrings_NEEDS_MANA_POOL
        endif
        if ( GetUnitState( TEMP_UNIT_SELF, UNIT_STATE_MANA ) >= targetMaxMana ) then
            return ErrorStrings_ALREADY_FULL_MANA
        endif
        if ( IsUnitIllusionWJ( target ) ) then
            return ErrorStrings_NOT_ILLUSION
        endif
        if ( IsUnitWard( target ) ) then
            return ErrorStrings_NOT_WARD
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( CASTER, CASTER.owner, TARGET_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        //! runtextmacro AddNewEventById( "EVENT_ENDCAST", "SPELL_ID", "UnitFinishesCasting_EVENT_KEY", "0", "function EndCast_Event" )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        call InitEffectType( TARGET_EFFECT_PATH )
    endfunction
//! runtextmacro Endscope()