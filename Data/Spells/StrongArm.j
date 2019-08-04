//TESH.scrollpos=53
//TESH.alwaysfold=0
//! runtextmacro Scope("StrongArm")
    globals
        public constant integer RESEARCH_ID = 'R015'
        public constant integer SPELL_ID = 'A088'

        private constant real CHANCE = 0.25
        private constant real DURATION = 2.
        private constant real HERO_DURATION = 1.
    endglobals

    public function DecayEnd takes Unit caster returns nothing
        local integer casterId = caster.id
        if ( GetAttachedBooleanById( casterId, StrongArm_SCOPE_ID ) ) then
            call FlushAttachedBooleanById( casterId, StrongArm_SCOPE_ID )
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DECAY_END" )
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DAMAGE" )
        endif
    endfunction

    private function DecayEnd_Event takes nothing returns nothing
        call DecayEnd( DYING_UNIT )
    endfunction

    private function Damage_Conditions takes Unit caster, Unit target returns boolean
        if ( GetAttachedBooleanById( caster.id, StrongArm_SCOPE_ID ) == false ) then
            return false
        endif
        if ( IsUnitType( target.self, UNIT_TYPE_HERO ) ) then
            return false
        endif
        if ( IsUnitType( target.self, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        if ( IsUnitWard( target ) ) then
            return false
        endif
        if ( GetRandomReal( 0.01, 1 ) > CHANCE ) then
            return false
        endif
        return true
    endfunction

    public function Damage takes Unit caster, Unit target returns nothing
        local real duration
        if ( Damage_Conditions( caster, target ) ) then
            call SetUnitStunTimed( target, 1, DURATION )
        endif
    endfunction

    private function Damage_Event takes nothing returns nothing
        call Damage( DAMAGE_SOURCE, TRIGGER_UNIT )
    endfunction

    public function Learn takes Unit caster returns nothing
        local integer casterId = caster.id
        call AttachBooleanById( casterId, StrongArm_SCOPE_ID, true )
        //! runtextmacro AddEventById( "casterId", "EVENT_DAMAGE" )
        //! runtextmacro AddEventById( "casterId", "EVENT_DECAY_END" )
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 300)

        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY_AS_DAMAGE_SOURCE", "0", "function Damage_Event" )
        //! runtextmacro CreateEvent( "EVENT_DECAY_END", "UnitFinishesDecaying_End_End_EVENT_KEY", "0", "function DecayEnd_Event" )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
        call SetAbilityRequiredResearch( SPELL_ID, RESEARCH_ID )
    endfunction
//! runtextmacro Endscope()