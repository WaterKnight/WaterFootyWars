//TESH.scrollpos=129
//TESH.alwaysfold=0
//! runtextmacro Scope("MagicalLariat")
    globals
        private constant integer ORDER_ID = 852480//OrderId( "magicleash" )
        public constant integer RESEARCH_ID = 'R016'
        public constant integer SPELL_ID = 'A08C'

        private constant real DURATION = 10.
        private constant string EFFECT_LIGHTNING_PATH = "LEAS"
        private constant real INTERVAL = 1.
        private constant real DAMAGE_PER_INTERVAL = 50 * INTERVAL / DURATION
        private constant real UPDATE_TIME = 0.1
    endglobals

    private struct Data
        Unit caster
        timer damageTimer
        timer durationTimer
        lightning effectLightning
        sound effectSound
        Unit target
        timer updateTimer
    endstruct

    private function Ending takes Unit caster, Data d returns nothing
        local timer damageTimer = d.damageTimer
        local timer durationTimer = d.durationTimer
        local lightning effectLightning = d.effectLightning
        local sound effectSound = d.effectSound
        local Unit target = d.target
        local integer targetId = target.id
        local timer updateTimer = d.updateTimer
        call d.destroy()
        call FlushAttachedIntegerById( caster.id, MagicalLariat_SCOPE_ID_BASIC )
        call FlushAttachedInteger( damageTimer, MagicalLariat_SCOPE_ID )
        call DestroyTimerWJ( damageTimer )
        set damageTimer = null
        call FlushAttachedInteger( durationTimer, MagicalLariat_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call DestroyLightningWJ( effectLightning )
        set effectLightning = null
        call StopSoundWJ( effectSound, false )
        set effectSound = null
        call RemoveIntegerFromTableById( targetId, MagicalLariat_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, MagicalLariat_SCOPE_ID ) == TABLE_EMPTY ) then
            //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        endif
        call FlushAttachedInteger( updateTimer, MagicalLariat_SCOPE_ID )
        call DestroyTimerWJ(updateTimer)
        set updateTimer = null
        call RemoveUnitStun( target, 0 )
    endfunction

    public function Death takes Unit target returns nothing
        local Unit caster
        local Data d
        local integer targetId = target.id
        local integer iteration = CountIntegersInTableById( targetId, MagicalLariat_SCOPE_ID )
        if (iteration > TABLE_EMPTY) then
            loop
                set d = GetIntegerFromTableById( targetId, MagicalLariat_SCOPE_ID, iteration )
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
        local Data d = GetAttachedIntegerById( caster.id, MagicalLariat_SCOPE_ID_BASIC )
        if ( d != NULL ) then
            call Ending( caster, d )
        endif
    endfunction

    private function EndCast_Event takes nothing returns nothing
        call EndCast( CASTER )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, MagicalLariat_SCOPE_ID)
        set durationTimer = null
        call IssueImmediateOrderById( d.caster.self, STOP_ORDER_ID )
    endfunction

    private function DealDamage takes nothing returns nothing
        local timer damageTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(damageTimer, MagicalLariat_SCOPE_ID)
        local Unit target = d.target
        set damageTimer = null
        if ( IsUnitIllusionWJ( target ) ) then
            call KillUnit( target.self )
        else
            call UnitDamageUnitBySpell( d.caster, target, DAMAGE_PER_INTERVAL )
        endif
    endfunction

    private function ResetLightning takes nothing returns nothing
        local timer updateTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(updateTimer, MagicalLariat_SCOPE_ID)
        local Unit caster = d.caster
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local Unit target = d.target
        local unit targetSelf = target.self
        local real targetX = GetUnitX( targetSelf )
        local real targetY = GetUnitY( targetSelf )
        set updateTimer = null
        call MoveLightningEx( d.effectLightning, true, casterX, casterY, GetUnitZ( casterSelf, casterX, casterY ) + GetUnitOutpactZ(caster), targetX, targetY, GetUnitZ( targetSelf, targetX, targetY ) + GetUnitImpactZ(target) )
        set casterSelf = null
        set targetSelf = null
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local Data d = Data.create()
        local timer damageTimer = CreateTimerWJ()
        local real duration
        local timer durationTimer = CreateTimerWJ()
        local sound effectSound = CreateSoundFromType( MAGICAL_LARIAT_SOUND_TYPE )
        local integer targetId = target.id
        local unit targetSelf = target.self
        local real targetX = GetUnitX( targetSelf )
        local real targetY = GetUnitY( targetSelf )
        local timer updateTimer = CreateTimerWJ()
        set d.caster = caster
        set d.damageTimer = damageTimer
        set d.durationTimer = durationTimer
        set d.effectLightning = AddLightningWJ( EFFECT_LIGHTNING_PATH, casterX, casterY, GetUnitZ( casterSelf, casterX, casterY ) + GetUnitOutpactZ(caster), targetX, targetY, GetUnitZ( targetSelf, targetX, targetY ) + GetUnitImpactZ(target) )
        set casterSelf = null
        set d.effectSound = effectSound
        set d.target = target
        set d.updateTimer = updateTimer
        call AttachIntegerById( caster.id, MagicalLariat_SCOPE_ID_BASIC, d )
        call AttachInteger( damageTimer, MagicalLariat_SCOPE_ID, d )
        call AttachInteger( durationTimer, MagicalLariat_SCOPE_ID, d )
        call AddIntegerToTableById( targetId, MagicalLariat_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, MagicalLariat_SCOPE_ID ) == TABLE_STARTED ) then
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
        endif
        call AttachInteger( updateTimer, MagicalLariat_SCOPE_ID, d )
        call AttachSoundToUnit( effectSound, targetSelf )
        set targetSelf = null
        call StartSound( effectSound )
        set effectSound = null
        call AddUnitStun( target, 0 )
        call TimerStart( damageTimer, INTERVAL, true, function DealDamage )
        set damageTimer = null
        call TimerStart( updateTimer, UPDATE_TIME, true, function ResetLightning )
        set updateTimer = null
        call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    public function Order takes Unit caster, Unit target returns string
        set TEMP_UNIT_SELF = target.self
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_HERO ) ) then
            return ErrorStrings_NOT_HERO
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return ErrorStrings_NOT_MECHANICAL
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return ErrorStrings_NOT_STRUCTURE
        endif
        if ( GetUnitMagicImmunity( target ) > 0 ) then
            return ErrorStrings_TARGET_IS_MAGIC_IMMUNE
        endif
        if ( IsUnitWard( target ) ) then
            return ErrorStrings_NOT_WARD
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( ORDERED_UNIT, TARGET_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 300)

        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ENDCAST", "SPELL_ID", "UnitFinishesCasting_EVENT_KEY", "0", "function EndCast_Event" )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()