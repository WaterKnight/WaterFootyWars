//TESH.scrollpos=0
//TESH.alwaysfold=0
scope UnitPawnsItem
    globals
        public trigger DUMMY_TRIGGER
        private constant real GOLD_RESTORATION_FACTOR = 0.5
    endglobals

    private function Trig takes nothing returns nothing
        local unit sellingUnitSelf = GetSellingUnit()
        local Unit sellingUnit = GetUnit(sellingUnitSelf)
        local player sellingUnitOwner = sellingUnit.owner
        local real sellingUnitX = GetUnitX( sellingUnitSelf )
        local real sellingUnitY = GetUnitY( sellingUnitSelf )
        local real sellingUnitZ = GetUnitZ( sellingUnitSelf, sellingUnitX, sellingUnitY ) + GetUnitImpactZ(sellingUnit)
        local Item soldItem = GetItem(GetSoldItem())
        local integer goldToReturn = R2I( GetItemGoldCost( soldItem ) * GOLD_RESTORATION_FACTOR )
        local texttag goldToReturnTextTag = CreateRisingTextTag( "+" + I2S( goldToReturn ), 0.024, sellingUnitX, sellingUnitY, sellingUnitZ, 80, 255, 204, 0, 255, 0, 3 )
        call AddPlayerState( sellingUnitOwner, PLAYER_STATE_RESOURCE_GOLD, goldToReturn )
        if ( goldToReturnTextTag != null ) then
            call LimitTextTagVisibilityToPlayer( goldToReturnTextTag, sellingUnitOwner )
            set goldToReturnTextTag = null
        endif
        set PlayerChangesLumberAmount_IGNORE_NEXT = true
        set sellingUnitOwner = null
        set sellingUnitSelf = null
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope