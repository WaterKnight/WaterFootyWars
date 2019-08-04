//TESH.scrollpos=30
//TESH.alwaysfold=0
//! runtextmacro Scope("Fertilizer")
    globals
        public constant integer SPELL_ID = 'A01S'

        private real array BONUS_ARMOR
        private real array BONUS_SPEED
    endglobals

    private struct Data
        integer abilityLevel
    endstruct

    public function Learn takes Unit caster returns nothing
        local integer abilityLevel = GetUnitAbilityLevel(caster.self, SPELL_ID)
        local integer casterId = caster.id
        local Data d = GetAttachedIntegerById(casterId, Fertilizer_SCOPE_ID)
        local boolean isNew = (d == NULL)
        local integer oldAbilityLevel
        if (isNew) then
            call AttachIntegerById(casterId, Fertilizer_SCOPE_ID, d)
        else
            set oldAbilityLevel = d.abilityLevel
        endif
        set d.abilityLevel = abilityLevel
        if (isNew) then
            call AddUnitArmorBonus( caster, BONUS_ARMOR[abilityLevel] )
            call AddUnitSpeedBonus( caster, BONUS_SPEED[abilityLevel] )
        else
            call AddUnitArmorBonus( caster, BONUS_ARMOR[abilityLevel] - BONUS_ARMOR[oldAbilityLevel] )
            call AddUnitSpeedBonus( caster, BONUS_SPEED[abilityLevel] - BONUS_SPEED[oldAbilityLevel] )
        endif
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        set BONUS_ARMOR[1] = 2
        set BONUS_ARMOR[2] = 3
        set BONUS_ARMOR[3] = 4
        set BONUS_ARMOR[4] = 5
        set BONUS_ARMOR[5] = 6
        set BONUS_SPEED[1] = 30
        set BONUS_SPEED[2] = 30
        set BONUS_SPEED[3] = 30
        set BONUS_SPEED[4] = 30
        set BONUS_SPEED[5] = 30
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
    endfunction
//! runtextmacro Endscope()