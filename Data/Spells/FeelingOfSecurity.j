//TESH.scrollpos=170
//TESH.alwaysfold=0
//! runtextmacro Scope("FeelingOfSecurity")
    globals
        private constant integer ORDER_ID = 852160//OrderId( "rejuvination" )
        public constant integer RESEARCH_ID = 'R00W'
        public constant integer SPELL_ID = 'A081'
        public constant integer UPGRADED_SPELL_ID = 'A082'

        private constant real DURATION = 15.
        private constant real INTERVAL = 0.25
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Items\\ScrollOfRejuvenation\\ScrollManaHealth.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "chest"
        private constant integer WAVES_AMOUNT = R2I(DURATION / INTERVAL)
        private constant real RELATIVE_REFRESHED_LIFE_PER_INTERVAL = 0.5 / WAVES_AMOUNT
        private constant real RELATIVE_REFRESHED_MANA_PER_INTERVAL = 0.5 / WAVES_AMOUNT
    endglobals

    private struct Data
        timer durationTimer
        timer intervalTimer
        Unit target
        effect targetEffect
    endstruct

    //! runtextmacro Scope("Cooldown")
        globals
            private constant real Cooldown_DURATION = 100.
        endglobals

        private struct Cooldown_Data
            Unit caster
            timer durationTimer
        endstruct

        private function Cooldown_Ending takes Unit caster, Cooldown_Data d, timer durationTimer returns nothing
            local integer casterId = caster.id
            local unit casterSelf
            call d.destroy()
            call FlushAttachedIntegerById( casterId, Cooldown_SCOPE_ID )
            //! runtextmacro RemoveEventById( "casterId", "Cooldown_EVENT_DEATH" )
            call DestroyTimerWJ( durationTimer )
            if (GetPlayerTechCount(caster.owner, RESEARCH_ID, true) > 0) then
                set casterSelf = caster.self
                call UnitRemoveAbility(casterSelf, SPELL_ID)
                call UnitAddAbility(casterSelf, UPGRADED_SPELL_ID)
                set casterSelf = null
            endif
        endfunction

        private function Cooldown_EndingByTimer takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Cooldown_Data d = GetAttachedInteger(durationTimer, Cooldown_SCOPE_ID)
            call Cooldown_Ending(d.caster, d, durationTimer)
            set durationTimer = null
        endfunction

        public function Cooldown_Death takes Unit caster returns nothing
            local Cooldown_Data d = GetAttachedIntegerById( caster.id, Cooldown_SCOPE_ID )
            if (d != NULL) then
                call Cooldown_Ending( caster, d, d.durationTimer )
            endif
        endfunction

        private function Cooldown_Death_Event takes nothing returns nothing
            call Cooldown_Death( DYING_UNIT )
        endfunction

        public function Cooldown_ResearchFinish takes player researchingUnitOwner returns nothing
            local Unit townHall = GetPlayerTownHall( researchingUnitOwner )
            local unit townHallSelf
            if (GetAttachedIntegerById(townHall.id, Cooldown_SCOPE_ID) == NULL) then
                set townHallSelf = townHall.self
                call UnitRemoveAbility(townHallSelf, SPELL_ID)
                call UnitAddAbility(townHallSelf, UPGRADED_SPELL_ID)
                set townHallSelf = null
            endif
        endfunction

        public function Cooldown_Start takes Unit caster returns nothing
            local integer casterId = caster.id
            local timer durationTimer = CreateTimerWJ()
            local Cooldown_Data d = Cooldown_Data.create()
            set d.caster = caster
            set d.durationTimer = durationTimer
            call AttachIntegerById( casterId, Cooldown_SCOPE_ID, d )
            //! runtextmacro AddEventById( "casterId", "Cooldown_EVENT_DEATH" )
            call AttachInteger( durationTimer, Cooldown_SCOPE_ID, d )
            call TimerStart( durationTimer, Cooldown_DURATION, false, function Cooldown_EndingByTimer )
            set durationTimer = null
        endfunction

        public function Cooldown_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "Cooldown_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Cooldown_Death_Event" )
        endfunction
    //! runtextmacro Endscope()

    private function Ending takes Data d, timer durationTimer, Unit target returns nothing
        local timer intervalTimer = d.intervalTimer
        local effect targetEffect = d.targetEffect
        local integer targetId = target.id
        call d.destroy()
        call FlushAttachedInteger( durationTimer, FeelingOfSecurity_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        call FlushAttachedInteger( intervalTimer, FeelingOfSecurity_SCOPE_ID )
        call DestroyTimerWJ( intervalTimer )
        set intervalTimer = null
        call FlushAttachedIntegerById( targetId, FeelingOfSecurity_SCOPE_ID )
        //! runtextmacro RemoveEventById( "targetId", "EVENT_DAMAGE" )
        //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        //! runtextmacro RemoveEventById( "targetId", "EVENT_DISPEL" )
        call DestroyEffectWJ( targetEffect )
        set targetEffect = null
        call RemoveUnitMagicImmunity(target)
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, FeelingOfSecurity_SCOPE_ID)
        call Ending(d, durationTimer, d.target)
        set durationTimer = null
    endfunction

    public function Dispel takes Unit target returns nothing
        local Data d = GetAttachedIntegerById(target.id, FeelingOfSecurity_SCOPE_ID)
        if ( d != NULL ) then
            call Ending( d, d.durationTimer, target )
        endif
    endfunction

    private function Dispel_Event takes nothing returns nothing
        call Dispel( TRIGGER_UNIT )
    endfunction

    public function Damage takes Unit target returns nothing
        call Dispel( target )
    endfunction

    private function Damage_Event takes nothing returns nothing
        call Damage( TRIGGER_UNIT )
    endfunction

    public function Death takes Unit target returns nothing
        call Dispel( target )
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function Heal takes nothing returns nothing
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, FeelingOfSecurity_SCOPE_ID)
        local Unit target = d.target
        local unit targetSelf = target.self
        set intervalTimer = null
        call HealUnitBySpell( target, RELATIVE_REFRESHED_LIFE_PER_INTERVAL * GetUnitState( targetSelf, UNIT_STATE_MAX_LIFE ) )
        call AddUnitState( targetSelf, UNIT_STATE_MANA, RELATIVE_REFRESHED_MANA_PER_INTERVAL * GetUnitState( targetSelf, UNIT_STATE_MAX_MANA ) )
        set targetSelf = null
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local Data d = Data.create()
        local timer durationTimer = CreateTimerWJ()
        local timer intervalTimer = CreateTimerWJ()
        local integer targetId = target.id
        set d.durationTimer = durationTimer
        set d.intervalTimer = intervalTimer
        set d.target = target
        set d.targetEffect = AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, target.self, TARGET_EFFECT_ATTACHMENT_POINT )
        call AttachInteger( durationTimer, FeelingOfSecurity_SCOPE_ID, d )
        call AttachInteger( intervalTimer, FeelingOfSecurity_SCOPE_ID, d )
        call AttachIntegerById( targetId, FeelingOfSecurity_SCOPE_ID, d )
        //! runtextmacro AddEventById( "targetId", "EVENT_DAMAGE" )
        //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
        //! runtextmacro AddEventById( "targetId", "EVENT_DISPEL" )
        call TimerStart( intervalTimer, INTERVAL, true, function Heal )
        set intervalTimer = null
        call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
        set durationTimer = null
        if (GetPlayerTechCount(caster.owner, RESEARCH_ID, true) == 0) then
            call Cooldown_Cooldown_Start(caster)
        endif
        call AddUnitMagicImmunity(target)
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    private function Init_AddEvents takes nothing returns nothing
        //! runtextmacro AddEventById( "SPELL_ID", "EVENT_CAST" )
        //! runtextmacro AddEventById( "UPGRADED_SPELL_ID", "EVENT_CAST" )
    endfunction

    public function Init takes nothing returns nothing
        local ResearchType d

        set d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 350)

        //! runtextmacro CreateEvent( "EVENT_CAST", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY", "0", "function Damage_Event" )
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_DISPEL", "UnitIsDispelled_EVENT_KEY_POSITIVE", "0", "function Dispel_Event" )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )

        call InitEffectType( TARGET_EFFECT_PATH )

        call Init_AddEvents()

        call Cooldown_Cooldown_Init()
    endfunction
//! runtextmacro Endscope()