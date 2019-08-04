//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("UpgradeDamage")
    globals
        private constant integer HUMAN_RESEARCH_ID = 'R000'
        private constant integer NAGA_RESEARCH_ID = 'R00J'
        private constant integer NIGHTELF_RESEARCH_ID = 'R00B'
        private constant integer ORC_RESEARCH_ID = 'R002'
        public constant integer RESEARCH_ID = 'R00V'
        private integer array RESEARCH_TYPES_ID
        private integer RESEARCH_TYPES_ID_COUNT = -1
        private constant integer UNDEAD_RESEARCH_ID = 'R004'

        private real array BONUS_RELATIVE_DAMAGE
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
        local real bonusRelativeDamage = BONUS_RELATIVE_DAMAGE[researchLevel]
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
                call AddUnitDamage( enumUnit, GetUnitTypeDamage( enumUnit.type ) * bonusRelativeDamage )
                set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnitSelf == null )
            endloop
        endif
        loop
            exitwhen ( iteration < 0 )
            set specificUnitType = GetResearchTypeIdUnitType( RESEARCH_ID, iteration )
            call AddUnitTypeDamageForPlayer( specificUnitType, researchingUnitOwner, GetUnitTypeDamage( specificUnitType ) * bonusRelativeDamage )
            set iteration = iteration - 1
        endloop
        set iteration = RESEARCH_TYPES_ID_COUNT
        loop
            exitwhen ( iteration < 0 )
            call SetPlayerTechResearched( researchingUnitOwner, RESEARCH_TYPES_ID[iteration], researchLevel )
            set iteration = iteration - 1
        endloop
        call SetPlayerTechResearched( researchingUnitOwner, RESEARCH_ID, researchLevel )
    endfunction

    public function ResearchFinish_Conditions takes integer thisResearchTypeId returns boolean
        local integer iteration = RESEARCH_TYPES_ID_COUNT
        loop
            if (RESEARCH_TYPES_ID[iteration] == thisResearchTypeId) then
                return true
            endif
            set iteration = iteration - 1
            exitwhen (iteration < 0)
        endloop
        return false
    endfunction

    private function InitResearchTypeId takes integer whichResearchTypeId returns nothing
        set RESEARCH_TYPES_ID_COUNT = RESEARCH_TYPES_ID_COUNT + 1
        set RESEARCH_TYPES_ID[RESEARCH_TYPES_ID_COUNT] = whichResearchTypeId
    endfunction

    public function Init takes nothing returns nothing
        local ResearchType d
        local integer iteration

        call InitResearchTypeId(HUMAN_RESEARCH_ID)
        call InitResearchTypeId(ORC_RESEARCH_ID)
        call InitResearchTypeId(UNDEAD_RESEARCH_ID)
        call InitResearchTypeId(NIGHTELF_RESEARCH_ID)
        call InitResearchTypeId(NAGA_RESEARCH_ID)
        set iteration = RESEARCH_TYPES_ID_COUNT
        loop
            exitwhen ( iteration < 0 )
            set d = InitResearchType(RESEARCH_TYPES_ID[iteration])
            call SetResearchTypeGoldCost(d, 1, 200)
            call SetResearchTypeGoldCost(d, 2, 225)
            call SetResearchTypeGoldCost(d, 3, 265)
            call SetResearchTypeGoldCost(d, 4, 300)
            call SetResearchTypeGoldCost(d, 5, 340)
            call SetResearchTypeGoldCost(d, 6, 285)
            call SetResearchTypeGoldCost(d, 7, 335)
            call SetResearchTypeGoldCost(d, 8, 390)
            call SetResearchTypeGoldCost(d, 9, 450)
            set iteration = iteration - 1
        endloop
        call InitResearchType( RESEARCH_ID )

        set BONUS_RELATIVE_DAMAGE[1] = 0.15
        set BONUS_RELATIVE_DAMAGE[2] = 0.15
        set BONUS_RELATIVE_DAMAGE[3] = 0.15
        set BONUS_RELATIVE_DAMAGE[4] = 0.15
        set BONUS_RELATIVE_DAMAGE[5] = 0.15
        set BONUS_RELATIVE_DAMAGE[6] = 0.15
        set BONUS_RELATIVE_DAMAGE[7] = 0.15
        set BONUS_RELATIVE_DAMAGE[8] = 0.15
        set BONUS_RELATIVE_DAMAGE[9] = 0.15
        set ENUM_GROUP = CreateGroupWJ()
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
    endfunction
//! runtextmacro Endscope()