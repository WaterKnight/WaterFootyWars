//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("Sets")
    globals
        private constant string MANIPULATING_UNIT_EFFECT_PATH = "Abilities\\Spells\\Items\\TomeOfRetraining\\TomeOfRetrainingCaster.mdl"
        private constant string MANIPULATING_UNIT_EFFECT_ATTACHMENT_POINT = "origin"
    endglobals

    public function PickUp takes Item manipulatedItem, ItemType manipulatedItemType, Unit manipulatingUnit returns nothing
        local boolean found
        local boolean array founds
        local integer iteration
        local integer iteration2
        local integer manipulatedItemTypeId = manipulatedItemType.id
        local Set d = GetItemTypeSet(manipulatedItemTypeId)
        local player manipulatingUnitOwner = manipulatingUnit.owner
        local unit manipulatingUnitSelf
        local string s
        local Item specificItem
        local integer specificItemTypeId
        if (d != NULL) then
            set iteration = 3 * ShiftInventory_ROWS_AMOUNT - 1
            loop
                set founds[iteration] = false
                set iteration = iteration - 1
                exitwhen (iteration < 0)
            endloop
            set iteration = CountSetItemTypes(d)
            loop
                set found = false
                set iteration2 = 3 * ShiftInventory_ROWS_AMOUNT - 1
                set specificItemTypeId = GetSetItemType(d, iteration)
                loop
                    set specificItem = GetUnitItemInSlot(manipulatingUnit, iteration2)
                    if (((specificItem.type.id == specificItemTypeId) or ((specificItemTypeId == Lollipop_ITEM_ID) and (specificItem.type.id == Lollipop_MANUFACTURED_ITEM_ID))) and (founds[iteration2] == false)) then
                        set found = true
                        set founds[iteration2] = true
                    endif
                    exitwhen (found)
                    set iteration2 = iteration2 - 1
                    exitwhen (iteration2 < 0)
                endloop
                exitwhen (iteration2 < 0)
                set iteration = iteration - 1
                exitwhen (iteration < 0)
            endloop
            if (iteration < 0) then
                set iteration = CountSetItemTypes(d)
                set manipulatingUnitSelf = manipulatingUnit.self
                set s = ColorStrings_GOLD
                loop
                    set specificItemTypeId = GetSetItemType(d, iteration)
                    set s = s + GetObjectName(specificItemTypeId)
                    if (GetUnitItemOfType(manipulatingUnit, specificItemTypeId) == NULL) then
                        call RemoveItemEx(GetUnitItemOfType(manipulatingUnit, Lollipop_MANUFACTURED_ITEM_ID))
                    else
                        call RemoveItemEx(GetUnitItemOfType(manipulatingUnit, specificItemTypeId))
                    endif
                    set iteration = iteration - 1
                    exitwhen (iteration < 0)
                    set s = s + " + "
                endloop
                set iteration = CountSetProductItemTypes(d)
                set s = s + " --> "
                loop
                    set specificItemTypeId = GetSetProductItemType(d, iteration)
                    set s = s + GetObjectName(specificItemTypeId)
                    call UnitAddItem(manipulatingUnitSelf, CreateItemEx(specificItemTypeId, 0, 0).self)
                    set iteration = iteration - 1
                    exitwhen (iteration < 0)
                    set s = s + " + "
                endloop
                call DisplayTextTimedWJ(s + ColorStrings_RESET, 10, manipulatingUnitOwner)
                call DestroyEffectWJ( AddSpecialEffectTargetWJ( MANIPULATING_UNIT_EFFECT_PATH, manipulatingUnitSelf, MANIPULATING_UNIT_EFFECT_ATTACHMENT_POINT ) )
                set manipulatingUnitSelf = null
            else
                set iteration = 3 * ShiftInventory_ROWS_AMOUNT - 1
                set s = ""
                loop
                    set founds[iteration] = false
                    set iteration = iteration - 1
                    exitwhen (iteration < 0)
                endloop
                set iteration = CountSetItemTypes(d)
                loop
                    set found = false
                    set iteration2 = 3 * ShiftInventory_ROWS_AMOUNT - 1
                    set specificItemTypeId = GetSetItemType(d, iteration)
                    loop
                        set specificItem = GetUnitItemInSlot(manipulatingUnit, iteration2)
                        if ((specificItem.type.id == specificItemTypeId) and (founds[iteration2] == false)) then
                            set found = true
                            set founds[iteration2] = true
                        endif
                        exitwhen (found)
                        set iteration2 = iteration2 - 1
                        exitwhen (iteration2 < 0)
                    endloop
                    if (iteration2 > -1) then
                        set s = s + ColorStrings_GREEN
                    else
                        set s = s + ColorStrings_RED
                    endif
                    set s = s + GetObjectName(specificItemTypeId) + ColorStrings_RESET
                    set iteration = iteration - 1
                    exitwhen (iteration < 0)
                    set s = s + ColorStrings_GOLD + " + " + ColorStrings_RESET
                endloop
                set iteration = CountSetProductItemTypes(d)
                set s = s + ColorStrings_GOLD + " --> "
                loop
                    set specificItemTypeId = GetSetProductItemType(d, iteration)
                    set s = s + GetObjectName(specificItemTypeId)
                    set iteration = iteration - 1
                    exitwhen (iteration < 0)
                    set s = s + " + "
                endloop
                call Error(manipulatingUnitOwner, s + ColorStrings_RESET)
                call AddPlayerState(manipulatingUnitOwner, PLAYER_STATE_RESOURCE_GOLD, GetItemTypeGoldCost(manipulatedItemType))
            endif
        endif
        set manipulatingUnitOwner = null
    endfunction
//! runtextmacro Endscope()