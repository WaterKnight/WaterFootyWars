//TESH.scrollpos=10
//TESH.alwaysfold=0
//! runtextmacro Scope("ChooseRandomHero")
    globals
        private constant integer ORDER_ID = 852583//OrderId( "doom" )
        public constant integer SPELL_ID = 'A03N'

        private constant integer GOLD_COST = 500
    endglobals

    public function SpellEffect takes Unit caster returns nothing
        local player casterOwner = caster.owner
        local integer casterOwnerId = GetPlayerId(casterOwner)
        local real x = START_POSITION_X[casterOwnerId]
        local real y = START_POSITION_Y[casterOwnerId]
        local Unit newUnit = Miscellaneous_Altar_Altar_ChooseRandomHero(casterOwner, x, y)
        local unit newUnitSelf = newUnit.self
        call UnitAddItem( newUnitSelf, CreateItemEx( Lollipop_ITEM_ID, 0, 0 ).self )
        set newUnitSelf = null
        call Miscellaneous_Altar_Altar_Ending( caster )
        call PanCameraTimedAfter( casterOwner, x, y, 2 )
        set casterOwner = null
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