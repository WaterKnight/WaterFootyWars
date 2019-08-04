//TESH.scrollpos=213
//TESH.alwaysfold=0
//! runtextmacro Scope("SpellDisconnection")
    private struct Data
        integer abilityLevel
        Unit caster
        unit dummyUnit
        real duration
        integer gold
        integer goldPerBuff
        real heroDuration
        integer jumpsAmount
        timer moveTimer
        Unit target
        real targetX
        real targetY
        real targetZ
        group targetGroup
        boolean targetsAreAllied
        real x
        real y
        real z
    endstruct

    globals
        private constant integer ORDER_ID = 852665//OrderId( "transmute" )
        public constant integer SPELL_ID = 'A01X'

        private constant real AREA_RANGE = 500
        private trigger CHOOSE_TRIGGER
        private constant real DAMAGE_SUMMON = 400.
        private constant integer DUMMY_UNIT_ID = 'h00K'
        private real array DURATION
        private real array DURATION_PER_INTELLIGENCE_POINT
        private group ENUM_GROUP
        private group ENUM_GROUP2
        private integer array GOLD
        private integer array GOLD_PER_INTELLIGENCE_POINT
        private integer array GOLD_PER_BUFF
        private integer array GOLD_PER_BUFF_PER_INTELLIGENCE_POINT
        private real array HERO_DURATION
        private real array HERO_DURATION_PER_INTELLIGENCE_POINT
        private integer array MAX_TARGETS_AMOUNT
        private constant real SPEED = 400.
        private boolexpr TARGET_CONDITIONS
        private constant real UPDATE_TIME = 0.035
        private constant real LENGTH = SPEED * UPDATE_TIME

        private Data chooseTriggerD
    endglobals

    private function Ending takes Data d, unit dummyUnit, timer moveTimer, group targetGroup returns nothing
        call d.destroy()
        call SetUnitAnimationByIndex( dummyUnit, 2 )
        call RemoveUnitTimed( dummyUnit, 1 )
        call FlushAttachedReal( moveTimer, SpellDisconnection_SCOPE_ID )
        call DestroyTimerWJ( moveTimer )
        call DestroyGroupWJ( targetGroup )
    endfunction

    private function EndTarget takes Data d, Unit target returns nothing
        local integer targetId = target.id
        call RemoveIntegerFromTableById( targetId, SpellDisconnection_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, SpellDisconnection_SCOPE_ID ) == TABLE_EMPTY ) then
            //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        endif
    endfunction

    private function Death_ResetTarget takes Data d, Unit target, real targetX, real targetY, real targetZ returns nothing
        set d.target = NULL
        set d.targetX = targetX
        set d.targetY = targetY
        set d.targetZ = targetZ
        call EndTarget(d, target)
    endfunction

    public function Death takes Unit target, real targetX, real targetY, real targetZ returns nothing
        local integer targetId = target.id
        local integer iteration = CountIntegersInTableById( targetId, SpellDisconnection_SCOPE_ID )
        if ( iteration > TABLE_EMPTY ) then
            loop
                call Death_ResetTarget( GetIntegerFromTableById( targetId, SpellDisconnection_SCOPE_ID, iteration ), target, targetX, targetY, targetZ )
                set iteration = iteration - 1
                exitwhen ( iteration < TABLE_STARTED )
            endloop
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        local unit dyingUnitSelf = DYING_UNIT.self
        local real dyingUnitX = GetUnitX(dyingUnitSelf)
        local real dyingUnitY = GetUnitY(dyingUnitSelf)
        call Death( DYING_UNIT, dyingUnitX, dyingUnitY, GetUnitZ(dyingUnitSelf, dyingUnitX, dyingUnitY) )
        set dyingUnitSelf = null
    endfunction

    private function TargetConditions_Single takes Unit checkingUnit, boolean targetsAreAllied returns string
        set TEMP_UNIT_SELF = checkingUnit.self
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_MECHANICAL ) and ( targetsAreAllied == false ) ) then
            return ErrorStrings_NOT_ENEMY_MECHANICAL
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return ErrorStrings_NOT_STRUCTURE
        endif
        if ( GetUnitInvulnerability( checkingUnit ) > 0 ) then
            return ErrorStrings_TARGET_IS_INVULNERABLE
        endif
        if ( IsUnitWard( checkingUnit ) ) then
            return ErrorStrings_NOT_WARD
        endif
        return null
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) != TEMP_BOOLEAN ) then
            return false
        endif
        if ( IsUnitInGroup( FILTER_UNIT_SELF, TEMP_GROUP ) ) then
            return false
        endif
        if ( TargetConditions_Single( GetUnit(FILTER_UNIT_SELF), TEMP_BOOLEAN ) != null ) then
            return false
        endif
        return true
    endfunction

    private function Move takes nothing returns nothing
        local integer abilityLevel
        local real angleXY
        local real angleYZ
        local Unit caster
        local player casterOwner
        local real distance
        local texttag dropTextTag
        local real duration
        local unit enumUnit
        local boolean found
        local integer gold
        local integer goldPerBuff
        local integer jumpsAmount
        local real lengthXY
        local timer moveTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(moveTimer, SpellDisconnection_SCOPE_ID)
        local unit dummyUnit = d.dummyUnit
        local boolean reachesTarget
        local Unit target = d.target
        local boolean isTargetNull = (target == NULL)
        local boolean targetsAreAllied
        local boolean targetsAreNotAllied
        local unit targetSelf
        local real targetX
        local real targetY
        local real targetZ
        local real x = d.x
        local real y = d.y
        local real z = d.z
        if ( isTargetNull ) then
            set targetX = d.targetX
            set targetY = d.targetY
            set targetZ = d.targetZ
        else
            set targetSelf = target.self
            set targetX = GetUnitX( targetSelf )
            set targetY = GetUnitY( targetSelf )
            set targetZ = GetUnitZ( targetSelf, targetX, targetY ) + GetUnitImpactZ(target)
        endif
        set distance = DistanceByCoordinatesWithZ( x, y, z, targetX, targetY, targetZ )
        set reachesTarget = ( distance <= LENGTH )
        if ( reachesTarget ) then
            set x = targetX
            set y = targetY
            set z = targetZ
        else
            set angleXY = Atan2( targetX - x, DistanceByCoordinates( y, z, targetY, targetZ ) )
            set angleYZ = Atan2( targetZ - z, targetY - y )
            set lengthXY = Cos( angleXY )
            set x = x + LENGTH * Sin( angleXY )
            set y = y + LENGTH * Cos( angleYZ ) * lengthXY
            set z = z + LENGTH * Sin( angleYZ ) * lengthXY
        endif
        call SetUnitX( dummyUnit, x )
        call SetUnitY( dummyUnit, y )
        call SetUnitZ( dummyUnit, x, y, z )
        if ( reachesTarget ) then
            set abilityLevel = d.abilityLevel
            set caster = d.caster
            set casterOwner = caster.owner
            set gold = d.gold
            set goldPerBuff = d.goldPerBuff
            set jumpsAmount = d.jumpsAmount + 1
            set targetsAreAllied = d.targetsAreAllied
            if ( jumpsAmount >= MAX_TARGETS_AMOUNT[abilityLevel] ) then
                call Ending( d, dummyUnit, moveTimer, d.targetGroup )
            else
                set d.x = x
                set d.y = y
                set d.z = z
                set chooseTriggerD = d
                call RunTrigger(CHOOSE_TRIGGER)
            endif
            if (isTargetNull == false) then
                call EndTarget(d, target)
                if ( TargetConditions_Single( target, targetsAreAllied ) == null ) then
                    set targetsAreNotAllied = ( targetsAreAllied == false )
                    call PlaySoundFromTypeAtPosition( SPELL_DISCONNECTION_IMPACT_SOUND_TYPE, x, y, z )
                    if ( targetsAreAllied ) then
                        set gold = gold + R2I( CountUnitDispelableBuffs( target, targetsAreNotAllied, targetsAreAllied ) * goldPerBuff )
                        set dropTextTag = CreateRisingTextTag( "+" + I2S( gold ), 0.023, targetX, targetY, targetZ, 80, 255, 204, 0, 255, 0, 3 )
                        call AddPlayerState( casterOwner, PLAYER_STATE_RESOURCE_GOLD, gold )
                        if ( dropTextTag != null ) then
                            call LimitTextTagVisibilityToPlayer( dropTextTag, casterOwner )
                            set dropTextTag = null
                        endif
                    else
                        if ( IsUnitIllusionWJ( target ) ) then
                            call KillUnit( targetSelf )
                        else
                            call DispelUnit( target, targetsAreAllied, targetsAreNotAllied, true )
                            if ( targetsAreNotAllied ) then
                                if ( IsUnitType( targetSelf, UNIT_TYPE_HERO ) ) then
                                    set duration = HERO_DURATION[abilityLevel]
                                else
                                    set duration = DURATION[abilityLevel]
                                endif
                                call SetUnitStunTimed( target, 1, duration )
                            endif
                            if (IsUnitType( targetSelf, UNIT_TYPE_SUMMONED )) then
                                call UnitDamageUnitBySpell(caster, target, DAMAGE_SUMMON)
                            endif
                        endif
                    endif
                endif
            endif
            set casterOwner = null
        else
            set d.x = x
            set d.y = y
            set d.z = z
        endif
        set dummyUnit = null
        set moveTimer = null
        set targetSelf = null
    endfunction

    private function StartTarget takes Data d, Unit target, group targetGroup returns nothing
        local integer targetId = target.id
        set d.target = target
        call AddIntegerToTableById( targetId, SpellDisconnection_SCOPE_ID, d )
        if (CountIntegersInTableById(targetId, SpellDisconnection_SCOPE_ID) == TABLE_STARTED) then
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
        endif
        call GroupAddUnit( targetGroup, target.self )
    endfunction

    private function ChooseTrig takes nothing returns nothing
        local Data d = chooseTriggerD
        local Unit caster = d.caster
        local integer currentDispelableBuffsAmount
        local unit enumUnit
        local integer enumUnitDispelableBuffsAmount
        local boolean found
        local group targetGroup = d.targetGroup
        local boolean targetsAreAllied = d.targetsAreAllied
        local boolean targetsAreNotAllied
        local real x = d.x
        local real y = d.y
        set TEMP_BOOLEAN = targetsAreAllied
        set TEMP_GROUP = targetGroup
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, x, y, AREA_RANGE, TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit == null ) then
            call Ending( d, d.dummyUnit, d.moveTimer, targetGroup )
        else
            set found = false
            set targetsAreNotAllied = (targetsAreAllied == false)
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                call GroupAddUnit( ENUM_GROUP2, enumUnit )
                set enumUnitDispelableBuffsAmount = CountUnitDispelableBuffs( GetUnit(enumUnit), targetsAreNotAllied, targetsAreAllied )
                if ( found == false ) then
                    set currentDispelableBuffsAmount = enumUnitDispelableBuffsAmount
                    set found = true
                elseif ( enumUnitDispelableBuffsAmount > currentDispelableBuffsAmount ) then
                    set currentDispelableBuffsAmount = enumUnitDispelableBuffsAmount
                endif
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
            loop
                set enumUnit = FirstOfGroup( ENUM_GROUP2 )
                exitwhen ( enumUnit == null )
                call GroupRemoveUnit( ENUM_GROUP2, enumUnit )
                if ( CountUnitDispelableBuffs( GetUnit(enumUnit), targetsAreNotAllied, targetsAreAllied ) == currentDispelableBuffsAmount ) then
                    call GroupAddUnit( ENUM_GROUP, enumUnit )
                endif
            endloop
            set enumUnit = GetNearestUnit( ENUM_GROUP, x, y )
            call StartTarget(d, GetUnit(enumUnit), targetGroup)
            set d.jumpsAmount = d.jumpsAmount + 1
            set enumUnit = null
        endif
        set targetGroup = null
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local real casterIntelligence = GetHeroIntelligenceTotal( caster )
        local unit casterSelf = caster.self
        local integer abilityLevel = GetUnitAbilityLevel( casterSelf, SPELL_ID )
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local real casterZ = GetUnitZ( casterSelf, casterX, casterY ) + GetUnitOutpactZ(caster)
        local Data d = Data.create()
        local timer moveTimer = CreateTimerWJ()
        local group targetGroup = CreateGroupWJ()
        local unit targetSelf = target.self
        local real targetX = GetUnitX( targetSelf )
        local real targetY = GetUnitY( targetSelf )
        local real angle = Atan2( targetY - casterY, targetX - casterX )
        local unit dummyUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, DUMMY_UNIT_ID, casterX, casterY, angle )
        set d.abilityLevel = abilityLevel
        set d.caster = caster
        set d.dummyUnit = dummyUnit
        set d.duration = DURATION[abilityLevel] + casterIntelligence * DURATION_PER_INTELLIGENCE_POINT[abilityLevel]
        set d.gold = R2I( GOLD[abilityLevel] + casterIntelligence * GOLD_PER_INTELLIGENCE_POINT[abilityLevel] )
        set d.goldPerBuff = R2I( GOLD_PER_BUFF[abilityLevel] + casterIntelligence * GOLD_PER_BUFF_PER_INTELLIGENCE_POINT[abilityLevel] )
        set d.heroDuration = HERO_DURATION[abilityLevel] + casterIntelligence * HERO_DURATION_PER_INTELLIGENCE_POINT[abilityLevel]
        set d.jumpsAmount = 0
        set d.moveTimer = moveTimer
        set d.targetGroup = targetGroup
        set d.targetsAreAllied = IsUnitAlly( targetSelf, caster.owner )
        set targetSelf = null
        set d.x = casterX
        set d.y = casterY
        set d.z = casterZ
        call AttachInteger( moveTimer, SpellDisconnection_SCOPE_ID, d )
        call StartTarget(d, target, targetGroup)
        set targetGroup = null
        call SetUnitZ( dummyUnit, casterX, casterY, casterZ )
        set dummyUnit = null
        call PlaySoundFromTypeAtPosition( SPELL_DISCONNECTION_LAUNCH_SOUND_TYPE, casterX, casterY, GetUnitZ( casterSelf, casterX, casterY ) )
        set casterSelf = null
        call TimerStart( moveTimer, UPDATE_TIME, true, function Move )
        set moveTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    public function Order takes Unit caster, player casterOwner, Unit target returns string
        return TargetConditions_Single( target, IsUnitAlly( target.self, casterOwner ) )
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( ORDERED_UNIT, ORDERED_UNIT.owner, TARGET_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        set CHOOSE_TRIGGER = CreateTriggerWJ()
        set DURATION[1] = 5
        set DURATION[2] = 5
        set DURATION_PER_INTELLIGENCE_POINT[1] = 0.03
        set DURATION_PER_INTELLIGENCE_POINT[2] = 0.03
        set ENUM_GROUP = CreateGroupWJ()
        set ENUM_GROUP2 = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        set GOLD[1] = 10
        set GOLD[2] = 20
        set GOLD_PER_INTELLIGENCE_POINT[1] = 0
        set GOLD_PER_INTELLIGENCE_POINT[2] = 0
        set GOLD_PER_BUFF[1] = 20
        set GOLD_PER_BUFF[2] = 20
        set GOLD_PER_BUFF_PER_INTELLIGENCE_POINT[1] = 0
        set GOLD_PER_BUFF_PER_INTELLIGENCE_POINT[2] = 0
        set HERO_DURATION[1] = 4
        set HERO_DURATION[2] = 4
        set HERO_DURATION_PER_INTELLIGENCE_POINT[1] = 0.02
        set HERO_DURATION_PER_INTELLIGENCE_POINT[2] = 0.02
        set MAX_TARGETS_AMOUNT[1] = 6
        set MAX_TARGETS_AMOUNT[2] = 8
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call AddTriggerCode(CHOOSE_TRIGGER, function ChooseTrig)
        call InitUnitType( DUMMY_UNIT_ID )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()