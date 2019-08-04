//TESH.scrollpos=31
//TESH.alwaysfold=0
//! runtextmacro Scope("AxeMaster")
    globals
        public constant integer SPELL_ID = 'A00H'

        private real array BONUS_CRITICAL_STRIKE
        private real array BONUS_DAMAGE
    endglobals

    private struct Data
        integer abilityLevel
    endstruct

    public function Learn takes Unit caster returns nothing
        local integer abilityLevel = GetUnitAbilityLevel(caster.self, SPELL_ID)
        local integer casterId = caster.id
        local Data d = GetAttachedIntegerById(casterId, AxeMaster_SCOPE_ID)
        local boolean isNew = (d == NULL)
        local integer oldAbilityLevel
        if (isNew) then
            set d = Data.create()
            call AttachIntegerById(casterId, AxeMaster_SCOPE_ID, d)
        else
            set oldAbilityLevel = d.abilityLevel
        endif
        set d.abilityLevel = abilityLevel
        if (isNew) then
            call AddUnitCriticalStrike( caster, BONUS_CRITICAL_STRIKE[abilityLevel] )
            call AddUnitDamageBonus( caster, BONUS_DAMAGE[abilityLevel] )
        else
            call AddUnitCriticalStrike( caster, BONUS_CRITICAL_STRIKE[abilityLevel] - BONUS_CRITICAL_STRIKE[oldAbilityLevel] )
            call AddUnitDamageBonus( caster, BONUS_DAMAGE[abilityLevel] - BONUS_DAMAGE[oldAbilityLevel] )
        endif
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        set BONUS_DAMAGE[1] = 3
        set BONUS_DAMAGE[2] = 6
        set BONUS_DAMAGE[3] = 9
        set BONUS_DAMAGE[4] = 12
        set BONUS_DAMAGE[5] = 15
        set BONUS_CRITICAL_STRIKE[1] = 0.2
        set BONUS_CRITICAL_STRIKE[2] = 0.24
        set BONUS_CRITICAL_STRIKE[3] = 0.28
        set BONUS_CRITICAL_STRIKE[4] = 0.32
        set BONUS_CRITICAL_STRIKE[5] = 0.36
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
    endfunction
//! runtextmacro Endscope()