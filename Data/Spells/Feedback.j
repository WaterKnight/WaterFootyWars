//TESH.scrollpos=70
//TESH.alwaysfold=0
//! runtextmacro Scope("Feedback")
    globals
        public constant integer RESEARCH_ID = 'R01I'
        public constant integer SPELL_ID = 'A086'

        private constant real BURNED_MANA = 10.
        private constant real DAMAGE_FACTOR = 1.
        private constant real HERO_BURNED_MANA = 5.
        private string TARGET_EFFECT_PATH = "Abilities\\Spells\\Human\\Feedback\\ArcaneTowerAttack.mdl"
        private string TARGET_EFFECT_ATTACHMENT_POINT = "origin"
    endglobals

    public function DecayEnd takes Unit caster returns nothing
        local integer casterId = caster.id
        if (GetAttachedBooleanById( casterId, Feedback_SCOPE_ID )) then
            call FlushAttachedBooleanById( casterId, Feedback_SCOPE_ID )
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DAMAGE" )
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DECAY_END" )
        endif
    endfunction

    private function DecayEnd_Event takes nothing returns nothing
        call DecayEnd( TRIGGER_UNIT )
    endfunction

    private function Damage_Conditions takes Unit target returns boolean
        set TEMP_UNIT_SELF = target.self
        if (IsUnitType(TEMP_UNIT_SELF, UNIT_TYPE_MECHANICAL)) then
            return false
        endif
        if (IsUnitType(TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE)) then
            return false
        endif
        if (GetUnitState(TEMP_UNIT_SELF, UNIT_STATE_MANA) <= 0) then
            return false
        endif
        if (GetUnitMagicImmunity(target) > 0) then
            return false
        endif
        return true
    endfunction

    public function Damage takes Unit caster, real damageAmount, Unit target returns real
        local real burnedMana
        local real maxBurnedMana
        local real targetMana
        local unit targetSelf
        if ( GetAttachedBooleanById( caster.id, Feedback_SCOPE_ID ) ) then
            if (Damage_Conditions(target)) then
                set targetSelf = target.self
                set targetMana = GetUnitState(targetSelf, UNIT_STATE_MANA)
                if (IsUnitType( targetSelf, UNIT_TYPE_HERO )) then
                    set maxBurnedMana = HERO_BURNED_MANA
                else
                    set maxBurnedMana = BURNED_MANA
                endif
                set burnedMana = Min( maxBurnedMana, targetMana )
                call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, targetSelf, TARGET_EFFECT_ATTACHMENT_POINT ) )
                call SetUnitState( targetSelf, UNIT_STATE_MANA, targetMana - burnedMana )
                set targetSelf = null
                return (damageAmount + burnedMana * DAMAGE_FACTOR)
            endif
        endif
        return damageAmount
    endfunction

    private function Damage_Event takes nothing returns nothing
        set DAMAGE_AMOUNT = Damage( DAMAGE_SOURCE, DAMAGE_AMOUNT, TRIGGER_UNIT )
    endfunction

    public function Learn takes Unit caster returns nothing
        local integer casterId = caster.id
        call AttachBooleanById( casterId, Feedback_SCOPE_ID, true )
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
        call InitEffectType( TARGET_EFFECT_PATH )
    endfunction
//! runtextmacro Endscope()