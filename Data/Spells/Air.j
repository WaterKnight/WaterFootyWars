//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("Air")
    globals
        public constant integer SPELL_ID = 'A07V'

        public constant real DAMAGE_FACTOR = 1.
    endglobals

    public function Damage takes Unit caster, real damageAmount, Unit target returns real
        if ( IsUnitType( caster.self, UNIT_TYPE_MELEE_ATTACKER ) ) then
            if ( IsUnitType(target.self, UNIT_TYPE_FLYING) ) then
                set damageAmount = damageAmount * DAMAGE_FACTOR
            endif
        endif
        return damageAmount
    endfunction

    public function Init takes nothing returns nothing
        call InitAbility( SPELL_ID )
    endfunction
//! runtextmacro Endscope()