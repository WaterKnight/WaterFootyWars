//TESH.scrollpos=32
//TESH.alwaysfold=0
//! runtextmacro Scope("MysticalAttack")
    globals
        public constant integer SPELL_ID = 'A03R'

        private constant real HERO_LIFE_FACTOR = 0.05
        private constant real HERO_MANA_FACTOR = 0.05
        private constant real LIFE_FACTOR = 0.05
        private constant real MANA_FACTOR = 0.05
    endglobals

    public function DecayEnd takes Unit caster returns nothing
        local integer casterId
        if (GetUnitAbilityLevel(caster.self, SPELL_ID) > 0) then
            set casterId = caster.id
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
        if (GetUnitMagicImmunity(target) > 0) then
            return false
        endif
        return true
    endfunction

    public function Damage takes Unit caster, real damageAmount, Unit target returns real
        local real lifeFactor
        local real manaFactor
        local unit targetSelf
        if ( GetUnitAbilityLevel( caster.self, SPELL_ID ) > 0 ) then
            if (Damage_Conditions(target)) then
                set targetSelf = target.self
                if ( IsUnitType( targetSelf, UNIT_TYPE_HERO ) ) then
                    set lifeFactor = HERO_LIFE_FACTOR
                    set manaFactor = HERO_MANA_FACTOR
                else
                    set lifeFactor = LIFE_FACTOR
                    set manaFactor = MANA_FACTOR
                endif
                set damageAmount = damageAmount + GetUnitMaxLife( target ) * lifeFactor
                call AddUnitState( targetSelf, UNIT_STATE_MANA, -GetUnitState( targetSelf, UNIT_STATE_MAX_MANA ) * manaFactor )
                set targetSelf = null
            endif
        endif
        return damageAmount
    endfunction

    private function Damage_Event takes nothing returns nothing
        set DAMAGE_AMOUNT = Damage( DAMAGE_SOURCE, DAMAGE_AMOUNT, TRIGGER_UNIT )
    endfunction

    public function Learn takes Unit caster returns nothing
        local integer casterId = caster.id
        //! runtextmacro AddEventById( "casterId", "EVENT_DAMAGE" )
        //! runtextmacro AddEventById( "casterId", "EVENT_DECAY_END" )
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY_FOR_UNBLOCKABLE_AS_DAMAGE_SOURCE", "0", "function Damage_Event" )
        //! runtextmacro CreateEvent( "EVENT_DECAY_END", "UnitFinishesDecaying_End_End_EVENT_KEY", "0", "function DecayEnd_Event" )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
    endfunction
//! runtextmacro Endscope()