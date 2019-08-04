//TESH.scrollpos=194
//TESH.alwaysfold=0
//! runtextmacro Scope("ShiftInventory")
    globals
        public constant integer DISABLED_ITEM_ID = 'I01K'
        public constant integer ITEM_ID = 'I01L'
        public constant integer RESEARCH_ID = 'R012'
        public constant integer SPELL_ID = 'A07P'

        private boolexpr CASTER_CONDITIONS
        private constant integer COLUMN_AMOUNT = 2
        private group ENUM_GROUP
        public constant integer ROWS_AMOUNT = 3
        private constant integer SHIFTER_OFF_POSITION = 2
        private constant integer SHIFTER_ON_POSITION = 3
    endglobals

    public struct Data
        Item array hiddenItems[ROWS_AMOUNT]
        Item shifterOff
        Item shifterOn
        boolean right = false
    endstruct

    public function Death takes Item whichItem returns nothing
        local integer iteration
        local integer whichItemId = whichItem.id
        local Data d = GetAttachedIntegerById(whichItemId, ShiftInventory_SCOPE_ID)
        if (d != NULL) then
            set iteration = ROWS_AMOUNT
            loop
                if (d.hiddenItems[iteration] == whichItem) then
                    set d.hiddenItems[iteration] = NULL
                endif
                set iteration = iteration - 1
                exitwhen (iteration < 0)
            endloop
            call FlushAttachedIntegerById(whichItemId, ShiftInventory_SCOPE_ID)
        endif
    endfunction

    public function GetCasterData takes Unit caster returns Data
        return GetAttachedIntegerById(caster.id, ShiftInventory_SCOPE_ID)
    endfunction

    private function Shift takes Unit caster, Data d, boolean off returns nothing
        local unit casterSelf = caster.self
        local integer iteration = ROWS_AMOUNT - 1
        local integer offState = B2I(off)
        local integer onState = B2I(off == false)
        local integer rowStart
        local Item specificItem
        local item specificItemSelf
        local Item specificItem2
        local item specificItem2Self
        if (off) then
            set d.right = false
            set specificItem = d.shifterOff
        else
            set d.right = true
            set specificItem = d.shifterOn
        endif
        set specificItemSelf = specificItem.self
        call SetItemDroppable(specificItemSelf, true)
        set UnitDropsItem_IGNORE_NEXT = true
        call SetItemPosition(specificItemSelf, 0, 0)
        call SetItemVisible(specificItemSelf, false)
        if (off) then
            set specificItem = d.shifterOn
        else
            set specificItem = d.shifterOff
        endif
        set specificItemSelf = specificItem.self
        call SetItemVisible(specificItemSelf, true)
        call UnitAddItem(casterSelf, specificItemSelf)
        call SetItemDroppable(specificItemSelf, false)
        call UnitDropItemSlot(casterSelf, specificItemSelf, SHIFTER_OFF_POSITION + onState)
        loop
            set rowStart = iteration * COLUMN_AMOUNT
            set specificItem = GetItem(UnitItemInSlot(casterSelf, rowStart + offState))
            set specificItem2 = d.hiddenItems[iteration]
            set d.hiddenItems[iteration] = specificItem
            if (specificItem != NULL) then
                set specificItemSelf = specificItem.self
                call AttachIntegerById(specificItem.id, ShiftInventory_SCOPE_ID, d)
                set UnitDropsItem_IGNORE_NEXT = true
                call SetItemPosition(specificItemSelf, 0, 0)
                call SetItemVisible(specificItemSelf, false)
            endif
            call UnitDropItemSlot(casterSelf, UnitItemInSlot(casterSelf, rowStart + onState), rowStart + offState)
            if (specificItem2 != NULL) then
                set specificItem2Self = specificItem2.self
                call FlushAttachedIntegerById(specificItem2.id, ShiftInventory_SCOPE_ID)
                call SetItemVisible(specificItem2Self, true)
                set UnitAcquiresItem_IGNORE_NEXT = true
                call UnitAddItem(casterSelf, specificItem2Self)
                call UnitDropItemSlot(casterSelf, specificItem2Self, rowStart + onState)
            endif
            set iteration = iteration - 1
            exitwhen (iteration < 0)
        endloop
        set casterSelf = null
        set specificItemSelf = null
        set specificItem2Self = null
    endfunction

    //! runtextmacro Scope("Off")
        globals
            public constant integer Off_ITEM_ID = 'I01M'
            public constant integer Off_SPELL_ID = 'A07R'
        endglobals

        public function Off_SpellEffect takes Unit caster returns nothing
            call Shift(caster, GetAttachedIntegerById(caster.id, ShiftInventory_SCOPE_ID), true)
        endfunction

        private function Off_SpellEffect_Event takes nothing returns nothing
            call Off_SpellEffect( CASTER )
        endfunction

        public function Off_Init takes nothing returns nothing
            //! runtextmacro AddNewEventById( "Off_EVENT_CAST", "Off_SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function Off_SpellEffect_Event" )
        endfunction
    //! runtextmacro Endscope()

    public function SpellEffect takes Unit caster returns nothing
        call Shift(caster, GetAttachedIntegerById(caster.id, ShiftInventory_SCOPE_ID), false)
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    private function Start takes Unit caster returns nothing
        local unit casterSelf = caster.self
        local Data d = Data.create()
        local integer iteration = ROWS_AMOUNT - 1
        local Item shifterOff = CreateItemEx(Off_Off_ITEM_ID, 0, 0)
        local Item shifterOn = CreateItemEx(ITEM_ID, 0, 0)
        local item shifterOnSelf = shifterOn.self
        loop
            set d.hiddenItems[iteration] = NULL
            set iteration = iteration - 1
            exitwhen (iteration < 0)
        endloop
        set d.shifterOff = shifterOff
        set d.shifterOn = shifterOn
        call AttachIntegerById(caster.id, ShiftInventory_SCOPE_ID, d)
        call SetItemVisible(shifterOff.self, false)
        call UnitAddItem(casterSelf, shifterOnSelf)
        call UnitDropItemSlot(casterSelf, shifterOnSelf, SHIFTER_ON_POSITION)
        set casterSelf = null
        set shifterOnSelf = null
    endfunction

    private function CasterConditions_Single takes Unit caster returns boolean
        if (IsUnitType(caster.self, UNIT_TYPE_HERO) == false) then
            return false
        endif
        if (IsUnitIllusionWJ(caster)) then
            return false
        endif
        return true
    endfunction

    private function CasterConditions takes nothing returns boolean
        return CasterConditions_Single(GetUnit(GetFilterUnit()))
    endfunction

    public function Appearance takes Unit caster returns nothing
        local unit casterSelf
        local item shifter
        if (CasterConditions_Single(caster)) then
            if (GetPlayerTechCount(caster.owner, RESEARCH_ID, true) > 0) then
                call Start(caster)
            else
                set casterSelf = caster.self
                set shifter = CreateItemEx(DISABLED_ITEM_ID, 0, 0).self
                call UnitAddItem(casterSelf, shifter)
                call UnitDropItemSlot(casterSelf, shifter, SHIFTER_ON_POSITION)
                set casterSelf = null
                set shifter = null
            endif
        endif
    endfunction

    public function ResearchFinish takes player casterOwner returns nothing
        local unit enumUnit
        call GroupEnumUnitsOfPlayer(ENUM_GROUP, casterOwner, CASTER_CONDITIONS)
        set enumUnit = FirstOfGroup(ENUM_GROUP)
        if (enumUnit != null) then
            loop
                call GroupRemoveUnit(ENUM_GROUP, enumUnit)
                call RemoveItemEx(GetItem(UnitItemInSlot(enumUnit, SHIFTER_ON_POSITION)))
                call Start(GetUnit(enumUnit))
                set enumUnit = FirstOfGroup(ENUM_GROUP)
                exitwhen (enumUnit == null)
            endloop
        endif
    endfunction

    public function Init takes nothing returns nothing
        local ResearchType d
        local ItemType e

        set d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 500)

        set e = InitItemTypeEx(DISABLED_ITEM_ID)

        set e = InitItemTypeEx(ITEM_ID)

        set CASTER_CONDITIONS = ConditionWJ(function CasterConditions)
        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call Off_Off_Init()
    endfunction
//! runtextmacro Endscope()