//TESH.scrollpos=334
//TESH.alwaysfold=0
//! runtextmacro Scope("KittyJump")
    globals
        private constant integer ORDER_ID = 852525//OrderId( "blink" )
        public constant integer SPELL_ID = 'A01W'

        private real array ACCELERATION_Z
        private real array DAMAGE
        private real array DAMAGE_PER_STRENGTH_POINT
        private real array DAMAGE_PER_INTERVAL
        private real array DAMAGE_PER_INTERVAL_PER_AGILITY_POINT
        private real array DURATION
        private group ENUM_GROUP
        private constant real HEIGHT = 234.375
        private constant real HIT_HEIGHT = 64.
        private constant real HIT_RADIUS = 224.
        private real array LENGTH_Z_ADD
        private real array LENGTH_Z_START
        private constant integer LEVELS_AMOUNT = 5
        private constant real MINIMUM_RANGE = 500.
        private constant string SPECIAL_EFFECT_PATH = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"
        private boolexpr TARGET_CONDITIONS
        private constant real UPDATE_TIME = 0.035
        private integer array WAVES_AMOUNT
    endglobals

    private struct Data
        integer abilityLevel
        Unit caster
        real damageAmount
        real damagePerIntervalAmount
        real lengthX
        real lengthY
        real lengthZ
        group targetGroup
        timer updateTimer
    endstruct

    private function Ending takes Unit caster, real casterX, real casterY, real casterZ, Data d returns nothing
        local integer casterId = caster.id
        local unit casterSelf = caster.self
        local group targetGroup = d.targetGroup
        local timer updateTimer = d.updateTimer
        call d.destroy()
        call FlushAttachedIntegerById( casterId, KittyJump_SCOPE_ID )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_ORDER2" )
        call DestroyGroupWJ( targetGroup )
        set targetGroup = null
        call FlushAttachedInteger( updateTimer, KittyJump_SCOPE_ID )
        call DestroyTimerWJ( updateTimer )
        set updateTimer = null
        call AddUnitPathing( caster )
        call RemoveUnitSilence( caster )
        call SetUnitPosition( casterSelf, casterX, casterY )
        call SetUnitZ( casterSelf, casterX, casterY, -99999 )
        set casterSelf = null
        call PlaySoundFromTypeAtPosition( KITTY_JUMP_ENDING_SOUND_TYPE, casterX, casterY, casterZ )
    endfunction

    public function MoveCheck takes Unit caster, real casterX, real casterY, real casterZ returns nothing
        local Data d = GetAttachedIntegerById( caster.id, KittyJump_SCOPE_ID)
        if ( d != NULL ) then
            if ( casterZ <= GetFloorHeight( casterX, casterY ) ) then
                call Ending(caster, casterX, casterY, casterZ, d)
            endif
        endif
    endfunction

    //! runtextmacro Scope("Target")
        globals
            public real array Target_DAMAGE_PER_INTERVAL
            public real array Target_DAMAGE_PER_INTERVAL_PER_AGILITY_POINT
            private real array Target_DURATION
            private constant real Target_INTERVAL = 1.
            private constant string Target_TARGET_EFFECT_ATTACHMENT_POINT = "chest"
            private integer array Target_WAVES_AMOUNT
        endglobals

        private struct Target_Data
            integer abilityLevel
            Unit array caster[LEVELS_AMOUNT]
            real array damagePerIntervalAmount[LEVELS_AMOUNT]
            timer array durationTimer[LEVELS_AMOUNT]
            timer intervalTimer
            Unit target
        endstruct

        private function Target_DealDamage takes nothing returns nothing
            local timer intervalTimer = GetExpiredTimer()
            local Target_Data d = GetAttachedInteger(intervalTimer, Target_SCOPE_ID)
            local integer abilityLevel = d.abilityLevel - 1
            local Unit target = d.target
            set intervalTimer = null
            call DestroyEffectWJ( AddSpecialEffectTargetWJ( GetUnitBlood( target ), target.self, Target_TARGET_EFFECT_ATTACHMENT_POINT ) )
            call UnitDamageUnitEx( d.caster[abilityLevel], target, d.damagePerIntervalAmount[abilityLevel], null )
        endfunction

        private function Target_Ending takes Target_Data d, timer durationTimer, Unit target returns nothing
            local integer abilityLevel = d.abilityLevel
            local timer intervalTimer
            local integer iteration = abilityLevel - 1
            local integer targetId
            loop
                exitwhen (durationTimer == d.durationTimer[iteration])
                set iteration = iteration - 1
            endloop
            set d.durationTimer[iteration] = null
            if ( abilityLevel - 1 <= iteration ) then
                loop
                    exitwhen (iteration < 0)
                    exitwhen (d.durationTimer[iteration] != null)
                    set iteration = iteration - 1
                endloop
                if ( iteration > -1 ) then
                    set d.abilityLevel = iteration + 1
                else
                    set intervalTimer = d.intervalTimer
                    set targetId = target.id
                    call d.destroy()
                    call DestroyTimerWJ(intervalTimer)
                    set intervalTimer = null
                    call FlushAttachedIntegerById( targetId, Target_SCOPE_ID )
                    //! runtextmacro RemoveEventById( "targetId", "Target_EVENT_DEATH" )
                endif
            endif
            call FlushAttachedInteger( durationTimer, Target_SCOPE_ID )
            call DestroyTimerWJ( durationTimer )
        endfunction

        public function Target_Death takes Unit target returns nothing
            local Target_Data d = GetAttachedIntegerById(target.id, Target_SCOPE_ID)
            local timer durationTimer
            local integer iteration
            if (d != NULL) then
                set iteration = 0
                loop
                    set durationTimer = d.durationTimer[iteration]
                    if ( durationTimer != null ) then
                        call Target_Ending( d, durationTimer, target )
                    endif
                    set iteration = iteration + 1
                    exitwhen ( iteration >= LEVELS_AMOUNT )
                endloop
                set durationTimer = null
            endif
        endfunction

        private function Target_Death_Event takes nothing returns nothing
            call Target_Death( DYING_UNIT )
        endfunction

        private function Target_EndingByTimer takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Target_Data d = GetAttachedInteger(durationTimer, Target_SCOPE_ID)
            call Target_Ending( d, durationTimer, d.target )
            set durationTimer = null
        endfunction

        public function Target_Start takes integer abilityLevel, Unit caster, real damagePerIntervalAmount, Unit target returns nothing
            local timer durationTimer
            local timer intervalTimer
            local integer iteration
            local integer oldAbilityLevel
            local integer targetId = target.id
            local Target_Data d = GetAttachedIntegerById(targetId, Target_SCOPE_ID)
            local boolean isNew = (d == NULL)
            local unit targetSelf = target.self
            if ( isNew ) then
                set d = Target_Data.create()
                set durationTimer = CreateTimerWJ()
                set intervalTimer = CreateTimerWJ()
                set iteration = LEVELS_AMOUNT - 1
                set d.abilityLevel = abilityLevel
                set d.intervalTimer = intervalTimer
                loop
                    if (iteration == abilityLevel - 1) then
                        set d.caster[iteration] = caster
                        set d.durationTimer[iteration] = durationTimer
                    else
                        set d.caster[iteration] = NULL
                        set d.durationTimer[iteration] = null
                    endif
                    set iteration = iteration - 1
                    exitwhen (iteration < 0)
                endloop
                set d.target = target
                call AttachInteger(durationTimer, Target_SCOPE_ID, d)
                call AttachInteger(intervalTimer, Target_SCOPE_ID, d)
                call AttachIntegerById(targetId, Target_SCOPE_ID, d)
                //! runtextmacro AddEventById( "targetId", "Target_EVENT_DEATH" )
            else
                set durationTimer = d.durationTimer[abilityLevel - 1]
                set d.caster[abilityLevel - 1] = caster
                if (durationTimer == null) then
                    set durationTimer = CreateTimerWJ()
                    set d.durationTimer[abilityLevel - 1] = durationTimer
                    call AttachInteger(durationTimer, Target_SCOPE_ID, d)
                endif
                set oldAbilityLevel = d.abilityLevel
            endif
            set d.damagePerIntervalAmount[abilityLevel - 1] = damagePerIntervalAmount
            if ( isNew ) then
                call TimerStart(intervalTimer, Target_INTERVAL, true, function Target_DealDamage)
                set intervalTimer = null
            elseif (abilityLevel > oldAbilityLevel) then
                set d.abilityLevel = abilityLevel
            endif
            call DestroyEffectWJ( AddSpecialEffectWJ( GetUnitBloodExplosion( target ), GetUnitX( targetSelf ), GetUnitY( targetSelf ) ) )
            set targetSelf = null
            call TimerStart( durationTimer, Target_DURATION[abilityLevel], false, function Target_EndingByTimer )
            set durationTimer = null
        endfunction

        public function Target_Init takes nothing returns nothing
            local integer iteration = LEVELS_AMOUNT
            set DAMAGE_PER_INTERVAL[1] = 48
            set DAMAGE_PER_INTERVAL[2] = 63
            set DAMAGE_PER_INTERVAL[3] = 80
            set DAMAGE_PER_INTERVAL[4] = 99
            set DAMAGE_PER_INTERVAL[5] = 120
            set DAMAGE_PER_INTERVAL_PER_AGILITY_POINT[1] = 0.5
            set DAMAGE_PER_INTERVAL_PER_AGILITY_POINT[2] = 0.5
            set DAMAGE_PER_INTERVAL_PER_AGILITY_POINT[3] = 0.5
            set DAMAGE_PER_INTERVAL_PER_AGILITY_POINT[4] = 0.5
            set DAMAGE_PER_INTERVAL_PER_AGILITY_POINT[5] = 0.5
            set Target_DURATION[1] = 6
            set Target_DURATION[2] = 7
            set Target_DURATION[3] = 8
            set Target_DURATION[4] = 9
            set Target_DURATION[5] = 10
            loop
                set Target_WAVES_AMOUNT[iteration] = R2I(Target_DURATION[iteration] / Target_INTERVAL)
                set DAMAGE_PER_INTERVAL[iteration] = DAMAGE_PER_INTERVAL[iteration] / Target_WAVES_AMOUNT[iteration]
                set DAMAGE_PER_INTERVAL_PER_AGILITY_POINT[iteration] = DAMAGE_PER_INTERVAL_PER_AGILITY_POINT[iteration] / Target_WAVES_AMOUNT[iteration]
                set iteration = iteration - 1
                exitwhen (iteration < 1)
            endloop
            //! runtextmacro CreateEvent( "Target_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Target_Death_Event" )
        endfunction
    //! runtextmacro Endscope()

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( Absolute( TEMP_REAL - GetUnitZ( FILTER_UNIT_SELF, GetUnitX( FILTER_UNIT_SELF ), GetUnitY( FILTER_UNIT_SELF ) ) ) > HIT_RADIUS ) then
            return false
        endif
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) ) then
            return false
        endif
        if ( IsUnitInGroup( FILTER_UNIT_SELF, TEMP_GROUP ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        if ( GetUnitInvulnerability( GetUnit(FILTER_UNIT_SELF) ) > 0 ) then
            return false
        endif
        return true
    endfunction

    private function Move takes nothing returns nothing
        local real damageAmount
        local real damagePerIntervalAmount
        local Unit enumUnit
        local unit enumUnitSelf
        local timer updateTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(updateTimer, KittyJump_SCOPE_ID)
        local integer abilityLevel = d.abilityLevel
        local Unit caster = d.caster
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local real casterZ = GetUnitZ( casterSelf, casterX, casterY )
        local real lengthZ = d.lengthZ + LENGTH_Z_ADD[abilityLevel]
        local real newX = casterX + d.lengthX
        local real newY = casterY + d.lengthY
        local real floorZ = GetFloorHeight( newX, newY )
        local real newZ = casterZ + lengthZ
        local group targetGroup = d.targetGroup
        set updateTimer = null
        set d.lengthZ = lengthZ
        if ( casterZ < floorZ ) then
            set newX = casterX
            set newY = casterY
            set floorZ = GetFloorHeight( newX, newY )
        else
            call SetUnitX( casterSelf, newX )
            call SetUnitY( casterSelf, newY )
        endif
        call SetUnitFlyHeight(casterSelf, newZ - floorZ, 0)
        set casterSelf = null
        if ( Absolute( newZ - floorZ ) <= HIT_HEIGHT ) then
            call DestroyEffectWJ( AddSpecialEffectWJ( SPECIAL_EFFECT_PATH, newX, newY ) )
        endif
        set TEMP_GROUP = targetGroup
        set TEMP_PLAYER = caster.owner
        set TEMP_REAL = casterZ
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, newX, newY, HIT_RADIUS, TARGET_CONDITIONS )
        set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
        if ( enumUnitSelf != null ) then
            set damageAmount = d.damageAmount
            set damagePerIntervalAmount = d.damagePerIntervalAmount
            loop
                set enumUnit = GetUnit(enumUnitSelf)
                call GroupRemoveUnit( ENUM_GROUP, enumUnitSelf )
                call GroupAddUnit( targetGroup, enumUnitSelf )
                call Target_Target_Start(abilityLevel, caster, damagePerIntervalAmount, enumUnit)
                call UnitDamageUnitBySpell( caster, enumUnit, damageAmount )
                set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnitSelf == null )
            endloop
            call PlaySoundFromTypeAtPosition( KITTY_JUMP_SLICE_SOUND_TYPE, newX, newY, newZ )
        endif
        set targetGroup = null
        call CheckMoveEvents( caster, newX, newY, newZ )
    endfunction

    public function SpellEffect takes Unit caster, real targetX, real targetY returns nothing
        local real angle
        local integer casterId = caster.id
        local unit casterSelf = caster.self
        local integer abilityLevel = GetUnitAbilityLevel( casterSelf, SPELL_ID )
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local Data d = Data.create()
        local real distance = DistanceByCoordinates( casterX, casterY, targetX, targetY )
        local real lengthXY = distance / DURATION[abilityLevel] * UPDATE_TIME
        local timer updateTimer = CreateTimerWJ()
        if ( ( casterX != targetX ) or ( casterY != targetY ) ) then
            set angle = Atan2( targetY - casterY, targetX - casterX )
        else
            set angle = GetUnitFacingWJ( casterSelf )
        endif
        set d.abilityLevel = abilityLevel
        set d.caster = caster
        set d.damageAmount = DAMAGE[abilityLevel] + GetHeroStrengthTotal(caster) * DAMAGE_PER_STRENGTH_POINT[abilityLevel]
        set d.damagePerIntervalAmount = Target_Target_DAMAGE_PER_INTERVAL[abilityLevel] + GetHeroAgilityTotal(caster) * Target_Target_DAMAGE_PER_INTERVAL_PER_AGILITY_POINT[abilityLevel]
        set d.lengthX = lengthXY * Cos(angle)
        set d.lengthY = lengthXY * Sin(angle)
        set d.lengthZ = LENGTH_Z_START[abilityLevel]
        set d.targetGroup = CreateGroupWJ()
        set d.updateTimer = updateTimer
        call AttachIntegerById(casterId, KittyJump_SCOPE_ID, d)
        //! runtextmacro AddEventById( "casterId", "EVENT_ORDER2" )
        call AttachInteger(updateTimer, KittyJump_SCOPE_ID, d)
        call RemoveUnitPathing( caster )
        call AddUnitSilence( caster )
        call PlaySoundFromTypeAtPosition( KITTY_JUMP_START_SOUND_TYPE, casterX, casterY, GetUnitZ( casterSelf, casterX, casterY ) )
        set casterSelf = null
        call TimerStart( updateTimer, UPDATE_TIME, true, function Move )
        set updateTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_X, TARGET_Y )
    endfunction

    public function Order2 takes Unit caster returns string
        if ( GetAttachedIntegerById(caster.id, KittyJump_SCOPE_ID) != NULL ) then
            return ""
        endif
        return null
    endfunction

    private function Order2_Event takes nothing returns nothing
        set ERROR_MSG = Order2( ORDERED_UNIT )
    endfunction

    public function Order takes real casterX, real casterY, real targetX, real targetY returns string
        if ( DistanceByCoordinates( casterX, casterY, targetX, targetY ) < MINIMUM_RANGE ) then
            return ErrorStrings_TARGET_TOO_CLOSE
        endif
        if ( IsTerrainPathable( targetX, targetY, PATHING_TYPE_WALKABILITY ) ) then
            return ErrorStrings_INVALID_TARGET
        endif
        if ( IsPointInPlayRegion(targetX, targetY) == false ) then
            return ErrorStrings_INVALID_TARGET
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        local unit casterSelf = ORDERED_UNIT.self
        set ERROR_MSG = Order( GetUnitX(casterSelf), GetUnitY(casterSelf), TARGET_X, TARGET_Y )
        set casterSelf = null
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = LEVELS_AMOUNT
        set ACCELERATION_Z[1] = -8
        set ACCELERATION_Z[2] = -8
        set ACCELERATION_Z[3] = -8
        set ACCELERATION_Z[4] = -8
        set ACCELERATION_Z[5] = -8
        set DAMAGE[1] = 25
        set DAMAGE[2] = 30
        set DAMAGE[3] = 35
        set DAMAGE[4] = 40
        set DAMAGE[5] = 45
        set DAMAGE_PER_STRENGTH_POINT[1] = 0
        set DAMAGE_PER_STRENGTH_POINT[2] = 0
        set DAMAGE_PER_STRENGTH_POINT[3] = 0
        set DAMAGE_PER_STRENGTH_POINT[4] = 0
        set DAMAGE_PER_STRENGTH_POINT[5] = 0
        set DURATION[1] = 1.75
        set DURATION[2] = 1.5
        set DURATION[3] = 1.25
        set DURATION[4] = 1
        set DURATION[5] = 0.75
        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_ORDER2", "UnitGetsOrder_EVENT_KEY", "0", "function Order2_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        set WAVES_AMOUNT[1] = 6
        set WAVES_AMOUNT[2] = 7
        set WAVES_AMOUNT[3] = 8
        set WAVES_AMOUNT[4] = 9
        set WAVES_AMOUNT[5] = 10
        loop
            set ACCELERATION_Z[iteration] = ACCELERATION_Z[iteration] * HEIGHT / DURATION[iteration] / DURATION[iteration]
            set LENGTH_Z_START[iteration] = -ACCELERATION_Z[iteration] / 2 * DURATION[iteration] * UPDATE_TIME
            set LENGTH_Z_ADD[iteration] = ACCELERATION_Z[iteration] * UPDATE_TIME * UPDATE_TIME
            set iteration = iteration - 1
            exitwhen (iteration < 1)
        endloop
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitEffectType( SPECIAL_EFFECT_PATH )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call Target_Target_Init()
    endfunction
//! runtextmacro Endscope()