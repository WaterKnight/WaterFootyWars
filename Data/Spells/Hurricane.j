//TESH.scrollpos=373
//TESH.alwaysfold=0
//! runtextmacro Scope("Hurricane")
    globals
        private constant integer ORDER_ID = 852144//OrderId( "cyclone" )
        public constant integer SPELL_ID = 'A005'

        private constant integer DUMMY_UNIT_ID = 'n00R'
        private real array DURATION
        private constant real EFFECT_INTERVAL = 0.3
        private constant integer EFFECTS_AMOUNT_PER_INTERVAL = 3
        private group ENUM_GROUP
        private real array LENGTH
        private constant integer LEVELS_AMOUNT = 5
        private real array LIFE_APPROXIMATION_LENGTH
        private real array LIFE_APPROXIMATION_LENGTH_PER_AGILITY_POINT
        private real array LIFE_LOSS_RELATIVE_PER_INTERVAL
        private real array LIFE_LOSS_RELATIVE_PER_INTERVAL_PER_AGILITY_POINT
        private constant integer MAX_EFFECTS_AMOUNT = 20
        private real array MAX_LENGTH
        private constant real MOVE_INTERVAL = 0.045
        private boolexpr TARGET_CONDITIONS
        private real array WIDTH
    endglobals

    private struct Data
        integer abilityLevel
        real angle
        Unit caster
        unit array dummyUnits[MAX_EFFECTS_AMOUNT]
        timer durationTimer
        integer effectsCount = -1
        real array effectsLengthX[MAX_EFFECTS_AMOUNT]
        real array effectsLengthY[MAX_EFFECTS_AMOUNT]
        real array effectsX[MAX_EFFECTS_AMOUNT]
        real array effectsY[MAX_EFFECTS_AMOUNT]
        timer effectTimer
        real lengthX
        real lengthY
        real lifeApproximationLength
        real lifeLossRelative
        timer moveTimer
        real sourceX
        real sourceY
        rect targetRect
    endstruct

    private function Ending takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, Hurricane_SCOPE_ID)
        local unit dummyUnit
        local timer effectTimer = d.effectTimer
        local unit enumUnit
        local integer iteration = d.effectsCount
        local timer moveTimer = d.moveTimer
        local rect targetRect = d.targetRect
        call d.destroy()
        call FlushAttachedInteger(durationTimer, Hurricane_SCOPE_ID)
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call FlushAttachedInteger(effectTimer, Hurricane_SCOPE_ID)
        call DestroyTimerWJ( effectTimer )
        set effectTimer = null
        if (iteration > -1) then
            loop
                set dummyUnit = d.dummyUnits[iteration]
                call SetUnitAnimationByIndex( dummyUnit, 2 )
                call RemoveUnitTimed( dummyUnit, 2 )
                set iteration = iteration - 1
                exitwhen (iteration < 0)
            endloop
            set dummyUnit = null
        endif
        call FlushAttachedInteger(moveTimer, Hurricane_SCOPE_ID)
        call DestroyTimerWJ( moveTimer )
        set moveTimer = null
        call RemoveRectWJ( targetRect )
        set targetRect = null
    endfunction

    private function TargetConditions takes nothing returns boolean
        local real angle
        local real distance
        local real filterUnitLife
        local real filterUnitX
        local real filterUnitY
        local real sourceX
        local real sourceY
        set FILTER_UNIT_SELF = GetFilterUnit()
        set filterUnitLife = GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE )
        if ( filterUnitLife <= 0 ) then
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
        if ( IsUnitWard( GetUnit(FILTER_UNIT_SELF) ) ) then
            return false
        endif
        set filterUnitX = GetUnitX( FILTER_UNIT_SELF )
        set filterUnitY = GetUnitY( FILTER_UNIT_SELF )
        set sourceX = TEMP_REAL
        set sourceY = TEMP_REAL2
        set distance = DistanceByCoordinates( sourceX, sourceY, filterUnitX, filterUnitY )
        set angle = GetAngleDifference( TEMP_REAL3, Atan2( filterUnitY - sourceY, filterUnitX - sourceX ) )
        if ( ( Sin( angle ) * distance > TEMP_REAL4 ) or ( Cos( angle ) * distance > TEMP_REAL5 ) ) then
            return false
        endif
        set TEMP_INTEGER = TEMP_INTEGER + 1
        set TEMP_REAL6 = TEMP_REAL6 + filterUnitLife
        return true
    endfunction

    private function Move takes nothing returns nothing
        local integer bonusLifeSign
        local unit dummyUnit
        local integer effectsCount
        local unit enumUnit
        local real enumUnitLife
        local real enumUnitX
        local real enumUnitY
        local timer moveTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(moveTimer, Hurricane_SCOPE_ID)
        local Unit caster = d.caster
        local integer abilityLevel = d.abilityLevel
        local real angle = d.angle
        local integer iteration = d.effectsCount
        local real maxLength = MAX_LENGTH[abilityLevel]
        local real lengthX
        local real lengthY
        local real lifeApproximationLength
        local real lifeAverage
        local real newX
        local real newY
        local real sourceX = d.sourceX
        local real sourceY = d.sourceY
        local rect targetRect = d.targetRect
        local real width = WIDTH[abilityLevel]
        set TEMP_INTEGER = 0
        set TEMP_PLAYER = caster.owner
        set TEMP_REAL = sourceX
        set TEMP_REAL2 = sourceY
        set TEMP_REAL3 = angle
        set TEMP_REAL4 = width
        set TEMP_REAL5 = maxLength
        set TEMP_REAL6 = 0
        call GroupEnumUnitsInRectWithCollision( ENUM_GROUP, targetRect, TARGET_CONDITIONS )
        if ( TEMP_INTEGER > 0 ) then
            set lifeApproximationLength = d.lifeApproximationLength
            set lifeAverage = Max( TEMP_REAL6 / TEMP_INTEGER * ( 1 - d.lifeLossRelative ), R2I( LIMIT_OF_DEATH + 1 ) )
        endif
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit != null ) then
            set lengthX = d.lengthX
            set lengthY = d.lengthY
            loop
                set enumUnitX = GetUnitX( enumUnit )
                set enumUnitY = GetUnitY( enumUnit )
                set newX = enumUnitX + lengthX
                set newY = enumUnitY + lengthY
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                call SetUnitFacingWJ( enumUnit, GetRandomReal( 0, 2 * PI ) )
                if ( GetUnitTypeId( enumUnit ) == DUMMY_UNIT_ID ) then
                    set newX = newX + 2 * lengthX
                    set newY = newY + 2 * lengthY

                else
                    call SetUnitXYIfNotBlocked( enumUnit, enumUnitX, enumUnitY, newX, newY )
                    set enumUnitLife = GetUnitState( enumUnit, UNIT_STATE_LIFE )
                    if ( enumUnitLife > 0 ) then
                        set bonusLifeSign = Sign( lifeAverage - enumUnitLife )
                        call SetUnitState( enumUnit, UNIT_STATE_LIFE, MinMax( enumUnitLife + bonusLifeSign * lifeApproximationLength, lifeAverage, I2B( bonusLifeSign ) == false ) )
                    endif
                endif
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
        if (iteration > -1) then
            set effectsCount = iteration
            loop
                set dummyUnit = d.dummyUnits[iteration]
                set newX = d.effectsX[iteration] + d.effectsLengthX[iteration]
                set newY = d.effectsY[iteration] + d.effectsLengthY[iteration]
                call SetUnitXWJ( dummyUnit, newX )
                call SetUnitYWJ( dummyUnit, newY )
                if ( Cos( angle - Atan2( newY - sourceY, newX - sourceX ) ) * DistanceByCoordinates( sourceX, sourceY, newX, newY ) > maxLength ) then
                    set d.dummyUnits[iteration] = d.dummyUnits[effectsCount]
                    set d.effectsX[iteration] = d.effectsX[effectsCount]
                    set d.effectsY[iteration] = d.effectsY[effectsCount]
                    set effectsCount = effectsCount - 1
                    call SetUnitAnimationByIndex( dummyUnit, 2 )
                    call RemoveUnitTimed( dummyUnit, 2 )
                else
                    set d.effectsX[iteration] = newX
                    set d.effectsY[iteration] = newY
                endif
                set iteration = iteration - 1
                exitwhen (iteration < 0)
            endloop
            set dummyUnit = null
            set d.effectsCount = effectsCount
        endif
    endfunction

    private function NewEffect takes nothing returns nothing
        local timer effectTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(effectTimer, Hurricane_SCOPE_ID)
        local integer abilityLevel
        local real angle
        local real angle2
        local integer count = d.effectsCount
        local integer iteration
        local real lengthHorizontal
        local real lengthVertical
        local real random
        local real sourceX
        local real sourceY
        local real width
        local real x
        local real xHorizontalPart
        local real xVerticalPart
        local real y
        local real yHorizontalPart
        local real yVerticalPart
        set effectTimer = null
        if (count < MAX_EFFECTS_AMOUNT - 1) then
            set abilityLevel = d.abilityLevel
            set angle = d.angle
            set angle2 = angle + PI / 2
            set iteration = 1
            set lengthVertical = LENGTH[abilityLevel]
            set sourceX = d.sourceX
            set sourceY = d.sourceY
            set width = WIDTH[abilityLevel]
            set xHorizontalPart = Cos(angle2)
            set xVerticalPart = Cos(angle)
            set yHorizontalPart = Sin(angle2)
            set yVerticalPart = Sin(angle)
            loop
                set lengthHorizontal = GetRandomReal( -width, width )
                set count = count + 1
                set random = GetRandomReal(2, 4) * lengthVertical
                set x = sourceX + lengthHorizontal * xHorizontalPart
                set y = sourceY + lengthHorizontal * yHorizontalPart
                set d.dummyUnits[count] = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, DUMMY_UNIT_ID, x, y, angle )
                set d.effectsLengthX[count] = random * xVerticalPart
                set d.effectsLengthY[count] = random * yVerticalPart
                set d.effectsX[count] = x
                set d.effectsY[count] = y
                exitwhen (count == MAX_EFFECTS_AMOUNT)
                set iteration = iteration + 1
                exitwhen ( iteration > EFFECTS_AMOUNT_PER_INTERVAL )
            endloop
            set d.effectsCount = count
        endif
    endfunction

    public function SpellEffect takes Unit caster, real targetX, real targetY returns nothing
        local real angle
        local real angle2
        local real casterAgility = GetHeroAgilityTotal( caster )
        local unit casterSelf = caster.self
        local integer abilityLevel = GetUnitAbilityLevel( casterSelf, SPELL_ID )
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local Data d = Data.create()
        local timer durationTimer = CreateTimerWJ()
        local timer effectTimer = CreateTimerWJ()
        local real endX
        local real endY
        local real maxLength = MAX_LENGTH[abilityLevel]
        local real length = LENGTH[abilityLevel]
        local timer moveTimer = CreateTimerWJ()
        local real width = WIDTH[abilityLevel]
        local real widthX
        local real widthY
        local real aX
        local real bX
        local real cX
        local real dX
        local real aY
        local real bY
        local real cY
        local real dY
        if ( ( casterX != targetX ) or ( casterY != targetY ) ) then
            set angle = Atan2( targetY - casterY, targetX - casterX )
        else
            set angle = GetUnitFacingWJ( casterSelf )
        endif
        set casterSelf = null
        set angle2 = angle - PI / 2
        set widthX = width * Cos( angle2 )
        set widthY = width * Sin( angle2 )
        set aX = casterX - widthX
        set aY = casterY - widthY
        set bX = casterX + widthX
        set bY = casterY + widthY
        set endX = casterX + maxLength * Cos( angle )
        set cX = endX - widthX
        set dX = endX + widthX
        set endY = casterY + maxLength * Sin( angle )
        set cY = endY - widthY
        set dY = endY + widthY
        set d.abilityLevel = abilityLevel
        set d.angle = angle
        set d.caster = caster
        set d.durationTimer = durationTimer
        set d.effectTimer = effectTimer
        set d.lengthX = length * Cos(angle)
        set d.lengthY = length * Sin(angle)
        set d.lifeApproximationLength = LIFE_APPROXIMATION_LENGTH[abilityLevel] + casterAgility * LIFE_APPROXIMATION_LENGTH_PER_AGILITY_POINT[abilityLevel]
        set d.lifeLossRelative = LIFE_LOSS_RELATIVE_PER_INTERVAL[abilityLevel] + casterAgility * LIFE_LOSS_RELATIVE_PER_INTERVAL_PER_AGILITY_POINT[abilityLevel]
        set d.moveTimer = moveTimer
        set d.sourceX = casterX
        set d.sourceY = casterY
        set d.targetRect = RectWJ( Min( Min( aX, bX ), Min( cX, dX ) ), Min( Min( aY, bY ), Min( cY, dY ) ), Max( Max( aX, bX ), Max( cX, dX ) ), Max( Max( aY, bY ), Max( cY, dY ) ) )
        call AttachInteger(durationTimer, Hurricane_SCOPE_ID, d)
        call AttachInteger(effectTimer, Hurricane_SCOPE_ID, d)
        call AttachInteger(moveTimer, Hurricane_SCOPE_ID, d)
        call TimerStart( effectTimer, EFFECT_INTERVAL, true, function NewEffect )
        set effectTimer = null
        call TimerStart( moveTimer, MOVE_INTERVAL, true, function Move )
        set moveTimer = null
        call TimerStart( durationTimer, DURATION[abilityLevel], false, function Ending )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_X, TARGET_Y )
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = LEVELS_AMOUNT
        set DURATION[1] = 3
        set DURATION[2] = 4
        set DURATION[3] = 5
        set DURATION[4] = 5
        set DURATION[5] = 5
        set ENUM_GROUP = CreateGroupWJ()
        set LENGTH[1] = 150
        set LENGTH[2] = 225
        set LENGTH[3] = 300
        set LENGTH[4] = 375
        set LENGTH[5] = 450
        set LIFE_APPROXIMATION_LENGTH[1] = 7.5
        set LIFE_APPROXIMATION_LENGTH[2] = 7.5
        set LIFE_APPROXIMATION_LENGTH[3] = 7.5
        set LIFE_APPROXIMATION_LENGTH[4] = 7.5
        set LIFE_APPROXIMATION_LENGTH[5] = 7.5
        set LIFE_APPROXIMATION_LENGTH_PER_AGILITY_POINT[1] = 0.15
        set LIFE_APPROXIMATION_LENGTH_PER_AGILITY_POINT[2] = 0.15
        set LIFE_APPROXIMATION_LENGTH_PER_AGILITY_POINT[3] = 0.15
        set LIFE_APPROXIMATION_LENGTH_PER_AGILITY_POINT[4] = 0.15
        set LIFE_APPROXIMATION_LENGTH_PER_AGILITY_POINT[5] = 0.15
        set LIFE_LOSS_RELATIVE_PER_INTERVAL[1] = 0.05
        set LIFE_LOSS_RELATIVE_PER_INTERVAL[2] = 0.08
        set LIFE_LOSS_RELATIVE_PER_INTERVAL[3] = 0.11
        set LIFE_LOSS_RELATIVE_PER_INTERVAL[4] = 0.14
        set LIFE_LOSS_RELATIVE_PER_INTERVAL[5] = 0.17
        set LIFE_LOSS_RELATIVE_PER_INTERVAL_PER_AGILITY_POINT[1] = 0.0005
        set LIFE_LOSS_RELATIVE_PER_INTERVAL_PER_AGILITY_POINT[2] = 0.0005
        set LIFE_LOSS_RELATIVE_PER_INTERVAL_PER_AGILITY_POINT[3] = 0.0005
        set LIFE_LOSS_RELATIVE_PER_INTERVAL_PER_AGILITY_POINT[4] = 0.0005
        set LIFE_LOSS_RELATIVE_PER_INTERVAL_PER_AGILITY_POINT[5] = 0.0005
        loop
            set LENGTH[iteration] = LENGTH[iteration] * MOVE_INTERVAL
            set LIFE_APPROXIMATION_LENGTH[iteration] = LIFE_APPROXIMATION_LENGTH[iteration] * MOVE_INTERVAL
            set LIFE_APPROXIMATION_LENGTH_PER_AGILITY_POINT[iteration] = LIFE_APPROXIMATION_LENGTH_PER_AGILITY_POINT[iteration] * MOVE_INTERVAL
            set LIFE_LOSS_RELATIVE_PER_INTERVAL[iteration] = LIFE_LOSS_RELATIVE_PER_INTERVAL[iteration] * MOVE_INTERVAL
            set LIFE_LOSS_RELATIVE_PER_INTERVAL_PER_AGILITY_POINT[iteration] = LIFE_LOSS_RELATIVE_PER_INTERVAL_PER_AGILITY_POINT[iteration] * MOVE_INTERVAL
            set iteration = iteration - 1
            exitwhen (iteration < 1)
        endloop
        set MAX_LENGTH[1] = 700
        set MAX_LENGTH[2] = 700
        set MAX_LENGTH[3] = 700
        set MAX_LENGTH[4] = 700
        set MAX_LENGTH[5] = 700
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        set WIDTH[1] = 175
        set WIDTH[2] = 200
        set WIDTH[3] = 230
        set WIDTH[4] = 265
        set WIDTH[5] = 305
        call InitUnitType( DUMMY_UNIT_ID )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()