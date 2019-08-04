//TESH.scrollpos=20
//TESH.alwaysfold=0
//! runtextmacro Scope("Neutralization")
    globals
        public constant integer RESEARCH_ID = 'R01H'
        public constant integer SPELL_ID = 'A08A'

        private constant real CHANCE = 0.15
        private constant real BONUS_SUMMONED_DAMAGE = 15.
    endglobals

    public function DecayEnd takes Unit caster returns nothing
        local integer casterId = caster.id
        if (GetAttachedBooleanById( casterId, Neutralization_SCOPE_ID )) then
            call FlushAttachedBooleanById( casterId, Neutralization_SCOPE_ID )
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DAMAGE" )
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DECAY_END" )
        endif
    endfunction

    private function DecayEnd_Event takes nothing returns nothing
        call DecayEnd( TRIGGER_UNIT )
    endfunction

    private function Damage_Conditions takes player casterOwner, Unit target returns boolean
        set TEMP_UNIT_SELF = target.self
        if (IsUnitAlly(TEMP_UNIT_SELF, casterOwner)) then
            return false
        endif
        if (IsUnitType(TEMP_UNIT_SELF, UNIT_TYPE_MECHANICAL)) then
            return false
        endif
        if (IsUnitType(TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE)) then
            return false
        endif
        if (GetUnitMagicImmunity(target) > 0) then
            return false
        endif
        if (GetRandomReal(0.01, 1) > CHANCE) then
            return false
        endif
        return true
    endfunction

    public function Damage takes Unit caster, real damageAmount, Unit target returns real
        if ( GetAttachedBooleanById( caster.id, Neutralization_SCOPE_ID ) ) then
            if (Damage_Conditions(caster.owner, target)) then
                call DispelUnit(target, false, true, true)
                return (damageAmount * BONUS_SUMMONED_DAMAGE)
            endif
        endif
        return damageAmount
    endfunction

    private function Damage_Event takes nothing returns nothing
        set DAMAGE_AMOUNT = Damage( DAMAGE_SOURCE, DAMAGE_AMOUNT, TRIGGER_UNIT )
    endfunction

    public function Learn takes Unit caster returns nothing
        local integer casterId = caster.id
        call AttachBooleanById( casterId, Neutralization_SCOPE_ID, true )
        //! runtextmacro AddEventById( "casterId", "EVENT_DAMAGE" )
        //! runtextmacro AddEventById( "casterId", "EVENT_DECAY_END" )
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 300)

        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY_FOR_UNBLOCKABLE_AS_DAMAGE_SOURCE", "0", "function Damage_Event" )
        //! runtextmacro CreateEvent( "EVENT_DECAY_END", "UnitFinishesDecaying_End_End_EVENT_KEY", "0", "function DecayEnd_Event" )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
        call SetAbilityRequiredResearch( SPELL_ID, RESEARCH_ID )
    endfunction
//! runtextmacro Endscope()