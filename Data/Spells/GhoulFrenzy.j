//TESH.scrollpos=107
//TESH.alwaysfold=0
//! runtextmacro Scope("GhoulFrenzy")
    globals
        public constant integer RESEARCH_ID = 'R01B'
        public constant integer SPELL_ID = 'A085'

        private constant real BONUS_SPEED = 100.
        private constant string CASTER_EFFECT_PATH = "Abilities\\Weapons\\IllidanMissile\\IllidanMissile.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "hand left"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT2 = "hand right"
        private constant real DURATION = 10.
        private constant real RELATIVE_BONUS_ATTACK_RATE = 1.
    endglobals

    private struct Data
        Unit caster
        effect casterEffect
        effect casterEffect2
        timer durationTimer
    endstruct

    public function Caster_Death takes Unit caster returns nothing
        local integer casterId = caster.id
        if (GetAttachedBooleanById(casterId, GhoulFrenzy_SCOPE_ID)) then
            call FlushAttachedBooleanById(casterId, GhoulFrenzy_SCOPE_ID)
            //! runtextmacro RemoveEventById( "casterId", "EVENT_CASTER_DEATH" )
            //! runtextmacro RemoveEventById( "casterId", "EVENT_SOURCE_DEATH" )
        endif
    endfunction

    private function Caster_Death_Event takes nothing returns nothing
        call Caster_Death( DYING_UNIT )
    endfunction

    private function Ending takes Unit caster, Data d, timer durationTimer returns nothing
        local effect casterEffect = d.casterEffect
        local effect casterEffect2 = d.casterEffect2
        local integer casterId = caster.id
        call d.destroy()
        call FlushAttachedIntegerById( casterId, GhoulFrenzy_SCOPE_ID )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_CASTER_DEATH2" )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DISPEL" )
        call DestroyEffectWJ( casterEffect )
        set casterEffect = null
        call DestroyEffectWJ( casterEffect2 )
        set casterEffect2 = null
        call FlushAttachedInteger( durationTimer, GhoulFrenzy_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call AddUnitAttackRate( caster, -RELATIVE_BONUS_ATTACK_RATE )
        call AddUnitSpeedBonus( caster, -BONUS_SPEED )
    endfunction

    public function Dispel takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, GhoulFrenzy_SCOPE_ID)
        if ( d != NULL ) then
            call Ending( caster, d, d.durationTimer )
        endif
    endfunction

    private function Dispel_Event takes nothing returns nothing
        call Dispel( TRIGGER_UNIT )
    endfunction

    public function Caster_Death2 takes Unit caster returns nothing
        call Dispel( caster )
    endfunction

    private function Caster_Death2_Event takes nothing returns nothing
        call Caster_Death2( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, GhoulFrenzy_SCOPE_ID)
        call Ending( d.caster, d, durationTimer )
        set durationTimer = null
    endfunction

    public function Source_Death takes Unit caster returns nothing
        local integer casterId = caster.id
        local unit casterSelf
        local Data d
        local timer durationTimer
        local boolean isNew
        if (GetAttachedBooleanById( casterId, GhoulFrenzy_SCOPE_ID )) then
            set casterSelf = caster.self
            set d = GetAttachedIntegerById(casterId, GhoulFrenzy_SCOPE_ID)
            set isNew = (d == NULL)
            if ( isNew ) then
                set d = Data.create()
                set durationTimer = CreateTimerWJ()
                set d.caster = caster
                set d.durationTimer = durationTimer
                call AttachIntegerById(casterId, GhoulFrenzy_SCOPE_ID, d)
                //! runtextmacro AddEventById( "casterId", "EVENT_CASTER_DEATH2" )
                //! runtextmacro AddEventById( "casterId", "EVENT_DISPEL" )
                call AttachInteger(durationTimer, GhoulFrenzy_SCOPE_ID, d)
            else
                set durationTimer = d.durationTimer
                call DestroyEffectWJ( d.casterEffect )
                call DestroyEffectWJ( d.casterEffect2 )
            endif
            set d.casterEffect = AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, casterSelf, CASTER_EFFECT_ATTACHMENT_POINT )
            set d.casterEffect2 = AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, casterSelf, CASTER_EFFECT_ATTACHMENT_POINT2 )
            set casterSelf = null
            if (isNew) then
                call AddUnitAttackRate( caster, RELATIVE_BONUS_ATTACK_RATE )
                call AddUnitSpeedBonus( caster, BONUS_SPEED )
            endif
            call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
            set durationTimer = null
        endif
    endfunction

    private function Source_Death_Event takes nothing returns nothing
        call Source_Death( KILLING_UNIT )
    endfunction

    public function Learn takes Unit caster returns nothing
        local integer casterId = caster.id
        call AttachBooleanById( casterId, GhoulFrenzy_SCOPE_ID, true )
        //! runtextmacro AddEventById( "casterId", "EVENT_CASTER_DEATH" )
        //! runtextmacro AddEventById( "casterId", "EVENT_SOURCE_DEATH" )
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 300)

        //! runtextmacro CreateEvent( "EVENT_CASTER_DEATH", "UnitDies_EVENT_KEY", "0", "function Caster_Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_CASTER_DEATH2", "UnitDies_EVENT_KEY", "0", "function Caster_Death2_Event" )
        //! runtextmacro CreateEvent( "EVENT_DISPEL", "UnitIsDispelled_EVENT_KEY_POSITIVE", "0", "function Dispel_Event" )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
        //! runtextmacro CreateEvent( "EVENT_SOURCE_DEATH", "UnitDies_EVENT_KEY_AS_KILLING_UNIT", "0", "function Source_Death_Event" )
        call InitEffectType( CASTER_EFFECT_PATH )
        call InitAbility( SPELL_ID )
        //    call AddNewSavedEvent( "MainIntegers", UnitDies_EVENT_STRING_KEY, 0, function Source_Death_Event )
        call SetAbilityRequiredResearch( SPELL_ID, RESEARCH_ID )
    endfunction
//! runtextmacro Endscope()