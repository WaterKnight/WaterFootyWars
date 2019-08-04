//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("FreeRoad")
    globals
        public constant integer SPELL_ID = 'A08E'
    endglobals

    public function Learn takes Unit caster returns nothing
        call RemoveUnitPathing(caster)
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
    endfunction
//! runtextmacro Endscope()