//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("NextHero")
    globals
        private constant integer ORDER_ID = 852046//OrderId( "load" )
        public constant integer SPELL_ID = 'A02U'
    endglobals

    public function SpellEffect takes Unit caster returns nothing
        call Miscellaneous_Altar_Altar_NextHero(caster)
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()