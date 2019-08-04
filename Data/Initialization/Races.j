//TESH.scrollpos=56
//TESH.alwaysfold=0
scope Races
    globals
        private integer COUNT
        Race RACE_HUMAN_WJ
        Race RACE_ORC_WJ
        Race RACE_UNDEAD_WJ
        Race RACE_NIGHTELF_WJ
        Race RACE_NAGA_WJ
    endglobals

    private function AddSpawn takes integer whichUnitTypeId, real interval, integer stage, Race whichRace returns nothing
        local UnitType whichUnitType = GetUnitType(whichUnitTypeId)
        call SetUnitTypeRace(whichUnitType, whichRace)
        call SetUnitTypeSpawn(whichUnitType)
        call SetUnitTypeSpawnStage(whichUnitType, stage)
        call SetUnitTypeSpawnTime( whichUnitType, interval )

        call AddUnitTypeResearchTypeId( whichUnitType, UpgradeArmor_RESEARCH_ID )
        call AddUnitTypeResearchTypeId( whichUnitType, UpgradeAttackRate_RESEARCH_ID )
        call AddUnitTypeResearchTypeId( whichUnitType, UpgradeDamage_RESEARCH_ID )
        call AddUnitTypeResearchTypeId( whichUnitType, UpgradePower_RESEARCH_ID )

        call AddUnitTypeResearchTypeId( whichUnitType, CriticalStrikes_RESEARCH_ID )
        call AddUnitTypeResearchTypeId( whichUnitType, MassProduction_RESEARCH_ID )
        call AddUnitTypeResearchTypeId( whichUnitType, RegenerativeHerbs_RESEARCH_ID )
        call AddUnitTypeResearchTypeId( whichUnitType, SparklingScales_RESEARCH_ID )
        call AddUnitTypeResearchTypeId( whichUnitType, UpgradeSpeed_RESEARCH_ID )
    endfunction

    private function AddTownHall takes Race whichRace, integer whichTownHallTypeId, integer whichSpawnTypeId, real interval returns nothing
        local UnitType whichTownHallType = GetUnitType(whichTownHallTypeId)
        call SetRaceTownHall(whichRace, COUNT, whichTownHallType)
        call SetUnitTypeSpawnTypeId(whichTownHallType, whichSpawnTypeId)
        call SetUnitTypeTownHall(whichTownHallType)
        call SetUnitTypeRace(whichTownHallType, whichRace)
        call SetUnitTypeSpawnStage(whichTownHallType, COUNT)
        call AddSpawn(whichSpawnTypeId, interval, COUNT, whichRace)
        set COUNT = COUNT + 1
    endfunction

    public function Init takes nothing returns nothing
        set RACE_HUMAN_WJ = CreateRace()
        set RACE_ORC_WJ = CreateRace()
        set RACE_UNDEAD_WJ = CreateRace()
        set RACE_NIGHTELF_WJ = CreateRace()
        set RACE_NAGA_WJ = CreateRace()
        call SetUnitTypeTownHall(FLAG_UNIT_ID)

        set COUNT = 0
        call SetRaceResearchCenter(RACE_HUMAN_WJ, RESEARCH_CENTER_HUMAN_UNIT_ID)
        call AddTownHall( RACE_HUMAN_WJ, HUMAN_TIER1_UNIT_ID, FOOTMAN_UNIT_ID, 12.125 )
        call AddTownHall( RACE_HUMAN_WJ, HUMAN_TIER2_UNIT_ID, RIFLEMAN_UNIT_ID, 13.175 )
        call AddTownHall( RACE_HUMAN_WJ, HUMAN_TIER3_UNIT_ID, KNIGHT_UNIT_ID, 14.3 )
        call AddTownHall( RACE_HUMAN_WJ, HUMAN_TIER4_UNIT_ID, DRAGON_HAWK_UNIT_ID, 15.5 )

        call AddSpawn( PRIEST_UNIT_ID, 12, 0, RACE_HUMAN_WJ )

        set COUNT = 0
        call SetRaceResearchCenter(RACE_ORC_WJ, RESEARCH_CENTER_ORC_UNIT_ID)
        call AddTownHall( RACE_ORC_WJ, ORC_TIER1_UNIT_ID, HEAD_HUNTER_UNIT_ID, 11 )
        call AddTownHall( RACE_ORC_WJ, ORC_TIER2_UNIT_ID, RAIDER_UNIT_ID, 13 )
        call AddTownHall( RACE_ORC_WJ, ORC_TIER3_UNIT_ID, GRUNT_UNIT_ID, 14 )
        call AddTownHall( RACE_ORC_WJ, ORC_TIER4_UNIT_ID, WIND_RIDER_UNIT_ID, 16 )

        call AddSpawn( SHAMAN_UNIT_ID, 12, 0, RACE_ORC_WJ )

        set COUNT = 0
        call SetRaceResearchCenter(RACE_UNDEAD_WJ, RESEARCH_CENTER_UNDEAD_UNIT_ID)
        call AddTownHall( RACE_UNDEAD_WJ, UNDEAD_TIER1_UNIT_ID, GHOUL_UNIT_ID, 10 )
        call AddTownHall( RACE_UNDEAD_WJ, UNDEAD_TIER2_UNIT_ID, CRYPT_FIEND_UNIT_ID, 14 )
        call AddTownHall( RACE_UNDEAD_WJ, UNDEAD_TIER3_UNIT_ID, GARGOYLE_UNIT_ID, 13.25 )
        call AddTownHall( RACE_UNDEAD_WJ, UNDEAD_TIER4_UNIT_ID, ABOMINATION_UNIT_ID, 16 )

        call AddSpawn( NECROMANCER_UNIT_ID, 12, 0, RACE_UNDEAD_WJ )

        set COUNT = 0
        call SetRaceResearchCenter(RACE_NIGHTELF_WJ, RESEARCH_CENTER_NIGHTELF_UNIT_ID)
        call AddTownHall( RACE_NIGHTELF_WJ, NIGHTELF_TIER1_UNIT_ID, ARCHER_UNIT_ID, 10 )
        call AddTownHall( RACE_NIGHTELF_WJ, NIGHTELF_TIER2_UNIT_ID, HUNTRESS_UNIT_ID, 12 )
        call AddTownHall( RACE_NIGHTELF_WJ, NIGHTELF_TIER3_UNIT_ID, DRYAD_UNIT_ID, 15.25 )
        call AddTownHall( RACE_NIGHTELF_WJ, NIGHTELF_TIER4_UNIT_ID, MOUNTAIN_GIANT_UNIT_ID, 15.5 )

        call AddSpawn( DRUID_OF_THE_TALON_UNIT_ID, 12, 0, RACE_NIGHTELF_WJ )

        set COUNT = 0
        call SetRaceResearchCenter(RACE_NAGA_WJ, RESEARCH_CENTER_NAGA_UNIT_ID)
        call AddTownHall( RACE_NAGA_WJ, NAGA_TIER1_UNIT_ID, MURGUL_REAVER_UNIT_ID, 13 )
        call AddTownHall( RACE_NAGA_WJ, NAGA_TIER2_UNIT_ID, DRAGON_TURTLE_UNIT_ID, 14 )
        call AddTownHall( RACE_NAGA_WJ, NAGA_TIER3_UNIT_ID, MYRMIDON_UNIT_ID, 13.5 )
        call AddTownHall( RACE_NAGA_WJ, NAGA_TIER4_UNIT_ID, SNAP_DRAGON_UNIT_ID, 14.5 )

        call AddSpawn( SIREN_UNIT_ID, 12, 0, RACE_NAGA_WJ )
    endfunction
endscope