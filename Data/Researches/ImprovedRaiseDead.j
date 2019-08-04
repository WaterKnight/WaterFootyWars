//TESH.scrollpos=1
//TESH.alwaysfold=0
//! runtextmacro Scope("ImprovedRaiseDead")
    globals
        public constant integer RESEARCH_ID = 'R00P'

        private real array BONUS_ARMOR
        private real array BONUS_DAMAGE
        private real array BONUS_LIFE
    endglobals

    public function ResearchFinish takes integer researchLevel, player researchingUnitOwner returns nothing
        local real bonusArmor = BONUS_ARMOR[researchLevel]
        local real bonusDamage = BONUS_DAMAGE[researchLevel]
        local real bonusLife = BONUS_LIFE[researchLevel]
        local integer iteration = CountResearchTypeIdUnitTypes(RESEARCH_ID)
        local UnitType specificUnitType
        loop
            exitwhen ( iteration < 0 )
            set specificUnitType = GetResearchTypeIdUnitType(RESEARCH_ID, iteration)
            call AddUnitTypeArmorForPlayer( specificUnitType, researchingUnitOwner, bonusArmor )
            call AddUnitTypeDamageForPlayer( specificUnitType, researchingUnitOwner, bonusDamage )
            call AddUnitTypeMaxLifeForPlayer( specificUnitType, researchingUnitOwner, bonusLife )
            set iteration = iteration - 1
        endloop
    endfunction

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 350)
        call SetResearchTypeGoldCost(d, 2, 350)

        set BONUS_ARMOR[1] = 1
        set BONUS_ARMOR[2] = 1
        set BONUS_DAMAGE[1] = 5
        set BONUS_DAMAGE[1] = 5
        set BONUS_LIFE[1] = 50
        set BONUS_LIFE[1] = 50
    endfunction
//! runtextmacro Endscope()