//TESH.scrollpos=80
//TESH.alwaysfold=0
//! runtextmacro Scope("Suicide")
    globals
        private constant integer ORDER_ID = 852593//OrderId( "stampede" )
        public constant integer SPELL_ID = 'A047'

        private constant real DURATION = 3.
    endglobals

    private struct Data
        Unit caster
        timer durationTimer
    endstruct

    private function Ending takes Unit caster, Data d returns nothing
        local timer durationTimer = d.durationTimer
        call d.destroy()
        call FlushAttachedIntegerById( caster.id, Suicide_SCOPE_ID )
        call FlushAttachedInteger( durationTimer, Suicide_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
    endfunction

    public function EndCast takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById( caster.id, Suicide_SCOPE_ID )
        if ( d != NULL ) then
            call Ending( caster, d )
        endif
    endfunction

    private function EndCast_Event takes nothing returns nothing
        call EndCast( CASTER )
    endfunction

    //! runtextmacro Scope("Fade")
        globals
            private constant real Fade_DURATION = 5.
        endglobals

        private struct Fade_Data
            Unit caster
            timer durationTimer
        endstruct

        private function Fade_Ending takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Fade_Data d = GetAttachedInteger(durationTimer, Fade_SCOPE_ID)
            local Unit caster = d.caster
            call FlushAttachedIntegerById( caster.id, Fade_SCOPE_ID )
            call FlushAttachedInteger( durationTimer, Fade_SCOPE_ID )
            call DestroyTimerWJ( durationTimer )
            set durationTimer = null
            call KillUnit( caster.self )
        endfunction

        public function Fade_Start takes Unit caster, timer durationTimer returns nothing
            local unit casterSelf = caster.self
            local Fade_Data d = Fade_Data.create()
            set d.caster = caster
            set d.durationTimer = durationTimer
            call AttachIntegerById( caster.id, Fade_SCOPE_ID, d )
            call AttachInteger( durationTimer, Fade_SCOPE_ID, d )
            call AddUnitVertexColorTimed( caster, 0, 0, 0, -255, null, Fade_DURATION )
            call SetUnitAnimationByIndex( casterSelf, 11 )
            call AddUnitLocust( casterSelf )
            set casterSelf = null
            call TimerStart( durationTimer, Fade_DURATION, false, function Fade_Ending )
        endfunction
    //! runtextmacro Endscope()

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, Suicide_SCOPE_ID)
        local Unit caster = d.caster
        local timer FadeTimer = CreateTimerWJ()
        call RemoveUnitDecay(caster)
        call KillUnit( caster.self )
        call Fade_Fade_Start(caster, durationTimer)
        set durationTimer = null
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local Data d = Data.create()
        local timer durationTimer = CreateTimerWJ()
        set d.caster = caster
        set d.durationTimer = durationTimer
        call AttachIntegerById( caster.id, Suicide_SCOPE_ID, d )
        call AttachInteger( durationTimer, Suicide_SCOPE_ID, d )
        call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ENDCAST", "SPELL_ID", "UnitFinishesCasting_EVENT_KEY", "0", "function EndCast_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()