//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("SpecialDrops")
    globals
        public constant real DURATION = 30.
    endglobals

    private struct Data
        timer durationTimer
        Item whichItem
    endstruct

    private function Ending takes Data d, Item whichItem returns nothing
        local timer durationTimer = d.durationTimer
        call d.destroy()
        call FlushAttachedInteger( durationTimer, SpecialDrops_SCOPE_ID )
        call FlushAttachedIntegerById( whichItem.id, SpecialDrops_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
    endfunction

    public function Item_Death takes Item whichItem returns nothing
        local Data d = GetAttachedIntegerById( whichItem.id, SpecialDrops_SCOPE_ID )
        if ( d != NULL ) then
            call Ending( d, whichItem )
        endif
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, SpecialDrops_SCOPE_ID)
        call KillItem( d.whichItem.self )
    endfunction

    public function PickUp takes Item whichItem returns nothing
        local Data d = GetAttachedIntegerById( whichItem.id, SpecialDrops_SCOPE_ID )
        call Ending( d, whichItem )
    endfunction

    public function Start takes Item whichItem returns nothing
        local Data d = Data.create()
        local timer durationTimer = CreateTimerWJ()
        set d.durationTimer = durationTimer
        set d.whichItem = whichItem
        call AttachInteger( durationTimer, SpecialDrops_SCOPE_ID, d )
        call AttachIntegerById( whichItem.id, SpecialDrops_SCOPE_ID, d )
        call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
        set durationTimer = null
    endfunction

    public function Source_Death takes boolean deathCausedByEnemy, boolean isDyingUnitStructure, real dyingUnitX, real dyingUnitY returns nothing
        local integer newItemTypeId
        local integer random
        if ( ( deathCausedByEnemy ) and ( isDyingUnitStructure == false ) ) then
            set random = GetRandomInt( 0, 9 )
            if ( random == 0 ) then
                set random = GetRandomInt( 0, 1 )
                if ( random == 0 ) then
                    set newItemTypeId = Runes_RUNES[GetRandomInt(0, Runes_RUNES_COUNT)]
                else
                    set newItemTypeId = GoldCoin_ITEM_ID
                endif
                call Start( CreateItemEx( newItemTypeId, dyingUnitX, dyingUnitY ) )
            endif
        endif
    endfunction

    public function Drop takes Item whichItem returns nothing
        call Start( whichItem )
    endfunction
//! runtextmacro Endscope()