//TESH.scrollpos=450
//TESH.alwaysfold=0
scope Sounds
    public function Init takes nothing returns nothing
        local SoundType d

        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //  Abilities
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        globals
            integer ACID_STRIKE_SOUND_TYPE = 'S000'
        endglobals

        set d = InitSoundTypeEx(ACID_STRIKE_SOUND_TYPE, "Abilities\\Spells\\NightElf\\shadowstrike\\ShadowStrikeBirth1.wav")
        set ACID_STRIKE_SOUND_TYPE = d
        set d.duration = 2194
        set d.eax = "SpellsEAX"
        set d.is3D = true
        set d.pitch = 1
        set d.volume = 127

        globals
            integer BOND_OF_SOULS_SOUND_TYPE = 'S001'
        endglobals

        set d = InitSoundTypeEx(BOND_OF_SOULS_SOUND_TYPE, "Abilities\\Spells\\Human\\AerialShackles\\MagicLariatLoop1.wav")
        set BOND_OF_SOULS_SOUND_TYPE = d
        set d.duration = 3230
        set d.eax = "SpellsEAX"
        set d.is3D = true
        set d.looping = true
        set d.pitch = 1
        set d.volume = 127

        globals
            integer CASH_DISCOUNT_SOUND_TYPE = 'S002'
        endglobals

        set d = InitSoundTypeEx(CASH_DISCOUNT_SOUND_TYPE, "Sound\\Dialogue\\OrcCampaign\\Orc04\\O04Goblin19.mp3")
        set CASH_DISCOUNT_SOUND_TYPE = d
        set d.duration = 9822
        set d.eax = "DefaultEAXON"
        set d.pitch = 1
        set d.volume = 0

        globals
            integer COOLDOWN_SOUND_TYPE = 'S003'
        endglobals

        set d = InitSoundTypeEx(COOLDOWN_SOUND_TYPE, "Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldImpact1.wav" )
        set COOLDOWN_SOUND_TYPE = d
        set d.duration = 476
        set d.eax = "DefaultEAXON"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer DOWNGRADE_SOUND_TYPE = 'S004'
        endglobals

        set d = InitSoundTypeEx(DOWNGRADE_SOUND_TYPE, "Sound\\Buildings\\Shared\\BuildingPlacement.wav" )
        set DOWNGRADE_SOUND_TYPE = d
        set d.duration = 1283
        set d.eax = "DefaultEAXON"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer ELIXIR_OF_THE_GROWTH_SOUND_TYPE = 'S005'
        endglobals

        set d = InitSoundTypeEx(ELIXIR_OF_THE_GROWTH_SOUND_TYPE, "Abilities\\Spells\\NightElf\\Rejuvenation\\RejuvenationTarget1.wav" )
        set ELIXIR_OF_THE_GROWTH_SOUND_TYPE = d
        set d.duration = 1335
        set d.eax = "SpellsEAX"
        set d.is3D = true
        set d.pitch = 0.8
        set d.volume = 127

        globals
            integer ENCHANT_SOUND_TYPE = 'S006'
        endglobals

        set d = InitSoundTypeEx(ENCHANT_SOUND_TYPE, "Abilities\\Spells\\Undead\\AntiMagicShell\\AntiMagicShellBirth1.wav" )
        set ENCHANT_SOUND_TYPE = d
        set d.duration = 1301
        set d.eax = "DefaultEAXON"
        set d.is3D = true
        set d.pitch = 1
        set d.volume = 127

        globals
            integer FAUST_LAUGH_SOUND_TYPE = 'S007'
        endglobals

        set d = InitSoundTypeEx(FAUST_LAUGH_SOUND_TYPE, "Sound\\Ambient\\DoodadEffects\\SargerasLaugh.wav" )
        set FAUST_LAUGH_SOUND_TYPE = d
        set d.duration = 3326
        set d.eax = "DefaultEAXON"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer FIERY_BOOTS_FIRE_SOUND_TYPE = 'S008'
        endglobals

        set d = InitSoundTypeEx(FIERY_BOOTS_FIRE_SOUND_TYPE, "Abilities\\Spells\\Orc\\LiquidFire\\TrollBatriderLiquidFire1.wav" )
        set FIERY_BOOTS_FIRE_SOUND_TYPE = d
        set d.duration = 1724
        set d.eax = "SpellsEAX"
        set d.is3D = true
        set d.looping = true
        set d.pitch = 1
        set d.stop = true
        set d.volume = 70

        globals
            integer FIREBALL_IMPACT_SOUND_TYPE = 'Sfi0'
        endglobals

        set d = InitSoundTypeEx(FIREBALL_IMPACT_SOUND_TYPE, "Abilities\\Weapons\\FireBallMissile\\FireBallMissileDeath.wav" )
        set FIREBALL_IMPACT_SOUND_TYPE = d
        set d.duration = 1477
        set d.eax = "SpellsEAX"
        set d.is3D = true
        set d.looping = true
        set d.pitch = 1
        set d.stop = true
        set d.volume = 127

        globals
            integer FIREBALL_LAUNCH_SOUND_TYPE = 'Sfl0'
        endglobals

        set d = InitSoundTypeEx(FIREBALL_LAUNCH_SOUND_TYPE, "Abilities\\Weapons\\FireBallMissile\\FireBallMissileLaunch1.wav" )
        set FIREBALL_LAUNCH_SOUND_TYPE = d
        set d.duration = 652
        set d.eax = "SpellsEAX"
        set d.is3D = true
        set d.looping = true
        set d.pitch = 1
        set d.stop = true
        set d.volume = 127

        globals
            integer FIREBALL_LAUNCH2_SOUND_TYPE = 'Sfl1'
        endglobals

        set d = InitSoundTypeEx(FIREBALL_LAUNCH2_SOUND_TYPE, "Abilities\\Weapons\\FireBallMissile\\FireBallMissileLaunch2.wav" )
        set FIREBALL_LAUNCH2_SOUND_TYPE = d
        set d.duration = 605
        set d.eax = "SpellsEAX"
        set d.is3D = true
        set d.looping = true
        set d.pitch = 1
        set d.stop = true
        set d.volume = 127

        globals
            integer FIREBALL_LAUNCH3_SOUND_TYPE = 'Sfl2'
        endglobals

        set d = InitSoundTypeEx(FIREBALL_LAUNCH3_SOUND_TYPE, "Abilities\\Weapons\\FireBallMissile\\FireBallMissileLaunch3.wav" )
        set FIREBALL_LAUNCH3_SOUND_TYPE = d
        set d.duration = 796
        set d.eax = "SpellsEAX"
        set d.is3D = true
        set d.looping = true
        set d.pitch = 1
        set d.stop = true
        set d.volume = 127

        globals
            integer FLYING_SHEEP_SOUND_TYPE = 'S02U'
        endglobals

        set d = InitSoundTypeEx(FLYING_SHEEP_SOUND_TYPE, "Units\\Critters\\Sheep\\Sheep2.wav" )
        set FLYING_SHEEP_SOUND_TYPE = d
        set d.duration = 1300
        set d.eax = "SpellsEAX"
        set d.is3D = true
        set d.pitch = 1
        set d.stop = true
        set d.volume = 127

        globals
            integer FRENZY_SOUND_TYPE = 'S009'
        endglobals

        set d = InitSoundTypeEx(FRENZY_SOUND_TYPE, "Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.wav" )
        set FRENZY_SOUND_TYPE = d
        set d.duration = 2583
        set d.eax = "DefaultEAXON"
        set d.is3D = true
        set d.pitch = 1
        set d.volume = 127

        globals
            integer FURY_SOUND_TYPE = 'S00A'
        endglobals

        set d = InitSoundTypeEx(FURY_SOUND_TYPE, "Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.wav" )
        set FURY_SOUND_TYPE = d
        set d.duration = 2583
        set d.eax = "DefaultEAXON"
        set d.is3D = true
        set d.pitch = 1
        set d.volume = 127

        globals
            integer HARMAGEDON_WARNING_SOUND_TYPE = 'S00B'
        endglobals

        set d = InitSoundTypeEx(HARMAGEDON_WARNING_SOUND_TYPE, "Sound\\Interface\\CreepAggroWhat1.wav" )
        set HARMAGEDON_WARNING_SOUND_TYPE = d
        set d.duration = 1236
        set d.eax = "DefaultEAXON"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer HEALING_WARD_SOUND_TYPE = 'Shlw'
        endglobals

        set d = InitSoundTypeEx(HEALING_WARD_SOUND_TYPE, "Units\\Orc\\HealingWard\\PlaceAncestralGuardian.wav" )
        set HEALING_WARD_SOUND_TYPE = d
        set d.duration = 3063
        set d.eax = "SpellsEAX"
        set d.is3D = true
        set d.pitch = 1
        set d.volume = 127

        globals
            integer HINDRANCE_OF_LEARNING_SOUND_TYPE = 'S00C'
        endglobals

        set d = InitSoundTypeEx(HINDRANCE_OF_LEARNING_SOUND_TYPE, "Units\\Creeps\\Ogre\\OgrePissed4.wav" )
        set HINDRANCE_OF_LEARNING_SOUND_TYPE = d
        set d.duration = 3534
        set d.eax = "DefaultEAXON"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer KIDNEY_SHOT_SOUND_TYPE = 'S02F'
        endglobals

        set d = InitSoundTypeEx(KIDNEY_SHOT_SOUND_TYPE, "Sound\\Units\\Combat\\MetalHeavyBashMetal2.wav" )
        set KIDNEY_SHOT_SOUND_TYPE = d
        set d.duration = 1248
        set d.eax = "DefaultEAXON"
        set d.is3D = true
        set d.pitch = 1
        set d.volume = 127

        globals
            integer KITTY_JUMP_SLICE_SOUND_TYPE = 'S00M'
        endglobals

        set d = InitSoundTypeEx(KITTY_JUMP_SLICE_SOUND_TYPE, "Sound\\Units\\Combat\\MetalHeavySliceFlesh1.wav" )
        set KITTY_JUMP_SLICE_SOUND_TYPE = d
        set d.duration = 1104
        set d.eax = "CombatSoundsEAX"
        set d.is3D = true
        set d.pitch = 0.75
        set d.volume = 90

        globals
            integer KITTY_JUMP_START_SOUND_TYPE = 'S00N'
        endglobals

        set d = InitSoundTypeEx(KITTY_JUMP_START_SOUND_TYPE, "Sound\\Units\\Footsteps\\step.wav" )
        set KITTY_JUMP_START_SOUND_TYPE = d
        set d.duration = 540
        set d.eax = "DefaultEAXON"
        set d.is3D = true
        set d.pitch = 0.6
        set d.volume = 100

        globals
            integer KITTY_JUMP_ENDING_SOUND_TYPE = 'S00O'
        endglobals

        set d = InitSoundTypeEx(KITTY_JUMP_ENDING_SOUND_TYPE, "Abilities\\Weapons\\FireBallMissile\\FireBallMissileLaunch1.wav" )
        set KITTY_JUMP_ENDING_SOUND_TYPE = d
        set d.duration = 652
        set d.eax = "MissilesEAX"
        set d.is3D = true
        set d.pitch = 0.8
        set d.volume = 100

        globals
            integer KITTY_JUMP_ENDING2_SOUND_TYPE = 'S00P'
        endglobals

        set d = InitSoundTypeEx(KITTY_JUMP_ENDING2_SOUND_TYPE, "Abilities\\Weapons\\LavaSpawnMissile\\LavaSpawnMissileDeath1.wav" )
        set KITTY_JUMP_ENDING2_SOUND_TYPE = d
        set d.duration = 438
        set d.eax = "CombatSoundsEAX"
        set d.is3D = true
        set d.pitch = 1
        set d.volume = 127

        globals
            integer LIFE_DRAIN_LOOP_SOUND_TYPE = 'S00D'
        endglobals

        set d = InitSoundTypeEx(LIFE_DRAIN_LOOP_SOUND_TYPE, "Abilities\\Spells\\Other\\Drain\\LifeDrain.wav" )
        set LIFE_DRAIN_LOOP_SOUND_TYPE = d
        set d.duration = 2490
        set d.eax = "SpellsEAX"
        set d.is3D = true
        set d.looping = true
        set d.pitch = 1
        set d.volume = 127

        globals
            integer LIGHTNING_ATTACK_SOUND_TYPE = 'S00E'
        endglobals

        set d = InitSoundTypeEx(LIGHTNING_ATTACK_SOUND_TYPE, "Abilities\\Spells\\Orc\\LightningBolt\\LightningBolt.wav" )
        set LIGHTNING_ATTACK_SOUND_TYPE = d
        set d.duration = 2136
        set d.eax = "SpellsEAX"
        set d.is3D = true
        set d.pitch = 1
        set d.volume = 127

        globals
            integer LIGHT_OF_PURGE_LOOP_SOUND_TYPE = 'S00F'
        endglobals

        set d = InitSoundTypeEx(LIGHT_OF_PURGE_LOOP_SOUND_TYPE, "Abilities\\Spells\\Other\\Drain\\SiphonManaLoop.wav" )
        set LIGHT_OF_PURGE_LOOP_SOUND_TYPE = d
        set d.duration = 1588
        set d.eax = "SpellsEAX"
        set d.is3D = true
        set d.looping = true
        set d.pitch = 1
        set d.volume = 127

        globals
            integer MAGICAL_LARIAT_SOUND_TYPE = 'Smla'
        endglobals

        set d = InitSoundTypeEx(MAGICAL_LARIAT_SOUND_TYPE, "Abilities\\Spells\\Human\\AerialShackles\\MagicLariatLoop1.wav")
        set MAGICAL_LARIAT_SOUND_TYPE = d
        set d.duration = 3230
        set d.eax = "SpellsEAX"
        set d.is3D = true
        set d.looping = true
        set d.pitch = 1
        set d.volume = 127

        globals
            integer PEQ_WARCRY_SOUND_TYPE = 'S00G'
        endglobals

        set d = InitSoundTypeEx(PEQ_WARCRY_SOUND_TYPE, "Sound\\Dialogue\\HumanExpCamp\\Human06x\\BUTCHER.WAV" )
        set PEQ_WARCRY_SOUND_TYPE = d
        set d.duration = 3030
        set d.eax = "DefaultEAXON"
        set d.pitch = 1.1
        set d.volume = 127

        globals
            integer POISON_FOUNTAIN_LOOP_SOUND_TYPE = 'S00H'
        endglobals

        set d = InitSoundTypeEx(POISON_FOUNTAIN_LOOP_SOUND_TYPE, "Abilities\\Spells\\Undead\\DeathandDecay\\DeathAndDecayLoop1.wav" )
        set POISON_FOUNTAIN_LOOP_SOUND_TYPE = d
        set d.duration = 4004
        set d.eax = "SpellsEAX"
        set d.is3D = true
        set d.looping = true
        set d.pitch = 2
        set d.volume = 127

        globals
            integer POTION_OF_THE_INCONSPICUOUS_SHAPE_SOUND_TYPE = 'S00I'
        endglobals

        set d = InitSoundTypeEx(POTION_OF_THE_INCONSPICUOUS_SHAPE_SOUND_TYPE, "Abilities\\Spells\\Human\\Banish\\BanishCaster.wav" )
        set POTION_OF_THE_INCONSPICUOUS_SHAPE_SOUND_TYPE = d
        set d.duration = 2415
        set d.eax = "SpellsEAX"
        set d.is3D = true
        set d.pitch = 2
        set d.volume = 127

        globals
            integer STABILITY_SOUND_TYPE = 'S00J'
        endglobals

        set d = InitSoundTypeEx(STABILITY_SOUND_TYPE, "Abilities\\Spells\\Human\\Invisibility\\InvisibilityTarget.wav" )
        set STABILITY_SOUND_TYPE = d
        set d.duration = 2043
        set d.eax = "SpellsEAX"
        set d.is3D = true
        set d.pitch = 1
        set d.volume = 127

        globals
            integer SPELL_DISCONNECTION_IMPACT_SOUND_TYPE = 'S00K'
        endglobals

        set d = InitSoundTypeEx(SPELL_DISCONNECTION_IMPACT_SOUND_TYPE, "Abilities\\Weapons\\DemonHunterMissile\\DemonHunterMissileHit1.wav" )
        set SPELL_DISCONNECTION_IMPACT_SOUND_TYPE = d
        set d.duration = 775
        set d.eax = "MissilesEAX"
        set d.is3D = true
        set d.pitch = 0.8
        set d.volume = 115

        globals
            integer SPELL_DISCONNECTION_LAUNCH_SOUND_TYPE = 'S00L'
        endglobals

        set d = InitSoundTypeEx(SPELL_DISCONNECTION_LAUNCH_SOUND_TYPE, "Abilities\\Weapons\\DemonHunterMissile\\HeroDemonMissileLaunch2.wav" )
        set SPELL_DISCONNECTION_LAUNCH_SOUND_TYPE = d
        set d.duration = 1219
        set d.eax = "MissilesEAX"
        set d.is3D = true
        set d.pitch = 0.7
        set d.volume = 100

        globals
            integer TRIDENT_SOUND_TYPE = 'Str0'
        endglobals

        set d = InitSoundTypeEx(TRIDENT_SOUND_TYPE, "Abilities\\Weapons\\CannonTowerMissile\\CannonTowerMissileLaunch1.wav" )
        set TRIDENT_SOUND_TYPE = d
        set d.duration = 1088
        set d.eax = "DefaultEAXOn"
        set d.is3D = true
        set d.pitch = 1
        set d.volume = 127

        globals
            integer TRIDENT_SOUND1_TYPE = 'Str1'
        endglobals

        set d = InitSoundTypeEx(TRIDENT_SOUND1_TYPE, "Abilities\\Weapons\\CannonTowerMissile\\CannonTowerMissileLaunch2.wav" )
        set TRIDENT_SOUND1_TYPE = d
        set d.duration = 1219
        set d.eax = "DefaultEAXOn"
        set d.is3D = true
        set d.pitch = 1
        set d.volume = 127

        globals
            integer TRIDENT_SOUND2_TYPE = 'Str2'
        endglobals

        set d = InitSoundTypeEx(TRIDENT_SOUND2_TYPE, "Abilities\\Weapons\\CannonTowerMissile\\CannonTowerMissileLaunch3.wav" )
        set TRIDENT_SOUND2_TYPE = d
        set d.duration = 1088
        set d.eax = "DefaultEAXOn"
        set d.is3D = true
        set d.pitch = 1
        set d.volume = 127

        globals
            integer WHIP_LASH_SOUND_TYPE = 'S00Q'
        endglobals

        set d = InitSoundTypeEx(WHIP_LASH_SOUND_TYPE, "WhipLash.wav" )
        set WHIP_LASH_SOUND_TYPE = d
        set d.duration = 800
        set d.eax = "DefaultEAXON"
        set d.is3D = true
        set d.pitch = 1
        set d.volume = 127

        globals
            integer REQUEST_REINFORCEMENTS_LAUNCH_SOUND_TYPE = 'Srri'
        endglobals

        set d = InitSoundTypeEx(REQUEST_REINFORCEMENTS_LAUNCH_SOUND_TYPE, "Units\\Creeps\\GoblinZeppelin\\GoblinZeppelinYes2.wav" )
        set REQUEST_REINFORCEMENTS_LAUNCH_SOUND_TYPE = d
        set d.duration = 2519
        set d.eax = "SpellsEAX"
        set d.is3D = true
        set d.pitch = 1
        set d.volume = 127

        globals
            integer RUST_SOUND_TYPE = 'S00S'
        endglobals

        set d = InitSoundTypeEx(RUST_SOUND_TYPE, "" )
        set RUST_SOUND_TYPE = d
        set d.duration = 996
        set d.eax = "MissilesEAX"
        set d.is3D = true
        set d.pitch = 1
        set d.volume = 127

        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //  Units
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

        globals
            integer BERSERK_PISSED_SOUND_TYPE = 'S00T'
        endglobals

        set d = InitSoundTypeEx(BERSERK_PISSED_SOUND_TYPE, "Units\\Orc\\Hellscream\\GromPissed1.wav" )
        set BERSERK_PISSED_SOUND_TYPE = d
        set d.duration = 2043
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer BERSERK_PISSED2_SOUND_TYPE = 'S00U'
        endglobals

        set d = InitSoundTypeEx(BERSERK_PISSED2_SOUND_TYPE, "Units\\Orc\\Hellscream\\GromPissed2.wav" )
        set BERSERK_PISSED2_SOUND_TYPE = d
        set d.duration = 1735
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer BERSERK_PISSED3_SOUND_TYPE = 'S00V'
        endglobals

        set d = InitSoundTypeEx(BERSERK_PISSED3_SOUND_TYPE, "Units\\Orc\\Hellscream\\GromPissed3.wav" )
        set BERSERK_PISSED3_SOUND_TYPE = d
        set d.duration = 3136
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer BOTANIST_PISSED_SOUND_TYPE = 'S00W'
        endglobals

        set d = InitSoundTypeEx(BOTANIST_PISSED_SOUND_TYPE, "Units\\NightElf\\HeroKeeperOfTheGrove\\KeeperOfTheGrovePissed1.wav" )
        set BOTANIST_PISSED_SOUND_TYPE = d
        set d.duration = 3813
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer BOTANIST_PISSED2_SOUND_TYPE = 'S00X'
        endglobals

        set d = InitSoundTypeEx(BOTANIST_PISSED2_SOUND_TYPE, "Units\\NightElf\\HeroKeeperOfTheGrove\\KeeperOfTheGrovePissed2.wav" )
        set BOTANIST_PISSED2_SOUND_TYPE = d
        set d.duration = 2705
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer BOTANIST_PISSED3_SOUND_TYPE = 'S00Y'
        endglobals

        set d = InitSoundTypeEx(BOTANIST_PISSED3_SOUND_TYPE, "Units\\NightElf\\HeroKeeperOfTheGrove\\KeeperOfTheGrovePissed3.wav" )
        set BOTANIST_PISSED3_SOUND_TYPE = d
        set d.duration = 2952
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer BOTANIST_PISSED4_SOUND_TYPE = 'S00Z'
        endglobals

        set d = InitSoundTypeEx(BOTANIST_PISSED4_SOUND_TYPE, "Units\\NightElf\\HeroKeeperOfTheGrove\\KeeperOfTheGrovePissed4.wav" )
        set BOTANIST_PISSED4_SOUND_TYPE = d
        set d.duration = 2971
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer BOTANIST_PISSED5_SOUND_TYPE = 'S010'
        endglobals

        set d = InitSoundTypeEx(BOTANIST_PISSED5_SOUND_TYPE, "Units\\NightElf\\HeroKeeperOfTheGrove\\KeeperOfTheGrovePissed5.wav" )
        set BOTANIST_PISSED5_SOUND_TYPE = d
        set d.duration = 2541
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer BOTANIST_PISSED6_SOUND_TYPE = 'S011'
        endglobals

        set d = InitSoundTypeEx(BOTANIST_PISSED6_SOUND_TYPE, "Units\\NightElf\\HeroKeeperOfTheGrove\\KeeperOfTheGrovePissed6.wav" )
        set BOTANIST_PISSED6_SOUND_TYPE = d
        set d.duration = 2758
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer FANATICAL_MECHANIC_PISSED_SOUND_TYPE = 'S012'
        endglobals

        set d = InitSoundTypeEx(FANATICAL_MECHANIC_PISSED_SOUND_TYPE, "Units\\Creeps\\HeroTinker\\HeroTinkerPissed1.wav" )
        set FANATICAL_MECHANIC_PISSED_SOUND_TYPE = d
        set d.duration = 2265
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer FANATICAL_MECHANIC_PISSED2_SOUND_TYPE = 'S013'
        endglobals

        set d = InitSoundTypeEx(FANATICAL_MECHANIC_PISSED2_SOUND_TYPE, "Units\\Creeps\\HeroTinker\\HeroTinkerPissed2.wav" )
        set FANATICAL_MECHANIC_PISSED2_SOUND_TYPE = d
        set d.duration = 2242
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer FANATICAL_MECHANIC_PISSED3_SOUND_TYPE = 'S014'
        endglobals

        set d = InitSoundTypeEx(FANATICAL_MECHANIC_PISSED3_SOUND_TYPE, "Units\\Creeps\\HeroTinker\\HeroTinkerPissed3.wav" )
        set FANATICAL_MECHANIC_PISSED3_SOUND_TYPE = d
        set d.duration = 5020
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer FANATICAL_MECHANIC_PISSED4_SOUND_TYPE = 'S015'
        endglobals

        set d = InitSoundTypeEx(FANATICAL_MECHANIC_PISSED4_SOUND_TYPE, "Units\\Creeps\\HeroTinker\\HeroTinkerPissed4.wav" )
        set FANATICAL_MECHANIC_PISSED4_SOUND_TYPE = d
        set d.duration = 5690
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer FANATICAL_MECHANIC_PISSED5_SOUND_TYPE = 'S016'
        endglobals

        set d = InitSoundTypeEx(FANATICAL_MECHANIC_PISSED5_SOUND_TYPE, "Units\\Creeps\\HeroTinker\\HeroTinkerPissed5.wav" )
        set FANATICAL_MECHANIC_PISSED5_SOUND_TYPE = d
        set d.duration = 4377
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer FANATICAL_MECHANIC_PISSED6_SOUND_TYPE = 'S017'
        endglobals

        set d = InitSoundTypeEx(FANATICAL_MECHANIC_PISSED6_SOUND_TYPE, "Units\\Creeps\\HeroTinker\\HeroTinkerPissed6.wav" )
        set FANATICAL_MECHANIC_PISSED6_SOUND_TYPE = d
        set d.duration = 7657
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer FANATICAL_MECHANIC_PISSED7_SOUND_TYPE = 'S018'
        endglobals

        set d = InitSoundTypeEx(FANATICAL_MECHANIC_PISSED7_SOUND_TYPE, "Units\\Creeps\\HeroTinker\\HeroTinkerPissed7.wav" )
        set FANATICAL_MECHANIC_PISSED7_SOUND_TYPE = d
        set d.duration = 2316
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer FANATICAL_MECHANIC_PISSED8_SOUND_TYPE = 'S019'
        endglobals

        set d = InitSoundTypeEx(FANATICAL_MECHANIC_PISSED8_SOUND_TYPE, "Units\\Creeps\\HeroTinker\\HeroTinkerPissed8.wav" )
        set FANATICAL_MECHANIC_PISSED8_SOUND_TYPE = d
        set d.duration = 3243
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer HEADHUNTRESS_PISSED_SOUND_TYPE = 'S01A'
        endglobals

        set d = InitSoundTypeEx(HEADHUNTRESS_PISSED_SOUND_TYPE, "Units\\NightElf\\Tyrande\\TyrandePissed1.wav" )
        set HEADHUNTRESS_PISSED_SOUND_TYPE = d
        set d.duration = 3686
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer HEADHUNTRESS_PISSED2_SOUND_TYPE = 'S01B'
        endglobals

        set d = InitSoundTypeEx(HEADHUNTRESS_PISSED2_SOUND_TYPE, "Units\\NightElf\\Tyrande\\TyrandePissed2.wav" )
        set HEADHUNTRESS_PISSED2_SOUND_TYPE = d
        set d.duration = 4359
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer HEADHUNTRESS_PISSED3_SOUND_TYPE = 'S01C'
        endglobals

        set d = InitSoundTypeEx(HEADHUNTRESS_PISSED3_SOUND_TYPE, "Units\\NightElf\\Tyrande\\TyrandePissed3.wav" )
        set HEADHUNTRESS_PISSED3_SOUND_TYPE = d
        set d.duration = 2640
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer HEADHUNTRESS_PISSED4_SOUND_TYPE = 'S01D'
        endglobals

        set d = InitSoundTypeEx(HEADHUNTRESS_PISSED4_SOUND_TYPE, "Units\\NightElf\\Tyrande\\TyrandePissed4.wav" )
        set HEADHUNTRESS_PISSED4_SOUND_TYPE = d
        set d.duration = 2099
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer HEADHUNTRESS_PISSED5_SOUND_TYPE = 'S01E'
        endglobals

        set d = InitSoundTypeEx(HEADHUNTRESS_PISSED5_SOUND_TYPE, "Units\\NightElf\\Tyrande\\TyrandePissed5.wav" )
        set HEADHUNTRESS_PISSED5_SOUND_TYPE = d
        set d.duration = 4672
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer LICH_PISSED_SOUND_TYPE = 'S01F'
        endglobals

        set d = InitSoundTypeEx(LICH_PISSED_SOUND_TYPE, "Units\\Undead\\KelThuzadLich\\KelThuzadPissed1.wav" )
        set LICH_PISSED_SOUND_TYPE = d
        set d.duration = 4127
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 63

        globals
            integer LICH_PISSED2_SOUND_TYPE = 'S01G'
        endglobals

        set d = InitSoundTypeEx(LICH_PISSED2_SOUND_TYPE, "Units\\Undead\\KelThuzadLich\\KelThuzadPissed2.wav" )
        set LICH_PISSED2_SOUND_TYPE = d
        set d.duration = 5712
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer LICH_PISSED3_SOUND_TYPE = 'S01H'
        endglobals

        set d = InitSoundTypeEx(LICH_PISSED3_SOUND_TYPE, "Units\\Undead\\KelThuzadLich\\KelThuzadPissed3.wav" )
        set LICH_PISSED3_SOUND_TYPE = d
        set d.duration = 2494
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer LICH_PISSED4_SOUND_TYPE = 'S01I'
        endglobals

        set d = InitSoundTypeEx(LICH_PISSED4_SOUND_TYPE, "Units\\Undead\\KelThuzadLich\\KelThuzadPissed4.wav" )
        set LICH_PISSED4_SOUND_TYPE = d
        set d.duration = 4809
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer LICH_PISSED5_SOUND_TYPE = 'S01J'
        endglobals

        set d = InitSoundTypeEx(LICH_PISSED5_SOUND_TYPE, "Units\\Undead\\KelThuzadLich\\KelThuzadPissed5.wav" )
        set LICH_PISSED5_SOUND_TYPE = d
        set d.duration = 6504
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer MEDICINE_MAN_PISSED_SOUND_TYPE = 'S01K'
        endglobals

        set d = InitSoundTypeEx(MEDICINE_MAN_PISSED_SOUND_TYPE, "Units\\Orc\\Thrall\\ThrallPissed1.wav" )
        set MEDICINE_MAN_PISSED_SOUND_TYPE = d
        set d.duration = 1607
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer MEDICINE_MAN_PISSED2_SOUND_TYPE = 'S01L'
        endglobals

        set d = InitSoundTypeEx(MEDICINE_MAN_PISSED2_SOUND_TYPE, "Units\\Orc\\Thrall\\ThrallPissed2.wav" )
        set MEDICINE_MAN_PISSED2_SOUND_TYPE = d
        set d.duration = 2786
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer MEDICINE_MAN_PISSED3_SOUND_TYPE = 'S01M'
        endglobals

        set d = InitSoundTypeEx(MEDICINE_MAN_PISSED3_SOUND_TYPE, "Units\\Orc\\Thrall\\ThrallPissed3.wav" )
        set MEDICINE_MAN_PISSED3_SOUND_TYPE = d
        set d.duration = 1983
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer MEDICINE_MAN_PISSED4_SOUND_TYPE = 'S01N'
        endglobals

        set d = InitSoundTypeEx(MEDICINE_MAN_PISSED4_SOUND_TYPE, "Units\\Orc\\Thrall\\ThrallPissed4.wav" )
        set MEDICINE_MAN_PISSED4_SOUND_TYPE = d
        set d.duration = 3493
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer BLACK_KNIGHT_PISSED_SOUND_TYPE = 'S01O'
        endglobals

        set d = InitSoundTypeEx(BLACK_KNIGHT_PISSED_SOUND_TYPE, "Units\\Undead\\HeroDeathKnight\\DeathKnightPissed1.wav" )
        set BLACK_KNIGHT_PISSED_SOUND_TYPE = d
        set d.duration = 3089
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer BLACK_KNIGHT_PISSED2_SOUND_TYPE = 'S01P'
        endglobals

        set d = InitSoundTypeEx(BLACK_KNIGHT_PISSED2_SOUND_TYPE, "Units\\Undead\\HeroDeathKnight\\DeathKnightPissed2.wav" )
        set BLACK_KNIGHT_PISSED2_SOUND_TYPE = d
        set d.duration = 2999
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer BLACK_KNIGHT_PISSED3_SOUND_TYPE = 'S01Q'
        endglobals

        set d = InitSoundTypeEx(BLACK_KNIGHT_PISSED3_SOUND_TYPE, "Units\\Undead\\HeroDeathKnight\\DeathKnightPissed3.wav" )
        set BLACK_KNIGHT_PISSED3_SOUND_TYPE = d
        set d.duration = 3989
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer BLACK_KNIGHT_PISSED4_SOUND_TYPE = 'S01R'
        endglobals

        set d = InitSoundTypeEx(BLACK_KNIGHT_PISSED4_SOUND_TYPE, "Units\\Undead\\HeroDeathKnight\\DeathKnightPissed4.wav" )
        set BLACK_KNIGHT_PISSED4_SOUND_TYPE = d
        set d.duration = 4350
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer BLACK_KNIGHT_PISSED5_SOUND_TYPE = 'S01S'
        endglobals

        set d = InitSoundTypeEx(BLACK_KNIGHT_PISSED5_SOUND_TYPE, "Units\\Undead\\HeroDeathKnight\\DeathKnightPissed5.wav" )
        set BLACK_KNIGHT_PISSED5_SOUND_TYPE = d
        set d.duration = 2129
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer BLACK_KNIGHT_PISSED6_SOUND_TYPE = 'S01T'
        endglobals

        set d = InitSoundTypeEx(BLACK_KNIGHT_PISSED6_SOUND_TYPE, "Units\\Undead\\HeroDeathKnight\\DeathKnightPissed6.wav" )
        set BLACK_KNIGHT_PISSED6_SOUND_TYPE = d
        set d.duration = 4079
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer PALADIN_PISSED_SOUND_TYPE = 'S01U'
        endglobals

        set d = InitSoundTypeEx(PALADIN_PISSED_SOUND_TYPE, "Units\\Human\\Arthas\\ArthasPissed1.wav" )
        set PALADIN_PISSED_SOUND_TYPE = d
        set d.duration = 1698
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer PALADIN_PISSED2_SOUND_TYPE = 'S01V'
        endglobals

        set d = InitSoundTypeEx(PALADIN_PISSED2_SOUND_TYPE, "Units\\Human\\Arthas\\ArthasPissed2.wav" )
        set PALADIN_PISSED2_SOUND_TYPE = d
        set d.duration = 2609
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer PALADIN_PISSED3_SOUND_TYPE = 'S01W'
        endglobals

        set d = InitSoundTypeEx(PALADIN_PISSED3_SOUND_TYPE, "Units\\Human\\Arthas\\ArthasPissed3.wav" )
        set PALADIN_PISSED3_SOUND_TYPE = d
        set d.duration = 2043
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer PALADIN_PISSED4_SOUND_TYPE = 'S01X'
        endglobals

        set d = InitSoundTypeEx(PALADIN_PISSED4_SOUND_TYPE, "Units\\Human\\Arthas\\ArthasPissed4.wav" )
        set PALADIN_PISSED4_SOUND_TYPE = d
        set d.duration = 1994
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer PALADIN_PISSED5_SOUND_TYPE = 'S01Y'
        endglobals

        set d = InitSoundTypeEx(PALADIN_PISSED5_SOUND_TYPE, "Units\\Human\\Arthas\\ArthasPissed5.wav" )
        set PALADIN_PISSED5_SOUND_TYPE = d
        set d.duration = 1558
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer PALADIN_PISSED6_SOUND_TYPE = 'S01Z'
        endglobals

        set d = InitSoundTypeEx(PALADIN_PISSED6_SOUND_TYPE, "Units\\Human\\Arthas\\ArthasPissed6.wav" )
        set PALADIN_PISSED6_SOUND_TYPE = d
        set d.duration = 1082
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer PALADIN_PISSED7_SOUND_TYPE = 'S020'
        endglobals

        set d = InitSoundTypeEx(PALADIN_PISSED7_SOUND_TYPE, "Units\\Human\\Arthas\\ArthasPissed7.wav" )
        set PALADIN_PISSED7_SOUND_TYPE = d
        set d.duration = 2030
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer TRAVELLING_TRADER_PISSED_SOUND_TYPE = 'S021'
        endglobals

        set d = InitSoundTypeEx(TRAVELLING_TRADER_PISSED_SOUND_TYPE, "Units\\Creeps\\HEROGoblinALCHEMIST\\HeroAlchemistPissed1.wav" )
        set TRAVELLING_TRADER_PISSED_SOUND_TYPE = d
        set d.duration = 2642
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer TRAVELLING_TRADER_PISSED2_SOUND_TYPE = 'S022'
        endglobals

        set d = InitSoundTypeEx(TRAVELLING_TRADER_PISSED2_SOUND_TYPE, "Units\\Creeps\\HEROGoblinALCHEMIST\\HeroAlchemistPissed2.wav" )
        set TRAVELLING_TRADER_PISSED2_SOUND_TYPE = d
        set d.duration = 1736
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer TRAVELLING_TRADER_PISSED3_SOUND_TYPE = 'S023'
        endglobals

        set d = InitSoundTypeEx(TRAVELLING_TRADER_PISSED3_SOUND_TYPE, "Units\\Creeps\\HEROGoblinALCHEMIST\\HeroAlchemistPissed3.wav" )
        set TRAVELLING_TRADER_PISSED3_SOUND_TYPE = d
        set d.duration = 3541
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer TRAVELLING_TRADER_PISSED4_SOUND_TYPE = 'S024'
        endglobals

        set d = InitSoundTypeEx(TRAVELLING_TRADER_PISSED4_SOUND_TYPE, "Units\\Creeps\\HEROGoblinALCHEMIST\\HeroAlchemistPissed4.wav" )
        set TRAVELLING_TRADER_PISSED4_SOUND_TYPE = d
        set d.duration = 3608
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer TRAVELLING_TRADER_PISSED5_SOUND_TYPE = 'S025'
        endglobals

        set d = InitSoundTypeEx(TRAVELLING_TRADER_PISSED5_SOUND_TYPE, "Units\\Creeps\\HEROGoblinALCHEMIST\\HeroAlchemistPissed5.wav" )
        set TRAVELLING_TRADER_PISSED5_SOUND_TYPE = d
        set d.duration = 3700
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer TRAVELLING_TRADER_PISSED6_SOUND_TYPE = 'S026'
        endglobals

        set d = InitSoundTypeEx(TRAVELLING_TRADER_PISSED6_SOUND_TYPE, "Units\\Creeps\\HEROGoblinALCHEMIST\\HeroAlchemistPissed6.wav" )
        set TRAVELLING_TRADER_PISSED6_SOUND_TYPE = d
        set d.duration = 10879
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer WITCH_PISSED_SOUND_TYPE = 'S027'
        endglobals

        set d = InitSoundTypeEx(WITCH_PISSED_SOUND_TYPE, "Units\\Human\\Jaina\\JainaPissed1.wav" )
        set WITCH_PISSED_SOUND_TYPE = d
        set d.duration = 1377
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer WITCH_PISSED2_SOUND_TYPE = 'S028'
        endglobals

        set d = InitSoundTypeEx(WITCH_PISSED2_SOUND_TYPE, "Units\\Human\\Jaina\\JainaPissed2.wav" )
        set WITCH_PISSED2_SOUND_TYPE = d
        set d.duration = 1244
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer WITCH_PISSED3_SOUND_TYPE = 'S029'
        endglobals

        set d = InitSoundTypeEx(WITCH_PISSED3_SOUND_TYPE, "Units\\Human\\Jaina\\JainaPissed3.wav" )
        set WITCH_PISSED3_SOUND_TYPE = d
        set d.duration = 2365
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer WITCH_PISSED4_SOUND_TYPE = 'S02A'
        endglobals

        set d = InitSoundTypeEx(WITCH_PISSED4_SOUND_TYPE, "Units\\Human\\Jaina\\JainaPissed4.wav" )
        set WITCH_PISSED4_SOUND_TYPE = d
        set d.duration = 1950
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer WITCH_PISSED5_SOUND_TYPE = 'S02B'
        endglobals

        set d = InitSoundTypeEx(WITCH_PISSED5_SOUND_TYPE, "Units\\Human\\Jaina\\JainaPissed5.wav" )
        set WITCH_PISSED5_SOUND_TYPE = d
        set d.duration = 1623
        set d.eax = "HeroAcksEAX"
        set d.pitch = 1
        set d.volume = 127

        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //  Misc
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

        globals
            integer ERROR_SOUND_TYPE = 'S02C'
        endglobals

        set d = InitSoundTypeEx(ERROR_SOUND_TYPE, "Sound\\Interface\\Error.wav" )
        set ERROR_SOUND_TYPE = d
        set d.duration = 2043
        set d.eax = "DefaultEAXON"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer LIGHTNING_IMPACT_SOUND_TYPE = 'S02D'
        endglobals

        set d = InitSoundTypeEx(LIGHTNING_IMPACT_SOUND_TYPE, "Abilities\\Spells\\Other\\StormEarthFire\\PandarenUltimate.wav" )
        set LIGHTNING_IMPACT_SOUND_TYPE = d
        set d.duration = 3251
        set d.eax = "DefaultEAXON"
        set d.is3D = true
        set d.pitch = 0.4
        set d.volume = 127

        globals
            integer HINT_SOUND_TYPE = 'S02E'
        endglobals

        set d = InitSoundTypeEx(HINT_SOUND_TYPE, "Sound\\Interface\\Hint.wav" )
        set HINT_SOUND_TYPE = d
        set d.duration = 2006
        set d.eax = "DefaultEAXON"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer MIST_SOUND_TYPE = 'S02G'
        endglobals

        set d = InitSoundTypeEx(MIST_SOUND_TYPE, "Sound\\Ambient\\Ashenvale\\FreakyForest1.wav" )
        set MIST_SOUND_TYPE = d
        set d.duration = 3135
        set d.eax = "DefaultEAXON"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer MIST2_SOUND_TYPE = 'S02H'
        endglobals

        set d = InitSoundTypeEx(MIST2_SOUND_TYPE, "Sound\\Ambient\\Ashenvale\\FreakyForest2.wav" )
        set MIST2_SOUND_TYPE = d
        set d.duration = 3901
        set d.eax = "DefaultEAXON"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer MIST3_SOUND_TYPE = 'S02I'
        endglobals

        set d = InitSoundTypeEx(MIST3_SOUND_TYPE, "Sound\\Ambient\\Ashenvale\\FreakyForest3.wav" )
        set MIST3_SOUND_TYPE = d
        set d.duration = 4830
        set d.eax = "DefaultEAXON"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer MIST4_SOUND_TYPE = 'S02J'
        endglobals

        set d = InitSoundTypeEx(MIST4_SOUND_TYPE, "Sound\\Ambient\\Ashenvale\\FreakyForest4.wav" )
        set MIST4_SOUND_TYPE = d
        set d.duration = 5248
        set d.eax = "DefaultEAXON"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer MIST5_SOUND_TYPE = 'S02K'
        endglobals

        set d = InitSoundTypeEx(MIST5_SOUND_TYPE, "Units\\NightElf\\Wisp\\WispPissed1.wav" )
        set MIST5_SOUND_TYPE = d
        set d.duration = 2798
        set d.eax = "DefaultEAXON"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer MIST6_SOUND_TYPE = 'S02L'
        endglobals

        set d = InitSoundTypeEx(MIST6_SOUND_TYPE, "Units\\NightElf\\Wisp\\WispPissed2.wav" )
        set MIST6_SOUND_TYPE = d
        set d.duration = 2786
        set d.eax = "DefaultEAXON"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer MIST7_SOUND_TYPE = 'S02M'
        endglobals

        set d = InitSoundTypeEx(MIST7_SOUND_TYPE, "Units\\NightElf\\Wisp\\WispPissed3.wav" )
        set MIST7_SOUND_TYPE = d
        set d.duration = 2682
        set d.eax = "DefaultEAXON"
        set d.pitch = 1
        set d.volume = 127

        globals
            integer RAIN_SOUND_TYPE = 'S02N'
        endglobals

        set d = InitSoundTypeEx(RAIN_SOUND_TYPE, "Sound\\Ambient\\RainAmbience.wav" )
        set RAIN_SOUND_TYPE = d
        set d.duration = 4418
        set d.eax = "DefaultEAXON"
        set d.looping = true
        set d.pitch = 1
        set d.volume = 127

        globals
            integer RECEIVE_GOLD_SOUND_TYPE = 'S02O'
        endglobals

        set d = InitSoundTypeEx(RECEIVE_GOLD_SOUND_TYPE, "Abilities\\Spells\\Items\\ResourceItems\\ReceiveGold.wav" )
        set RECEIVE_GOLD_SOUND_TYPE = d
        set d.duration = 589
        set d.eax = "SpellsEAX"
        set d.is3D = true
        set d.pitch = 1
        set d.volume = 127

        globals
            integer REFRESH_SOUND_TYPE = 'S02P'
        endglobals

        set d = InitSoundTypeEx(REFRESH_SOUND_TYPE, "Abilities\\Spells\\Items\\AIre\\RestorationPotion.wav" )
        set REFRESH_SOUND_TYPE = d
        set d.duration = 3158
        set d.eax = "DefaultEAXON"
        set d.is3D = true
        set d.pitch = 1
        set d.volume = 127

        globals
            integer REFRESH_MANA_SOUND_TYPE = 'S02Q'
        endglobals

        set d = InitSoundTypeEx(REFRESH_MANA_SOUND_TYPE, "Abilities\\Spells\\Items\\AIma\\ManaPotion.wav" )
        set REFRESH_MANA_SOUND_TYPE = d
        set d.duration = 1555
        set d.eax = "SpellsEAX"
        set d.is3D = true
        set d.pitch = 1
        set d.volume = 127

        globals
            integer SNOW_GHOST_MANA_DRAIN_SOUND_TYPE = 'S02R'
        endglobals

        set d = InitSoundTypeEx(SNOW_GHOST_MANA_DRAIN_SOUND_TYPE, "Abilities\\Spells\\NightElf\\ManaBurn\\ManaDrainTarget1.wav" )
        set SNOW_GHOST_MANA_DRAIN_SOUND_TYPE = d
        set d.duration = 1357
        set d.eax = "SpellsEAX"
        set d.is3D = true
        set d.pitch = 1
        set d.volume = 127

        globals
            integer WATER_SOUND_TYPE = 'S02S'
        endglobals

        set d = InitSoundTypeEx(WATER_SOUND_TYPE, "Sound\\Ambient\\DoodadEffects\\WaterLakeLoop1.wav" )
        set WATER_SOUND_TYPE = d
        set d.duration = 3297
        set d.eax = "DoodadsEAX"
        set d.is3D = true
        set d.pitch = 0.65
        set d.stop = true
        set d.volume = 127

        globals
            integer WATER2_SOUND_TYPE = 'S02T'
        endglobals

        set d = InitSoundTypeEx(WATER2_SOUND_TYPE, "Sound\\Ambient\\DoodadEffects\\WaterWavesLoop1.wav" )
        set WATER2_SOUND_TYPE = d
        set d.duration = 7445
        set d.eax = "DoodadsEAX"
        set d.is3D = true
        set d.pitch = 0.65
        set d.stop = true
        set d.volume = 110
    endfunction
endscope