//TESH.scrollpos=2699
//TESH.alwaysfold=0
scope Units
    scope Human
        public function Human_Init takes nothing returns nothing
            local UnitType d

            globals
                constant integer FARM_UNIT_ID = 'h00B'
            endglobals

            // Farm
            set d = InitUnitTypeEx( FARM_UNIT_ID )
            call AddUnitTypeAbility( d, GHOST_SPELL_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call SetUnitTypeMaxLife(d, 150000)
            call SetUnitTypeSightRange(d, 600)
            call SetUnitTypeScale(d, 1.4)
            call SetUnitTypeUpgradesInstantly( d )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 200)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer HUMAN_TIER1_UNIT_ID = 'h000'
            endglobals

            // Human - Tier 1
            set d = InitUnitTypeEx( HUMAN_TIER1_UNIT_ID )
            call AddUnitTypeAbility( d, AdvancedTraining_SPELL_ID )
            call AddUnitTypeAbility( d, LifeRegenerationAura_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Human\\HCancelDeath\\HCancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeImpactZ( d, 160 )
            call SetUnitTypeMaxLife( d, 4000 )
            call SetUnitTypeScale( d, 0.9 )
            call SetUnitTypeSightRange( d, 1000 )
            call AddShopUnitSupply( d, RESERVE_UNIT_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeSupplyProduced( d, 12 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer FOOTMAN_UNIT_ID = 'h001'
            endglobals

            // Footman
            set d = InitUnitTypeEx( FOOTMAN_UNIT_ID )
            call AddUnitTypeAbility( d, Defend_SPELL_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Human\\HumanBlood\\HumanBloodFootman.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Human\\HumanSmallDeathExplode\\HumanSmallDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 10 )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 2 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 25 )
            call SetUnitTypeEP( d, 27 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 0.5 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 410 )
            call SetUnitTypeScale( d, 1.05 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 300 )
            call SetUnitTypeVertexColor(d, 230, 230, 230, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer WITCH_UNIT_ID = 'H003'
            endglobals

            // Witch
            set d = InitUnitTypeEx( WITCH_UNIT_ID )
            call AddUnitTypeAbility( d, Enchant_SPELL_ID )
            call AddUnitTypeAbility( d, MagicalSuperiority_SPELL_ID )
            call SetUnitTypeArmor( d, -2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_HERO )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Other\\HumanBloodCinematicEffect\\HumanBloodCinematicEffect.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Human\\HumanSmallDeathExplode\\HumanSmallDeathExplode.mdl" )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 4 )
            call SetUnitTypeDamageType( d, DMG_TYPE_MAGIC )
            call SetUnitTypeDrop( d, 50 )
            call SetUnitTypeEP( d, 50 )
            call AddUnitHeroAbility( d, ChillyPresence_SPELL_ID )
            call AddUnitHeroAbility( d, FireBurst_SPELL_ID )
            call AddUnitHeroAbility( d, Hurricane_SPELL_ID )
            call AddUnitHeroAbility( d, SummonInfernal_SPELL_ID )
            call SetUnitTypeImage( d, "ReplaceableTextures\\CommandButtons\\BTNJaina.blp" )
            call SetUnitTypeImpactZ( d, 69 )
            call SetUnitTypeMaxLife( d, 300 )
            call SetUnitTypeMaxMana( d, 100 )
            call SetUnitTypeScale( d, 1.15 )
            call SetUnitTypeSightRange( d, 800 )
            call AddUnitTypePissedSound( d, WITCH_PISSED_SOUND_TYPE )
            call AddUnitTypePissedSound( d, WITCH_PISSED2_SOUND_TYPE )
            call AddUnitTypePissedSound( d, WITCH_PISSED3_SOUND_TYPE )
            call AddUnitTypePissedSound( d, WITCH_PISSED4_SOUND_TYPE )
            call AddUnitTypePissedSound( d, WITCH_PISSED5_SOUND_TYPE )
            call SetUnitTypeSpeed( d, 290 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            call SetUnitTypeAgility( d, 15 )
            call SetUnitTypeAgilityPerLevel( d, 1.35 )
            call SetUnitTypeIntelligence( d, 20 )
            call SetUnitTypeIntelligencePerLevel( d, 3.45 )
            call SetUnitTypePrimaryAttribute( d, 3 )
            call SetUnitTypeStrength( d, 14 )
            call SetUnitTypeStrengthPerLevel( d, 1.05 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer PALADIN_UNIT_ID = 'H004'
            endglobals

            // Paladin
            set d = InitUnitTypeEx( PALADIN_UNIT_ID )
            call AddUnitTypeAbility( d, CourageAndHonor_SPELL_ID )
            call AddUnitTypeAbility( d, HammerThrow_SPELL_ID )
            call SetUnitTypeArmor( d, -2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_HERO )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Other\\HumanBloodCinematicEffect\\HumanBloodCinematicEffect.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Human\\HumanSmallDeathExplode\\HumanSmallDeathExplode.mdl" )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 6 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDrop( d, 50 )
            call SetUnitTypeEP( d, 50 )
            call AddUnitHeroAbility( d, EnergyGap_SPELL_ID )
            call AddUnitHeroAbility( d, LightOfPurge_SPELL_ID )
            call AddUnitHeroAbility( d, Resurrection_SPELL_ID )
            call AddUnitHeroAbility( d, Stability_SPELL_ID )
            call SetUnitTypeImage( d, "ReplaceableTextures\\CommandButtons\\BTNArthas.blp" )
            call SetUnitTypeImpactZ( d, 69 )
            call SetUnitTypeMaxLife( d, 300 )
            call SetUnitTypeMaxMana( d, 100 )
            call SetUnitTypeScale( d, 1.25 )
            call SetUnitTypeSightRange( d, 800 )
            call AddUnitTypePissedSound( d, PALADIN_PISSED_SOUND_TYPE )
            call AddUnitTypePissedSound( d, PALADIN_PISSED2_SOUND_TYPE )
            call AddUnitTypePissedSound( d, PALADIN_PISSED3_SOUND_TYPE )
            call AddUnitTypePissedSound( d, PALADIN_PISSED4_SOUND_TYPE )
            call AddUnitTypePissedSound( d, PALADIN_PISSED5_SOUND_TYPE )
            call AddUnitTypePissedSound( d, PALADIN_PISSED6_SOUND_TYPE )
            call AddUnitTypePissedSound( d, PALADIN_PISSED7_SOUND_TYPE )
            call SetUnitTypeSpeed( d, 290 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            call SetUnitTypeAgility( d, 13 )
            call SetUnitTypeAgilityPerLevel( d, 1.05 )
            call SetUnitTypeIntelligence( d, 16 )
            call SetUnitTypeIntelligencePerLevel( d, 2.25 )
            call SetUnitTypePrimaryAttribute( d, 1 )
            call SetUnitTypeStrength( d, 21 )
            call SetUnitTypeStrengthPerLevel( d, 3 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer HUMAN_TIER2_UNIT_ID = 'h005'
            endglobals

            // Human - Tier 2
            set d = InitUnitTypeEx( HUMAN_TIER2_UNIT_ID )
            call AddUnitTypeAbility( d, AdvancedTraining_SPELL_ID )
            call AddUnitTypeAbility( d, LifeRegenerationAura_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Human\\HCancelDeath\\HCancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeGoldCost( d, 1250 )
            call SetUnitTypeImpactZ( d, 160 )
            call SetUnitTypeMaxLife( d, 5000 )
            call SetUnitTypeScale( d, 0.85 )
            call SetUnitTypeSightRange( d, 1000 )
            call AddShopUnitSupply( d, RESERVE_UNIT_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeSupplyProduced( d, 16 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer RIFLEMAN_UNIT_ID = 'h006'
            endglobals

            // Rifleman
            set d = InitUnitTypeEx( RIFLEMAN_UNIT_ID )
            call AddUnitTypeAbility( d, BigGun_SPELL_ID )
            call SetUnitTypeArmor( d, 1 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Human\\HumanBlood\\HumanBloodRifleman.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Human\\HumanSmallDeathExplode\\HumanSmallDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 12 )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 4 )
            call SetUnitTypeDamageType( d, DMG_TYPE_PIERCE )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 25 )
            call SetUnitTypeEP( d, 29 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 0.5 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 432 )
            call SetUnitTypeScale( d, 1.05 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 290 )
            call SetUnitTypeSplashAffectionAir( d )
            call SetUnitTypeSplashAffectionEnemy( d )
            call SetUnitTypeSplashAffectionGround( d )
            call SetUnitTypeSplashDamageFactor( d, 0.6 )
            call SetUnitTypeSplashAreaRange( d, 215 )
            call SetUnitTypeSplashWindowAngle( d, 360 * RAD_TO_DEG )
            call SetUnitTypeVertexColor(d, 210, 210, 210, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            call AddUnitTypeResearchTypeId( d, BigGun_RESEARCH_ID )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer HUMAN_TIER3_UNIT_ID = 'h007'
            endglobals

            // Human - Tier 3
            set d = InitUnitTypeEx( HUMAN_TIER3_UNIT_ID )
            call AddUnitTypeAbility( d, AdvancedTraining_SPELL_ID )
            call AddUnitTypeAbility( d, LifeRegenerationAura_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Human\\HCancelDeath\\HCancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeGoldCost( d, 1750 )
            call SetUnitTypeImpactZ( d, 160 )
            call SetUnitTypeMaxLife( d, 6000 )
            call SetUnitTypeScale( d, 0.85 )
            call SetUnitTypeSightRange( d, 1000 )
            call AddShopUnitSupply( d, RESERVE_UNIT_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeSupplyProduced( d, 20 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer KNIGHT_UNIT_ID = 'h008'
            endglobals

            // Knight
            set d = InitUnitTypeEx( KNIGHT_UNIT_ID )
            call AddUnitTypeAbility( d, StrongArm_SPELL_ID )
            call SetUnitTypeArmor( d, 4 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_LARGE )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Human\\HumanBlood\\HumanBloodKnight.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Human\\HumanSmallDeathExplode\\HumanSmallDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 15 )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 4 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 31 )
            call SetUnitTypeEP( d, 32 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 0.65 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 585 )
            call SetUnitTypeScale( d, 1.05 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 350 )
            call SetUnitTypeVertexColor(d, 210, 210, 210, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            call AddUnitTypeResearchTypeId( d, StrongArm_RESEARCH_ID )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer HUMAN_TIER4_UNIT_ID = 'h009'
            endglobals

            // Human - Tier 4
            set d = InitUnitTypeEx( HUMAN_TIER4_UNIT_ID )
            call AddUnitTypeAbility( d, AdvancedTraining_SPELL_ID )
            call AddUnitTypeAbility( d, LifeRegenerationAura_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Human\\HCancelDeath\\HCancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeGoldCost( d, 2250 )
            call SetUnitTypeImpactZ( d, 160 )
            call SetUnitTypeMaxLife( d, 7000 )
            call SetUnitTypeScale( d, 0.75 )
            call SetUnitTypeSightRange( d, 1000 )
            call AddShopUnitSupply( d, RESERVE_UNIT_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeSupplyProduced( d, 24 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer DRAGON_HAWK_UNIT_ID = 'h00Z'
            endglobals

            // Dragonhawk
            set d = InitUnitTypeEx( DRAGON_HAWK_UNIT_ID )
            call AddUnitTypeAbility( d, MagicalLariat_SPELL_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_LIGHT )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Human\\HumanBlood\\HumanBloodMortarTeam.mdl" )
            call SetUnitTypeCanNotBeRevived(d)
            call SetUnitTypeDamage( d, 19 )
            call SetUnitTypeDamageDices( d, 1 )
            call SetUnitTypeDamageDicesSides( d, 7 )
            call SetUnitTypeDamageType( d, DMG_TYPE_MAGIC )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 34 )
            call SetUnitTypeEP( d, 25 )
            call SetUnitTypeImpactZ( d, 20 )
            call SetUnitTypeLifeRegeneration( d, 1 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 470 )
            call SetUnitTypeScale( d, 1 )
            call SetUnitTypeSightRange( d, 700 )
            call SetUnitTypeSpeed( d, 310 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer PRIEST_UNIT_ID = 'h00A'
            endglobals

            // Priest
            set d = InitUnitTypeEx( PRIEST_UNIT_ID )
            call AddUnitTypeAbility( d, Inspiration_SPELL_ID )
            call SetUnitTypeArmor( d, 1 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_UNARMORED )
            call SetUnitTypeAutomaticAbility( d, Inspiration_SPELL_ID )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Human\\HumanBlood\\HumanBloodPriest.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Human\\HumanSmallDeathExplode\\HumanSmallDeathExplode.mdl" )
            call SetUnitTypeCaster( d )
            call SetUnitTypeDamage( d, 10 )
            call SetUnitTypeDamageDices( d, 1 )
            call SetUnitTypeDamageDicesSides( d, 4 )
            call SetUnitTypeDamageType( d, DMG_TYPE_MAGIC )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 23 )
            call SetUnitTypeEP( d, 25 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 0.5 * REGENERATION_INTERVAL )
            call SetUnitTypeManaRegeneration( d, 0.8 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 270 )
            call SetUnitTypeMaxMana( d, 150 )
            call SetUnitTypeScale( d, 1.05 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 270 )
            call SetUnitTypeStartMana( d, 300 )
            call SetUnitTypeVertexColor(d, 210, 210, 210, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer INFERNAL_UNIT_ID = 'n005'
            endglobals

            // Infernal
            set d = InitUnitTypeEx( INFERNAL_UNIT_ID )
            call AddUnitTypeAbility( d, Immolation_SPELL_ID )
            call SetUnitTypeArmor( d, 6 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_HERO )
            call SetUnitTypeCanNotBeRevived(d)
            call SetUnitTypeDamage( d, 48 )
            call SetUnitTypeDamageDices( d, 1 )
            call SetUnitTypeDamageDicesSides( d, 12 )
            call SetUnitTypeDamageType( d, DMG_TYPE_CHAOS )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 120 )
            call SetUnitTypeEP( d, 100 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 1 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 900 )
            call SetUnitTypeScale( d, 1.1 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 290 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer MONSTROUS_INFERNAL_UNIT_ID = 'n02A'
            endglobals

            // Monstrous Infernal
            set d = InitUnitTypeEx( MONSTROUS_INFERNAL_UNIT_ID )
            call AddUnitTypeAbility( d, Immolation_SPELL_ID )
            call SetUnitTypeArmor( d, 10 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_HERO )
            call SetUnitTypeCanNotBeRevived(d)
            call SetUnitTypeDamage( d, 55 )
            call SetUnitTypeDamageDices( d, 4 )
            call SetUnitTypeDamageDicesSides( d, 8 )
            call SetUnitTypeDamageType( d, DMG_TYPE_CHAOS )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 200 )
            call SetUnitTypeEP( d, 150 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 1.5 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 1300 )
            call SetUnitTypeScale( d, 1.3 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 310 )
            call SetUnitTypeVertexColor(d, 255, 80, 80, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer RESEARCH_CENTER_HUMAN_UNIT_ID = 'h00O'
            endglobals

            // Research Center (Human, Page 1)
            set d = InitUnitTypeEx( RESEARCH_CENTER_HUMAN_UNIT_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Human\\HCancelDeath\\HCancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeImpactZ( d, 120 )
            call SetUnitTypeMaxLife( d, 500 )
            call SetUnitTypeScale( d, 0.75 )
            call SetUnitTypeSightRange( d, 400 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer RESEARCH_CENTER_HUMAN_PAGE_2_UNIT_ID = 'h011'
            endglobals

            // Research Center (Human, Page 2)
            set d = InitUnitTypeEx( RESEARCH_CENTER_HUMAN_PAGE_2_UNIT_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Human\\HCancelDeath\\HCancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeImpactZ( d, 120 )
            call SetUnitTypeMaxLife( d, 500 )
            call SetUnitTypeScale( d, 0.75 )
            call SetUnitTypeSightRange( d, 400 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
        endfunction
    endscope

    scope Orc
        public function Orc_Init takes nothing returns nothing
            local UnitType d

            globals
                constant integer TROLL_BURROW_UNIT_ID = 'o00A'
            endglobals

            // TrollBurrow
            set d = InitUnitTypeEx( TROLL_BURROW_UNIT_ID )
            call AddUnitTypeAbility( d, GHOST_SPELL_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call SetUnitTypeMaxLife( d, 150000 )
            call SetUnitTypeScale( d, 1.4 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeUpgradesInstantly( d )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 200)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer ORC_TIER1_UNIT_ID = 'o000'
            endglobals

            // Orc - Tier 1
            set d = InitUnitTypeEx( ORC_TIER1_UNIT_ID )
            call AddUnitTypeAbility( d, AdvancedTraining_SPELL_ID )
            call AddUnitTypeAbility( d, LifeRegenerationAura_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Human\\HCancelDeath\\HCancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeImpactZ( d, 160 )
            call SetUnitTypeMaxLife( d, 4000 )
            call SetUnitTypeScale( d, 0.9 )
            call SetUnitTypeSightRange( d, 1000 )
            call AddShopUnitSupply( d, RESERVE_UNIT_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeSupplyProduced( d, 12 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer HEAD_HUNTER_UNIT_ID = 'o00J'
            endglobals

            // Head Hunter
            set d = InitUnitTypeEx( HEAD_HUNTER_UNIT_ID )
            call AddUnitTypeAbility( d, Berserk_SPELL_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Orc\\Orcblood\\OrcBloodHeadhunter.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Orc\\OrcSmallDeathExplode\\OrcSmallDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 11 )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 4 )
            call SetUnitTypeDamageType( d, DMG_TYPE_PIERCE )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 20 )
            call SetUnitTypeEP( d, 25 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 0.45 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 350 )
            call SetUnitTypeScale( d, 1 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 270 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer ORC_TIER2_UNIT_ID = 'o002'
            endglobals

            // Orc - Tier 2
            set d = InitUnitTypeEx( ORC_TIER2_UNIT_ID )
            call AddUnitTypeAbility( d, AdvancedTraining_SPELL_ID )
            call AddUnitTypeAbility( d, LifeRegenerationAura_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Human\\HCancelDeath\\HCancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeGoldCost( d, 1250 )
            call SetUnitTypeImpactZ( d, 160 )
            call SetUnitTypeMaxLife( d, 5000 )
            call SetUnitTypeScale( d, 0.8 )
            call SetUnitTypeSightRange( d, 1000 )
            call AddShopUnitSupply( d, RESERVE_UNIT_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeSupplyProduced( d, 16 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer RAIDER_UNIT_ID = 'o003'
            endglobals

            // Raider
            set d = InitUnitTypeEx( RAIDER_UNIT_ID )
            call AddUnitTypeAbility( d, Evasion_RAIDER_SPELL_ID )
            call SetUnitTypeArmor( d, 1 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Orc\\Orcblood\\OrcBloodWolfrider.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Orc\\OrcSmallDeathExplode\\OrcSmallDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 10 )
            call SetUnitTypeDamageDices( d, 3 )
            call SetUnitTypeDamageDicesSides( d, 2 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 27 )
            call SetUnitTypeEP( d, 30 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 0.95 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 468 )
            call SetUnitTypeScale( d, 1 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 360 )
            call SetUnitTypeVertexColor(d, 210, 210, 210, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            call AddUnitTypeResearchTypeId( d, Evasion_RAIDER_RESEARCH_ID )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer ORC_TIER3_UNIT_ID = 'o004'
            endglobals

            // Orc - Tier 3
            set d = InitUnitTypeEx( ORC_TIER3_UNIT_ID )
            call AddUnitTypeAbility( d, AdvancedTraining_SPELL_ID )
            call AddUnitTypeAbility( d, LifeRegenerationAura_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Human\\HCancelDeath\\HCancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeGoldCost( d, 1750 )
            call SetUnitTypeImpactZ( d, 160 )
            call SetUnitTypeMaxLife( d, 6000 )
            call SetUnitTypeScale( d, 0.8 )
            call SetUnitTypeSightRange( d, 1000 )
            call AddShopUnitSupply( d, RESERVE_UNIT_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeSupplyProduced( d, 20 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer GRUNT_UNIT_ID = 'o005'
            endglobals

            // Grunt
            set d = InitUnitTypeEx( GRUNT_UNIT_ID )
            call AddUnitTypeAbility( d, Disarm_SPELL_ID )
            call SetUnitTypeArmor( d, 1 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_LARGE )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Orc\\Orcblood\\OrcBloodGrunt.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Orc\\OrcSmallDeathExplode\\OrcSmallDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 16 )
            call SetUnitTypeDamageDices( d, 3 )
            call SetUnitTypeDamageDicesSides( d, 4 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 29 )
            call SetUnitTypeEP( d, 32 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 1.1 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 585 )
            call SetUnitTypeScale( d, 1.1 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 300 )
            call SetUnitTypeVertexColor(d, 210, 210, 210, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            call AddUnitTypeResearchTypeId( d, Disarm_RESEARCH_ID )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer ORC_TIER4_UNIT_ID = 'o006'
            endglobals

            // Orc - Tier 4
            set d = InitUnitTypeEx( ORC_TIER4_UNIT_ID )
            call AddUnitTypeAbility( d, AdvancedTraining_SPELL_ID )
            call AddUnitTypeAbility( d, LifeRegenerationAura_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Human\\HCancelDeath\\HCancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeGoldCost( d, 2250 )
            call SetUnitTypeImpactZ( d, 160 )
            call SetUnitTypeMaxLife( d, 7000 )
            call SetUnitTypeScale( d, 0.75 )
            call SetUnitTypeSightRange( d, 1000 )
            call AddShopUnitSupply( d, RESERVE_UNIT_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeSupplyProduced( d, 24 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer WIND_RIDER_UNIT_ID = 'o007'
            endglobals

            // Windrider
            set d = InitUnitTypeEx( WIND_RIDER_UNIT_ID )
            call AddUnitTypeAbility( d, AirPassage_SPELL_ID )
            call SetUnitTypeArmor( d, 1 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_LIGHT )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Orc\\Orcblood\\OrdBloodWyvernRider.mdl" )
            call SetUnitTypeCanNotBeRevived(d)
            call SetUnitTypeDamage( d, 20 )
            call SetUnitTypeDamageDices( d, 4 )
            call SetUnitTypeDamageDicesSides( d, 4 )
            call SetUnitTypeDamageType( d, DMG_TYPE_PIERCE )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 30 )
            call SetUnitTypeEP( d, 32 )
            call SetUnitTypeImpactZ( d, 20 )
            call SetUnitTypeLifeRegeneration( d, 0.75 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 528 )
            call SetUnitTypeScale( d, 1 )
            call SetUnitTypeSightRange( d, 700 )
            call SetUnitTypeSpeed( d, 320 )
            call SetUnitTypeVertexColor(d, 210, 210, 210, 255)
            call SetUnitTypeSupplyUsed( d, 2 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer SHAMAN_UNIT_ID = 'o001'
            endglobals

            // Shaman
            set d = InitUnitTypeEx( SHAMAN_UNIT_ID )
            call AddUnitTypeAbility( d, Fireball_SPELL_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_UNARMORED )
            call SetUnitTypeAutomaticAbility( d, Fireball_SPELL_ID )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Orc\\Orcblood\\OrcBloodPeon.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Orc\\OrcSmallDeathExplode\\OrcSmallDeathExplode.mdl" )
            call SetUnitTypeCaster( d )
            call SetUnitTypeDamage( d, 11 )
            call SetUnitTypeDamageDices( d, 1 )
            call SetUnitTypeDamageDicesSides( d, 5 )
            call SetUnitTypeDamageType( d, DMG_TYPE_MAGIC )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 20 )
            call SetUnitTypeEP( d, 26 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 0.6 * REGENERATION_INTERVAL )
            call SetUnitTypeManaRegeneration( d, 0.75 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 245 )
            call SetUnitTypeMaxMana( d, 150 )
            call SetUnitTypeScale( d, 0.95 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 270 )
            call SetUnitTypeStartMana( d, 150 )
            call SetUnitTypeVertexColor(d, 210, 210, 210, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer BERSERKER_UNIT_ID = 'O008'
            endglobals

            // Berserker
            set d = InitUnitTypeEx( BERSERKER_UNIT_ID )
            call AddUnitTypeAbility( d, Evasion_BERSERKER_SPELL_ID )
            call AddUnitTypeAbility( d, Meditation_SPELL_ID )
            call SetUnitTypeArmor( d, -2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_HERO )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Orc\\Orcblood\\OrcBloodHellScream.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Orc\\OrcSmallDeathExplode\\OrcSmallDeathExplode.mdl" )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 12 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDrop( d, 50 )
            call SetUnitTypeEP( d, 50 )
            call AddUnitHeroAbility( d, AxeMaster_SPELL_ID )
            call AddUnitHeroAbility( d, Frenzy_SPELL_ID )
            call AddUnitHeroAbility( d, MindBreaker_SPELL_ID )
            call AddUnitHeroAbility( d, Whirlwind_SPELL_ID )
            call SetUnitTypeImage( d, "ReplaceableTextures\\CommandButtons\\BTNHellScream.blp" )
            call SetUnitTypeImpactZ( d, 69 )
            call SetUnitTypeMaxLife( d, 300 )
            call SetUnitTypeMaxMana( d, 100 )
            call SetUnitTypeScale( d, 1.15 )
            call SetUnitTypeSightRange( d, 800 )
            call AddUnitTypePissedSound( d, BERSERK_PISSED_SOUND_TYPE )
            call AddUnitTypePissedSound( d, BERSERK_PISSED2_SOUND_TYPE )
            call AddUnitTypePissedSound( d, BERSERK_PISSED3_SOUND_TYPE )
            call SetUnitTypeSpeed( d, 320 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            call SetUnitTypeAgility( d, 23 )
            call SetUnitTypeAgilityPerLevel( d, 3.3 )
            call SetUnitTypeIntelligence( d, 14 )
            call SetUnitTypeIntelligencePerLevel( d, 1.05 )
            call SetUnitTypePrimaryAttribute( d, 2 )
            call SetUnitTypeStrength( d, 17 )
            call SetUnitTypeStrengthPerLevel( d, 2.4 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer MEDICINE_MAN_UNIT_ID = 'O00B'
            endglobals

            // Medicine Man
            set d = InitUnitTypeEx( MEDICINE_MAN_UNIT_ID )
            call AddUnitTypeAbility( d, SoulVessel_SPELL_ID )
            call AddUnitTypeAbility( d, ThermalFissure_SPELL_ID )
            call SetUnitTypeArmor( d, -2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_HERO )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Orc\\Orcblood\\OrcBloodHeroFarSeer.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Orc\\OrcSmallDeathExplode\\OrcSmallDeathExplode.mdl" )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 4 )
            call SetUnitTypeDamageType( d, DMG_TYPE_MAGIC )
            call SetUnitTypeDrop( d, 50 )
            call SetUnitTypeEP( d, 50 )
            call AddUnitHeroAbility( d, BondOfSouls_SPELL_ID )
            call AddUnitHeroAbility( d, DarkCloud_SPELL_ID )
            call AddUnitHeroAbility( d, GhostTakeOver_SPELL_ID )
            call AddUnitHeroAbility( d, LittleThunderstorm_SPELL_ID )
            call SetUnitTypeImage( d, "ReplaceableTextures\\CommandButtons\\BTNThrall.blp" )
            call SetUnitTypeImpactZ( d, 69 )
            call SetUnitTypeMaxLife( d, 300 )
            call SetUnitTypeMaxMana( d, 100 )
            call SetUnitTypeScale( d, 1.15 )
            call SetUnitTypeSightRange( d, 800 )
            call AddUnitTypePissedSound( d, MEDICINE_MAN_PISSED_SOUND_TYPE )
            call AddUnitTypePissedSound( d, MEDICINE_MAN_PISSED2_SOUND_TYPE )
            call AddUnitTypePissedSound( d, MEDICINE_MAN_PISSED3_SOUND_TYPE )
            call AddUnitTypePissedSound( d, MEDICINE_MAN_PISSED4_SOUND_TYPE )
            call SetUnitTypeSpeed( d, 320 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            call SetUnitTypeAgility( d, 15 )
            call SetUnitTypeAgilityPerLevel( d, 1.65 )
            call SetUnitTypeIntelligence( d, 18 )
            call SetUnitTypeIntelligencePerLevel( d, 3 )
            call SetUnitTypePrimaryAttribute( d, 3 )
            call SetUnitTypeStrength( d, 16 )
            call SetUnitTypeStrengthPerLevel( d, 1.5 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer RESEARCH_CENTER_ORC_UNIT_ID = 'o00E'
            endglobals

            // Research Center (Orc, Page 1)
            set d = InitUnitTypeEx( RESEARCH_CENTER_ORC_UNIT_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Human\\HCancelDeath\\HCancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeImpactZ( d, 120 )
            call SetUnitTypeMaxLife( d, 500 )
            call SetUnitTypeScale( d, 0.75 )
            call SetUnitTypeSightRange( d, 400 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer RESEARCH_CENTER_ORC_PAGE_2_UNIT_ID = 'o00K'
            endglobals

            // Research Center (Orc, Page 2)
            set d = InitUnitTypeEx( RESEARCH_CENTER_ORC_PAGE_2_UNIT_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Human\\HCancelDeath\\HCancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeImpactZ( d, 120 )
            call SetUnitTypeMaxLife( d, 500 )
            call SetUnitTypeScale( d, 0.75 )
            call SetUnitTypeSightRange( d, 400 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
        endfunction
    endscope

    scope Undead
        public function Undead_Init takes nothing returns nothing
            local UnitType d

            globals
                constant integer ZIGGURAT_UNIT_ID = 'u008'
            endglobals

            // Ziggurat
            set d = InitUnitTypeEx( ZIGGURAT_UNIT_ID )
            call AddUnitTypeAbility( d, GHOST_SPELL_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call SetUnitTypeMaxLife( d, 150000 )
            call SetUnitTypeScale( d, 1.4 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeUpgradesInstantly( d )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 200)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer UNDEAD_TIER1_UNIT_ID = 'u000'
            endglobals

            // Undead - Tier 1
            set d = InitUnitTypeEx( UNDEAD_TIER1_UNIT_ID )
            call AddUnitTypeAbility( d, AdvancedTraining_SPELL_ID )
            call AddUnitTypeAbility( d, LifeRegenerationAura_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Undead\\UCancelDeath\\UCancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeImpactZ( d, 120 )
            call SetUnitTypeMaxLife( d, 4000 )
            call SetUnitTypeScale( d, 0.9 )
            call SetUnitTypeSightRange( d, 1000 )
            call AddShopUnitSupply( d, RESERVE_UNIT_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeSupplyProduced( d, 12 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer GHOUL_UNIT_ID = 'u001'
            endglobals

            // Ghoul
            set d = InitUnitTypeEx( GHOUL_UNIT_ID )
            call AddUnitTypeAbility( d, GhoulFrenzy_SPELL_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Undead\\UndeadBlood\\UndeadBloodGhoul.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Undead\\UndeadLargeDeathExplode\\UndeadLargeDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 8 )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 2 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 21 )
            call SetUnitTypeEP( d, 24 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 1.2 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 345 )
            call SetUnitTypeScale( d, 1 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 330 )
            call SetUnitTypeVertexColor(d, 210, 210, 210, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            call AddUnitTypeResearchTypeId( d, GhoulFrenzy_RESEARCH_ID )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer UNDEAD_TIER2_UNIT_ID = 'u002'
            endglobals

            // Undead - Tier 2
            set d = InitUnitTypeEx( UNDEAD_TIER2_UNIT_ID )
            call AddUnitTypeAbility( d, AdvancedTraining_SPELL_ID )
            call AddUnitTypeAbility( d, LifeRegenerationAura_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Undead\\UCancelDeath\\UCancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeGoldCost( d, 1250 )
            call SetUnitTypeImpactZ( d, 260 )
            call SetUnitTypeMaxLife( d, 5000 )
            call SetUnitTypeScale( d, 0.8 )
            call SetUnitTypeSightRange( d, 1000 )
            call AddShopUnitSupply( d, RESERVE_UNIT_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeSupplyProduced( d, 16 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer CRYPT_FIEND_UNIT_ID = 'u003'
            endglobals

            // Crypt Fiend
            set d = InitUnitTypeEx( CRYPT_FIEND_UNIT_ID )
            call AddUnitTypeAbility( d, Burrow_SPELL_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_LARGE )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Undead\\UndeadBlood\\UndeadBloodCryptFiend.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Demon\\DemonLargeDeathExplode\\DemonLargeDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 18 )
            call SetUnitTypeDamageDices( d, 4 )
            call SetUnitTypeDamageDicesSides( d, 4 )
            call SetUnitTypeDamageType( d, DMG_TYPE_SIEGE )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 26 )
            call SetUnitTypeEP( d, 30 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 0.9 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 366 )
            call SetUnitTypeScale( d, 0.9 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 290 )
            call SetUnitTypeVertexColor(d, 210, 210, 210, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer CRYPT_FIEND_BURROWED_UNIT_ID = 'u00H'
            endglobals

            // Crypt Fiend (Burrowed)
            set d = InitUnitTypeEx( CRYPT_FIEND_BURROWED_UNIT_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_LARGE )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Undead\\UndeadBlood\\UndeadBloodCryptFiend.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Demon\\DemonLargeDeathExplode\\DemonLargeDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 18 )
            call SetUnitTypeDamageDices( d, 4 )
            call SetUnitTypeDamageDicesSides( d, 4 )
            call SetUnitTypeDamageType( d, DMG_TYPE_SIEGE )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 26 )
            call SetUnitTypeEP( d, 30 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 0.9 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 366 )
            call SetUnitTypeScale( d, 0.9 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeVertexColor(d, 210, 210, 210, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer UNDEAD_TIER3_UNIT_ID = 'u004'
            endglobals

            // Undead - Tier 3
            set d = InitUnitTypeEx( UNDEAD_TIER3_UNIT_ID )
            call AddUnitTypeAbility( d, AdvancedTraining_SPELL_ID )
            call AddUnitTypeAbility( d, LifeRegenerationAura_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Undead\\UCancelDeath\\UCancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeGoldCost( d, 1750 )
            call SetUnitTypeImpactZ( d, 260 )
            call SetUnitTypeMaxLife( d, 6000 )
            call SetUnitTypeScale( d, 0.75 )
            call SetUnitTypeSightRange( d, 1000 )
            call AddShopUnitSupply( d, RESERVE_UNIT_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeSupplyProduced( d, 20 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer GARGOYLE_UNIT_ID = 'u00F'
            endglobals

            // Gargoyle
            set d = InitUnitTypeEx( GARGOYLE_UNIT_ID )
            call AddUnitTypeAbility( d, Kataikaze_SPELL_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Undead\\UndeadBlood\\UndeadBloodGargoyle.mdl" )
            call SetUnitTypeCanNotBeRevived(d)
            call SetUnitTypeDamage( d, 16 )
            call SetUnitTypeDamageDices( d, 1 )
            call SetUnitTypeDamageDicesSides( d, 6 )
            call SetUnitTypeDamageType( d, DMG_TYPE_PIERCE )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 26 )
            call SetUnitTypeEP( d, 26 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 3 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 425 )
            call SetUnitTypeScale( d, 1 )
            call SetUnitTypeSightRange( d, 700 )
            call SetUnitTypeSpeed( d, 340 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer UNDEAD_TIER4_UNIT_ID = 'u006'
            endglobals

            // Undead - Tier 4
            set d = InitUnitTypeEx( UNDEAD_TIER4_UNIT_ID )
            call AddUnitTypeAbility( d, AdvancedTraining_SPELL_ID )
            call AddUnitTypeAbility( d, LifeRegenerationAura_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Undead\\UCancelDeath\\UCancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeGoldCost( d, 2250 )
            call SetUnitTypeImpactZ( d, 260 )
            call SetUnitTypeMaxLife( d, 7000 )
            call SetUnitTypeScale( d, 0.8 )
            call SetUnitTypeSightRange( d, 1000 )
            call AddShopUnitSupply( d, RESERVE_UNIT_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeSupplyProduced( d, 24 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer ABOMINATION_UNIT_ID = 'u007'
            endglobals

            // Abomination
            set d = InitUnitTypeEx( ABOMINATION_UNIT_ID )
            call AddUnitTypeAbility( d, Cannibalism_SPELL_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_LARGE )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Undead\\UndeadBlood\\UndeadBloodAbomination.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Demon\\DemonLargeDeathExplode\\DemonLargeDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 25 )
            call SetUnitTypeDamageDices( d, 1 )
            call SetUnitTypeDamageDicesSides( d, 7 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 34 )
            call SetUnitTypeEP( d, 22 )
            call SetUnitTypeImpactZ( d, 70 )
            call SetUnitTypeLifeRegeneration( d, 1.4 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 650 )
            call SetUnitTypeScale( d, 0.9 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 280 )
            call SetUnitTypeVertexColor(d, 210, 210, 210, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            call AddUnitTypeResearchTypeId( d, Cannibalism_RESEARCH_ID )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer NECROMANCER_UNIT_ID = 'u005'
            endglobals

            // Necromancer
            set d = InitUnitTypeEx( NECROMANCER_UNIT_ID )
            call AddUnitTypeAbility( d, RaiseDead_SPELL_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_UNARMORED )
            call SetUnitTypeAutomaticAbility( d, RaiseDead_SPELL_ID )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Undead\\UndeadBlood\\UndeadBloodNecromancer.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Undead\\UndeadLargeDeathExplode\\UndeadLargeDeathExplode.mdl" )
            call SetUnitTypeCaster( d )
            call SetUnitTypeDamage( d, 11 )
            call SetUnitTypeDamageDices( d, 3 )
            call SetUnitTypeDamageDicesSides( d, 3 )
            call SetUnitTypeDamageType( d, DMG_TYPE_MAGIC )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 22 )
            call SetUnitTypeEP( d, 26 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 0.4 * REGENERATION_INTERVAL )
            call SetUnitTypeManaRegeneration( d, 0.8 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 270 )
            call SetUnitTypeMaxMana( d, 200 )
            call SetUnitTypeScale( d, 1 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 300 )
            call SetUnitTypeStartMana( d, 200 )
            call SetUnitTypeVertexColor(d, 210, 210, 210, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer SKELETON_WARRIOR_UNIT_ID = 'u00B'
            endglobals

            // Skeleton Warrior
            set d = InitUnitTypeEx( SKELETON_WARRIOR_UNIT_ID )
            call SetUnitTypeArmor( d, 1 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_LARGE )
            call SetUnitTypeCanNotBeRevived(d)
            call SetUnitTypeDamage( d, 9 )
            call SetUnitTypeDamageDices( d, 3 )
            call SetUnitTypeDamageDicesSides( d, 2 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 9 )
            call SetUnitTypeEP( d, 10 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeMaxLife( d, 350 )
            call SetUnitTypeScale( d, 0.9 )
            call SetUnitTypeSightRange( d, 400 )
            call SetUnitTypeSpeed( d, 300 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer DARK_KNIGHT_UNIT_ID = 'U009'
            endglobals

            // Dark Knight
            set d = InitUnitTypeEx( DARK_KNIGHT_UNIT_ID )
            call AddUnitTypeAbility( d, UnholyArmor_SPELL_ID )
            call AddUnitTypeAbility( d, VividStrikes_SPELL_ID )
            call SetUnitTypeArmor( d, -2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_HERO )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Undead\\UndeadLargeDeathExplode\\UndeadLargeDeathExplode.mdl" )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 6 )
            call SetUnitTypeDamageType( d, DMG_TYPE_CHAOS )
            call SetUnitTypeDrop( d, 50 )
            call SetUnitTypeEP( d, 50 )
            call AddUnitHeroAbility( d, AcidStrike_SPELL_ID )
            call AddUnitHeroAbility( d, FleshBomb_SPELL_ID )
            call AddUnitHeroAbility( d, Metamorphosis_SPELL_ID )
            call AddUnitHeroAbility( d, UtilizationOfRests_SPELL_ID )
            call SetUnitTypeImage( d, "ReplaceableTextures\\CommandButtons\\BTNHeroDeathKnight.blp" )
            call SetUnitTypeImpactZ( d, 115 )
            call SetUnitTypeMaxLife( d, 300 )
            call SetUnitTypeMaxMana( d, 100 )
            call SetUnitTypeScale( d, 1.15 )
            call SetUnitTypeSightRange( d, 800 )
            call AddUnitTypePissedSound( d, BLACK_KNIGHT_PISSED_SOUND_TYPE )
            call AddUnitTypePissedSound( d, BLACK_KNIGHT_PISSED2_SOUND_TYPE )
            call AddUnitTypePissedSound( d, BLACK_KNIGHT_PISSED3_SOUND_TYPE )
            call AddUnitTypePissedSound( d, BLACK_KNIGHT_PISSED4_SOUND_TYPE )
            call AddUnitTypePissedSound( d, BLACK_KNIGHT_PISSED5_SOUND_TYPE )
            call AddUnitTypePissedSound( d, BLACK_KNIGHT_PISSED6_SOUND_TYPE )
            call SetUnitTypeSpeed( d, 320 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            call SetUnitTypeAgility( d, 12 )
            call SetUnitTypeAgilityPerLevel( d, 0.6 )
            call SetUnitTypeIntelligence( d, 17 )
            call SetUnitTypeIntelligencePerLevel( d, 2.4 )
            call SetUnitTypePrimaryAttribute( d, 1 )
            call SetUnitTypeStrength( d, 23 )
            call SetUnitTypeStrengthPerLevel( d, 3.3 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer LICH_UNIT_ID = 'U00A'
            endglobals

            // Lich
            set d = InitUnitTypeEx( LICH_UNIT_ID )
            call AddUnitTypeAbility( d, FuneralFeast_SPELL_ID )
            call AddUnitTypeAbility( d, SuddenFrost_SPELL_ID )
            call SetUnitTypeArmor( d, -2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_HERO )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Undead\\UndeadLargeDeathExplode\\UndeadLargeDeathExplode.mdl" )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 4 )
            call SetUnitTypeDamageType( d, DMG_TYPE_MAGIC )
            call SetUnitTypeDrop( d, 50 )
            call SetUnitTypeEP( d, 50 )
            call AddUnitHeroAbility( d, IceBall_SPELL_ID )
            call AddUnitHeroAbility( d, LastGrave_SPELL_ID )
            call AddUnitHeroAbility( d, LifeDrain_SPELL_ID )
            call AddUnitHeroAbility( d, ManaTheft_SPELL_ID )
            call SetUnitTypeImage( d, "ReplaceableTextures\\CommandButtons\\BTNHeroLich.blp" )
            call SetUnitTypeImpactZ( d, 69 )
            call SetUnitTypeMaxLife( d, 300 )
            call SetUnitTypeMaxMana( d, 100 )
            call SetUnitTypeScale( d, 1.15 )
            call SetUnitTypeSightRange( d, 800 )
            call AddUnitTypePissedSound( d, LICH_PISSED_SOUND_TYPE )
            call AddUnitTypePissedSound( d, LICH_PISSED2_SOUND_TYPE )
            call AddUnitTypePissedSound( d, LICH_PISSED3_SOUND_TYPE )
            call AddUnitTypePissedSound( d, LICH_PISSED4_SOUND_TYPE )
            call AddUnitTypePissedSound( d, LICH_PISSED5_SOUND_TYPE )
            call SetUnitTypeSpeed( d, 290 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            call SetUnitTypeAgility( d, 17 )
            call SetUnitTypeAgilityPerLevel( d, 1.65 )
            call SetUnitTypeIntelligence( d, 20 )
            call SetUnitTypeIntelligencePerLevel( d, 3.45 )
            call SetUnitTypePrimaryAttribute( d, 3 )
            call SetUnitTypeStrength( d, 12 )
            call SetUnitTypeStrengthPerLevel( d, 0.75 )

            call AddUnitTypeResearchTypeId( d, SecondaryTalent_RESEARCH_ID )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer ZOMBIE_LEVEL1_UNIT_ID = 'n008'
            endglobals

            // Zombie (Level 1)
            set d = InitUnitTypeEx( ZOMBIE_LEVEL1_UNIT_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Demon\\DemonLargeDeathExplode\\DemonLargeDeathExplode.mdl" )
            call SetUnitTypeCanNotBeRevived(d)
            call SetUnitTypeDamage( d, 19 )
            call SetUnitTypeDamageDices( d, 1 )
            call SetUnitTypeDamageDicesSides( d, 8 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 22 )
            call SetUnitTypeEP( d, 20 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeMaxLife( d, 240 )
            call SetUnitTypeScale( d, 1.3 )
            call SetUnitTypeSightRange( d, 500 )
            call SetUnitTypeSpeed( d, 300 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer ZOMBIE_LEVEL2_UNIT_ID = 'n009'
            endglobals

            // Zombie (Level 2)
            set d = InitUnitTypeEx( ZOMBIE_LEVEL2_UNIT_ID )
            call SetUnitTypeArmor( d, 1 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Demon\\DemonLargeDeathExplode\\DemonLargeDeathExplode.mdl" )
            call SetUnitTypeCanNotBeRevived(d)
            call SetUnitTypeDamage( d, 24 )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 3 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 24 )
            call SetUnitTypeEP( d, 21 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeMaxLife( d, 330 )
            call SetUnitTypeScale( d, 1.35 )
            call SetUnitTypeSightRange( d, 500 )
            call SetUnitTypeSpeed( d, 300 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer ZOMBIE_LEVEL3_UNIT_ID = 'n00A'
            endglobals

            // Zombie (Level 3)
            set d = InitUnitTypeEx( ZOMBIE_LEVEL3_UNIT_ID )
            call SetUnitTypeArmor( d, 1 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Demon\\DemonLargeDeathExplode\\DemonLargeDeathExplode.mdl" )
            call SetUnitTypeCanNotBeRevived(d)
            call SetUnitTypeDamage( d, 26 )
            call SetUnitTypeDamageDices( d, 3 )
            call SetUnitTypeDamageDicesSides( d, 3 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 26 )
            call SetUnitTypeEP( d, 23 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeMaxLife( d, 410 )
            call SetUnitTypeScale( d, 1.5 )
            call SetUnitTypeSightRange( d, 500 )
            call SetUnitTypeSpeed( d, 300 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer ZOMBIE_LEVEL4_UNIT_ID = 'n02B'
            endglobals

            // Zombie (Level 4)
            set d = InitUnitTypeEx( ZOMBIE_LEVEL4_UNIT_ID )
            call AddUnitTypeAbility( d, Bash_Zombie_Zombie_SPELL_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Demon\\DemonLargeDeathExplode\\DemonLargeDeathExplode.mdl" )
            call SetUnitTypeCanNotBeRevived(d)
            call SetUnitTypeDamage( d, 29 )
            call SetUnitTypeDamageDices( d, 3 )
            call SetUnitTypeDamageDicesSides( d, 3 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 28 )
            call SetUnitTypeEP( d, 26 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeMaxLife( d, 480 )
            call SetUnitTypeScale( d, 1.6 )
            call SetUnitTypeSightRange( d, 500 )
            call SetUnitTypeSpeed( d, 300 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer ZOMBIE_LEVEL5_UNIT_ID = 'n02C'
            endglobals

            // Zombie (Level 5)
            set d = InitUnitTypeEx( ZOMBIE_LEVEL5_UNIT_ID )
            call AddUnitTypeAbility( d, Bash_Zombie_Zombie_SPELL_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Demon\\DemonLargeDeathExplode\\DemonLargeDeathExplode.mdl" )
            call SetUnitTypeCanNotBeRevived(d)
            call SetUnitTypeDamage( d, 33 )
            call SetUnitTypeDamageDices( d, 3 )
            call SetUnitTypeDamageDicesSides( d, 4 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 30 )
            call SetUnitTypeEP( d, 28 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeMaxLife( d, 520 )
            call SetUnitTypeScale( d, 1.7 )
            call SetUnitTypeSightRange( d, 500 )
            call SetUnitTypeSpeed( d, 300 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer RESEARCH_CENTER_UNDEAD_UNIT_ID = 'u00E'
            endglobals

            // Research Center (Undead, Page 1)
            set d = InitUnitTypeEx( RESEARCH_CENTER_UNDEAD_UNIT_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Undead\\UCancelDeath\\UCancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeImpactZ( d, 120 )
            call SetUnitTypeMaxLife( d, 500 )
            call SetUnitTypeScale( d, 0.75 )
            call SetUnitTypeSightRange( d, 400 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer RESEARCH_CENTER_UNDEAD_PAGE_2_UNIT_ID = 'u00G'
            endglobals

            // Research Center (Undead, Page 2)
            set d = InitUnitTypeEx( RESEARCH_CENTER_UNDEAD_PAGE_2_UNIT_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Undead\\UCancelDeath\\UCancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeImpactZ( d, 120 )
            call SetUnitTypeMaxLife( d, 500 )
            call SetUnitTypeScale( d, 0.75 )
            call SetUnitTypeSightRange( d, 400 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
        endfunction
    endscope

    scope Nightelf
        public function Nightelf_Init takes nothing returns nothing
            local UnitType d

            globals
                constant integer MOON_WELL_UNIT_ID = 'e008'
            endglobals

            // Moon Well
            set d = InitUnitTypeEx( MOON_WELL_UNIT_ID )
            call AddUnitTypeAbility( d, GHOST_SPELL_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call SetUnitTypeMaxLife( d, 150000 )
            call SetUnitTypeScale( d, 1.4 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeUpgradesInstantly( d )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 200)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer NIGHTELF_TIER1_UNIT_ID = 'e000'
            endglobals

            // Nightelf - Tier 1
            set d = InitUnitTypeEx( NIGHTELF_TIER1_UNIT_ID )
            call AddUnitTypeAbility( d, AdvancedTraining_SPELL_ID )
            call AddUnitTypeAbility( d, LifeRegenerationAura_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\NightElf\\NECancelDeath\\NECancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeImpactZ( d, 160 )
            call SetUnitTypeMaxLife( d, 4000 )
            call SetUnitTypeScale( d, 0.8 )
            call SetUnitTypeSightRange( d, 1000 )
            call AddShopUnitSupply( d, RESERVE_UNIT_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeSupplyProduced( d, 12 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer ARCHER_UNIT_ID = 'e001'
            endglobals

            // Archer
            set d = InitUnitTypeEx( ARCHER_UNIT_ID )
            call AddUnitTypeAbility( d, ShadowMeld_SPELL_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\NightElf\\NightElfBlood\\NightElfBloodArcher.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\NightElf\\NightElfSmallDeathExplode\\NightElfSmallDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 13 )
            call SetUnitTypeDamageDices( d, 1 )
            call SetUnitTypeDamageDicesSides( d, 3 )
            call SetUnitTypeDamageType( d, DMG_TYPE_PIERCE )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 21 )
            call SetUnitTypeEP( d, 26 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 0.7 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 280 )
            call SetUnitTypeScale( d, 1 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 290 )
            call SetUnitTypeVertexColor(d, 210, 210, 210, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer NIGHTELF_TIER2_UNIT_ID = 'e002'
            endglobals

            // Nightelf - Tier 2
            set d = InitUnitTypeEx( NIGHTELF_TIER2_UNIT_ID )
            call AddUnitTypeAbility( d, AdvancedTraining_SPELL_ID )
            call AddUnitTypeAbility( d, LifeRegenerationAura_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\NightElf\\NECancelDeath\\NECancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeGoldCost( d, 1250 )
            call SetUnitTypeImpactZ( d, 120 )
            call SetUnitTypeMaxLife( d, 5000 )
            call SetUnitTypeScale( d, 0.95 )
            call SetUnitTypeSightRange( d, 1000 )
            call AddShopUnitSupply( d, RESERVE_UNIT_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeSupplyProduced( d, 16 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer HUNTRESS_UNIT_ID = 'e003'
            endglobals

            // Huntress
            set d = InitUnitTypeEx( HUNTRESS_UNIT_ID )
            call AddUnitTypeAbility( d, AttackDerivation_SPELL_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_UNARMORED )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\NightElf\\NightElfBlood\\NightElfBloodHuntress.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\NightElf\\NightElfSmallDeathExplode\\NightElfSmallDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 15 )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 2 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 26 )
            call SetUnitTypeEP( d, 29 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 0.8 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 480 )
            call SetUnitTypeScale( d, 1 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 330 )
            call SetUnitTypeVertexColor(d, 210, 210, 210, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            call AddUnitTypeResearchTypeId( d, AttackDerivation_RESEARCH_ID )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer NIGHTELF_TIER3_UNIT_ID = 'e004'
            endglobals

            // Nightelf - Tier 3
            set d = InitUnitTypeEx( NIGHTELF_TIER3_UNIT_ID )
            call AddUnitTypeAbility( d, AdvancedTraining_SPELL_ID )
            call AddUnitTypeAbility( d, LifeRegenerationAura_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\NightElf\\NECancelDeath\\NECancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeGoldCost( d, 1750 )
            call SetUnitTypeImpactZ( d, 120 )
            call SetUnitTypeMaxLife( d, 6000 )
            call SetUnitTypeScale( d, 0.95 )
            call SetUnitTypeSightRange( d, 1000 )
            call AddShopUnitSupply( d, RESERVE_UNIT_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeSupplyProduced( d, 20 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer DRYAD_UNIT_ID = 'e005'
            endglobals

            // Dryad
            set d = InitUnitTypeEx( DRYAD_UNIT_ID )
            call AddUnitTypeAbility( d, Neutralization_SPELL_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_UNARMORED )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\NightElf\\NightElfBlood\\NightElfBloodDryad.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\NightElf\\NightElfSmallDeathExplode\\NightElfSmallDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 10 )
            call SetUnitTypeDamageDices( d, 1 )
            call SetUnitTypeDamageDicesSides( d, 3 )
            call SetUnitTypeDamageType( d, DMG_TYPE_PIERCE )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 20 )
            call SetUnitTypeEP( d, 20 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 0.8 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 460 )
            call SetUnitTypeScale( d, 0.9 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpawnBonus( d, 1 )
            call SetUnitTypeSpeed( d, 350 )
            call SetUnitTypeVertexColor(d, 210, 210, 210, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            call AddUnitTypeResearchTypeId( d, Neutralization_RESEARCH_ID )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer NIGHTELF_TIER4_UNIT_ID = 'e006'
            endglobals

            // Nightelf - Tier 4
            set d = InitUnitTypeEx( NIGHTELF_TIER4_UNIT_ID )
            call AddUnitTypeAbility( d, AdvancedTraining_SPELL_ID )
            call AddUnitTypeAbility( d, LifeRegenerationAura_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\NightElf\\NECancelDeath\\NECancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeGoldCost( d, 2250 )
            call SetUnitTypeImpactZ( d, 120 )
            call SetUnitTypeMaxLife( d, 7000 )
            call SetUnitTypeScale( d, 1 )
            call SetUnitTypeSightRange( d, 1000 )
            call AddShopUnitSupply( d, RESERVE_UNIT_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeSupplyProduced( d, 24 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer MOUNTAIN_GIANT_UNIT_ID = 'e007'
            endglobals

            // Mountain Giant
            set d = InitUnitTypeEx( MOUNTAIN_GIANT_UNIT_ID )
            call AddUnitTypeAbility( d, SelfHeal_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeDamage( d, 20 )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 7 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 35 )
            call SetUnitTypeEP( d, 36 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 1 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 845 )
            call SetUnitTypeScale( d, 0.7 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 270 )
            call SetUnitTypeVertexColor(d, 210, 210, 210, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer DRUID_OF_THE_TALON_UNIT_ID = 'e00H'
            endglobals

            // Druid of the Talon
            set d = InitUnitTypeEx( DRUID_OF_THE_TALON_UNIT_ID )
            call AddUnitTypeAbility( d, VioletDefense_SPELL_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_UNARMORED )
            call SetUnitTypeAutomaticAbility( d, VioletDefense_SPELL_ID )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\NightElf\\NightElfBlood\\NightElfBloodDruidoftheTalon.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\NightElf\\NightElfLargeDeathExplode\\NightElfLargeDeathExplode.mdl" )
            call SetUnitTypeCaster( d )
            call SetUnitTypeDamage( d, 9 )
            call SetUnitTypeDamageDices( d, 1 )
            call SetUnitTypeDamageDicesSides( d, 5 )
            call SetUnitTypeDamageType( d, DMG_TYPE_MAGIC )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 20 )
            call SetUnitTypeEP( d, 24 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 0.4 * REGENERATION_INTERVAL )
            call SetUnitTypeManaRegeneration( d, 0.9 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 225 )
            call SetUnitTypeMaxMana( d, 200 )
            call SetUnitTypeScale( d, 1 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 285 )
            call SetUnitTypeStartMana( d, 135 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer BOTANIST_UNIT_ID = 'E00A'
            endglobals

            // Botanist
            set d = InitUnitTypeEx( BOTANIST_UNIT_ID )
            call SetUnitTypeArmor( d, -2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_HERO )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\NightElf\\NightElfBlood\\NightElfBloodHeroKeeperoftheGrove.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\NightElf\\NightElfSmallDeathExplode\\NightElfSmallDeathExplode.mdl" )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 4 )
            call SetUnitTypeDamageType( d, DMG_TYPE_MAGIC )
            call SetUnitTypeDrop( d, 50 )
            call SetUnitTypeEP( d, 50 )
            call AddUnitHeroAbility( d, Fertilizer_SPELL_ID )
            call AddUnitHeroAbility( d, NaturalEmbrace_SPELL_ID )
            //call AddUnitHeroAbility( d, TonelessMist_SPELL_ID )
            call AddUnitHeroAbility( d, WonderSeeds_SPELL_ID )
            call SetUnitTypeImage( d, "ReplaceableTextures\\CommandButtons\\BTNKeeperOfTheGroove.blp" )
            call SetUnitTypeImpactZ( d, 69 )
            call SetUnitTypeMaxLife( d, 300 )
            call SetUnitTypeMaxMana( d, 100 )
            call SetUnitTypeScale( d, 1.15 )
            call SetUnitTypeSightRange( d, 800 )
            call AddUnitTypePissedSound( d, BOTANIST_PISSED_SOUND_TYPE )
            call AddUnitTypePissedSound( d, BOTANIST_PISSED2_SOUND_TYPE )
            call AddUnitTypePissedSound( d, BOTANIST_PISSED3_SOUND_TYPE )
            call AddUnitTypePissedSound( d, BOTANIST_PISSED4_SOUND_TYPE )
            call AddUnitTypePissedSound( d, BOTANIST_PISSED5_SOUND_TYPE )
            call AddUnitTypePissedSound( d, BOTANIST_PISSED6_SOUND_TYPE )
            call SetUnitTypeSpeed( d, 320 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            call SetUnitTypeAgility( d, 15 )
            call SetUnitTypeAgilityPerLevel( d, 0.75 )
            call SetUnitTypeIntelligence( d, 18 )
            call SetUnitTypeIntelligencePerLevel( d, 1.35 )
            call SetUnitTypePrimaryAttribute( d, 3 )
            call SetUnitTypeStrength( d, 16 )
            call SetUnitTypeStrengthPerLevel( d, 0.9 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer TREANT_UNIT_ID = 'e00B'
            endglobals

            // Treant
            set d = InitUnitTypeEx( TREANT_UNIT_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_LARGE )
            call SetUnitTypeDamage( d, 14 )
            call SetUnitTypeDamageDices( d, 1 )
            call SetUnitTypeDamageDicesSides( d, 3 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 15 )
            call SetUnitTypeEP( d, 15 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 0.7 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 300 )
            call SetUnitTypeScale( d, 1.15 )
            call SetUnitTypeSightRange( d, 500 )
            call SetUnitTypeSpeed( d, 320 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer HEADHUNTRESS_UNIT_ID = 'E00C'
            endglobals

            // Headhuntress
            set d = InitUnitTypeEx( HEADHUNTRESS_UNIT_ID )
            call AddUnitTypeAbility( d, KidneyShot_SPELL_ID )
            call AddUnitTypeAbility( d, Libertine_SPELL_ID )
            call SetUnitTypeArmor( d, -2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_HERO )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\NightElf\\NightElfBlood\\NightElfBloodHeroMoonPriestess.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\NightElf\\NightElfSmallDeathExplode\\NightElfSmallDeathExplode.mdl" )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 6 )
            call SetUnitTypeDamageType( d, DMG_TYPE_PIERCE )
            call SetUnitTypeDrop( d, 50 )
            call SetUnitTypeEP( d, 50 )
            call AddUnitHeroAbility( d, Barrage_SPELL_ID )
            call AddUnitHeroAbility( d, EasyPrey_SPELL_ID )
            call AddUnitHeroAbility( d, KittyJump_SPELL_ID )
            call AddUnitHeroAbility( d, SpellDisconnection_SPELL_ID )
            call SetUnitTypeImage( d, "ReplaceableTextures\\CommandButtons\\BTNPriestessOfTheMoon.blp" )
            call SetUnitTypeImpactZ( d, 69 )
            call SetUnitTypeMaxLife( d, 300 )
            call SetUnitTypeMaxMana( d, 100 )
            call SetUnitTypeScale( d, 1.15 )
            call SetUnitTypeSightRange( d, 800 )
            call AddUnitTypePissedSound( d, HEADHUNTRESS_PISSED_SOUND_TYPE )
            call AddUnitTypePissedSound( d, HEADHUNTRESS_PISSED2_SOUND_TYPE )
            call AddUnitTypePissedSound( d, HEADHUNTRESS_PISSED3_SOUND_TYPE )
            call AddUnitTypePissedSound( d, HEADHUNTRESS_PISSED4_SOUND_TYPE )
            call AddUnitTypePissedSound( d, HEADHUNTRESS_PISSED5_SOUND_TYPE )
            call SetUnitTypeSpeed( d, 320 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            call SetUnitTypeAgility( d, 21 )
            call SetUnitTypeAgilityPerLevel( d, 3.15 )
            call SetUnitTypeIntelligence( d, 14 )
            call SetUnitTypeIntelligencePerLevel( d, 1.2 )
            call SetUnitTypePrimaryAttribute( d, 2 )
            call SetUnitTypeStrength( d, 17 )
            call SetUnitTypeStrengthPerLevel( d, 2.2 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer RESEARCH_CENTER_NIGHTELF_UNIT_ID = 'e00G'
            endglobals

            // Research Center (Nightelf, Page 1)
            set d = InitUnitTypeEx( RESEARCH_CENTER_NIGHTELF_UNIT_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\NightElf\\NECancelDeath\\NECancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeImpactZ( d, 120 )
            call SetUnitTypeMaxLife( d, 500 )
            call SetUnitTypeScale( d, 0.75 )
            call SetUnitTypeSightRange( d, 400 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer RESEARCH_CENTER_NIGHTELF_PAGE_2_UNIT_ID = 'e00I'
            endglobals

            // Research Center (Nightelf, Page 2)
            set d = InitUnitTypeEx( RESEARCH_CENTER_NIGHTELF_PAGE_2_UNIT_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\NightElf\\NECancelDeath\\NECancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeImpactZ( d, 120 )
            call SetUnitTypeMaxLife( d, 500 )
            call SetUnitTypeScale( d, 0.75 )
            call SetUnitTypeSightRange( d, 400 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
        endfunction
    endscope

    scope Naga
        public function Naga_Init takes nothing returns nothing
            local UnitType d

            globals
                constant integer CORAL_BED_UNIT_ID = 'n01R'
            endglobals

            // Coral Bed
            set d = InitUnitTypeEx( CORAL_BED_UNIT_ID )
            call AddUnitTypeAbility( d, GHOST_SPELL_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call SetUnitTypeMaxLife( d, 150000 )
            call SetUnitTypeScale( d, 1.4 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeUpgradesInstantly( d )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 200)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer NAGA_TIER1_UNIT_ID = 'n01S'
            endglobals

            // Naga - Tier 1
            set d = InitUnitTypeEx( NAGA_TIER1_UNIT_ID )
            call AddUnitTypeAbility( d, AdvancedTraining_SPELL_ID )
            call AddUnitTypeAbility( d, LifeRegenerationAura_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeImpactZ( d, 160 )
            call SetUnitTypeMaxLife( d, 4000 )
            call SetUnitTypeScale( d, 0.8 )
            call SetUnitTypeSightRange( d, 1000 )
            call AddShopUnitSupply( d, RESERVE_UNIT_ID )
            call SetUnitTypeStartMana( d, 40 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeSupplyProduced( d, 12 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer MURGUL_REAVER_UNIT_ID = 'n030'
            endglobals

            // Murgul Reaver
            set d = InitUnitTypeEx( MURGUL_REAVER_UNIT_ID )
            call AddUnitTypeAbility( d, Feedback_SPELL_ID )
            call SetUnitTypeArmor( d, 1 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_LARGE )
            call SetUnitTypeBlood( d, "" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Demon\\DemonSmallDeathExplode\\DemonSmallDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 10 )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 2 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 28 )
            call SetUnitTypeDrop( d, 26 )
            call SetUnitTypeEP( d, 29 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 0.75 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 420 )
            call SetUnitTypeScale( d, 1.2 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 270 )
            call SetUnitTypeVertexColor(d, 230, 230, 230, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            call AddUnitTypeResearchTypeId( d, Feedback_RESEARCH_ID )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer NAGA_TIER2_UNIT_ID = 'n01T'
            endglobals

            // Naga - Tier 2
            set d = InitUnitTypeEx( NAGA_TIER2_UNIT_ID )
            call AddUnitTypeAbility( d, AdvancedTraining_SPELL_ID )
            call AddUnitTypeAbility( d, LifeRegenerationAura_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeGoldCost( d, 1250 )
            call SetUnitTypeImpactZ( d, 120 )
            call SetUnitTypeMaxLife( d, 5000 )
            call SetUnitTypeScale( d, 0.9 )
            call SetUnitTypeSightRange( d, 1000 )
            call AddShopUnitSupply( d, RESERVE_UNIT_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeSupplyProduced( d, 16 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer DRAGON_TURTLE_UNIT_ID = 'n01X'
            endglobals

            // Dragon Turtle
            set d = InitUnitTypeEx( DRAGON_TURTLE_UNIT_ID )
            call AddUnitTypeAbility( d, ToadReflection_SPELL_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_LARGE )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Orc\\Orcblood\\OrcBloodHellScream.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Orc\\OrcLargeDeathExplode\\OrcLargeDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 19 )
            call SetUnitTypeDamageDices( d, 1 )
            call SetUnitTypeDamageDicesSides( d, 7 )
            call SetUnitTypeDamageType( d, DMG_TYPE_SIEGE )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 27 )
            call SetUnitTypeEP( d, 28 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 1.2 * REGENERATION_INTERVAL )
            call SetUnitTypeMelee( d )
            call SetUnitTypeMaxLife( d, 500 )
            call SetUnitTypeScale( d, 0.7 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 270 )
            call SetUnitTypeVertexColor(d, 210, 210, 210, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer NAGA_TIER3_UNIT_ID = 'n01U'
            endglobals

            // Naga - Tier 3
            set d = InitUnitTypeEx( NAGA_TIER3_UNIT_ID )
            call AddUnitTypeAbility( d, AdvancedTraining_SPELL_ID )
            call AddUnitTypeAbility( d, LifeRegenerationAura_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeGoldCost( d, 1750 )
            call SetUnitTypeImpactZ( d, 120 )
            call SetUnitTypeMaxLife( d, 6000 )
            call SetUnitTypeScale( d, 0.75 )
            call SetUnitTypeSightRange( d, 1000 )
            call AddShopUnitSupply( d, RESERVE_UNIT_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeSupplyProduced( d, 20 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer MYRMIDON_UNIT_ID = 'n01Y'
            endglobals

            // Myrmidon
            set d = InitUnitTypeEx( MYRMIDON_UNIT_ID )
            call AddUnitTypeAbility( d, Slam_SPELL_ID )
            call SetUnitTypeArmor( d, 1 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Orc\\Orcblood\\OrcBloodTauren.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Orc\\OrcSmallDeathExplode\\OrcSmallDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 12 )
            call SetUnitTypeDamageDices( d, 3 )
            call SetUnitTypeDamageDicesSides( d, 4 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 30 )
            call SetUnitTypeEP( d, 33 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 3 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 565 )
            call SetUnitTypeScale( d, 0.9 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 320 )
            call SetUnitTypeVertexColor(d, 210, 210, 210, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer NAGA_TIER4_UNIT_ID = 'n01V'
            endglobals

            // Naga - Tier 4
            set d = InitUnitTypeEx( NAGA_TIER4_UNIT_ID )
            call AddUnitTypeAbility( d, AdvancedTraining_SPELL_ID )
            call AddUnitTypeAbility( d, LifeRegenerationAura_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeGoldCost( d, 2250 )
            call SetUnitTypeImpactZ( d, 120 )
            call SetUnitTypeMaxLife( d, 7000 )
            call SetUnitTypeScale( d, 0.75 )
            call SetUnitTypeSightRange( d, 1000 )
            call AddShopUnitSupply( d, RESERVE_UNIT_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeSupplyProduced( d, 24 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer SNAP_DRAGON_UNIT_ID = 'n01Z'
            endglobals

            // Snap Dragon
            set d = InitUnitTypeEx( SNAP_DRAGON_UNIT_ID )
            call AddUnitTypeAbility( d, SlowPoison_SPELL_ID )
            call SetUnitTypeArmor( d, 1 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_LIGHT )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Orc\\Orcblood\\OrcBloodGrunt.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Orc\\OrcSmallDeathExplode\\OrcSmallDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 21 )
            call SetUnitTypeDamageDices( d, 1 )
            call SetUnitTypeDamageDicesSides( d, 7 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 31 )
            call SetUnitTypeEP( d, 32 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 1 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 480 )
            call SetUnitTypeScale( d, 0.95 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 300 )
            call SetUnitTypeVertexColor(d, 210, 210, 210, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            call AddUnitTypeResearchTypeId( d, SlowPoison_RESEARCH_ID )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer SIREN_UNIT_ID = 'n01W'
            endglobals

            // Siren
            set d = InitUnitTypeEx( SIREN_UNIT_ID )
            call AddUnitTypeAbility( d, BubbleArmor_SPELL_ID )
            call SetUnitTypeArmor( d, 1 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_UNARMORED )
            call SetUnitTypeAutomaticAbility( d, BubbleArmor_SPELL_ID )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Orc\\Orcblood\\OrcBloodWitchDoctor.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Orc\\OrcSmallDeathExplode\\OrcSmallDeathExplode.mdl" )
            call SetUnitTypeCaster( d )
            call SetUnitTypeDamage( d, 9 )
            call SetUnitTypeDamageDices( d, 1 )
            call SetUnitTypeDamageDicesSides( d, 4 )
            call SetUnitTypeDamageType( d, DMG_TYPE_MAGIC )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 20 )
            call SetUnitTypeEP( d, 24 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 0.4 * REGENERATION_INTERVAL )
            call SetUnitTypeManaRegeneration( d, 0.6 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 290 )
            call SetUnitTypeMaxMana( d, 120 )
            call SetUnitTypeScale( d, 1 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 290 )
            call SetUnitTypeStartMana( d, 120 )
            call SetUnitTypeVertexColor(d, 210, 210, 210, 255)
            call SetUnitTypeSupplyUsed( d, 1 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer RESEARCH_CENTER_NAGA_UNIT_ID = 'h00P'
            endglobals

            // Research Center (Naga, Page 1)
            set d = InitUnitTypeEx( RESEARCH_CENTER_NAGA_UNIT_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeImpactZ( d, 120 )
            call SetUnitTypeMaxLife( d, 500 )
            call SetUnitTypeScale( d, 0.75 )
            call SetUnitTypeSightRange( d, 400 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer RESEARCH_CENTER_NAGA_PAGE_2_UNIT_ID = 'h012'
            endglobals

            // Research Center (Naga, Page 2)
            set d = InitUnitTypeEx( RESEARCH_CENTER_NAGA_PAGE_2_UNIT_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeImpactZ( d, 120 )
            call SetUnitTypeMaxLife( d, 500 )
            call SetUnitTypeScale( d, 0.75 )
            call SetUnitTypeSightRange( d, 400 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
        endfunction
    endscope

    scope Miscellaneous
        public function Miscellaneous_Init takes nothing returns nothing
            local UnitType d

            globals
                constant integer TAVERN_UNIT_ID = 'n01K'
            endglobals

            // Tavern
            set d = InitUnitTypeEx( TAVERN_UNIT_ID )
            call AddUnitTypeAbility( d, GHOST_SPELL_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call SetUnitTypeMaxLife( d, 150000 )
            call SetUnitTypeScale( d, 1.4 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeUpgradesInstantly( d )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 200)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer FOUNTAIN_UNIT_ID = 'n000'
            endglobals

            // Fountain
            set d = InitUnitTypeEx( FOUNTAIN_UNIT_ID )
            call AddUnitTypeAbility( d, BUY_SHOP_ITEM_SPELL_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call AddUnitTypeAbility( d, ManaRegenerationAuraNeutral_SPELL_ID )
            call AddUnitTypeAbility( d, MightAura_SPELL_ID )
            call SetUnitTypeMaxLife( d, 150000 )
            call SetUnitTypeScale( d, 1.4 )
            call AddShopUnitSupply( d, ShopInformation_UNIT_ID )
            call AddShopItemSupply( d, ChaosSword_SET_ITEM_ID )
            call AddShopItemSupply( d, FrostArmor_SET_ITEM_ID )
            call AddShopItemSupply( d, HealingWard_ITEM_ID )
            call AddShopItemSupply( d, HeartOfTheHards_SET_ITEM_ID )
            call AddShopItemSupply( d, LifeArmor_SET_ITEM_ID )
            call AddShopItemSupply( d, MedaillonOfTheStrivingGod_SET_ITEM_ID )
            call AddShopItemSupply( d, MightyHammer_SET_ITEM_ID )
            call AddShopItemSupply( d, Nethermask_SET_ITEM_ID )
            call AddShopItemSupply( d, PrismaticCape_SET_ITEM_ID )
            call AddShopItemSupply( d, SuperCarrot_ITEM_ID )
            call AddShopItemSupply( d, WindBoots_SET_ITEM_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer GOBLIN_SHOP_UNIT_ID = 'h00R'
            endglobals

            // Goblin Shop
            set d = InitUnitTypeEx( GOBLIN_SHOP_UNIT_ID )
            call AddUnitTypeAbility( d, BUY_SHOP_ITEM_SPELL_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call AddUnitTypeAbility( d, SHARED_CONTROL_SPELL_ID )
            call SetUnitTypeMaxLife( d, 150000 )
            call SetUnitTypeScale( d, 1.25 )
            call SetUnitTypeShared(d)
            call SetUnitTypeSightRange( d, 500 )
            call AddShopUnitSupply( d, ShopInformation_UNIT_ID )
            call AddShopItemSupply( d, ChimeraEgg_ITEM_ID )
            call AddShopItemSupply( d, ElixirOfTheGrowth_ITEM_ID )
            //call AddShopItemSupply( d, FriendshipBracelet_ITEM_ID )
            call AddShopItemSupply( d, HealingPotion_ITEM_ID )
            call AddShopItemSupply( d, HealingPotionBloodOrange_ITEM_ID )
            call AddShopItemSupply( d, MecaPenguin_ITEM_ID )
            call AddShopItemSupply( d, ScrollOfRage_ITEM_ID )
            call AddShopItemSupply( d, SpiderEgg_ITEM_ID )
            call AddShopItemSupply( d, StaffOfAbolition_ITEM_ID )
            call AddShopItemSupply( d, TownPortal_ITEM_ID )
            call AddShopItemSupply( d, VolatileManaPotion_ITEM_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

           globals
                constant integer WORKSHOP_UNIT_ID = 'h010'
            endglobals

            // Workshop
            set d = InitUnitTypeEx( WORKSHOP_UNIT_ID )
            call AddUnitTypeAbility( d, BUY_SHOP_ITEM_SPELL_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call AddUnitTypeAbility( d, SHARED_CONTROL_SPELL_ID )
            call SetUnitTypeMaxLife( d, 150000 )
            call SetUnitTypeScale( d, 1.25 )
            call SetUnitTypeShared(d)
            call SetUnitTypeSightRange( d, 500 )
            call AddShopUnitSupply( d, ShopInformation_UNIT_ID )
            call AddShopItemSupply( d, CamouflageSuit_ITEM_ID )
            call AddShopItemSupply( d, ElectroNet_ITEM_ID )
            call AddShopUnitSupply( d, GLAIVE_THROWER_UNIT_ID )
            call AddShopItemSupply( d, Lens_ITEM_ID )
            call AddShopUnitSupply( d, SIEGE_TIN_UNIT_ID )
            call AddShopItemSupply( d, Trap_ITEM_ID )
            call AddShopUnitSupply( d, WORKER_UNIT_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer SECONDHAND_DEALER_UNIT_ID = 'o00H'
            endglobals

            // Secondhand Dealer
            set d = InitUnitTypeEx( SECONDHAND_DEALER_UNIT_ID )
            call AddUnitTypeAbility( d, BUY_SHOP_ITEM_SPELL_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call SetUnitTypeMaxLife( d, 150000 )
            call SetUnitTypeScale( d, 1.25 )
            call SetUnitTypeShared(d)
            call SetUnitTypeSightRange( d, 500 )
            call AddShopUnitSupply( d, ShopInformation_UNIT_ID )
            call AddShopItemSupply( d, AstralGauntlets_ITEM_ID )
            call AddShopItemSupply( d, BeltOfTheCelt_ITEM_ID )
            call AddShopItemSupply( d, FenixsFeather_ITEM_ID )
            call AddShopItemSupply( d, FlyingSheep_ITEM_ID )
            call AddShopItemSupply( d, FrozenShard_ITEM_ID )
            call AddShopItemSupply( d, GexxoSlippers_ITEM_ID )
            call AddShopItemSupply( d, GoldenRing_ITEM_ID )
            call AddShopItemSupply( d, Lollipop_MANUFACTURED_ITEM_ID )
            call AddShopItemSupply( d, IllusionaryStaff_ITEM_ID )
            call AddShopItemSupply( d, RobeOfThePope_ITEM_ID )
            call AddShopItemSupply( d, SpidermanSocks_ITEM_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer MARKET_UNIT_ID = 'h00W'
            endglobals

            // Market
            set d = InitUnitTypeEx( MARKET_UNIT_ID )
            call AddUnitTypeAbility( d, BUY_SHOP_ITEM_SPELL_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call SetUnitTypeMaxLife( d, 150000 )
            call SetUnitTypeScale( d, 1 )
            call AddShopUnitSupply( d, ShopInformation_UNIT_ID )
            call AddShopItemSupply( d, CareBear_ITEM_ID )
            call AddShopItemSupply( d, GiantAxe_ITEM_ID )
            call AddShopItemSupply( d, GloveOfTheBeast_ITEM_ID )
            call AddShopItemSupply( d, HeartStone_ITEM_ID )
            call AddShopItemSupply( d, JeweledDaggerOfGreed_ITEM_ID )
            call AddShopItemSupply( d, OrbOfWisdom_ITEM_ID )
            call AddShopItemSupply( d, PotionOfTheInconspicuousShape_ITEM_ID )
            call AddShopItemSupply( d, RegenerationPotion_ITEM_ID )
            call AddShopItemSupply( d, RhythmicDrum_ITEM_ID )
            call AddShopItemSupply( d, Trident_ITEM_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer FANATICAL_MECHANICIAN_UNIT_ID = 'N016'
            endglobals

            // FanaticalMechanician
            set d = InitUnitTypeEx( FANATICAL_MECHANICIAN_UNIT_ID )
            call SetUnitTypeArmor( d, -2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_HERO )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Other\\HumanBloodCinematicEffect\\HumanBloodCinematicEffect.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Human\\HumanLargeDeathExplode\\HumanLargeDeathExplode.mdl" )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 4 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDrop( d, 50 )
            call SetUnitTypeEP( d, 50 )
            //call AddUnitHeroAbility( d, BattleGolem_SPELL_ID )
            //call AddUnitHeroAbility( d, BlastFurnace_SPELL_ID )
            call SetUnitTypeImage( d, "ReplaceableTextures\\CommandButtons\\BTNHeroTinker.blp" )
            call SetUnitTypeImpactZ( d, 69 )
            call SetUnitTypeMaxLife( d, 300 )
            call SetUnitTypeMaxMana( d, 100 )
            call SetUnitTypeScale( d, 1.15 )
            call SetUnitTypeSightRange( d, 800 )
            call AddUnitTypePissedSound( d, FANATICAL_MECHANIC_PISSED_SOUND_TYPE )
            call AddUnitTypePissedSound( d, FANATICAL_MECHANIC_PISSED2_SOUND_TYPE )
            call AddUnitTypePissedSound( d, FANATICAL_MECHANIC_PISSED3_SOUND_TYPE )
            call AddUnitTypePissedSound( d, FANATICAL_MECHANIC_PISSED4_SOUND_TYPE )
            call AddUnitTypePissedSound( d, FANATICAL_MECHANIC_PISSED5_SOUND_TYPE )
            call AddUnitTypePissedSound( d, FANATICAL_MECHANIC_PISSED6_SOUND_TYPE )
            call AddUnitTypePissedSound( d, FANATICAL_MECHANIC_PISSED7_SOUND_TYPE )
            call AddUnitTypePissedSound( d, FANATICAL_MECHANIC_PISSED8_SOUND_TYPE )
            call SetUnitTypeSpeed( d, 300 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            call SetUnitTypeAgility( d, 7 )
            call SetUnitTypeAgilityPerLevel( d, 1 )
            call SetUnitTypeIntelligence( d, 18 )
            call SetUnitTypeIntelligencePerLevel( d, 2 )
            call SetUnitTypePrimaryAttribute( d, 3 )
            call SetUnitTypeStrength( d, 24 )
            call SetUnitTypeStrengthPerLevel( d, 3 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer BATTLE_GOLEM_LEVEL1_UNIT_ID = 'n018'
            endglobals

            // Battle Golem (Level 1)
            set d = InitUnitTypeEx( BATTLE_GOLEM_LEVEL1_UNIT_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeDamage( d, 15 )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 5 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeMaxLife( d, 500 )
            call SetUnitTypeScale( d, 1.15 )
            call SetUnitTypeSightRange( d, 400 )
            call SetUnitTypeSpeed( d, 160 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer BATTLE_GOLEM_LEVEL2_UNIT_ID = 'n019'
            endglobals

            // Battle Golem (Level 2)
            set d = InitUnitTypeEx( BATTLE_GOLEM_LEVEL2_UNIT_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeDamage( d, 20 )
            call SetUnitTypeDamageDices( d, 3 )
            call SetUnitTypeDamageDicesSides( d, 5 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeMaxLife( d, 700 )
            call SetUnitTypeScale( d, 1.15 )
            call SetUnitTypeSightRange( d, 400 )
            call SetUnitTypeSpeed( d, 160 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer BATTLE_GOLEM_LEVEL3_UNIT_ID = 'n01A'
            endglobals

            // Battle Golem (Level 3)
            set d = InitUnitTypeEx( BATTLE_GOLEM_LEVEL3_UNIT_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeDamage( d, 25 )
            call SetUnitTypeDamageDices( d, 4 )
            call SetUnitTypeDamageDicesSides( d, 5 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeMaxLife( d, 900 )
            call SetUnitTypeScale( d, 1.15 )
            call SetUnitTypeSightRange( d, 400 )
            call SetUnitTypeSpeed( d, 160 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer FLAG_UNIT_ID = 'n003'
            endglobals

            // Flag
            set d = InitUnitTypeEx( FLAG_UNIT_ID )
            call AddUnitTypeAbility( d, LifeRegenerationAura_SPELL_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 1 )
            call SetUnitTypeMaxLife( d, 1500 )
            call SetUnitTypeScale( d, 2.5 )
            call SetUnitTypeSightRange( d, 1000 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer WORKER_UNIT_ID = 'h00M'
            endglobals

            // Worker
            set d = InitUnitTypeEx( WORKER_UNIT_ID )
            //call AddUnitTypeAbility( d, HARVESTING_SPELL_ID )
            call AddUnitTypeAbility( d, REPAIR_SPELL_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Human\\HumanBlood\\HumanBloodFootman.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Human\\HumanSmallDeathExplode\\HumanSmallDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 15 )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 2 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 25 )
            call SetUnitTypeEP( d, 10 )
            call SetUnitTypeGoldCost( d, 125 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 0.5 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 165 )
            call SetUnitTypeScale( d, 1.25 )
            call SetUnitTypeShopMaxCharges( d, 3 )
            call SetUnitTypeShopRefreshInterval( d, 15 )
            call SetUnitTypeShopRefreshIntervalStart( d, 15 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 270 )
            call SetUnitTypeVertexColor(d, 210, 210, 210, 255)
            call SetUnitTypeSupplyUsed( d, 0 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer MERCENARY_CAMP_UNIT_ID = 'n00I'
            endglobals

            // Mercenary Camp
            set d = InitUnitTypeEx( MERCENARY_CAMP_UNIT_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call SetUnitTypeMaxLife( d, 150000 )
            call SetUnitTypeScale( d, 0.8 )
            call AddShopItemSupply( d, ShopInformation_ITEM_ID )
            call AddShopUnitSupply( d, ADJUTANT_UNIT_ID )
            call AddShopUnitSupply( d, BATTLE_SHIP_UNIT_ID )
            call AddShopUnitSupply( d, DIRE_WOLF_UNIT_ID )
            call AddShopUnitSupply( d, DOJO_THE_MOJO_UNIT_ID )
            call AddShopUnitSupply( d, DWARVES_UNIT_ID )
            call AddShopUnitSupply( d, FRIENDLY_WOMAN_UNIT_ID )
            call AddShopUnitSupply( d, ICE_TROLL_PRIEST_UNIT_ID )
            call AddShopUnitSupply( d, OGRE_BRAT_UNIT_ID )
            call AddShopUnitSupply( d, SILVER_TAIL_UNIT_ID )
            call AddShopUnitSupply( d, TAUREN_UNIT_ID )
            call AddShopUnitSupply( d, TUSKAR_UNIT_ID )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer TRAVELLING_TRADER_UNIT_ID = 'N00L'
            endglobals

            // Travelling Trader
            set d = InitUnitTypeEx( TRAVELLING_TRADER_UNIT_ID )
            call AddUnitTypeAbility( d, EmployHenchman_SPELL_ID )
            call AddUnitTypeAbility( d, EsteemInCoins_SPELL_ID )
            call SetUnitTypeArmor( d, -2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Other\\HumanBloodCinematicEffect\\HumanBloodCinematicEffect.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Human\\HumanLargeDeathExplode\\HumanLargeDeathExplode.mdl" )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 4 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDrop( d, 50 )
            call SetUnitTypeEP( d, 50 )
            call AddUnitHeroAbility( d, CrowdPuller_SPELL_ID )
            call AddUnitHeroAbility( d, FieryBoots_ACTIVATION_SPELL_ID )
            call AddUnitHeroAbility( d, Payday_SPELL_ID )
            call AddUnitHeroAbility( d, Sales_SPELL_ID )
            call SetUnitTypeImage( d, "ReplaceableTextures\\CommandButtons\\BTNHeroAlchemist.blp" )
            call SetUnitTypeImpactZ( d, 69 )
            call SetUnitTypeMaxLife( d, 300 )
            call SetUnitTypeMaxMana( d, 100 )
            call SetUnitTypeScale( d, 1.15 )
            call SetUnitTypeSightRange( d, 800 )
            call AddUnitTypePissedSound( d, TRAVELLING_TRADER_PISSED_SOUND_TYPE )
            call AddUnitTypePissedSound( d, TRAVELLING_TRADER_PISSED2_SOUND_TYPE )
            call AddUnitTypePissedSound( d, TRAVELLING_TRADER_PISSED3_SOUND_TYPE )
            call AddUnitTypePissedSound( d, TRAVELLING_TRADER_PISSED4_SOUND_TYPE )
            call AddUnitTypePissedSound( d, TRAVELLING_TRADER_PISSED5_SOUND_TYPE )
            call AddUnitTypePissedSound( d, TRAVELLING_TRADER_PISSED6_SOUND_TYPE )
            call SetUnitTypeSpeed( d, 290 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            call SetUnitTypeAgility( d, 16 )
            call SetUnitTypeAgilityPerLevel( d, 1.95 )
            call SetUnitTypeIntelligence( d, 15 )
            call SetUnitTypeIntelligencePerLevel( d, 1.5 )
            call SetUnitTypePrimaryAttribute( d, 1 )
            call SetUnitTypeStrength( d, 19 )
            call SetUnitTypeStrengthPerLevel( d, 2.7 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer MASTER_WIZARD_UNIT_ID = 'n00M'
            endglobals

            // Master Wizard
            set d = InitUnitTypeEx( MASTER_WIZARD_UNIT_ID )
            call AddUnitTypeAbility( d, CashDiscount_SPELL_ID )
            call AddUnitTypeAbility( d, ChainLightning_SPELL_ID )
            call AddUnitTypeAbility( d, DivineShield_SPELL_ID )
            call AddUnitTypeAbility( d, Downgrade_SPELL_ID )
            call AddUnitTypeAbility( d, EarlyPromotion_SPELL_ID )
            call AddUnitTypeAbility( d, Harmagedon2_SPELL_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call AddUnitTypeAbility( d, PoisonFountain_SPELL_ID )
            call AddUnitTypeAbility( d, RequestReinforcements_SPELL_ID )
            call AddUnitTypeAbility( d, STOP_EX_SPELL_ID )
            call AddUnitTypeAbility( d, SummonFaust_SPELL_ID )
            call AddUnitTypeAbility( d, SummonPeq_SPELL_ID )
            //call AddUnitTypeAbility( d, SwitchShops_SPELL_ID )
            call SetUnitTypeImpactZ( d, 100 )
            call SetUnitTypeManaRegeneration( d, 2 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 150000 )
            call SetUnitTypeMaxMana( d, 1000 )
            call SetUnitTypeScale( d, 1.5 )
            call SetUnitTypeShared(d)
            call SetUnitTypeSightRange( d, 500 )
            call SetUnitTypeStartMana( d, 100 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer POISONED_FOUNTAIN_UNIT_ID = 'n00O'
            endglobals

            // Poisoned Fountain
            set d = InitUnitTypeEx( POISONED_FOUNTAIN_UNIT_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call SetUnitTypeMaxLife( d, 150000 )
            call SetUnitTypeScale( d, 1.4 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer ALTAR_UNIT_ID = 'n00T'
            endglobals

            // Altar
            set d = InitUnitTypeEx( ALTAR_UNIT_ID )
            call AddUnitTypeAbility( d, GHOST_SPELL_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call SetUnitTypeMaxLife( d, 150000 )
            call SetUnitTypeScale( d, 1.4 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeUpgradesInstantly( d )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 200)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer CATAPULT_UNIT_ID = 'o00G'
            endglobals

            // Catapult
            set d = InitUnitTypeEx( CATAPULT_UNIT_ID )
            call AddUnitTypeAbility( d, ArtilleryAttack_SPELL_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Human\\HCancelDeath\\HCancelDeath.mdl" )
            call SetUnitTypeDamage( d, 35 )
            call SetUnitTypeDamageDices( d, 9 )
            call SetUnitTypeDamageDicesSides( d, 5 )
            call SetUnitTypeDamageType( d, DMG_TYPE_PIERCE )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 50 )
            call SetUnitTypeGoldCost( d, 450 )
            call SetUnitTypeImpactZ( d, 25 )
            call SetUnitTypeMaxLife( d, 800 )
            call SetUnitTypeMissileArc( d, 0.8 )
            call SetUnitTypeMissileDummyUnitId( d, 'n026' )
            call SetUnitTypeMissileSpeed( d, 1100 )
            call SetUnitTypeScale( d, 1.15 )
            call SetUnitTypeSightRange( d, 400 )
            call SetUnitTypeSpecialAttack( d )
            call SetUnitTypeSplash( d )
            call SetUnitTypeSplashAffectionAlly( d )
            call SetUnitTypeSplashAffectionEnemy( d )
            call SetUnitTypeSplashAffectionGround( d )
            call SetUnitTypeSplashAreaRange( d, 450 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer CHIMERA_UNIT_ID = 'e009'
            endglobals

            // Chimera
            set d = InitUnitTypeEx( CHIMERA_UNIT_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_LARGE )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\NightElf\\NightElfBlood\\NightElfBloodChimaera.mdl" )
            call SetUnitTypeCanNotBeRevived(d)
            call SetUnitTypeDamage( d, 36 )
            call SetUnitTypeDamageDices( d, 3 )
            call SetUnitTypeDamageDicesSides( d, 8 )
            call SetUnitTypeDamageType( d, DMG_TYPE_SIEGE )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 65 )
            call SetUnitTypeEP( d, 50 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 1 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 1400 )
            call SetUnitTypeScale( d, 1.25 )
            call SetUnitTypeSightRange( d, 700 )
            call SetUnitTypeSpeed( d, 270 )
            call SetUnitTypeSplash( d )
            call SetUnitTypeSplashAffectionAlly( d )
            call SetUnitTypeSplashAffectionEnemy( d )
            call SetUnitTypeSplashAffectionGround( d )
            call SetUnitTypeSplashAreaRange( d, 400 )
            call SetUnitTypeSplashDamageFactor( d, 0.7 )
            call SetUnitTypeSplashWindowAngle( d, 360 * RAD_TO_DEG )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer SPOUT_SPIDER_UNIT_ID = 'n00H'
            endglobals

            // Spout Spider
            set d = InitUnitTypeEx( SPOUT_SPIDER_UNIT_ID )
            call AddUnitTypeAbility( d, LayEgg_SPELL_ID )
            call SetUnitTypeArmor( d, 1 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_LARGE )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Undead\\UndeadBlood\\UndeadBloodCryptFiend.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Demon\\DemonLargeDeathExplode\\DemonLargeDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 27 )
            call SetUnitTypeDamageDices( d, 3 )
            call SetUnitTypeDamageDicesSides( d, 6 )
            call SetUnitTypeDamageType( d, DMG_TYPE_PIERCE )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 37 )
            call SetUnitTypeEP( d, 30 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 1.7 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 800 )
            call SetUnitTypeScale( d, 1.25 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 270 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer OGRE_BRAT_UNIT_ID = 'n00J'
            endglobals

            // Ogre Brat
            set d = InitUnitTypeEx( OGRE_BRAT_UNIT_ID )
            call AddUnitTypeAbility( d, Bash_OgreBrat_OgreBrat_SPELL_ID )
            call AddUnitTypeAbility( d, ShockWave_SPELL_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_LARGE )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Human\\HumanBlood\\HumanBloodKnight.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Orc\\OrcSmallDeathExplode\\OrcSmallDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 24 )
            call SetUnitTypeDamageDices( d, 4 )
            call SetUnitTypeDamageDicesSides( d, 7 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 48 )
            call SetUnitTypeEP( d, 44 )
            call SetUnitTypeGoldCost( d, 400 )
            call SetUnitTypeImpactZ( d, 100 )
            call SetUnitTypeLifeRegeneration( d, 2 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 1300 )
            call SetUnitTypeScale( d, 1.65 )
            call SetUnitTypeShopMaxCharges( d, 1 )
            call SetUnitTypeShopRefreshInterval( d, 100 )
            call SetUnitTypeShopRefreshIntervalStart( d, 220 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSupplyUsed( d, 0 )
            call SetUnitTypeSpeed( d, 270 )
            call SetUnitTypeVertexColor(d, 255, 160, 160, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer ICE_TROLL_PRIEST_UNIT_ID = 'n00K'
            endglobals

            // Ice Troll Priest
            set d = InitUnitTypeEx( ICE_TROLL_PRIEST_UNIT_ID )
            call AddUnitTypeAbility( d, FrostBolt_SPELL_ID )
            call AddUnitTypeAbility( d, Heal_SPELL_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeAutomaticAbility( d, Heal_SPELL_ID )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Orc\\Orcblood\\OrcBloodWitchDoctor.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Orc\\OrcSmallDeathExplode\\OrcSmallDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 16 )
            call SetUnitTypeDamageDices( d, 1 )
            call SetUnitTypeDamageDicesSides( d, 8 )
            call SetUnitTypeDamageType( d, DMG_TYPE_PIERCE )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 28 )
            call SetUnitTypeEP( d, 20 )
            call SetUnitTypeGoldCost( d, 200 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 0.5 * REGENERATION_INTERVAL )
            call SetUnitTypeManaRegeneration( d, 0.75 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 750 )
            call SetUnitTypeMaxMana( d, 200 )
            call SetUnitTypeScale( d, 1.5 )
            call SetUnitTypeShopMaxCharges( d, 2 )
            call SetUnitTypeShopRefreshInterval( d, 50 )
            call SetUnitTypeShopRefreshIntervalStart( d, 150 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 270 )
            call SetUnitTypeStartMana( d, 100 )
            call SetUnitTypeSupplyUsed( d, 0 )
            call SetUnitTypeVertexColor(d, 190, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer DOJO_THE_MOJO_UNIT_ID = 'n00Z'
            endglobals

            // Dojo the Mojo
            set d = InitUnitTypeEx( DOJO_THE_MOJO_UNIT_ID )
            call AddUnitTypeAbility( d, DiversionaryTactics_SPELL_ID )
            call AddUnitTypeAbility( d, Riposte_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_LARGE )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Orc\\Orcblood\\OrcBloodWitchDoctor.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Orc\\OrcSmallDeathExplode\\OrcSmallDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 17 )
            call SetUnitTypeDamageDices( d, 1 )
            call SetUnitTypeDamageDicesSides( d, 6 )
            call SetUnitTypeDamageType( d, DMG_TYPE_CHAOS )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 80 )
            call SetUnitTypeEP( d, 60 )
            call SetUnitTypeGoldCost( d, 600 )
            call SetUnitTypeImpactZ( d, 100 )
            call SetUnitTypeLifeRegeneration( d, 2.5 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 2250 )
            call SetUnitTypeScale( d, 1.45 )
            call SetUnitTypeShopMaxCharges( d, 1 )
            call SetUnitTypeShopRefreshInterval( d, 100 )
            call SetUnitTypeShopRefreshIntervalStart( d, 220 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 320 )
            call SetUnitTypeSupplyUsed( d, 0 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)


            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer TAUREN_UNIT_ID = 'o00I'
            endglobals

            // Tauren
            set d = InitUnitTypeEx( TAUREN_UNIT_ID )
            call AddUnitTypeAbility( d, Reincarnation_SPELL_ID )
            call SetUnitTypeArmor( d, 3 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_LARGE )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Orc\\Orcblood\\OrcBloodTauren.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Orc\\OrcLargeDeathExplode\\OrcLargeDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 49 )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 13 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 46 )
            call SetUnitTypeEP( d, 68 )
            call SetUnitTypeGoldCost( d, 500 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 3 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 1450 )
            call SetUnitTypeScale( d, 1.2 )
            call SetUnitTypeShopMaxCharges( d, 1 )
            call SetUnitTypeShopRefreshInterval( d, 40 )
            call SetUnitTypeShopRefreshIntervalStart( d, 300 )
            call SetUnitTypeSightRange( d, 430 )
            call SetUnitTypeSupplyUsed( d, 0 )
            call SetUnitTypeSpeed( d, 260 )
            call SetUnitTypeSplash( d )
            call SetUnitTypeSplashAffectionEnemy( d )
            call SetUnitTypeSplashAffectionGround( d )
            call SetUnitTypeSplashDamageFactor( d, 1 )
            call SetUnitTypeSplashAreaRange( d, 200 )
            call SetUnitTypeSplashWindowAngle( d, 360 * RAD_TO_DEG )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer FAUST_UNIT_ID = 'n00N'
            endglobals

            // Faust
            set d = InitUnitTypeEx( FAUST_UNIT_ID )
            call AddUnitTypeAbility( d, SHARED_CONTROL_SPELL_ID )
            call AddUnitTypeAbility( d, SummonFaust_AttackGraphic_AttackGraphic_SPELL_ID )
            call SetUnitTypeArmor( d, 8 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_HERO )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Undead\\UndeadBlood\\UndeadBloodAbomination.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Demon\\DemonLargeDeathExplode\\DemonLargeDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 45 )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 7 )
            call SetUnitTypeDamageType( d, DMG_TYPE_CHAOS )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 200 )
            call SetUnitTypeEP( d, 100 )
            call SetUnitTypeImpactZ( d, 135 )
            call SetUnitTypeLifeRegeneration( d, -9 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 3000 )
            call SetUnitTypeScale( d, 0.25 )
            call SetUnitTypeShared(d)
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 270 )
            call SetUnitTypeSplash( d )
            call SetUnitTypeSplashAffectionAir( d )
            call SetUnitTypeSplashAffectionEnemy( d )
            call SetUnitTypeSplashAffectionGround( d )
            call SetUnitTypeSplashDamageFactor( d, 0.6 )
            call SetUnitTypeSplashAreaRange( d, 250 )
            call SetUnitTypeSplashWindowAngle( d, 250 * RAD_TO_DEG )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer LIGHTNING_TOWER_UNIT_ID = 'o00F'
            endglobals

            // Lightning Tower
            set d = InitUnitTypeEx( LIGHTNING_TOWER_UNIT_ID )
            call AddUnitTypeAbility( d, LightningAttack_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Human\\HCancelDeath\\HCancelDeath.mdl" )
            call SetUnitTypeDamage( d, 30 )
            call SetUnitTypeDamageType( d, DMG_TYPE_MAGIC )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 45 )
            call SetUnitTypeGoldCost( d, 550 )
            call SetUnitTypeImpactZ( d, 80 )
            call SetUnitTypeMaxLife( d, 1200 )
            call SetUnitTypeScale( d, 1.15 )
            call SetUnitTypeSightRange( d, 500 )
            call SetUnitTypeSpecialAttack( d )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer GOLD_TOWER_UNIT_ID = 'h00C'
            endglobals

            // Gold Tower
            set d = InitUnitTypeEx( GOLD_TOWER_UNIT_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Human\\HCancelDeath\\HCancelDeath.mdl" )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 10 )
            call SetUnitTypeImpactZ( d, 120 )
            call SetUnitTypeMaxLife( d, 500 )
            call SetUnitTypeScale( d, 1.4 )
            call SetUnitTypeShared(d)
            call SetUnitTypeSightRange( d, 300 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer GUARD_TOWER_NEW_BUILD_UNIT_ID = 'h00D'
            endglobals

            // Guard Tower (New Build)
            set d = InitUnitTypeEx( GUARD_TOWER_NEW_BUILD_UNIT_ID )
            call AddUnitTypeAbility( d, SHARED_CONTROL_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Human\\HCancelDeath\\HCancelDeath.mdl" )
            call SetUnitTypeDamage( d, 20 )
            call SetUnitTypeDamageDices( d, 4 )
            call SetUnitTypeDamageDicesSides( d, 5 )
            call SetUnitTypeDamageType( d, DMG_TYPE_PIERCE )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeGoldCost( d, 250 )
            call SetUnitTypeImpactZ( d, 120 )
            call SetUnitTypeLifeRegeneration( d, 1 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 700 )
            call SetUnitTypeScale( d, 1.15 )
            call SetUnitTypeSightRange( d, 500 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer GUARD_TOWER_UPGRADE_UNIT_ID = 'h00S'
            endglobals

            // Guard Tower (Upgrade)
            set d = InitUnitTypeEx( GUARD_TOWER_UPGRADE_UNIT_ID )
            call AddUnitTypeAbility( d, SHARED_CONTROL_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Human\\HCancelDeath\\HCancelDeath.mdl" )
            call SetUnitTypeDamage( d, 20 )
            call SetUnitTypeDamageDices( d, 4 )
            call SetUnitTypeDamageDicesSides( d, 5 )
            call SetUnitTypeDamageType( d, DMG_TYPE_PIERCE )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeGoldCost( d, 250 )
            call SetUnitTypeImpactZ( d, 120 )
            call SetUnitTypeLifeRegeneration( d, 1 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 700 )
            call SetUnitTypeScale( d, 1.4 )
            call SetUnitTypeShared(d)
            call SetUnitTypeSightRange( d, 500 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer MECA_PENGUIN_UNIT_ID = 'n00G'
            endglobals

            // Meca Penguin
            set d = InitUnitTypeEx( MECA_PENGUIN_UNIT_ID )
            call SetUnitTypeDecay( d )
            call SetUnitTypeMaxLife( d, 100 )
            call SetUnitTypeScale( d, 1.5 )
            call SetUnitTypeSpeed( d, 170 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer MYSTICAL_TOWER_UNIT_ID = 'h00Q'
            endglobals

            // Mystical Tower
            set d = InitUnitTypeEx( MYSTICAL_TOWER_UNIT_ID )
            call AddUnitTypeAbility( d, MysticalAttack_SPELL_ID )
            call SetUnitTypeArmor( d, 10 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Human\\HCancelDeath\\HCancelDeath.mdl" )
            call SetUnitTypeDamage( d, 9 )
            call SetUnitTypeDamageDices( d, 3 )
            call SetUnitTypeDamageDicesSides( d, 5 )
            call SetUnitTypeDamageType( d, DMG_TYPE_MAGIC )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 100 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeMaxLife( d, 1000 )
            call SetUnitTypeScale( d, 1.25 )
            call SetUnitTypeSightRange( d, 500 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer PEQ_UNIT_ID = 'n01G'
            endglobals

            // Peq
            set d = InitUnitTypeEx( PEQ_UNIT_ID )
            call AddUnitTypeAbility( d, CripplingWave_SPELL_ID )
            call AddUnitTypeAbility( d, SHARED_CONTROL_SPELL_ID )
            call AddUnitTypeAbility( d, SummonPeqqiBeast_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_HERO )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Undead\\UndeadBlood\\UndeadBloodAbomination.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Demon\\DemonLargeDeathExplode\\DemonLargeDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 33 )
            call SetUnitTypeDamageDices( d, 3 )
            call SetUnitTypeDamageDicesSides( d, 6 )
            call SetUnitTypeDamageType( d, DMG_TYPE_PIERCE )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 250 )
            call SetUnitTypeEP( d, 150 )
            call SetUnitTypeImpactZ( d, 135 )
            call SetUnitTypeLifeRegeneration( d, -11 * REGENERATION_INTERVAL )
            call SetUnitTypeManaRegeneration( d, 3 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 2500 )
            call SetUnitTypeMaxMana( d, 1000 )
            call SetUnitTypeScale( d, 0.35 )
            call SetUnitTypeShared(d)
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 270 )
            call SetUnitTypeStartMana( d, 1000 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer PEQQI_BEAST_UNIT_ID = 'n001'
            endglobals

            // Peqqi Beast
            set d = InitUnitTypeEx( PEQQI_BEAST_UNIT_ID )
            call AddUnitTypeAbility( d, SHARED_CONTROL_SPELL_ID )
            call SetUnitTypeArmor( d, 1 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_LARGE )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Undead\\UndeadBlood\\UndeadBloodGargoyle.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Demon\\DemonLargeDeathExplode\\DemonLargeDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 10 )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 6 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDrop( d, 15 )
            call SetUnitTypeEP( d, 15 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 0.65 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 300 )
            call SetUnitTypeScale( d, 1.15 )
            call SetUnitTypeShared(d)
            call SetUnitTypeSightRange( d, 500 )
            call SetUnitTypeSpeed( d, 270 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer SILVER_TAIL_UNIT_ID = 'e00F'
            endglobals

            // Silver Tail
            set d = InitUnitTypeEx( SILVER_TAIL_UNIT_ID )
            call AddUnitTypeAbility( d, Evasion_SILVER_TAIL_SPELL_ID )
            call AddUnitTypeAbility( d, SilverSpores_SPELL_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_LIGHT )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\NightElf\\NightElfBlood\\NightElfBloodHippogryph.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\NightElf\\NightElfLargeDeathExplode\\NightElfLargeDeathExplode.mdl" )
            call SetUnitTypeCanNotBeRevived(d)
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 20 )
            call SetUnitTypeEP( d, 20 )
            call SetUnitTypeGoldCost( d, 150 )
            call SetUnitTypeImpactZ( d, 10 )
            call SetUnitTypeLifeRegeneration( d, 2 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 450 )
            call SetUnitTypeScale( d, 0.95 )
            call SetUnitTypeShopMaxCharges( d, 3 )
            call SetUnitTypeShopRefreshInterval( d, 45 )
            call SetUnitTypeShopRefreshIntervalStart( d, 200 )
            call SetUnitTypeSightRange( d, 850 )
            call SetUnitTypeSpeed( d, 350 )
            call SetUnitTypeSupplyUsed( d, 0 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer UNIT_SHREDDER_UNIT_ID = 'n02S'
            endglobals

            // Unit Shredder
            set d = InitUnitTypeEx( UNIT_SHREDDER_UNIT_ID )
            call AddUnitTypeAbility( d, Invulnerability_SPELL_ID )
            call AddUnitTypeAbility( d, SHARED_CONTROL_SPELL_ID )
            call AddUnitTypeAbility( d, STOP_EX_SPELL_ID )
            call SetUnitTypeDamage( d, 90 )
            call SetUnitTypeDamageDices( d, 5 )
            call SetUnitTypeDamageDicesSides( d, 6 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeMaxLife( d, 750 )
            call SetUnitTypeScale( d, 1.6 )
            call SetUnitTypeShared(d)
            call SetUnitTypeSightRange( d, 500 )
            call AddShopUnitSupply( d, ShopInformation_UNIT_ID )
            call AddShopUnitSupply( d, UNIT_SHREDDER_RELEASED_UNIT_ID )
            call SetUnitTypeVertexColor(d, 190, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer UNIT_SHREDDER_RELEASED_UNIT_ID = 'n02R'
            endglobals

            // Unit Shredder (released)
            set d = InitUnitTypeEx( UNIT_SHREDDER_RELEASED_UNIT_ID )
            call AddUnitTypeAbility( d, SHARED_CONTROL_SPELL_ID )
            call SetUnitTypeArmor( d, 20 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeCanNotBeInited(d)
            call SetUnitTypeDamage( d, 90 )
            call SetUnitTypeDamageDices( d, 5 )
            call SetUnitTypeDamageDicesSides( d, 6 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 28 )
            call SetUnitTypeEP( d, 300 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeMaxLife( d, 4000 )
            call SetUnitTypeScale( d, 1.75 )
            call SetUnitTypeShared(d)
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeShopMaxCharges( d, 1 )
            call SetUnitTypeShopRefreshInterval( d, 600 )
            call SetUnitTypeShopRefreshIntervalStart( d, 600 )
            call SetUnitTypeSpeed( d, 280 )
            call SetUnitTypeVertexColor(d, 190, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer GLAIVE_THROWER_UNIT_ID = 'e00J'
            endglobals

            // Glaive Thrower
            set d = InitUnitTypeEx( GLAIVE_THROWER_UNIT_ID )
            call AddUnitTypeAbility( d, LinearBoomerang_SPELL_ID )
            call SetUnitTypeArmor( d, 10 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeDamage( d, 150 )
            call SetUnitTypeDamageType( d, DMG_TYPE_PIERCE )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeGoldCost( d, 1000 )
            call SetUnitTypeImpactZ( d, 75 )
            call SetUnitTypeMaxLife( d, 2500 )
            call SetUnitTypeScale( d, 1.25 )
            call SetUnitTypeSightRange( d, 450 )
            call SetUnitTypeShopMaxCharges( d, 2 )
            call SetUnitTypeShopRefreshInterval( d, 900 )
            call SetUnitTypeShopRefreshIntervalStart( d, 900 )
            call SetUnitTypeSpecialAttack( d )
            call SetUnitTypeSpeed( d, 200 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer SIEGE_TIN_UNIT_ID = 'h013'
            endglobals

            // Siege Tin
            set d = InitUnitTypeEx( SIEGE_TIN_UNIT_ID )
            call AddUnitTypeAbility( d, FreeRoad_SPELL_ID )
            call SetUnitTypeArmor( d, 20 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeDamage( d, 117 )
            call SetUnitTypeDamageDices( d, 6 )
            call SetUnitTypeDamageDicesSides( d, 11 )
            call SetUnitTypeDamageType( d, DMG_TYPE_SIEGE )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeGoldCost( d, 2500 )
            call SetUnitTypeImpactZ( d, 45 )
            call SetUnitTypeMaxLife( d, 5000 )
            call SetUnitTypeScale( d, 0.75 )
            call SetUnitTypeSightRange( d, 450 )
            call SetUnitTypeShopMaxCharges( d, 2 )
            call SetUnitTypeShopRefreshInterval( d, 900 )
            call SetUnitTypeShopRefreshIntervalStart( d, 900 )
            call SetUnitTypeSpeed( d, 200 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer ADJUTANT_UNIT_ID = 'n01P'
            endglobals

            // Adjutant
            set d = InitUnitTypeEx( ADJUTANT_UNIT_ID )
            call AddUnitTypeAbility( d, RefillMana_SPELL_ID )
            call AddUnitTypeAbility( d, Rust_SPELL_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeDamage( d, 17 )
            call SetUnitTypeDamageDices( d, 1 )
            call SetUnitTypeDamageDicesSides( d, 8 )
            call SetUnitTypeDamageType( d, DMG_TYPE_MAGIC )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 35 )
            call SetUnitTypeEP( d, 25 )
            call SetUnitTypeGoldCost( d, 280 )
            call SetUnitTypeImpactZ( d, 100 )
            call SetUnitTypeLifeRegeneration( d, 0.65 * REGENERATION_INTERVAL )
            call SetUnitTypeManaRegeneration( d, 0.75 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 850 )
            call SetUnitTypeMaxMana( d, 300 )
            call SetUnitTypeScale( d, 1.05 )
            call SetUnitTypeShopMaxCharges( d, 2 )
            call SetUnitTypeShopRefreshInterval( d, 70 )
            call SetUnitTypeShopRefreshIntervalStart( d, 300 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 290 )
            call SetUnitTypeStartMana( d, 300 )
            call SetUnitTypeSupplyUsed( d, 0 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer BATTLE_SHIP_UNIT_ID = 'h00V'
            endglobals

            // Battle Ship
            set d = InitUnitTypeEx( BATTLE_SHIP_UNIT_ID )
            call AddUnitTypeAbility( d, ArtilleryAttack_SPELL_ID )
            call SetUnitTypeArmor( d, 5 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeDamage( d, 65 )
            call SetUnitTypeDamageDices( d, 4 )
            call SetUnitTypeDamageDicesSides( d, 5 )
            call SetUnitTypeDamageType( d, DMG_TYPE_SIEGE )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 100 )
            call SetUnitTypeEP( d, 150 )
            call SetUnitTypeGoldCost( d, 600 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeMaxLife( d, 1000 )
            call SetUnitTypeMissileArc( d, 0.3 )
            call SetUnitTypeMissileDummyUnitId( d, 'n02Q' )
            call SetUnitTypeMissileSpeed( d, 900 )
            call SetUnitTypeScale( d, 1 )
            call SetUnitTypeShopMaxCharges( d, 2 )
            call SetUnitTypeShopRefreshInterval( d, 70 )
            call SetUnitTypeShopRefreshIntervalStart( d, 180 )
            call SetUnitTypeSightRange( d, 1000 )
            call SetUnitTypeSpecialAttack( d )
            call SetUnitTypeSpeed( d, 250 )
            call SetUnitTypeSupplyUsed( d, 0 )
            call SetUnitTypeSplash( d )
            call SetUnitTypeSplashAffectionEnemy( d )
            call SetUnitTypeSplashAffectionGround( d )
            call SetUnitTypeSplashAreaRange( d, 350 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer DWARVES_UNIT_ID = 'h00N'
            endglobals

            // Dwarves
            set d = InitUnitTypeEx( DWARVES_UNIT_ID )
            call AddUnitTypeAbility( d, ArtilleryAttack_SPELL_ID )
            call AddUnitTypeAbility( d, DiversionShot_SPELL_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeDamage( d, 26 )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 7 )
            call SetUnitTypeDamageType( d, DMG_TYPE_SIEGE )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 30 )
            call SetUnitTypeEP( d, 25 )
            call SetUnitTypeGoldCost( d, 280 )
            call SetUnitTypeImpactZ( d, 25 )
            call SetUnitTypeLifeRegeneration( d, 0.55 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 700 )
            call SetUnitTypeMissileArc( d, 0.8 )
            call SetUnitTypeMissileDummyUnitId( d, 'n01N' )
            call SetUnitTypeMissileSpeed( d, 1300 )
            call SetUnitTypeScale( d, 1.05 )
            call SetUnitTypeShopMaxCharges( d, 2 )
            call SetUnitTypeShopRefreshInterval( d, 70 )
            call SetUnitTypeShopRefreshIntervalStart( d, 220 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpecialAttack( d )
            call SetUnitTypeSpeed( d, 270 )
            call SetUnitTypeSupplyUsed( d, 0 )
            call SetUnitTypeSplash( d )
            call SetUnitTypeSplashAffectionAlly( d )
            call SetUnitTypeSplashAffectionEnemy( d )
            call SetUnitTypeSplashAffectionGround( d )
            call SetUnitTypeSplashAreaRange( d, 250 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer SPIDERLY_EGG_UNIT_ID = 'n02G'
            endglobals

            // Spiderly Egg
            set d = InitUnitTypeEx( SPIDERLY_EGG_UNIT_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeMaxLife( d, 150 )
            call SetUnitTypeScale( d, 1.15 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeWard(d)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer SPIDERLY_EGG2_UNIT_ID = 'n02H'
            endglobals

            // Spiderly Egg2
            set d = InitUnitTypeEx( SPIDERLY_EGG2_UNIT_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeMaxLife( d, 150 )
            call SetUnitTypeScale( d, 1.15 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeWard(d)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer SPIDERLY_UNIT_ID = 'n02J'
            endglobals

            // Spiderly
            set d = InitUnitTypeEx( SPIDERLY_UNIT_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Human\\HumanBlood\\HumanBloodLarge0.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Demon\\DemonLargeDeathExplode\\DemonLargeDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 7 )
            call SetUnitTypeDamageDices( d, 1 )
            call SetUnitTypeDamageDicesSides( d, 4 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 3 )
            call SetUnitTypeEP( d, 2 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 0.35 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 150 )
            call SetUnitTypeScale( d, 0.75 )
            call SetUnitTypeSightRange( d, 275 )
            call SetUnitTypeSpeed( d, 270 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer RESERVE_UNIT_ID = 'n02F'
            endglobals

            // Reserve
            set d = InitUnitTypeEx( RESERVE_UNIT_ID )
            call AddUnitTypeAbility( d, Suicide_SPELL_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_LARGE )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Human\\HumanBlood\\HumanBloodFootman.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Human\\HumanSmallDeathExplode\\HumanSmallDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 9 )
            call SetUnitTypeDamageDices( d, 1 )
            call SetUnitTypeDamageDicesSides( d, 5 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 5 )
            call SetUnitTypeEP( d, 3 )
            call SetUnitTypeGoldCost( d, 50 )
            call SetUnitTypeImpactZ( d, 45 )
            call SetUnitTypeLifeRegeneration( d, 0.5 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 350 )
            call SetUnitTypeScale( d, 1.35 )
            call SetUnitTypeShopMaxCharges( d, 3 )
            call SetUnitTypeShopRefreshInterval( d, 35 )
            call SetUnitTypeShopRefreshIntervalStart( d, 35 )
            call SetUnitTypeSightRange( d, 450 )
            call SetUnitTypeSpeed( d, 290 )
            call SetUnitTypeSupplyUsed( d, 6 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            call AddUnitTypeResearchTypeId( d, UpgradeArmor_RESEARCH_ID )
            call AddUnitTypeResearchTypeId( d, UpgradeAttackRate_RESEARCH_ID )
            call AddUnitTypeResearchTypeId( d, UpgradeDamage_RESEARCH_ID )
            call AddUnitTypeResearchTypeId( d, UpgradePower_RESEARCH_ID )

            call AddUnitTypeResearchTypeId( d, CriticalStrikes_RESEARCH_ID )
            call AddUnitTypeResearchTypeId( d, MassProduction_RESEARCH_ID )
            call AddUnitTypeResearchTypeId( d, RegenerativeHerbs_RESEARCH_ID )
            call AddUnitTypeResearchTypeId( d, SparklingScales_RESEARCH_ID )
            call AddUnitTypeResearchTypeId( d, UpgradeSpeed_RESEARCH_ID )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer TUSKAR_UNIT_ID = 'n01L'
            endglobals

            // Tuskar
            set d = InitUnitTypeEx( TUSKAR_UNIT_ID )
            call AddUnitTypeAbility( d, Net_SPELL_ID )
            call AddUnitTypeAbility( d, RapidFire_SPELL_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Orc\\Orcblood\\OrcBloodWitchDoctor.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Orc\\OrcSmallDeathExplode\\OrcSmallDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 43 )
            call SetUnitTypeDamageDices( d, 2 )
            call SetUnitTypeDamageDicesSides( d, 5 )
            call SetUnitTypeDamageType( d, DMG_TYPE_PIERCE )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 40 )
            call SetUnitTypeEP( d, 33 )
            call SetUnitTypeGoldCost( d, 350 )
            call SetUnitTypeImpactZ( d, 100 )
            call SetUnitTypeLifeRegeneration( d, 1.05 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 1150 )
            call SetUnitTypeScale( d, 1.25 )
            call SetUnitTypeShopMaxCharges( d, 1 )
            call SetUnitTypeShopRefreshInterval( d, 80 )
            call SetUnitTypeShopRefreshIntervalStart( d, 220 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 270 )
            call SetUnitTypeSupplyUsed( d, 0 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer DIRE_WOLF_UNIT_ID = 'n01Q'
            endglobals

            // Dire Wolf
            set d = InitUnitTypeEx( DIRE_WOLF_UNIT_ID )
            call AddUnitTypeAbility( d, CriticalStrike_TerrorWolf_TerrorWolf_SPELL_ID )
            call AddUnitTypeAbility( d, DreadCall_SPELL_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Orc\\Orcblood\\OrcBloodWitchDoctor.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Orc\\OrcSmallDeathExplode\\OrcSmallDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 44 )
            call SetUnitTypeDamageDices( d, 3 )
            call SetUnitTypeDamageDicesSides( d, 9 )
            call SetUnitTypeDamageType( d, DMG_TYPE_CHAOS )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 95 )
            call SetUnitTypeEP( d, 60 )
            call SetUnitTypeGoldCost( d, 1000 )
            call SetUnitTypeImpactZ( d, 40 )
            call SetUnitTypeLifeRegeneration( d, 3.5 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 2500 )
            call SetUnitTypeScale( d, 1.6 )
            call SetUnitTypeShopMaxCharges( d, 1 )
            call SetUnitTypeShopRefreshInterval( d, 250 )
            call SetUnitTypeShopRefreshIntervalStart( d, 500 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 250 )
            call SetUnitTypeSupplyUsed( d, 0 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer FRIENDLY_WOMAN_UNIT_ID = 'n02Z'
            endglobals

            // Friendly Woman
            set d = InitUnitTypeEx( FRIENDLY_WOMAN_UNIT_ID )
            call AddUnitTypeAbility( d, WhipLash_SPELL_ID )
            call SetUnitTypeArmor( d, 1 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Undead\\UndeadBlood\\UndeadBloodNecromancer.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Demon\\DemonLargeDeathExplode\\DemonLargeDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 21 )
            call SetUnitTypeDamageDices( d, 1 )
            call SetUnitTypeDamageDicesSides( d, 10 )
            call SetUnitTypeDamageType( d, DMG_TYPE_CHAOS )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 32 )
            call SetUnitTypeEP( d, 60 )
            call SetUnitTypeGoldCost( d, 300 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 1.35 * REGENERATION_INTERVAL )
            call SetUnitTypeManaRegeneration( d, 2.25 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 975 )
            call SetUnitTypeMaxMana( d, 200 )
            call SetUnitTypeScale( d, 1.4 )
            call SetUnitTypeShopMaxCharges( d, 1 )
            call SetUnitTypeShopRefreshInterval( d, 50 )
            call SetUnitTypeShopRefreshIntervalStart( d, 120 )
            call SetUnitTypeSightRange( d, 750 )
            call SetUnitTypeSpeed( d, 315 )
            call SetUnitTypeStartMana( d, 125 )
            call SetUnitTypeSupplyUsed( d, 0 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer WAR_ENGINEER_UNIT_ID = 'n01O'
            endglobals

            // War Engineer
            set d = InitUnitTypeEx( WAR_ENGINEER_UNIT_ID )
            call AddUnitTypeAbility( d, REPAIR_SPELL_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Undead\\UndeadBlood\\UndeadBloodNecromancer.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Undead\\UndeadLargeDeathExplode\\UndeadLargeDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 19 )
            call SetUnitTypeDamageDices( d, 3 )
            call SetUnitTypeDamageDicesSides( d, 4 )
            call SetUnitTypeDamageType( d, DMG_TYPE_CHAOS )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 35 )
            call SetUnitTypeEP( d, 30 )
            call SetUnitTypeGoldCost( d, 300 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 0.85 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 1000 )
            call SetUnitTypeScale( d, 1.6 )
            call SetUnitTypeShopMaxCharges( d, 2 )
            call SetUnitTypeShopRefreshInterval( d, 70 )
            call SetUnitTypeShopRefreshIntervalStart( d, 180 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 270 )
            call SetUnitTypeSupplyUsed( d, 0 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer SHOP_INFORMATION_UNIT_ID = 'n02X'
            endglobals

            // Shop Information
            set d = InitUnitTypeEx( SHOP_INFORMATION_UNIT_ID )
            call SetUnitTypeCanNotBeInited(d)
            call SetUnitTypeShopMaxCharges( d, 1 )
            call SetUnitTypeShopRefreshInterval( d, 1 )
            call SetUnitTypeShopRefreshIntervalStart( d, 0 )

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer CROWD_PULLER_UNIT_ID = 'n02I'
            endglobals

            // CrowdPuller
            set d = InitUnitTypeEx( CROWD_PULLER_UNIT_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeImpactZ( d, 180 )
            call SetUnitTypeMaxLife( d, 100 )
            call SetUnitTypeScale( d, 1.65 )
            call SetUnitTypeSightRange( d, 500 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeWard(d)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer SOUL_VESSEL_UNIT_ID = 'n02O'
            endglobals

            // Soul Vessel
            set d = InitUnitTypeEx( SOUL_VESSEL_UNIT_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 3 )
            call SetUnitTypeMaxLife( d, 100 )
            call SetUnitTypeScale( d, 1 )
            call SetUnitTypeSightRange( d, 150 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeWard(d)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer TRAP_UNIT_ID = 'n027'
            endglobals

            // Trap
            set d = InitUnitTypeEx( TRAP_UNIT_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeGoldCost( d, 75 )
            call SetUnitTypeMaxLife( d, 150 )
            call SetUnitTypeScale( d, 1.15 )
            call SetUnitTypeSightRange( d, 500 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer TRAP_BUILT_UP_UNIT_ID = 'n028'
            endglobals

            // Trap Built Up
            set d = InitUnitTypeEx( TRAP_BUILT_UP_UNIT_ID )
            call AddUnitTypeAbility( d, MATSUGAN_SPELL_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeMaxLife( d, 150 )
            call SetUnitTypeScale( d, 1 )
            call SetUnitTypeSightRange( d, 500 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeWard(d)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer MURLOC_NIGHTSTALKER_UNIT_ID = 'n032'
            endglobals

            // Murloc Nightstalker
            set d = InitUnitTypeEx( MURLOC_NIGHTSTALKER_UNIT_ID )
            call SetUnitTypeArmor( d, 1 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_LARGE )
            call SetUnitTypeBlood( d, "" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Demon\\DemonLargeDeathExplode\\DemonLargeDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 10 )
            call SetUnitTypeDamageDices( d, 1 )
            call SetUnitTypeDamageDicesSides( d, 2 )
            call SetUnitTypeDamageType( d, DMG_TYPE_CHAOS )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 60 )
            call SetUnitTypeEP( d, 60 )
            call SetUnitTypeImpactZ( d, 60 )
            call SetUnitTypeLifeRegeneration( d, 0.5 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 800 )
            call SetUnitTypeScale( d, 1.6 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 270 )
            call SetUnitTypeVertexColor(d, 255, 200, 200, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer SEA_GIANT_UNIT_ID = 'n031'
            endglobals

            // Sea Giant
            set d = InitUnitTypeEx( SEA_GIANT_UNIT_ID )
            call AddUnitTypeAbility( d, Pulverize_SPELL_ID )
            call SetUnitTypeArmor( d, 2 )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_LARGE )
            call SetUnitTypeBlood( d, "Objects\\Spawnmodels\\Orc\\Orcblood\\OrcBloodGrunt.mdl" )
            call SetUnitTypeBloodExplosion( d, "Objects\\Spawnmodels\\Orc\\OrcLargeDeathExplode\\OrcLargeDeathExplode.mdl" )
            call SetUnitTypeDamage( d, 24 )
            call SetUnitTypeDamageDices( d, 4 )
            call SetUnitTypeDamageDicesSides( d, 5 )
            call SetUnitTypeDamageType( d, DMG_TYPE_NORMAL )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeDrop( d, 150 )
            call SetUnitTypeEP( d, 150 )
            call SetUnitTypeImpactZ( d, 160 )
            call SetUnitTypeLifeRegeneration( d, 5 * REGENERATION_INTERVAL )
            call SetUnitTypeMaxLife( d, 1400 )
            call SetUnitTypeScale( d, 1 )
            call SetUnitTypeSightRange( d, 600 )
            call SetUnitTypeSpeed( d, 270 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer HEALING_WARD_UNIT_ID = 'n02W'
            endglobals

            // Healing Ward
            set d = InitUnitTypeEx( HEALING_WARD_UNIT_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_MEDIUM )
            call SetUnitTypeDecay( d )
            call SetUnitTypeDecayTime( d, 30 )
            call SetUnitTypeMaxLife( d, 25 )
            call SetUnitTypeScale( d, 1.15 )
            call SetUnitTypeSightRange( d, 500 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)
            call SetUnitTypeWard(d)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer GRASS_UNIT_ID = 'n014'
            endglobals

            // Grass
            set d = InitUnitTypeEx( GRASS_UNIT_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeDecay( d )
            call SetUnitTypeMaxLife( d, 150 )
            call SetUnitTypeScale( d, 1.25 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer BRICK_UNIT_ID = 'n015'
            endglobals

            // Brick
            set d = InitUnitTypeEx( BRICK_UNIT_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeDecay( d )
            call SetUnitTypeMaxLife( d, 150 )
            call SetUnitTypeScale( d, 1.25 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            globals
                constant integer MARBLE_UNIT_ID = 'n01B'
            endglobals

            // Marble
            set d = InitUnitTypeEx( MARBLE_UNIT_ID )
            call SetUnitTypeArmorType( d, ARMOR_TYPE_FORT )
            call SetUnitTypeDecay( d )
            call SetUnitTypeMaxLife( d, 150 )
            call SetUnitTypeScale( d, 1.25 )
            call SetUnitTypeVertexColor(d, 255, 255, 255, 255)

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            call SaveIntegerWJ( "UnitTypes", "Soldat", 'h001' )
            call SaveIntegerWJ( "UnitTypes", "Scharfschuetze", 'h006' )
            call SaveIntegerWJ( "UnitTypes", "Ritter", 'h008' )
            call SaveIntegerWJ( "UnitTypes", "Priester", 'h00A' )
            call SaveIntegerWJ( "UnitTypes", "Magierin", 'H003' )
            call SaveIntegerWJ( "UnitTypes", "Paladin", 'H004' )
            call SaveIntegerWJ( "UnitTypes", "Infernal", INFERNAL_UNIT_ID )

            call SaveIntegerWJ( "UnitTypes", "Schamane", 'o001' )
            call SaveIntegerWJ( "UnitTypes", "Raeuber", 'o003' )
            call SaveIntegerWJ( "UnitTypes", "Grunzer", 'o005' )
            call SaveIntegerWJ( "UnitTypes", "Windreiter", 'o007' )
            call SaveIntegerWJ( "UnitTypes", "Medizinmann", 'O00B' )
            call SaveIntegerWJ( "UnitTypes", "Schwertkaempfer", 'O008' )

            call SaveIntegerWJ( "UnitTypes", "Ghul", 'u001' )
            call SaveIntegerWJ( "UnitTypes", "Gruftbestie", 'u003' )
            call SaveIntegerWJ( "UnitTypes", "Gargoyle", GARGOYLE_UNIT_ID )
            call SaveIntegerWJ( "UnitTypes", "Totenbeschwoerer", 'u005' )
            call SaveIntegerWJ( "UnitTypes", "Skelettkrieger", 'u00B' )
            call SaveIntegerWJ( "UnitTypes", "Monstrositaet", 'u007' )
            call SaveIntegerWJ( "UnitTypes", "DunklerReiter", 'U009' )
            call SaveIntegerWJ( "UnitTypes", "Lich", 'U00A' )
            call SaveIntegerWJ( "UnitTypes", "Skelettkaempfer", 'u00B' )
            call SaveIntegerWJ( "UnitTypes", "Zombie1", 'n008' )
            call SaveIntegerWJ( "UnitTypes", "Zombie2", 'n009' )
            call SaveIntegerWJ( "UnitTypes", "Zombie3", 'n00A' )

            call SaveIntegerWJ( "UnitTypes", "Bogenschuetze", 'e001' )
            call SaveIntegerWJ( "UnitTypes", "Jaegerin", 'e003' )
            call SaveIntegerWJ( "UnitTypes", "Dryade", 'e005' )
            call SaveIntegerWJ( "UnitTypes", "Bergriese", 'e007' )
            call SaveIntegerWJ( "UnitTypes", "Botaniker", 'E00A' )
            call SaveIntegerWJ( "UnitTypes", "Kopfgeldjaegerin", 'E00C' )
            call SaveIntegerWJ( "UnitTypes", "Treant", 'e00B' )

            call SaveIntegerWJ( "UnitTypes", "EistrollPriester", 'n00K' )
            call SaveIntegerWJ( "UnitTypes", "Dojo", 'n00Z' )
            call SaveIntegerWJ( "UnitTypes", "Oger", 'n00J' )
            call SaveIntegerWJ( "UnitTypes", "Faust", 'n00N' )
            call SaveIntegerWJ( "UnitTypes", "Speispinne", 'n00H' )
            call SaveIntegerWJ( "UnitTypes", "Schimaere", 'e009' )
        endfunction
    endscope

    public function Init takes nothing returns nothing
        call Human_Human_Init()
        call Orc_Orc_Init()
        call Undead_Undead_Init()
        call Nightelf_Nightelf_Init()
        call Naga_Naga_Init()
        call Miscellaneous_Miscellaneous_Init()
    endfunction
endscope