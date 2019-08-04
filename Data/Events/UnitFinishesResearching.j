//TESH.scrollpos=18
//TESH.alwaysfold=0
scope UnitFinishesResearching
    globals
        public trigger DUMMY_TRIGGER
    endglobals

    scope LearnRequiredResearchAbilities
        globals
            private group LearnRequiredResearchAbilities_ENUM_GROUP
            private boolexpr LearnRequiredResearchAbilities_TARGET_CONDITIONS
        endglobals

        private function LearnRequiredResearchAbilities_TargetConditions takes nothing returns boolean
            set FILTER_UNIT = GetUnit(GetFilterUnit())
            if (FILTER_UNIT.owner != TEMP_PLAYER) then
                return false
            endif
            if (FILTER_UNIT.type != TEMP_UNIT_TYPE) then
                return false
            endif
            if (IsUnitIllusionWJ(FILTER_UNIT)) then
                return false
            endif
            return true
        endfunction

        public function LearnRequiredResearchAbilities_Start takes player researchingUnitOwner, integer triggerResearchTypeId returns nothing
            local unit enumUnit
            local UnitType enumUnitType
            local integer iteration = CountRequiredResearchAbilities( triggerResearchTypeId )
            local integer iteration2
            local integer specificAbility
            loop
                exitwhen (iteration < 0)
                set iteration2 = CountResearchTypeIdUnitTypes( triggerResearchTypeId )
                set specificAbility = GetRequiredResearchAbility( triggerResearchTypeId, iteration )
                loop
                    exitwhen (iteration2 < 0)
                    set enumUnitType = GetResearchTypeIdUnitType( triggerResearchTypeId, iteration2 )
                    set TEMP_PLAYER = researchingUnitOwner
                    set TEMP_UNIT_TYPE = enumUnitType
                    call GroupEnumUnitsInRect( LearnRequiredResearchAbilities_ENUM_GROUP, WORLD_RECT, LearnRequiredResearchAbilities_TARGET_CONDITIONS )
                    loop
                        set enumUnit = FirstOfGroup( LearnRequiredResearchAbilities_ENUM_GROUP )
                        exitwhen (enumUnit == null)
                        call GroupRemoveUnit( LearnRequiredResearchAbilities_ENUM_GROUP, enumUnit )
                        call UnitLearnsSkill_TriggerEvents( GetUnit( enumUnit ), researchingUnitOwner, enumUnitType, specificAbility )
                    endloop
                    set iteration2 = iteration2 - 1
                endloop
                set iteration = iteration - 1
            endloop
        endfunction

        public function LearnRequiredResearchAbilities_Init takes nothing returns nothing
            set LearnRequiredResearchAbilities_ENUM_GROUP = CreateGroupWJ()
            set LearnRequiredResearchAbilities_TARGET_CONDITIONS = ConditionWJ( function LearnRequiredResearchAbilities_TargetConditions )
        endfunction
    endscope

    private function TriggerEvents_Static takes player researchingUnitOwner, integer researchLevel, integer triggerResearchTypeId returns nothing
        call Infoboard_Additionboard_Additionboard_ResearchFinish(researchingUnitOwner)
        if ( triggerResearchTypeId == BigGun_RESEARCH_ID ) then
            call BigGun_ResearchFinish( researchingUnitOwner )
        elseif ( triggerResearchTypeId == CriticalStrikes_RESEARCH_ID ) then
            call CriticalStrikes_ResearchFinish( researchLevel, researchingUnitOwner )
        elseif ( triggerResearchTypeId == DoubleHead_RESEARCH_ID ) then
            call DoubleHead_ResearchFinish( researchingUnitOwner )
        elseif ( triggerResearchTypeId == FeelingOfSecurity_RESEARCH_ID ) then
            call FeelingOfSecurity_Cooldown_Cooldown_ResearchFinish( researchingUnitOwner )
        elseif ( triggerResearchTypeId == ImprovedRaiseDead_RESEARCH_ID ) then
            call ImprovedRaiseDead_ResearchFinish( researchLevel, researchingUnitOwner )
        elseif ( triggerResearchTypeId == MassProduction_RESEARCH_ID ) then
            call MassProduction_ResearchFinish( researchLevel, researchingUnitOwner )
        elseif ( triggerResearchTypeId == RegenerativeHerbs_RESEARCH_ID ) then
            call RegenerativeHerbs_ResearchFinish( researchLevel, researchingUnitOwner )
        elseif ( triggerResearchTypeId == ShiftInventory_RESEARCH_ID ) then
            call ShiftInventory_ResearchFinish( researchingUnitOwner )
        elseif ( triggerResearchTypeId == SparklingScales_RESEARCH_ID ) then
            call SparklingScales_ResearchFinish( researchLevel, researchingUnitOwner )
        elseif ( UpgradeArmor_ResearchFinish_Conditions(triggerResearchTypeId) ) then
            call UpgradeArmor_ResearchFinish( researchLevel, researchingUnitOwner )
        elseif ( UpgradeAttackRate_ResearchFinish_Conditions(triggerResearchTypeId) ) then
            call UpgradeAttackRate_ResearchFinish( researchLevel, researchingUnitOwner )
        elseif ( UpgradeDamage_ResearchFinish_Conditions(triggerResearchTypeId) ) then
            call UpgradeDamage_ResearchFinish( researchLevel, researchingUnitOwner )
        elseif ( UpgradePower_ResearchFinish_Conditions(triggerResearchTypeId) ) then
            call UpgradePower_ResearchFinish( researchLevel, researchingUnitOwner )
        elseif ( triggerResearchTypeId == UpgradeSpeed_RESEARCH_ID ) then
            call UpgradeSpeed_ResearchFinish( researchLevel, researchingUnitOwner )
        endif

        call LearnRequiredResearchAbilities_LearnRequiredResearchAbilities_Start( researchingUnitOwner, triggerResearchTypeId )
    endfunction

    private function Trig takes nothing returns nothing
        local Unit researchingUnit = GetUnit(GetResearchingUnit())
        local player researchingUnitOwner = researchingUnit.owner
        local integer researchTypeId = GetResearched()
        local integer researchLevel = GetPlayerTechCount( researchingUnitOwner, researchTypeId, true )

        call TriggerEvents_Static(researchingUnitOwner, researchLevel, researchTypeId)

        set researchingUnitOwner = null
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
        call LearnRequiredResearchAbilities_LearnRequiredResearchAbilities_Init()
    endfunction
endscope