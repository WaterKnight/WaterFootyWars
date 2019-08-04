//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("LinearBoomerang")
    globals
        public constant integer SPELL_ID = 'A08K'

        private constant real AREA_RANGE = 90.
        private constant integer DUMMY_UNIT_ID = 'n034'
        private group ENUM_GROUP
        private constant real MAX_LENGTH = 700.
        private constant real DURATION = 1.5
        private constant real SPEED = 2 * MAX_LENGTH / DURATION
        private boolexpr TARGET_CONDITIONS
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        private constant real UPDATE_TIME = 0.035
        private constant real LENGTH = SPEED * UPDATE_TIME
        private constant real SPEED_ADD = -SPEED / DURATION * UPDATE_TIME
        private constant real LENGTH_ADD = SPEED_ADD * UPDATE_TIME
    endglobals

    private struct Data
        Unit caster
        real damageAmount
        unit dummyUnit
        timer durationTimer
        real lengthX
        real lengthXAdd
        real lengthY
        real lengthYAdd
        group targetGroup
        timer updateTimer
        real x
        real y
    endstruct

    //! runtextmacro Scope("DrawBack")
        globals
            private constant real DrawBack_SPEED = 600.
            private constant real DrawBack_UPDATE_TIME = 0.035
            private constant real DrawBack_LENGTH = DrawBack_SPEED * DrawBack_UPDATE_TIME
        endglobals

        private struct DrawBack_Data
            Unit caster
            real damageAmount
            unit dummyUnit
            real length
            timer moveTimer
            group targetGroup
            real targetX
            real targetY
            real targetZ
            real x
            real y
            real z
        endstruct

        private function DrawBack_Ending takes Unit caster, DrawBack_Data d, unit dummyUnit, timer moveTimer returns nothing
            local integer casterId
            call d.destroy()
            call SetUnitAnimation( dummyUnit, "death" )
            call RemoveUnitTimed( dummyUnit, 2 )
            call FlushAttachedInteger( moveTimer, DrawBack_SCOPE_ID )
            call DestroyTimerWJ( moveTimer )
            if ( caster != NULL ) then
                set casterId = caster.id
                call RemoveIntegerFromTableById( casterId, DrawBack_SCOPE_ID, d )
                if ( CountIntegersInTableById( casterId, DrawBack_SCOPE_ID ) == TABLE_EMPTY ) then
                    //! runtextmacro RemoveEventById( "casterId", "DrawBack_EVENT_DEATH" )
                endif
            endif
            call RemoveUnitAttackSilence( caster )
        endfunction

        private function Death_ResetTarget takes Unit caster, real casterX, real casterY, real casterZ, DrawBack_Data d returns nothing
            local integer casterId = caster.id
            call RemoveIntegerFromTableById( casterId, DrawBack_SCOPE_ID, d )
            set d.caster = NULL
            if ( CountIntegersInTableById( casterId, DrawBack_SCOPE_ID ) == TABLE_EMPTY ) then
                //! runtextmacro RemoveEventById( "casterId", "DrawBack_EVENT_DEATH" )
            endif
            set d.targetX = casterX
            set d.targetY = casterY
            set d.targetZ = casterZ
        endfunction

        public function DrawBack_Death takes Unit caster, real casterX, real casterY, real casterZ returns nothing
            local integer casterId = caster.id
            local DrawBack_Data d
            local integer iteration = CountIntegersInTableById( casterId, DrawBack_SCOPE_ID )
            if ( iteration > TABLE_EMPTY ) then
                loop
                    set d = GetIntegerFromTableById( casterId, DrawBack_SCOPE_ID, iteration )
                    call Death_ResetTarget( caster, casterX, casterY, casterZ, d )
                    set iteration = iteration - 1
                    exitwhen ( iteration < TABLE_STARTED )
                endloop
            endif
        endfunction

        private function DrawBack_Death_Event takes nothing returns nothing
            local unit dyingUnitSelf = DYING_UNIT.self
            local real dyingUnitX = GetUnitX(dyingUnitSelf)
            local real dyingUnitY = GetUnitY(dyingUnitSelf)
            call DrawBack_Death( DYING_UNIT, dyingUnitX, dyingUnitY, GetUnitZ(dyingUnitSelf, dyingUnitX, dyingUnitY) )
            set dyingUnitSelf = null
        endfunction

        private function DrawBack_Move takes nothing returns nothing
            local real angleLengthXYZ
            local real angleXY
            local unit casterSelf
            local real damageAmount
            local real distanceX
            local real distanceY
            local real distanceZ
            local unit enumUnit
            local real lengthXY
            local timer moveTimer = GetExpiredTimer()
            local DrawBack_Data d = GetAttachedInteger(moveTimer, DrawBack_SCOPE_ID)
            local Unit caster = d.caster
            local unit dummyUnit = d.dummyUnit
            local real dummyUnitX = d.x
            local real dummyUnitY = d.y
            local real dummyUnitZ = d.z
            local real length = d.length - LENGTH_ADD
            local boolean reachesTarget
            local group targetGroup
            local real targetX
            local real targetY
            local real targetZ
            if ( caster == null ) then
                set targetX = d.targetX
                set targetY = d.targetY
                set targetZ = d.targetZ
            else
                set casterSelf = caster.self
                set targetX = GetUnitX( casterSelf )
                set targetY = GetUnitY( casterSelf )
                set targetZ = GetUnitZ( casterSelf, targetX, targetY ) + GetUnitImpactZ(caster)
                set casterSelf = null
            endif
            set reachesTarget = ( DistanceByCoordinatesWithZ( dummyUnitX, dummyUnitY, dummyUnitZ, targetX, targetY, targetZ ) <= length )
            if ( reachesTarget ) then
                set dummyUnitX = targetX
                set dummyUnitY = targetY
                set dummyUnitZ = targetZ
            else
                set distanceZ = targetZ - dummyUnitZ
                set angleLengthXYZ = Atan2( distanceZ, DistanceByCoordinates( dummyUnitX, dummyUnitY, targetX, targetY ) )
                set distanceX = targetX - dummyUnitX
                set distanceY = targetY - dummyUnitY
                set angleXY = Atan2( distanceY, distanceX )
                set lengthXY = length * Cos( angleLengthXYZ )
                set dummyUnitX = dummyUnitX + lengthXY * Cos( angleXY )
                set dummyUnitY = dummyUnitY + lengthXY * Sin( angleXY )
                set dummyUnitZ = dummyUnitZ + length * Sin( angleLengthXYZ )
                call SetUnitFacingWJ( dummyUnit, angleXY )
            endif
            call SetUnitX( dummyUnit, dummyUnitX )
            call SetUnitY( dummyUnit, dummyUnitY )
            call SetUnitZ( dummyUnit, dummyUnitX, dummyUnitY, dummyUnitZ )
            call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, dummyUnitX, dummyUnitY, AREA_RANGE, TARGET_CONDITIONS )
            set enumUnit = FirstOfGroup( ENUM_GROUP )
            if ( enumUnit != null ) then
                set damageAmount = d.damageAmount
                set targetGroup = d.targetGroup
                loop
                    call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                    if (IsUnitInGroup(enumUnit, targetGroup) == false) then
                        call GroupAddUnit( targetGroup, enumUnit )
                        call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, enumUnit, TARGET_EFFECT_ATTACHMENT_POINT ) )
                        call UnitDamageUnitEx( caster, GetUnit(enumUnit), damageAmount, null )
                    endif
                    set enumUnit = FirstOfGroup( ENUM_GROUP )
                    exitwhen ( enumUnit == null )
                endloop
                set targetGroup = null
            endif
            if ( reachesTarget ) then
                call DrawBack_Ending( caster, d, dummyUnit, moveTimer )
            else
                set d.length = length
                set d.x = dummyUnitX
                set d.y = dummyUnitY
                set d.z = dummyUnitZ
            endif
            set moveTimer = null
        endfunction

        public function DrawBack_Start takes Unit caster, real damageAmount, unit dummyUnit, group targetGroup, real x, real y, real z returns nothing
            local integer casterId = caster.id
            local DrawBack_Data d = DrawBack_Data.create()
            local timer moveTimer = CreateTimer()
            set d.caster = caster
            set d.damageAmount = damageAmount
            set d.dummyUnit = dummyUnit
            set d.length = 0
            set d.moveTimer = moveTimer
            set d.targetGroup = targetGroup
            set d.x = x
            set d.y = y
            set d.z = z
            call AddIntegerToTableById( casterId, DrawBack_SCOPE_ID, d )
            if ( CountIntegersInTableById( casterId, DrawBack_SCOPE_ID ) == TABLE_STARTED ) then
                //! runtextmacro AddEventById( "casterId", "DrawBack_EVENT_DEATH" )
            endif
            call AttachInteger( moveTimer, DrawBack_SCOPE_ID, d )
            call SetUnitZ( dummyUnit, x, y, z )
            set dummyUnit = null
            call TimerStart( moveTimer, UPDATE_TIME, true, function DrawBack_Move )
            set moveTimer = null
        endfunction

        public function DrawBack_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "DrawBack_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function DrawBack_Death_Event" )
        endfunction
    //! runtextmacro Endscope()

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, LinearBoomerang_SCOPE_ID)
        local Unit caster = d.caster
        local real damageAmount = d.damageAmount
        local unit dummyUnit = d.dummyUnit
        local group targetGroup = d.targetGroup
        local timer updateTimer = d.updateTimer
        local real x = d.x
        local real y = d.y
        call d.destroy()
        call FlushAttachedInteger( durationTimer, LinearBoomerang_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call DestroyGroupWJ( targetGroup )
        set targetGroup = null
        call FlushAttachedInteger( updateTimer, LinearBoomerang_SCOPE_ID )
        call DestroyTimerWJ( updateTimer )
        set updateTimer = null
        call DrawBack_DrawBack_Start(caster, damageAmount, dummyUnit, targetGroup, x, y, GetUnitZ(dummyUnit, x, y))
        set dummyUnit = null
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_FLYING ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        set FILTER_UNIT = GetUnit(FILTER_UNIT_SELF)
        if ( GetUnitInvulnerability( FILTER_UNIT ) > 0 ) then
            return false
        endif
        return true
    endfunction

    private function Move takes nothing returns nothing
        local real damageAmount
        local unit enumUnit
        local timer updateTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(updateTimer, LinearBoomerang_SCOPE_ID)
        local Unit caster = d.caster
        local unit dummyUnit = d.dummyUnit
        local real dummyUnitX = GetUnitX(dummyUnit)
        local real dummyUnitY = GetUnitY(dummyUnit)
        local real lengthX = d.lengthX + d.lengthXAdd
        local real lengthY = d.lengthY + d.lengthYAdd
        local real newX = d.x + lengthX
        local real newY = d.y + lengthY
        local group targetGroup = d.targetGroup
        set updateTimer = null
        set d.lengthX = lengthX
        set d.lengthY = lengthY
        set d.x = newX
        set d.y = newY
        call SetUnitXWJ( dummyUnit, newX )
        call SetUnitYWJ( dummyUnit, newY )
        set dummyUnit = null
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, newX, newY, AREA_RANGE, TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit != null ) then
            set damageAmount = d.damageAmount
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                if (IsUnitInGroup(enumUnit, targetGroup) == false) then
                    call GroupAddUnit( targetGroup, enumUnit )
                    call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, enumUnit, TARGET_EFFECT_ATTACHMENT_POINT ) )
                    call UnitDamageUnitEx( caster, GetUnit(enumUnit), damageAmount, null )
                endif
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
        set targetGroup = null
    endfunction

    public function Damage takes Unit caster, Unit target returns nothing
        local real angle
        local unit casterSelf = caster.self
        local real casterX
        local real casterY
        local Data d
        local unit dummyUnit
        local timer durationTimer
        local real partX
        local real partY
        local unit targetSelf
        local real targetX
        local real targetY
        local timer updateTimer
        if (GetUnitAbilityLevel(casterSelf, SPELL_ID) > 0) then
            set casterX = GetUnitX( casterSelf )
            set casterY = GetUnitY( casterSelf )
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set targetSelf = target.self
            set targetX = GetUnitX(targetSelf)
            set targetY = GetUnitY(targetSelf)
            set targetSelf = null
            set updateTimer = CreateTimerWJ()
            if ( ( casterX != targetX ) or ( casterY != targetY ) ) then
                set angle = Atan2( targetY - casterY, targetX - casterX )
            else
                set angle = GetUnitFacingWJ( casterSelf )
            endif
            set dummyUnit = CreateUnitWJ( caster.owner, DUMMY_UNIT_ID, casterX, casterY, angle )
            set partX = Cos( angle )
            set partY = Sin( angle )
            set d.caster = caster
            set d.damageAmount = GetUnitDamageTotal(caster) * UPDATE_TIME
            set d.dummyUnit = dummyUnit
            set d.durationTimer = durationTimer
            set d.lengthX = LENGTH * partX
            set d.lengthXAdd = LENGTH_ADD * partX
            set d.lengthY = LENGTH * partY
            set d.lengthYAdd = LENGTH_ADD * partY
            set d.targetGroup = CreateGroupWJ()
            set d.updateTimer = updateTimer
            set d.x = casterX
            set d.y = casterY
            call AttachInteger( durationTimer, LinearBoomerang_SCOPE_ID, d )
            call AttachInteger( updateTimer, LinearBoomerang_SCOPE_ID, d )
            call AddUnitAttackSilence( caster )
            call SetUnitZ(dummyUnit, casterX, casterY, GetUnitZ(casterSelf, casterX, casterY) + GetUnitOutpactZ(caster))
            set dummyUnit = null
            call TimerStart( updateTimer, UPDATE_TIME, true, function Move )
            set updateTimer = null
            call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
            set durationTimer = null
        endif
        set casterSelf = null
    endfunction

    public function Init takes nothing returns nothing
        set ENUM_GROUP = CreateGroupWJ()
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitUnitType( DUMMY_UNIT_ID )
        call InitEffectType( TARGET_EFFECT_PATH )
        call InitAbility( SPELL_ID )
        call DrawBack_DrawBack_Init()
    endfunction
//! runtextmacro Endscope()