//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("Downgrade")
    globals
        private constant integer ORDER_ID = 852534//OrderId( "unburrow" )
        public constant integer SPELL_ID = 'A036'

        private constant real RESTORED_GOLD_FACTOR = 0.65
    endglobals

    public function SpellEffect2 takes Unit caster returns nothing
        local player casterOwner = caster.owner
        local Unit townHall = GetPlayerTownHall(casterOwner)
        local unit townHallSelf = townHall.self
        local real townHallRelativeLife = GetUnitState( townHallSelf, UNIT_STATE_LIFE ) / GetUnitState( townHallSelf, UNIT_STATE_MAX_LIFE )
        local integer goldSpent = R2I( GetUnitGoldSpentInUpgrades(townHall) * RESTORED_GOLD_FACTOR )
        call RemoveUnitEx( GetPlayerResearchCenter(townHall.owner) )
        call ClearUnitRequestQueue( townHall )
        call RemoveUnitEx( townHall )
        set townHall = CreateUnitEx( casterOwner, FLAG_UNIT_ID, GetStartLocationX( GetPlayerStartLocation( casterOwner ) ), GetStartLocationY( GetPlayerStartLocation( casterOwner ) ), STANDARD_ANGLE )
        set townHallSelf = townHall.self
        call SetPlayerRaceWJ(casterOwner, NULL)
        call SetPlayerTownHall(casterOwner, townHall)
        call PlaySoundFromTypeForPlayer( DOWNGRADE_SOUND_TYPE, casterOwner )
        call SetUnitState( townHallSelf, UNIT_STATE_LIFE, townHallRelativeLife * GetUnitState( townHallSelf, UNIT_STATE_MAX_LIFE ) )
        set townHallSelf = null
        call AddPlayerState( casterOwner, PLAYER_STATE_RESOURCE_GOLD, goldSpent )
        set casterOwner = null
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        call SpellEffect2(caster)
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Order takes player casterOwner, Unit target returns string
        if ( IsUnitType( target.self, UNIT_TYPE_TOWNHALL ) == false ) then
            return ErrorStrings_ONLY_TOWN_HALL
        endif
        if ( casterOwner != target.owner ) then
            return ErrorStrings_ONLY_YOUR_TOWN_HALL
        endif
        if (GetPlayerRaceWJ(casterOwner) == NULL) then
            return ErrorStrings_WHAT_ABOUT_RACE_FIRST
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( ORDERED_UNIT.owner, TARGET_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()