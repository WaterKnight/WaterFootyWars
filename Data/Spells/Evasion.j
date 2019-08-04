//TESH.scrollpos=3
//TESH.alwaysfold=0
//! runtextmacro Scope("Evasion")
    globals
        public constant integer BERSERKER_SPELL_ID = 'A06L'
        public constant integer RAIDER_RESEARCH_ID = 'R018'
        public constant integer RAIDER_SPELL_ID = 'A008'
        public constant integer SILVER_TAIL_SPELL_ID = 'A03G'
    endglobals

    private struct Data
        real BONUS_CHANCE
    endstruct

    public function Learn takes Unit caster, integer spellId returns nothing
        local Data d = GetAttachedIntegerById(spellId, Evasion_SCOPE_ID)
        call AddUnitEvasionChance( caster, d.BONUS_CHANCE )
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER, SKILL )
    endfunction

    private function Init_AddEvents takes nothing returns nothing
        //! runtextmacro AddEventById( "BERSERKER_SPELL_ID", "EVENT_LEARN" )
        //! runtextmacro AddEventById( "RAIDER_SPELL_ID", "EVENT_LEARN" )
        //! runtextmacro AddEventById( "SILVER_TAIL_SPELL_ID", "EVENT_LEARN" )
    endfunction

    public function Init takes nothing returns nothing
        local Data d = Data.create()
        local ResearchType e
        //! runtextmacro CreateEvent( "EVENT_LEARN", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
        set d.BONUS_CHANCE = 0.15
        call AttachIntegerById( BERSERKER_SPELL_ID, Evasion_SCOPE_ID, d )
        call InitAbility( BERSERKER_SPELL_ID )

        set e = InitResearchType( RAIDER_RESEARCH_ID )
        call SetResearchTypeGoldCost(e, 1, 300)

        set d = Data.create()
        set d.BONUS_CHANCE = 0.2
        call AttachIntegerById( RAIDER_SPELL_ID, Evasion_SCOPE_ID, d )
        call InitAbility( RAIDER_SPELL_ID )
        call SetAbilityRequiredResearch( RAIDER_SPELL_ID, RAIDER_RESEARCH_ID )

        set d = Data.create()
        set d.BONUS_CHANCE = 0.7
        call AttachIntegerById( SILVER_TAIL_SPELL_ID, Evasion_SCOPE_ID, d )
        call InitAbility( SILVER_TAIL_SPELL_ID )

        call Init_AddEvents()
    endfunction
//! runtextmacro Endscope()