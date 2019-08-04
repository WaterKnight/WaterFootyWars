//TESH.scrollpos=18
//TESH.alwaysfold=0
//! runtextmacro Scope("SparklingScales")
    globals
        public constant integer RESEARCH_ID = 'R00T'

        private real array BONUS_ARMOR_BY_SPELL
        private group ENUM_GROUP
        private boolexpr TARGET_CONDITIONS
    endglobals

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        set FILTER_UNIT = GetUnit(FILTER_UNIT_SELF)
        if ( FILTER_UNIT.owner != TEMP_PLAYER ) then
            return false
        endif
        if ( IsUnitTypeUsingResearchTypeId( FILTER_UNIT.type, RESEARCH_ID ) == false ) then
            return false
        endif
        return true
    endfunction

    public function ResearchFinish takes integer researchLevel, player researchingUnitOwner returns nothing
        local real bonusRelativeResistance = BONUS_ARMOR_BY_SPELL[researchLevel]
        local unit enumUnit
        local integer iteration = CountResearchTypeIdUnitTypes(RESEARCH_ID)
        local integer specificUnitTypeId
        set TEMP_PLAYER = researchingUnitOwner
        call GroupEnumUnitsInRectWJ( ENUM_GROUP, PLAY_RECT, TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit != null ) then
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                call AddUnitArmorBySpellBonus( GetUnit(enumUnit), bonusRelativeResistance )
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
        loop
            exitwhen ( iteration < 0 )
            call AddUnitTypeArmorBySpellForPlayer( GetResearchTypeIdUnitType(RESEARCH_ID, iteration), researchingUnitOwner, bonusRelativeResistance )
            set iteration = iteration - 1
        endloop
    endfunction

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 800)
        call SetResearchTypeGoldCost(d, 2, 800)

        set ENUM_GROUP = CreateGroupWJ()
        set BONUS_ARMOR_BY_SPELL[1] = 0.1
        set BONUS_ARMOR_BY_SPELL[2] = 0.1
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
    endfunction
//! runtextmacro Endscope()