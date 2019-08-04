//TESH.scrollpos=0
//TESH.alwaysfold=0
scope ItemFinishesDecaying
    globals
        public trigger DUMMY_TRIGGER
    endglobals

    private function TriggerEvents_Static takes Item decayingItem returns nothing
        call Item_RemoveItemTimedEx_RemoveItemTimedEx_Decay(decayingItem)
    endfunction

    private function Trig takes nothing returns nothing
        local Item decayingItem = TRIGGER_ITEM
        local integer decayingItemId = decayingItem.id
        local item decayingItemSelf = decayingItem.self

        call SetItemPosition(decayingItemSelf, 0, 0)

        if (decayingItem.dead == false) then
            set TRIGGER_ITEM = decayingItem
            call RunTrigger(ItemDies_REMOVE_TRIGGER)
        endif

        call TriggerEvents_Static(decayingItem)

        call decayingItem.destroy()
        call FlushAttachedIntegerById(decayingItemId, ITEM_KEY)
        call DisableTrigger(ItemDies_DUMMY_TRIGGER)
        call RemoveItemWJ( decayingItemSelf )
        set decayingItemSelf = null
        call EnableTrigger(ItemDies_DUMMY_TRIGGER)
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope