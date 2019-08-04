//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("Shop")
    //! runtextmacro Scope("ItemSupply")
        private struct ItemSupply_Data
            integer count
            integer array whichItemTypes[12]
        endstruct

        //! runtextmacro Scope("Refresh")
            public struct Refresh_Data
                integer amount
                timer intervalTimer
                Unit shop
                ItemType whichItemType
            endstruct

            public function Refresh_CountShopDatas takes integer shopId returns integer
                return CountIntegersInTableById(shopId, Refresh_SCOPE_ID)
            endfunction

            public function Refresh_GetShopDatas takes integer shopId, integer index returns Refresh_Data
                return GetIntegerFromTableById(shopId, Refresh_SCOPE_ID, index)
            endfunction

            private function Refresh_Interval takes nothing returns nothing
                local timer intervalTimer = GetExpiredTimer()
                local Refresh_Data d = GetAttachedInteger(intervalTimer, Refresh_SCOPE_ID)
                local integer amount = d.amount + 1
                local ItemType whichItemType = d.whichItemType
                set d.amount = amount
                call AddUnitSoldItemTypeId( d.shop.self, whichItemType.id, amount )
                if ( amount < GetItemTypeMaxCharges( whichItemType ) ) then
                    call TimerStart( intervalTimer, GetItemTypeRefreshInterval(whichItemType), false, function Refresh_Interval )
                endif
                set intervalTimer = null
            endfunction

            private function Refresh_Refresh takes nothing returns nothing
                local timer intervalTimer = GetExpiredTimer()
                local Refresh_Data d = GetAttachedInteger(intervalTimer, Refresh_SCOPE_ID)
                set intervalTimer = null
                call AddUnitSoldItemTypeId( d.shop.self, d.whichItemType.id, d.amount )
            endfunction

            public function Refresh_ItemSell takes Unit shop, ItemType soldItemType, boolean success returns nothing
                local integer amount
                local integer amount2
                local Refresh_Data d
                local Refresh_Data e
                local integer shopId = shop.id
                local integer iteration = CountIntegersInTableById(shopId, Refresh_SCOPE_ID)
                local unit shopSelf = shop.self
                local ItemType specificItemType
                loop
                    set d = GetIntegerFromTableById(shopId, Refresh_SCOPE_ID, iteration)
                    set amount = d.amount
                    set specificItemType = d.whichItemType
                    if (specificItemType == soldItemType) then
                        set e = d
                        if (success) then
                            set amount2 = amount
                            set d.amount = amount2 - 1
                            call AddUnitSoldItemTypeId( shopSelf, soldItemType.id, amount )
                        else
                            //if (GetItemTypeSet(soldItemType.id) == NULL) then
                                //call AddUnitSoldItemTypeIdEx( shopSelf, soldItemType.id, amount + 1, amount + 1 )
                            //else
                                call AddUnitSoldItemTypeId( shopSelf, soldItemType.id, amount + 1 )
                            //endif
                        endif
                    else
                        call AddUnitSoldItemTypeId( shopSelf, specificItemType.id, amount )
                    endif
                    set iteration = iteration - 1
                    exitwhen ( iteration < TABLE_STARTED )
                endloop
                if (success) then
            //        if ( sellingUnitOwner == NEUTRAL_PASSIVE_PLAYER ) then
                        //call AddUnitSoldItemTypeId( shopSelf, soldItemTypeId, amount2 + 1 )
            //        endif
                    if ( amount2 == GetItemTypeMaxCharges(soldItemType) ) then
                        call TimerStart( e.intervalTimer, GetItemTypeRefreshInterval(soldItemType), false, function Refresh_Interval )
                    endif
                else
                    call TimerStart(e.intervalTimer, GetItemTypeRefreshInterval(soldItemType), false, function Refresh_Refresh)
                    //call AddUnitSoldItemTypeId( shopSelf, soldItemType.id, amount2 )
                endif
                set shopSelf = null
            endfunction

            public function Refresh_Start takes Unit shop, integer whichItemTypeId returns nothing
                local Refresh_Data d = Refresh_Data.create()
                local timer intervalTimer = CreateTimerWJ()
                local ItemType whichItemType = GetItemTypeWJ(whichItemTypeId)
                set d.amount = 0
                set d.intervalTimer = intervalTimer
                set d.shop = shop
                set d.whichItemType = whichItemType
                call AttachInteger( intervalTimer, Refresh_SCOPE_ID, d )
                call AddIntegerToTableById( shop.id, Refresh_SCOPE_ID, d )
                call AddUnitSoldItemTypeId( shop.self, whichItemTypeId, 0 )
                call TimerStart( intervalTimer, GetItemTypeRefreshInterval(whichItemType), false, function Refresh_Interval )
                set intervalTimer = null
            endfunction
        //! runtextmacro Endscope()

        public function ItemSupply_Start takes Unit shop, integer shopTypeId returns nothing
            local ItemSupply_Data d = GetAttachedIntegerById( shopTypeId, ItemSupply_SCOPE_ID )
            local integer iteration
            local unit shopSelf
            local integer specificItemTypeId
            if (d != NULL) then
                set iteration = d.count
                set shopSelf = shop.self
                call UnitAddAbility( shopSelf, SELL_ITEMS_SPELL_ID )
                call UnitAddAbility( shopSelf, SELL_UNITS_SPELL_ID )
                set shopSelf = null
                loop
                    call Refresh_Refresh_Start(shop, d.whichItemTypes[iteration])
                    set iteration = iteration - 1
                    exitwhen ( iteration < 0 )
                endloop
            endif
        endfunction

        function AddShopItemSupply takes UnitType shopType, integer whichItemTypeId returns nothing
            local integer count
            local integer shopTypeId = shopType.id
            local ItemSupply_Data d = GetAttachedIntegerById(shopTypeId, ItemSupply_SCOPE_ID)
            if (d == NULL) then
                set count = 0
                set d = ItemSupply_Data.create()
                set d.count = 0
                call AttachIntegerById(shopTypeId, ItemSupply_SCOPE_ID, d)
            else
                set count = d.count + 1
                set d.count = count
            endif
            set d.whichItemTypes[count] = whichItemTypeId
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro Scope("UnitSupply")
        private struct UnitSupply_Data
            integer count
            integer array whichUnitTypes[12]
        endstruct

        //! runtextmacro Scope("Refresh")
            public struct Refresh_Data
                integer amount
                timer intervalTimer
                Unit shop
                UnitType whichUnitType
            endstruct

            public function Refresh_CountShopDatas takes integer shopId returns integer
                return CountIntegersInTableById(shopId, Refresh_SCOPE_ID)
            endfunction

            public function Refresh_GetShopDatas takes integer shopId, integer index returns Refresh_Data
                return GetIntegerFromTableById(shopId, Refresh_SCOPE_ID, index)
            endfunction

            private function Refresh_Interval takes nothing returns nothing
                local timer intervalTimer = GetExpiredTimer()
                local Refresh_Data d = GetAttachedInteger(intervalTimer, Refresh_SCOPE_ID)
                local integer amount = d.amount + 1
                local UnitType whichUnitType = d.whichUnitType
                set d.amount = amount
                call AddUnitSoldUnitTypeId( d.shop.self, whichUnitType.id, amount )
                if ( amount < GetUnitTypeShopMaxCharges( whichUnitType ) ) then
                    call TimerStart( intervalTimer, GetUnitTypeShopRefreshInterval(whichUnitType), false, function Refresh_Interval )
                endif
                set intervalTimer = null
            endfunction

            public function Refresh_UnitSell takes Unit shop, UnitType soldUnitType, boolean success returns nothing
                local integer amount
                local Refresh_Data d
                local integer shopId = shop.id
                local integer supplyCount = CountIntegersInTableById(shopId, Refresh_SCOPE_ID)
                local integer iteration = supplyCount
                loop
                    set d = GetIntegerFromTableById(shopId, Refresh_SCOPE_ID, iteration)
                    exitwhen ( d.whichUnitType == soldUnitType )
                    set iteration = iteration - 1
                endloop
                set amount = d.amount
                if (success) then
                    set d.amount = amount - 1
                    if ( amount == GetUnitTypeShopMaxCharges(soldUnitType) ) then
                        call TimerStart( d.intervalTimer, GetUnitTypeShopRefreshInterval(soldUnitType), false, function Refresh_Interval )
                    endif
                else
                    set iteration = supplyCount
                    loop
                        set d = GetIntegerFromTableById(shopId, Refresh_SCOPE_ID, iteration)
                        call AddUnitSoldUnitTypeId( shop.self, soldUnitType.id, amount )
                        set iteration = iteration - 1
                        exitwhen ( iteration < 0 )
                    endloop
                endif
            endfunction

            public function Refresh_Start takes Unit shop, integer whichUnitTypeId returns nothing
                local Refresh_Data d = Refresh_Data.create()
                local timer intervalTimer = CreateTimerWJ()
                local UnitType whichUnitType = GetUnitType(whichUnitTypeId)
                set d.amount = 0
                set d.intervalTimer = intervalTimer
                set d.shop = shop
                set d.whichUnitType = whichUnitType
                call AttachInteger( intervalTimer, Refresh_SCOPE_ID, d )
                call AddIntegerToTableById( shop.id, Refresh_SCOPE_ID, d )
                call AddUnitSoldUnitTypeId( shop.self, whichUnitTypeId, 0 )
                call TimerStart( intervalTimer, GetUnitTypeShopRefreshInterval(whichUnitType), false, function Refresh_Interval )
                set intervalTimer = null
            endfunction
        //! runtextmacro Endscope()

        public function UnitSupply_Start takes Unit shop, integer shopTypeId returns nothing
            local UnitSupply_Data d = GetAttachedIntegerById( shopTypeId, UnitSupply_SCOPE_ID )
            local integer iteration
            local integer specificUnitTypeId
            if (d != NULL) then
                set iteration = d.count
                call UnitAddAbility( shop.self, SELL_UNITS_SPELL_ID )
                loop
                    call Refresh_Refresh_Start(shop, d.whichUnitTypes[iteration])
                    set iteration = iteration - 1
                    exitwhen ( iteration < 0 )
                endloop
            endif
        endfunction

        function AddShopUnitSupply takes UnitType shopType, integer whichUnitTypeId returns nothing
            local integer count
            local integer shopTypeId = shopType.id
            local UnitSupply_Data d = GetAttachedIntegerById(shopTypeId, UnitSupply_SCOPE_ID)
            if (d == NULL) then
                set count = 0
                set d = UnitSupply_Data.create()
                set d.count = 0
                call AttachIntegerById(shopTypeId, UnitSupply_SCOPE_ID, d)
            else
                set count = d.count + 1
                set d.count = count
            endif
            set d.whichUnitTypes[count] = whichUnitTypeId
        endfunction
    //! runtextmacro Endscope()

    public function FormChange takes Unit shop, integer shopTypeId returns nothing
        call ItemSupply_ItemSupply_Start(shop, shopTypeId)
        call UnitSupply_UnitSupply_Start(shop, shopTypeId)
    endfunction

    public function Appearance takes Unit shop, integer shopTypeId returns nothing
        call ItemSupply_ItemSupply_Start(shop, shopTypeId)
        call UnitSupply_UnitSupply_Start(shop, shopTypeId)
    endfunction
//! runtextmacro Endscope()