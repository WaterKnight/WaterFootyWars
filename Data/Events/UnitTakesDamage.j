//TESH.scrollpos=6
//TESH.alwaysfold=0
scope UnitTakesDamage
    globals
        private constant real ARMOR_REDUCTION_FACTOR = 0.04
        public trigger DUMMY_TRIGGER
        private group ENUM_GROUP
        private constant integer SPECIAL_ATTACK_SPELL_ID = 'A040'
        private boolexpr SPLASH_TARGET_CONDITIONS

        public boolean NEXT_DAMAGE_IS_SPELL = false

        real DAMAGE_AMOUNT = 0
        boolean DAMAGE_BLOCKED
        integer DAMAGE_BLOCKED_AMOUNT = 0
        Unit DAMAGE_SOURCE
        real UNBLOCKABLE_DAMAGE_AMOUNT = 0
    endglobals

    private function TriggerEvents_Dynamic takes integer blocked, real damageAmount, Unit damageSource, boolean isPrimaryTarget, integer priority, Unit triggerUnit, real unblockableDamageAmount returns nothing
        local integer damageSourceId = damageSource.id
        local integer triggerUnitId = triggerUnit.id
        local integer iteration = CountEventsById( triggerUnitId, UnitTakesDamage_EVENT_KEY_FOR_BLOCKING, priority )
        loop
            exitwhen ( iteration < TABLE_STARTED )
            set DAMAGE_AMOUNT = damageAmount
            set DAMAGE_SOURCE = damageSource
            set TRIGGER_UNIT = triggerUnit
            call RunTrigger( GetEventsById( triggerUnitId, UnitTakesDamage_EVENT_KEY_FOR_BLOCKING, priority, iteration ) )
            set blocked = blocked + B2I(DAMAGE_BLOCKED)
            set iteration = iteration - 1
        endloop

        ////////// Primary

        if ( isPrimaryTarget ) then
            set iteration = CountEventsById( damageSourceId, UnitTakesDamage_EVENT_KEY_PRIMARY_AS_DAMAGE_SOURCE, priority )
            loop
                exitwhen ( iteration < TABLE_STARTED )
                set DAMAGE_AMOUNT = damageAmount
                set DAMAGE_SOURCE = damageSource
                set TRIGGER_UNIT = triggerUnit
                call RunTrigger( GetEventsById( damageSourceId, UnitTakesDamage_EVENT_KEY_PRIMARY_AS_DAMAGE_SOURCE, priority, iteration ) )
                set iteration = iteration - 1
            endloop
            set iteration = CountEventsById( triggerUnitId, UnitTakesDamage_EVENT_KEY_PRIMARY, priority )
            loop
                exitwhen ( iteration < TABLE_STARTED )
                set DAMAGE_AMOUNT = damageAmount
                set DAMAGE_SOURCE = damageSource
                set TRIGGER_UNIT = triggerUnit
                call RunTrigger( GetEventsById( triggerUnitId, UnitTakesDamage_EVENT_KEY_PRIMARY, priority, iteration ) )
                set iteration = iteration - 1
            endloop
            set iteration = CountEventsById( damageSourceId, UnitTakesDamage_EVENT_KEY_PRIMARY_FOR_DAMAGE_AS_DAMAGE_SOURCE, priority )
            loop
                exitwhen ( iteration < TABLE_STARTED )
                set DAMAGE_AMOUNT = damageAmount
                set DAMAGE_SOURCE = damageSource
                set TRIGGER_UNIT = triggerUnit
                call RunTrigger( GetEventsById( damageSourceId, UnitTakesDamage_EVENT_KEY_PRIMARY_FOR_DAMAGE_AS_DAMAGE_SOURCE, priority, iteration ) )
                set damageAmount = DAMAGE_AMOUNT
                set iteration = iteration - 1
            endloop
            set iteration = CountEventsById( damageSourceId, UnitTakesDamage_EVENT_KEY_PRIMARY_FOR_UNBLOCKABLE_AS_DAMAGE_SOURCE, priority )
            loop
                exitwhen ( iteration < TABLE_STARTED )
                set DAMAGE_AMOUNT = unblockableDamageAmount
                set DAMAGE_SOURCE = damageSource
                set TRIGGER_UNIT = triggerUnit
                call RunTrigger( GetEventsById( damageSourceId, UnitTakesDamage_EVENT_KEY_PRIMARY_FOR_UNBLOCKABLE_AS_DAMAGE_SOURCE, priority, iteration ) )
                set unblockableDamageAmount = DAMAGE_AMOUNT
                set iteration = iteration - 1
            endloop
            set iteration = CountEventsById( damageSourceId, UnitTakesDamage_EVENT_KEY_PRIMARY_UNBLOCKED_AS_DAMAGE_SOURCE, priority )
            loop
                exitwhen ( iteration < TABLE_STARTED )
                set DAMAGE_AMOUNT = damageAmount
                set DAMAGE_SOURCE = damageSource
                set TRIGGER_UNIT = triggerUnit
                call RunTrigger( GetEventsById( damageSourceId, UnitTakesDamage_EVENT_KEY_PRIMARY_UNBLOCKED_AS_DAMAGE_SOURCE, priority, iteration ) )
                set iteration = iteration - 1
            endloop
        endif

        ////////// Primary End

        set iteration = CountEventsById( triggerUnitId, UnitTakesDamage_EVENT_KEY_FOR_DAMAGE, priority )
        loop
            exitwhen ( iteration < TABLE_STARTED )
            set DAMAGE_AMOUNT = damageAmount
            set DAMAGE_SOURCE = damageSource
            set TRIGGER_UNIT = triggerUnit
            call RunTrigger( GetEventsById( triggerUnitId, UnitTakesDamage_EVENT_KEY_FOR_DAMAGE, priority, iteration ) )
            set damageAmount = DAMAGE_AMOUNT
            set iteration = iteration - 1
        endloop
        set iteration = CountEventsById( damageSourceId, UnitTakesDamage_EVENT_KEY_FOR_DAMAGE_AS_DAMAGE_SOURCE, priority )
        loop
            exitwhen ( iteration < TABLE_STARTED )
            set DAMAGE_AMOUNT = damageAmount
            set DAMAGE_SOURCE = damageSource
            set TRIGGER_UNIT = triggerUnit
            call RunTrigger( GetEventsById( damageSourceId, UnitTakesDamage_EVENT_KEY_FOR_DAMAGE_AS_DAMAGE_SOURCE, priority, iteration ) )
            set damageAmount = DAMAGE_AMOUNT
            set iteration = iteration - 1
        endloop
        set iteration = CountEventsById( damageSourceId, UnitTakesDamage_EVENT_KEY_AS_DAMAGE_SOURCE, priority )
        loop
            exitwhen ( iteration < TABLE_STARTED )
            set DAMAGE_SOURCE = damageSource
            set TRIGGER_UNIT = triggerUnit
            call RunTrigger( GetEventsById( damageSourceId, UnitTakesDamage_EVENT_KEY_AS_DAMAGE_SOURCE, priority, iteration ) )
            set iteration = iteration - 1
        endloop
        set iteration = CountEventsById( triggerUnitId, UnitTakesDamage_EVENT_KEY, priority )
        loop
            exitwhen ( iteration < TABLE_STARTED )
            set DAMAGE_SOURCE = damageSource
            set TRIGGER_UNIT = triggerUnit
            call RunTrigger( GetEventsById( triggerUnitId, UnitTakesDamage_EVENT_KEY, priority, iteration ) )
            set iteration = iteration - 1
        endloop
        set iteration = CountEventsById( damageSourceId, UnitTakesDamage_EVENT_KEY_UNBLOCKED_AS_DAMAGE_SOURCE, priority )
        loop
            exitwhen ( iteration < TABLE_STARTED )
            set DAMAGE_AMOUNT = damageAmount
            set DAMAGE_SOURCE = damageSource
            set TRIGGER_UNIT = triggerUnit
            call RunTrigger( GetEventsById( damageSourceId, UnitTakesDamage_EVENT_KEY_UNBLOCKED_AS_DAMAGE_SOURCE, priority, iteration ) )
            set iteration = iteration - 1
        endloop

        set DAMAGE_AMOUNT = damageAmount
        set DAMAGE_BLOCKED_AMOUNT = blocked
        set UNBLOCKABLE_DAMAGE_AMOUNT = unblockableDamageAmount
    endfunction

    private function TriggerEvents_Static takes integer blocked, real damageAmount, Unit damageSource, boolean isPrimaryTarget, integer priority, Unit triggerUnit, real unblockableDamageAmount returns nothing
        set blocked = blocked + B2I(BubbleArmor_Damage( triggerUnit ))
        if ( isPrimaryTarget ) then
            if (priority == 0) then
                //! runtextmacro AddEventStaticLineSet("unblockableDamageAmount", "AstralGauntlets", "EVENT_DAMAGE", "Damage( damageSource, unblockableDamageAmount, triggerUnit )")
                //! runtextmacro AddEventStaticLine("AttackDerivation", "EVENT_DAMAGE", "Damage( damageSource, damageAmount, triggerUnit )")
                //! runtextmacro AddEventStaticLine("Bash_OgreBrat_OgreBrat", "EVENT_DAMAGE", "Damage( damageSource, triggerUnit )")
                //! runtextmacro AddEventStaticLine("Bash_Zombie_Zombie", "EVENT_DAMAGE", "Damage( damageSource, triggerUnit )")
            endif
            if ( blocked == 0 ) then
                if (priority == 0) then
                    //! runtextmacro AddEventStaticLine("BloodyClaws", "EVENT_DAMAGE", "Damage( damageSource, damageAmount, triggerUnit )")
                endif
            endif
            if (priority == 0) then
                //! runtextmacro AddEventStaticLine("Disarm", "EVENT_DAMAGE", "Damage( damageSource, triggerUnit )")
                //! runtextmacro AddEventStaticLine("DivineArmor", "EVENT_DAMAGE", "Damage( damageSource, triggerUnit )")
                //! runtextmacro AddEventStaticLineSet("damageAmount", "EasyPrey_Arrow_Arrow", "EVENT_DAMAGE", "Damage( damageSource, damageAmount, triggerUnit )")
                //! runtextmacro AddEventStaticLine("Enchant", "EVENT_DAMAGE", "Damage( damageAmount, damageSource, triggerUnit )")
                //! runtextmacro AddEventStaticLine("EnergyGap_Heal_Heal", "EVENT_DAMAGE", "Damage( damageSource, damageAmount, triggerUnit )")
                //! runtextmacro AddEventStaticLine("FenixsFeather", "EVENT_DAMAGE", "Damage( damageSource, triggerUnit )")
                //! runtextmacro AddEventStaticLineSet("unblockableDamageAmount", "Feedback", "EVENT_DAMAGE", "Damage( damageSource, unblockableDamageAmount, triggerUnit )")
                //! runtextmacro AddEventStaticLine("FeelingOfSecurity", "EVENT_DAMAGE", "Damage( triggerUnit )")
                //! runtextmacro AddEventStaticLine("FrostArmor", "EVENT_DAMAGE", "Damage( triggerUnit, damageSource )")
                //! runtextmacro AddEventStaticLine("FrozenShard", "EVENT_DAMAGE", "Damage( damageSource, triggerUnit )")
                //! runtextmacro AddEventStaticLine("GiantAxe", "EVENT_DAMAGE", "Damage( damageAmount, damageSource, triggerUnit )")
                //! runtextmacro AddEventStaticLine("GloveOfTheBeast", "EVENT_DAMAGE", "Damage( damageSource, triggerUnit )")
                //! runtextmacro AddEventStaticLine("HealingPotionBloodOrange", "EVENT_DAMAGE", "Damage( damageSource, damageAmount, triggerUnit )")
                //! runtextmacro AddEventStaticLineSet("damageAmount", "IllusionaryStaff", "EVENT_DAMAGE", "Damage( damageSource, damageAmount, triggerUnit )")
                //! runtextmacro AddEventStaticLineSet("unblockableDamageAmount", "MysticalAttack", "EVENT_DAMAGE", "Damage( damageSource, unblockableDamageAmount, triggerUnit )")
                //! runtextmacro AddEventStaticLineSet("unblockableDamageAmount", "Neutralization", "EVENT_DAMAGE", "Damage( damageSource, unblockableDamageAmount, triggerUnit )")
                //! runtextmacro AddEventStaticLine("Pulverize", "EVENT_DAMAGE", "Damage( damageSource, damageAmount, triggerUnit )")
                //! runtextmacro AddEventStaticLine("Riposte_Target_Target", "EVENT_DAMAGE", "Damage( damageAmount, damageSource, triggerUnit )")
                //! runtextmacro AddEventStaticLine("SlowPoison", "EVENT_DAMAGE", "Damage( damageSource, triggerUnit )")
                //! runtextmacro AddEventStaticLine("StrongArm", "EVENT_DAMAGE", "Damage( damageSource, triggerUnit )")
                //! runtextmacro AddEventStaticLine("SuddenFrost", "EVENT_DAMAGE", "Damage( damageSource, triggerUnit )")
                //! runtextmacro AddEventStaticLine("Trident", "EVENT_DAMAGE", "Damage( damageSource, triggerUnit )")
                //! runtextmacro AddEventStaticLineSet("unblockableDamageAmount", "VividStrikes", "EVENT_DAMAGE", "Damage( damageSource, unblockableDamageAmount, triggerUnit )")
            endif
        endif
        if (priority == 0) then
            //! runtextmacro AddEventStaticLineSet("damageAmount", "Berserk", "EVENT_DAMAGE", "Damage( triggerUnit, damageAmount )")
            //! runtextmacro AddEventStaticLineSet("damageAmount", "Defend", "EVENT_DAMAGE", "Damage( triggerUnit, damageAmount, damageSource )")
            //! runtextmacro AddEventStaticLine("SummonFaust_AttackGraphic_AttackGraphic", "EVENT_DAMAGE", "Damage( damageSource.self, triggerUnit.self )")
            //! runtextmacro AddEventStaticLine("Meditation", "EVENT_DAMAGE", "Damage( triggerUnit )")
            //! runtextmacro AddEventStaticLine("ThermalFissure_Target_Target", "EVENT_DAMAGE", "Damage( triggerUnit )")
        endif
        if ( blocked == 0 ) then
            if (priority == 0) then
                //! runtextmacro AddEventStaticLine("CurseOfTheBloodline", "EVENT_DAMAGE", "Damage( damageAmount, triggerUnit, damageSource )")
            endif
        endif

        if ( isPrimaryTarget ) then
            if (priority == 1) then
                ////! runtextmacro AddEventStaticLineSet("damageAmount", "FriendshipBracelet_Buff_Buff_Damage", "EVENT_DAMAGE", "Damage( damageAmount, damageSource, triggerUnit )")
            endif
        endif

        set DAMAGE_AMOUNT = damageAmount
        set DAMAGE_BLOCKED_AMOUNT = blocked
        set UNBLOCKABLE_DAMAGE_AMOUNT = unblockableDamageAmount
    endfunction

    private function TriggerEvents takes real damageAmount, Unit damageSource, boolean isPrimaryTarget, Unit triggerUnit returns nothing
        local integer blocked = 0
        local integer iteration = 0
        local real unblockableDamageAmount = 0

        loop
            call TriggerEvents_Dynamic(blocked, damageAmount, damageSource, isPrimaryTarget, iteration, triggerUnit, unblockableDamageAmount)
            set blocked = DAMAGE_BLOCKED_AMOUNT
            set damageAmount = DAMAGE_AMOUNT
            set unblockableDamageAmount = UNBLOCKABLE_DAMAGE_AMOUNT
            call TriggerEvents_Static(blocked, damageAmount, damageSource, isPrimaryTarget, iteration, triggerUnit, unblockableDamageAmount)
            set blocked = DAMAGE_BLOCKED_AMOUNT
            set damageAmount = DAMAGE_AMOUNT
            set unblockableDamageAmount = UNBLOCKABLE_DAMAGE_AMOUNT
            set iteration = iteration + 1
            exitwhen (iteration > 0)
        endloop
    endfunction

    private function DealDamage takes Unit damageSource, UnitType damageSourceType, boolean isPrimaryTarget, real relativeDamage, Unit triggerUnit returns nothing
        local real armorAmount = GetUnitArmorTotal( triggerUnit )
        local real armorBreakRelative = GetUnitArmorBreakRelativeBonus(damageSource)
        local boolean causesDeath
        local real currentLife = GetUnitState( triggerUnit.self, UNIT_STATE_LIFE )
        local real damageAmount = GetUnitDamageTotal( damageSource )
        local integer damageDicesSides = GetUnitTypeDamageDicesSides( damageSourceType )
        local unit damageSourceSelf
        local real damageSourceX
        local real damageSourceY
        local boolean isNotBlocked = true
        local integer iteration = GetUnitTypeDamageDices( damageSourceType )
        local integer triggerUnitType = triggerUnit.type
        local real armorMultiplier = GetAttackMultiplier( GetUnitTypeDamageType( damageSourceType ), GetUnitTypeArmorType( triggerUnitType ) )
        if (armorAmount > 0) then
            set armorAmount = Max(0, armorAmount * (1 - armorBreakRelative))
        endif
        loop
            exitwhen ( iteration < 0 )
            set damageAmount = damageAmount + GetRandomInt( 1, damageDicesSides )
            set iteration = iteration - 1
        endloop
        if ( armorAmount < 0 ) then
            set damageAmount = damageAmount * ( 2 - Pow( ( 1 - ARMOR_REDUCTION_FACTOR ), -armorAmount ) )
        else
            set damageAmount = damageAmount / ( 1 + ARMOR_REDUCTION_FACTOR * armorAmount )
        endif
        if (armorMultiplier < 1) then
            set armorMultiplier = Max( 0, armorMultiplier * (1 - armorBreakRelative) )
        endif

        set damageAmount = damageAmount * armorMultiplier
        set damageAmount = damageAmount * ( 1 + GetUnitDamageRelativeBonus( damageSource ) - Max(0, GetUnitArmorRelativeBonus( triggerUnit ) - armorBreakRelative) )
        set damageAmount = damageAmount * relativeDamage

        call TriggerEvents(damageAmount, damageSource, isPrimaryTarget, triggerUnit)

        set damageAmount = DAMAGE_AMOUNT

        set damageAmount = Air_Damage( damageSource, damageAmount, triggerUnit )

        if ( damageAmount > 0 ) then
            if ( ( GetRandomReal( 0.01, 1 ) <= GetUnitCriticalStrike( damageSource ) - GetUnitCriticalStrikeDefense( triggerUnit ) ) and ( GetUnitCriticalStrikeImmunity( triggerUnit ) == 0 ) ) then
                set damageAmount = damageAmount * CRITICAL_STRIKE_DAMAGE_FACTOR
                set damageSourceSelf = damageSource.self
                set damageSourceX = GetUnitX(damageSourceSelf)
                set damageSourceY = GetUnitY(damageSourceSelf)
                call CreateRisingTextTag( I2S( R2I( damageAmount ) ) + "!", 0.026, damageSourceX, damageSourceY, GetUnitZ( damageSourceSelf, damageSourceX, damageSourceY ), 80, 255, 0, 0, 255, 0, 3 )
                set damageSourceSelf = null
            endif

            set isNotBlocked = (DAMAGE_BLOCKED_AMOUNT == 0)
            set causesDeath = ( ( damageAmount >= currentLife - LIMIT_OF_DEATH ) and isNotBlocked )
            if ( isNotBlocked ) then
                set damageAmount = damageAmount + UNBLOCKABLE_DAMAGE_AMOUNT
                call UnitDamageUnitEx( damageSource, triggerUnit, damageAmount, null )
            else
                call UnitDamageUnitEx( damageSource, triggerUnit, UNBLOCKABLE_DAMAGE_AMOUNT, null )
            endif
        endif
    endfunction

    private function SplashTargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( ( TEMP_BOOLEAN == false ) and ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_FLYING ) ) ) then
            return false
        endif
        if ( ( TEMP_BOOLEAN2 == false ) and ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) ) ) then
            return false
        endif
        if ( ( TEMP_BOOLEAN3 == false ) and ( IsUnitEnemy( FILTER_UNIT_SELF, TEMP_PLAYER ) ) ) then
            return false
        endif
        if ( ( TEMP_BOOLEAN4 == false ) and ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_GROUND ) ) ) then
            return false
        endif
        if ( GetUnitInvulnerability(GetUnit(FILTER_UNIT_SELF)) > 0 ) then
            return false
        endif
        return true
    endfunction

    scope ArtilleryAttack
        globals
            public trigger ArtilleryAttack_DUMMY_TRIGGER
        endglobals

        private function ArtilleryAttack_Trig takes nothing returns nothing
            local Unit damageSource = TRIGGER_UNIT
            local UnitType damageSourceType = damageSource.type
            local Unit enumUnit
            local unit enumUnitSelf
            local real targetX = TARGET_X
            local real targetY = TARGET_Y
            local real splashAreaRange = damageSourceType.splashAreaRange
            call DiversionShot_Damage( damageSource, targetX, targetY )
            set TEMP_UNIT = damageSource
            set TEMP_PLAYER = damageSource.owner
            set TEMP_BOOLEAN = damageSourceType.splashAffectionAir
            set TEMP_BOOLEAN2 = damageSourceType.splashAffectionAlly
            set TEMP_BOOLEAN3 = damageSourceType.splashAffectionEnemy
            set TEMP_BOOLEAN4 = damageSourceType.splashAffectionGround
            call GroupEnumUnitsInRangeWJ( ENUM_GROUP, targetX, targetY, splashAreaRange, SPLASH_TARGET_CONDITIONS )
            set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
            if (enumUnitSelf != null) then
                loop
                    set enumUnit = GetUnit(enumUnitSelf)
                    call GroupRemoveUnit( ENUM_GROUP, enumUnitSelf )
                    call DealDamage( damageSource, damageSourceType, false, ( 1 - DistanceByCoordinates( GetUnitX( enumUnitSelf ), GetUnitY( enumUnitSelf ), targetX, targetY ) / splashAreaRange ), enumUnit )
                    set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
                    exitwhen ( enumUnitSelf == null )
                endloop
            endif
        endfunction

        public function ArtilleryAttack_Init takes nothing returns nothing
            set ArtilleryAttack_DUMMY_TRIGGER = CreateTriggerWJ()
            call AddTriggerCode(ArtilleryAttack_DUMMY_TRIGGER, function ArtilleryAttack_Trig)
        endfunction
    endscope

    private function Trig takes nothing returns nothing
        local real attackAngle
        local real damageAmount
        local Unit damageSource
        local player damageSourceOwner
        local unit damageSourceSelf
        local UnitType damageSourceType
        local real damageSourceX
        local real damageSourceY
        local unit enumUnit
        local real enumUnitX
        local real enumUnitY
        local boolean hasSplash
        local real splashAreaRange
        local real splashDamageFactor
        local real splashWindowAngleHalf
        local Unit triggerUnit
        local unit triggerUnitSelf
        local real triggerUnitX
        local real triggerUnitY
        if ( NEXT_DAMAGE_IS_SPELL ) then
            set NEXT_DAMAGE_IS_SPELL = false
        else
            set damageAmount = GetEventDamage()
            if ( damageAmount != 0 ) then
                set damageSourceSelf = GetEventDamageSource()
                if ( damageSourceSelf != null ) then
                    set damageSource = GetUnit(damageSourceSelf)
                    set damageSourceType = damageSource.type
                    set triggerUnitSelf = GetTriggerUnit()
                    set triggerUnit = GetUnit(triggerUnitSelf)
                    if ( IsUnitTypeSpecialAttack(damageSourceType) ) then
                        call ArtilleryAttack_Damage( damageSource, triggerUnit )
                        call LightningAttack_Damage( damageSource, triggerUnit )
                        call LinearBoomerang_Damage( damageSource, triggerUnit )
                    else
                        set damageSourceOwner = damageSource.owner
                        call DealDamage( damageSource, damageSourceType, true, 1, triggerUnit )
                        if ( IsUnitTypeSplashForPlayer(damageSourceType, damageSourceOwner) ) then
                            set damageSourceX = GetUnitX( damageSourceSelf )
                            set damageSourceY = GetUnitY( damageSourceSelf )
                            set splashAreaRange = damageSourceType.splashAreaRange
                            set splashWindowAngleHalf = damageSourceType.splashWindowAngle / 2
                            set triggerUnitX = GetUnitX( triggerUnitSelf )
                            set triggerUnitY = GetUnitY( triggerUnitSelf )
                            set attackAngle = Atan2( triggerUnitY - damageSourceY, triggerUnitX - damageSourceX )
                            set TEMP_BOOLEAN = damageSourceType.splashAffectionAir
                            set TEMP_BOOLEAN2 = damageSourceType.splashAffectionAlly
                            set TEMP_BOOLEAN3 = damageSourceType.splashAffectionEnemy
                            set TEMP_BOOLEAN4 = damageSourceType.splashAffectionGround
                            set TEMP_PLAYER = damageSourceOwner
                            set TEMP_UNIT = damageSource
                            call GroupEnumUnitsInRangeWJ( ENUM_GROUP, triggerUnitX, triggerUnitY, splashAreaRange, SPLASH_TARGET_CONDITIONS )
                            set enumUnit = FirstOfGroup( ENUM_GROUP )
                            if (enumUnit != null) then
                                set splashDamageFactor = damageSourceType.splashDamageFactor
                                loop
                                    call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                                    if ( ( enumUnit != triggerUnitSelf ) and ( Absolute( Atan2( GetUnitY( enumUnit ) - damageSourceY, GetUnitX( enumUnit ) - damageSourceX ) - attackAngle ) <= splashWindowAngleHalf ) ) then
                                        call DealDamage( damageSource, damageSourceType, false, ( 1 - Pow( DistanceByCoordinates( GetUnitX( enumUnit ), GetUnitY( enumUnit ), triggerUnitX, triggerUnitY ) / splashAreaRange, 2 ) ) * splashDamageFactor, GetUnit(enumUnit) )
                                    endif
                                    set enumUnit = FirstOfGroup( ENUM_GROUP )
                                    exitwhen ( enumUnit == null )
                                endloop
                            endif
                        endif
                        set damageSourceOwner = null
                    endif
                    set damageSourceSelf = null
                    set triggerUnitSelf = null
                endif
            endif
        endif
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        set ENUM_GROUP = CreateGroupWJ()
        set SPLASH_TARGET_CONDITIONS = ConditionWJ(function SplashTargetConditions)
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
        call InitAbility(SPECIAL_ATTACK_SPELL_ID)
        call ArtilleryAttack_ArtilleryAttack_Init()
    endfunction
endscope