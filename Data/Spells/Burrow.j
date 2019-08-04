//TESH.scrollpos=102
//TESH.alwaysfold=0
//! runtextmacro Scope("Burrow")
    globals
        public constant integer ORDER_ID = 852533//OrderId("burrow")
        public constant integer RESEARCH_ID = 'R01C'
        public constant integer SPELL_ID = 'A08D'

        private constant real HEAL_INTERVAL = 1.
        private constant real HEAL_REFRESHED_LIFE_PER_INTERVAL = 3.

        private boolean IGNORE_NEXT_FORM_CHANGE = false
    endglobals

    private struct Data
        Unit caster
        UnitType oldUnitType
        boolean on = false
        timer healTimer
    endstruct

    private function Ending takes Unit caster, Data d returns nothing
        local integer casterId = caster.id
        local timer healTimer = d.healTimer
        local UnitType oldUnitType = d.oldUnitType
        call d.destroy()
        call FlushAttachedIntegerById(casterId, Burrow_SCOPE_ID)
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
        call FlushAttachedInteger(healTimer, Burrow_SCOPE_ID)
        call DestroyTimerWJ(healTimer)
        set healTimer = null
        call SetUnitAnimation(caster.self, "stand")
        call UnitChangeForm(caster, oldUnitType)
    endfunction

    public function Death takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, Burrow_SCOPE_ID)
        if (d != NULL) then
            call Ending(caster, d)
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function Heal takes nothing returns nothing
        local timer healTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(healTimer, Burrow_SCOPE_ID)
        call HealUnitBySpell( d.caster, HEAL_REFRESHED_LIFE_PER_INTERVAL )
    endfunction

    public function EndCast takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, Burrow_SCOPE_ID)
        local UnitType oldUnitType
        if (d.on) then
            call Ending(caster, d)
        else
            set oldUnitType = d.oldUnitType
            set d.oldUnitType = caster.type
            set d.on = true
            call TimerStart(d.healTimer, HEAL_INTERVAL, true, function Heal)
            set IGNORE_NEXT_FORM_CHANGE = true
            call UnitChangeForm(caster, GetUnitType(CRYPT_FIEND_BURROWED_UNIT_ID))
        endif
    endfunction

    private function EndCast_Event takes nothing returns nothing
        call EndCast( CASTER )
    endfunction

    public function FormChange takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, Burrow_SCOPE_ID)
        if (d != NULL) then
            if (IGNORE_NEXT_FORM_CHANGE) then
                set IGNORE_NEXT_FORM_CHANGE = false
            else
                call Ending(caster, d)
            endif
        endif
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local integer casterId = caster.id
        local player casterOwner
        local unit casterSelf
        local Data d = GetAttachedIntegerById(casterId, Burrow_SCOPE_ID)
        local timer healTimer
        if (d == NULL) then
            set casterOwner = caster.owner
            set casterSelf = caster.self
            set healTimer = CreateTimerWJ()
            set d = Data.create()
            set d.caster = caster
            set d.healTimer = healTimer
            set d.oldUnitType = caster.type
            call AttachIntegerById(casterId, Burrow_SCOPE_ID, d)
            //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
            call AttachInteger(healTimer, Burrow_SCOPE_ID, d)
            set healTimer = null
            if (IsUnitSelected(casterSelf, casterOwner)) then
                if (GetLocalPlayer() == casterOwner) then
                    call SelectUnit(casterSelf, false)
                    call SelectUnit(casterSelf, true)
                endif
            endif
            set casterOwner = null
            set casterSelf = null
        endif
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 300)

        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ENDCAST", "SPELL_ID", "UnitFinishesCasting_EVENT_KEY", "0", "function EndCast_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()