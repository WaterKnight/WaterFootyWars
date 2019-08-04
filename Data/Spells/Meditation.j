//TESH.scrollpos=109
//TESH.alwaysfold=0
//! runtextmacro Scope("Meditation")
    globals
        private constant integer ORDER_ID = 852227//OrderId( "sleep" )
        public constant integer SPELL_ID = 'A06S'

        private constant string CASTER_EFFECT_PATH = "Abilities\\Spells\\Orc\\EtherealForm\\SpiritWalkerChange.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "origin"
        private constant real DURATION = 8.
        private constant real DURATION_PER_INTELLIGENCE_POINT = -0.05
        private constant real INTERVAL = 0.25
        private constant real RELATIVE_REFRESHED_LIFE_PER_INTERVAL = 0.2 * INTERVAL
        private constant real RELATIVE_REFRESHED_LIFE_PER_INTERVAL_PER_STRENGTH_POINT = 0.0011 * INTERVAL
        private constant real RELATIVE_REFRESHED_MANA_PER_INTERVAL = 0.2 * INTERVAL
        private constant real RELATIVE_REFRESHED_MANA_PER_INTERVAL_PER_STRENGTH_POINT = 0.0011 * INTERVAL
        public trigger WHIRLWIND_TRIGGER

        public Unit WHIRLWIND_CASTER
    endglobals

    private struct Data
        Unit caster
        timer durationTimer
        timer intervalTimer
        real refreshedRelativeLifePerInterval
        real refreshedRelativeManaPerInterval
    endstruct

    private function Ending takes Unit caster, Data d returns nothing
        local integer casterId = caster.id
        local unit casterSelf = caster.self
        local timer durationTimer = d.durationTimer
        local timer intervalTimer = d.intervalTimer
        call d.destroy()
        call FlushAttachedIntegerById( casterId, Meditation_SCOPE_ID )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DAMAGE" )
        call SetUnitAnimationByIndex( casterSelf, 12 )
        call QueueUnitAnimation( casterSelf, "stand" )
        call FlushAttachedInteger( durationTimer, Meditation_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call FlushAttachedInteger( intervalTimer, Meditation_SCOPE_ID )
        call DestroyTimerWJ( intervalTimer )
        set intervalTimer = null
    endfunction

    public function EndCast takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, Meditation_SCOPE_ID)
        if ( d != NULL ) then
            call Ending( caster, d )
        endif
    endfunction

    private function EndCast_Event takes nothing returns nothing
        call EndCast( CASTER )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, Meditation_SCOPE_ID)
        local Unit caster = d.caster
        call StopUnit( caster )
        call DispelUnit( caster, true, false, true )
    endfunction

    private function Whirlwind takes nothing returns nothing
        call StopUnit( WHIRLWIND_CASTER )
    endfunction

    public function Damage takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById( caster.id, Meditation_SCOPE_ID )
        if ( d != NULL ) then
            call StopUnit( caster )
        endif
    endfunction

    private function Damage_Event takes nothing returns nothing
        call Damage( TRIGGER_UNIT )
    endfunction

    private function Heal takes nothing returns nothing
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, Meditation_SCOPE_ID)
        local Unit caster = d.caster
        local unit casterSelf = caster.self
        set intervalTimer = null
        call DestroyEffectTimed( AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, casterSelf, CASTER_EFFECT_ATTACHMENT_POINT ), 1 )
        call HealUnitBySpell( caster, d.refreshedRelativeLifePerInterval * GetUnitState( casterSelf, UNIT_STATE_MAX_LIFE ) )
        call AddUnitState( casterSelf, UNIT_STATE_MANA, d.refreshedRelativeManaPerInterval * GetUnitState( casterSelf, UNIT_STATE_MAX_MANA ) )
        set casterSelf = null
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local integer casterId = caster.id
        local real casterStrength = GetHeroStrengthTotal( caster )
        local Data d = Data.create()
        local real duration = Max( 1, DURATION + GetHeroIntelligenceTotal( caster ) * DURATION_PER_INTELLIGENCE_POINT )
        local timer durationTimer = CreateTimerWJ()
        local timer intervalTimer = CreateTimerWJ()
        local integer wavesAmount = R2I(duration / INTERVAL)
        call Whirlwind_Death( caster )
        set d.caster = caster
        set d.durationTimer = durationTimer
        set d.intervalTimer = intervalTimer
        set d.refreshedRelativeLifePerInterval = (RELATIVE_REFRESHED_LIFE_PER_INTERVAL + casterStrength * RELATIVE_REFRESHED_LIFE_PER_INTERVAL_PER_STRENGTH_POINT) / wavesAmount
        set d.refreshedRelativeManaPerInterval = (RELATIVE_REFRESHED_MANA_PER_INTERVAL + casterStrength * RELATIVE_REFRESHED_MANA_PER_INTERVAL_PER_STRENGTH_POINT) / wavesAmount
        call AttachIntegerById( casterId, Meditation_SCOPE_ID, d )
        //! runtextmacro AddEventById( "casterId", "EVENT_DAMAGE" )
        call AttachInteger( durationTimer, Meditation_SCOPE_ID, d )
        call AttachInteger( intervalTimer, Meditation_SCOPE_ID, d )
        call SetUnitAnimationByIndex( caster.self, 15 )
        call TimerStart( intervalTimer, INTERVAL, true, function Heal )
        set intervalTimer = null
        call TimerStart( durationTimer, duration, false, function EndingByTimer )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY", "0", "function Damage_Event" )
        set WHIRLWIND_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode(WHIRLWIND_TRIGGER, function Whirlwind)
        call InitEffectType( CASTER_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ENDCAST", "SPELL_ID", "UnitFinishesCasting_EVENT_KEY", "0", "function EndCast_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()