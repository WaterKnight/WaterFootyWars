//TESH.scrollpos=33
//TESH.alwaysfold=0
scope UnitSellsItem
    globals
        public trigger DUMMY_TRIGGER
    endglobals

    scope Executed
        private function Executed_TriggerEvents takes Unit shop, player buyingUnitOwner, Item soldItem, ItemType soldItemType returns nothing
            local integer soldItemTypeId = soldItemType.id
            if (soldItemTypeId != ShopInformation_ITEM_ID) then
                call Infoboard_Additionboard_Additionboard_SellItemExecute(buyingUnitOwner, soldItem.self)
            endif
            if (soldItemTypeId == ShopInformation_ITEM_ID) then
                call ShopInformation_SellItemExecute(shop, soldItem, buyingUnitOwner)
            endif
        endfunction

        public function Executed_Start takes Unit shop, player buyingUnitOwner, Item soldItem, ItemType soldItemType returns nothing
            call Executed_TriggerEvents(shop, buyingUnitOwner, soldItem, soldItemType)
        endfunction
    endscope

    private function Trig takes nothing returns nothing
        local unit buyingUnitSelf = GetBuyingUnit()
        local Unit buyingUnit = GetUnit(buyingUnitSelf)
        local player buyingUnitOwner = buyingUnit.owner
        local string errorMsg = null
        local integer lumberCost = 0
        local Item soldItem
        local item soldItemSelf = GetSoldItem()
        local ItemType soldItemType = GetItemTypeWJ(GetItemTypeId(soldItemSelf))
        local integer goldCost = GetPlayerGoldCost(GetItemTypeGoldCost( soldItemType ), buyingUnitOwner)
        local Unit shop = GetUnit(GetSellingUnit())
        local player shopOwner = shop.owner
        local UnitType shopType = shop.type
        local integer specificItemTypeId
        local boolean success
        if ( GetPlayerState( buyingUnitOwner, PLAYER_STATE_RESOURCE_GOLD ) < goldCost ) then
            set errorMsg = ErrorStrings_TOO_LESS_GOLD
        else
            if ( GetPlayerRaceWJ(buyingUnitOwner) == NULL ) then
                set errorMsg = ErrorStrings_NEEDS_RACE
            elseif ( IsUnitEnemy( buyingUnitSelf, shopOwner ) ) then
                set errorMsg = ErrorStrings_SHOP_BELONGS_TO_ENEMY
            endif
        endif
        set success = (errorMsg == null)
        if ( success ) then
            call AddPlayerState( buyingUnitOwner, PLAYER_STATE_RESOURCE_GOLD, -goldCost )
            set soldItem = InitItemEx( soldItemSelf )
            call SetItemGoldCost(soldItem, goldCost)

            call Executed_Executed_Start(shop, buyingUnitOwner, soldItem, soldItemType)
        else
            set UnitAcquiresItem_REMOVE_NEXT = true
            call Error( buyingUnitOwner, errorMsg )
        endif

        call Shop_ItemSupply_Refresh_Refresh_ItemSell(shop, soldItemType, success)

        set buyingUnitOwner = null
        set buyingUnitSelf = null
        set shopOwner = null
        set soldItemSelf = null
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope