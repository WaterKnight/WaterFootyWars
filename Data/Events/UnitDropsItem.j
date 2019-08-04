//TESH.scrollpos=0
//TESH.alwaysfold=0
scope UnitDropsItem
    globals
        public trigger DUMMY_TRIGGER
        public boolean IGNORE_NEXT = false
    endglobals

    private function TriggerEvents_Static takes Item manipulatedItem, integer manipulatedItemTypeId, Unit manipulatingUnit returns nothing
        if ( manipulatedItemTypeId == AstralGauntlets_ITEM_ID ) then
            call AstralGauntlets_Drop( manipulatingUnit )
        elseif ( manipulatedItemTypeId == BeltOfTheCelt_ITEM_ID ) then
            call BeltOfTheCelt_Drop( manipulatingUnit )
        elseif ( manipulatedItemTypeId == ChaosSword_ITEM_ID ) then
            call ChaosSword_Drop( manipulatingUnit )
        elseif ( manipulatedItemTypeId == FenixsFeather_ITEM_ID ) then
            call FenixsFeather_Drop( manipulatingUnit )
        elseif ( manipulatedItemTypeId == FrostArmor_ITEM_ID ) then
            call FrostArmor_Drop( manipulatingUnit )
        elseif ( manipulatedItemTypeId == FrozenShard_ITEM_ID ) then
            call FrozenShard_Drop( manipulatingUnit )
        elseif ( manipulatedItemTypeId == GexxoSlippers_ITEM_ID ) then
            call GexxoSlippers_Drop(manipulatingUnit)
        elseif ( manipulatedItemTypeId == GiantAxe_ITEM_ID ) then
            call GiantAxe_Drop(manipulatingUnit)
        elseif( manipulatedItemTypeId == GloveOfTheBeast_ITEM_ID ) then
            call GloveOfTheBeast_Drop( manipulatingUnit )
        elseif( manipulatedItemTypeId == GoldenRing_ITEM_ID ) then
            call GoldenRing_Drop(manipulatingUnit)
        elseif ( manipulatedItemTypeId == HeartOfTheHards_ITEM_ID ) then
            call HeartOfTheHards_Drop( manipulatingUnit )
        elseif ( manipulatedItemTypeId == HeartStone_ITEM_ID ) then
            call HeartStone_Drop( manipulatingUnit )
        elseif ( manipulatedItemTypeId == JeweledDaggerOfGreed_ITEM_ID ) then
            call JeweledDaggerOfGreed_Drop( manipulatingUnit )
        elseif ( manipulatedItemTypeId == LifeArmor_ITEM_ID ) then
            call LifeArmor_Drop( manipulatingUnit )
        elseif( (manipulatedItemTypeId == Lollipop_ITEM_ID) or (manipulatedItemTypeId == Lollipop_MANUFACTURED_ITEM_ID) ) then
            call Lollipop_Drop( manipulatingUnit )
        elseif( manipulatedItemTypeId == MedaillonOfTheStrivingGod_ITEM_ID ) then
            call MedaillonOfTheStrivingGod_Drop( manipulatingUnit, manipulatedItem )
        elseif( manipulatedItemTypeId == MightyHammer_ITEM_ID ) then
            call MightyHammer_Drop( manipulatingUnit )
        elseif( manipulatedItemTypeId == Nethermask_ITEM_ID ) then
            call Nethermask_Drop( manipulatingUnit, manipulatedItem )
        elseif( manipulatedItemTypeId == OrbOfWisdom_ITEM_ID ) then
            call OrbOfWisdom_Drop( manipulatingUnit, manipulatedItem )
        elseif ( manipulatedItemTypeId == PrismaticCape_ITEM_ID ) then
            call PrismaticCape_Drop( manipulatedItem, manipulatingUnit )
        elseif ( manipulatedItemTypeId == RhythmicDrum_ITEM_ID ) then
            call RhythmicDrum_Drop( manipulatingUnit )
        elseif( manipulatedItemTypeId == RobeOfThePope_ITEM_ID ) then
            call RobeOfThePope_Drop( manipulatingUnit )
        elseif( manipulatedItemTypeId == SpidermanSocks_ITEM_ID ) then
            call SpidermanSocks_Drop( manipulatingUnit )
        elseif( manipulatedItemTypeId == Trident_ITEM_ID ) then
            call Trident_Drop( manipulatingUnit )
        elseif ( manipulatedItemTypeId == WindBoots_ITEM_ID ) then
            call WindBoots_Drop( manipulatingUnit )
        endif
    endfunction

    private function Trig takes nothing returns nothing
        local Item manipulatedItem
        local Unit manipulatingUnit
        local integer manipulatedItemTypeId
        if ( IGNORE_NEXT ) then
            set IGNORE_NEXT = false
        else
            set manipulatedItem = GetItem(GetManipulatedItem())
            set manipulatedItemTypeId = manipulatedItem.type.id
            set manipulatingUnit = GetUnit(GetManipulatingUnit())

            call TriggerEvents_Static(manipulatedItem, manipulatedItemTypeId, manipulatingUnit)
        endif
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope