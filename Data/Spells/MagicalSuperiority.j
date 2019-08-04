//TESH.scrollpos=6
//TESH.alwaysfold=0
//! runtextmacro Scope("MagicalSuperiority")
    globals
        public constant integer SPELL_ID = 'A06N'

        private constant real BONUS_ARMOR_BY_SPELL = 0.1
        private constant real BONUS_ARMOR_BY_SPELL_PER_MANA = 0.2
        private constant real UPDATE_TIME = 1.
    endglobals

    private struct Data
        real bonusArmorBySpell
        Unit caster
        timer updateTimer
    endstruct

    public function Death takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById( caster.id, MagicalSuperiority_SCOPE_ID )
        if ( d != NULL ) then
            call PauseTimer(d.updateTimer)
            call AddUnitArmorBySpellBonus( caster, -d.bonusArmorBySpell )
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function Update takes nothing returns nothing
        local timer updateTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(updateTimer, MagicalSuperiority_SCOPE_ID)
        local Unit caster = d.caster
        local unit casterSelf = caster.self
        local real bonusArmorBySpell = BONUS_ARMOR_BY_SPELL + RoundTo( GetUnitState( casterSelf, UNIT_STATE_MANA ) / GetUnitState( casterSelf, UNIT_STATE_MAX_MANA ), 0.01 ) * BONUS_ARMOR_BY_SPELL_PER_MANA
        local real bonusArmorBySpellAdd = bonusArmorBySpell - d.bonusArmorBySpell
        set casterSelf = null
        set updateTimer = null
        set d.bonusArmorBySpell = bonusArmorBySpell
        call AddUnitArmorBySpellBonus( caster, bonusArmorBySpellAdd )
    endfunction

    private function Start takes Unit caster, Data d, timer updateTimer returns nothing
        local unit casterSelf = caster.self
        local real bonusArmorBySpell = BONUS_ARMOR_BY_SPELL + RoundTo( GetUnitState( casterSelf, UNIT_STATE_MANA ) / GetUnitState( casterSelf, UNIT_STATE_MAX_MANA ), 0.01 ) * BONUS_ARMOR_BY_SPELL_PER_MANA
        set casterSelf = null
        set d.bonusArmorBySpell = bonusArmorBySpell
        call AddUnitArmorBySpellBonus( caster, bonusArmorBySpell )
        call TimerStart( updateTimer, UPDATE_TIME, true, function Update )
    endfunction

    public function Learn takes Unit caster returns nothing
        local integer casterId = caster.id
        local Data d = Data.create()
        local timer updateTimer = CreateTimerWJ()
        set d.caster = caster
        set d.updateTimer = updateTimer
        call AttachIntegerById(casterId, MagicalSuperiority_SCOPE_ID, d)
        //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
        //! runtextmacro AddEventById( "casterId", "EVENT_REVIVE" )
        call AttachInteger(updateTimer, MagicalSuperiority_SCOPE_ID, d)
        call Start( caster, d, updateTimer )
        set updateTimer = null
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Revive takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, MagicalSuperiority_SCOPE_ID)
        if ( d != NULL ) then
            call Start( caster, d, d.updateTimer )
        endif
    endfunction

    private function Revive_Event takes nothing returns nothing
        call Revive( REVIVING_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_REVIVE", "UnitFinishesReviving_EVENT_KEY", "0", "function Revive_Event" )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
    endfunction
//! runtextmacro Endscope()