//TESH.scrollpos=253
//TESH.alwaysfold=0
//! runtextmacro Scope("AttackDerivation")
    globals
        public constant integer RESEARCH_ID = 'R01G'
        public constant integer SPELL_ID = 'A00I'

        private constant real AREA_RANGE = 350.
        private constant integer DUMMY_UNIT_ID = 'h00J'
        private group ENUM_GROUP
        private constant real RELATIVE_DAMAGE = 0.25
        private boolexpr TARGET_CONDITIONS
        private constant real UPDATE_TIME = 0.1
        private constant real LENGTH = 1000 * UPDATE_TIME

        private boolean IS_NEXT_ATTACK = false
    endglobals

    private struct Data
        Unit caster
        real damageAmount
        unit dummyUnit
        timer moveTimer
        Unit target
        real targetX
        real targetY
        real targetZ
        real x
        real y
        real z
    endstruct

    public function DecayEnd takes Unit caster returns nothing
        local integer casterId = caster.id
        if (GetAttachedBooleanById(casterId, AttackDerivation_SCOPE_ID)) then
            call FlushAttachedBooleanById(casterId, AttackDerivation_SCOPE_ID)
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DAMAGE" )
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DECAY_END" )
        endif
    endfunction

    private function DecayEnd_Event takes nothing returns nothing
        call DecayEnd( DYING_UNIT )
    endfunction

    private function Ending takes Unit caster, Data d, unit dummyUnit, boolean isTargetNotNull, timer moveTimer, Unit target returns nothing
        local integer targetId
        call d.destroy()
        call RemoveUnitRemainingReference( caster )
        call SetUnitAnimationByIndex( dummyUnit, 1 )
        call RemoveUnitTimed( dummyUnit, 2 )
        call FlushAttachedInteger( moveTimer, AttackDerivation_SCOPE_ID )
        call DestroyTimerWJ( moveTimer )
        if ( isTargetNotNull ) then
            set targetId = target.id
            call RemoveIntegerFromTableById( targetId, AttackDerivation_SCOPE_ID, d )
            if ( CountIntegersInTableById( targetId, AttackDerivation_SCOPE_ID ) == TABLE_EMPTY ) then
                //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
            endif
        endif
    endfunction

    private function Death_ResetTarget takes Data d, Unit target, real targetX, real targetY, real targetZ returns nothing
        local integer targetId = target.id
        set d.target = NULL
        call RemoveIntegerFromTableById( targetId, AttackDerivation_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, AttackDerivation_SCOPE_ID ) == TABLE_EMPTY ) then
            //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        endif
        set d.targetX = targetX
        set d.targetY = targetY
        set d.targetZ = targetZ
    endfunction

    public function Death takes Unit target, real targetX, real targetY, real targetZ returns nothing
        local Data d
        local integer targetId = target.id
        local integer iteration = CountIntegersInTableById( targetId, AttackDerivation_SCOPE_ID )
        if ( iteration > -1 ) then
            loop
                set d = GetIntegerFromTableById( targetId, AttackDerivation_SCOPE_ID, iteration )
                call Death_ResetTarget( d, target, targetX, targetY, targetZ )
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

    private function TargetConditions_Single takes player casterOwner, unit checkingUnit returns boolean
        if ( IsUnitAlly( checkingUnit, casterOwner ) ) then
            return false
        endif
        return true
    endfunction

    private function Move takes nothing returns nothing
        local real angleLengthXYZ
        local real angleXY
        local Unit caster
        local player casterOwner
        local real damageAmount
        local real distanceX
        local real distanceY
        local real distanceZ
        local boolean isTargetNotNull
        local real lengthXY
        local timer moveTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(moveTimer, AttackDerivation_SCOPE_ID)
        local unit dummyUnit = d.dummyUnit
        local boolean reachesTarget
        local Unit target = d.target
        local boolean isTargetNull = ( target == null )
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
        set reachesTarget = ( DistanceByCoordinatesWithZ( x, y, z, targetX, targetY, targetZ ) <= LENGTH )
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
            set lengthXY = LENGTH * Cos( angleLengthXYZ )
            set x = x + lengthXY * Cos( angleXY )
            set y = y + lengthXY * Sin( angleXY )
            set z = z + LENGTH * Sin( angleLengthXYZ )
            call SetUnitFacingWJ( dummyUnit, angleXY )
        endif
        call SetUnitX( dummyUnit, x )
        call SetUnitY( dummyUnit, y )
        call SetUnitZ( dummyUnit, x, y, z )
        if ( reachesTarget ) then
            set caster = d.caster
            set isTargetNotNull = ( isTargetNull == false )
            if ( isTargetNotNull ) then
                set damageAmount = d.damageAmount
            endif
            call Ending( caster, d, dummyUnit, isTargetNotNull, moveTimer, target )
            if ( isTargetNotNull ) then
                if ( TargetConditions_Single( caster.owner, targetSelf ) ) then
                    set IS_NEXT_ATTACK = true
                    call UnitDamageUnitEx( caster, target, damageAmount, null )
                endif
            endif
        else
            set d.x = x
            set d.y = y
            set d.z = z
        endif
        set moveTimer = null
        set targetSelf = null
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( FILTER_UNIT_SELF == TEMP_UNIT_SELF ) then
            return false
        endif
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        return TargetConditions_Single( TEMP_PLAYER, FILTER_UNIT_SELF )
    endfunction

    public function Damage takes Unit caster, real damageAmount, Unit target returns nothing
        local unit casterSelf
        local Data d
        local unit dummyUnit
        local Unit enumUnit
        local integer enumUnitId
        local unit enumUnitSelf
        local timer moveTimer
        local unit targetSelf
        local real targetX
        local real targetY
        local real targetZ
        if ( IS_NEXT_ATTACK ) then
            set IS_NEXT_ATTACK = false
        else
            if ( GetAttachedBooleanById( caster.id, AttackDerivation_SCOPE_ID ) ) then
                set targetSelf = target.self
                set targetX = GetUnitX( targetSelf )
                set targetY = GetUnitY( targetSelf )
                set TEMP_PLAYER = caster.owner
                set TEMP_UNIT_SELF = targetSelf
                call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, targetX, targetY, AREA_RANGE, TARGET_CONDITIONS )
                set enumUnitSelf = GetNearestUnit( ENUM_GROUP, targetX, targetY )
                if ( enumUnitSelf != null ) then
                    set casterSelf = caster.self
                    set d = Data.create()
                    set dummyUnit = CreateUnitWJ(NEUTRAL_PASSIVE_PLAYER, DUMMY_UNIT_ID, targetX, targetY, Atan2(targetY - GetUnitY(casterSelf), targetX - GetUnitX(casterSelf)))
                    set casterSelf = null
                    set enumUnit = GetUnit(enumUnitSelf)
                    set enumUnitId = enumUnit.id
                    set enumUnitSelf = null
                    set moveTimer = CreateTimerWJ()
                    set targetZ = GetUnitZ(targetSelf, targetX, targetY) + GetUnitOutpactZ(target)
                    set d.caster = caster
                    set d.damageAmount = damageAmount * RELATIVE_DAMAGE
                    set d.dummyUnit = dummyUnit
                    set d.moveTimer = moveTimer
                    set d.target = enumUnit
                    set d.x = targetX
                    set d.y = targetY
                    set d.z = targetZ
                    call AddUnitRemainingReference( caster )
                    call AttachInteger( moveTimer, AttackDerivation_SCOPE_ID, d )
                    call AddIntegerToTableById( enumUnitId, AttackDerivation_SCOPE_ID, d )
                    if ( CountIntegersInTableById( enumUnitId, AttackDerivation_SCOPE_ID ) == TABLE_STARTED ) then
                        //! runtextmacro AddEventById( "enumUnitId", "EVENT_DEATH" )
                    endif
                    call SetUnitZ(dummyUnit, targetX, targetY, targetZ)
                    set dummyUnit = null
                    call TimerStart( moveTimer, UPDATE_TIME, true, function Move )
                    set moveTimer = null
                endif
                set targetSelf = null
            endif
        endif
    endfunction

    private function Damage_Event takes nothing returns nothing
        call Damage( DAMAGE_SOURCE, DAMAGE_AMOUNT, TRIGGER_UNIT )
    endfunction

    public function Learn takes Unit caster returns nothing
        local integer casterId = caster.id
        call AttachBooleanById( casterId, AttackDerivation_SCOPE_ID, true )
        //! runtextmacro AddEventById( "casterId", "EVENT_DAMAGE" )
        //! runtextmacro AddEventById( "casterId", "EVENT_DECAY_END" )
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 300)

        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY_AS_DAMAGE_SOURCE", "0", "function Damage_Event" )
        //! runtextmacro CreateEvent( "EVENT_DECAY_END", "UnitFinishesDecaying_End_End_EVENT_KEY", "0", "function DecayEnd_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        call InitUnitType( DUMMY_UNIT_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
        call SetAbilityRequiredResearch( SPELL_ID, RESEARCH_ID )
    endfunction
//! runtextmacro Endscope()