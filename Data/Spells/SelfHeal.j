//TESH.scrollpos=67
//TESH.alwaysfold=0
//! runtextmacro Scope("SelfHeal")
    globals
        private constant integer ORDER_ID = 852146//OrderId( "eattree" )
        public constant integer RESEARCH_ID = 'R00R'
        public constant integer SPELL_ID = 'A031'

        private constant string CASTER_EFFECT_PATH = "Abilities\\Spells\\Human\\MarkOfChaos\\MarkOfChaosTarget.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "origin"
        private constant real DURATION = 5.
        private constant real INTERVAL = 1.
        private constant real REFRESHED_LIFE_PER_INTERVAL = 325 * INTERVAL / DURATION
    endglobals

    private struct Data
        Unit caster
        timer durationTimer
        timer intervalTimer
    endstruct

    private function Ending takes Unit caster, Data d returns nothing
        local timer durationTimer = d.durationTimer
        local timer intervalTimer = d.intervalTimer
        call d.destroy()
        call FlushAttachedIntegerById( caster.id, SelfHeal_SCOPE_ID )
        call FlushAttachedInteger( durationTimer, SelfHeal_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call FlushAttachedInteger( intervalTimer, SelfHeal_SCOPE_ID )
        call DestroyTimerWJ( intervalTimer )
        set intervalTimer = null
    endfunction

    public function EndCast takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, SelfHeal_SCOPE_ID)
        if ( d != NULL ) then
            call Ending( caster, d )
        endif
    endfunction

    private function EndCast_Event takes nothing returns nothing
        call EndCast( CASTER )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, SelfHeal_SCOPE_ID)
        set durationTimer = null
        call IssueImmediateOrderById(d.caster.self, STOP_ORDER_ID)
    endfunction

    private function Heal takes nothing returns nothing
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, SelfHeal_SCOPE_ID)
        local Unit caster = d.caster
        call DestroyEffectWJ( AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, caster.self, CASTER_EFFECT_ATTACHMENT_POINT ) )
        call HealUnitBySpell( caster, REFRESHED_LIFE_PER_INTERVAL )
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local Data d = Data.create()
        local timer durationTimer = CreateTimerWJ()
        local timer intervalTimer = CreateTimerWJ()
        set d.caster = caster
        set d.durationTimer = durationTimer
        set d.intervalTimer = intervalTimer
        call AttachIntegerById( caster.id, SelfHeal_SCOPE_ID, d )
        call AttachInteger( durationTimer, SelfHeal_SCOPE_ID, d )
        call AttachInteger( intervalTimer, SelfHeal_SCOPE_ID, d )
        call TimerStart( intervalTimer, INTERVAL, true, function Heal )
        set intervalTimer = null
        call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 300)

        call InitEffectType( CASTER_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ENDCAST", "SPELL_ID", "UnitFinishesCasting_EVENT_KEY", "0", "function EndCast_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()