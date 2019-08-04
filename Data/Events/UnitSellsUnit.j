//TESH.scrollpos=0
//TESH.alwaysfold=0
scope UnitSellsUnit
    globals
        public trigger DUMMY_TRIGGER
    endglobals

    scope Executed
        private function Executed_TriggerEvents_Static takes Unit shop, Unit soldUnit, player soldUnitOwner, unit soldUnitSelf, UnitType soldUnitType returns nothing
            local integer soldUnitTypeId = soldUnitType.id
            if (soldUnitTypeId != ShopInformation_UNIT_ID) then
                call Infoboard_Additionboard_Additionboard_SellUnitExecute(soldUnitOwner)
            endif
            if (soldUnitTypeId == UNIT_SHREDDER_RELEASED_UNIT_ID) then
                call ReleaseUnitShredder_SellUnitExecute( soldUnitOwner, shop, soldUnitSelf )
            elseif (soldUnitTypeId == ShopInformation_UNIT_ID) then
                call ShopInformation_SellUnitExecute( shop, soldUnitSelf, soldUnitOwner )
            elseif (soldUnitTypeId == RESERVE_UNIT_ID) then
                call Reserve_SellUnitExecute( soldUnit, soldUnitType )
            endif
        endfunction

        public function Executed_Start takes integer goldCost, Unit shop, Unit soldUnit, player soldUnitOwner, unit soldUnitSelf, UnitType soldUnitType returns nothing
            call AddPlayerState( soldUnitOwner, PLAYER_STATE_RESOURCE_GOLD, -goldCost )

            call Executed_TriggerEvents_Static(shop, soldUnit, soldUnitOwner, soldUnitSelf, soldUnitType)
        endfunction
    endscope

    private function TriggerEvents_Static takes player soldUnitOwner, UnitType soldUnitType returns string
        local string errorMsg = null
        local integer soldUnitTypeId = soldUnitType.id
        if (soldUnitTypeId == WORKER_UNIT_ID) then
            set errorMsg = Worker_SellUnit( soldUnitOwner )
        endif
        return errorMsg
    endfunction

    private function Trig takes nothing returns nothing
        local unit buyingUnit = GetBuyingUnit()
        local string errorMsg = null
        local unit shopSelf = GetSellingUnit()
        local Unit shop = GetUnit(shopSelf)
        local player shopOwner = shop.owner
        local Unit soldUnit
        local unit soldUnitSelf = GetSoldUnit()
        local player soldUnitOwner = GetOwningPlayer(soldUnitSelf)
        local integer soldUnitType = GetUnitType(GetUnitTypeId(soldUnitSelf))
        local integer goldCost = GetPlayerGoldCost(GetUnitTypeGoldCost( soldUnitType ), soldUnitOwner)
        local boolean success
        local integer supplyUsed
        if ( GetPlayerState( soldUnitOwner, PLAYER_STATE_RESOURCE_GOLD ) < goldCost ) then
            set errorMsg = ErrorStrings_TOO_LESS_GOLD
        else
            set supplyUsed = GetUnitTypeSupplyUsed( soldUnitType )
            if ( GetPlayerRaceWJ(soldUnitOwner) == NULL ) then
                set errorMsg = ErrorStrings_NEEDS_RACE
            elseif ( IsUnitEnemy( soldUnitSelf, shopOwner ) ) then
                set errorMsg = ErrorStrings_SHOP_BELONGS_TO_ENEMY
            endif
        endif
        if (errorMsg == null) then
            set errorMsg = TriggerEvents_Static(soldUnitOwner, soldUnitType)
        endif
        set success = (errorMsg == null)
        if ( success ) then
            if (IsUnitTypeCanNotBeInited(soldUnitType)) then
                set soldUnit = NULL
            else
                set soldUnit = InitUnitEx( soldUnitSelf )
            endif

            call Executed_Executed_Start(goldCost, shop, soldUnit, soldUnitOwner, soldUnitSelf, soldUnitType)
        else
            call RemoveUnitWJ( soldUnitSelf )
            call Error( soldUnitOwner, errorMsg )
        endif
        call Shop_UnitSupply_Refresh_Refresh_UnitSell(shop, soldUnitType, success)

        set buyingUnit = null
        set shopOwner = null
        set shopSelf = null
        set soldUnitOwner = null
        set soldUnitSelf = null
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope