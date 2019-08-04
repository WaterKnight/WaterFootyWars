//TESH.scrollpos=0
//TESH.alwaysfold=0
scope UnitAcquiresItem
    globals
        public trigger DUMMY_TRIGGER

        public boolean IGNORE_NEXT = false
        public boolean REMOVE_NEXT = false
    endglobals

    private function TriggerEvents_Static takes Item manipulatedItem, integer manipulatedItemTypeId, Unit manipulatingUnit returns nothing
        local item manipulatedItemSelf = manipulatedItem.self
        if ( manipulatedItemTypeId == AstralGauntlets_ITEM_ID ) then
            call AstralGauntlets_PickUp( manipulatingUnit )
        elseif ( manipulatedItemTypeId == BeltOfTheCelt_ITEM_ID ) then
            call BeltOfTheCelt_PickUp( manipulatingUnit )
        elseif ( manipulatedItemTypeId == ChaosSword_ITEM_ID ) then
            call ChaosSword_PickUp( manipulatingUnit )
        elseif ( manipulatedItemTypeId == FenixsFeather_ITEM_ID ) then
            call FenixsFeather_PickUp( manipulatingUnit )
        elseif ( manipulatedItemTypeId == FrostArmor_ITEM_ID ) then
            call FrostArmor_PickUp( manipulatingUnit )
        elseif ( manipulatedItemTypeId == FrozenShard_ITEM_ID ) then
            call FrozenShard_PickUp( manipulatingUnit )
        elseif( manipulatedItemTypeId == GexxoSlippers_ITEM_ID ) then
            call GexxoSlippers_PickUp(manipulatingUnit)
        elseif( manipulatedItemTypeId == GiantAxe_ITEM_ID ) then
            call GiantAxe_PickUp(manipulatingUnit)
        elseif( manipulatedItemTypeId == GloveOfTheBeast_ITEM_ID ) then
            call GloveOfTheBeast_PickUp( manipulatingUnit )
        elseif( manipulatedItemTypeId == GoldCoin_ITEM_ID ) then
            call GoldCoin_PickUp( manipulatedItemSelf, manipulatingUnit )
        elseif( manipulatedItemTypeId == GoldenRing_ITEM_ID ) then
            call GoldenRing_PickUp(manipulatingUnit)
        elseif( manipulatedItemTypeId == HeartOfTheHards_ITEM_ID ) then
            call HeartOfTheHards_PickUp( manipulatingUnit )
        elseif( manipulatedItemTypeId == HeartStone_ITEM_ID ) then
            call HeartStone_PickUp( manipulatingUnit )
        elseif ( manipulatedItemTypeId == JeweledDaggerOfGreed_ITEM_ID ) then
            call JeweledDaggerOfGreed_PickUp( manipulatingUnit )
        elseif ( manipulatedItemTypeId == LifeArmor_ITEM_ID ) then
            call LifeArmor_PickUp( manipulatingUnit )
        elseif( (manipulatedItemTypeId == Lollipop_ITEM_ID) or (manipulatedItemTypeId == Lollipop_MANUFACTURED_ITEM_ID) ) then
            call Lollipop_PickUp( manipulatingUnit )
        elseif( manipulatedItemTypeId == MedaillonOfTheStrivingGod_ITEM_ID ) then
            call MedaillonOfTheStrivingGod_PickUp( manipulatingUnit, manipulatedItem )
        elseif( manipulatedItemTypeId == MightyHammer_ITEM_ID ) then
            call MightyHammer_PickUp( manipulatingUnit )
        elseif( manipulatedItemTypeId == Nethermask_ITEM_ID ) then
            call Nethermask_PickUp( manipulatingUnit, manipulatedItem )
        elseif( manipulatedItemTypeId == OrbOfWisdom_ITEM_ID ) then
            call OrbOfWisdom_PickUp( manipulatingUnit, manipulatedItem )
        elseif ( manipulatedItemTypeId == PrismaticCape_ITEM_ID ) then
            call PrismaticCape_PickUp( manipulatedItem, manipulatingUnit )
        elseif ( manipulatedItemTypeId == RhythmicDrum_ITEM_ID ) then
            call RhythmicDrum_PickUp( manipulatingUnit )
        elseif( manipulatedItemTypeId == RobeOfThePope_ITEM_ID ) then
            call RobeOfThePope_PickUp( manipulatingUnit )
        elseif ( Runes_PickUp_Conditions(manipulatedItemTypeId) ) then
            call Runes_PickUp( manipulatingUnit, manipulatedItemSelf, manipulatedItemTypeId )
        elseif( manipulatedItemTypeId == SpidermanSocks_ITEM_ID ) then
            call SpidermanSocks_PickUp( manipulatingUnit )
        elseif( manipulatedItemTypeId == Trident_ITEM_ID ) then
            call Trident_PickUp( manipulatingUnit )
        elseif ( manipulatedItemTypeId == WindBoots_ITEM_ID ) then
            call WindBoots_PickUp( manipulatingUnit )
        endif
        call Sets_PickUp(manipulatedItem, GetItemTypeWJ(manipulatedItemTypeId), manipulatingUnit)
        set manipulatedItemSelf = null
    endfunction

    private function Trig takes nothing returns nothing
        local Item manipulatedItem
        local item manipulatedItemSelf
        local integer manipulatedItemTypeId
        local Unit manipulatingUnit
        local unit manipulatingUnitSelf
        if (IGNORE_NEXT) then
            set IGNORE_NEXT = false
        else
            set manipulatedItemSelf = GetManipulatedItem()
            if ( REMOVE_NEXT ) then
                set REMOVE_NEXT = false
                set UnitDropsItem_IGNORE_NEXT = true
                call RemoveItemWJ( manipulatedItemSelf )
            else
                set manipulatedItem = GetItem(manipulatedItemSelf)
                set manipulatedItemTypeId = manipulatedItem.type.id
                set manipulatingUnitSelf = GetManipulatingUnit()
                set manipulatingUnit = GetUnit(manipulatingUnitSelf)

                call TriggerEvents_Static(manipulatedItem, manipulatedItemTypeId, manipulatingUnit)

                set manipulatingUnitSelf = null
            endif
            set manipulatedItemSelf = null
        endif
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope