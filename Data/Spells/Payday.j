//TESH.scrollpos=515
//TESH.alwaysfold=0
//! runtextmacro Scope("Payday")
    globals
        private constant integer ORDER_ID = 852520//OrderId( "taunt" )
        public constant integer SPELL_ID = 'A030'

        private real array AREA_RANGE
        private real array AREA_RANGE_PER_AGILITY_POINT
        private real array DURATION
        private group ENUM_GROUP
        private real array INTERVAL
        private constant integer LEVELS_AMOUNT = 5
        private integer array MAX_TARGETS_AMOUNT
        private boolexpr TARGET_CONDITIONS
        private integer array WAVES_AMOUNT
    endglobals

    private struct Data
        integer abilityLevel
        real areaRange
        Unit caster
        timer durationTimer
        timer intervalTimer
    endstruct

    private function TargetConditions_Single takes player casterOwner, Unit checkingUnit returns boolean
        set TEMP_UNIT_SELF = checkingUnit.self
        if ( GetUnitState( TEMP_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( TEMP_UNIT_SELF, casterOwner ) ) then
            return false
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        if ( GetUnitInvulnerability( checkingUnit ) > 0 ) then
            return false
        endif
        if ( GetUnitMagicImmunity( checkingUnit ) > 0 ) then
            return false
        endif
        if ( IsUnitWard( checkingUnit ) ) then
            return false
        endif
        return true
    endfunction

    private function TargetConditions takes nothing returns boolean
        if ( TargetConditions_Single( TEMP_PLAYER, GetUnit(GetFilterUnit()) ) == false ) then
            return false
        endif
        return true
    endfunction

    //! runtextmacro Scope("AttackSilence")
        globals
            private group AttackSilence_ENUM_GROUP
            private group AttackSilence_ENUM_GROUP2
            private boolexpr AttackSilence_TARGET_CONDITIONS
            private constant real AttackSilence_UPDATE_TIME = 0.1
        endglobals

        private struct AttackSilence_Data
            Data d
            group targetGroup
            timer updateTimer
        endstruct

        private function AttackSilence_GetCasterData takes Unit caster returns AttackSilence_Data
            return GetAttachedIntegerById(caster.id, AttackSilence_SCOPE_ID)
        endfunction

        //! runtextmacro Scope("Target")
            globals
                private constant string Target_TARGET_EFFECT_PATH = "Abilities\\Spells\\Undead\\Sleep\\SleepTarget.mdl"
                private constant string Target_TARGET_EFFECT_ATTACHMENT_POINT = "hand left"
                private constant string Target_TARGET_EFFECT_ATTACHMENT_POINT2 = "hand right"
            endglobals

            private struct Target_Data
                group casterGroup
                AttackSilence_Data d
                effect targetEffect
                effect targetEffect2
            endstruct

            private function Target_Ending takes Unit caster, group casterGroup, Target_Data d, Unit target, group targetGroup returns nothing
                local effect targetEffect
                local effect targetEffect2
                local integer targetId
                call GroupRemoveUnit( casterGroup, caster.self )
                call GroupRemoveUnit( targetGroup, target.self )
                if (FirstOfGroup(casterGroup) == null) then
                    set targetEffect = d.targetEffect
                    set targetEffect2 = d.targetEffect2
                    set targetId = target.id
                    call d.destroy()
                    call DestroyGroupWJ(casterGroup)
                    call FlushAttachedIntegerById( targetId, Target_SCOPE_ID )
                    //! runtextmacro RemoveEventById( "targetId", "Target_EVENT_DEATH" )
                    call DestroyEffectWJ( targetEffect )
                    set targetEffect = null
                    call DestroyEffectWJ( targetEffect2 )
                    set targetEffect2 = null
                    call RemoveUnitAttackSilence( target )
                endif
            endfunction

            public function Target_EndingByEnding takes Unit caster, Unit target, group targetGroup returns nothing
                local Target_Data e = GetAttachedIntegerById(target.id, Target_SCOPE_ID)
                call Target_Ending(caster, e.casterGroup, e, target, targetGroup)
            endfunction

            public function Target_EndingByUpdate takes Unit caster, Unit target, group targetGroup returns nothing
                local Target_Data e = GetAttachedIntegerById(target.id, Target_SCOPE_ID)
                call Target_Ending(caster, e.casterGroup, e, target, targetGroup)
            endfunction

            public function Target_Death takes Unit target returns nothing
                local Unit caster
                local group casterGroup
                local AttackSilence_Data d
                local Target_Data e = GetAttachedIntegerById(target.id, Target_SCOPE_ID)
                local integer iteration
                if (e != NULL) then
                    set casterGroup = e.casterGroup
                    set iteration = CountUnits(casterGroup)
                    loop
                        set caster = GetUnit(FirstOfGroup(casterGroup))
                        set d = AttackSilence_GetCasterData(caster)
                        call Target_Ending(caster, casterGroup, e, target, d.targetGroup)
                        set iteration = iteration - 1
                        exitwhen (iteration < 1)
                    endloop
                    set casterGroup = null
                endif
            endfunction

            private function Target_Death_Event takes nothing returns nothing
                call Target_Death( DYING_UNIT )
            endfunction

            public function Target_Start takes Unit caster, Unit target returns nothing
                local group casterGroup
                local integer targetId = target.id
                local Target_Data d = GetAttachedIntegerById(targetId, Target_SCOPE_ID)
                local unit targetSelf
                if ( d == NULL ) then
                    set casterGroup = CreateGroupWJ()
                    set targetSelf = target.self
                    set d = Target_Data.create()
                    set d.casterGroup = casterGroup
                    set d.targetEffect = AddSpecialEffectTargetWJ( Target_TARGET_EFFECT_PATH, targetSelf, Target_TARGET_EFFECT_ATTACHMENT_POINT )
                    set d.targetEffect2 = AddSpecialEffectTargetWJ( Target_TARGET_EFFECT_PATH, targetSelf, Target_TARGET_EFFECT_ATTACHMENT_POINT2 )
                    set targetSelf = null
                    call AttachIntegerById( targetId, Target_SCOPE_ID, d )
                    //! runtextmacro AddEventById( "targetId", "Target_EVENT_DEATH" )
                    call AddUnitAttackSilence( target )
                endif
                call GroupAddUnit(casterGroup, caster.self)
                set casterGroup = null
            endfunction

            public function Target_Init takes nothing returns nothing
                //! runtextmacro CreateEvent( "Target_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Target_Death_Event" )
                call InitEffectType( Target_TARGET_EFFECT_PATH )
            endfunction
        //! runtextmacro Endscope()

        public function AttackSilence_Ending takes Unit caster returns nothing
            local AttackSilence_Data d = AttackSilence_GetCasterData(caster)
            local unit enumUnit
            local group targetGroup = d.targetGroup
            local timer updateTimer = d.updateTimer
            call d.destroy()
            set targetGroup = d.targetGroup
            call FlushAttachedIntegerById(caster.id, AttackSilence_SCOPE_ID)
            loop
                set enumUnit = FirstOfGroup( targetGroup )
                exitwhen ( enumUnit == null )
                call Target_Target_EndingByEnding( caster, GetUnit(enumUnit), targetGroup )
            endloop
            call DestroyGroupWJ( targetGroup )
            set targetGroup = null
            call FlushAttachedInteger( updateTimer, AttackSilence_SCOPE_ID )
            call DestroyTimerWJ( updateTimer )
            set updateTimer = null
        endfunction

        private function AttackSilence_TargetConditions takes nothing returns boolean
            if ( TargetConditions_Single( TEMP_PLAYER, GetUnit(GetFilterUnit()) ) == false ) then
                return false
            endif
            return true
        endfunction

        private function AttackSilence_Update takes real areaRange, Unit caster, group targetGroup returns nothing
            local unit casterSelf = caster.self
            local unit enumUnit
            set TEMP_PLAYER = caster.owner
            call GroupEnumUnitsInRangeWithCollision( AttackSilence_ENUM_GROUP, GetUnitX(casterSelf), GetUnitY(casterSelf), areaRange, AttackSilence_TARGET_CONDITIONS )
            set casterSelf = null
            set enumUnit = FirstOfGroup( targetGroup )
            if ( enumUnit != null ) then
                loop
                    if ( IsUnitInGroup( enumUnit, AttackSilence_ENUM_GROUP ) == false ) then
                        call Target_Target_EndingByUpdate( caster, GetUnit(enumUnit), targetGroup )
                    else
                        call GroupRemoveUnit( AttackSilence_ENUM_GROUP, enumUnit )
                        call GroupRemoveUnit( targetGroup, enumUnit )
                        call GroupAddUnit( AttackSilence_ENUM_GROUP2, enumUnit )
                    endif
                    set enumUnit = FirstOfGroup( targetGroup )
                    exitwhen ( enumUnit == null )
                endloop
                set enumUnit = FirstOfGroup( AttackSilence_ENUM_GROUP2 )
                loop
                    call GroupRemoveUnit( AttackSilence_ENUM_GROUP2, enumUnit )
                    call GroupAddUnit( targetGroup, enumUnit )
                    set enumUnit = FirstOfGroup( AttackSilence_ENUM_GROUP2 )
                    exitwhen ( enumUnit == null )
                endloop
            endif
            set enumUnit = FirstOfGroup( AttackSilence_ENUM_GROUP )
            if ( enumUnit != null ) then
                loop
                    call GroupRemoveUnit( AttackSilence_ENUM_GROUP, enumUnit )
                    call GroupAddUnit( targetGroup, enumUnit )
                    call Target_Target_Start(caster, GetUnit(enumUnit))
                    set enumUnit = FirstOfGroup( AttackSilence_ENUM_GROUP )
                    exitwhen ( enumUnit == null )
                endloop
            endif
        endfunction

        private function AttackSilence_UpdateByTimer takes nothing returns nothing
            local timer updateTimer = GetExpiredTimer()
            local AttackSilence_Data e = GetAttachedInteger(updateTimer, AttackSilence_SCOPE_ID)
            local Data d = e.d
            set updateTimer = null
            call AttackSilence_Update( d.areaRange, d.caster, e.targetGroup )
        endfunction

        public function AttackSilence_Start takes real areaRange, Unit caster, Data d returns nothing
            local AttackSilence_Data e = AttackSilence_Data.create()
            local group targetGroup = CreateGroupWJ()
            local timer updateTimer = CreateTimerWJ()
            set e.d = d
            set e.targetGroup = targetGroup
            set e.updateTimer = updateTimer
            call AttachIntegerById(caster.id, AttackSilence_SCOPE_ID, e)
            call AttachInteger( updateTimer, AttackSilence_SCOPE_ID, e )
            call TimerStart( updateTimer, AttackSilence_UPDATE_TIME, true, function AttackSilence_UpdateByTimer )
            call AttackSilence_Update( areaRange, caster, targetGroup )
            set targetGroup = null
            set updateTimer = null
        endfunction

        public function AttackSilence_Init takes nothing returns nothing
            set AttackSilence_ENUM_GROUP = CreateGroupWJ()
            set AttackSilence_ENUM_GROUP2 = CreateGroupWJ()
            set AttackSilence_TARGET_CONDITIONS = ConditionWJ( function AttackSilence_TargetConditions )
            call Target_Target_Init()
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro Scope("Missile")
        globals
            private constant string Missile_CASTER_EFFECT_PATH = "UI\\Feedback\\GoldCredit\\GoldCredit.mdl"
            private constant string Missile_CASTER_EFFECT_ATTACHMENT_POINT = "origin"
            private integer array Missile_DROP
            private constant real Missile_DROP_TEXT_TAG_Z_OFFESET = 100.
            private constant integer Missile_DUMMY_UNIT_ID = 'n011'
            private constant real Missile_SPEED = 600.
            private constant string Missile_TARGET_EFFECT_PATH = "Abilities\\Spells\\Items\\ResourceItems\\ResourceEffectTarget.mdl"
            private constant string Missile_TARGET_EFFECT_ATTACHMENT_POINT = "origin"
            private constant real Missile_UPDATE_TIME = 0.035
            private constant real Missile_LENGTH = Missile_SPEED * Missile_UPDATE_TIME
        endglobals

        private struct Missile_Data
            integer abilityLevel
            Unit caster
            unit dummyUnit
            timer durationTimer
            real length
            timer moveTimer
            real x
            real y
            real z
        endstruct

        private function Missile_Ending takes Unit caster, Missile_Data d, unit dummyUnit, timer moveTimer returns nothing
            call RemoveIntegerFromTableById( caster.id, Missile_SCOPE_ID, d )
            call d.destroy()
            call SetUnitAnimationByIndex( dummyUnit, 2 )
            call RemoveUnitTimed( dummyUnit, 1 )
            call FlushAttachedInteger( moveTimer, Missile_SCOPE_ID )
            call DestroyTimerWJ( moveTimer )
        endfunction

        public function Missile_EndingByEnding takes Unit caster returns nothing
            local integer casterId = caster.id
            local Missile_Data d
            local integer iteration = CountIntegersInTableById(casterId, Missile_SCOPE_ID)
            if (iteration > TABLE_EMPTY) then
                loop
                    set d = GetIntegerFromTableById( casterId, Missile_SCOPE_ID, iteration )
                    call Missile_Ending( caster, d, d.dummyUnit, d.moveTimer )
                    set iteration = iteration - 1
                    exitwhen ( iteration < TABLE_STARTED )
                endloop
            endif
        endfunction

        private function Missile_GiveBounty takes Unit caster, Missile_Data d, integer drop, real dropTextTagX, real dropTextTagY, real dropTextTagZ, unit dummyUnit, timer moveTimer returns nothing
            local player casterOwner = caster.owner
            local texttag dropTextTag = CreateRisingTextTag( "+" + I2S( drop ), 0.02, dropTextTagX, dropTextTagY, dropTextTagZ, 80, 255, 204, 0, 255, 0, 1 )
            call Missile_Ending(caster, d, dummyUnit, moveTimer)
            call DestroyEffectWJ( AddSpecialEffectTargetWJ( Missile_CASTER_EFFECT_PATH, caster.self, Missile_CASTER_EFFECT_PATH ) )
            call AddPlayerState( casterOwner, PLAYER_STATE_RESOURCE_GOLD, drop )
            if ( dropTextTag != null ) then
                call LimitTextTagVisibilityToPlayer( dropTextTag, casterOwner )
                set dropTextTag = null
            endif
            set casterOwner = null
            call PlaySoundFromTypeAtPosition( RECEIVE_GOLD_SOUND_TYPE, dropTextTagX, dropTextTagY, dropTextTagZ )
        endfunction

        private function Missile_Move takes nothing returns nothing
            local real angleLengthXYZ
            local real angleXY
            local real distanceX
            local real distanceY
            local real distanceZ
            local real lengthXY
            local timer moveTimer = GetExpiredTimer()
            local Missile_Data d = GetAttachedInteger(moveTimer, Missile_SCOPE_ID)
            local Unit caster = d.caster
            local real casterMissileAngle
            local unit casterSelf = caster.self
            local real casterX = GetUnitX( casterSelf )
            local real casterY = GetUnitY( casterSelf )
            local real casterZ = GetUnitZ( casterSelf, casterX, casterY ) + GetUnitImpactZ(caster)
            local unit dummyUnit = d.dummyUnit
            local real x = d.x
            local real y = d.y
            local real z = d.z
            local boolean reachesCaster = ( DistanceByCoordinatesWithZ( x, y, z, casterX, casterY, casterZ ) <= Missile_LENGTH )
            set casterSelf = null
            if ( reachesCaster ) then
                set casterMissileAngle = Atan2( y - casterY, x - casterX )
                set x = casterX
                set y = casterY
                set z = casterZ
            else
                set distanceZ = casterZ - z
                set angleLengthXYZ = Atan2( distanceZ, DistanceByCoordinates( x, y, casterX, casterY ) )
                set distanceX = casterX - x
                set distanceY = casterY - y
                set angleXY = Atan2( distanceY, distanceX )
                set lengthXY = Missile_LENGTH * Cos( angleLengthXYZ )
                set x = x + lengthXY * Cos( angleXY )
                set y = y + lengthXY * Sin( angleXY )
                set z = z + Missile_LENGTH * Sin( angleLengthXYZ )
                call SetUnitFacingWJ( dummyUnit, angleXY )
            endif
            call SetUnitX( dummyUnit, x )
            call SetUnitY( dummyUnit, y )
            call SetUnitZ( dummyUnit, x, y, z )
            if ( reachesCaster ) then
                call Missile_GiveBounty( caster, d, Missile_DROP[d.abilityLevel], casterX + Missile_DROP_TEXT_TAG_Z_OFFESET * Cos( casterMissileAngle ), casterY + Missile_DROP_TEXT_TAG_Z_OFFESET * Sin( casterMissileAngle ), casterZ + GetUnitOutpactZ(caster), dummyUnit, moveTimer )
            else
                set d.x = x
                set d.y = y
                set d.z = z
            endif
            set dummyUnit = null
            set moveTimer = null
        endfunction

        public function Missile_Start takes integer abilityLevel, Unit caster, real casterX, real casterY, Unit target returns nothing
            local Missile_Data d = Missile_Data.create()
            local timer moveTimer = CreateTimerWJ()
            local unit targetSelf = target.self
            local real targetX = GetUnitX( targetSelf )
            local real targetY = GetUnitY( targetSelf )
            local unit dummyUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, Missile_DUMMY_UNIT_ID, targetX, targetY, Atan2( targetY - casterY, targetX - casterX ) )
            local real targetZ = GetUnitZ( targetSelf, targetX, targetY ) + GetUnitOutpactZ(target)
            set d.abilityLevel = abilityLevel
            set d.caster = caster
            set d.dummyUnit = dummyUnit
            set d.moveTimer = moveTimer
            set d.x = targetX
            set d.y = targetY
            set d.z = targetZ
            call AddIntegerToTableById(caster.id, Missile_SCOPE_ID, d)
            call AttachInteger( moveTimer, Missile_SCOPE_ID, d )
            call SetUnitZ( dummyUnit, targetX, targetY, targetZ )
            set dummyUnit = null
            call DestroyEffectWJ( AddSpecialEffectTargetWJ( Missile_TARGET_EFFECT_PATH, targetSelf, Missile_TARGET_EFFECT_ATTACHMENT_POINT ) )
            set targetSelf = null
            call TimerStart( moveTimer, Missile_UPDATE_TIME, true, function Missile_Move )
            set moveTimer = null
        endfunction

        public function Missile_Init takes nothing returns nothing
            set Missile_DROP[1] = 5
            set Missile_DROP[2] = 8
            call InitUnitType( Missile_DUMMY_UNIT_ID )
            call InitEffectType( Missile_CASTER_EFFECT_PATH )
        endfunction
    //! runtextmacro Endscope()

    private function Ending takes Unit caster, Data d returns nothing
        local timer durationTimer = d.durationTimer
        local timer intervalTimer = d.intervalTimer
        call d.destroy()
        call FlushAttachedIntegerById( caster.id, Payday_SCOPE_ID )
        call FlushAttachedInteger( durationTimer, Payday_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call FlushAttachedInteger( intervalTimer, Payday_SCOPE_ID )
        call DestroyTimerWJ( intervalTimer )
        set intervalTimer = null
        call AttackSilence_AttackSilence_Ending( caster )
        call Missile_Missile_EndingByEnding(caster)
    endfunction

    public function EndCast takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, Payday_SCOPE_ID)
        if ( d != NULL ) then
            call Ending( caster, d )
        endif
    endfunction

    private function EndCast_Event takes nothing returns nothing
        call EndCast( CASTER )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, Payday_SCOPE_ID)
        set durationTimer = null
        call IssueImmediateOrderById( d.caster.self, STOP_ORDER_ID )
    endfunction

    private function Interval takes integer abilityLevel, real areaRange, Unit caster, Data d returns nothing
        local unit casterSelf = caster.self
        local real casterX = GetUnitX(casterSelf)
        local real casterY = GetUnitY(casterSelf)
        local Unit enumUnit
        local unit enumUnitSelf
        local integer iteration
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, casterX, casterY, areaRange, TARGET_CONDITIONS )
        set casterSelf = null
        set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
        if ( enumUnitSelf != null ) then
            set iteration = MAX_TARGETS_AMOUNT[abilityLevel]
            loop
                set enumUnit = GetUnit(enumUnitSelf)
                call GroupRemoveUnit( ENUM_GROUP, enumUnitSelf )
                if ( IsUnitIllusionWJ( enumUnit ) ) then
                    call KillUnit( enumUnitSelf )
                else
                    call Missile_Missile_Start(abilityLevel, caster, casterX, casterY, enumUnit)
                endif
                set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnitSelf == null )
                set iteration = iteration - 1
                exitwhen ( iteration < 1 )
            endloop
            if (iteration > 0) then
                set enumUnitSelf = null
            endif
        endif
    endfunction

    private function IntervalByTimer takes nothing returns nothing
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, Payday_SCOPE_ID)
        set intervalTimer = null
        call Interval( d.abilityLevel, d.areaRange, d.caster, d )
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local integer abilityLevel = GetUnitAbilityLevel( caster.self, SPELL_ID )
        local real areaRange = AREA_RANGE[abilityLevel] + GetHeroAgilityTotal( caster ) * AREA_RANGE_PER_AGILITY_POINT[abilityLevel]
        local Data d = Data.create()
        local timer durationTimer = CreateTimerWJ()
        local timer intervalTimer = CreateTimerWJ()
        set d.abilityLevel = abilityLevel
        set d.areaRange = areaRange
        set d.caster = caster
        set d.durationTimer = durationTimer
        set d.intervalTimer = intervalTimer
        call AttachIntegerById( caster.id, Payday_SCOPE_ID, d )
        call AttachInteger( durationTimer, Payday_SCOPE_ID, d )
        call AttachInteger( intervalTimer, Payday_SCOPE_ID, d )
        call TimerStart( intervalTimer, INTERVAL[abilityLevel], true, function IntervalByTimer )
        set intervalTimer = null
        call TimerStart( durationTimer, DURATION[abilityLevel], false, function EndingByTimer )
        set durationTimer = null
        call Interval( abilityLevel, areaRange, caster, d )
        call AttackSilence_AttackSilence_Start( areaRange, caster, d )
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = LEVELS_AMOUNT
        set AREA_RANGE[1] = 400
        set AREA_RANGE[2] = 400
        set AREA_RANGE_PER_AGILITY_POINT[1] = 5
        set AREA_RANGE_PER_AGILITY_POINT[2] = 5
        set INTERVAL[1] = 0.35
        set INTERVAL[2] = 0.35
        set ENUM_GROUP = CreateGroupWJ()
        set MAX_TARGETS_AMOUNT[1] = 4
        set MAX_TARGETS_AMOUNT[2] = 6
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        set WAVES_AMOUNT[1] = 18
        set WAVES_AMOUNT[2] = 18
        loop
            set DURATION[iteration] = INTERVAL[iteration] * (WAVES_AMOUNT[iteration] + 0.5)
            set iteration = iteration - 1
            exitwhen (iteration < 1)
        endloop
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ENDCAST", "SPELL_ID", "UnitFinishesCasting_EVENT_KEY", "0", "function EndCast_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call AttackSilence_AttackSilence_Init()
        call Missile_Missile_Init()
    endfunction
//! runtextmacro Endscope()