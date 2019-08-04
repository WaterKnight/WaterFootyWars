//TESH.scrollpos=568
//TESH.alwaysfold=0
//! runtextmacro Scope("IceBall")
    globals
        private constant integer ORDER_ID = 852075//OrderId( "slow" )
        public constant integer SPELL_ID = 'A003'

        private real array AREA_RANGE
        private constant string CASTER_EFFECT_PATH = "Abilities\\Spells\\Human\\Feedback\\SpellBreakerAttack.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "origin"
        private real array DAMAGE_LOW
        private real array DAMAGE_LOW_PER_AGILITY_POINT
        private real array DAMAGE_WIDTH
        private real array DAMAGE_WIDTH_PER_AGILITY_POINT
        private constant integer DUMMY_UNIT_ID = 'h00E'
        private group ENUM_GROUP
        private constant real HIT_RANGE = 32.
        private real array LENGTH
        private real array LENGTH_PER_AGILITY_POINT
        private constant integer LEVELS_AMOUNT = 5
        private constant real RISING_TIME = 0.25
        private boolexpr TARGET_CONDITIONS
        private constant real UPDATE_TIME = 0.01
        private constant real RISING_LENGTH = 400 * UPDATE_TIME
    endglobals

    private struct Data
        integer abilityLevel
        Unit caster
        real damageAmountLow
        real damageAmountWidth
        unit dummyUnit
        real length
        timer moveTimer
        timer riseTimer
        Unit target
        real targetX
        real targetY
        real targetZ
        real x
        real y
        real z
    endstruct

    private function TargetConditions takes nothing returns boolean
        local real filterUnitX
        local real filterUnitY
        set FILTER_UNIT_SELF = GetFilterUnit()
        set filterUnitX = GetUnitX( FILTER_UNIT_SELF )
        set filterUnitY = GetUnitY( FILTER_UNIT_SELF )
        set FILTER_UNIT = GetUnit(FILTER_UNIT_SELF)
        if ( DistanceByCoordinatesWithZ( filterUnitX, filterUnitY, GetUnitZ( FILTER_UNIT_SELF, filterUnitX, filterUnitY ) + GetUnitImpactZ(FILTER_UNIT), TEMP_REAL2, TEMP_REAL3, TEMP_REAL4 ) > TEMP_REAL ) then
            return false
        endif
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        if ( GetUnitInvulnerability( FILTER_UNIT ) > 0 ) then
            return false
        endif
        if ( GetUnitMagicImmunity( FILTER_UNIT ) > 0 ) then
            return false
        endif
        return true
    endfunction

    //! runtextmacro Scope("Buff")
        globals
            private real array Buff_BONUS_SPEED
            private constant real Buff_DAMAGE_SPEED_CAP_LOW = 250.
            private constant real Buff_DAMAGE_SPEED_CAP_WIDTH = 350 - Buff_DAMAGE_SPEED_CAP_LOW
            private real array Buff_DURATION
            private trigger Buff_EVENT_DISPEL
            private real array Buff_HERO_DURATION
            private constant string Buff_TARGET_EFFECT_PATH = "Abilities\\Spells\\Other\\FrostDamage\\FrostDamage.mdl"
            private constant string Buff_TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        endglobals

        private struct Buff_Data
            integer abilityLevel
            timer durationTimer
            Unit target
            effect targetEffect
        endstruct

        private function Buff_Ending takes Buff_Data d, timer durationTimer, Unit target returns nothing
            local integer abilityLevel = d.abilityLevel
            local integer targetId = target.id
            local effect targetEffect = d.targetEffect
            call d.destroy()
            call FlushAttachedInteger( durationTimer, Buff_SCOPE_ID )
            call DestroyTimerWJ( durationTimer )
            call FlushAttachedIntegerById( targetId, Buff_SCOPE_ID )
            //! runtextmacro RemoveEventById( "targetId", "Buff_EVENT_DEATH" )
            call DestroyEffectWJ(targetEffect)
            set targetEffect = null
            call AddUnitSpeedBonus( target, -Buff_BONUS_SPEED[abilityLevel] )
            call RemoveUnitFrostSlow(target)
        endfunction

        public function Buff_Dispel takes Unit target returns nothing
            local Buff_Data d = GetAttachedIntegerById( target.id, Buff_SCOPE_ID )
            if ( d != NULL ) then
                call Buff_Ending( d, d.durationTimer, target )
            endif
        endfunction

        private function Buff_Dispel_Event takes nothing returns nothing
            call Buff_Dispel( TRIGGER_UNIT )
        endfunction

        public function Buff_Death takes Unit target returns nothing
            call Buff_Dispel( target )
        endfunction

        private function Buff_Death_Event takes nothing returns nothing
            call Buff_Death( DYING_UNIT )
        endfunction

        private function Buff_EndingByTimer takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Buff_Data d = GetAttachedInteger(durationTimer, Buff_SCOPE_ID)
            set durationTimer = null
            call Buff_Ending( d, durationTimer, d.target )
        endfunction

        public function Buff_Start takes integer abilityLevel, Unit caster, player casterOwner, real damageAmountLow, real damageAmountWidth, real targetX, real targetY, real targetZ returns nothing
            local real areaRange = AREA_RANGE[abilityLevel]
            local real bonusSpeed
            local Buff_Data d
            local real damageAmount
            local real duration
            local timer durationTimer
            local Unit enumUnit
            local integer enumUnitId
            local unit enumUnitSelf
            local boolean isNew
            local integer oldAbilityLevel
            set TEMP_PLAYER = casterOwner
            set TEMP_REAL = areaRange
            set TEMP_REAL2 = targetX
            set TEMP_REAL3 = targetY
            set TEMP_REAL4 = targetZ
            call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, targetX, targetY, areaRange, TARGET_CONDITIONS )
            set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
            if ( enumUnitSelf != null ) then
                set bonusSpeed = Buff_BONUS_SPEED[abilityLevel]
                loop
                    set enumUnit = GetUnit(enumUnitSelf)
                    set damageAmount = damageAmountLow + Min( Max( GetUnitSpeed( enumUnit ) - Buff_DAMAGE_SPEED_CAP_LOW, 0 ), Buff_DAMAGE_SPEED_CAP_WIDTH ) / Buff_DAMAGE_SPEED_CAP_WIDTH * damageAmountWidth
                    set enumUnitId = enumUnit.id
                    set d = GetAttachedIntegerById( enumUnitId, Buff_SCOPE_ID )
                    set isNew = ( d == NULL )
                    call GroupRemoveUnit( ENUM_GROUP, enumUnitSelf )
                    if ( isNew ) then
                        set d = Buff_Data.create()
                        set durationTimer = CreateTimerWJ()
                        set d.durationTimer = durationTimer
                        set d.target = enumUnit
                        call AttachInteger( durationTimer, Buff_SCOPE_ID, d )
                        call AttachIntegerById( enumUnitId, Buff_SCOPE_ID, d )
                        //! runtextmacro AddEventById( "enumUnitId", "Buff_EVENT_DEATH" )
                    else
                        set durationTimer = d.durationTimer
                        set oldAbilityLevel = d.abilityLevel
                        call DestroyEffectWJ( d.targetEffect )
                    endif
                    set d.abilityLevel = abilityLevel
                    set d.targetEffect = AddSpecialEffectTargetWJ( Buff_TARGET_EFFECT_PATH, enumUnitSelf, Buff_TARGET_EFFECT_ATTACHMENT_POINT )
                    if ( isNew ) then
                        call AddUnitSpeedBonus( enumUnit, bonusSpeed )
                        call AddUnitFrostSlow(enumUnit)
                    else
                        call AddUnitSpeedBonus( enumUnit, bonusSpeed - Buff_BONUS_SPEED[oldAbilityLevel] )
                    endif
                    if ( IsUnitType( enumUnitSelf, UNIT_TYPE_HERO ) ) then
                        set duration = Buff_HERO_DURATION[abilityLevel]
                    else
                        set duration = Buff_DURATION[abilityLevel]
                    endif
                    call TimerStart( durationTimer, duration, false, function Buff_EndingByTimer )
                    call UnitDamageUnitBySpell( caster, enumUnit, damageAmount )
                    set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
                    exitwhen ( enumUnitSelf == null )
                endloop
                set durationTimer = null
            endif
        endfunction

        public function Buff_Init takes nothing returns nothing
            set Buff_BONUS_SPEED[1] = -100
            set Buff_BONUS_SPEED[2] = -100
            set Buff_BONUS_SPEED[3] = -100
            set Buff_BONUS_SPEED[4] = -100
            set Buff_BONUS_SPEED[5] = -100
            set Buff_DURATION[1] = 5
            set Buff_DURATION[2] = 7
            set Buff_DURATION[3] = 9
            set Buff_DURATION[4] = 10
            set Buff_DURATION[5] = 11
            set Buff_HERO_DURATION[1] = 1.2
            set Buff_HERO_DURATION[2] = 1.4
            set Buff_HERO_DURATION[3] = 1.6
            set Buff_HERO_DURATION[4] = 1.8
            set Buff_HERO_DURATION[5] = 2
            //! runtextmacro CreateEvent( "Buff_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Buff_Death_Event" )
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro Scope("FrostNova")
        globals
            private constant integer FrostNova_DUMMY_UNIT_ID = 'n029'
            private constant integer FrostNova_DUMMY_UNITS_AMOUNT = 4
            private constant real FrostNova_DURATION = 0.75
            private real array FrostNova_LENGTH
            private constant real FrostNova_TIME_SCALE = 2 / FrostNova_DURATION
            private constant real FrostNova_UPDATE_TIME = 0.035
            private constant integer FrostNova_WAVES_AMOUNT = R2I(FrostNova_DURATION / FrostNova_UPDATE_TIME)
        endglobals

        private struct FrostNova_Data
            unit array dummyUnits[FrostNova_DUMMY_UNITS_AMOUNT]
            integer iteration
            real length
            timer updateTimer
            real array x[FrostNova_DUMMY_UNITS_AMOUNT]
            real array y[FrostNova_DUMMY_UNITS_AMOUNT]
            real z
        endstruct

        private function FrostNova_Ending takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local FrostNova_Data d = GetAttachedInteger(durationTimer, FrostNova_SCOPE_ID)
            local unit array dummyUnits
            local integer iteration = FrostNova_DUMMY_UNITS_AMOUNT - 1
            local timer updateTimer = d.updateTimer
            loop
                set dummyUnits[iteration] = d.dummyUnits[iteration]
                set iteration = iteration - 1
                exitwhen ( iteration < 0 )
            endloop
            set iteration = FrostNova_DUMMY_UNITS_AMOUNT - 1
            call d.destroy()
            call FlushAttachedInteger( durationTimer, FrostNova_SCOPE_ID )
            call DestroyTimerWJ( durationTimer )
            set durationTimer = null
            loop
                call RemoveUnitWJ( dummyUnits[iteration] )
                set dummyUnits[iteration] = null
                set iteration = iteration - 1
                exitwhen ( iteration < 0 )
            endloop
            call FlushAttachedInteger(updateTimer, FrostNova_SCOPE_ID)
            call DestroyTimerWJ( updateTimer )
            set updateTimer = null
        endfunction

        private function FrostNova_Move takes nothing returns nothing
            local real currentAngle
            local unit dummyUnit
            local integer iteration = FrostNova_DUMMY_UNITS_AMOUNT - 1
            local timer updateTimer = GetExpiredTimer()
            local FrostNova_Data d = GetAttachedInteger(updateTimer, FrostNova_SCOPE_ID)
            local real length = d.length
            local real x
            local real y
            local real z = d.z
            set d.iteration = d.iteration + 1
            set updateTimer = null
            loop
                set currentAngle = PI / 2 * ( 0.5 + iteration )
                set dummyUnit = d.dummyUnits[iteration]
                set x = d.x[iteration] + length * Cos( currentAngle )
                set y = d.y[iteration] + length * Sin( currentAngle )
                set d.x[iteration] = x
                set d.y[iteration] = y
                call SetUnitX( dummyUnit, x )
                call SetUnitY( dummyUnit, y )
                call SetUnitZ( dummyUnit, x, y, z )
                set iteration = iteration - 1
                exitwhen ( iteration < 0 )
            endloop
            set dummyUnit = null
        endfunction

        public function FrostNova_Start takes integer abilityLevel, timer durationTimer, real targetX, real targetY, real targetZ returns nothing
            local FrostNova_Data d = FrostNova_Data.create()
            local unit dummyUnit
            local integer iteration = FrostNova_DUMMY_UNITS_AMOUNT - 1
            local timer updateTimer = CreateTimerWJ()
            set d.iteration = 0
            set d.length = FrostNova_LENGTH[abilityLevel]
            set d.updateTimer = updateTimer
            loop
                set dummyUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, FrostNova_DUMMY_UNIT_ID, targetX, targetY, PI / 2 * ( 0.5 + iteration ) )
                set d.dummyUnits[iteration] = dummyUnit
                set d.x[iteration] = targetX
                set d.y[iteration] = targetY
                call SetUnitTimeScale( dummyUnit, FrostNova_TIME_SCALE )
                call SetUnitZ( dummyUnit, targetX, targetY, targetZ )
                set iteration = iteration - 1
                exitwhen ( iteration < 0 )
            endloop
            set dummyUnit = null
            set d.z = targetZ
            call AttachInteger(durationTimer, FrostNova_SCOPE_ID, d)
            call AttachInteger(updateTimer, FrostNova_SCOPE_ID, d)
            call TimerStart( updateTimer, FrostNova_UPDATE_TIME, true, function FrostNova_Move )
            set updateTimer = null
            call TimerStart( durationTimer, FrostNova_DURATION, false, function FrostNova_Ending )
        endfunction

        public function FrostNova_Init takes nothing returns nothing
            local integer iteration = LEVELS_AMOUNT
            loop
                set FrostNova_LENGTH[iteration] = ( AREA_RANGE[iteration] + 115 ) / FrostNova_WAVES_AMOUNT
                set iteration = iteration - 1
                exitwhen (iteration < 1)
            endloop
            call InitUnitType( FrostNova_DUMMY_UNIT_ID )
        endfunction
    //! runtextmacro Endscope()

    private function Ending takes integer abilityLevel, Data d, unit dummyUnit, boolean isTargetNotNull, timer moveTimer, Unit target, real targetX, real targetY, real targetZ returns nothing
        local integer targetId = target.id
        call d.destroy()
        call FlushAttachedInteger( moveTimer, IceBall_SCOPE_ID )
        if ( isTargetNotNull ) then
            call RemoveIntegerFromTableById( targetId, IceBall_SCOPE_ID, d )
            if ( CountIntegersInTableById( targetId, IceBall_SCOPE_ID ) == TABLE_EMPTY ) then
                //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
            endif
        endif
        call SetUnitAnimationByIndex( dummyUnit, 1 )
        call RemoveUnitTimed( dummyUnit, 2 )
        call FrostNova_FrostNova_Start(abilityLevel, moveTimer, targetX, targetY, targetZ)
    endfunction

    private function Death_ResetTarget takes Data d, Unit target, real targetX, real targetY, real targetZ returns nothing
        local integer targetId = target.id
        set d.target = NULL
        call RemoveIntegerFromTableById( targetId, IceBall_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, IceBall_SCOPE_ID ) == TABLE_EMPTY ) then
            //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        endif
        set d.targetX = targetX
        set d.targetY = targetY
        set d.targetZ = targetZ
    endfunction

    public function Death takes Unit target, real targetX, real targetY, real targetZ returns nothing
        local integer targetId = target.id
        local integer iteration = CountIntegersInTableById( targetId, IceBall_SCOPE_ID )
        if ( iteration > TABLE_EMPTY ) then
            loop
                call Death_ResetTarget( GetIntegerFromTableById( targetId, IceBall_SCOPE_ID, iteration ), target, targetX, targetY, targetZ )
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

    private function Move takes nothing returns nothing
        local real angleLengthXYZ
        local real angleXY
        local real damageAmountLow
        local real damageAmountWidth
        local real distanceX
        local real distanceY
        local real distanceZ
        local unit enumUnit
        local real lengthXY
        local timer moveTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(moveTimer, IceBall_SCOPE_ID)
        local integer abilityLevel = d.abilityLevel
        local Unit caster = d.caster
        local player casterOwner = caster.owner
        local unit dummyUnit = d.dummyUnit
        local real length = d.length
        local boolean reachesTarget
        local Unit target = d.target
        local boolean isTargetNull = ( target == NULL )
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
            set targetSelf = null
        endif
        set reachesTarget = ( DistanceByCoordinatesWithZ( x, y, z, targetX, targetY, targetZ ) <= length )
        if ( reachesTarget ) then
            set x = targetX
            set y = targetY
            set z = targetZ
        else
            set distanceZ = targetZ - z
            set angleLengthXYZ = Atan2( distanceZ, DistanceByCoordinates( x, y, targetX, targetY ) )
            set distanceX = targetX - x
            set distanceY = targetY - y
            set angleXY = Atan2( distanceY, distanceX )
            set lengthXY = length * Cos( angleLengthXYZ )
            set x = x + lengthXY * Cos( angleXY )
            set y = y + lengthXY * Sin( angleXY )
            set z = z + length * Sin( angleLengthXYZ )
            call SetUnitFacingWJ( dummyUnit, angleXY )
        endif
        call SetUnitX( dummyUnit, x )
        call SetUnitY( dummyUnit, y )
        call SetUnitZ( dummyUnit, x, y, z )
        set TEMP_PLAYER = casterOwner
        set TEMP_REAL = AREA_RANGE[abilityLevel]
        set TEMP_REAL2 = x
        set TEMP_REAL3 = y
        set TEMP_REAL4 = z
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, x, y, HIT_RANGE, TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( ( enumUnit != null ) or ( reachesTarget ) ) then
            set damageAmountLow = d.damageAmountLow
            set damageAmountWidth = d.damageAmountWidth
            if ( enumUnit != null ) then
                set targetX = GetUnitX( enumUnit )
                set targetY = GetUnitY( enumUnit )
                set targetZ = GetUnitZ( enumUnit, targetX, targetY )
                set enumUnit = null
            endif
            call Ending( abilityLevel, d, dummyUnit, isTargetNull == false, moveTimer, target, targetX, targetY, targetZ )
            call Buff_Buff_Start( abilityLevel, caster, casterOwner, damageAmountLow, damageAmountWidth, targetX, targetY, targetZ )
        else
            set d.x = x
            set d.y = y
            set d.z = z
        endif
        set casterOwner = null
        set dummyUnit = null
        set moveTimer = null
    endfunction

    private function Rise_Ending takes nothing returns nothing
        local timer moveTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger( moveTimer, IceBall_SCOPE_ID )
        local timer riseTimer = d.riseTimer
        call FlushAttachedInteger( riseTimer, IceBall_SCOPE_ID )
        call DestroyTimerWJ( riseTimer )
        set riseTimer = null
        call TimerStart( moveTimer, UPDATE_TIME, true, function Move )
        set moveTimer = null
    endfunction

    private function Rise takes nothing returns nothing
        local timer riseTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger( riseTimer, IceBall_SCOPE_ID )
        local unit dummyUnit = d.dummyUnit
        local real z = d.z + d.length
        set riseTimer = null
        set d.z = z
        call SetUnitZ( dummyUnit, d.x, d.y, z )
        set dummyUnit = null
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local real casterAgility = GetHeroAgilityTotal( caster )
        local unit casterSelf = caster.self
        local integer abilityLevel = GetUnitAbilityLevel( casterSelf, SPELL_ID )
        local real casterX = GetUnitX(casterSelf)
        local real casterY = GetUnitY(casterSelf)
        local real casterZ = GetUnitZ( casterSelf, casterX, casterY ) + GetUnitOutpactZ(caster)
        local Data d = Data.create()
        local unit dummyUnit = CreateUnitWJ( caster.owner, DUMMY_UNIT_ID, casterX, casterY, GetUnitFacingWJ( casterSelf ) )
        local timer moveTimer = CreateTimerWJ()
        local timer riseTimer = CreateTimerWJ()
        local integer targetId = target.id
        call DestroyEffectWJ( AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, casterSelf, CASTER_EFFECT_ATTACHMENT_POINT ) )
        set casterSelf = null
        set d.abilityLevel = abilityLevel
        set d.caster = caster
        set d.damageAmountLow = DAMAGE_LOW[abilityLevel] + casterAgility * DAMAGE_LOW_PER_AGILITY_POINT[abilityLevel]
        set d.damageAmountWidth = DAMAGE_WIDTH[abilityLevel] + casterAgility * DAMAGE_WIDTH_PER_AGILITY_POINT[abilityLevel]
        set d.dummyUnit = dummyUnit
        set d.length = LENGTH[abilityLevel] + casterAgility * LENGTH_PER_AGILITY_POINT[abilityLevel]
        set d.moveTimer = moveTimer
        set d.riseTimer = riseTimer
        set d.target = target
        set d.x = casterX
        set d.y = casterY
        set d.z = casterZ
        call AttachInteger(moveTimer, IceBall_SCOPE_ID, d)
        call AttachInteger(riseTimer, IceBall_SCOPE_ID, d)
        call AddIntegerToTableById( targetId, IceBall_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, IceBall_SCOPE_ID ) == TABLE_STARTED ) then
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
        endif
        call SetUnitZ( dummyUnit, casterX, casterY, casterZ )
        set dummyUnit = null
        call TimerStart( riseTimer, UPDATE_TIME, true, function Rise )
        set riseTimer = null
        call TimerStart( moveTimer, RISING_TIME, false, function Rise_Ending )
        set moveTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT)
    endfunction

    public function Order takes Unit target returns string
        set TEMP_UNIT_SELF = target.self
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return ErrorStrings_NOT_MECHANICAL
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return ErrorStrings_NOT_STRUCTURE
        endif
        if ( GetUnitMagicImmunity( FILTER_UNIT ) > 0 ) then
            return ErrorStrings_TARGET_IS_MAGIC_IMMUNE
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( TARGET_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = LEVELS_AMOUNT
        set AREA_RANGE[1] = 200
        set AREA_RANGE[2] = 225
        set AREA_RANGE[3] = 250
        set AREA_RANGE[4] = 275
        set AREA_RANGE[5] = 300
        set DAMAGE_LOW[1] = 28
        set DAMAGE_LOW[2] = 36
        set DAMAGE_LOW[3] = 44
        set DAMAGE_LOW[4] = 52
        set DAMAGE_LOW[5] = 60
        set DAMAGE_LOW_PER_AGILITY_POINT[1] = 0.24
        set DAMAGE_LOW_PER_AGILITY_POINT[2] = 0.24
        set DAMAGE_LOW_PER_AGILITY_POINT[3] = 0.24
        set DAMAGE_LOW_PER_AGILITY_POINT[4] = 0.24
        set DAMAGE_LOW_PER_AGILITY_POINT[5] = 0.24
        set DAMAGE_WIDTH[1] = 50
        set DAMAGE_WIDTH[2] = 50
        set DAMAGE_WIDTH[3] = 50
        set DAMAGE_WIDTH[4] = 50
        set DAMAGE_WIDTH[5] = 50
        set DAMAGE_WIDTH_PER_AGILITY_POINT[1] = 0.4
        set DAMAGE_WIDTH_PER_AGILITY_POINT[2] = 0.4
        set DAMAGE_WIDTH_PER_AGILITY_POINT[3] = 0.4
        set DAMAGE_WIDTH_PER_AGILITY_POINT[4] = 0.4
        set DAMAGE_WIDTH_PER_AGILITY_POINT[5] = 0.4
        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        set LENGTH[1] = 450
        set LENGTH[2] = 450
        set LENGTH[3] = 450
        set LENGTH[4] = 450
        set LENGTH[5] = 450
        set LENGTH_PER_AGILITY_POINT[1] = 0
        set LENGTH_PER_AGILITY_POINT[2] = 0
        set LENGTH_PER_AGILITY_POINT[3] = 0
        set LENGTH_PER_AGILITY_POINT[4] = 0
        set LENGTH_PER_AGILITY_POINT[5] = 0
        loop
            set DAMAGE_WIDTH[iteration] = DAMAGE_WIDTH[iteration] - DAMAGE_LOW[iteration]
            set DAMAGE_WIDTH_PER_AGILITY_POINT[iteration] = DAMAGE_WIDTH_PER_AGILITY_POINT[iteration] - DAMAGE_LOW_PER_AGILITY_POINT[iteration]
            set LENGTH[iteration] = LENGTH[iteration] * UPDATE_TIME
            set LENGTH_PER_AGILITY_POINT[iteration] = LENGTH_PER_AGILITY_POINT[iteration] * UPDATE_TIME
            set iteration = iteration - 1
            exitwhen (iteration < 1)
        endloop
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( CASTER_EFFECT_PATH )
        call InitUnitType( DUMMY_UNIT_ID )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call FrostNova_FrostNova_Init()
        call Buff_Buff_Init()
    endfunction
//! runtextmacro Endscope()