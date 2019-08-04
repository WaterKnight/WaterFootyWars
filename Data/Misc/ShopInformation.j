//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("ShopInformation")
    globals
        public constant integer ITEM_ID = 'I01P'
        public constant integer UNIT_ID = 'n02X'
    endglobals

    private function Start takes Unit shop, player whichPlayer, boolean fromItem returns nothing
        local string colorString
        local Shop_ItemSupply_Refresh_Refresh_Data d
        local Shop_UnitSupply_Refresh_Refresh_Data e
        local timer intervalTimer
        local boolean isSet
        local string name
        local integer shopId = shop.id
        local integer iteration = Shop_ItemSupply_Refresh_Refresh_CountShopDatas(shopId)
        local integer specificObjectTypeId
        local boolean uneven
        if ( iteration - 1 * B2I(fromItem) > TABLE_EMPTY ) then
            call DisplayTextTimedWJ( ColorStrings_GOLD + "==============================" + ColorStrings_RESET, 15, whichPlayer )
            loop
                set d = Shop_ItemSupply_Refresh_Refresh_GetShopDatas(shopId, iteration)
                set specificObjectTypeId = d.whichItemType.id
                set isSet = (GetItemTypeSet(specificObjectTypeId) != NULL)
                set name = GetObjectName( specificObjectTypeId )
                set uneven = (iteration / 2 != iteration / 2.)
                if (specificObjectTypeId != ShopInformation_ITEM_ID) then
                    set intervalTimer = d.intervalTimer
                    if ( uneven ) then
                        set colorString = ColorStrings_FOOTY_DARK
                    else
                        set colorString = ColorStrings_FOOTY_LIGHT
                    endif
                    call DisplayTextTimedWJ( StringIfElse(StringIfElse(ColorStrings_SET_DARK, ColorStrings_SET_LIGHT, uneven), colorString, isSet) + SubString(name, B2I(isSet) * (ColorStrings_START_LENGTH + ColorStrings_BODY_LENGTH), StringLength(name)) + StringIf(StringIfElse(ColorStrings_SET_DARK, ColorStrings_SET_LIGHT, uneven), isSet) + " --> " + I2S( R2I( TimerGetElapsed( intervalTimer ) ) ) + " / " + I2S( R2I( TimerGetTimeout( intervalTimer ) ) ) + " seconds" + ColorStrings_RESET, 15, whichPlayer )
                endif
                set iteration = iteration - 1
                exitwhen ( iteration < TABLE_STARTED )
            endloop
            call DisplayTextTimedWJ( ColorStrings_GOLD + "==============================" + ColorStrings_RESET, 15, whichPlayer )
        endif
        set iteration = Shop_UnitSupply_Refresh_Refresh_CountShopDatas(shopId)
        if ( iteration - 1 * B2I(fromItem == false) > TABLE_EMPTY ) then
            call DisplayTextTimedWJ( ColorStrings_GOLD + "==============================" + ColorStrings_RESET, 15, whichPlayer )
            loop
                set e = Shop_UnitSupply_Refresh_Refresh_GetShopDatas(shopId, iteration)
                set specificObjectTypeId = e.whichUnitType.id
                if (specificObjectTypeId != ShopInformation_UNIT_ID) then
                    set intervalTimer = e.intervalTimer
                    if ( iteration / 2 != iteration / 2. ) then
                        set colorString = ColorStrings_FOOTY_DARK
                    else
                        set colorString = ColorStrings_FOOTY_LIGHT
                    endif
                    call DisplayTextTimedWJ( colorString + GetObjectName( specificObjectTypeId ) + " --> " + I2S( R2I( TimerGetElapsed( intervalTimer ) ) ) + " / " + I2S( R2I( TimerGetTimeout( intervalTimer ) ) ) + " seconds" + ColorStrings_RESET, 15, whichPlayer )
                endif
                set iteration = iteration - 1
                exitwhen ( iteration < TABLE_STARTED )
            endloop
            call DisplayTextTimedWJ( ColorStrings_GOLD + "==============================" + ColorStrings_RESET, 15, whichPlayer )
        endif
        set intervalTimer = null
    endfunction

    public function SellItemExecute takes Unit shop, Item soldItem, player whichPlayer returns nothing
        call RemoveItemEx(soldItem)
        call Start(shop, whichPlayer, true)
    endfunction

    public function SellUnitExecute takes Unit shop, unit soldUnit, player whichPlayer returns nothing
        call RemoveUnitWJ( soldUnit )
        call Start(shop, whichPlayer, false)
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 1)
        call SetItemTypeRefreshIntervalStart(d, 0)

        call InitUnitType( UNIT_ID )
    endfunction
//! runtextmacro Endscope()