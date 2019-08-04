//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("CriticalStrike")
    //! runtextmacro Scope("Myrmidon")
        globals
            public constant integer Myrmidon_SPELL_ID = 'A04G'

            private constant real Myrmidon_CHANCE = 0.2
        endglobals

        public function Myrmidon_Learn takes Unit caster returns nothing
            call AddUnitCriticalStrike( caster, Myrmidon_CHANCE )
        endfunction

        private function Myrmidon_Learn_Event takes nothing returns nothing
            call Myrmidon_Learn( LEARNER )
        endfunction

        public function Myrmidon_Init takes nothing returns nothing
            call InitAbility( Myrmidon_SPELL_ID )
            //! runtextmacro AddNewEventById( "Myrmidon_EVENT_LEARN", "Myrmidon_SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Myrmidon_Learn_Event" )
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro Scope("TerrorWolf")
        globals
            public constant integer TerrorWolf_SPELL_ID = 'A03I'

            private constant real TerrorWolf_CHANCE = 0.2
        endglobals

        public function TerrorWolf_Learn takes Unit caster returns nothing
            call AddUnitCriticalStrike( caster, TerrorWolf_CHANCE )
        endfunction

        private function TerrorWolf_Learn_Event takes nothing returns nothing
            call TerrorWolf_Learn( LEARNER )
        endfunction

        public function TerrorWolf_Init takes nothing returns nothing
            call InitAbility( TerrorWolf_SPELL_ID )
            //! runtextmacro AddNewEventById( "TerrorWolf_EVENT_LEARN", "TerrorWolf_SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function TerrorWolf_Learn_Event" )
        endfunction
    //! runtextmacro Endscope()

    public function Init takes nothing returns nothing
        call Myrmidon_Myrmidon_Init()
        call TerrorWolf_TerrorWolf_Init()
    endfunction
//! runtextmacro Endscope()