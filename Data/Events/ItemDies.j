//TESH.scrollpos=0
//TESH.alwaysfold=0
scope ItemDies
    globals
        public trigger DUMMY_TRIGGER
        public trigger REMOVE_TRIGGER
    endglobals

    private function TriggerEvents_Static takes Item dyingItem, ItemType dyingItemType returns nothing
        call ShiftInventory_Death( dyingItem )

        call SpecialDrops_Item_Death( dyingItem )
    endfunction

    private function Actions takes Item dyingItem returns nothing
        local ItemType dyingItemType = dyingItem.type
        set dyingItem.dead = true

        call TriggerEvents_Static(dyingItem, dyingItemType)

        call RemoveItemTimedEx(dyingItem)
    endfunction

    private function Trig takes nothing returns nothing
        local Item dyingItem = GetItemById(GetHandleId(GetTriggerWidget()))
        call Actions( dyingItem )
    endfunction

    private function RemoveTrig takes nothing returns nothing
        local Item dyingItem = TRIGGER_ITEM
        call Actions( dyingItem )
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
        set REMOVE_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( REMOVE_TRIGGER, function RemoveTrig )
    endfunction
endscope