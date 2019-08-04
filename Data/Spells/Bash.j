//TESH.scrollpos=123
//TESH.alwaysfold=0
//! runtextmacro Scope("Bash")
    //! runtextmacro Scope("Zombie")
        globals
            public constant integer Zombie_SPELL_ID = 'A00X'

            private constant real Zombie_CHANCE = 0.25
            private constant real Zombie_DURATION = 2.
            private constant real Zombie_HERO_DURATION = 1.
        endglobals

        public function Zombie_Death takes Unit caster returns nothing
            local integer casterId
            if ( GetUnitAbilityLevel( caster.self, Zombie_SPELL_ID ) > 0 ) then
                set casterId = caster.id
                //! runtextmacro RemoveEventById( "casterId", "Zombie_EVENT_DEATH" )
                //! runtextmacro RemoveEventById( "casterId", "Zombie_EVENT_DAMAGE" )
            endif
        endfunction

        private function Zombie_Death_Event takes nothing returns nothing
            call Zombie_Death( DYING_UNIT )
        endfunction

        private function Zombie_Damage_Conditions takes unit caster, Unit target returns boolean
            if ( GetUnitAbilityLevel( caster, Zombie_SPELL_ID ) <= 0 ) then
                return false
            endif
            if ( IsUnitType( target.self, UNIT_TYPE_STRUCTURE ) ) then
                return false
            endif
            if ( IsUnitWard( target ) ) then
                return false
            endif
            if ( GetRandomReal( 0.01, 1 ) > Zombie_CHANCE ) then
                return false
            endif
            return true
        endfunction

        public function Zombie_Damage takes Unit caster, Unit target returns nothing
            local real duration
            if ( Zombie_Damage_Conditions( caster.self, target ) ) then
                if ( IsUnitType( target.self, UNIT_TYPE_HERO ) ) then
                    set duration = Zombie_HERO_DURATION
                else
                    set duration = Zombie_DURATION
                endif
                call SetUnitStunTimed( target, 1, duration )
            endif
        endfunction

        private function Zombie_Damage_Event takes nothing returns nothing
            call Zombie_Damage( DAMAGE_SOURCE, TRIGGER_UNIT )
        endfunction

        public function Zombie_Learn takes Unit caster returns nothing
            local integer casterId = caster.id
            //! runtextmacro AddEventById( "casterId", "Zombie_EVENT_DAMAGE" )
            //! runtextmacro AddEventById( "casterId", "Zombie_EVENT_DEATH" )
        endfunction

        private function Zombie_Learn_Event takes nothing returns nothing
            call Zombie_Learn( LEARNER )
        endfunction

        public function Zombie_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "Zombie_EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY_AS_DAMAGE_SOURCE", "0", "function Zombie_Damage_Event" )
            //! runtextmacro CreateEvent( "Zombie_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Zombie_Death_Event" )
            call InitAbility( Zombie_SPELL_ID )
            call AddNewEventById( Zombie_SPELL_ID, UnitLearnsSkill_EVENT_KEY, 0, function Zombie_Learn_Event )
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro Scope("OgreBrat")
        globals
            public constant integer OgreBrat_SPELL_ID = 'A02D'

            private constant real OgreBrat_CHANCE = 0.25
            private constant real OgreBrat_DURATION = 2.5
            private constant real OgreBrat_HERO_DURATION = 1.5
        endglobals

        public function OgreBrat_Death takes Unit caster returns nothing
            local integer casterId
            if ( GetUnitAbilityLevel( caster.self, OgreBrat_SPELL_ID ) > 0 ) then
                set casterId = caster.id
                //! runtextmacro RemoveEventById( "casterId", "OgreBrat_EVENT_DAMAGE" )
                //! runtextmacro RemoveEventById( "casterId", "OgreBrat_EVENT_DEATH" )
            endif
        endfunction

        private function OgreBrat_Death_Event takes nothing returns nothing
            call OgreBrat_Death( DYING_UNIT )
        endfunction

        private function OgreBrat_Damage_Conditions takes unit caster, Unit target returns boolean
            if ( GetUnitAbilityLevel( caster, OgreBrat_SPELL_ID ) <= 0 ) then
                return false
            endif
            if ( IsUnitType( target.self, UNIT_TYPE_STRUCTURE ) ) then
                return false
            endif
            if ( IsUnitWard( target ) ) then
                return false
            endif
            if ( GetRandomReal( 0.01, 1 ) > OgreBrat_CHANCE ) then
                return false
            endif
            return true
        endfunction

        public function OgreBrat_Damage takes Unit caster, Unit target returns nothing
            local real duration
            if ( OgreBrat_Damage_Conditions( caster.self, target ) ) then
                if ( IsUnitType( target.self, UNIT_TYPE_HERO ) ) then
                    set duration = OgreBrat_HERO_DURATION
                else
                    set duration = OgreBrat_DURATION
                endif
                call SetUnitStunTimed( target, 1, duration )
            endif
        endfunction

        private function OgreBrat_Damage_Event takes nothing returns nothing
            call OgreBrat_Damage( DAMAGE_SOURCE, TRIGGER_UNIT )
        endfunction

        public function OgreBrat_Learn takes Unit caster returns nothing
            local integer casterId = caster.id
            //! runtextmacro AddEventById( "casterId", "OgreBrat_EVENT_DAMAGE" )
            //! runtextmacro AddEventById( "casterId", "OgreBrat_EVENT_DEATH" )
        endfunction

        private function OgreBrat_Learn_Event takes nothing returns nothing
            call OgreBrat_Learn( LEARNER )
        endfunction

        public function OgreBrat_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "OgreBrat_EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY_AS_DAMAGE_SOURCE", "0", "function OgreBrat_Damage_Event" )
            //! runtextmacro CreateEvent( "OgreBrat_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function OgreBrat_Death_Event" )
            call InitAbility( OgreBrat_SPELL_ID )
            //! runtextmacro AddNewEventById( "OgreBrat_EVENT_LEARN", "OgreBrat_SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function OgreBrat_Learn_Event" )
        endfunction
    //! runtextmacro Endscope()

    public function Init takes nothing returns nothing
        call OgreBrat_OgreBrat_Init()
        call Zombie_Zombie_Init()
    endfunction
//! runtextmacro Endscope()