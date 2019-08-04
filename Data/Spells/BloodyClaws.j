//TESH.scrollpos=50
//TESH.alwaysfold=0
//! runtextmacro Scope("BloodyClaws")
    globals
        public constant integer SPELL_ID = 'A00C'

        private constant string CASTER_EFFECT_PATH = "Abilities\\Spells\\Undead\\VampiricAura\\VampiricAuraTarget.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "origin"
        private constant real REFRESHED_LIFE_FACTOR = 0.25
    endglobals

    public function Death takes Unit caster returns nothing
        local integer casterId
        if (GetUnitAbilityLevel(caster.self, SPELL_ID) > 0) then
            set casterId = caster.id
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DAMAGE" )
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function Conditions takes unit caster, Unit target returns boolean
        if ( GetUnitAbilityLevel( caster, SPELL_ID ) <= 0 ) then
            return false
        endif
        if ( IsUnitType( target.self, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        if ( IsUnitType( target.self, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        if ( IsUnitIllusionWJ( target ) ) then
            return false
        endif
        if ( IsUnitWard( target ) ) then
            return false
        endif
        return true
    endfunction

    public function Damage takes Unit caster, real damageAmount, Unit target returns nothing
        local unit casterSelf = caster.self
        if ( Conditions( casterSelf, target ) ) then
            call DestroyEffectWJ( AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, casterSelf, CASTER_EFFECT_ATTACHMENT_POINT ) )
            call HealUnitBySpell( caster, damageAmount * REFRESHED_LIFE_FACTOR )
        endif
        set casterSelf = null
    endfunction

    private function Damage_Event takes nothing returns nothing
        call Damage( DAMAGE_SOURCE, DAMAGE_AMOUNT, TRIGGER_UNIT )
    endfunction

    public function Learn takes Unit caster returns nothing
        local integer casterId = caster.id
        //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
        //! runtextmacro AddEventById( "casterId", "EVENT_DAMAGE" )
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY_UNBLOCKED_AS_DAMAGE_SOURCE", "0", "function Damage_Event" )
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        call InitEffectType( CASTER_EFFECT_PATH )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
    endfunction
//! runtextmacro Endscope()