//TESH.scrollpos=92
//TESH.alwaysfold=0
//! runtextmacro Scope("UpgradePower")
    globals
        private constant integer HUMAN_RESEARCH_ID = 'R00F'
        private constant integer NAGA_RESEARCH_ID = 'R00L'
        private constant integer NIGHTELF_RESEARCH_ID = 'R00I'
        private constant integer ORC_RESEARCH_ID = 'R00G'
        public constant integer RESEARCH_ID = 'R00Y'
        private integer array RESEARCH_TYPES_ID
        private integer RESEARCH_TYPES_ID_COUNT = -1
        private constant integer UNDEAD_RESEARCH_ID = 'R00H'

        private real array BONUS_RELATIVE_LIFE
        private real array BONUS_RELATIVE_MANA
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
        local real bonusRelativeLife = BONUS_RELATIVE_LIFE[researchLevel]
        local real bonusRelativeMana = BONUS_RELATIVE_MANA[researchLevel]
        local Unit enumUnit
        local unit enumUnitSelf
        local integer iteration = CountResearchTypeIdUnitTypes( RESEARCH_ID )
        local real mana
        local UnitType specificUnitType
        set TEMP_PLAYER = researchingUnitOwner
        call GroupEnumUnitsInRectWJ( ENUM_GROUP, PLAY_RECT, TARGET_CONDITIONS )
        set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
        if ( enumUnitSelf != null ) then
            loop
                set enumUnit = GetUnit(enumUnitSelf)
                set mana = GetUnitMaxMana(enumUnit)
                set specificUnitType = enumUnit.type
                call GroupRemoveUnit( ENUM_GROUP, enumUnitSelf )
                call AddUnitMaxLife( enumUnit, GetUnitTypeMaxLife( specificUnitType ) * bonusRelativeLife )
                if (mana > 0) then
                    call AddUnitMaxMana( enumUnit, mana * bonusRelativeMana )
                endif
                set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnitSelf == null )
            endloop
        endif
        loop
            exitwhen ( iteration < 0 )
            set specificUnitType = GetResearchTypeIdUnitType( RESEARCH_ID, iteration )
            set mana = GetUnitTypeMaxMana(specificUnitType)
            call AddUnitTypeMaxLifeForPlayer( specificUnitType, researchingUnitOwner, GetUnitTypeMaxLife( specificUnitType ) * bonusRelativeLife )
            if (mana > 0) then
                call AddUnitTypeMaxManaForPlayer( specificUnitType, researchingUnitOwner, mana * bonusRelativeMana )
            endif
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
            call SetResearchTypeGoldCost(d, 1, 350)
            call SetResearchTypeGoldCost(d, 2, 400)
            call SetResearchTypeGoldCost(d, 3, 450)
            call SetResearchTypeGoldCost(d, 4, 500)
            call SetResearchTypeGoldCost(d, 5, 550)
            call SetResearchTypeGoldCost(d, 6, 600)
            call SetResearchTypeGoldCost(d, 7, 650)
            call SetResearchTypeGoldCost(d, 8, 700)
            call SetResearchTypeGoldCost(d, 9, 750)
            set iteration = iteration - 1
        endloop
        call InitResearchType( RESEARCH_ID )

        set BONUS_RELATIVE_LIFE[1] = 0.1
        set BONUS_RELATIVE_LIFE[2] = 0.1
        set BONUS_RELATIVE_LIFE[3] = 0.1
        set BONUS_RELATIVE_LIFE[4] = 0.1
        set BONUS_RELATIVE_LIFE[5] = 0.1
        set BONUS_RELATIVE_LIFE[6] = 0.1
        set BONUS_RELATIVE_LIFE[7] = 0.1
        set BONUS_RELATIVE_LIFE[8] = 0.1
        set BONUS_RELATIVE_LIFE[9] = 0.1
        set BONUS_RELATIVE_MANA[1] = 0.1
        set BONUS_RELATIVE_MANA[2] = 0.1
        set BONUS_RELATIVE_MANA[3] = 0.1
        set BONUS_RELATIVE_MANA[4] = 0.1
        set BONUS_RELATIVE_MANA[5] = 0.1
        set BONUS_RELATIVE_MANA[6] = 0.1
        set BONUS_RELATIVE_MANA[7] = 0.1
        set BONUS_RELATIVE_MANA[8] = 0.1
        set BONUS_RELATIVE_MANA[9] = 0.1
        set ENUM_GROUP = CreateGroupWJ()
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
    endfunction
//! runtextmacro Endscope()