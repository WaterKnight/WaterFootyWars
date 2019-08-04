//TESH.scrollpos=76
//TESH.alwaysfold=0
//! runtextmacro Scope("UpgradeArmor")
    globals
        private constant integer HUMAN_RESEARCH_ID = 'R001'
        private constant integer NAGA_RESEARCH_ID = 'R00M'
        private constant integer NIGHTELF_RESEARCH_ID = 'R007'
        private constant integer ORC_RESEARCH_ID = 'R003'
        public constant integer RESEARCH_ID = 'R00X'
        private integer array RESEARCH_TYPES_ID
        private integer RESEARCH_TYPES_ID_COUNT = -1
        private constant integer UNDEAD_RESEARCH_ID = 'R005'

        private real array BONUS_ARMOR
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
        local real bonusArmor = BONUS_ARMOR[researchLevel]
        local unit enumUnit
        local integer iteration = CountResearchTypeIdUnitTypes( RESEARCH_ID )
        set TEMP_PLAYER = researchingUnitOwner
        call GroupEnumUnitsInRectWJ( ENUM_GROUP, PLAY_RECT, TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit != null ) then
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                call AddUnitArmor( GetUnit(enumUnit), bonusArmor )
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
        loop
            exitwhen ( iteration < 0 )
            call AddUnitTypeArmorForPlayer( GetResearchTypeIdUnitType(RESEARCH_ID, iteration), researchingUnitOwner, bonusArmor )
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

        set BONUS_ARMOR[1] = 1
        set BONUS_ARMOR[2] = 1
        set BONUS_ARMOR[3] = 1
        set BONUS_ARMOR[4] = 1
        set BONUS_ARMOR[5] = 1
        set BONUS_ARMOR[6] = 1
        set BONUS_ARMOR[7] = 1
        set BONUS_ARMOR[8] = 1
        set BONUS_ARMOR[9] = 1
        set ENUM_GROUP = CreateGroupWJ()
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
    endfunction
//! runtextmacro Endscope()