//TESH.scrollpos=129
//TESH.alwaysfold=0
scope UnitDies
    globals
        public trigger DUMMY_TRIGGER

        Unit DYING_UNIT
        Unit KILLING_UNIT
    endglobals

    private function TriggerEvents_Dynamic takes Unit dyingUnit, Unit killingUnit, integer priority returns nothing
        local integer dyingUnitId = dyingUnit.id
        local integer iteration = CountEventsById( dyingUnitId, UnitDies_EVENT_KEY, priority )
        local integer killingUnitId = killingUnit.id
        loop
            exitwhen ( iteration < TABLE_STARTED )
            set DYING_UNIT = dyingUnit
            set KILLING_UNIT = killingUnit
            call RunTrigger( GetEventsById(dyingUnitId, UnitDies_EVENT_KEY, priority, iteration) )
            set iteration = iteration - 1
        endloop
        set iteration = CountEventsById( killingUnitId, UnitDies_EVENT_KEY_AS_KILLING_UNIT, priority )
        loop
            exitwhen ( iteration < TABLE_STARTED )
            set DYING_UNIT = dyingUnit
            set KILLING_UNIT = killingUnit
            call RunTrigger( GetEventsById(killingUnitId, UnitDies_EVENT_KEY_AS_KILLING_UNIT, priority, iteration) )
            set iteration = iteration - 1
        endloop
    endfunction

    private function TriggerEvents_Static takes boolean deathCausedByEnemy, Unit dyingUnit, player dyingUnitOwner, real dyingUnitX, real dyingUnitY, real dyingUnitZ, Unit killingUnit, player killingUnitOwner, integer priority returns nothing
        if (priority == 0) then
            //! runtextmacro AddEventStaticLine("CamouflageSuit", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("ElectroNet", "EVENT_DEATH", "Death( dyingUnit, dyingUnitX, dyingUnitY, dyingUnitZ )")
            //! runtextmacro AddEventStaticLine("ElectroNet_Buff_Buff", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("ElixirOfTheGrowth", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("FlyingSheep", "EVENT_DEATH", "Death( dyingUnit, dyingUnitX, dyingUnitY, dyingUnitZ )")
            //! runtextmacro AddEventStaticLine("FriendshipBracelet_Buff_Buff", "EVENT_DEATH", "Death(dyingUnit)")
            //! runtextmacro AddEventStaticLine("FrostArmor_Slow_Slow", "EVENT_DEATH", "Death(dyingUnit)")
            //! runtextmacro AddEventStaticLine("FrozenShard_Buff_Buff", "EVENT_DEATH", "Death(dyingUnit)")
            //! runtextmacro AddEventStaticLine("HealingPotionBloodOrange", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("HeartOfTheHards", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Lens", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Lens_Target_Target", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("LifeArmor", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("LifeArmor_Target_Target", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("MightyHammer", "EVENT_DEATH", "Death( dyingUnit, dyingUnitX, dyingUnitY, dyingUnitZ )")
            //! runtextmacro AddEventStaticLine("Nethermask_Use_Use", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("PotionOfTheInconspicuousShape", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("ScrollOfRage", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Trident_Knockback_Knockback", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("VolatileManaPotion", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("WindBoots", "EVENT_DEATH", "Death( dyingUnit )")
            //////////////////////////////////////////////////////////////////////////////////////////////////
            //! runtextmacro AddEventStaticLine("AcidStrike", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("AdvertisingGift_Target_Target", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("AttackDerivation", "EVENT_DEATH", "Death( dyingUnit, dyingUnitX, dyingUnitY, dyingUnitZ )")
            //! runtextmacro AddEventStaticLine("Bash_OgreBrat_OgreBrat", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Bash_Zombie_Zombie", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Berserk", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("BloodyClaws", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("BondOfSouls", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("BubbleArmor", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Burrow", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("ChillyPresence", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("ChillyPresence_Target_Target", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("CourageAndHonor", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("CourageAndHonor_Target_Target", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("CripplingWave_Target_Target", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("CrowdPuller", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("CrowdPuller_Target_Target", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("CurseOfTheBloodline", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("DarkCloud", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Defend", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Disarm", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("DivineShield_Target_Target", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("DreadCall", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("EasyPrey", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("EmployHenchman", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Enchant", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("EnergyGap_Heal_Heal", "EVENT_DEATH", "Death( dyingUnit, dyingUnitX, dyingUnitY, dyingUnitZ )")
            //! runtextmacro AddEventStaticLine("EnergyGap_Aura_Aura", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("EnergyGap_Aura_Target_Target", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("FeelingOfSecurity", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("FeelingOfSecurity_Cooldown_Cooldown", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("FieryBoots", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Fireball", "EVENT_DEATH", "Death( dyingUnit, dyingUnitX, dyingUnitY, dyingUnitZ )")
            //! runtextmacro AddEventStaticLine("Frenzy", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("FrostBolt", "EVENT_DEATH", "Death( dyingUnit, dyingUnitX, dyingUnitY, dyingUnitZ )")
            //! runtextmacro AddEventStaticLine("FuneralFeast_Buff_Buff", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("FuneralFeast", "EVENT_CASTER_DEATH", "Caster_Death( dyingUnit, dyingUnitX, dyingUnitY, dyingUnitZ )")
            //! runtextmacro AddEventStaticLine("Fury", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("GhoulFrenzy", "EVENT_CASTER_DEATH", "Caster_Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("GhoulFrenzy", "EVENT_CASTER_DEATH", "Caster_Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("GhoulFrenzy", "EVENT_SOURCE_DEATH", "Source_Death( killingUnit )")
            //! runtextmacro AddEventStaticLine("HammerThrow", "EVENT_DEATH", "Death( dyingUnit, dyingUnitX, dyingUnitY, dyingUnitZ )")
            //! runtextmacro AddEventStaticLine("HammerThrow_Mana_Mana", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("HealingWard", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("IceBall_Buff_Buff", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("IceBall", "EVENT_DEATH", "Death( dyingUnit, dyingUnitX, dyingUnitY, dyingUnitZ )")
            //! runtextmacro AddEventStaticLine("Immolation", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Inspiration", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Kataikaze", "EVENT_CASTER_DEATH", "Caster_Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Kataikaze", "EVENT_TARGET_DEATH", "Target_Death( dyingUnit, dyingUnitX, dyingUnitY, dyingUnitZ )")
            //! runtextmacro AddEventStaticLine("KidneyShot", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("KittyJump_Target_Target", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("LastGrave_Target_Target", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("LayEgg", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("LayEgg_Egg_Egg", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Libertine", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("LifeDrain", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("LifeRegenerationAura", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("LifeRegenerationAura_Target_Target", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("LifeRegenerationAuraNeutral", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("LifeRegenerationAuraNeutral_Target_Target", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("LightOfPurge", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("LinearBoomerang_DrawBack_DrawBack", "EVENT_DEATH", "Death( dyingUnit, dyingUnitX, dyingUnitY, dyingUnitZ )")
            //! runtextmacro AddEventStaticLine("MagicalLariat", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("MagicalSuperiority", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("ManaRegenerationAura", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("ManaRegenerationAura_Target_Target", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("ManaRegenerationAuraNeutral", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("ManaRegenerationAuraNeutral_Target_Target", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("ManaTheft", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Metamorphosis", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("MightAura", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("MightAura_Target_Target", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("MindBreaker", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("NaturalEmbrace", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Net", "EVENT_DEATH", "Death( dyingUnit, dyingUnitX, dyingUnitY, dyingUnitZ )")
            //! runtextmacro AddEventStaticLine("Payday_AttackSilence_Target_Target", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("RapidFire_Buff_Buff", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("RapidFire", "EVENT_CASTER_DEATH", "Caster_Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("RapidFire", "EVENT_SOURCE_DEATH", "Source_Death( killingUnit, killingUnitOwner, dyingUnit )")
            //! runtextmacro AddEventStaticLine("RefillMana", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("RhythmicDrum", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("RhythmicDrum_Target_Target", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Riposte", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Riposte_Target_Target", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Rust", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Sales", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Sales_Target_Target", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("SilverSpores", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Slam", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("SlowPoison", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("SoulVessel", "EVENT_CASTER_DEATH", "Caster_Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("SoulVessel", "EVENT_SOURCE_DEATH", "Source_Death( killingUnit, killingUnitOwner, dyingUnit )")
            //! runtextmacro AddEventStaticLine("SoulVessel_Vessel_Vessel", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("SpellDisconnection", "EVENT_DEATH", "Death( dyingUnit, dyingUnitX, dyingUnitY, dyingUnitZ )")
            //! runtextmacro AddEventStaticLine("Stability", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("SuddenFrost", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("SummonFaust", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("SummonFaust_AttackGraphic_AttackGraphic", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("SummonPeq", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("ThermalFissure_Target_Target", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("ToadReflection", "EVENT_DEATH", "Death( dyingUnit )")
            ////! runtextmacro AddEventStaticLine("TonelessMist", "EVENT_DEATH", "Death( dyingUnit )")
            ////! runtextmacro AddEventStaticLine("TonelessMist_Target_Target", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("UnholyArmor", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("UnholyArmor_Target_Target", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("UtilizationOfRests", "EVENT_CASTER_DEATH", "Caster_Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("UtilizationOfRests_Servant_Servant", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("VioletDefense", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("VividStrikes", "EVENT_DEATH", "Death( dyingUnit )")
            ////! runtextmacro AddEventStaticLine("WhipLash", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Whirlwind", "EVENT_DEATH", "Death( dyingUnit )")
            //////////////////////////////////////////////////////////////////////////////////////////////////
            //! runtextmacro AddEventStaticLine("Grass", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Marble", "EVENT_DEATH", "Death( dyingUnit )")
            //////////////////////////////////////////////////////////////////////////////////////////////////
            //! runtextmacro AddEventStaticLine("Creeps_Market_Market", "EVENT_DEATH", "Death( dyingUnit )")
            //! runtextmacro AddEventStaticLine("Creeps_MercenaryCamp_MercenaryCamp", "EVENT_DEATH", "Death( dyingUnit )")
            //////////////////////////////////////////////////////////////////////////////////////////////////
            //! runtextmacro AddEventStaticLine("Lightning_AddLightningBetweenUnits_AddLightningBetweenUnits_Post", "EVENT_DEATH", "Death(dyingUnit, dyingUnitX, dyingUnitY, dyingUnitZ)")
            //! runtextmacro AddEventStaticLine("UnitRevaluation_RevaluatingUnit", "EVENT_DEATH", "Death(dyingUnit)")
            //////////////////////////////////////////////////////////////////////////////////////////////////
            //! runtextmacro AddEventStaticLine("Unit_Order_ImmediateTimed_ImmediateTimed", "EVENT_DEATH", "Death(dyingUnit)")
            //! runtextmacro AddEventStaticLine("Unit_Order_TargetTimed_TargetTimed", "EVENT_DEATH", "Death(dyingUnit)")
            //! runtextmacro AddEventStaticLine("Upgrade", "EVENT_DEATH", "Death( dyingUnit )")

            //! runtextmacro AddEventStaticLine("Unit_Stun_Thunderbolt_Cancel_Cancel", "EVENT_DEATH", "Death(dyingUnit)")
            //! runtextmacro AddEventStaticLine("Unit_Stun_Timed_Timed", "EVENT_DEATH", "Death(dyingUnit)")
        elseif (priority == 1) then
            //! runtextmacro AddEventStaticLine("Unit_Stun_Type0_Type0", "EVENT_DEATH", "Death(dyingUnit)")
            //! runtextmacro AddEventStaticLine("Unit_Stun_Type1_Type1", "EVENT_DEATH", "Death(dyingUnit)")
            //! runtextmacro AddEventStaticLine("Unit_Stun_Type2_Type2", "EVENT_DEATH", "Death(dyingUnit)")
            //! runtextmacro AddEventStaticLine("Unit_Stun_Type3_Type3", "EVENT_DEATH", "Death(dyingUnit)")
            //! runtextmacro AddEventStaticLine("Unit_Stun_Type4_Type4", "EVENT_DEATH", "Death(dyingUnit)")
            //! runtextmacro AddEventStaticLine("Unit_Stun_Type5_Type5", "EVENT_DEATH", "Death(dyingUnit)")
        endif
    endfunction

    private function TriggerEvents takes boolean deathCausedByEnemy, Unit dyingUnit, player dyingUnitOwner, UnitType dyingUnitType, real dyingUnitX, real dyingUnitY, real dyingUnitZ, boolean isDyingUnitStructure, Unit killingUnit, player killingUnitOwner, UnitType killingUnitType returns nothing
        local integer iteration = 0
        call SetUnitDead(dyingUnit, true)

        loop
            call TriggerEvents_Dynamic(dyingUnit, killingUnit, iteration)
            call TriggerEvents_Static(deathCausedByEnemy, dyingUnit, dyingUnitOwner, dyingUnitX, dyingUnitY, dyingUnitZ, killingUnit, killingUnitOwner, iteration)
            set iteration = iteration + 1
            exitwhen (iteration > 1)
        endloop

        call Cannibalism_Death( dyingUnit, dyingUnitX, dyingUnitY )
        call FuneralFeast_Source_Death( deathCausedByEnemy, killingUnitOwner, dyingUnit, dyingUnitOwner, dyingUnitX, dyingUnitY, dyingUnitZ )
        //////////////////////////////////////////////////////////////////////////////////////////////////
        call MasterWizard_Death(killingUnit, killingUnitOwner)
        call TownHall_Death( dyingUnit, dyingUnitType )
        call UnitRevaluation_Source_Death( deathCausedByEnemy, dyingUnitOwner, isDyingUnitStructure, killingUnit, killingUnitOwner, killingUnitType )
        call Worker_Death( dyingUnitOwner, dyingUnitType )
        //////////////////////////////////////////////////////////////////////////////////////////////////
        call Spawn_Death( dyingUnitOwner, dyingUnitType )
    endfunction

    public function Decay takes Unit dyingUnit, player dyingUnitOwner returns nothing
        local unit dyingUnitSelf = dyingUnit.self
        local real dyingUnitX = GetUnitX(dyingUnitSelf)
        local real dyingUnitY = GetUnitY(dyingUnitSelf)

        call TriggerEvents(false, dyingUnit, dyingUnit.owner, dyingUnit.type, dyingUnitX, dyingUnitY, GetUnitZ(dyingUnitSelf, dyingUnitX, dyingUnitY), IsUnitType(dyingUnitSelf, UNIT_TYPE_STRUCTURE), NULL, null, NULL)

        set dyingUnitSelf = null
    endfunction

    public function BeforeDying takes Unit dyingUnit, Unit killingUnit returns nothing
        local unit dyingUnitSelf = dyingUnit.self
        local real dyingUnitX = GetUnitX(dyingUnitSelf)
        local real dyingUnitY = GetUnitY(dyingUnitSelf)
        local player killingUnitOwner
        local UnitType killingUnitType

        if (killingUnit == NULL) then
            set killingUnitOwner = null
            set killingUnitType = NULL
        else
            set killingUnitOwner = killingUnit.owner
            set killingUnitType = killingUnit.type
        endif

        call TriggerEvents(false, dyingUnit, dyingUnit.owner, dyingUnit.type, dyingUnitX, dyingUnitY, GetUnitZ(dyingUnitSelf, dyingUnitX, dyingUnitY), IsUnitType(dyingUnitSelf, UNIT_TYPE_STRUCTURE), killingUnit, killingUnitOwner, killingUnitType)

        set dyingUnitSelf = null
        set killingUnitOwner = null
    endfunction

    private function Trig takes nothing returns nothing
        local boolean deathCausedByEnemy
        local unit dyingUnitSelf = GetDyingUnit()
        local Unit dyingUnit = GetUnit(dyingUnitSelf)
        local boolean decays = (GetUnitDecay(dyingUnit) > 0)
        local player dyingUnitOwner = dyingUnit.owner
        local UnitType dyingUnitType = dyingUnit.type
        local real dyingUnitX = GetUnitX( dyingUnitSelf )
        local real dyingUnitY = GetUnitY( dyingUnitSelf )
        local real dyingUnitZ = GetUnitZ( dyingUnitSelf, dyingUnitX, dyingUnitY )
        local boolean explodes = (GetUnitExplode(dyingUnit) > 0)
        local boolean isDyingUnitIllusion = IsUnitIllusionWJ( dyingUnit )
        local boolean isDyingUnitStructure = IsUnitType( dyingUnitSelf, UNIT_TYPE_STRUCTURE )
        local unit killingUnitSelf = GetKillingUnit()
        local Unit killingUnit = GetUnit(killingUnitSelf)
        local boolean isKillingUnitNull = ( killingUnit == NULL )
        local integer iteration
        local player killingUnitOwner
        local integer killingUnitTeam
        local UnitType killingUnitType
        local player specificPlayer
        if ( isKillingUnitNull ) then
            set deathCausedByEnemy = false
            set killingUnitOwner = null
            set killingUnitTeam = -1
            set killingUnitType = NULL
        else
            set deathCausedByEnemy = IsUnitEnemy( killingUnitSelf, dyingUnitOwner )
            set killingUnitOwner = killingUnit.owner
            set killingUnitTeam = GetPlayerTeam( killingUnitOwner )
            set killingUnitType = killingUnit.type
        endif
        if ( explodes ) then
            call DestroyEffectWJ( AddSpecialEffectWJ( GetUnitBloodExplosion( dyingUnit ), dyingUnitX, dyingUnitY ) )
        elseif (decays) then
            call RemoveUnitTimedEx(dyingUnit, GetUnitDecayTime(dyingUnit))
        endif

        if ( isDyingUnitIllusion == false ) then
            if (isKillingUnitNull == false) then
                call Drop_Death(deathCausedByEnemy, dyingUnit, dyingUnitOwner, dyingUnitType, dyingUnitX, dyingUnitY, dyingUnitZ, killingUnit, killingUnitOwner, killingUnitTeam)
                call Experience_Death(deathCausedByEnemy, dyingUnit, dyingUnitType, dyingUnitX, dyingUnitY, killingUnitOwner, killingUnitTeam)
            endif
            call Infoboard_Death(deathCausedByEnemy, dyingUnit, killingUnit)
        endif

        call TriggerEvents(deathCausedByEnemy, dyingUnit, dyingUnitOwner, dyingUnitType, dyingUnitX, dyingUnitY, dyingUnitZ, isDyingUnitStructure, killingUnit, killingUnitOwner, killingUnitType)

        if ( IsUnitType( dyingUnitSelf, UNIT_TYPE_HERO ) == false ) then
            if ( isDyingUnitStructure ) then
                call SetUnitSupplyProduced( dyingUnit, dyingUnitOwner, 0 )
            endif
            call SetUnitSupplyUsed( dyingUnit, dyingUnitOwner, 0 )
        endif

        //////////////////////////////////////////////////////////////////////////////////////////////////
        set iteration = MAX_PLAYER_INDEX
        loop
            set specificPlayer = Player( iteration )
            if ( IsUnitSelected( dyingUnitSelf, specificPlayer ) ) then
                call SelectUnitWJ( dyingUnitSelf, false, specificPlayer )
            endif
            set iteration = iteration - 1
            exitwhen ( iteration < 0 )
        endloop
        set specificPlayer = null

        //////////////////////////////////////////////////////////////////////////////////////////////////
        set dyingUnit.orderTarget = null
        set dyingUnit.orderX = 0
        set dyingUnit.orderY = 0
        //////////////////////////////////////////////////////////////////////////////////////////////////

        if ( decays ) then
            call SpecialDrops_Source_Death(deathCausedByEnemy, isDyingUnitStructure, dyingUnitX, dyingUnitY)
            if ( explodes ) then
                call RemoveUnitEx( dyingUnit )
            else
                call UtilizationOfRests_Source_Death( dyingUnit, dyingUnitX, dyingUnitY )
                //////////////////////////////////////////////////////////////////////////////////////////////////
                if ( IsUnitType( dyingUnitSelf, UNIT_TYPE_TOWNHALL ) ) then
                    call KillPlayer( dyingUnitOwner )
                endif
            endif
        endif

        set dyingUnitOwner = null
        set dyingUnitSelf = null
        set killingUnitSelf = null
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope