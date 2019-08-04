//TESH.scrollpos=21
//TESH.alwaysfold=0
//! runtextmacro Scope("UpgradeSpeed")
    globals
        public constant integer RESEARCH_ID = 'R00C'

        private real array BONUS_RELATIVE_SPEED
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
        local real bonusRelativeSpeed = BONUS_RELATIVE_SPEED[researchLevel]
        local Unit enumUnit
        local unit enumUnitSelf
        local integer iteration = CountResearchTypeIdUnitTypes( RESEARCH_ID )
        local UnitType specificUnitType
        set TEMP_PLAYER = researchingUnitOwner
        call GroupEnumUnitsInRectWJ( ENUM_GROUP, PLAY_RECT, TARGET_CONDITIONS )
        set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
        if ( enumUnitSelf != null ) then
            loop
                set enumUnit = GetUnit(enumUnitSelf)
                call GroupRemoveUnit( ENUM_GROUP, enumUnitSelf )
                call AddUnitSpeed( enumUnit, GetUnitTypeSpeed( GetUnit(enumUnitSelf).type ) * bonusRelativeSpeed )
                set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnitSelf == null )
            endloop
        endif
        loop
            exitwhen ( iteration < 0 )
            set specificUnitType = GetResearchTypeIdUnitType(RESEARCH_ID, iteration )
            call AddUnitTypeSpeedForPlayer( specificUnitType, researchingUnitOwner, GetUnitTypeSpeed( specificUnitType ) * bonusRelativeSpeed )
            set iteration = iteration - 1
        endloop
    endfunction

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType(RESEARCH_ID)
        call SetResearchTypeGoldCost(d, 1, 800)
        call SetResearchTypeGoldCost(d, 2, 800)

        set ENUM_GROUP = CreateGroupWJ()
        set BONUS_RELATIVE_SPEED[1] = 0.2
        set BONUS_RELATIVE_SPEED[2] = 0.4
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
    endfunction
//! runtextmacro Endscope()