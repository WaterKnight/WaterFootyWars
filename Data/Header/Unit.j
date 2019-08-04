//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("Unit")
    globals
        Unit CASTER
        Unit FILTER_UNIT
        unit FILTER_UNIT_SELF
        private constant integer Stun_AMOUNT = 6
        Unit TARGET_UNIT
        Unit TEMP_UNIT
        unit TEMP_UNIT_SELF
        UnitType TEMP_UNIT_TYPE
        Unit TRIGGER_UNIT = NULL
        unit TRIGGER_UNIT_SELF
        UnitType TRIGGER_UNIT_TYPE
    endglobals

    struct UnitType
        integer array abilities[13]
        integer abilitiesCount = -1
        real agility = 0
        real agilityPerLevel = 0
        real armor = 0
        real array armorForPlayer[MAX_PLAYERS_AMOUNT]
        real array armorBySpellForPlayer[MAX_PLAYERS_AMOUNT]
        integer armorType = 0
        real array attackRateForPlayer[MAX_PLAYERS_AMOUNT]
        integer automaticAbility = 0
        string blood = null
        string bloodExplosion = null
        boolean canNotBeRevived = false
        boolean canNotBeInited = false
        real array criticalStrikeForPlayer[MAX_PLAYERS_AMOUNT]
        boolean decay = false
        real decayTime = 0
        real damage = 0
        integer damageDices = 0
        integer damageDicesSides = 0
        real array damageForPlayer[MAX_PLAYERS_AMOUNT]
        integer damageType = 0
        integer drop = 0
        integer ep = 0
        integer goldCost = 0
        integer array heroAbilities[4]
        integer heroAbilitiesCount = -1
        integer id
        string imagePath
        real impactZ = 0
        real intelligence = 0
        real intelligencePerLevel = 0
        boolean isAltar = false
        boolean isCaster = false
        boolean isMelee = false
        boolean isShared = false
        boolean isSpawn = false
        boolean isTownHall = false
        boolean isWard = false
        integer level = 0
        real lifeRegeneration = 0
        real array lifeRegenerationForPlayer[MAX_PLAYERS_AMOUNT]
        real mana = 0
        real manaRegeneration = 0
        real array manaRegenerationForPlayer[MAX_PLAYERS_AMOUNT]
        real maxLife = 0
        real array maxLifeForPlayer[MAX_PLAYERS_AMOUNT]
        real maxMana = 0
        real array maxManaForPlayer[MAX_PLAYERS_AMOUNT]
        real missileArc = 0
        integer missileDummyUnitId = 0
        real missileSpeed = 0
        real outpactZ = 0
        SoundType array pissedSounds[12]
        integer pissedSoundsCount = -1
        integer primaryAttribute = 0
        Race race = NULL
        real scale = 0
        real sightRange = 0
        integer shopMaxCharges = 0
        real shopRefreshInterval = 0
        real shopRefreshIntervalStart = 0
        integer spawnBonus = 0
        integer spawnStage = 0
        real spawnTime = 0
        real array spawnTimeForPlayer[MAX_PLAYERS_AMOUNT]
        integer spawnTypeId = 0
        boolean specialAttack = false
        real speed = 0
        real array speedForPlayer[MAX_PLAYERS_AMOUNT]
        boolean array splash[MAX_NEUTRAL_PLAYERS_AMOUNT]
        boolean splashAffectionAir = false
        boolean splashAffectionAlly = false
        boolean splashAffectionEnemy = false
        boolean splashAffectionGround = false
        real splashAreaRange = 0
        real splashDamageFactor = 0
        real splashWindowAngle = 0
        real strength = 0
        real strengthPerLevel = 0
        integer supplyProduced = 0
        integer supplyUsed = 0
        boolean upgradesInstantly = false
        real vertexColorRed = 0
        real vertexColorGreen = 0
        real vertexColorBlue = 0
        real vertexColorAlpha = 0

        static method create_Executed takes nothing returns nothing
            local integer iteration = MAX_PLAYER_INDEX
            local UnitType new = TEMP_UNIT_TYPE
            loop
                set new.armorForPlayer[iteration] = 0
                set new.armorBySpellForPlayer[iteration] = 0
                set new.attackRateForPlayer[iteration] = 0
                set new.criticalStrikeForPlayer[iteration] = 0
                set new.damageForPlayer[iteration] = 0
                set new.lifeRegenerationForPlayer[iteration] = 0
                set new.manaRegenerationForPlayer[iteration] = 0
                set new.maxLifeForPlayer[iteration] = 0
                set new.maxManaForPlayer[iteration] = 0
                set new.spawnTimeForPlayer[iteration] = 0
                set new.speedForPlayer[iteration] = 0
                set iteration = iteration - 1
                exitwhen (iteration < 0)
            endloop
        endmethod

        static method create takes nothing returns UnitType
            set TEMP_UNIT_TYPE = UnitType.allocate()
            call UnitType.create_Executed.execute()
            return TEMP_UNIT_TYPE
        endmethod
    endstruct

    function GetUnitType takes integer whichUnitTypeId returns UnitType
        return GetAttachedIntegerById(whichUnitTypeId, UNIT_TYPE_KEY)
    endfunction

    //! textmacro CreateSimpleUnitTypeState takes structMember, name, type
        function GetUnitType$name$ takes UnitType whichUnitType returns $type$
            return whichUnitType.$structMember$
        endfunction

        function SetUnitType$name$ takes UnitType whichUnitType, $type$ amount returns nothing
            set whichUnitType.$structMember$ = amount
        endfunction
    //! endtextmacro

    //! textmacro CreateSimpleUnitTypeStateForPlayer takes structMember, name, type
        function GetUnitType$name$ForPlayer takes UnitType whichUnitType, player whichPlayer returns $type$
            return whichUnitType.$structMember$ForPlayer[GetPlayerId(whichPlayer)]
        endfunction

        function SetUnitType$name$ForPlayer takes UnitType whichUnitType, player whichPlayer, $type$ amount returns nothing
            set whichUnitType.$structMember$ForPlayer[GetPlayerId(whichPlayer)] = amount
        endfunction

        function AddUnitType$name$ForPlayer takes UnitType whichUnitType, player whichPlayer, $type$ amount returns nothing
            call SetUnitType$name$ForPlayer(whichUnitType, whichPlayer, GetUnitType$name$ForPlayer(whichUnitType, whichPlayer) + amount)
        endfunction
    //! endtextmacro

    //! textmacro CreateSimpleFlagUnitTypeState takes structMember, name
        function IsUnitType$name$ takes UnitType whichUnitType returns boolean
            return whichUnitType.$structMember$
        endfunction

        function SetUnitType$name$ takes UnitType whichUnitType returns nothing
            set whichUnitType.$structMember$ = true
        endfunction
    //! endtextmacro

    //! runtextmacro CreateSimpleFlagUnitTypeState("canNotBeRevived", "CanNotBeRevived")
    //! runtextmacro CreateSimpleFlagUnitTypeState("canNotBeInited", "CanNotBeInited")
    //! runtextmacro CreateSimpleFlagUnitTypeState("decay", "Decay")
    //! runtextmacro CreateSimpleFlagUnitTypeState("specialAttack", "SpecialAttack")

    //! runtextmacro Scope("Splash")
        function IsUnitTypeSplashForPlayer takes UnitType whichUnitType, player whichPlayer returns boolean
            return whichUnitType.splash[GetPlayerId(whichPlayer)]
        endfunction

        function SetUnitTypeSplashForPlayer takes UnitType whichUnitType, player whichPlayer returns nothing
            set whichUnitType.splash[GetPlayerId(whichPlayer)] = true
        endfunction

        function SetUnitTypeSplash takes UnitType whichUnitType returns nothing
            local integer iteration = MAX_NEUTRAL_PLAYER_INDEX
            loop
                call SetUnitTypeSplashForPlayer(whichUnitType, PlayerWJ(iteration))
                set iteration = iteration - 1
                exitwhen (iteration < 0)
            endloop
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro CreateSimpleUnitTypeState("goldCost", "GoldCost", "integer")
    //! runtextmacro CreateSimpleUnitTypeState("imagePath", "Image", "string")
    //! runtextmacro CreateSimpleUnitTypeState("primaryAttribute", "PrimaryAttribute", "integer")
    //! runtextmacro CreateSimpleUnitTypeState("race", "Race", "Race")
    //! runtextmacro CreateSimpleUnitTypeState("mana", "StartMana", "real")

    //! runtextmacro CreateSimpleUnitTypeState("missileArc", "MissileArc", "real")
    //! runtextmacro CreateSimpleUnitTypeState("missileDummyUnitId", "MissileDummyUnitId", "integer")
    //! runtextmacro CreateSimpleUnitTypeState("missileSpeed", "MissileSpeed", "real")

    //! runtextmacro CreateSimpleFlagUnitTypeState("isAltar", "Altar")
    //! runtextmacro CreateSimpleFlagUnitTypeState("isCaster", "Caster")
    //! runtextmacro CreateSimpleFlagUnitTypeState("isMelee", "Melee")
    //! runtextmacro CreateSimpleFlagUnitTypeState("isShared", "Shared")
    //! runtextmacro CreateSimpleFlagUnitTypeState("isSpawn", "Spawn")
    //! runtextmacro CreateSimpleFlagUnitTypeState("isTownHall", "TownHall")
    //! runtextmacro CreateSimpleFlagUnitTypeState("isWard", "Ward")

    //! runtextmacro CreateSimpleFlagUnitTypeState("splashAffectionAir", "SplashAffectionAir")
    //! runtextmacro CreateSimpleFlagUnitTypeState("splashAffectionAlly", "SplashAffectionAlly")
    //! runtextmacro CreateSimpleFlagUnitTypeState("splashAffectionEnemy", "SplashAffectionEnemy")
    //! runtextmacro CreateSimpleFlagUnitTypeState("splashAffectionGround", "SplashAffectionGround")
    //! runtextmacro CreateSimpleUnitTypeState("splashAreaRange", "SplashAreaRange", "real")
    //! runtextmacro CreateSimpleUnitTypeState("splashDamageFactor", "SplashDamageFactor", "real")
    //! runtextmacro CreateSimpleUnitTypeState("splashWindowAngle", "SplashWindowAngle", "real")

    //! runtextmacro CreateSimpleFlagUnitTypeState("upgradesInstantly", "UpgradesInstantly")

    struct Unit
        real agility = 0
        real agilityBonus = 0
        integer anyDamageEvents = 0
        real armor = 0
        real armorBonus = 0
        real armorBreakRelativeBonus = 0
        real armorBySpellBonus = 0
        real armorRelativeBonus = 0
        real attackRate = 0
        integer attackSilence = 0
        integer automaticAbility = 0
        real criticalStrike = 0
        real criticalStrikeDefense = 0
        integer criticalStrikeImmunity = 0
        integer currentUpgradeGoldCost = 0
        string blood = null
        string bloodExplosion = null
        integer canNotBeRevived = 0
        real damage = 0
        real damageBonus = 0
        real damageBySpellBonus = 0
        real damageRelativeBonus = 0
        boolean dead = false
        integer decay = 0
        real decayTime = 0
        integer drop = 0
        integer dropBonus = 0
        integer dropByKillBonus = 0
        real dropByKillRelativeBonus = 0
        real evasion = 0
        integer explode = 0
        integer frostSlow = 0
        effect frostSlowEffect = null
        integer ghost = 0
        integer goldSpentInUpgrades = 0
        real healBySpell = 0
        integer id
        real impactZ = 0
        real intelligence = 0
        real intelligenceBonus = 0
        integer invisibility = 0
        integer invulnerability = 0
        integer invulnerabilityEffectAmount = 0
        effect invulnerabilityEffect = null
        integer level = 0
        real lifeRegeneration = 0
        real lifeRegenerationBonus = 0
        integer magicImmunity = 0
        real manaRegeneration = 0
        real manaRegenerationBonus = 0
        real maxLife = 0
        real maxMana = 0
        real miss = 0
        real outpactZ = 0
        widget orderTarget = null
        real orderX = 0
        real orderY = 0
        player owner
        integer pathing = 1
        integer pause = 0
        real rallyX = 0
        real rallyY = 0
        integer remainingReferences = 0
        integer revaluation = 0
        real scale = 0
        real array scaleForPlayer[MAX_PLAYERS_AMOUNT]
        unit self
        real sightRange = 0
        integer silence = 0
        real speed = 0
        real speedBonus = 0
        real strength = 0
        real strengthBonus = 0
        integer array stun[Stun_AMOUNT]
        integer stunEntanglingRoots = 0
        real stunDurationRelativeBonus = 0
        effect array stunEffect[Stun_AMOUNT]
        integer stunEnsnare = 0
        integer stunThunderbolt = 0
        integer supplyProduced = 0
        integer supplyUsed = 0
        UnitType type
        real vertexColorRed = 0
        real array vertexColorRedForPlayer[MAX_PLAYERS_AMOUNT]
        real vertexColorGreen = 0
        real array vertexColorGreenForPlayer[MAX_PLAYERS_AMOUNT]
        real vertexColorBlue = 0
        real array vertexColorBlueForPlayer[MAX_PLAYERS_AMOUNT]
        real vertexColorAlpha = 0
        real array vertexColorAlphaForPlayer[MAX_PLAYERS_AMOUNT]
        boolean waitsForRemoval = false

        static method create_Executed takes nothing returns nothing
            local integer iteration = MAX_PLAYER_INDEX
            local Unit new = TEMP_UNIT
            loop
                set new.scaleForPlayer[iteration] = 0
                set new.vertexColorRedForPlayer[iteration] = 0
                set new.vertexColorGreenForPlayer[iteration] = 0
                set new.vertexColorBlueForPlayer[iteration] = 0
                set new.vertexColorAlphaForPlayer[iteration] = 0
                set iteration = iteration - 1
                exitwhen (iteration < 0)
            endloop
        endmethod

        static method create takes nothing returns Unit
            set TEMP_UNIT = Unit.allocate()
            call Unit.create_Executed.execute()
            return TEMP_UNIT
        endmethod
    endstruct

    function GetUnit takes unit whichUnit returns Unit
        return GetAttachedInteger(whichUnit, UNIT_KEY)
    endfunction

    //! textmacro CreateSimpleUnitState takes structMember, name, type
        function GetUnit$name$ takes Unit whichUnit returns $type$
            return whichUnit.$structMember$
        endfunction

        function SetUnit$name$ takes Unit whichUnit, $type$ amount returns nothing
            set whichUnit.$structMember$ = amount
        endfunction

        function AddUnit$name$ takes Unit whichUnit, $type$ amount returns nothing
            call SetUnit$name$( whichUnit, GetUnit$name$(whichUnit) + amount)
        endfunction
    //! endtextmacro

    //! textmacro CreateSimpleAddUnitState takes structMember, name, type
        function GetUnit$name$ takes Unit whichUnit returns $type$
            return whichUnit.$structMember$
        endfunction

        function RemoveUnit$name$ takes Unit whichUnit returns nothing
            set whichUnit.$structMember$ = GetUnit$name$(whichUnit) - 1
        endfunction

        function SetUnit$name$ takes Unit whichUnit, $type$ amount returns nothing
            set whichUnit.$structMember$ = amount
        endfunction

        function AddUnit$name$ takes Unit whichUnit returns nothing
            call SetUnit$name$( whichUnit, GetUnit$name$(whichUnit) + 1)
        endfunction
    //! endtextmacro

    //! textmacro CreateSimpleFlagUnitState takes structMember, name
        function IsUnit$name$ takes Unit whichUnit returns boolean
            return whichUnit.$structMember$
        endfunction

        function SetUnit$name$ takes Unit whichUnit, boolean flag returns nothing
            set whichUnit.$structMember$ = flag
        endfunction
    //! endtextmacro

    //! textmacro CreateSimpleFlagCountUnitState takes structMember, name
        function GetUnit$name$ takes Unit whichUnit returns integer
            return whichUnit.$structMember$
        endfunction

        function RemoveUnit$name$ takes Unit whichUnit returns nothing
            set whichUnit.$structMember$ = GetUnit$name$(whichUnit) - 1
        endfunction

        function SetUnit$name$ takes Unit whichUnit, integer amount returns nothing
            set whichUnit.$structMember$ = amount
        endfunction

        function AddUnit$name$ takes Unit whichUnit returns nothing
            set whichUnit.$structMember$ = GetUnit$name$(whichUnit) + 1
        endfunction

        function AddUnit$name$ByAmount takes Unit whichUnit, integer amount returns nothing
            set whichUnit.$structMember$ = GetUnit$name$(whichUnit) + amount
        endfunction
    //! endtextmacro

    //! runtextmacro CreateSimpleFlagCountUnitState("anyDamageEvents", "AnyDamageEvents")
    //! runtextmacro CreateSimpleFlagCountUnitState("canNotBeRevived", "CanNotBeRevived")
    //! runtextmacro CreateSimpleFlagUnitState("dead", "Dead")
    //! runtextmacro CreateSimpleFlagCountUnitState("decay", "Decay")
    //! runtextmacro CreateSimpleUnitState("goldSpentInUpgrades", "GoldSpentInUpgrades", "integer")

    scope AutomaticAbility
        function GetUnitAutomaticAbility takes Unit whichUnit returns integer
            return whichUnit.automaticAbility
        endfunction

        function SetUnitAutomaticAbility takes Unit whichUnit, integer whichAbility returns nothing
            set whichUnit.automaticAbility = whichAbility
        endfunction

        //! runtextmacro CreateSimpleUnitTypeState("automaticAbility", "AutomaticAbility", "integer")
    endscope

    function IsUnitWard takes Unit whichUnit returns boolean
        return IsUnitTypeWard( GetUnitType(GetUnitTypeId(whichUnit.self)) )
    endfunction

    //! runtextmacro Scope("OutpactZ")
        //! runtextmacro CreateSimpleUnitState("outpactZ", "OutpactZ", "real")

        //! runtextmacro CreateSimpleUnitTypeState("outpactZ", "OutpactZ", "real")
    //! runtextmacro Endscope()

    //! runtextmacro Scope("ImpactZ")
        //! runtextmacro CreateSimpleUnitState("impactZ", "ImpactZ", "real")

        function GetUnitTypeImpactZ takes UnitType whichUnitType returns real
            return whichUnitType.impactZ
        endfunction

        function SetUnitTypeImpactZ takes UnitType whichUnitType, real amount returns nothing
            set whichUnitType.impactZ = amount
            call SetUnitTypeOutpactZ(whichUnitType, amount)
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro Scope("Decay")

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //! runtextmacro CreateSimpleUnitState("decayTime", "DecayTime", "real")

        //! runtextmacro CreateSimpleUnitTypeState("decayTime", "DecayTime", "real")
    //! runtextmacro Endscope()

    //! runtextmacro Scope("UpdateUnitDisplay")
        globals
            private constant integer DUMMY_SPELL_ID = 'A012'
        endglobals

        function UpdateUnitDisplay takes unit whichUnit returns nothing
            call UnitAddAbility( whichUnit, DUMMY_SPELL_ID )
            call UnitRemoveAbility( whichUnit, DUMMY_SPELL_ID )
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro Scope("EP")
        function GetUnitEP takes unit whichUnit returns integer
            return GetHeroXP( whichUnit )
        endfunction

        function SetUnitEP takes unit whichUnit, real amount returns nothing
            call SetHeroXP( whichUnit, R2I( amount ), false )
            call UpdateUnitDisplay(whichUnit)
        endfunction

        function AddUnitEP takes unit whichUnit, real amount returns nothing
            call SetUnitEP( whichUnit, GetUnitEP( whichUnit ) + amount )
        endfunction

        function SetUnitSkillPointsWJ takes unit whichUnit, integer amount returns nothing
            call UnitModifySkillPoints( whichUnit, amount - GetHeroSkillPoints( whichUnit ) )
        endfunction

        //! runtextmacro CreateSimpleUnitTypeState("ep", "EP", "integer")
    //! runtextmacro Endscope()

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("Supply")
        function GetUnitSupplyProduced takes Unit whichUnit returns integer
            return whichUnit.supplyProduced
        endfunction

        function SetUnitSupplyProduced takes Unit whichUnit, player whichUnitOwner, integer amount returns nothing
            local integer oldAmount = GetUnitSupplyProduced( whichUnit )
            set whichUnit.supplyProduced = amount
            call AddPlayerState( whichUnitOwner, PLAYER_STATE_RESOURCE_FOOD_CAP, amount - oldAmount )
        endfunction

        function AddUnitSupplyProduced takes Unit whichUnit, player whichUnitOwner, integer amount returns nothing
            call SetUnitSupplyProduced( whichUnit, whichUnitOwner, GetUnitSupplyProduced( whichUnit ) + amount )
        endfunction

        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        //! runtextmacro CreateSimpleUnitTypeState("supplyProduced", "SupplyProduced", "integer")

        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        function GetUnitSupplyUsed takes Unit whichUnit returns integer
            return whichUnit.supplyUsed
        endfunction

        function SetUnitSupplyUsed takes Unit whichUnit, player whichUnitOwner, integer amount returns nothing
            local integer oldAmount = GetUnitSupplyUsed( whichUnit )
            set whichUnit.supplyUsed = amount
            call AddPlayerState( whichUnitOwner, PLAYER_STATE_RESOURCE_FOOD_USED, amount - oldAmount )
        endfunction

        function AddUnitSupplyUsed takes Unit whichUnit, player whichUnitOwner, integer amount returns nothing
            call SetUnitSupplyUsed( whichUnit, whichUnitOwner, GetUnitSupplyUsed( whichUnit ) + amount )
        endfunction

        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        //! runtextmacro CreateSimpleUnitTypeState("supplyUsed", "SupplyUsed", "integer")
    //! runtextmacro Endscope()

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function GetUnitFacingWJ takes unit whichUnit returns real
        return GetUnitFacing( whichUnit ) * DEG_TO_RAD
    endfunction

    function GetUnitLevelWJ takes UnitType whichUnitType returns integer
        return whichUnitType.level
    endfunction

    function GetUnitCurrentTarget takes Unit whichUnit returns widget
        return whichUnit.orderTarget
    endfunction

    function GetUnitCurrentX takes Unit whichUnit returns real
        return whichUnit.orderX
    endfunction

    function GetUnitCurrentY takes Unit whichUnit returns real
        return whichUnit.orderX
    endfunction

    function SetUnitFacingWJ takes unit whichUnit, real angle returns nothing
        call SetUnitFacing( whichUnit, angle * RAD_TO_DEG )
    endfunction

    function AddUnitState takes unit whichUnit, unitstate whichUnitState, real value returns nothing
        call SetUnitState( whichUnit, whichUnitState, GetUnitState( whichUnit, whichUnitState ) + value )
    endfunction

    function DispelUnit takes Unit whichUnit, boolean negativeBuffs, boolean positiveBuffs, boolean showGraphics returns nothing
        set UnitIsDispelled_NEGATIVE_BUFFS = negativeBuffs
        set UnitIsDispelled_POSITIVE_BUFFS = positiveBuffs
        set UnitIsDispelled_SHOW_GRAPHICS = showGraphics
        set TRIGGER_UNIT = whichUnit
        call RunTrigger( UnitIsDispelled_DUMMY_TRIGGER )
    endfunction

    function IsUnitChanneling takes Unit whichUnit returns boolean
        return false
    endfunction

    function UnitHasItemOfType takes Unit whichUnit, integer whichItemTypeId returns boolean
        local integer inventorySize
        local unit whichUnitSelf = whichUnit.self
        local integer iteration = UnitInventorySize( whichUnitSelf ) - 1
        loop
            exitwhen ( iteration < 0 )
            if ( GetItemTypeId( UnitItemInSlot( whichUnitSelf, iteration ) ) == whichItemTypeId ) then
                return true
            endif
            set iteration = iteration - 1
        endloop
        set whichUnitSelf = null
        return false
    endfunction

    function InitAbility takes integer abilcode returns nothing
        //call UnitAddAbility( WORLD_CASTER, abilcode )
        call UnitRemoveAbility( WORLD_CASTER, abilcode )
    endfunction

    function UnitApplyTimedLifeWJ takes unit whichUnit, real time returns nothing
        call UnitApplyTimedLife( whichUnit, 'BTLF', time )
    endfunction

    function SetUnitOwnerWJ takes Unit whichUnit, player whichPlayer, boolean changeColor returns nothing
        local unit whichUnitSelf = whichUnit.self
        if ( changeColor ) then
            call SetUnitColor( whichUnitSelf, GetPlayerColor( whichPlayer ) )
        endif
        call SetUnitOwner( whichUnitSelf, whichPlayer, false )
        set whichUnitSelf = null
    endfunction

    //! runtextmacro Scope("Position")
        globals
            private item DUMMY_ITEM
        endglobals

        function SetUnitXWJ takes unit whichUnit, real x returns nothing
            if ( x < PLAY_RECT_MIN_X ) then
        debug call WriteBug( "Unterschreitung MapX: " + GetUnitName( whichUnit ) + "; " + R2S( x ) )
                set x = PLAY_RECT_MIN_X
            elseif ( x > PLAY_RECT_MAX_X ) then
        debug call WriteBug( "Ueberschreitung MapX: " + GetUnitName( whichUnit ) + "; " + R2S( x ) )
                set x = PLAY_RECT_MAX_X
            endif
            call SetUnitX( whichUnit, x )
        endfunction

        function SetUnitYWJ takes unit whichUnit, real y returns nothing
            if ( y < PLAY_RECT_MIN_Y ) then
        debug call WriteBug( "Unterschreitung MapY: " + GetUnitName( whichUnit ) + "; " + R2S( y ) )
                set y = PLAY_RECT_MIN_Y
            elseif ( y > PLAY_RECT_MAX_Y ) then
        debug call WriteBug( "Ueberschreitung MapY: " + GetUnitName( whichUnit ) + "; " + R2S( y ) )
                set y = PLAY_RECT_MAX_Y
            endif
            call SetUnitY( whichUnit, y )
        endfunction

        //! runtextmacro Scope("SetUnitZ")
            globals
                private constant integer SetUnitZ_DUMMY_SPELL_ID = 'Amrf'
            endglobals

            function GetUnitZ takes unit whichUnit, real x, real y returns real
                return GetFloorHeight( x, y ) + GetUnitFlyHeight( whichUnit )
            endfunction

            function SetUnitZ takes unit whichUnit, real x, real y, real z returns nothing
                call SetUnitFlyHeight( whichUnit, z - GetFloorHeight( x, y ), 0 )
            endfunction

            function InitUnitZ takes unit whichUnit returns nothing
                call UnitAddAbility(whichUnit, SetUnitZ_DUMMY_SPELL_ID)
                call UnitRemoveAbility(whichUnit, SetUnitZ_DUMMY_SPELL_ID)
            endfunction
        //! runtextmacro Endscope()

        function SetUnitXIfNotBlocked takes unit whichUnit, real oldX, real oldY, real x returns boolean
            call SetItemPosition( DUMMY_ITEM, x, oldY )
            if ( ( Absolute( GetItemX( DUMMY_ITEM ) - x ) < 1 ) and ( Absolute( GetItemY( DUMMY_ITEM ) - oldY ) < 1 ) ) then
                call SetUnitX( whichUnit, x )
                return false
            endif
            return true
        endfunction

        function SetUnitYIfNotBlocked takes unit whichUnit, real oldX, real oldY, real y returns boolean
            call SetItemPosition( DUMMY_ITEM, oldX, y )
            if ( ( Absolute( GetItemX( DUMMY_ITEM ) - oldX ) < 1 ) and ( Absolute( GetItemY( DUMMY_ITEM ) - y ) < 1 ) ) then
                call SetUnitY( whichUnit, y )
                return false
            endif
            return true
        endfunction

        function SetUnitXYIfNotBlocked takes unit whichUnit, real oldX, real oldY, real x, real y returns boolean
            if ( SetUnitXIfNotBlocked( whichUnit, oldX, oldY, x ) ) then
                if ( SetUnitYIfNotBlocked( whichUnit, x, oldY, y ) ) then
                    return true
                endif
            else
                call SetUnitYIfNotBlocked( whichUnit, oldX, oldY, y )
            endif
            return false
        endfunction

        public function Position_Init takes nothing returns nothing
            set DUMMY_ITEM = CreateHiddenItem('I014')
        endfunction
    //! runtextmacro Endscope()

    function CheckMoveEvents takes Unit whichUnit, real x, real y, real z returns nothing
        set TRIGGER_UNIT = whichUnit
        set UnitIsMoveChecked_X = x
        set UnitIsMoveChecked_Y = y
        set UnitIsMoveChecked_Z = z
        call RunTrigger(UnitIsMoveChecked_DUMMY_TRIGGER)
    endfunction

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Armor
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("Armor")
        //! runtextmacro Scope("Base")
            //! runtextmacro CreateSimpleUnitState("armor", "Armor", "real")
        //! runtextmacro Endscope()

        //! runtextmacro Scope("Bonus")
            globals
                private constant integer Bonus_DECREASING_ABILITIES_MAX = 6
                private integer array Bonus_DECREASING_ABILITIES
                private constant integer Bonus_INCREASING_ABILITIES_MAX = 6
                private integer array Bonus_INCREASING_ABILITIES
            endglobals

            function GetUnitArmorBonus takes Unit whichUnit returns real
                return whichUnit.armorBonus
            endfunction

            function SetUnitArmorBonus takes Unit whichUnit, real amount returns nothing
                local integer packet
                local integer packetLevel
                local real previousAmount = GetUnitArmorBonus(whichUnit)
                local unit whichUnitSelf = whichUnit.self
                set whichUnit.armorBonus = amount
                if (amount * previousAmount <= 0) then
                    if (previousAmount < 0) then
                        set packetLevel = Bonus_DECREASING_ABILITIES_MAX
                        loop
                            call UnitRemoveAbility(whichUnitSelf, Bonus_DECREASING_ABILITIES[packetLevel])
                            set packetLevel = packetLevel - 1
                            exitwhen (packetLevel < 0)
                        endloop
                    else
                        set packetLevel = Bonus_INCREASING_ABILITIES_MAX
                        loop
                            call UnitRemoveAbility(whichUnitSelf, Bonus_INCREASING_ABILITIES[packetLevel])
                            set packetLevel = packetLevel - 1
                            exitwhen (packetLevel < 0)
                        endloop
                    endif
                    if (amount < 0) then
                        set packetLevel = R2I(Min(Log(Max(Absolute(previousAmount), Absolute(amount)), 2), Bonus_DECREASING_ABILITIES_MAX))
                        set packet = R2I(Pow(2, packetLevel))
                        set amount = -amount
                        loop
                            exitwhen (packetLevel < 0)
                            if (packet <= amount) then
                                call UnitAddAbility(whichUnitSelf, Bonus_DECREASING_ABILITIES[packetLevel])
                                set amount = amount - packet
                            endif
                            set packet = packet / 2
                            set packetLevel = packetLevel - 1
                        endloop
                    else
                        set packetLevel = R2I(Min(Log(Max(Absolute(previousAmount), Absolute(amount)), 2), Bonus_INCREASING_ABILITIES_MAX))
                        set packet = R2I(Pow(2, packetLevel))
                        loop
                            exitwhen (packetLevel < 0)
                            if (packet <= amount) then
                                call UnitAddAbility(whichUnitSelf, Bonus_INCREASING_ABILITIES[packetLevel])
                                set amount = amount - packet
                            endif
                            set packet = packet / 2
                            set packetLevel = packetLevel - 1
                        endloop
                    endif
                else
                    set packetLevel = R2I(Min(Log(Max(Absolute(previousAmount), Absolute(amount)), 2), Bonus_DECREASING_ABILITIES_MAX))
                    set packet = R2I(Pow(2, packetLevel))
                    if (amount < 0) then
                        set amount = -amount
                        loop
                            exitwhen (packetLevel < 0)
                            if (packet <= amount) then
                                call UnitAddAbility(whichUnitSelf, Bonus_DECREASING_ABILITIES[packetLevel])
                                set amount = amount - packet
                            else
                                call UnitRemoveAbility(whichUnitSelf, Bonus_DECREASING_ABILITIES[packetLevel])
                            endif
                            set packet = packet / 2
                            set packetLevel = packetLevel - 1
                        endloop
                    else
                    set packetLevel = R2I(Min(Log(Max(Absolute(previousAmount), Absolute(amount)), 2), Bonus_INCREASING_ABILITIES_MAX))
                    set packet = R2I(Pow(2, packetLevel))
                        loop
                            exitwhen (packetLevel < 0)
                            if (packet <= amount) then
                                call UnitAddAbility(whichUnitSelf, Bonus_INCREASING_ABILITIES[packetLevel])
                                set amount = amount - packet
                            else
                                call UnitRemoveAbility(whichUnitSelf, Bonus_INCREASING_ABILITIES[packetLevel])
                            endif
                            set packet = packet / 2
                            set packetLevel = packetLevel - 1
                        endloop
                    endif
                endif
                set whichUnitSelf = null
            endfunction

            function AddUnitArmorBonus takes Unit whichUnit, real amount returns nothing
                call SetUnitArmorBonus( whichUnit, GetUnitArmorBonus( whichUnit ) + amount )
            endfunction

            public function Bonus_Init takes nothing returns nothing
                set Bonus_DECREASING_ABILITIES[0] = 'A00U'
                set Bonus_DECREASING_ABILITIES[1] = 'A06E'
                set Bonus_DECREASING_ABILITIES[2] = 'A06F'
                set Bonus_DECREASING_ABILITIES[3] = 'A06G'
                set Bonus_DECREASING_ABILITIES[4] = 'A06H'
                set Bonus_DECREASING_ABILITIES[5] = 'A06I'
                set Bonus_DECREASING_ABILITIES[6] = 'A06J'

                set Bonus_INCREASING_ABILITIES[0] = 'A00T'
                set Bonus_INCREASING_ABILITIES[1] = 'A068'
                set Bonus_INCREASING_ABILITIES[2] = 'A069'
                set Bonus_INCREASING_ABILITIES[3] = 'A06A'
                set Bonus_INCREASING_ABILITIES[4] = 'A06B'
                set Bonus_INCREASING_ABILITIES[5] = 'A06C'
                set Bonus_INCREASING_ABILITIES[6] = 'A06D'
            endfunction
        //! runtextmacro Endscope()

        function GetUnitArmorTotal takes Unit whichUnit returns real
            return (GetUnitArmor(whichUnit) + GetUnitArmorBonus(whichUnit))
        endfunction

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        //! runtextmacro CreateSimpleUnitTypeState("armor", "Armor", "real")

        //! runtextmacro CreateSimpleUnitTypeStateForPlayer("armor", "Armor", "real")

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        //! runtextmacro CreateSimpleUnitState("armorRelativeBonus", "ArmorRelativeBonus", "real")

        //! runtextmacro CreateSimpleUnitState("armorBreakRelativeBonus", "ArmorBreakRelativeBonus", "real")

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        //! runtextmacro CreateSimpleUnitState("armorBySpellBonus", "ArmorBySpellBonus", "real")

        //! runtextmacro CreateSimpleUnitTypeStateForPlayer("armorBySpell", "ArmorBySpell", "real")

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        //! runtextmacro CreateSimpleUnitTypeState("armorType", "ArmorType", "integer")

        public function Armor_Init takes nothing returns nothing
            call Bonus_Bonus_Init()
        endfunction
    //! runtextmacro Endscope()

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Attack
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("Attack")
        //! runtextmacro Scope("AttackMultiplier")
            globals
                constant integer ARMOR_TYPE_LIGHT = 0
                constant integer ARMOR_TYPE_MEDIUM = 1
                constant integer ARMOR_TYPE_LARGE = 2
                constant integer ARMOR_TYPE_FORT = 3
                constant integer ARMOR_TYPE_HERO = 4
                constant integer ARMOR_TYPE_UNARMORED = 5
                constant integer ARMOR_TYPE_DIVINE = 6

                private constant integer ARMOR_TYPES_AMOUNT = 7
                private real array ATTACK_MULTIPLIERS

                constant integer DMG_TYPE_NORMAL = 0
                constant integer DMG_TYPE_PIERCE = 1
                constant integer DMG_TYPE_SIEGE = 2
                constant integer DMG_TYPE_MAGIC = 3
                constant integer DMG_TYPE_CHAOS = 4
                constant integer DMG_TYPE_HERO = 5
                constant integer DMG_TYPE_SPELLS = 6
            endglobals

            function GetAttackMultiplier takes integer whichDamageType, integer whichArmorType returns real
                return ATTACK_MULTIPLIERS[whichDamageType * ARMOR_TYPES_AMOUNT + whichArmorType]
            endfunction

            private function InitAttackMultiplier takes integer whichDamageType, integer whichArmorType, real amount returns nothing
                set ATTACK_MULTIPLIERS[whichDamageType * ARMOR_TYPES_AMOUNT + whichArmorType] = amount
            endfunction

            public function AttackMultiplier_Init takes nothing returns nothing
                call InitAttackMultiplier(DMG_TYPE_NORMAL, ARMOR_TYPE_LIGHT, 1)
                call InitAttackMultiplier(DMG_TYPE_NORMAL, ARMOR_TYPE_MEDIUM, 1.35)
                call InitAttackMultiplier(DMG_TYPE_NORMAL, ARMOR_TYPE_LARGE, 1)
                call InitAttackMultiplier(DMG_TYPE_NORMAL, ARMOR_TYPE_FORT, 0.7)
                call InitAttackMultiplier(DMG_TYPE_NORMAL, ARMOR_TYPE_HERO, 1)
                call InitAttackMultiplier(DMG_TYPE_NORMAL, ARMOR_TYPE_UNARMORED, 1)
                call InitAttackMultiplier(DMG_TYPE_NORMAL, ARMOR_TYPE_DIVINE, 1)

                call InitAttackMultiplier(DMG_TYPE_PIERCE, ARMOR_TYPE_LIGHT, 1.5)
                call InitAttackMultiplier(DMG_TYPE_PIERCE, ARMOR_TYPE_MEDIUM, 0.7)
                call InitAttackMultiplier(DMG_TYPE_PIERCE, ARMOR_TYPE_LARGE, 1)
                call InitAttackMultiplier(DMG_TYPE_PIERCE, ARMOR_TYPE_FORT, 0.35)
                call InitAttackMultiplier(DMG_TYPE_PIERCE, ARMOR_TYPE_HERO, 0.5)
                call InitAttackMultiplier(DMG_TYPE_PIERCE, ARMOR_TYPE_UNARMORED, 1.35)
                call InitAttackMultiplier(DMG_TYPE_PIERCE, ARMOR_TYPE_DIVINE, 1)

                call InitAttackMultiplier(DMG_TYPE_SIEGE, ARMOR_TYPE_LIGHT, 1)
                call InitAttackMultiplier(DMG_TYPE_SIEGE, ARMOR_TYPE_MEDIUM, 0.65)
                call InitAttackMultiplier(DMG_TYPE_SIEGE, ARMOR_TYPE_LARGE, 1)
                call InitAttackMultiplier(DMG_TYPE_SIEGE, ARMOR_TYPE_FORT, 1.5)
                call InitAttackMultiplier(DMG_TYPE_SIEGE, ARMOR_TYPE_HERO, 0.35)
                call InitAttackMultiplier(DMG_TYPE_SIEGE, ARMOR_TYPE_UNARMORED, 1)
                call InitAttackMultiplier(DMG_TYPE_SIEGE, ARMOR_TYPE_DIVINE, 1)

                call InitAttackMultiplier(DMG_TYPE_MAGIC, ARMOR_TYPE_LIGHT, 1.25)
                call InitAttackMultiplier(DMG_TYPE_MAGIC, ARMOR_TYPE_MEDIUM, 0.75)
                call InitAttackMultiplier(DMG_TYPE_MAGIC, ARMOR_TYPE_LARGE, 1.5)
                call InitAttackMultiplier(DMG_TYPE_MAGIC, ARMOR_TYPE_FORT, 0.35)
                call InitAttackMultiplier(DMG_TYPE_MAGIC, ARMOR_TYPE_HERO, 0.5)
                call InitAttackMultiplier(DMG_TYPE_MAGIC, ARMOR_TYPE_UNARMORED, 1)
                call InitAttackMultiplier(DMG_TYPE_MAGIC, ARMOR_TYPE_DIVINE, 1)

                call InitAttackMultiplier(DMG_TYPE_CHAOS, ARMOR_TYPE_LIGHT, 1)
                call InitAttackMultiplier(DMG_TYPE_CHAOS, ARMOR_TYPE_MEDIUM, 1)
                call InitAttackMultiplier(DMG_TYPE_CHAOS, ARMOR_TYPE_LARGE, 1)
                call InitAttackMultiplier(DMG_TYPE_CHAOS, ARMOR_TYPE_FORT, 1)
                call InitAttackMultiplier(DMG_TYPE_CHAOS, ARMOR_TYPE_HERO, 1)
                call InitAttackMultiplier(DMG_TYPE_CHAOS, ARMOR_TYPE_UNARMORED, 1)
                call InitAttackMultiplier(DMG_TYPE_CHAOS, ARMOR_TYPE_DIVINE, 1)

                call InitAttackMultiplier(DMG_TYPE_HERO, ARMOR_TYPE_LIGHT, 1)
                call InitAttackMultiplier(DMG_TYPE_HERO, ARMOR_TYPE_MEDIUM, 1)
                call InitAttackMultiplier(DMG_TYPE_HERO, ARMOR_TYPE_LARGE, 1)
                call InitAttackMultiplier(DMG_TYPE_HERO, ARMOR_TYPE_FORT, 1)
                call InitAttackMultiplier(DMG_TYPE_HERO, ARMOR_TYPE_HERO, 1)
                call InitAttackMultiplier(DMG_TYPE_HERO, ARMOR_TYPE_UNARMORED, 1)
                call InitAttackMultiplier(DMG_TYPE_HERO, ARMOR_TYPE_DIVINE, 1)

                call InitAttackMultiplier(DMG_TYPE_SPELLS, ARMOR_TYPE_LIGHT, 1)
                call InitAttackMultiplier(DMG_TYPE_SPELLS, ARMOR_TYPE_MEDIUM, 1)
                call InitAttackMultiplier(DMG_TYPE_SPELLS, ARMOR_TYPE_LARGE, 1)
                call InitAttackMultiplier(DMG_TYPE_SPELLS, ARMOR_TYPE_FORT, 0.5)
                call InitAttackMultiplier(DMG_TYPE_SPELLS, ARMOR_TYPE_HERO, 1)
                call InitAttackMultiplier(DMG_TYPE_SPELLS, ARMOR_TYPE_UNARMORED, 1)
                call InitAttackMultiplier(DMG_TYPE_SPELLS, ARMOR_TYPE_DIVINE, 1)
            endfunction
        //! runtextmacro Endscope()

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        //! runtextmacro Scope("Silence")
            globals
                private constant integer Silence_DUMMY_SPELL_ID = 'Abun'
                private constant integer Silence_ICON_DUMMY_SPELL_ID = 'A08P'
            endglobals

            function GetUnitAttackSilence takes Unit whichUnit returns integer
                return whichUnit.attackSilence
            endfunction

            function RemoveUnitAttackSilence takes Unit whichUnit returns nothing
                local integer amount = GetUnitAttackSilence( whichUnit ) - 1
                local unit whichUnitSelf
                set whichUnit.attackSilence = amount
                if ( amount == 0 ) then
                    set whichUnitSelf = whichUnit.self
                    call UnitRemoveAbility( whichUnitSelf, Silence_DUMMY_SPELL_ID )
                    call UnitRemoveAbility( whichUnitSelf, Silence_ICON_DUMMY_SPELL_ID )
                    set whichUnitSelf = null
                endif
            endfunction

            function AddUnitAttackSilence takes Unit whichUnit returns nothing
                local integer amount = GetUnitAttackSilence( whichUnit ) + 1
                local unit whichUnitSelf
                set whichUnit.attackSilence = amount
                if ( amount == 1 ) then
                    set whichUnitSelf = whichUnit.self
                    call UnitAddAbility( whichUnitSelf, Silence_DUMMY_SPELL_ID )
                    call UnitAddAbility( whichUnitSelf, Silence_ICON_DUMMY_SPELL_ID )
                    set whichUnitSelf = null
                endif
            endfunction

            public function Silence_Init takes nothing returns nothing
                call InitAbility(Silence_DUMMY_SPELL_ID)
            endfunction
        //! runtextmacro Endscope()

        public function Attack_Init takes nothing returns nothing
            call AttackMultiplier_AttackMultiplier_Init()
            call Silence_Silence_Init()
        endfunction
    //! runtextmacro Endscope()

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Blood
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("Blood")
        //! runtextmacro CreateSimpleUnitState("blood", "Blood", "string")

        //! runtextmacro CreateSimpleUnitTypeState("blood", "Blood", "string")

        //! runtextmacro CreateSimpleUnitState("bloodExplosion", "BloodExplosion", "string")

        //! runtextmacro CreateSimpleUnitTypeState("bloodExplosion", "BloodExplosion", "string")
    //! runtextmacro Endscope()

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Pause
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("Pause")
        function RemoveUnitPause takes Unit whichUnit returns nothing
            local integer amount = whichUnit.pause - 1
            set whichUnit.pause = amount
            if (amount == 0) then
                call PauseUnit( whichUnit.self, false )
            endif
        endfunction

        function AddUnitPause takes Unit whichUnit returns nothing
            local integer amount = whichUnit.pause + 1
            set whichUnit.pause = amount
            if (amount == 1) then
                call PauseUnit( whichUnit.self, true )
            endif
        endfunction
    //! runtextmacro Endscope()

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Critical Strike
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("CriticalStrike")
        globals
            constant real CRITICAL_STRIKE_DAMAGE_FACTOR = 2.
        endglobals

        //! runtextmacro CreateSimpleUnitState("criticalStrike", "CriticalStrike", "real")

        //! runtextmacro CreateSimpleUnitTypeStateForPlayer("criticalStrike", "CriticalStrike", "real")

        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        //! runtextmacro CreateSimpleUnitState("criticalStrikeDefense", "CriticalStrikeDefense", "real")

        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        function GetUnitCriticalStrikeImmunity takes Unit whichUnit returns integer
            return whichUnit.criticalStrikeImmunity
        endfunction

        function RemoveUnitCriticalStrikeImmunity takes Unit whichUnit returns nothing
            set whichUnit.criticalStrikeImmunity = GetUnitCriticalStrikeImmunity(whichUnit) - 1
        endfunction

        function AddUnitCriticalStrikeImmunity takes Unit whichUnit returns nothing
            set whichUnit.criticalStrikeImmunity = GetUnitCriticalStrikeImmunity(whichUnit) + 1
        endfunction
    //! runtextmacro Endscope()

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Drop
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("Drop")
        globals
            private constant real Drop_HERO_LEVEL_FACTOR = 23.
        endglobals

        //! runtextmacro Scope("Bonus")
            //! runtextmacro CreateSimpleUnitState("dropBonus", "DropBonus", "integer")

            ///////////////////////////////////////////////////////////////////////////////////////////////////////////

            //! runtextmacro CreateSimpleUnitState("dropByKillBonus", "DropByKillBonus", "integer")

            //! runtextmacro CreateSimpleUnitState("dropByKillRelativeBonus", "DropByKillRelativeBonus", "real")
        //! runtextmacro Endscope()

        //! runtextmacro CreateSimpleUnitTypeState("drop", "Drop", "integer")

        function GetUnitDrop takes UnitType whichUnitType returns integer
            return GetUnitTypeDrop(whichUnitType)
        endfunction

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        function GetAttackDrop takes UnitType attacker, Unit victim, UnitType victimType returns integer
            return R2I( ( GetUnitTypeDrop( victimType ) + GetHeroLevel( victim.self ) * Drop_HERO_LEVEL_FACTOR ) * ( 1 + GetUnitDropByKillRelativeBonus( attacker ) ) + GetUnitDropByKillBonus( attacker ) + GetUnitDropBonus( victim ) )
        endfunction
    //! runtextmacro Endscope()

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function ClearUnitRequestQueue takes Unit whichUnit returns nothing
        local integer iteration = 1
        local unit whichUnitSelf = whichUnit.self
        loop
            exitwhen ( iteration > 8 )
            set UnitGetsOrder_IGNORE_NEXT = true
            call IssueImmediateOrderById( whichUnitSelf, CANCEL_ORDER_ID )
            set iteration = iteration + 1
        endloop
        set UnitGetsOrder_IGNORE_NEXT = false
        set whichUnitSelf = null
    endfunction

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////    Invulnerability
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("Invulnerability")
        globals
            private constant string Invulnerability_TARGET_EFFECT_PATH = "Abilities\\Spells\\Human\\DivineShield\\DivineShieldTarget.mdl"
            private constant string Invulnerability_TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        endglobals

        function GetUnitInvulnerability takes Unit whichUnit returns integer
            return whichUnit.invulnerability
        endfunction

        function RemoveUnitInvulnerability takes Unit whichUnit returns nothing
            local integer amount = GetUnitInvulnerability(whichUnit) - 1
            set whichUnit.invulnerability = amount
            if (amount == 0) then
                call SetUnitInvulnerable(whichUnit.self, false)
            endif
        endfunction

        function AddUnitInvulnerability takes Unit whichUnit returns nothing
            local integer amount = GetUnitInvulnerability(whichUnit) + 1
            set whichUnit.invulnerability = amount
            if (amount == 1) then
                call SetUnitInvulnerable(whichUnit.self, true)
            endif
        endfunction

        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

        function GetUnitInvulnerabilityEffectAmount takes Unit whichUnit returns integer
            return whichUnit.invulnerabilityEffectAmount
        endfunction

        function RemoveUnitInvulnerabilityWithEffect takes Unit whichUnit returns nothing
            local integer amount = GetUnitInvulnerabilityEffectAmount(whichUnit) - 1
            set whichUnit.invulnerabilityEffectAmount = amount
            if (amount == 0) then
                call DestroyEffectWJ(whichUnit.invulnerabilityEffect)
            endif
            call RemoveUnitInvulnerability(whichUnit)
        endfunction

        function AddUnitInvulnerabilityWithEffect takes Unit whichUnit returns nothing
            local integer amount = GetUnitInvulnerabilityEffectAmount(whichUnit) + 1
            set whichUnit.invulnerabilityEffectAmount = amount
            if (amount == 1) then
                set whichUnit.invulnerabilityEffect = AddSpecialEffectTargetWJ( Invulnerability_TARGET_EFFECT_PATH, whichUnit.self, Invulnerability_TARGET_EFFECT_ATTACHMENT_POINT )
            endif
            call AddUnitInvulnerability(whichUnit)
        endfunction

        //! runtextmacro Scope("Timed")
            private struct Timed_Data
                timer durationTimer
                Unit target
            endstruct

            private function Timed_Ending takes Timed_Data d, timer durationTimer, Unit target returns nothing
                call FlushAttachedInteger( durationTimer, Timed_SCOPE_ID )
                call DestroyTimerWJ( durationTimer )
                call FlushAttachedIntegerById( target.id, Timed_SCOPE_ID )
                call RemoveUnitInvulnerabilityWithEffect( target )
            endfunction

            private function Timed_EndingByTimer takes nothing returns nothing
                local timer durationTimer = GetExpiredTimer()
                local Timed_Data d = GetAttachedInteger(durationTimer, Timed_SCOPE_ID)
                call Timed_Ending(d, durationTimer, d.target)
                set durationTimer = null
            endfunction

            function SetUnitInvulnerabilityTimed takes Unit target, real duration returns nothing
                local timer durationTimer
                local integer targetId = target.id
                local Timed_Data d = GetAttachedIntegerById( targetId, Timed_SCOPE_ID )
                if ( d == NULL ) then
                    set d = Timed_Data.create()
                    set durationTimer = CreateTimerWJ()
                    set d.durationTimer = durationTimer
                    set d.target = target
                    call AttachInteger( durationTimer, Timed_SCOPE_ID, d )
                    call AttachIntegerById( targetId, Timed_SCOPE_ID, d )
                    call AddUnitInvulnerabilityWithEffect( target )
                else
                    set durationTimer = d.durationTimer
                endif
                if ( duration > TimerGetRemaining( durationTimer ) ) then
                    call TimerStart( durationTimer, duration, false, function Timed_EndingByTimer )
                endif
                set durationTimer = null
            endfunction
        //! runtextmacro Endscope()

        public function Invulnerability_Init takes nothing returns nothing
            call InitEffectType(Invulnerability_TARGET_EFFECT_PATH)
        endfunction
    //! runtextmacro Endscope()

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function UnitDamageUnitEx takes Unit whichUnit, Unit whichTarget, real amount, weapontype whichWeaponType returns nothing
        local boolean causesDeath
        local integer DamageTrigger
        local player whichTargetOwner
        local unit whichTargetSelf = whichTarget.self
        local unit whichUnitSelf = whichUnit.self
        if ( GetUnitInvulnerability( whichTarget ) <= 0 ) then
            call DisableTrigger( UnitTakesDamage_DUMMY_TRIGGER )
            if (GetUnitAnyDamageEvents(whichTarget) > 0) then
                set DAMAGE_AMOUNT = amount
                set DAMAGE_SOURCE = whichUnit
                set TRIGGER_UNIT = whichTarget
                call RunTrigger(UnitTakesAnyDamage_DUMMY_TRIGGER)
                set amount = DAMAGE_AMOUNT
            endif
            set causesDeath = ( ( amount >= GetUnitState( whichTargetSelf, UNIT_STATE_LIFE ) - LIMIT_OF_DEATH ) and ( whichUnit != null ) )
            if ( causesDeath ) then
                set whichTargetOwner = whichTarget.owner
                if ( IsUnitEnemy( whichUnitSelf, whichTargetOwner ) ) then
                    if ( GetAttackDrop( whichUnit, whichTarget, whichTarget.type ) != GetUnitDrop( whichTarget ) ) then
                        call SetPlayerState( whichTargetOwner, PLAYER_STATE_GIVES_BOUNTY, 0 )
                    endif
                    set TRIGGER_UNIT = whichUnit
                endif
                set whichTargetOwner = null
                if ( IsUnitType( whichTargetSelf, UNIT_TYPE_STRUCTURE ) ) then
                    call ClearUnitRequestQueue( whichTarget )
                endif
            endif
            call UnitDamageTarget( whichUnitSelf, whichTargetSelf, amount, false, false, null, null, whichWeaponType )
            call EnableTrigger( UnitTakesDamage_DUMMY_TRIGGER )
            if ( causesDeath ) then
                set TRIGGER_UNIT = whichUnit
            endif
        endif
        set whichTargetSelf = null
        set whichUnitSelf = null
    endfunction

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Damage
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("Damage")
        //! runtextmacro Scope("Base")
            globals
                private constant integer Base_DECREASING_ITEMS_MAX = 6
                private item array Base_DECREASING_ITEMS
                private constant integer Base_INCREASING_ITEMS_MAX = 6
                private item array Base_INCREASING_ITEMS
            endglobals

            function GetUnitDamage takes Unit whichUnit returns real
                return whichUnit.damage
            endfunction

            function SetUnitDamage takes Unit whichUnit, real amount returns nothing
                local integer packet
                local integer packetLevel
                local real previousAmount = GetUnitDamage(whichUnit)
                local unit whichUnitSelf = whichUnit.self
                local boolean hasInventory = (UnitInventorySize(whichUnitSelf) > 0)
                set whichUnit.damage = amount
                set amount = R2I(amount) - R2I(previousAmount)
                if (hasInventory == false) then
                    call UnitAddAbility(whichUnitSelf, HERO_INVENTORY_SPELL_ID)
                endif
                if (amount < 0) then
                    set amount = -amount
                    set packet = 64
                    set packetLevel = Base_DECREASING_ITEMS_MAX
                    loop
                        exitwhen (amount < 1)
                        loop
                            exitwhen (amount < packet)
                            call UnitAddItem(whichUnitSelf, Base_DECREASING_ITEMS[packetLevel])
                            call SetWidgetLife(Base_DECREASING_ITEMS[packetLevel], 1)
                            set amount = amount - packet
                        endloop
                        set packet = packet / 2
                        set packetLevel = packetLevel - 1
                    endloop
                else
                    set packet = 64
                    set packetLevel = Base_INCREASING_ITEMS_MAX
                    loop
                        exitwhen (amount < 1)
                        loop
                            exitwhen (amount < packet)
                            call UnitAddItem(whichUnitSelf, Base_INCREASING_ITEMS[packetLevel])
                            call SetWidgetLife(Base_INCREASING_ITEMS[packetLevel], 1)
                            set amount = amount - packet
                        endloop
                        set packet = packet / 2
                        set packetLevel = packetLevel - 1
                    endloop
                endif
                if (hasInventory == false) then
                    call UnitRemoveAbility(whichUnitSelf, HERO_INVENTORY_SPELL_ID)
                endif
                set whichUnitSelf = null
            endfunction

            function AddUnitDamage takes Unit whichUnit, real amount returns nothing
                call SetUnitDamage( whichUnit, GetUnitDamage( whichUnit ) + amount )
            endfunction

            public function Base_Init takes nothing returns nothing
                local integer array itemTypes
                local integer iteration = 0

                set itemTypes[0] = 'I00N'
                set itemTypes[1] = 'I00O'
                set itemTypes[2] = 'I00P'
                set itemTypes[3] = 'I00Q'
                set itemTypes[4] = 'I00R'
                set itemTypes[5] = 'I00S'
                set itemTypes[6] = 'I00T'
                loop
                    exitwhen (iteration > Base_DECREASING_ITEMS_MAX)
                    set Base_DECREASING_ITEMS[iteration] = CreateHiddenItem(itemTypes[iteration])
                    set iteration = iteration + 1
                endloop

                set itemTypes[0] = 'I00G'
                set itemTypes[1] = 'I00H'
                set itemTypes[2] = 'I00I'
                set itemTypes[3] = 'I00J'
                set itemTypes[4] = 'I00K'
                set itemTypes[5] = 'I00L'
                set itemTypes[6] = 'I00M'
                set iteration = 0
                loop
                    exitwhen (iteration > Base_INCREASING_ITEMS_MAX)
                    set Base_INCREASING_ITEMS[iteration] = CreateHiddenItem(itemTypes[iteration])
                    set iteration = iteration + 1
                endloop
            endfunction
        //! runtextmacro Endscope()

        //! runtextmacro Scope("Bonus")
            globals
                private constant integer Bonus_DECREASING_ABILITIES_MAX = 6
                private integer array Bonus_DECREASING_ABILITIES
                private constant integer Bonus_INCREASING_ABILITIES_MAX = 6
                private integer array Bonus_INCREASING_ABILITIES
            endglobals

            function GetUnitDamageBonus takes Unit whichUnit returns real
                return whichUnit.damageBonus
            endfunction

            function SetUnitDamageBonus takes Unit whichUnit, real amount returns nothing
                local integer packet
                local integer packetLevel
                local real previousAmount = GetUnitDamageBonus(whichUnit)
                local unit whichUnitSelf = whichUnit.self
                set whichUnit.damageBonus = amount
                if (amount * previousAmount <= 0) then
                    if (previousAmount < 0) then
                        set packetLevel = Bonus_DECREASING_ABILITIES_MAX
                        loop
                            call UnitRemoveAbility(whichUnitSelf, Bonus_DECREASING_ABILITIES[packetLevel])
                            set packetLevel = packetLevel - 1
                            exitwhen (packetLevel < 0)
                        endloop
                    else
                        set packetLevel = Bonus_INCREASING_ABILITIES_MAX
                        loop
                            call UnitRemoveAbility(whichUnitSelf, Bonus_INCREASING_ABILITIES[packetLevel])
                            set packetLevel = packetLevel - 1
                            exitwhen (packetLevel < 0)
                        endloop
                    endif
                    if (amount < 0) then
                        set packetLevel = R2I(Min(Log(Max(Absolute(previousAmount), Absolute(amount)), 2), Bonus_DECREASING_ABILITIES_MAX))
                        set packet = R2I(Pow(2, packetLevel))
                        set amount = -amount
                        loop
                            exitwhen (packetLevel < 0)
                            if (packet <= amount) then
                                call UnitAddAbility(whichUnitSelf, Bonus_DECREASING_ABILITIES[packetLevel])
                                set amount = amount - packet
                            endif
                            set packet = packet / 2
                            set packetLevel = packetLevel - 1
                        endloop
                    else
                        set packetLevel = R2I(Min(Log(Max(Absolute(previousAmount), Absolute(amount)), 2), Bonus_INCREASING_ABILITIES_MAX))
                        set packet = R2I(Pow(2, packetLevel))
                        loop
                            exitwhen (packetLevel < 0)
                            if (packet <= amount) then
                                call UnitAddAbility(whichUnitSelf, Bonus_INCREASING_ABILITIES[packetLevel])
                                set amount = amount - packet
                            endif
                            set packet = packet / 2
                            set packetLevel = packetLevel - 1
                        endloop
                    endif
                else
                    set packetLevel = R2I(Min(Log(Max(Absolute(previousAmount), Absolute(amount)), 2), Bonus_DECREASING_ABILITIES_MAX))
                    set packet = R2I(Pow(2, packetLevel))
                    if (amount < 0) then
                        set amount = -amount
                        loop
                            exitwhen (packetLevel < 0)
                            if (packet <= amount) then
                                call UnitAddAbility(whichUnitSelf, Bonus_DECREASING_ABILITIES[packetLevel])
                                set amount = amount - packet
                            else
                                call UnitRemoveAbility(whichUnitSelf, Bonus_DECREASING_ABILITIES[packetLevel])
                            endif
                            set packet = packet / 2
                            set packetLevel = packetLevel - 1
                        endloop
                    else
                    set packetLevel = R2I(Min(Log(Max(Absolute(previousAmount), Absolute(amount)), 2), Bonus_INCREASING_ABILITIES_MAX))
                    set packet = R2I(Pow(2, packetLevel))
                        loop
                            exitwhen (packetLevel < 0)
                            if (packet <= amount) then
                                call UnitAddAbility(whichUnitSelf, Bonus_INCREASING_ABILITIES[packetLevel])
                                set amount = amount - packet
                            else
                                call UnitRemoveAbility(whichUnitSelf, Bonus_INCREASING_ABILITIES[packetLevel])
                            endif
                            set packet = packet / 2
                            set packetLevel = packetLevel - 1
                        endloop
                    endif
                endif
            endfunction

            function AddUnitDamageBonus takes Unit whichUnit, real amount returns nothing
                call SetUnitDamageBonus( whichUnit, GetUnitDamageBonus( whichUnit ) + amount )
            endfunction

            public function Bonus_Init takes nothing returns nothing
                set Bonus_DECREASING_ABILITIES[0] = 'A00O'
                set Bonus_DECREASING_ABILITIES[1] = 'A04K'
                set Bonus_DECREASING_ABILITIES[2] = 'A04L'
                set Bonus_DECREASING_ABILITIES[3] = 'A04M'
                set Bonus_DECREASING_ABILITIES[4] = 'A04N'
                set Bonus_DECREASING_ABILITIES[5] = 'A04O'
                set Bonus_DECREASING_ABILITIES[6] = 'A04P'

                set Bonus_INCREASING_ABILITIES[0] = 'A00K'
                set Bonus_INCREASING_ABILITIES[1] = 'A04Q'
                set Bonus_INCREASING_ABILITIES[2] = 'A04R'
                set Bonus_INCREASING_ABILITIES[3] = 'A04S'
                set Bonus_INCREASING_ABILITIES[4] = 'A04T'
                set Bonus_INCREASING_ABILITIES[5] = 'A04U'
                set Bonus_INCREASING_ABILITIES[6] = 'A04V'
            endfunction
        //! runtextmacro Endscope()

        function GetUnitDamageTotal takes Unit whichUnit returns real
            return (GetUnitDamage(whichUnit) + GetUnitDamageBonus(whichUnit))
        endfunction

        //! runtextmacro CreateSimpleUnitTypeState("damage", "Damage", "real")

        //! runtextmacro CreateSimpleUnitTypeStateForPlayer("damage", "Damage", "real")

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        //! runtextmacro CreateSimpleUnitTypeState("damageDices", "DamageDices", "integer")

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        //! runtextmacro CreateSimpleUnitTypeState("damageDicesSides", "DamageDicesSides", "integer")

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        //! runtextmacro CreateSimpleUnitState("damageRelativeBonus", "DamageRelativeBonus", "real")

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        //! runtextmacro CreateSimpleUnitState("damageBySpellBonus", "DamageBySpellBonus", "real")

        function UnitDamageUnitBySpell takes Unit whichUnit, Unit whichTarget, real amount returns nothing
            call UnitDamageUnitEx( whichUnit, whichTarget, amount * ( 1 + GetUnitDamageBySpellBonus( whichUnit ) - GetUnitArmorBySpellBonus( whichTarget ) ), null )
        endfunction

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        //! runtextmacro CreateSimpleUnitTypeState("damageType", "DamageType", "integer")

        public function Damage_Init takes nothing returns nothing
            call Base_Base_Init()
            call Bonus_Bonus_Init()
        endfunction
    //! runtextmacro Endscope()

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Heal
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro CreateSimpleUnitState("healBySpell", "HealBySpell", "real")

    function HealUnitBySpell takes Unit whichUnit, real amount returns nothing
        set amount = amount * ( 1 + GetUnitHealBySpell( whichUnit ) )
        call AddUnitState( whichUnit.self, UNIT_STATE_LIFE, amount )
    endfunction

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Locust
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function AddUnitLocust takes unit whichUnit returns nothing
        call UnitAddAbility( whichUnit, LOCUST_SPELL_ID )
    endfunction

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Moveability
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function RemoveUnitMoveability takes unit whichUnit returns nothing
        call UnitRemoveAbility( whichUnit, MOVE_SPELL_ID )
    endfunction

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Max Life
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("MaxLife")
        globals
            private constant integer MaxLife_DECREASING_PACKET_LEVEL_MAX = 12
            private constant integer MaxLife_DECREASING_SPELL_ID = 'A01N'
            private constant integer MaxLife_INCREASING_PACKET_LEVEL_MAX = 12
            private constant integer MaxLife_INCREASING_SPELL_ID = 'A01M'
        endglobals

        function GetUnitMaxLife takes Unit whichUnit returns real
            return whichUnit.maxLife
        endfunction

        function SetUnitMaxLife takes Unit whichUnit, real amount returns nothing
            local integer packet
            local integer packetLevel
            local real previousAmount = GetUnitMaxLife(whichUnit)
            local unit whichUnitSelf = whichUnit.self
            set whichUnit.maxLife = amount
            set amount = R2I(amount) - R2I(previousAmount)
            if (amount < 0) then
                set amount = -amount
                set packet = 1024
                set packetLevel = MaxLife_DECREASING_PACKET_LEVEL_MAX
                loop
                    exitwhen (amount < 1)
                    loop
                        exitwhen (amount < packet)
                        call UnitAddAbility(whichUnitSelf, MaxLife_DECREASING_SPELL_ID)
                        call SetUnitAbilityLevel(whichUnitSelf, MaxLife_DECREASING_SPELL_ID, packetLevel)
                        call UnitRemoveAbility(whichUnitSelf, MaxLife_DECREASING_SPELL_ID)
                        set amount = amount - packet
                    endloop
                    set packet = packet / 2
                    set packetLevel = packetLevel - 1
                endloop
            else
                set packet = 1024
                set packetLevel = MaxLife_INCREASING_PACKET_LEVEL_MAX
                loop
                    exitwhen (amount < 1)
                    loop
                        exitwhen (amount < packet)
                        call UnitAddAbility(whichUnitSelf, MaxLife_INCREASING_SPELL_ID)
                        call SetUnitAbilityLevel(whichUnitSelf, MaxLife_INCREASING_SPELL_ID, packetLevel)
                        call UnitRemoveAbility(whichUnitSelf, MaxLife_INCREASING_SPELL_ID)
                        set amount = amount - packet
                    endloop
                    set packet = packet / 2
                    set packetLevel = packetLevel - 1
                endloop
            endif
            set whichUnitSelf = null
        endfunction

        function AddUnitMaxLife takes Unit whichUnit, real amount returns nothing
            call SetUnitMaxLife(whichUnit, GetUnitMaxLife(whichUnit) + amount)
        endfunction

        public function MaxLife_Init takes nothing returns nothing
            call InitAbility( MaxLife_DECREASING_SPELL_ID )
            call InitAbility( MaxLife_INCREASING_SPELL_ID )
        endfunction

        //! runtextmacro CreateSimpleUnitTypeState("maxLife", "MaxLife", "real")

        //! runtextmacro CreateSimpleUnitTypeStateForPlayer("maxLife", "MaxLife", "real")
    //! runtextmacro Endscope()

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Max Mana
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("MaxMana")
        globals
            private constant integer MaxMana_DECREASING_PACKET_LEVEL_MAX = 12
            private constant integer MaxMana_DECREASING_SPELL_ID = 'A02P'
            private constant integer MaxMana_INCREASING_PACKET_LEVEL_MAX = 12
            private constant integer MaxMana_INCREASING_SPELL_ID = 'A02O'
        endglobals

        function GetUnitMaxMana takes Unit whichUnit returns real
            return whichUnit.maxMana
        endfunction

        function SetUnitMaxMana takes Unit whichUnit, real amount returns nothing
            local integer packet
            local integer packetLevel
            local real previousAmount = GetUnitMaxMana(whichUnit)
            local unit whichUnitSelf = whichUnit.self
            set whichUnit.maxMana = amount
            set amount = R2I(amount) - R2I(previousAmount)
            if (amount < 0) then
                set amount = -amount
                set packet = 1024
                set packetLevel = MaxMana_DECREASING_PACKET_LEVEL_MAX
                loop
                    exitwhen (amount < 1)
                    loop
                        exitwhen (amount < packet)
                        call UnitAddAbility(whichUnitSelf, MaxMana_DECREASING_SPELL_ID)
                        call SetUnitAbilityLevel(whichUnitSelf, MaxMana_DECREASING_SPELL_ID, packetLevel)
                        call UnitRemoveAbility(whichUnitSelf, MaxMana_DECREASING_SPELL_ID)
                        set amount = amount - packet
                    endloop
                    set packet = packet / 2
                    set packetLevel = packetLevel - 1
                endloop
            else
                set packet = 1024
                set packetLevel = MaxMana_INCREASING_PACKET_LEVEL_MAX
                loop
                    exitwhen (amount < 1)
                    loop
                        exitwhen (amount < packet)
                        call UnitAddAbility(whichUnitSelf, MaxMana_INCREASING_SPELL_ID)
                        call SetUnitAbilityLevel(whichUnitSelf, MaxMana_INCREASING_SPELL_ID, packetLevel)
                        call UnitRemoveAbility(whichUnitSelf, MaxMana_INCREASING_SPELL_ID)
                        set amount = amount - packet
                    endloop
                    set packet = packet / 2
                    set packetLevel = packetLevel - 1
                endloop
            endif
            set whichUnitSelf = null
        endfunction

        function AddUnitMaxMana takes Unit whichUnit, real amount returns nothing
            call SetUnitMaxMana(whichUnit, GetUnitMaxMana(whichUnit) + amount)
        endfunction

        public function MaxMana_Init takes nothing returns nothing
            call InitAbility( MaxMana_DECREASING_SPELL_ID )
            call InitAbility( MaxMana_INCREASING_SPELL_ID )
        endfunction

        //! runtextmacro CreateSimpleUnitTypeState("maxMana", "MaxMana", "real")

        //! runtextmacro CreateSimpleUnitTypeStateForPlayer("maxMana", "MaxMana", "real")
    //! runtextmacro Endscope()

    //! runtextmacro Scope("Regeneration")
        globals
            constant real REGENERATION_INTERVAL = 1.
        endglobals

        //! runtextmacro Scope("LifeRegeneration")
            //! runtextmacro CreateSimpleUnitState("lifeRegeneration", "LifeRegeneration", "real")

            //! runtextmacro CreateSimpleUnitState("lifeRegenerationBonus", "LifeRegenerationBonus", "real")

            //! runtextmacro CreateSimpleUnitTypeState("lifeRegeneration", "LifeRegeneration", "real")

            //! runtextmacro CreateSimpleUnitTypeStateForPlayer("lifeRegeneration", "LifeRegeneration", "real")
        //! runtextmacro Endscope()

        //! runtextmacro Scope("ManaRegeneration")
            //! runtextmacro CreateSimpleUnitState("manaRegeneration", "ManaRegeneration", "real")

            //! runtextmacro CreateSimpleUnitState("manaRegenerationBonus", "ManaRegenerationBonus", "real")

            //! runtextmacro CreateSimpleUnitTypeState("manaRegeneration", "ManaRegeneration", "real")

            //! runtextmacro CreateSimpleUnitTypeStateForPlayer("manaRegeneration", "ManaRegeneration", "real")
        //! runtextmacro Endscope()
    //! runtextmacro Endscope()

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Hero Attributes
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    globals
        constant real DAMAGE_BONUS_PER_PRIMARY_ATTRIBUTE_POINT = 1.
    endglobals

    //! runtextmacro Scope("Agility")
        globals
            private constant real Agility_ARMOR_BONUS_PER_AGILITY_POINT = 0.2
        endglobals

        //! runtextmacro Scope("Base")
            function GetHeroAgility takes Unit whichUnit returns real
                return whichUnit.agility
            endfunction

            function SetHeroAgility takes Unit whichUnit, UnitType whichUnitType, real amount returns nothing
                local real previousAmount = GetHeroAgility(whichUnit)
                local integer primaryAttribute = whichUnitType.primaryAttribute
                set whichUnit.agility = amount
                call SetHeroAgi(whichUnit.self, R2I(amount), true)
                set amount = amount - previousAmount
                call AddUnitArmor( whichUnit, amount * Agility_ARMOR_BONUS_PER_AGILITY_POINT )
                if ( primaryAttribute == 2 ) then
                    call AddUnitDamage( whichUnit, amount * DAMAGE_BONUS_PER_PRIMARY_ATTRIBUTE_POINT )
                endif
            endfunction

            function AddHeroAgility takes Unit whichUnit, UnitType whichUnitType, real amount returns nothing
                call SetHeroAgility(whichUnit, whichUnitType, GetHeroAgility(whichUnit) + amount)
            endfunction
        //! runtextmacro Endscope()

        //! runtextmacro Scope("Bonus")
            globals
                private constant integer Bonus_DECREASING_ABILITIES_MAX = 6
                private integer array Bonus_DECREASING_ABILITIES
                private constant integer Bonus_INCREASING_ABILITIES_MAX = 6
                private integer array Bonus_INCREASING_ABILITIES
            endglobals

            function GetHeroAgilityBonus takes Unit whichUnit returns real
                return whichUnit.agilityBonus
            endfunction

            function SetHeroAgilityBonus takes Unit whichUnit, UnitType whichUnitType, real amount returns nothing
                local integer packet
                local integer packetLevel
                local real previousAmount = GetHeroAgilityBonus(whichUnit)
                local integer primaryAttribute = whichUnitType.primaryAttribute
                local real remainingAmount
                local unit whichUnitSelf = whichUnit.self
                set whichUnit.agilityBonus = amount
                if (amount * previousAmount <= 0) then
                    if (previousAmount < 0) then
                        set packetLevel = Bonus_DECREASING_ABILITIES_MAX
                        loop
                            call UnitRemoveAbility(whichUnitSelf, Bonus_DECREASING_ABILITIES[packetLevel])
                            set packetLevel = packetLevel - 1
                            exitwhen (packetLevel < 0)
                        endloop
                    else
                        set packetLevel = Bonus_INCREASING_ABILITIES_MAX
                        loop
                            call UnitRemoveAbility(whichUnitSelf, Bonus_INCREASING_ABILITIES[packetLevel])
                            set packetLevel = packetLevel - 1
                            exitwhen (packetLevel < 0)
                        endloop
                    endif
                    if (amount < 0) then
                        set packetLevel = R2I(Min(Log(Max(Absolute(previousAmount), Absolute(amount)), 2), Bonus_DECREASING_ABILITIES_MAX))
                        set packet = R2I(Pow(2, packetLevel))
                        set remainingAmount = -amount
                        loop
                            exitwhen (packetLevel < 0)
                            if (packet <= amount) then
                                call UnitAddAbility(whichUnitSelf, Bonus_DECREASING_ABILITIES[packetLevel])
                                set remainingAmount = remainingAmount - packet
                            endif
                            set packet = packet / 2
                            set packetLevel = packetLevel - 1
                        endloop
                    else
                        set packetLevel = R2I(Min(Log(Max(Absolute(previousAmount), Absolute(amount)), 2), Bonus_INCREASING_ABILITIES_MAX))
                        set packet = R2I(Pow(2, packetLevel))
                        set remainingAmount = amount
                        loop
                            exitwhen (packetLevel < 0)
                            if (packet <= remainingAmount) then
                                call UnitAddAbility(whichUnitSelf, Bonus_INCREASING_ABILITIES[packetLevel])
                                set remainingAmount = remainingAmount - packet
                            endif
                            set packet = packet / 2
                            set packetLevel = packetLevel - 1
                        endloop
                    endif
                else
                    if (amount < 0) then
                        set packetLevel = R2I(Min(Log(Max(Absolute(previousAmount), Absolute(amount)), 2), Bonus_DECREASING_ABILITIES_MAX))
                        set packet = R2I(Pow(2, packetLevel))
                        set remainingAmount = -amount
                        loop
                            exitwhen (packetLevel < 0)
                            if (packet <= remainingAmount) then
                                call UnitAddAbility(whichUnitSelf, Bonus_DECREASING_ABILITIES[packetLevel])
                                set remainingAmount = remainingAmount - packet
                            else
                                call UnitRemoveAbility(whichUnitSelf, Bonus_DECREASING_ABILITIES[packetLevel])
                            endif
                            set packet = packet / 2
                            set packetLevel = packetLevel - 1
                        endloop
                    else
                        set packetLevel = R2I(Min(Log(Max(Absolute(previousAmount), Absolute(amount)), 2), Bonus_INCREASING_ABILITIES_MAX))
                        set packet = R2I(Pow(2, packetLevel))
                        set remainingAmount = amount
                        loop
                            exitwhen (packetLevel < 0)
                            if (packet <= remainingAmount) then
                                call UnitAddAbility(whichUnitSelf, Bonus_INCREASING_ABILITIES[packetLevel])
                                set remainingAmount = remainingAmount - packet
                            else
                                call UnitRemoveAbility(whichUnitSelf, Bonus_INCREASING_ABILITIES[packetLevel])
                            endif
                            set packet = packet / 2
                            set packetLevel = packetLevel - 1
                        endloop
                    endif
                endif
                set amount = amount - previousAmount
                call AddUnitArmorBonus( whichUnit, amount * Agility_ARMOR_BONUS_PER_AGILITY_POINT )
                if ( primaryAttribute == 2 ) then
                    call AddUnitDamageBonus( whichUnit, amount * DAMAGE_BONUS_PER_PRIMARY_ATTRIBUTE_POINT )
                endif
                set whichUnitSelf = null
            endfunction

            function AddHeroAgilityBonus takes Unit whichUnit, UnitType whichUnitType, real amount returns nothing
                call SetHeroAgilityBonus( whichUnit, whichUnitType, GetHeroAgilityBonus( whichUnit ) + amount )
            endfunction

            public function Bonus_Init takes nothing returns nothing
                set Bonus_DECREASING_ABILITIES[0] = 'A019'
                set Bonus_DECREASING_ABILITIES[1] = 'A05E'
                set Bonus_DECREASING_ABILITIES[2] = 'A05F'
                set Bonus_DECREASING_ABILITIES[3] = 'A05G'
                set Bonus_DECREASING_ABILITIES[4] = 'A05H'
                set Bonus_DECREASING_ABILITIES[5] = 'A05I'
                set Bonus_DECREASING_ABILITIES[6] = 'A05J'

                set Bonus_INCREASING_ABILITIES[0] = 'A018'
                set Bonus_INCREASING_ABILITIES[1] = 'A058'
                set Bonus_INCREASING_ABILITIES[2] = 'A059'
                set Bonus_INCREASING_ABILITIES[3] = 'A05A'
                set Bonus_INCREASING_ABILITIES[4] = 'A05B'
                set Bonus_INCREASING_ABILITIES[5] = 'A05C'
                set Bonus_INCREASING_ABILITIES[6] = 'A05D'
            endfunction
        //! runtextmacro Endscope()

        function GetHeroAgilityTotal takes Unit whichUnit returns real
            return (GetHeroAgility(whichUnit) + GetHeroAgilityBonus(whichUnit))
        endfunction

        //! runtextmacro CreateSimpleUnitTypeState("agility", "Agility", "real")
        //! runtextmacro CreateSimpleUnitTypeState("agilityPerLevel", "AgilityPerLevel", "real")

        public function Agility_Init takes nothing returns nothing
            call Bonus_Bonus_Init()
        endfunction
    //! runtextmacro Endscope()

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("Intelligence")
        globals
            private constant real Intelligence_MAX_MANA_BONUS_PER_INTELLIGENCE_POINT = 15.
            private constant real Intelligence_MANA_REGENERATION_BONUS_PER_INTELLIGENCE_POINT = 0.025 * REGENERATION_INTERVAL
        endglobals

        //! runtextmacro Scope("Base")
            function GetHeroIntelligence takes Unit whichUnit returns real
                return whichUnit.intelligence
            endfunction

            function SetHeroIntelligence takes Unit whichUnit, UnitType whichUnitType, real amount returns nothing
                local real previousAmount = GetHeroIntelligence(whichUnit)
                local integer primaryAttribute = whichUnitType.primaryAttribute
                set whichUnit.intelligence = amount
                call SetHeroInt(whichUnit.self, R2I(amount), true)
                set amount = amount - previousAmount
                call AddUnitMaxMana( whichUnit, amount * Intelligence_MAX_MANA_BONUS_PER_INTELLIGENCE_POINT )
                call AddUnitManaRegeneration( whichUnit, amount * Intelligence_MANA_REGENERATION_BONUS_PER_INTELLIGENCE_POINT )
                if ( primaryAttribute == 3 ) then
                    call AddUnitDamage( whichUnit, amount * DAMAGE_BONUS_PER_PRIMARY_ATTRIBUTE_POINT )
                endif
            endfunction

            function AddHeroIntelligence takes Unit whichUnit, UnitType whichUnitType, real amount returns nothing
                call SetHeroIntelligence(whichUnit, whichUnitType, GetHeroIntelligence(whichUnit) + amount)
            endfunction
        //! runtextmacro Endscope()

        //! runtextmacro Scope("Bonus")
            globals
                private constant integer Bonus_DECREASING_ABILITIES_MAX = 6
                private integer array Bonus_DECREASING_ABILITIES
                private constant integer Bonus_INCREASING_ABILITIES_MAX = 6
                private integer array Bonus_INCREASING_ABILITIES
            endglobals

            function GetHeroIntelligenceBonus takes Unit whichUnit returns real
                return whichUnit.intelligenceBonus
            endfunction

            function SetHeroIntelligenceBonus takes Unit whichUnit, UnitType whichUnitType, real amount returns nothing
                local integer packet
                local integer packetLevel
                local real previousAmount = GetHeroIntelligenceBonus(whichUnit)
                local integer primaryAttribute = whichUnitType.primaryAttribute
                local real remainingAmount
                local unit whichUnitSelf = whichUnit.self
                set whichUnit.intelligenceBonus = amount
                if (amount * previousAmount <= 0) then
                    if (previousAmount < 0) then
                        set packetLevel = Bonus_DECREASING_ABILITIES_MAX
                        loop
                            call UnitRemoveAbility(whichUnitSelf, Bonus_DECREASING_ABILITIES[packetLevel])
                            set packetLevel = packetLevel - 1
                            exitwhen (packetLevel < 0)
                        endloop
                    else
                        set packetLevel = Bonus_INCREASING_ABILITIES_MAX
                        loop
                            call UnitRemoveAbility(whichUnitSelf, Bonus_INCREASING_ABILITIES[packetLevel])
                            set packetLevel = packetLevel - 1
                            exitwhen (packetLevel < 0)
                        endloop
                    endif
                    if (amount < 0) then
                        set packetLevel = R2I(Min(Log(Max(Absolute(previousAmount), Absolute(amount)), 2), Bonus_DECREASING_ABILITIES_MAX))
                        set packet = R2I(Pow(2, packetLevel))
                        set remainingAmount = -amount
                        loop
                            exitwhen (packetLevel < 0)
                            if (packet <= amount) then
                                call UnitAddAbility(whichUnitSelf, Bonus_DECREASING_ABILITIES[packetLevel])
                                set remainingAmount = remainingAmount - packet
                            endif
                            set packet = packet / 2
                            set packetLevel = packetLevel - 1
                        endloop
                    else
                        set packetLevel = R2I(Min(Log(Max(Absolute(previousAmount), Absolute(amount)), 2), Bonus_INCREASING_ABILITIES_MAX))
                        set packet = R2I(Pow(2, packetLevel))
                        set remainingAmount = amount
                        loop
                            exitwhen (packetLevel < 0)
                            if (packet <= remainingAmount) then
                                call UnitAddAbility(whichUnitSelf, Bonus_INCREASING_ABILITIES[packetLevel])
                                set remainingAmount = remainingAmount - packet
                            endif
                            set packet = packet / 2
                            set packetLevel = packetLevel - 1
                        endloop
                    endif
                else
                    if (amount < 0) then
                        set packetLevel = R2I(Min(Log(Max(Absolute(previousAmount), Absolute(amount)), 2), Bonus_DECREASING_ABILITIES_MAX))
                        set packet = R2I(Pow(2, packetLevel))
                        set remainingAmount = -amount
                        loop
                            exitwhen (packetLevel < 0)
                            if (packet <= remainingAmount) then
                                call UnitAddAbility(whichUnitSelf, Bonus_DECREASING_ABILITIES[packetLevel])
                                set remainingAmount = remainingAmount - packet
                            else
                                call UnitRemoveAbility(whichUnitSelf, Bonus_DECREASING_ABILITIES[packetLevel])
                            endif
                            set packet = packet / 2
                            set packetLevel = packetLevel - 1
                        endloop
                    else
                        set packetLevel = R2I(Min(Log(Max(Absolute(previousAmount), Absolute(amount)), 2), Bonus_INCREASING_ABILITIES_MAX))
                        set packet = R2I(Pow(2, packetLevel))
                        set remainingAmount = amount
                        loop
                            exitwhen (packetLevel < 0)
                            if (packet <= remainingAmount) then
                                call UnitAddAbility(whichUnitSelf, Bonus_INCREASING_ABILITIES[packetLevel])
                                set remainingAmount = remainingAmount - packet
                            else
                                call UnitRemoveAbility(whichUnitSelf, Bonus_INCREASING_ABILITIES[packetLevel])
                            endif
                            set packet = packet / 2
                            set packetLevel = packetLevel - 1
                        endloop
                    endif
                endif
                set amount = amount - previousAmount
                call AddUnitMaxMana( whichUnit, amount * Intelligence_MAX_MANA_BONUS_PER_INTELLIGENCE_POINT )
                call AddUnitManaRegenerationBonus( whichUnit, amount * Intelligence_MANA_REGENERATION_BONUS_PER_INTELLIGENCE_POINT )
                if ( primaryAttribute == 3 ) then
                    call AddUnitDamageBonus( whichUnit, amount * DAMAGE_BONUS_PER_PRIMARY_ATTRIBUTE_POINT )
                endif
                set whichUnitSelf = null
            endfunction

            function AddHeroIntelligenceBonus takes Unit whichUnit, UnitType whichUnitType, real amount returns nothing
                call SetHeroIntelligenceBonus( whichUnit, whichUnitType, GetHeroIntelligenceBonus( whichUnit ) + amount )
            endfunction

            public function Bonus_Init takes nothing returns nothing
                set Bonus_DECREASING_ABILITIES[0] = 'A01G'
                set Bonus_DECREASING_ABILITIES[1] = 'A05Q'
                set Bonus_DECREASING_ABILITIES[2] = 'A05R'
                set Bonus_DECREASING_ABILITIES[3] = 'A05S'
                set Bonus_DECREASING_ABILITIES[4] = 'A05T'
                set Bonus_DECREASING_ABILITIES[5] = 'A05U'
                set Bonus_DECREASING_ABILITIES[6] = 'A05V'

                set Bonus_INCREASING_ABILITIES[0] = 'A01E'
                set Bonus_INCREASING_ABILITIES[1] = 'A05K'
                set Bonus_INCREASING_ABILITIES[2] = 'A05L'
                set Bonus_INCREASING_ABILITIES[3] = 'A05M'
                set Bonus_INCREASING_ABILITIES[4] = 'A05N'
                set Bonus_INCREASING_ABILITIES[5] = 'A05O'
                set Bonus_INCREASING_ABILITIES[6] = 'A05P'
            endfunction
        //! runtextmacro Endscope()

        function GetHeroIntelligenceTotal takes Unit whichUnit returns real
            return (GetHeroIntelligence(whichUnit) + GetHeroIntelligenceBonus(whichUnit))
        endfunction

        //! runtextmacro CreateSimpleUnitTypeState("intelligence", "Intelligence", "real")
        //! runtextmacro CreateSimpleUnitTypeState("intelligencePerLevel", "IntelligencePerLevel", "real")

        public function Intelligence_Init takes nothing returns nothing
            call Bonus_Bonus_Init()
        endfunction
    //! runtextmacro Endscope()

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("Strength")
        globals
            private constant real Strength_MAX_LIFE_BONUS_PER_STRENGTH_POINT = 25.
            private constant real Strength_LIFE_REGENERATION_BONUS_PER_STRENGTH_POINT = 0.025 * REGENERATION_INTERVAL
        endglobals

        //! runtextmacro Scope("Base")
            function GetHeroStrength takes Unit whichUnit returns real
                return whichUnit.strength
            endfunction

            function SetHeroStrength takes Unit whichUnit, UnitType whichUnitType, real amount returns nothing
                local real previousAmount = GetHeroStrength(whichUnit)
                local integer primaryAttribute = whichUnitType.primaryAttribute
                set whichUnit.strength = amount
                call SetHeroStr(whichUnit.self, R2I(amount), true)
                set amount = amount - previousAmount
                call AddUnitMaxLife( whichUnit, amount * Strength_MAX_LIFE_BONUS_PER_STRENGTH_POINT )
                call AddUnitLifeRegeneration( whichUnit, amount * Strength_LIFE_REGENERATION_BONUS_PER_STRENGTH_POINT )
                if ( primaryAttribute == 1 ) then
                    call AddUnitDamage( whichUnit, amount * DAMAGE_BONUS_PER_PRIMARY_ATTRIBUTE_POINT )
                endif
            endfunction

            function AddHeroStrength takes Unit whichUnit, UnitType whichUnitType, real amount returns nothing
                call SetHeroStrength(whichUnit, whichUnitType, GetHeroStrength(whichUnit) + amount)
            endfunction
        //! runtextmacro Endscope()

        //! runtextmacro Scope("Bonus")
            globals
                private constant integer Bonus_DECREASING_ABILITIES_MAX = 6
                private integer array Bonus_DECREASING_ABILITIES
                private constant integer Bonus_INCREASING_ABILITIES_MAX = 6
                private integer array Bonus_INCREASING_ABILITIES
            endglobals

            function GetHeroStrengthBonus takes Unit whichUnit returns real
                return whichUnit.strengthBonus
            endfunction

            function SetHeroStrengthBonus takes Unit whichUnit, UnitType whichUnitType, real amount returns nothing
                local integer packet
                local integer packetLevel
                local real previousAmount = GetHeroStrengthBonus(whichUnit)
                local integer primaryAttribute = whichUnitType.primaryAttribute
                local real remainingAmount
                local unit whichUnitSelf = whichUnit.self
                set whichUnit.strengthBonus = amount
                if (amount * previousAmount <= 0) then
                    if (previousAmount < 0) then
                        set packetLevel = Bonus_DECREASING_ABILITIES_MAX
                        loop
                            call UnitRemoveAbility(whichUnitSelf, Bonus_DECREASING_ABILITIES[packetLevel])
                            set packetLevel = packetLevel - 1
                            exitwhen (packetLevel < 0)
                        endloop
                    else
                        set packetLevel = Bonus_INCREASING_ABILITIES_MAX
                        loop
                            call UnitRemoveAbility(whichUnitSelf, Bonus_INCREASING_ABILITIES[packetLevel])
                            set packetLevel = packetLevel - 1
                            exitwhen (packetLevel < 0)
                        endloop
                    endif
                    if (amount < 0) then
                        set packetLevel = R2I(Min(Log(Max(Absolute(previousAmount), Absolute(amount)), 2), Bonus_DECREASING_ABILITIES_MAX))
                        set packet = R2I(Pow(2, packetLevel))
                        set remainingAmount = -amount
                        loop
                            exitwhen (packetLevel < 0)
                            if (packet <= amount) then
                                call UnitAddAbility(whichUnitSelf, Bonus_DECREASING_ABILITIES[packetLevel])
                                set remainingAmount = remainingAmount - packet
                            endif
                            set packet = packet / 2
                            set packetLevel = packetLevel - 1
                        endloop
                    else
                        set packetLevel = R2I(Min(Log(Max(Absolute(previousAmount), Absolute(amount)), 2), Bonus_INCREASING_ABILITIES_MAX))
                        set packet = R2I(Pow(2, packetLevel))
                        set remainingAmount = amount
                        loop
                            exitwhen (packetLevel < 0)
                            if (packet <= remainingAmount) then
                                call UnitAddAbility(whichUnitSelf, Bonus_INCREASING_ABILITIES[packetLevel])
                                set remainingAmount = remainingAmount - packet
                            endif
                            set packet = packet / 2
                            set packetLevel = packetLevel - 1
                        endloop
                    endif
                else
                    if (amount < 0) then
                        set packetLevel = R2I(Min(Log(Max(Absolute(previousAmount), Absolute(amount)), 2), Bonus_DECREASING_ABILITIES_MAX))
                        set packet = R2I(Pow(2, packetLevel))
                        set remainingAmount = -amount
                        loop
                            exitwhen (packetLevel < 0)
                            if (packet <= remainingAmount) then
                                call UnitAddAbility(whichUnitSelf, Bonus_DECREASING_ABILITIES[packetLevel])
                                set remainingAmount = remainingAmount - packet
                            else
                                call UnitRemoveAbility(whichUnitSelf, Bonus_DECREASING_ABILITIES[packetLevel])
                            endif
                            set packet = packet / 2
                            set packetLevel = packetLevel - 1
                        endloop
                    else
                        set packetLevel = R2I(Min(Log(Max(Absolute(previousAmount), Absolute(amount)), 2), Bonus_INCREASING_ABILITIES_MAX))
                        set packet = R2I(Pow(2, packetLevel))
                        set remainingAmount = amount
                        loop
                            exitwhen (packetLevel < 0)
                            if (packet <= remainingAmount) then
                                call UnitAddAbility(whichUnitSelf, Bonus_INCREASING_ABILITIES[packetLevel])
                                set remainingAmount = remainingAmount - packet
                            else
                                call UnitRemoveAbility(whichUnitSelf, Bonus_INCREASING_ABILITIES[packetLevel])
                            endif
                            set packet = packet / 2
                            set packetLevel = packetLevel - 1
                        endloop
                    endif
                endif
                set amount = amount - previousAmount
                call AddUnitMaxLife( whichUnit, amount * Strength_MAX_LIFE_BONUS_PER_STRENGTH_POINT )
                call AddUnitLifeRegenerationBonus( whichUnit, amount * Strength_LIFE_REGENERATION_BONUS_PER_STRENGTH_POINT )
                if ( primaryAttribute == 1 ) then
                    call AddUnitDamageBonus( whichUnit, amount * DAMAGE_BONUS_PER_PRIMARY_ATTRIBUTE_POINT )
                endif
                set whichUnitSelf = null
            endfunction

            function AddHeroStrengthBonus takes Unit whichUnit, UnitType whichUnitType, real amount returns nothing
                call SetHeroStrengthBonus( whichUnit, whichUnitType, GetHeroStrengthBonus( whichUnit ) + amount )
            endfunction

            public function Bonus_Init takes nothing returns nothing
                set Bonus_DECREASING_ABILITIES[0] = 'A017'
                set Bonus_DECREASING_ABILITIES[1] = 'A062'
                set Bonus_DECREASING_ABILITIES[2] = 'A063'
                set Bonus_DECREASING_ABILITIES[3] = 'A064'
                set Bonus_DECREASING_ABILITIES[4] = 'A065'
                set Bonus_DECREASING_ABILITIES[5] = 'A066'
                set Bonus_DECREASING_ABILITIES[6] = 'A067'

                set Bonus_INCREASING_ABILITIES[0] = 'A016'
                set Bonus_INCREASING_ABILITIES[1] = 'A05W'
                set Bonus_INCREASING_ABILITIES[2] = 'A05X'
                set Bonus_INCREASING_ABILITIES[3] = 'A05Y'
                set Bonus_INCREASING_ABILITIES[4] = 'A05Z'
                set Bonus_INCREASING_ABILITIES[5] = 'A060'
                set Bonus_INCREASING_ABILITIES[6] = 'A061'
            endfunction
        //! runtextmacro Endscope()

        function GetHeroStrengthTotal takes Unit whichUnit returns real
            return (GetHeroStrength(whichUnit) + GetHeroStrengthBonus(whichUnit))
        endfunction

        //! runtextmacro CreateSimpleUnitTypeState("strength", "Strength", "real")
        //! runtextmacro CreateSimpleUnitTypeState("strengthPerLevel", "StrengthPerLevel", "real")

        public function Strength_Init takes nothing returns nothing
            call Bonus_Bonus_Init()
        endfunction
    //! runtextmacro Endscope()

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Evasion
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("Evasion")
        globals
            private constant integer Evasion_SPELL_ID = 'A00L'
        endglobals

        function GetUnitEvasionChance takes Unit whichUnit returns real
            return whichUnit.evasion
        endfunction

        function SetUnitEvasionChance takes Unit whichUnit, real chance returns nothing
            set whichUnit.evasion = chance
            call SetUnitAbilityLevel( whichUnit.self, Evasion_SPELL_ID, 1 + R2I( chance * 100 ) )
        endfunction

        function AddUnitEvasionChance takes Unit whichUnit, real chance returns nothing
            call SetUnitEvasionChance( whichUnit, GetUnitEvasionChance( whichUnit ) + chance )
        endfunction

        public function Evasion_Init takes nothing returns nothing
            call InitAbility(Evasion_SPELL_ID)
        endfunction
    //! runtextmacro Endscope()

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Miss
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("Miss")
        globals
            private constant integer Miss_BUFF_ID = 'B00Q'
            private constant integer Miss_ORDER_ID = 852190//OrderId("curse")
            private constant integer Miss_SPELL_ID = 'A04I'
        endglobals

        function GetUnitMissChance takes Unit whichUnit returns real
            return whichUnit.miss
        endfunction

        function SetUnitMissChance takes Unit whichUnit, real chance returns nothing
            local unit whichUnitSelf = whichUnit.self
            set whichUnit.miss = chance
            call UnitRemoveAbility( whichUnitSelf, Miss_BUFF_ID )
            if ( chance > 0 ) then
                call SetUnitAbilityLevel( WORLD_CASTER, Miss_SPELL_ID, R2I( chance * 100 ) )
                call IssueTargetOrderById( WORLD_CASTER, Miss_ORDER_ID, whichUnitSelf )
            endif
            set whichUnitSelf = null
        endfunction

        function AddUnitMissChance takes Unit whichUnit, real chance returns nothing
            call SetUnitMissChance( whichUnit, GetUnitMissChance( whichUnit ) + chance )
        endfunction

        public function Miss_Init takes nothing returns nothing
            call InitAbility( Miss_SPELL_ID )
        endfunction
    //! runtextmacro Endscope()

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Pathing
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("Pathing")
        function GetUnitPathing takes Unit whichUnit returns integer
            return whichUnit.pathing
        endfunction

        function RemoveUnitPathing takes Unit whichUnit returns nothing
            local integer amount = GetUnitPathing( whichUnit ) - 1
            set whichUnit.pathing = amount
            if ( amount == 0 ) then
                call SetUnitPathing( whichUnit.self, false )
            endif
        endfunction

        function AddUnitPathing takes Unit whichUnit returns nothing
            local integer amount = GetUnitPathing( whichUnit ) + 1
            set whichUnit.pathing = amount
            if ( amount == 1 ) then
                call SetUnitPathing( whichUnit.self, true )
            endif
        endfunction
    //! runtextmacro Endscope()

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Scaling
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("Scale")
        function GetUnitScale takes Unit whichUnit returns real
            return whichUnit.scale
        endfunction

        function SetUnitScaleWJ takes unit whichUnit, real scale returns nothing
            call SetUnitScale( whichUnit, scale, scale, scale )
        endfunction

        function SetUnitScaleEx takes Unit whichUnit, real scale returns nothing
            set whichUnit.scale = scale
            call SetUnitScaleWJ( whichUnit.self, scale )
        endfunction

        function AddUnitScale takes Unit whichUnit, real scale returns nothing
            call SetUnitScaleEx( whichUnit, GetUnitScale( whichUnit ) + scale )
        endfunction

        //! runtextmacro Scope("Timed")
            globals
                private constant real Timed_UPDATE_TIME = 0.035
            endglobals

            private struct Timed_Data
                real bonusScalePerInterval
                timer durationTimer
                timer updateTimer
                Unit whichUnit
            endstruct

            private function Timed_Ending takes Timed_Data d, timer durationTimer, Unit whichUnit returns nothing
                local timer updateTimer = d.updateTimer
                local integer whichUnitId = whichUnit.id
                call d.destroy()
                call FlushAttachedInteger( durationTimer, Timed_SCOPE_ID )
                call DestroyTimerWJ(durationTimer)
                call FlushAttachedInteger( updateTimer, Timed_SCOPE_ID )
                call DestroyTimerWJ( updateTimer )
                set updateTimer = null
                call RemoveIntegerFromTableById( whichUnitId, Timed_SCOPE_ID, d )
                if (CountIntegersInTableById(whichUnitId, Timed_SCOPE_ID) == TABLE_EMPTY) then
                    //! runtextmacro RemoveEventById( "whichUnitId", "Timed_EVENT_DECAY" )
                endif
            endfunction

            public function Timed_Decay takes Unit whichUnit returns nothing
                local Timed_Data d
                local integer whichUnitId = whichUnit.id
                local integer iteration = CountIntegersInTableById(whichUnitId, Timed_SCOPE_ID) - 1
                if (iteration > TABLE_EMPTY) then
                    loop
                        set d = GetIntegerFromTableById(whichUnitId, Timed_SCOPE_ID, iteration)
                        call Timed_Ending(d, d.durationTimer, whichUnit)
                        set iteration = iteration - 1
                        exitwhen (iteration < TABLE_STARTED)
                    endloop
                endif
            endfunction

            private function Timed_Decay_Event takes nothing returns nothing
                call Timed_Decay(TRIGGER_UNIT)
            endfunction

            private function Timed_EndingByTimer takes nothing returns nothing
                local timer durationTimer = GetExpiredTimer()
                local Timed_Data d = GetAttachedInteger(durationTimer, Timed_SCOPE_ID)
                call Timed_Ending( d, durationTimer, d.whichUnit )
                set durationTimer = null
            endfunction

            private function Timed_Update takes nothing returns nothing
                local timer updateTimer = GetExpiredTimer()
                local Timed_Data d = GetAttachedInteger(updateTimer, Timed_SCOPE_ID)
                local Unit whichUnit = d.whichUnit
                set updateTimer = null
                call AddUnitScale( whichUnit, d.bonusScalePerInterval )
            endfunction

            function AddUnitScaleTimed takes Unit whichUnit, real scale, real duration returns nothing
                local Timed_Data d = Timed_Data.create()
                local timer durationTimer = CreateTimerWJ()
                local timer updateTimer = CreateTimerWJ()
                local integer whichUnitId = whichUnit.id
                set d.bonusScalePerInterval = scale * Timed_UPDATE_TIME / duration
                set d.updateTimer = updateTimer
                set d.whichUnit = whichUnit
                call AttachInteger( durationTimer, Timed_SCOPE_ID, d )
                call AttachInteger( updateTimer, Timed_SCOPE_ID, d )
                call AddIntegerToTableById( whichUnitId, Timed_SCOPE_ID, d )
                if (CountIntegersInTableById(whichUnitId, Timed_SCOPE_ID) == TABLE_STARTED) then
                    //! runtextmacro AddEventById( "whichUnitId", "Timed_EVENT_DECAY" )
                endif
                call TimerStart( updateTimer, Timed_UPDATE_TIME, true, function Timed_Update )
                set updateTimer = null
                call TimerStart( durationTimer, duration, false, function Timed_EndingByTimer )
                set durationTimer = null
            endfunction

            public function Timed_Init takes nothing returns nothing
                //! runtextmacro CreateEvent( "Timed_EVENT_DECAY", "UnitFinishesDecaying_EVENT_KEY", "0", "function Timed_Decay_Event" )
            endfunction
        //! runtextmacro Endscope()

        //! runtextmacro CreateSimpleUnitTypeState("scale", "Scale", "real")

        public function Scale_Init takes nothing returns nothing
            call Timed_Timed_Init()
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro Scope("DummyScale")
        private struct DummyScale_Data
            real scale
        endstruct

        function DestroyDummyScale takes unit dummyUnit returns nothing
            local DummyScale_Data d = GetAttachedInteger(dummyUnit, DummyScale_SCOPE_ID)
            call d.destroy()
            call FlushAttachedInteger(dummyUnit, DummyScale_SCOPE_ID)
        endfunction

        private function DummyScale_GetScale takes DummyScale_Data d returns real
            return d.scale
        endfunction

        private function DummyScale_Set takes unit dummyUnit, DummyScale_Data d, real scale returns nothing
            set d.scale = scale
            call SetUnitScale( dummyUnit, scale, scale, scale )
        endfunction

        private function DummyScale_Add takes unit dummyUnit, DummyScale_Data d, real scale returns nothing
            call DummyScale_Set( dummyUnit, d, DummyScale_GetScale( d ) + scale )
        endfunction

        //! runtextmacro Scope("Timed")
            globals
                private constant real Timed_UPDATE_TIME = 0.035
            endglobals

            private struct Timed_Data
                real bonusScalePerInterval
                timer durationTimer
                timer updateTimer
                unit whichUnit
            endstruct

            private function Timed_GetUnitData takes unit whichUnit returns Timed_Data
                return GetAttachedInteger(whichUnit, Timed_SCOPE_ID)
            endfunction

            private function Timed_Ending takes Timed_Data d, timer durationTimer, unit whichUnit returns nothing
                local timer updateTimer = d.updateTimer
                call d.destroy()
                call DestroyTimerWJ( durationTimer )
                call DestroyTimerWJ( updateTimer )
                set updateTimer = null
                call RemoveIntegerFromTable( whichUnit, Timed_SCOPE_ID, d )
            endfunction

            private function Timed_EndingByTimer takes nothing returns nothing
                local timer durationTimer = GetExpiredTimer()
                local Timed_Data d = GetAttachedInteger(durationTimer, Timed_SCOPE_ID)
                call Timed_Ending( d, durationTimer, d.whichUnit )
                set durationTimer = null
            endfunction

            private function Timed_Update takes nothing returns nothing
                local timer updateTimer = GetExpiredTimer()
                local Timed_Data d = GetAttachedInteger(updateTimer, Timed_SCOPE_ID)
                local unit whichUnit = d.whichUnit
                call DummyScale_Add( whichUnit, Timed_GetUnitData(whichUnit), d.bonusScalePerInterval )
                set whichUnit = null
            endfunction

            function AddDummyScaleTimed takes unit whichUnit, real scale, real duration returns nothing
                local Timed_Data d
                local timer durationTimer
                local timer updateTimer
                if ( duration != 0 ) then
                    set d = Timed_Data.create()
                    set durationTimer = CreateTimerWJ()
                    set updateTimer = CreateTimerWJ()
                    set d.bonusScalePerInterval = scale / (R2I(duration / Timed_UPDATE_TIME))
                    set d.durationTimer = durationTimer
                    set d.updateTimer = updateTimer
                    set d.whichUnit = whichUnit
                    call AttachInteger( durationTimer, Timed_SCOPE_ID, d )
                    call AttachInteger( updateTimer, Timed_SCOPE_ID, d )
                    call AddIntegerToTable( whichUnit, Timed_SCOPE_ID, d )
                    call TimerStart( updateTimer, Timed_UPDATE_TIME, true, function Timed_Update )
                    set updateTimer = null
                    call TimerStart( durationTimer, duration, false, function Timed_EndingByTimer )
                    set durationTimer = null
                else
                    call DummyScale_Add(whichUnit, Timed_GetUnitData(whichUnit), scale)
                endif
            endfunction
        //! runtextmacro Endscope()

        function InitDummyScale takes unit dummyUnit, real scale returns nothing
            local DummyScale_Data d = DummyScale_Data.create()
            set d.scale = scale
            call AttachInteger(dummyUnit, DummyScale_SCOPE_ID, d)
            call SetUnitScale(dummyUnit, scale, scale, scale)
        endfunction
    //! runtextmacro Endscope()

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Silence
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("Silence")
        globals
            private constant integer Silence_DUMMY_BUFF_ID = 'B00G'
            private constant integer Silence_DUMMY_ORDER_ID = 852668//OrderId("soulburn")
            private constant integer Silence_DUMMY_SPELL_ID = 'B00G'
        endglobals

        function GetUnitSilence takes Unit whichUnit returns integer
            return whichUnit.silence
        endfunction

        function RemoveUnitSilence takes Unit whichUnit returns nothing
            local integer amount = GetUnitSilence( whichUnit ) - 1
            set whichUnit.silence = amount
            if ( amount == 0 ) then
                call UnitRemoveAbility( whichUnit.self, Silence_DUMMY_BUFF_ID )
            endif
        endfunction

        function AddUnitSilence takes Unit whichUnit returns nothing
            local integer amount = GetUnitSilence( whichUnit ) + 1
            set whichUnit.silence = amount
            if ( amount == 1 ) then
                call IssueTargetOrderById( WORLD_CASTER, Silence_DUMMY_ORDER_ID, whichUnit.self )
            endif
        endfunction

        public function Silence_Init takes nothing returns nothing
            call UnitAddAbility(WORLD_CASTER, Silence_DUMMY_SPELL_ID)
        endfunction
    //! runtextmacro Endscope()

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Attack Rate
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("AttackRate")
        globals
            private constant integer AttackRate_DECREASING_ABILITIES_MAX = 6
            private integer array AttackRate_DECREASING_ABILITIES
            private constant integer AttackRate_INCREASING_ABILITIES_MAX = 6
            private integer array AttackRate_INCREASING_ABILITIES
        endglobals

        function GetUnitAttackRate takes Unit whichUnit returns real
            return whichUnit.attackRate
        endfunction

        function SetUnitAttackRate takes Unit whichUnit, real amount returns nothing
            local integer packet
            local integer packetLevel
            local real previousAmount = GetUnitAttackRate(whichUnit)
            local unit whichUnitSelf = whichUnit.self
            set whichUnit.attackRate = amount
            set amount = amount * 100
            if (amount * previousAmount <= 0) then
                if (previousAmount < 0) then
                    set packetLevel = AttackRate_DECREASING_ABILITIES_MAX
                    loop
                        call UnitRemoveAbility(whichUnitSelf, AttackRate_DECREASING_ABILITIES[packetLevel])
                        set packetLevel = packetLevel - 1
                        exitwhen (packetLevel < 0)
                    endloop
                else
                    set packetLevel = AttackRate_INCREASING_ABILITIES_MAX
                    loop
                        call UnitRemoveAbility(whichUnitSelf, AttackRate_INCREASING_ABILITIES[packetLevel])
                        set packetLevel = packetLevel - 1
                        exitwhen (packetLevel < 0)
                    endloop
                endif
                if (amount < 0) then
                    set packetLevel = R2I(Min(Log(Max(Absolute(previousAmount), Absolute(amount)), 2), AttackRate_DECREASING_ABILITIES_MAX))
                    set packet = R2I(Pow(2, packetLevel))
                    set amount = -amount
                    loop
                        exitwhen (packetLevel < 0)
                        if (packet <= amount) then
                            call UnitAddAbility(whichUnitSelf, AttackRate_DECREASING_ABILITIES[packetLevel])
                            set amount = amount - packet
                        endif
                        set packet = packet / 2
                        set packetLevel = packetLevel - 1
                    endloop
                else
                    set packetLevel = R2I(Min(Log(Max(Absolute(previousAmount), Absolute(amount)), 2), AttackRate_INCREASING_ABILITIES_MAX))
                    set packet = R2I(Pow(2, packetLevel))
                    loop
                        exitwhen (packetLevel < 0)
                        if (packet <= amount) then
                            call UnitAddAbility(whichUnitSelf, AttackRate_INCREASING_ABILITIES[packetLevel])
                            set amount = amount - packet
                        endif
                        set packet = packet / 2
                        set packetLevel = packetLevel - 1
                    endloop
                endif
            else
                set packetLevel = R2I(Min(Log(Max(Absolute(previousAmount), Absolute(amount)), 2), AttackRate_DECREASING_ABILITIES_MAX))
                set packet = R2I(Pow(2, packetLevel))
                if (amount < 0) then
                    set amount = -amount
                    loop
                        exitwhen (packetLevel < 0)
                        if (packet <= amount) then
                            call UnitAddAbility(whichUnitSelf, AttackRate_DECREASING_ABILITIES[packetLevel])
                            set amount = amount - packet
                        else
                            call UnitRemoveAbility(whichUnitSelf, AttackRate_DECREASING_ABILITIES[packetLevel])
                        endif
                        set packet = packet / 2
                        set packetLevel = packetLevel - 1
                    endloop
                else
                    set packetLevel = R2I(Min(Log(Max(Absolute(previousAmount), Absolute(amount)), 2), AttackRate_INCREASING_ABILITIES_MAX))
                    set packet = R2I(Pow(2, packetLevel))
                    loop
                        exitwhen (packetLevel < 0)
                        if (packet <= amount) then
                            call UnitAddAbility(whichUnitSelf, AttackRate_INCREASING_ABILITIES[packetLevel])
                            set amount = amount - packet
                        else
                            call UnitRemoveAbility(whichUnitSelf, AttackRate_INCREASING_ABILITIES[packetLevel])
                        endif
                        set packet = packet / 2
                        set packetLevel = packetLevel - 1
                    endloop
                endif
            endif
            set whichUnitSelf = null
        endfunction

        function AddUnitAttackRate takes Unit whichUnit, real amount returns nothing
            call SetUnitAttackRate( whichUnit, GetUnitAttackRate( whichUnit ) + amount )
        endfunction

        //! runtextmacro CreateSimpleUnitTypeStateForPlayer("attackRate", "AttackRate", "real")

        public function AttackRate_Init takes nothing returns nothing
            set AttackRate_DECREASING_ABILITIES[0] = 'A02L'
            set AttackRate_DECREASING_ABILITIES[1] = 'A052'
            set AttackRate_DECREASING_ABILITIES[2] = 'A053'
            set AttackRate_DECREASING_ABILITIES[3] = 'A054'
            set AttackRate_DECREASING_ABILITIES[4] = 'A055'
            set AttackRate_DECREASING_ABILITIES[5] = 'A056'
            set AttackRate_DECREASING_ABILITIES[6] = 'A057'

            set AttackRate_INCREASING_ABILITIES[0] = 'A02K'
            set AttackRate_INCREASING_ABILITIES[1] = 'A04W'
            set AttackRate_INCREASING_ABILITIES[2] = 'A04X'
            set AttackRate_INCREASING_ABILITIES[3] = 'A04Y'
            set AttackRate_INCREASING_ABILITIES[4] = 'A04Z'
            set AttackRate_INCREASING_ABILITIES[5] = 'A050'
            set AttackRate_INCREASING_ABILITIES[6] = 'A051'
        endfunction
    //! runtextmacro Endscope()

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Sight Range
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("SightRange")
        globals
            private constant integer SightRange_DECREASING_PACKET_LEVEL_MAX = 12
            private constant integer SightRange_DECREASING_SPELL_ID = 'A03D'
            private constant integer SightRange_INCREASING_PACKET_LEVEL_MAX = 12
            private constant integer SightRange_INCREASING_SPELL_ID = 'A03C'
        endglobals

        function GetUnitSightRange takes Unit whichUnit returns real
            return whichUnit.sightRange
        endfunction

        function SetUnitSightRange takes Unit whichUnit, real amount returns nothing
            local integer packet
            local integer packetLevel
            local real previousAmount = GetUnitSightRange(whichUnit)
            local unit whichUnitSelf = whichUnit.self
            set whichUnit.sightRange = amount
            set amount = R2I(amount) - R2I(previousAmount)
            if (amount < 0) then
                set amount = -amount
                set packet = 1024
                set packetLevel = SightRange_DECREASING_PACKET_LEVEL_MAX
                loop
                    exitwhen (amount < 1)
                    loop
                        exitwhen (amount < packet)
                        call UnitAddAbility(whichUnitSelf, SightRange_DECREASING_SPELL_ID)
                        call SetUnitAbilityLevel(whichUnitSelf, SightRange_DECREASING_SPELL_ID, packetLevel)
                        call UnitRemoveAbility(whichUnitSelf, SightRange_DECREASING_SPELL_ID)
                        set amount = amount - packet
                    endloop
                    set packet = packet / 2
                    set packetLevel = packetLevel - 1
                endloop
            else
                set packet = 1024
                set packetLevel = SightRange_INCREASING_PACKET_LEVEL_MAX
                loop
                    exitwhen (amount < 1)
                    loop
                        exitwhen (amount < packet)
                        call UnitAddAbility(whichUnitSelf, SightRange_INCREASING_SPELL_ID)
                        call SetUnitAbilityLevel(whichUnitSelf, SightRange_INCREASING_SPELL_ID, packetLevel)
                        call UnitRemoveAbility(whichUnitSelf, SightRange_INCREASING_SPELL_ID)
                        set amount = amount - packet
                    endloop
                    set packet = packet / 2
                    set packetLevel = packetLevel - 1
                endloop
            endif
            set whichUnitSelf = null
        endfunction

        function AddUnitSightRange takes Unit whichUnit, real amount returns nothing
            call SetUnitSightRange(whichUnit, GetUnitSightRange(whichUnit) + amount)
        endfunction

        //! runtextmacro CreateSimpleUnitTypeState("sightRange", "SightRange", "real")

        public function SightRange_Init takes nothing returns nothing
            call InitAbility(SightRange_DECREASING_SPELL_ID)
            call InitAbility(SightRange_INCREASING_SPELL_ID)
        endfunction
    //! runtextmacro Endscope()

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Speed
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("Speed")
        globals
            public constant real Speed_LOWER_CAP = 125.
            public constant real Speed_UPPER_CAP = 522.
        endglobals

        function GetUnitSpeed takes Unit whichUnit returns real
            return whichUnit.speed
        endfunction

        function GetUnitSpeedBonus takes Unit whichUnit returns real
            return whichUnit.speedBonus
        endfunction

        //! runtextmacro Scope("Base")
            function SetUnitSpeed takes Unit whichUnit, real amount returns nothing
                local real bonusSpeed = GetUnitSpeedBonus( whichUnit )
                set whichUnit.speed = amount
                set amount = bonusSpeed + amount
                set amount = Max( Speed_LOWER_CAP, amount )
                set amount = Min( amount, Speed_UPPER_CAP )
                call SetUnitMoveSpeed( whichUnit.self, amount - Sign( bonusSpeed ) )
            endfunction

            function AddUnitSpeed takes Unit whichUnit, real amount returns nothing
                call SetUnitSpeed( whichUnit, GetUnitSpeed( whichUnit ) + amount )
            endfunction
        //! runtextmacro Endscope()

        //! runtextmacro Scope("Bonus")
            globals
                private constant integer Bonus_DUMMY_SPELL_ID = 'A010'
            endglobals

            function SetUnitSpeedBonus takes Unit whichUnit, real amount returns nothing
                local integer abilityLevel
                local unit whichUnitSelf = whichUnit.self
                set whichUnit.speedBonus = amount
                if ( amount > 0 ) then
                    set abilityLevel = 3
                else
                    set abilityLevel = 1 + B2I( amount < 0 )
                endif
                set amount = GetUnitSpeed( whichUnit ) + amount
                set amount = Max( Speed_LOWER_CAP, amount )
                set amount = Min( amount, Speed_UPPER_CAP )
                call SetUnitMoveSpeed( whichUnitSelf, amount - Sign( GetUnitSpeedBonus( whichUnit ) ) )
                call SetUnitAbilityLevel( whichUnitSelf, Bonus_DUMMY_SPELL_ID, abilityLevel )
                call UpdateUnitDisplay( whichUnitSelf )
                set whichUnitSelf = null
            endfunction

            function AddUnitSpeedBonus takes Unit whichUnit, real amount returns nothing
                call SetUnitSpeedBonus( whichUnit, GetUnitSpeedBonus( whichUnit ) + amount )
            endfunction

            public function Bonus_Init takes nothing returns nothing
                call InitAbility( Bonus_DUMMY_SPELL_ID )
            endfunction
        //! runtextmacro Endscope()

        function GetUnitSpeedTotal takes Unit whichUnit returns real
            return (GetUnitSpeed(whichUnit) + GetUnitSpeedBonus(whichUnit))
        endfunction

        //! runtextmacro CreateSimpleUnitTypeState("speed", "Speed", "real")

        //! runtextmacro CreateSimpleUnitTypeStateForPlayer("speed", "Speed", "real")

        public function Speed_Init takes nothing returns nothing
            call Bonus_Bonus_Init()
        endfunction
    //! runtextmacro Endscope()

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Stun
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("Stun")
        globals
            private string array Stun_TARGET_EFFECTS_PATH
            private string array Stun_TARGET_EFFECTS_ATTACHMENT_POINT
        endglobals

        //! runtextmacro CreateSimpleUnitState("stunDurationRelativeBonus", "StunDurationRelativeBonus", "real")

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        function GetUnitStun takes Unit whichUnit, integer number returns integer
            return whichUnit.stun[number]
        endfunction

        //! runtextmacro Scope("Ensnare")
            globals
                private constant integer Ensnare_AIR_BUFF_ID = 'B009'
                private constant integer Ensnare_GROUND_BUFF_ID = 'B00U'
                private constant integer Ensnare_DUMMY_ORDER_ID = 852106//OrderId( "ensnare" )
                private constant integer Ensnare_DUMMY_SPELL_ID = 'A07U'
            endglobals

            public function Ensnare_Remove takes Unit whichUnit returns nothing
                local integer amount = whichUnit.stunEnsnare - 1
                set whichUnit.stunEnsnare = amount
                if (amount == 0) then
                    call UnitRemoveAbility( whichUnit.self, Ensnare_AIR_BUFF_ID )
                    call UnitRemoveAbility( whichUnit.self, Ensnare_GROUND_BUFF_ID )
                endif
            endfunction

            //! runtextmacro Scope("Cancel")
                globals
                    public constant integer Cancel_ORDER_ID = 851973
                endglobals

                private struct Cancel_Data
                    timer delayTimer
                    Unit whichUnit
                endstruct

                private function Cancel_Ending takes Cancel_Data d, timer delayTimer, Unit whichUnit returns nothing
                    local integer whichUnitId = whichUnit.id
                    call d.destroy()
                    call FlushAttachedInteger(delayTimer, Cancel_SCOPE_ID)
                    call DestroyTimerWJ(delayTimer)
                    call FlushAttachedIntegerById(whichUnitId, Cancel_SCOPE_ID)
                    //! runtextmacro RemoveEventById( "whichUnitId", "Cancel_EVENT_DEATH" )
                    call UnitRemoveAbility( whichUnit.self, Ensnare_AIR_BUFF_ID )
                    call UnitRemoveAbility( whichUnit.self, Ensnare_GROUND_BUFF_ID )
                endfunction

                public function Cancel_Death takes Unit whichUnit returns nothing
                    local Cancel_Data d = GetAttachedIntegerById(whichUnit.id, Cancel_SCOPE_ID)
                    if (d != NULL) then
                        call Cancel_Ending(d, d.delayTimer, whichUnit)
                    endif
                endfunction

                private function Cancel_Death_Event takes nothing returns nothing
                    call Cancel_Death(DYING_UNIT)
                endfunction

                private function Cancel_EndingByTimer takes nothing returns nothing
                    local timer delayTimer = GetExpiredTimer()
                    local Cancel_Data d = GetAttachedInteger(delayTimer, Cancel_SCOPE_ID)
                    call Cancel_Ending(d, delayTimer, d.whichUnit)
                    set delayTimer = null
                endfunction

                public function Cancel_OrderExecute takes Unit whichUnit returns nothing
                    local Cancel_Data d
                    local timer delayTimer
                    local integer whichUnitId
                    if (whichUnit.stunThunderbolt == 0) then
                        set whichUnitId = whichUnit.id
                        if (GetAttachedIntegerById(whichUnitId, Cancel_SCOPE_ID) == NULL) then
                            set d = Cancel_Data.create()
                            set delayTimer = CreateTimerWJ()
                            set d.delayTimer = delayTimer
                            set d.whichUnit = whichUnit
                            call AttachInteger(delayTimer, Cancel_SCOPE_ID, d)
                            call AttachIntegerById(whichUnitId, Cancel_SCOPE_ID, d)
                            //! runtextmacro AddEventById( "whichUnitId", "Cancel_EVENT_DEATH" )
                            call TimerStart(delayTimer, 0, false, function Cancel_EndingByTimer)
                            set delayTimer = null
                        endif
                    endif
                endfunction

                private function Cancel_OrderExecute_Event takes nothing returns nothing
                    call Cancel_OrderExecute(ORDERED_UNIT)
                endfunction

                public function Cancel_Init takes nothing returns nothing
                    //! runtextmacro CreateEvent( "Cancel_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Cancel_Death_Event" )
                    //! runtextmacro AddNewEventById( "Cancel_EVENT_ORDER_EXECUTE", "Cancel_ORDER_ID", "UnitGetsOrder_Executed_Executed_EVENT_KEY", "0", "function Cancel_OrderExecute_Event" )
                endfunction
            //! runtextmacro Endscope()

            public function Ensnare_Add takes Unit whichUnit returns nothing
                local integer amount = whichUnit.stunEnsnare + 1
                local unit whichUnitSelf
                set whichUnit.stunEnsnare = amount
                if (amount == 1) then
                    set whichUnitSelf = whichUnit.self
                    call SetUnitX( WORLD_CASTER, GetUnitX( whichUnitSelf ) )
                    call SetUnitY( WORLD_CASTER, GetUnitY( whichUnitSelf ) )
                    call IssueTargetOrderById( WORLD_CASTER, Ensnare_DUMMY_ORDER_ID, whichUnitSelf )
                    set whichUnitSelf = null
                endif
            endfunction

            public function Ensnare_Init takes nothing returns nothing
                //call InitAbility(Ensnare_DUMMY_SPELL_ID)
                call Cancel_Cancel_Init()
            endfunction
        //! runtextmacro Endscope()

        //! runtextmacro Scope("EntanglingRoots")
            globals
                private constant integer EntanglingRoots_DUMMY_BUFF_ID = 'B00S'
                private constant integer EntanglingRoots_DUMMY_ORDER_ID = 852171//OrderId( "entanglingroots" )
                private constant integer EntanglingRoots_DUMMY_SPELL_ID = 'A072'
            endglobals

            public function EntanglingRoots_Remove takes Unit whichUnit returns nothing
                local integer amount = whichUnit.stunEntanglingRoots - 1
                set whichUnit.stunEntanglingRoots = amount
                if (amount == 0) then
                    call UnitRemoveAbility( whichUnit.self, EntanglingRoots_DUMMY_BUFF_ID )
                endif
            endfunction

            public function EntanglingRoots_Add takes Unit whichUnit returns nothing
                local integer amount = whichUnit.stunEntanglingRoots + 1
                local unit whichUnitSelf
                set whichUnit.stunEntanglingRoots = amount
                if (amount == 1) then
                    set whichUnitSelf = whichUnit.self
                    call SetUnitX( WORLD_CASTER, GetUnitX( whichUnitSelf ) )
                    call SetUnitY( WORLD_CASTER, GetUnitY( whichUnitSelf ) )
                    call IssueTargetOrderById( WORLD_CASTER, EntanglingRoots_DUMMY_ORDER_ID, whichUnitSelf )
                    set whichUnitSelf = null
                endif
            endfunction

            public function EntanglingRoots_Init takes nothing returns nothing
                //call InitAbility(EntanglingRoots_DUMMY_SPELL_ID)
            endfunction
        //! runtextmacro Endscope()

        //! runtextmacro Scope("Thunderbolt")
            globals
                private constant integer Thunderbolt_DUMMY_BUFF_ID = 'B00T'
                private constant integer Thunderbolt_DUMMY_ORDER_ID = 852095//OrderId( "thunderbolt" )
                private constant integer Thunderbolt_DUMMY_SPELL_ID = 'A073'
            endglobals

            public function Thunderbolt_Remove takes Unit whichUnit returns nothing
                local integer amount = whichUnit.stunThunderbolt - 1
                set whichUnit.stunThunderbolt = amount
                if (amount == 0) then
                    call UnitRemoveAbility( whichUnit.self, Thunderbolt_DUMMY_BUFF_ID )
                endif
            endfunction

            //! runtextmacro Scope("Cancel")
                globals
                    public constant integer Cancel_ORDER_ID = 851973
                endglobals

                private struct Cancel_Data
                    timer delayTimer
                    Unit whichUnit
                endstruct

                private function Cancel_Ending takes Cancel_Data d, timer delayTimer, Unit whichUnit returns nothing
                    local integer whichUnitId = whichUnit.id
                    call d.destroy()
                    call FlushAttachedInteger(delayTimer, Cancel_SCOPE_ID)
                    call DestroyTimerWJ(delayTimer)
                    call FlushAttachedIntegerById(whichUnitId, Cancel_SCOPE_ID)
                    //! runtextmacro RemoveEventById( "whichUnitId", "Cancel_EVENT_DEATH" )
                    call UnitRemoveAbility( whichUnit.self, Thunderbolt_DUMMY_BUFF_ID )
                endfunction

                public function Cancel_Death takes Unit whichUnit returns nothing
                    local Cancel_Data d = GetAttachedIntegerById(whichUnit.id, Cancel_SCOPE_ID)
                    if (d != NULL) then
                        call Cancel_Ending(d, d.delayTimer, whichUnit)
                    endif
                endfunction

                private function Cancel_Death_Event takes nothing returns nothing
                    call Cancel_Death(DYING_UNIT)
                endfunction

                private function Cancel_EndingByTimer takes nothing returns nothing
                    local timer delayTimer = GetExpiredTimer()
                    local Cancel_Data d = GetAttachedInteger(delayTimer, Cancel_SCOPE_ID)
                    call Cancel_Ending(d, delayTimer, d.whichUnit)
                    set delayTimer = null
                endfunction

                public function Cancel_OrderExecute takes Unit whichUnit returns nothing
                    local Cancel_Data d
                    local timer delayTimer
                    local integer whichUnitId
                    if (whichUnit.stunThunderbolt == 0) then
                        set whichUnitId = whichUnit.id
                        if (GetAttachedIntegerById(whichUnitId, Cancel_SCOPE_ID) == NULL) then
                            set d = Cancel_Data.create()
                            set delayTimer = CreateTimerWJ()
                            set d.delayTimer = delayTimer
                            set d.whichUnit = whichUnit
                            call AttachInteger(delayTimer, Cancel_SCOPE_ID, d)
                            call AttachIntegerById(whichUnitId, Cancel_SCOPE_ID, d)
                            //! runtextmacro AddEventById( "whichUnitId", "Cancel_EVENT_DEATH" )
                            call TimerStart(delayTimer, 0, false, function Cancel_EndingByTimer)
                            set delayTimer = null
                        endif
                    endif
                endfunction

                private function Cancel_OrderExecute_Event takes nothing returns nothing
                    call Cancel_OrderExecute(ORDERED_UNIT)
                endfunction

                public function Cancel_Init takes nothing returns nothing
                    //! runtextmacro CreateEvent( "Cancel_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Cancel_Death_Event" )
                    //! runtextmacro AddNewEventById( "Cancel_EVENT_ORDER_EXECUTE", "Cancel_ORDER_ID", "UnitGetsOrder_Executed_Executed_EVENT_KEY", "0", "function Cancel_OrderExecute_Event" )
                endfunction
            //! runtextmacro Endscope()

            public function Thunderbolt_Add takes Unit whichUnit returns nothing
                local integer amount = whichUnit.stunThunderbolt + 1
                local unit whichUnitSelf
                set whichUnit.stunThunderbolt = amount
                if (amount == 1) then
                    set whichUnitSelf = whichUnit.self
                    call SetUnitX( WORLD_CASTER, GetUnitX( whichUnitSelf ) )
                    call SetUnitY( WORLD_CASTER, GetUnitY( whichUnitSelf ) )
                    call IssueTargetOrderById( WORLD_CASTER, Thunderbolt_DUMMY_ORDER_ID, whichUnitSelf )
                    set whichUnitSelf = null
                endif
            endfunction

            public function Thunderbolt_Init takes nothing returns nothing
                //call InitAbility(Thunderbolt_DUMMY_SPELL_ID)
                call Cancel_Cancel_Init()
            endfunction
        //! runtextmacro Endscope()

        //! runtextmacro Scope("Type0")
            public function Type0_Ending takes Unit whichUnit returns nothing
                //! runtextmacro RemoveEventById( "whichUnit.id", "Type0_EVENT_DEATH" )
                call EntanglingRoots_EntanglingRoots_Remove(whichUnit)
            endfunction

            public function Type0_Death takes Unit whichUnit returns nothing
                if (GetUnitStun(whichUnit, 0) > 0) then
                    call Type0_Ending(whichUnit)
                endif
            endfunction

            private function Type0_Death_Event takes nothing returns nothing
                call Type0_Death(DYING_UNIT)
            endfunction

            public function Type0_Start takes Unit whichUnit returns nothing
                //! runtextmacro AddEventById( "whichUnit.id", "Type0_EVENT_DEATH" )
                call EntanglingRoots_EntanglingRoots_Add(whichUnit)
            endfunction

            public function Type0_Init takes nothing returns nothing
                //! runtextmacro CreateEvent( "Type0_EVENT_DEATH", "UnitDies_EVENT_KEY", "1", "function Type0_Death_Event" )
            endfunction
        //! runtextmacro Endscope()

        //! runtextmacro Scope("Type1")
            public function Type1_Ending takes Unit whichUnit returns nothing
                //! runtextmacro RemoveEventById( "whichUnit.id", "Type1_EVENT_DEATH" )
                call Thunderbolt_Thunderbolt_Remove(whichUnit)
            endfunction

            public function Type1_Death takes Unit whichUnit returns nothing
                if (GetUnitStun(whichUnit, 1) > 0) then
                    call Type1_Ending(whichUnit)
                endif
            endfunction

            private function Type1_Death_Event takes nothing returns nothing
                call Type1_Death(DYING_UNIT)
            endfunction

            public function Type1_Start takes Unit whichUnit returns nothing
                //! runtextmacro AddEventById( "whichUnit.id", "Type1_EVENT_DEATH" )
                call Thunderbolt_Thunderbolt_Add(whichUnit)
            endfunction

            public function Type1_Init takes nothing returns nothing
                //! runtextmacro CreateEvent( "Type1_EVENT_DEATH", "UnitDies_EVENT_KEY", "1", "function Type1_Death_Event" )
            endfunction
        //! runtextmacro Endscope()

        //! runtextmacro Scope("Type2")
            public function Type2_Ending takes Unit whichUnit returns nothing
                //! runtextmacro RemoveEventById( "whichUnit.id", "Type2_EVENT_DEATH" )
                call Thunderbolt_Thunderbolt_Remove(whichUnit)
            endfunction

            public function Type2_Death takes Unit whichUnit returns nothing
                if (GetUnitStun(whichUnit, 2) > 0) then
                    call Type2_Ending(whichUnit)
                endif
            endfunction

            private function Type2_Death_Event takes nothing returns nothing
                call Type2_Death(DYING_UNIT)
            endfunction

            public function Type2_Start takes Unit whichUnit returns nothing
                //! runtextmacro AddEventById( "whichUnit.id", "Type2_EVENT_DEATH" )
                call Thunderbolt_Thunderbolt_Add(whichUnit)
            endfunction

            public function Type2_Init takes nothing returns nothing
                //! runtextmacro CreateEvent( "Type2_EVENT_DEATH", "UnitDies_EVENT_KEY", "1", "function Type2_Death_Event" )
            endfunction
        //! runtextmacro Endscope()

        //! runtextmacro Scope("Type3")
            public function Type3_Ending takes Unit whichUnit returns nothing
                //! runtextmacro RemoveEventById( "whichUnit.id", "Type3_EVENT_DEATH" )
                call Ensnare_Ensnare_Remove(whichUnit)
            endfunction

            public function Type3_Death takes Unit whichUnit returns nothing
                if (GetUnitStun(whichUnit, 3) > 0) then
                    call Type3_Ending(whichUnit)
                endif
            endfunction

            private function Type3_Death_Event takes nothing returns nothing
                call Type3_Death(DYING_UNIT)
            endfunction

            public function Type3_Start takes Unit whichUnit returns nothing
                //! runtextmacro AddEventById( "whichUnit.id", "Type3_EVENT_DEATH" )
                call Ensnare_Ensnare_Add(whichUnit)
            endfunction

            public function Type3_Init takes nothing returns nothing
                //! runtextmacro CreateEvent( "Type3_EVENT_DEATH", "UnitDies_EVENT_KEY", "1", "function Type3_Death_Event" )
            endfunction
        //! runtextmacro Endscope()

        //! runtextmacro Scope("Type4")
            public function Type4_Ending takes Unit whichUnit returns nothing
                //! runtextmacro RemoveEventById( "whichUnit.id", "Type4_EVENT_DEATH" )
                call EntanglingRoots_EntanglingRoots_Remove(whichUnit)
            endfunction

            public function Type4_Death takes Unit whichUnit returns nothing
                if (GetUnitStun(whichUnit, 4) > 0) then
                    call Type4_Ending(whichUnit)
                endif
            endfunction

            private function Type4_Death_Event takes nothing returns nothing
                call Type4_Death(DYING_UNIT)
            endfunction

            public function Type4_Start takes Unit whichUnit returns nothing
                //! runtextmacro AddEventById( "whichUnit.id", "Type4_EVENT_DEATH" )
                call EntanglingRoots_EntanglingRoots_Add(whichUnit)
            endfunction

            public function Type4_Init takes nothing returns nothing
                //! runtextmacro CreateEvent( "Type4_EVENT_DEATH", "UnitDies_EVENT_KEY", "1", "function Type4_Death_Event" )
            endfunction
        //! runtextmacro Endscope()

        //! runtextmacro Scope("Type5")
            public function Type5_Ending takes Unit whichUnit returns nothing
                //! runtextmacro RemoveEventById( "whichUnit.id", "Type5_EVENT_DEATH" )
                call Thunderbolt_Thunderbolt_Remove(whichUnit)
            endfunction

            public function Type5_Death takes Unit whichUnit returns nothing
                if (GetUnitStun(whichUnit, 5) > 0) then
                    call Type5_Ending(whichUnit)
                endif
            endfunction

            private function Type5_Death_Event takes nothing returns nothing
                call Type5_Death(DYING_UNIT)
            endfunction

            public function Type5_Start takes Unit whichUnit returns nothing
                //! runtextmacro AddEventById( "whichUnit.id", "Type5_EVENT_DEATH" )
                call Thunderbolt_Thunderbolt_Add(whichUnit)
            endfunction

            public function Type5_Init takes nothing returns nothing
                //! runtextmacro CreateEvent( "Type5_EVENT_DEATH", "UnitDies_EVENT_KEY", "1", "function Type5_Death_Event" )
            endfunction
        //! runtextmacro Endscope()

        function RemoveUnitStun takes Unit whichUnit, integer number returns nothing
            local integer amount = whichUnit.stun[number] - 1
            set whichUnit.stun[number] = amount
            if (amount == 0) then
                call DestroyEffectWJ(whichUnit.stunEffect[number])
                if ( number == 0 ) then
                    call Type0_Type0_Ending(whichUnit)
                elseif ( number == 1 ) then
                    call Type1_Type1_Ending(whichUnit)
                elseif ( number == 2 ) then
                    call Type2_Type2_Ending(whichUnit)
                elseif ( number == 3 ) then
                    call Type3_Type3_Ending(whichUnit)
                elseif ( number == 4 ) then
                    call Type4_Type4_Ending(whichUnit)
                elseif ( number == 5 ) then
                    call Type5_Type5_Ending(whichUnit)
                endif
            endif
        endfunction

        function AddUnitStun takes Unit whichUnit, integer number returns nothing
            local integer amount = whichUnit.stun[number] + 1
            set whichUnit.stun[number] = amount
            if (amount == 1) then
                set whichUnit.stunEffect[number] = AddSpecialEffectTargetWJ( Stun_TARGET_EFFECTS_PATH[number], whichUnit.self, Stun_TARGET_EFFECTS_ATTACHMENT_POINT[number] )
                if ( number == 0 ) then
                    call Type0_Type0_Start(whichUnit)
                elseif ( number == 1 ) then
                    call Type1_Type1_Start(whichUnit)
                elseif ( number == 2 ) then
                    call Type2_Type2_Start(whichUnit)
                elseif ( number == 3 ) then
                    call Type3_Type3_Start(whichUnit)
                elseif ( number == 4 ) then
                    call Type4_Type4_Start(whichUnit)
                elseif ( number == 5 ) then
                    call Type5_Type5_Start(whichUnit)
                endif
            endif
        endfunction

        //! runtextmacro Scope("Timed")
            globals
                private integer array Timed_SCOPES_ID
            endglobals

            private struct Timed_Data
                Unit target
            endstruct

            //! runtextmacro Scope("Number")
                public struct Number_Data
                    timer durationTimer
                    integer number
                    Unit target
                endstruct

                public function Number_Ending takes Number_Data d, timer durationTimer, Unit target returns nothing
                    local integer number = d.number
                    call d.destroy()
                    call FlushAttachedInteger( durationTimer, Number_SCOPE_ID )
                    call DestroyTimerWJ( durationTimer )
                    call FlushAttachedIntegerById( target.id, Number_SCOPE_ID )
                    call RemoveUnitStun(target, number)
                endfunction

                public function Number_EndingByDeath takes Unit target returns nothing
                    local Number_Data d = GetAttachedIntegerById(target.id, Number_SCOPE_ID)
                    if (d != NULL) then
                        call Number_Ending(d, d.durationTimer, target)
                    endif
                endfunction

                private function Number_EndingByTimer takes nothing returns nothing
                    local timer durationTimer = GetExpiredTimer()
                    local Number_Data d = GetAttachedInteger(durationTimer, Number_SCOPE_ID)
                    call Number_Ending(d, durationTimer, d.target)
                    set durationTimer = null
                endfunction

                public function Number_Start takes Unit target, integer number, real duration returns nothing
                    local timer durationTimer
                    local integer targetId = target.id
                    local Number_Data d = GetAttachedIntegerById(targetId, Number_SCOPE_ID)
                    if (d == NULL) then
                        set durationTimer = CreateTimerWJ()
                        set d = Number_Data.create()
                        set d.durationTimer = durationTimer
                        set d.number = number
                        set d.target = target
                        call AttachInteger(durationTimer, Number_SCOPE_ID, d)
                        call AttachIntegerById(targetId, Number_SCOPE_ID, d)
                        call AddUnitStun( target, number )
                        call TimerStart( durationTimer, duration, false, function Number_EndingByTimer )
                    else
                        set durationTimer = d.durationTimer
                        if ( duration > TimerGetRemaining( durationTimer ) ) then
                            call TimerStart( durationTimer, duration, false, function Number_EndingByTimer )
                        endif
                    endif
                    set durationTimer = null
                endfunction
            //! runtextmacro Endscope()

            public function Timed_Death takes Unit target returns nothing
                local integer targetId = target.id
                local Timed_Data d = GetAttachedIntegerById(targetId, Timed_SCOPE_ID)
                if (d != NULL) then
                    call d.destroy()
                    call FlushAttachedIntegerById( targetId, Timed_SCOPE_ID )
                    //! runtextmacro RemoveEventById( "targetId", "Timed_EVENT_DEATH" )
                    call Number_Number_EndingByDeath(target)
                endif
            endfunction

            private function Timed_Death_Event takes nothing returns nothing
                call Timed_Death(DYING_UNIT)
            endfunction

            function SetUnitStunTimed takes Unit target, integer number, real duration returns nothing
                local Timed_Data d
                local integer targetId
                set duration = duration * ( 1 + GetUnitStunDurationRelativeBonus( target ) )
                if (duration > 0) then
                    set targetId = target.id
                    set d = GetAttachedIntegerById(targetId, Timed_SCOPE_ID)
                    if ( d == NULL ) then
                        set d = Timed_Data.create()
                        set d.target = target
                        call AttachIntegerById( targetId, Timed_SCOPE_ID, d )
                        //! runtextmacro AddEventById( "targetId", "Timed_EVENT_DEATH" )
                    endif
                    call Number_Number_Start(target, number, duration)
                endif
            endfunction

            public function Timed_Init takes nothing returns nothing
                //! runtextmacro CreateEvent( "Timed_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Timed_Death_Event" )
            endfunction
        //! runtextmacro Endscope()

        public function Stun_Init takes nothing returns nothing
            local integer iteration = Stun_AMOUNT - 1
            set Stun_TARGET_EFFECTS_PATH[0] = ""
            set Stun_TARGET_EFFECTS_ATTACHMENT_POINT[0] = ""
            set Stun_TARGET_EFFECTS_PATH[1] = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
            set Stun_TARGET_EFFECTS_ATTACHMENT_POINT[1] = "overhead"
            set Stun_TARGET_EFFECTS_PATH[2] = "Abilities\\Spells\\Undead\\FreezingBreath\\FreezingBreathTargetArt.mdl"
            set Stun_TARGET_EFFECTS_ATTACHMENT_POINT[2] = "origin"
            set Stun_TARGET_EFFECTS_PATH[3] = ""
            set Stun_TARGET_EFFECTS_ATTACHMENT_POINT[3] = ""
            set Stun_TARGET_EFFECTS_PATH[4] = "Abilities\\Spells\\Human\\slow\\slowtarget.mdl"
            set Stun_TARGET_EFFECTS_ATTACHMENT_POINT[4] = "origin"
            set Stun_TARGET_EFFECTS_PATH[5] = ""
            set Stun_TARGET_EFFECTS_ATTACHMENT_POINT[5] = ""
            loop
                call InitEffectType( Stun_TARGET_EFFECTS_PATH[iteration] )
                set iteration = iteration - 1
                exitwhen (iteration < 0)
            endloop
            call Ensnare_Ensnare_Init()
            call EntanglingRoots_EntanglingRoots_Init()
            call Thunderbolt_Thunderbolt_Init()
            call Type0_Type0_Init()
            call Type1_Type1_Init()
            call Type2_Type2_Init()
            call Type3_Type3_Init()
            call Type4_Type4_Init()
            call Type5_Type5_Init()
            call Timed_Timed_Init()
        endfunction
    //! runtextmacro Endscope()

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Vertex Color
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("VertexColor")
        function GetUnitVertexColorRed takes Unit whichUnit returns real
            return whichUnit.vertexColorRed
        endfunction

        function GetUnitVertexColorRedForPlayer takes Unit whichUnit, player whichPlayer returns real
            return whichUnit.vertexColorRedForPlayer[GetPlayerId(whichPlayer)]
        endfunction

        function GetUnitVertexColorGreen takes Unit whichUnit returns real
            return whichUnit.vertexColorGreen
        endfunction

        function GetUnitVertexColorGreenForPlayer takes Unit whichUnit, player whichPlayer returns real
            return whichUnit.vertexColorGreenForPlayer[GetPlayerId(whichPlayer)]
        endfunction

        function GetUnitVertexColorBlue takes Unit whichUnit returns real
            return whichUnit.vertexColorBlue
        endfunction

        function GetUnitVertexColorBlueForPlayer takes Unit whichUnit, player whichPlayer returns real
            return whichUnit.vertexColorBlueForPlayer[GetPlayerId(whichPlayer)]
        endfunction

        function GetUnitVertexColorAlpha takes Unit whichUnit returns real
            return whichUnit.vertexColorAlpha
        endfunction

        function GetUnitVertexColorAlphaForPlayer takes Unit whichUnit, player whichPlayer returns real
            return whichUnit.vertexColorAlphaForPlayer[GetPlayerId(whichPlayer)]
        endfunction

        function SetUnitVertexColorWJ takes Unit whichUnit, real red, real green, real blue, real alpha, player whichPlayer returns nothing
            if ( whichPlayer == null ) then
                set red = red + GetUnitVertexColorRedForPlayer(whichUnit, whichPlayer)
                set red = Max( 0, red )
                set red = Min( red, 255 )
                set green = green + GetUnitVertexColorGreenForPlayer(whichUnit, whichPlayer)
                set green = Max( 0, green )
                set green = Min( green, 255 )
                set blue = blue + GetUnitVertexColorBlueForPlayer(whichUnit, whichPlayer)
                set blue = Max( 0, blue )
                set blue = Min( blue, 255 )
                set alpha = alpha + GetUnitVertexColorAlphaForPlayer(whichUnit, whichPlayer)
                set alpha = Max( 0, alpha )
                set alpha = Min( alpha, 255 )
                call SetUnitVertexColor( whichUnit.self, R2I( red ), R2I( green ), R2I( blue ), R2I( alpha ) )
            elseif ( GetLocalPlayer() == whichPlayer ) then
                set red = red + GetUnitVertexColorRed(whichUnit)
                set red = Max( 0, red )
                set red = Min( red, 255 )
                set green = green + GetUnitVertexColorGreen(whichUnit)
                set green = Max( 0, green )
                set green = Min( green, 255 )
                set blue = blue + GetUnitVertexColorBlue(whichUnit)
                set blue = Max( 0, blue )
                set blue = Min( blue, 255 )
                set alpha = alpha + GetUnitVertexColorAlpha(whichUnit)
                set alpha = Max( 0, alpha )
                set alpha = Min( alpha, 255 )
                call SetUnitVertexColor( whichUnit.self, R2I( red ), R2I( green ), R2I( blue ), R2I( alpha ) )
            endif
        endfunction

        function SetUnitVertexColorEx takes Unit whichUnit, real red, real green, real blue, real alpha, player whichPlayer returns nothing
            local integer whichPlayerId
            if ( whichPlayer == null ) then
                set whichUnit.vertexColorRed = red
                set whichUnit.vertexColorGreen = green
                set whichUnit.vertexColorBlue = blue
                set whichUnit.vertexColorAlpha = alpha
            else
                set whichPlayerId = GetPlayerId(whichPlayer)
                set whichUnit.vertexColorRedForPlayer[whichPlayerId] = red
                set whichUnit.vertexColorGreenForPlayer[whichPlayerId] = green
                set whichUnit.vertexColorBlueForPlayer[whichPlayerId] = blue
                set whichUnit.vertexColorAlphaForPlayer[whichPlayerId] = alpha
            endif
            call SetUnitVertexColorWJ( whichUnit, red, green, blue, alpha, whichPlayer )
        endfunction

        function AddUnitVertexColor takes Unit whichUnit, real red, real green, real blue, real alpha, player whichPlayer returns nothing
            if (whichPlayer == null) then
                call SetUnitVertexColorEx( whichUnit, GetUnitVertexColorRed( whichUnit ) + red, GetUnitVertexColorGreen( whichUnit ) + green, GetUnitVertexColorBlue( whichUnit ) + blue, GetUnitVertexColorAlpha(whichUnit) + alpha, whichPlayer )
            else
                call SetUnitVertexColorEx( whichUnit, GetUnitVertexColorRedForPlayer(whichUnit, whichPlayer) + red, GetUnitVertexColorGreenForPlayer(whichUnit, whichPlayer) + green, GetUnitVertexColorBlueForPlayer(whichUnit, whichPlayer) + blue, GetUnitVertexColorAlphaForPlayer(whichUnit, whichPlayer) + alpha, whichPlayer )
            endif
        endfunction

        //! runtextmacro Scope("Timed")
            globals
                private constant real Timed_UPDATE_TIME = 0.035
            endglobals

            private struct Timed_Data
                real bonusRedPerInterval
                real bonusGreenPerInterval
                real bonusBluePerInterval
                real bonusAlphaPerInterval
                timer durationTimer
                timer updateTimer
                player whichPlayer
                Unit whichUnit
            endstruct

            private function Timed_Ending takes Timed_Data d, timer durationTimer, Unit whichUnit returns nothing
                local timer updateTimer = d.updateTimer
                local integer whichUnitId = whichUnit.id
                call d.destroy()
                call DestroyTimerWJ( durationTimer )
                call DestroyTimerWJ( updateTimer )
                set updateTimer = null
                call RemoveIntegerFromTableById( whichUnitId, Timed_SCOPE_ID, d )
                if (CountIntegersInTableById(whichUnitId, Timed_SCOPE_ID) == TABLE_EMPTY) then
                    //! runtextmacro RemoveEventById( "whichUnitId", "Timed_EVENT_DECAY" )
                endif
            endfunction

            public function Timed_Decay takes Unit whichUnit returns nothing
                local Timed_Data d
                local integer whichUnitId = whichUnit.id
                local integer iteration = CountIntegersInTableById(whichUnitId, Timed_SCOPE_ID)
                if (iteration > TABLE_EMPTY) then
                    loop
                        set d = GetIntegerFromTableById(whichUnitId, Timed_SCOPE_ID, iteration)
                        call Timed_Ending(d, d.durationTimer, whichUnit)
                        set iteration = iteration - 1
                        exitwhen (iteration < TABLE_STARTED)
                    endloop
                endif
            endfunction

            private function Timed_Decay_Event takes nothing returns nothing
                call Timed_Decay(TRIGGER_UNIT)
            endfunction

            private function Timed_EndingByTimer takes nothing returns nothing
                local timer durationTimer = GetExpiredTimer()
                local Timed_Data d = GetAttachedInteger(durationTimer, Timed_SCOPE_ID)
                call Timed_Ending( d, durationTimer, d.whichUnit )
                set durationTimer = null
            endfunction

            private function Timed_Update takes nothing returns nothing
                local timer updateTimer = GetExpiredTimer()
                local Timed_Data d = GetAttachedInteger(updateTimer, Timed_SCOPE_ID)
                local Unit whichUnit = d.whichUnit
                call AddUnitVertexColor( whichUnit, d.bonusRedPerInterval, d.bonusGreenPerInterval, d.bonusBluePerInterval, d.bonusAlphaPerInterval, d.whichPlayer )
            endfunction

            function AddUnitVertexColorTimed takes Unit whichUnit, real red, real green, real blue, real alpha, player whichPlayer, real duration returns nothing
                local Timed_Data d
                local timer durationTimer
                local timer updateTimer
                local integer wavesAmount
                local integer whichUnitId
                if ( duration != 0 ) then
                    set d = Timed_Data.create()
                    set durationTimer = CreateTimerWJ()
                    set updateTimer = CreateTimerWJ()
                    set wavesAmount = R2I(duration / Timed_UPDATE_TIME)
                    set whichUnitId = whichUnit.id
                    set d.bonusRedPerInterval = red / wavesAmount
                    set d.bonusGreenPerInterval = green / wavesAmount
                    set d.bonusBluePerInterval = blue / wavesAmount
                    set d.bonusAlphaPerInterval = alpha / wavesAmount
                    set d.durationTimer = durationTimer
                    set d.updateTimer = updateTimer
                    set d.whichPlayer = whichPlayer
                    set d.whichUnit = whichUnit
                    call AttachInteger( durationTimer, Timed_SCOPE_ID, d )
                    call AttachInteger( updateTimer, Timed_SCOPE_ID, d )
                    call AddIntegerToTableById( whichUnitId, Timed_SCOPE_ID, d )
                    if (CountIntegersInTableById(whichUnitId, Timed_SCOPE_ID) == TABLE_STARTED) then
                        //! runtextmacro AddEventById( "whichUnitId", "Timed_EVENT_DECAY" )
                    endif
                    call TimerStart( updateTimer, Timed_UPDATE_TIME, true, function Timed_Update )
                    set updateTimer = null
                    call TimerStart( durationTimer, duration, false, function Timed_EndingByTimer )
                    set durationTimer = null
                else
                    call AddUnitVertexColor(whichUnit, red, green, blue, alpha, whichPlayer)
                endif
            endfunction

            public function Timed_Init takes nothing returns nothing
                //! runtextmacro CreateEvent( "Timed_EVENT_DECAY", "UnitFinishesDecaying_EVENT_KEY", "0", "function Timed_Decay_Event" )
            endfunction
        //! runtextmacro Endscope()

        function GetUnitTypeVertexColorRed takes UnitType whichUnitType returns real
            return whichUnitType.vertexColorRed
        endfunction

        function GetUnitTypeVertexColorGreen takes UnitType whichUnitType returns real
            return whichUnitType.vertexColorGreen
        endfunction

        function GetUnitTypeVertexColorBlue takes UnitType whichUnitType returns real
            return whichUnitType.vertexColorBlue
        endfunction

        function GetUnitTypeVertexColorAlpha takes UnitType whichUnitType returns real
            return whichUnitType.vertexColorAlpha
        endfunction

        function SetUnitTypeVertexColor takes UnitType whichUnitType, real red, real green, real blue, real alpha returns nothing
            set whichUnitType.vertexColorRed = red
            set whichUnitType.vertexColorGreen = green
            set whichUnitType.vertexColorBlue = blue
            set whichUnitType.vertexColorAlpha = alpha
        endfunction

        public function VertexColor_Init takes nothing returns nothing
            call Timed_Timed_Init()
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro Scope("DummyVertexColor")
        private struct DummyVertexColor_Data
            real red
            real green
            real blue
            real alpha
        endstruct

        function DestroyDummyVertexColor takes unit dummyUnit returns nothing
            local DummyVertexColor_Data d = GetAttachedInteger(dummyUnit, DummyVertexColor_SCOPE_ID)
            call d.destroy()
            call FlushAttachedInteger(dummyUnit, DummyVertexColor_SCOPE_ID)
        endfunction

        private function DummyVertexColor_GetRed takes DummyVertexColor_Data d returns real
            return d.red
        endfunction

        private function DummyVertexColor_GetGreen takes DummyVertexColor_Data d returns real
            return d.green
        endfunction

        private function DummyVertexColor_GetBlue takes DummyVertexColor_Data d returns real
            return d.blue
        endfunction

        private function DummyVertexColor_GetAlpha takes DummyVertexColor_Data d returns real
            return d.alpha
        endfunction

        private function DummyVertexColor_Set takes unit dummyUnit, DummyVertexColor_Data d, real red, real green, real blue, real alpha returns nothing
            set d.red = red
            set d.green = green
            set d.blue = blue
            set d.alpha = alpha
            set red = Max( 0, red )
            set red = Min( red, 255 )
            set green = Max( 0, green )
            set green = Min( green, 255 )
            set blue = Max( 0, blue )
            set blue = Min( blue, 255 )
            set alpha = Max( 0, alpha )
            set alpha = Min( alpha, 255 )
            call SetUnitVertexColor( dummyUnit, R2I( red ), R2I( green ), R2I( blue ), R2I( alpha ) )
        endfunction

        private function DummyVertexColor_Add takes unit dummyUnit, DummyVertexColor_Data d, real red, real green, real blue, real alpha returns nothing
            call DummyVertexColor_Set( dummyUnit, d, DummyVertexColor_GetRed( d ) + red, DummyVertexColor_GetGreen( d ) + green, DummyVertexColor_GetBlue( d ) + blue, DummyVertexColor_GetAlpha( d ) + alpha )
        endfunction

        //! runtextmacro Scope("Timed")
            globals
                private constant real Timed_UPDATE_TIME = 0.035
            endglobals

            private struct Timed_Data
                real bonusRedPerInterval
                real bonusGreenPerInterval
                real bonusBluePerInterval
                real bonusAlphaPerInterval
                timer durationTimer
                timer updateTimer
                unit whichUnit
            endstruct

            private function Timed_GetUnitData takes unit whichUnit returns Timed_Data
                return GetAttachedInteger(whichUnit, Timed_SCOPE_ID)
            endfunction

            private function Timed_Ending takes Timed_Data d, timer durationTimer, unit whichUnit returns nothing
                local timer updateTimer = d.updateTimer
                call d.destroy()
                call DestroyTimerWJ( durationTimer )
                call DestroyTimerWJ( updateTimer )
                set updateTimer = null
                call RemoveIntegerFromTable( whichUnit, Timed_SCOPE_ID, d )
            endfunction

            private function Timed_EndingByTimer takes nothing returns nothing
                local timer durationTimer = GetExpiredTimer()
                local Timed_Data d = GetAttachedInteger(durationTimer, Timed_SCOPE_ID)
                call Timed_Ending( d, durationTimer, d.whichUnit )
                set durationTimer = null
            endfunction

            private function Timed_Update takes nothing returns nothing
                local timer updateTimer = GetExpiredTimer()
                local Timed_Data d = GetAttachedInteger(updateTimer, Timed_SCOPE_ID)
                local unit whichUnit = d.whichUnit
                call DummyVertexColor_Add( whichUnit, Timed_GetUnitData(whichUnit), d.bonusRedPerInterval, d.bonusGreenPerInterval, d.bonusBluePerInterval, d.bonusAlphaPerInterval )
                set whichUnit = null
            endfunction

            function AddDummyVertexColorTimed takes unit whichUnit, real red, real green, real blue, real alpha, real duration returns nothing
                local Timed_Data d
                local timer durationTimer
                local timer updateTimer
                local integer wavesAmount
                if ( duration != 0 ) then
                    set d = Timed_Data.create()
                    set durationTimer = CreateTimerWJ()
                    set updateTimer = CreateTimerWJ()
                    set wavesAmount = R2I(duration / Timed_UPDATE_TIME)
                    set d.bonusRedPerInterval = red / wavesAmount
                    set d.bonusGreenPerInterval = green / wavesAmount
                    set d.bonusBluePerInterval = blue / wavesAmount
                    set d.bonusAlphaPerInterval = alpha / wavesAmount
                    set d.durationTimer = durationTimer
                    set d.updateTimer = updateTimer
                    set d.whichUnit = whichUnit
                    call AttachInteger( durationTimer, Timed_SCOPE_ID, d )
                    call AttachInteger( updateTimer, Timed_SCOPE_ID, d )
                    call AddIntegerToTable( whichUnit, Timed_SCOPE_ID, d )
                    call TimerStart( updateTimer, Timed_UPDATE_TIME, true, function Timed_Update )
                    set updateTimer = null
                    call TimerStart( durationTimer, duration, false, function Timed_EndingByTimer )
                    set durationTimer = null
                else
                    call DummyVertexColor_Add(whichUnit, Timed_GetUnitData(whichUnit), red, green, blue, alpha)
                endif
            endfunction
        //! runtextmacro Endscope()

        function InitDummyVertexColor takes unit dummyUnit, real red, real green, real blue, real alpha returns nothing
            local DummyVertexColor_Data d = DummyVertexColor_Data.create()
            set d.red = red
            set d.green = green
            set d.blue = blue
            set d.alpha = alpha
            call AttachInteger(dummyUnit, DummyVertexColor_SCOPE_ID, d)
            call SetUnitVertexColor(dummyUnit, R2I(red), R2I(green), R2I(blue), R2I(alpha))
        endfunction
    //! runtextmacro Endscope()

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("FrostSlow")
        globals
            private constant real FrostSlow_BONUS_RED = -150.
            private constant real FrostSlow_BONUS_GREEN = -150.
            private constant real FrostSlow_BONUS_BLUE = 0.
            private constant real FrostSlow_FADE_TIME = 0.5
            private constant string FrostSlow_TARGET_EFFECT_PATH = "Abilities\\Spells\\Other\\FrostDamage\\FrostDamage.mdl"
            private constant string FrostSlow_TARGET_EFFECT_ATTACHMENT_POINT = "chest"
        endglobals

        function GetUnitFrostSlow takes Unit whichUnit returns integer
            return whichUnit.frostSlow
        endfunction

        function RemoveUnitFrostSlow takes Unit whichUnit returns nothing
            local integer amount = GetUnitFrostSlow(whichUnit) - 1
            set whichUnit.frostSlow = amount
            if (amount == 0) then
                call DestroyEffectWJ(whichUnit.frostSlowEffect)
                call AddUnitVertexColorTimed( whichUnit, -FrostSlow_BONUS_RED, -FrostSlow_BONUS_GREEN, -FrostSlow_BONUS_BLUE, 0, null, FrostSlow_FADE_TIME )
            endif
        endfunction

        function AddUnitFrostSlow takes Unit whichUnit returns nothing
            local integer amount = GetUnitFrostSlow(whichUnit) + 1
            set whichUnit.frostSlow = amount
            if (amount == 1) then
                set whichUnit.frostSlowEffect = AddSpecialEffectTargetWJ( FrostSlow_TARGET_EFFECT_PATH, whichUnit.self, FrostSlow_TARGET_EFFECT_ATTACHMENT_POINT )
                call AddUnitVertexColorTimed( whichUnit, FrostSlow_BONUS_RED, FrostSlow_BONUS_GREEN, FrostSlow_BONUS_BLUE, 0, null, FrostSlow_FADE_TIME )
            endif
        endfunction
    //! runtextmacro Endscope()

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Ghost
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("Ghost")
        function GetUnitGhost takes Unit whichUnit returns integer
            return whichUnit.ghost
        endfunction

        function RemoveUnitGhost takes Unit whichUnit returns nothing
            local integer amount = GetUnitGhost( whichUnit ) - 1
            set whichUnit.ghost = amount
            if ( amount == 0 ) then
                call UnitRemoveAbility( whichUnit.self, GHOST_SPELL_ID )
            endif
        endfunction

        function AddUnitGhost takes Unit whichUnit returns nothing
            local integer amount = GetUnitGhost( whichUnit ) + 1
            set whichUnit.ghost = amount
            if ( amount == 1 ) then
                call UnitAddAbility( whichUnit.self, GHOST_SPELL_ID )
            endif
        endfunction
    //! runtextmacro Endscope()

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////    Invisibility
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("Invisibility")
        function GetUnitInvisibility takes Unit whichUnit returns integer
            return whichUnit.invisibility
        endfunction

        function RemoveUnitInvisibility takes Unit whichUnit returns nothing
            local integer amount = GetUnitInvisibility(whichUnit) - 1
            set whichUnit.invisibility = amount
            if (amount == 0) then
                call RemoveUnitGhost(whichUnit)
                call UnitRemoveAbility(whichUnit.self, INVISIBILITY_SPELL_ID)
                call AddUnitVertexColor(whichUnit, 0, 0, 0, 0, null)
            endif
        endfunction

        function AddUnitInvisibility takes Unit whichUnit returns nothing
            local integer amount = GetUnitInvisibility(whichUnit) + 1
            set whichUnit.invisibility = amount
            if (amount == 1) then
                call AddUnitGhost(whichUnit)
                call UnitAddAbility(whichUnit.self, INVISIBILITY_SPELL_ID)
            endif
        endfunction
    //! runtextmacro Endscope()

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////    Magic Immunity
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("MagicImmunity")
        globals
            private constant integer MagicImmunity_DUMMY_SPELL_BOOK_SPELL_ID = 'A07N'
            private constant integer MagicImmunity_DUMMY_SPELL_ID = 'A02M'
            private constant integer MagicImmunity_ICON_DUMMY_SPELL_ID = 'A02N'
        endglobals

        function GetUnitMagicImmunity takes Unit whichUnit returns integer
            return whichUnit.magicImmunity
        endfunction

        function RemoveUnitMagicImmunity takes Unit whichUnit returns nothing
            local integer amount = whichUnit.magicImmunity - 1
            set whichUnit.magicImmunity = amount
            if (amount == 0) then
                call UnitRemoveAbility(whichUnit.self, MagicImmunity_DUMMY_SPELL_BOOK_SPELL_ID)
            endif
        endfunction

        function AddUnitMagicImmunity takes Unit whichUnit returns nothing
            local integer amount = whichUnit.magicImmunity + 1
            set whichUnit.magicImmunity = amount
            if (amount == 1) then
                call DispelUnit(whichUnit, true, false, false)
                call UnitAddAbility(whichUnit.self, MagicImmunity_DUMMY_SPELL_BOOK_SPELL_ID)
            endif
        endfunction

        public function MagicImmunity_Init takes nothing returns nothing
            local integer iteration = MAX_PLAYER_INDEX
            loop
                call SetPlayerAbilityAvailable(PlayerWJ(iteration), MagicImmunity_DUMMY_SPELL_BOOK_SPELL_ID, false)
                set iteration = iteration - 1
                exitwhen (iteration < 0)
            endloop
        endfunction
    //! runtextmacro Endscope()

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //! runtextmacro Scope("Order")
        function GetAbilityOrderId takes integer abilityId, integer orderId returns integer
            if (abilityId == 0) then
                return 0
            endif
            if (orderId == 0) then
                return 0
            endif
            return MaxI( INTEGER_MIN, -('0000' + (abilityId - 'A000') * (orderId - 851000)) )
        endfunction

        function IssueImmediateOrderByIdEx takes Unit whichUnit, integer whichOrder returns boolean
            local boolean result
            call DisableTrigger( UnitGetsOrder_DUMMY_TRIGGER )
            set result = IssueImmediateOrderById( whichUnit.self, whichOrder )
            call EnableTrigger( UnitGetsOrder_DUMMY_TRIGGER )
            return result
        endfunction

        //! runtextmacro Scope("ImmediateTimed")
            private struct ImmediateTimed_Data
                timer delayTimer
                Unit target
                integer whichOrder
                Unit whichUnit
            endstruct

            private function ImmediateTimed_Ending takes ImmediateTimed_Data d, timer delayTimer, Unit whichUnit returns nothing
                local integer whichUnitId = whichUnit.id
                call d.destroy()
                call FlushAttachedInteger( delayTimer, ImmediateTimed_SCOPE_ID )
                call DestroyTimerWJ( delayTimer )
                call FlushAttachedIntegerById( whichUnitId, ImmediateTimed_SCOPE_ID )
                //! runtextmacro RemoveEventById( "whichUnitId", "ImmediateTimed_EVENT_DEATH" )
                //! runtextmacro RemoveEventById( "whichUnitId", "ImmediateTimed_EVENT_ORDER" )
            endfunction

            public function ImmediateTimed_Death takes Unit whichUnit returns nothing
                local ImmediateTimed_Data d = GetAttachedIntegerById( whichUnit.id, ImmediateTimed_SCOPE_ID )
                if ( d != NULL ) then
                    call ImmediateTimed_Ending( d, d.delayTimer, whichUnit )
                endif
            endfunction

            private function ImmediateTimed_Death_Event takes nothing returns nothing
                call ImmediateTimed_Death(DYING_UNIT)
            endfunction

            public function ImmediateTimed_OrderExecute takes Unit whichUnit returns nothing
                local ImmediateTimed_Data d = GetAttachedIntegerById( whichUnit.id, ImmediateTimed_SCOPE_ID )
                if ( d != NULL ) then
                    call ImmediateTimed_Ending( d, d.delayTimer, whichUnit )
                endif
            endfunction

            private function ImmediateTimed_OrderExecute_Event takes nothing returns nothing
                call ImmediateTimed_OrderExecute(ORDERED_UNIT)
            endfunction

            private function ImmediateTimed_EndingByTimer takes nothing returns nothing
                local timer delayTimer = GetExpiredTimer()
                local ImmediateTimed_Data d = GetAttachedInteger(delayTimer, ImmediateTimed_SCOPE_ID)
                local integer whichOrder = d.whichOrder
                local Unit whichUnit = d.whichUnit
                call ImmediateTimed_Ending( d, delayTimer, whichUnit )
                set delayTimer = null
                call IssueImmediateOrderById( whichUnit.self, whichOrder )
            endfunction

            function IssueImmediateOrderByIdTimed takes Unit whichUnit, integer whichOrder, real time returns nothing
                local ImmediateTimed_Data d = ImmediateTimed_Data.create()
                local timer delayTimer = CreateTimerWJ()
                local integer whichUnitId = whichUnit.id
                set d.delayTimer = delayTimer
                set d.whichOrder = whichOrder
                set d.whichUnit = whichUnit
                call AttachInteger( delayTimer, ImmediateTimed_SCOPE_ID, d )
                call AttachIntegerById( whichUnitId, ImmediateTimed_SCOPE_ID, d )
                //! runtextmacro AddEventById( "whichUnitId", "ImmediateTimed_EVENT_DEATH" )
                //! runtextmacro AddEventById( "whichUnitId", "ImmediateTimed_EVENT_ORDER" )
                call TimerStart( delayTimer, time, false, function ImmediateTimed_EndingByTimer )
                set delayTimer = null
            endfunction

            public function ImmediateTimed_Init takes nothing returns nothing
                //! runtextmacro CreateEvent( "ImmediateTimed_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function ImmediateTimed_Death_Event" )
                //! runtextmacro CreateEvent( "ImmediateTimed_EVENT_ORDER_EXECUTE", "UnitGetsOrder_Executed_Executed_EVENT_KEY", "0", "function ImmediateTimed_OrderExecute_Event" )
            endfunction
        //! runtextmacro Endscope()

        function IssuePointOrderByIdEx takes Unit whichUnit, integer whichOrder, real x, real y returns boolean
            local boolean result
            call DisableTrigger( UnitGetsOrder_DUMMY_TRIGGER )
            set result = IssuePointOrderById( whichUnit.self, whichOrder, x, y )
            call EnableTrigger( UnitGetsOrder_DUMMY_TRIGGER )
            return result
        endfunction

        function IssueTargetOrderByIdEx takes Unit whichUnit, integer whichOrder, widget whichTarget returns boolean
            local boolean result
            call DisableTrigger( UnitGetsOrder_DUMMY_TRIGGER )
            set result = IssueTargetOrderById( whichUnit.self, whichOrder, whichTarget )
            call EnableTrigger( UnitGetsOrder_DUMMY_TRIGGER )
            return result
        endfunction

        //! runtextmacro Scope("TargetTimed")
            private struct TargetTimed_Data
                timer delayTimer
                Unit target
                integer whichOrder
                Unit whichUnit
            endstruct

            private function TargetTimed_Ending takes TargetTimed_Data d, timer delayTimer, Unit whichUnit returns nothing
                local integer whichUnitId = whichUnit.id
                call d.destroy()
                call FlushAttachedInteger( delayTimer, TargetTimed_SCOPE_ID )
                call DestroyTimerWJ( delayTimer )
                call FlushAttachedIntegerById( whichUnitId, TargetTimed_SCOPE_ID )
                //! runtextmacro RemoveEventById( "whichUnitId", "TargetTimed_EVENT_DEATH" )
                //! runtextmacro RemoveEventById( "whichUnitId", "TargetTimed_EVENT_ORDER" )
            endfunction

            public function TargetTimed_Death takes Unit whichUnit returns nothing
                local TargetTimed_Data d = GetAttachedIntegerById( whichUnit.id, TargetTimed_SCOPE_ID )
                if ( d != NULL ) then
                    call TargetTimed_Ending( d, d.delayTimer, whichUnit )
                endif
            endfunction

            private function TargetTimed_Death_Event takes nothing returns nothing
                call TargetTimed_Death(DYING_UNIT)
            endfunction

            public function TargetTimed_OrderExecute takes Unit whichUnit returns nothing
                local TargetTimed_Data d = GetAttachedIntegerById( whichUnit.id, TargetTimed_SCOPE_ID )
                if ( d != NULL ) then
                    call TargetTimed_Ending( d, d.delayTimer, whichUnit )
                endif
            endfunction

            private function TargetTimed_OrderExecute_Event takes nothing returns nothing
                call TargetTimed_OrderExecute(ORDERED_UNIT)
            endfunction

            private function TargetTimed_EndingByTimer takes nothing returns nothing
                local timer delayTimer = GetExpiredTimer()
                local TargetTimed_Data d = GetAttachedInteger(delayTimer, TargetTimed_SCOPE_ID)
                local Unit target = d.target
                local integer whichOrder = d.whichOrder
                local Unit whichUnit = d.whichUnit
                call TargetTimed_Ending( d, delayTimer, whichUnit )
                set delayTimer = null
                call IssueTargetOrderById( whichUnit.self, whichOrder, target.self )
            endfunction

            function IssueTargetOrderByIdTimed takes Unit whichUnit, integer whichOrder, Unit target, real time returns nothing
                local TargetTimed_Data d = TargetTimed_Data.create()
                local timer delayTimer = CreateTimerWJ()
                local integer whichUnitId = whichUnit.id
                set d.delayTimer = delayTimer
                set d.target = target
                set d.whichOrder = whichOrder
                set d.whichUnit = whichUnit
                call AttachInteger( delayTimer, TargetTimed_SCOPE_ID, d )
                call AttachIntegerById( whichUnitId, TargetTimed_SCOPE_ID, d )
                //! runtextmacro AddEventById( "whichUnitId", "TargetTimed_EVENT_DEATH" )
                //! runtextmacro AddEventById( "whichUnitId", "TargetTimed_EVENT_ORDER" )
                call TimerStart( delayTimer, time, false, function TargetTimed_EndingByTimer )
                set delayTimer = null
            endfunction

            public function TargetTimed_Init takes nothing returns nothing
                //! runtextmacro CreateEvent( "TargetTimed_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function TargetTimed_Death_Event" )
                //! runtextmacro CreateEvent( "TargetTimed_EVENT_ORDER_EXECUTE", "UnitGetsOrder_Executed_Executed_EVENT_KEY", "0", "function TargetTimed_OrderExecute_Event" )
            endfunction
        //! runtextmacro Endscope()

        //! runtextmacro Scope("Stop")
            function StopUnit takes Unit whichUnit returns nothing
                local real whichUnitAngle
                local unit whichUnitSelf = whichUnit.self
                if ( IsUnitType( whichUnitSelf, UNIT_TYPE_STRUCTURE ) ) then
                    call ClearUnitRequestQueue( whichUnit )
                    call IssueImmediateOrderById( whichUnitSelf, STOP_EX_ORDER_ID )
                else
                    set whichUnitAngle = GetUnitFacingWJ( whichUnitSelf )
                    set UnitGetsOrder_IGNORE_NEXT = true
                    if (IssuePointOrderById( whichUnitSelf, MOVE_ORDER_ID, GetUnitX( whichUnitSelf ) + 1 * Cos( whichUnitAngle ), GetUnitY( whichUnitSelf ) + 1 * Sin( whichUnitAngle ) ) == false) then
                        set UnitGetsOrder_IGNORE_NEXT = false
                    endif
                endif
                set whichUnitSelf = null
            endfunction
        //! runtextmacro Endscope()

        public function Order_Init takes nothing returns nothing
            call ImmediateTimed_ImmediateTimed_Init()
            call TargetTimed_TargetTimed_Init()
        endfunction
    //! runtextmacro Endscope()

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    globals
        key UNIT_KEY
    endglobals

    function InitUnit takes unit whichUnit returns unit
        call AddObject( whichUnit, "Unit" )
    ///    call AddSavedIntegerToTable( "Objects", "Units", whichUnitId )
        return whichUnit
    endfunction

    function InitUnitEx takes unit whichUnit returns Unit
        call InitUnit(whichUnit)
        set TRIGGER_UNIT_SELF = whichUnit
        call RunTrigger(UnitAppears_DUMMY_TRIGGER)
        return GetUnit(whichUnit)
    endfunction

    function CreateUnitWJ takes player whichPlayer, integer whichTypeId, real x, real y, real angle returns unit
        return InitUnit( CreateUnit( whichPlayer, whichTypeId, x, y, angle * RAD_TO_DEG ) )
    endfunction

    function CreateUnitEx takes player whichPlayer, integer whichTypeId, real x, real y, real angle returns Unit
        local Unit newUnit
        local unit newUnitSelf = CreateUnitWJ( whichPlayer, whichTypeId, x, y, angle )
        call InitUnitEx( newUnitSelf )
        set newUnit = GetUnit(newUnitSelf)
        set newUnitSelf = null
        return newUnit
    endfunction

    function GetConstructingStructureEx takes nothing returns Unit
        return InitUnitEx( GetConstructingStructure() )
    endfunction

    function GetSoldUnitEx takes nothing returns Unit
        return InitUnitEx( GetSoldUnit() )
    endfunction

    function GetTrainedUnitEx takes nothing returns Unit
        return InitUnitEx( GetTrainedUnit() )
    endfunction

    function RemoveUnitWJ takes unit whichUnit returns nothing
        call RemoveObject( whichUnit, "Unit" )
    ///    call RemoveSavedIntegerFromTable( "Objects", "Units", whichUnitId )
        call RemoveUnit( whichUnit )
        set whichUnit = null
    endfunction

    globals
        key UNIT_TYPE_KEY
    endglobals

    function IsUnitTypeWJ takes integer whichUnitTypeId returns boolean
        return (GetUnitType(whichUnitTypeId) != NULL)
    endfunction

    function InitUnitType takes integer whichUnitTypeId returns nothing
        call RemoveUnitWJ( CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, whichUnitTypeId, 0, 0, 0 ) )
    endfunction

    function InitUnitTypeEx takes integer whichUnitTypeId returns UnitType
        local UnitType d = UnitType.create()
        set d.id = whichUnitTypeId
        call AttachIntegerById( whichUnitTypeId, UNIT_TYPE_KEY, d )
        call InitUnitType(whichUnitTypeId)
        return d
    endfunction

    //! runtextmacro Scope("RemainingReferences")
        function GetUnitRemainingReferences takes Unit whichUnit returns integer
            return whichUnit.remainingReferences
        endfunction

        function RemoveUnitRemainingReference takes Unit whichUnit returns nothing
            local integer amount = GetUnitRemainingReferences( whichUnit ) - 1
            local unit whichUnitSelf
            if ( ( amount == 0 ) and ( whichUnit.waitsForRemoval ) ) then
                set whichUnitSelf = whichUnit.self
                call whichUnit.destroy()
        //        call ShowUnitWJ( whichUnit, true )
                call RemoveUnitWJ( whichUnitSelf )
                set whichUnitSelf = null
            else
                set whichUnit.remainingReferences = amount
            endif
        endfunction

        function AddUnitRemainingReference takes Unit whichUnit returns nothing
            set whichUnit.remainingReferences = GetUnitRemainingReferences(whichUnit) + 1
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro Scope("RemoveUnit")
        function RemoveUnitEx takes Unit decayingUnit returns nothing
            set TRIGGER_UNIT = decayingUnit
            call RunTrigger(UnitFinishesDecaying_DUMMY_TRIGGER)
        endfunction

        //! runtextmacro Scope("Timed")
            private struct Timed_Data
                unit target
            endstruct

            private function Timed_Ending takes nothing returns nothing
                local timer durationTimer = GetExpiredTimer()
                local Timed_Data d = GetAttachedInteger(durationTimer, Timed_SCOPE_ID)
                local unit target = d.target
                call FlushAttachedInteger( durationTimer, Timed_SCOPE_ID )
                call DestroyTimerWJ( durationTimer )
                set durationTimer = null
                call RemoveUnitWJ( target )
                set target = null
            endfunction

            function RemoveUnitTimed takes unit target, real time returns nothing
                local Timed_Data d = Timed_Data.create()
                local timer durationTimer = CreateTimerWJ()
                set d.target = target
                call AttachInteger( durationTimer, Timed_SCOPE_ID, d )
                call TimerStart( durationTimer, time, false, function Timed_Ending )
                set durationTimer = null
            endfunction
        //! runtextmacro Endscope()

        //! runtextmacro Scope("TimedEx")
            private struct TimedEx_Data
                timer durationTimer
                Unit target
            endstruct

            private function TimedEx_Ending takes TimedEx_Data d, timer durationTimer, Unit target returns nothing
                local integer targetId = target.id
                call d.destroy()
                call FlushAttachedInteger( durationTimer, TimedEx_SCOPE_ID )
                call DestroyTimerWJ( durationTimer )
                call FlushAttachedIntegerById(targetId, TimedEx_SCOPE_ID)
                //! runtextmacro RemoveEventById( "targetId", "TimedEx_EVENT_DECAY" )
            endfunction

            public function TimedEx_Decay takes Unit target returns nothing
                local TimedEx_Data d = GetAttachedIntegerById(target.id, TimedEx_SCOPE_ID)
                if (d != NULL) then
                    call TimedEx_Ending(d, d.durationTimer, target)
                endif
            endfunction

            private function TimedEx_Decay_Event takes nothing returns nothing
                call TimedEx_Decay(TRIGGER_UNIT)
            endfunction

            private function TimedEx_EndingByTimer takes nothing returns nothing
                local timer durationTimer = GetExpiredTimer()
                local TimedEx_Data d = GetAttachedInteger(durationTimer, TimedEx_SCOPE_ID)
                local Unit target = d.target
                call TimedEx_Ending(d, durationTimer, target)
                set durationTimer = null
                call RemoveUnitEx( target )
            endfunction

            function RemoveUnitTimedEx takes Unit target, real time returns nothing
                local TimedEx_Data d = TimedEx_Data.create()
                local timer durationTimer = CreateTimerWJ()
                local integer targetId = target.id
                set d.durationTimer = durationTimer
                set d.target = target
                call AttachInteger( durationTimer, TimedEx_SCOPE_ID, d )
                call AttachIntegerById(targetId, TimedEx_SCOPE_ID, d)
                //! runtextmacro AddEventById( "targetId", "TimedEx_EVENT_DECAY" )
                call TimerStart( durationTimer, time, false, function TimedEx_EndingByTimer )
                set durationTimer = null
            endfunction

            public function TimedEx_Init takes nothing returns nothing
                //! runtextmacro CreateEvent( "TimedEx_EVENT_DECAY", "UnitFinishesDecaying_EVENT_KEY", "0", "function TimedEx_Decay_Event" )
            endfunction
        //! runtextmacro Endscope()

        public function RemoveUnit_Init takes nothing returns nothing
            call TimedEx_TimedEx_Init()
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro Scope("Upgrade")
        private struct Upgrade_Data
        endstruct

        function GetUnitCurrentUpgradeGoldCost takes Unit whichUnit returns integer
            return whichUnit.currentUpgradeGoldCost
        endfunction

        private function Upgrade_Ending takes Upgrade_Data d, Unit whichUnit returns nothing
            local integer whichUnitId = whichUnit.id
            call d.destroy()
            call FlushAttachedIntegerById(whichUnitId, Upgrade_SCOPE_ID)
            //! runtextmacro RemoveEventById( "whichUnitId", "Upgrade_EVENT_DEATH" )
        endfunction

        function Upgrade_Remove takes Unit whichUnit returns nothing
            call Upgrade_Ending(GetAttachedIntegerById(whichUnit.id, Upgrade_SCOPE_ID), whichUnit)
        endfunction

        function Upgrade_Death takes Unit whichUnit returns nothing
            local Upgrade_Data d = GetAttachedIntegerById(whichUnit.id, Upgrade_SCOPE_ID)
            if ( d != NULL ) then
                call Upgrade_Ending(d, whichUnit)
            endif
        endfunction

        private function Upgrade_Death_Event takes nothing returns nothing
            call Upgrade_Death( DYING_UNIT )
        endfunction

        function Upgrade_Start takes Unit whichUnit, integer goldCost returns nothing
            local Upgrade_Data d = Upgrade_Data.create()
            local integer whichUnitId = whichUnit.id
            set whichUnit.currentUpgradeGoldCost = goldCost
            call AttachIntegerById(whichUnitId, Upgrade_SCOPE_ID, d)
            //! runtextmacro AddEventById( "whichUnitId", "Upgrade_EVENT_DEATH" )
        endfunction

        public function Upgrade_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "Upgrade_EVENT_DEATH", "UnitDies_EVENT_KEY", "1", "function Upgrade_Death_Event" )
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro Scope("Shop")
        function AddUnitSoldItemTypeId takes unit sellingUnit, integer soldItemTypeId, integer amount returns nothing
            if ( amount > 1 ) then
                call AddItemToStock( sellingUnit, soldItemTypeId, amount, amount )
            endif
            call AddItemToStock( sellingUnit, soldItemTypeId, amount, amount )
        endfunction

        function AddUnitSoldItemTypeIdEx takes unit sellingUnit, integer soldItemTypeId, integer amount, integer maxAmount returns nothing
            if ( amount > 1 ) then
                call AddItemToStock( sellingUnit, soldItemTypeId, amount, maxAmount )
            endif
            call AddItemToStock( sellingUnit, soldItemTypeId, amount, maxAmount )
        endfunction

        function RemoveUnitSoldUnitTypeId takes unit sellingUnit, integer soldUnitTypeId returns nothing
            call RemoveUnitFromStock( sellingUnit, soldUnitTypeId )
        endfunction

        function AddUnitSoldUnitTypeId takes unit sellingUnit, integer soldUnitTypeId, integer amount returns nothing
            if ( amount > 1 ) then
                call AddUnitToStock( sellingUnit, soldUnitTypeId, amount, amount )
            endif
            call AddUnitToStock( sellingUnit, soldUnitTypeId, amount, amount )
        endfunction

        //! runtextmacro CreateSimpleUnitTypeState("shopMaxCharges", "ShopMaxCharges", "integer")
        //! runtextmacro CreateSimpleUnitTypeState("shopRefreshInterval", "ShopRefreshInterval", "real")
        //! runtextmacro CreateSimpleUnitTypeState("shopRefreshIntervalStart", "ShopRefreshIntervalStart", "real")
    //! runtextmacro Endscope()

    //! runtextmacro Scope("Explode")
        function GetUnitExplode takes Unit whichUnit returns integer
            return whichUnit.explode
        endfunction

        function RemoveUnitExplode takes Unit whichUnit returns nothing
            set whichUnit.explode = whichUnit.explode - 1
        endfunction

        function AddUnitExplode takes Unit whichUnit returns nothing
            set whichUnit.explode = whichUnit.explode + 1
            call AddUnitCanNotBeRevived(whichUnit)
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro Scope("Abilities")
        function CountUnitTypeAbilities takes UnitType whichUnitType returns integer
            return whichUnitType.abilitiesCount
        endfunction

        function GetUnitTypeAbility takes UnitType whichUnitType, integer index returns integer
            return whichUnitType.abilities[index]
        endfunction

        function AddUnitTypeAbility takes UnitType whichUnitType, integer abilcode returns nothing
            local integer count = CountUnitTypeAbilities(whichUnitType) + 1
            set whichUnitType.abilities[count] = abilcode
            set whichUnitType.abilitiesCount = count
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro Scope("HeroAbilities")
        function CountUnitHeroAbilities takes UnitType whichUnitType returns integer
            return whichUnitType.heroAbilitiesCount
        endfunction

        function GetUnitHeroAbility takes UnitType whichUnitType, integer index returns integer
            return whichUnitType.heroAbilities[index]
        endfunction

        function AddUnitHeroAbility takes UnitType whichUnitType, integer abilcode returns nothing
            local integer count = CountUnitHeroAbilities(whichUnitType) + 1
            set whichUnitType.heroAbilities[count] = abilcode
            set whichUnitType.heroAbilitiesCount = count
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro Scope("Illusion")
        globals
            private constant integer Illusion_ILLUSION_HERO_INVENTORY_SPELL_ID = 'A07G'
            private constant string Illusion_SPECIAL_EFFECT_PATH = "Abilities\\Spells\\Orc\\MirrorImage\\MirrorImageDeathCaster.mdl"
        endglobals

        private struct Illusion_Data
            force displayShip
        endstruct

        function UpdateIllusionDisplay takes Unit whichUnit returns nothing
            local Illusion_Data d = GetAttachedIntegerById(whichUnit.id, Illusion_SCOPE_ID)
            local force displayShip = d.displayShip
            local integer iteration = MAX_PLAYER_INDEX
            local player specificPlayer
            loop
                set specificPlayer = PlayerWJ( iteration )
                if ( IsPlayerInForce(specificPlayer, displayShip) ) then
                    if ( IsUnitAlly( whichUnit.self, specificPlayer ) == false ) then
                        call ForceRemovePlayer(displayShip, specificPlayer)
                        call AddUnitVertexColor( whichUnit, 223, -163, 0, 0, specificPlayer )
                    endif
                else
                    if ( IsUnitAlly( whichUnit.self, specificPlayer ) ) then
                        call ForceAddPlayer(displayShip, specificPlayer)
                        call AddUnitVertexColor( whichUnit, -223, 163, 0, 0, specificPlayer )
                    endif
                endif
                set iteration = iteration - 1
                exitwhen ( iteration < 0 )
            endloop
            set displayShip = null
            set specificPlayer = null
        endfunction

        function IsUnitIllusionWJ takes Unit whichUnit returns boolean
            return (GetAttachedIntegerById( whichUnit.id, Illusion_SCOPE_ID ) != NULL)
        endfunction

        public function Illusion_Decay takes Unit whichUnit returns nothing
            local Illusion_Data d
            local force displayShip
            local integer whichUnitId
            if (IsUnitIllusionWJ(whichUnit)) then
                set whichUnitId = whichUnit.id
                set d = GetAttachedIntegerById(whichUnitId, Illusion_SCOPE_ID)
                set displayShip = d.displayShip
                call d.destroy()
                call DestroyForceWJ(displayShip)
                set displayShip = null
                call FlushAttachedIntegerById(whichUnitId, Illusion_SCOPE_ID)
                //! runtextmacro RemoveEventById( "whichUnitId", "Illusion_EVENT_DECAY" )
            endif
        endfunction

        private function Illusion_Decay_Event takes nothing returns nothing
            call Illusion_Decay(TRIGGER_UNIT)
        endfunction

        function CreateIllusion takes Unit fromWhichUnit, player forWhichPlayer returns Unit
            local Illusion_Data d = Illusion_Data.create()
            local unit fromWhichUnitSelf = fromWhichUnit.self
            local integer fromWhichUnitTypeId = fromWhichUnit.type.id
            local UnitType fromWhichUnitType = GetUnitType(fromWhichUnitTypeId)
            local real fromWhichUnitX = GetUnitX( fromWhichUnitSelf )
            local real fromWhichUnitY = GetUnitY( fromWhichUnitSelf )
            local integer iteration
            local real fromWhichUnitAngle = GetUnitFacingWJ( fromWhichUnitSelf )
            local Unit newUnit
            local integer newUnitId
            local unit newUnitSelf
            local item specificItem
            set UnitAppears_NEXT_IS_ILLUSION = true
            set newUnit = CreateUnitEx( forWhichPlayer, fromWhichUnitTypeId, fromWhichUnitX, fromWhichUnitY, fromWhichUnitAngle )
            set newUnitId = newUnit.id
            set newUnitSelf = newUnit.self
            set d.displayShip = CreateForceWJ()
            call AttachIntegerById(newUnitId, Illusion_SCOPE_ID, d)
            //! runtextmacro AddEventById( "newUnitId", "Illusion_EVENT_DECAY" )
            if ( IsUnitType( fromWhichUnitSelf, UNIT_TYPE_HERO ) ) then
                set iteration = CountUnitTypeAbilities(fromWhichUnitType)
                loop
                    exitwhen ( iteration < 0 )
                    call UnitRemoveAbility( newUnitSelf, GetUnitTypeAbility(fromWhichUnitType, iteration) )
                    set iteration = iteration - 1
                endloop
                set iteration = CountUnitHeroAbilities(fromWhichUnitType)
                loop
                    exitwhen ( iteration < 0 )
                    call UnitRemoveAbility( newUnitSelf, GetUnitHeroAbility(fromWhichUnitType, iteration) )
                    set iteration = iteration - 1
                endloop
                call SetUnitEP( newUnitSelf, GetUnitEP( fromWhichUnitSelf ) )
                call UnitModifySkillPoints( newUnitSelf, -GetHeroSkillPoints(newUnitSelf) )
            endif
            //call UnitRemoveAbility( newUnit, 'AHbu' )
            set iteration = 0
            if ( GetUnitAbilityLevel( newUnitSelf, HERO_INVENTORY_SPELL_ID ) > 0 ) then
                call UnitRemoveAbility(newUnitSelf, HERO_INVENTORY_SPELL_ID)
                call UnitAddAbility( newUnitSelf, Illusion_ILLUSION_HERO_INVENTORY_SPELL_ID )
                loop
                    exitwhen ( iteration >= UnitInventorySize( newUnitSelf ) )
                    set specificItem = UnitItemInSlot( fromWhichUnitSelf, iteration )
                    if ( specificItem != null ) then
                        set specificItem = CreateItemWJ( GetItemTypeId( specificItem ), 0, 0 )
                        call UnitAddItem( newUnitSelf, specificItem )
                        call UnitDropItemSlot( newUnitSelf, specificItem, iteration )
                    endif
                    set iteration = iteration + 1
                endloop
                set specificItem = null
            endif
            call AddUnitDecay(newUnit)
            call SetUnitDecayTime(newUnit, 0)
            call SetUnitBlood( newUnit, "" )
            call SetUnitBloodExplosion( newUnit, Illusion_SPECIAL_EFFECT_PATH )
            call SetUnitDamageRelativeBonus( newUnit, -1 )
            call AddUnitExplode( newUnit )
            call SetUnitState( newUnitSelf, UNIT_STATE_LIFE, GetUnitState( fromWhichUnitSelf, UNIT_STATE_LIFE ) )
            call SetUnitState( newUnitSelf, UNIT_STATE_MANA, GetUnitState( fromWhichUnitSelf, UNIT_STATE_MANA ) )
            call UnitAddType( newUnitSelf, UNIT_TYPE_SUMMONED )
            set fromWhichUnitSelf = null
            set newUnitSelf = null
            call SetUnitStunDurationRelativeBonus( newUnit, -1 )
            call SetUnitSupplyProduced( newUnit, forWhichPlayer, 0 )
            call SetUnitSupplyUsed( newUnit, forWhichPlayer, 0 )
            call UpdateIllusionDisplay( newUnit )
            return newUnit
        endfunction

        public function Illusion_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "Illusion_EVENT_DECAY", "UnitFinishesDecaying_EVENT_KEY", "0", "function Illusion_Decay_Event" )
            call InitEffectType(Illusion_SPECIAL_EFFECT_PATH)
        endfunction
    //! runtextmacro Endscope()

    function SetUnitOwnerEx takes Unit whichUnit, player whichPlayer, boolean changeColor returns nothing
        local player whichUnitOwner = whichUnit.owner
        local integer whichUnitSupplyProduced = GetUnitSupplyProduced( whichUnit )
        local integer whichUnitSupplyUsed = GetUnitSupplyUsed( whichUnit )
        call SetUnitSupplyProduced( whichUnit, whichUnitOwner, 0 )
        call SetUnitSupplyUsed( whichUnit, whichUnitOwner, 0 )
        call SetUnitOwnerWJ( whichUnit, whichPlayer, changeColor )
        call SetUnitSupplyProduced( whichUnit, whichUnitOwner, whichUnitSupplyProduced )
        call SetUnitSupplyUsed( whichUnit, whichUnitOwner, whichUnitSupplyUsed )
        if ( IsUnitIllusionWJ( whichUnit ) ) then
            call UpdateIllusionDisplay( whichUnit )
        endif
    endfunction

    //! runtextmacro Scope("UnitSound")
        function CountUnitTypePissedSounds takes UnitType whichUnitType returns integer
            return whichUnitType.pissedSoundsCount
        endfunction

        function GetUnitTypePissedSound takes UnitType whichUnitType, integer index returns SoundType
            return whichUnitType.pissedSounds[index]
        endfunction

        function AddUnitTypePissedSound takes UnitType whichUnitType, SoundType whichSoundType returns nothing
            local integer count = CountUnitTypePissedSounds(whichUnitType) + 1
            set whichUnitType.pissedSounds[count] = whichSoundType
            set whichUnitType.pissedSoundsCount = count
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro Scope("Revaluation")
        globals
            private real array Revaluation_BONUS_RELATIVE_DAMAGE
            private real array Revaluation_BONUS_RELATIVE_LIFE
            private real array Revaluation_BONUS_RELATIVE_LIFE_REGENERATION
            private real array Revaluation_BONUS_RELATIVE_MANA
            private real array Revaluation_BONUS_RELATIVE_MANA_REGENERATION
            private real array Revaluation_BONUS_RELATIVE_VERTEX_COLOR_RED
            private real array Revaluation_BONUS_RELATIVE_VERTEX_COLOR_GREEN
            private real array Revaluation_BONUS_RELATIVE_VERTEX_COLOR_BLUE
            private real array Revaluation_BONUS_SCALE
            private unittype array Revaluation_BONUS_UNIT_TYPE
            constant integer REVALUATION_LEVELS_AMOUNT = 2
            private constant string Revaluation_SPECIAL_EFFECT_PATH = "Abilities\\Spells\\Demon\\ReviveDemon\\ReviveDemon.mdl"//"Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl"//"Abilities\\Spells\\Other\\Levelup\\Levelupcaster.mdl"
        endglobals

        function GetUnitRevaluation takes Unit whichUnit returns integer
            return whichUnit.revaluation
        endfunction

        function SetUnitRevaluation takes Unit whichUnit, integer level returns nothing
            local real bonusRelativeDamage
            local real bonusRelativeLife
            local real bonusRelativeMana
            local real bonusRelativeLifeRegeneration
            local real bonusRelativeManaRegeneration
            local real bonusRelativeVertexColorRed
            local real bonusRelativeVertexColorGreen
            local real bonusRelativeVertexColorBlue
            local real bonusScale
            local integer oldLevel = whichUnit.revaluation
            local integer iteration
            local integer min
            local unit whichUnitSelf
            local UnitType whichUnitType
            if (level != oldLevel) then
                set bonusRelativeDamage = 0
                set bonusRelativeLife = 0
                set bonusRelativeMana = 0
                set bonusRelativeLifeRegeneration = 0
                set bonusRelativeManaRegeneration = 0
                set bonusRelativeVertexColorRed = 0
                set bonusRelativeVertexColorGreen = 0
                set bonusRelativeVertexColorBlue = 0
                set bonusScale = 0
                set iteration = MaxI(level, oldLevel)
                set min = MinI(level, oldLevel)
                set whichUnitSelf = whichUnit.self
                set whichUnitType = whichUnit.type
                loop
                    set bonusRelativeDamage = bonusRelativeDamage + Revaluation_BONUS_RELATIVE_DAMAGE[iteration]
                    set bonusRelativeLife = bonusRelativeLife + Revaluation_BONUS_RELATIVE_LIFE[iteration]
                    set bonusRelativeMana = bonusRelativeMana + Revaluation_BONUS_RELATIVE_MANA[iteration]
                    set bonusRelativeLifeRegeneration = bonusRelativeLifeRegeneration + Revaluation_BONUS_RELATIVE_LIFE_REGENERATION[iteration]
                    set bonusRelativeManaRegeneration = bonusRelativeManaRegeneration + Revaluation_BONUS_RELATIVE_MANA_REGENERATION[iteration]
                    set bonusRelativeVertexColorRed = bonusRelativeVertexColorRed + Revaluation_BONUS_RELATIVE_VERTEX_COLOR_RED[iteration]
                    set bonusRelativeVertexColorGreen = bonusRelativeVertexColorGreen + Revaluation_BONUS_RELATIVE_VERTEX_COLOR_GREEN[iteration]
                    set bonusRelativeVertexColorBlue = bonusRelativeVertexColorBlue + Revaluation_BONUS_RELATIVE_VERTEX_COLOR_BLUE[iteration]
                    set bonusScale = bonusScale + Revaluation_BONUS_SCALE[iteration]
                    set iteration = iteration - 1
                    exitwhen (iteration == min)
                endloop
                if (oldLevel > 0) then
                    call UnitRemoveType(whichUnitSelf, Revaluation_BONUS_UNIT_TYPE[oldLevel])
                endif
                if (level < oldLevel) then
                    set bonusRelativeDamage = -bonusRelativeDamage
                    set bonusRelativeLife = -bonusRelativeLife
                    set bonusRelativeMana = -bonusRelativeMana
                    set bonusRelativeLifeRegeneration = -bonusRelativeLifeRegeneration
                    set bonusRelativeManaRegeneration = -bonusRelativeManaRegeneration
                    set bonusRelativeVertexColorRed = -bonusRelativeVertexColorRed
                    set bonusRelativeVertexColorGreen = -bonusRelativeVertexColorGreen
                    set bonusRelativeVertexColorBlue = -bonusRelativeVertexColorBlue
                    set bonusScale = -bonusScale
                else
                    call DestroyEffectWJ( AddSpecialEffectWJ( Revaluation_SPECIAL_EFFECT_PATH, GetUnitX( whichUnitSelf ), GetUnitY( whichUnitSelf ) ) )
                    if (level > 0) then
                        call UnitAddType( whichUnitSelf, Revaluation_BONUS_UNIT_TYPE[level] )
                    endif
                endif
                set whichUnitSelf = null
                set whichUnit.revaluation = level
                call AddUnitDamage( whichUnit, bonusRelativeDamage * GetUnitTypeDamage( whichUnitType ) )
                call AddUnitMaxLife( whichUnit, bonusRelativeLife * GetUnitTypeMaxLife( whichUnitType ) )
                call AddUnitMaxMana( whichUnit, bonusRelativeMana * GetUnitTypeMaxMana( whichUnitType ) )
                call AddUnitLifeRegeneration( whichUnit, bonusRelativeLifeRegeneration * GetUnitTypeLifeRegeneration( whichUnitType ) )
                call AddUnitManaRegeneration( whichUnit, bonusRelativeManaRegeneration * GetUnitTypeManaRegeneration( whichUnitType ) )
                call AddUnitScaleTimed( whichUnit, bonusScale * GetUnitTypeScale(whichUnitType), 1 )
                call AddUnitVertexColorTimed( whichUnit, bonusRelativeVertexColorRed * GetUnitTypeVertexColorRed(whichUnitType), bonusRelativeVertexColorGreen * GetUnitTypeVertexColorGreen(whichUnitType), bonusRelativeVertexColorBlue * GetUnitTypeVertexColorBlue(whichUnitType), 0, null, 1 )
            endif
            set TRIGGER_UNIT = whichUnit
            set UnitIsRevaluated_LEVEL = level
            set UnitIsRevaluated_OLD_LEVEL = oldLevel
            call RunTrigger(UnitIsRevaluated_DUMMY_TRIGGER)
        endfunction

        public function Revaluation_Init takes nothing returns nothing
            set Revaluation_BONUS_RELATIVE_DAMAGE[1] = 0.5
            set Revaluation_BONUS_RELATIVE_DAMAGE[2] = 0.75
            set Revaluation_BONUS_RELATIVE_LIFE[1] = 0.5
            set Revaluation_BONUS_RELATIVE_LIFE[2] = 0.75
            set Revaluation_BONUS_RELATIVE_LIFE_REGENERATION[1] = 0.5
            set Revaluation_BONUS_RELATIVE_LIFE_REGENERATION[2] = 0.75
            set Revaluation_BONUS_RELATIVE_MANA[1] = 0.5
            set Revaluation_BONUS_RELATIVE_MANA[2] = 0.75
            set Revaluation_BONUS_RELATIVE_MANA_REGENERATION[1] = 0.5
            set Revaluation_BONUS_RELATIVE_MANA_REGENERATION[2] = 0.75
            set Revaluation_BONUS_RELATIVE_VERTEX_COLOR_RED[1] = -0.5
            set Revaluation_BONUS_RELATIVE_VERTEX_COLOR_RED[2] = 0.5
            set Revaluation_BONUS_RELATIVE_VERTEX_COLOR_GREEN[1] = -0.5
            set Revaluation_BONUS_RELATIVE_VERTEX_COLOR_GREEN[2] = 0.3
            set Revaluation_BONUS_RELATIVE_VERTEX_COLOR_BLUE[1] = -0.5
            set Revaluation_BONUS_RELATIVE_VERTEX_COLOR_BLUE[2] = -0.5
            set Revaluation_BONUS_SCALE[1] = 0.1
            set Revaluation_BONUS_SCALE[2] = 0.1
            set Revaluation_BONUS_UNIT_TYPE[1] = UNIT_TYPE_GIANT
            set Revaluation_BONUS_UNIT_TYPE[2] = UNIT_TYPE_TAUREN
            call InitEffectType( Revaluation_SPECIAL_EFFECT_PATH )
        endfunction
    //! runtextmacro Endscope()

    function UnitChangeForm takes Unit whichUnit, UnitType toWhichUnitType returns nothing
        set TRIGGER_UNIT = whichUnit
        set TRIGGER_UNIT_TYPE = toWhichUnitType
        call RunTrigger( UnitChangesForm_DUMMY_TRIGGER )
    endfunction

    public function Init takes nothing returns nothing
        call Armor_Armor_Init()
        call Attack_Attack_Init()
        call AttackRate_AttackRate_Init()
        call Damage_Damage_Init()
        call Evasion_Evasion_Init()
        call MaxLife_MaxLife_Init()
        call MaxMana_MaxMana_Init()
        call SightRange_SightRange_Init()
        call Scale_Scale_Init()
        call Speed_Speed_Init()
        call VertexColor_VertexColor_Init()

        call Agility_Agility_Init()
        call Intelligence_Intelligence_Init()
        call Strength_Strength_Init()

        call Invulnerability_Invulnerability_Init()
        call MagicImmunity_MagicImmunity_Init()
        call Silence_Silence_Init()

        call Illusion_Illusion_Init()
        call Position_Position_Init()
        call Stun_Stun_Init()

        call Order_Order_Init()
        call RemoveUnit_RemoveUnit_Init()
        call Revaluation_Revaluation_Init()
        call Upgrade_Upgrade_Init()
    endfunction
//! runtextmacro Endscope()