//TESH.scrollpos=211
//TESH.alwaysfold=0
//! runtextmacro Scope("Kataikaze")
    globals
        public constant integer ORDER_ID = 852132//OrderId( "unstableconcoction" )
        public constant integer RESEARCH_ID = 'R01D'
        public constant integer SPELL_ID = 'A08N'

        private constant real AREA_RANGE = 300.
        private constant real DAMAGE_FACTOR = 7.
        private constant real HERO_DAMAGE_FACTOR = 4.
        private constant real HIT_TOLERANCE = 30.
        private group ENUM_GROUP
        private constant string SPECIAL_EFFECT_PATH = "Abilities\\Weapons\\Mortar\\MortarMissile.mdl"
        private constant real SPEED_FACTOR = 1.25
        private boolexpr TARGET_CONDITIONS
        private constant real UPDATE_TIME = 0.035
    endglobals

    private struct Data
        Unit caster
        timer moveTimer
        Unit target
        real targetX
        real targetY
        real targetZ
    endstruct

    private function Ending takes Unit caster, Data d, boolean isTargetNotNull, timer moveTimer, Unit target returns nothing
        local integer casterId = caster.id
        local integer targetId
        call d.destroy()
        call FlushAttachedIntegerById( casterId, Kataikaze_SCOPE_ID_BASIC )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_CASTER_DEATH" )
        call FlushAttachedInteger( moveTimer, Kataikaze_SCOPE_ID )
        call DestroyTimerWJ( moveTimer )
        if ( isTargetNotNull ) then
            set targetId = target.id
            call RemoveIntegerFromTableById( targetId, Kataikaze_SCOPE_ID, d )
            if ( CountIntegersInTableById( targetId, Kataikaze_SCOPE_ID ) == TABLE_EMPTY ) then
                //! runtextmacro RemoveEventById( "targetId", "EVENT_TARGET_DEATH" )
            endif
        endif
        call AddUnitPathing(caster)
        call RemoveUnitStun(caster, 5)
    endfunction

    public function Caster_Death takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, Kataikaze_SCOPE_ID_BASIC)
        local Unit target
        if (d != NULL) then
            set target = d.target
            call Ending(caster, d, (target != NULL), d.moveTimer, target)
        endif
    endfunction

    private function Caster_Death_Event takes nothing returns nothing
        call Caster_Death( DYING_UNIT )
    endfunction

    private function Target_Death_ResetTarget takes Data d, Unit target, real targetX, real targetY, real targetZ returns nothing
        local integer targetId = target.id
        call RemoveIntegerFromTableById( targetId, Kataikaze_SCOPE_ID, d )
        set d.target = NULL
        if ( CountIntegersInTableById( targetId, Kataikaze_SCOPE_ID ) == TABLE_EMPTY ) then
            //! runtextmacro RemoveEventById( "targetId", "EVENT_TARGET_DEATH" )
        endif
        set d.targetX = targetX
        set d.targetY = targetY
        set d.targetZ = targetZ
    endfunction

    public function Target_Death takes Unit target, real targetX, real targetY, real targetZ returns nothing
        local Data d
        local integer targetId = target.id
        local integer iteration = CountIntegersInTableById( targetId, Kataikaze_SCOPE_ID )
        if ( iteration > TABLE_EMPTY ) then
            loop
                set d = GetIntegerFromTableById( targetId, Kataikaze_SCOPE_ID, iteration )
                call Target_Death_ResetTarget( d, target, targetX, targetY, targetZ )
                set iteration = iteration - 1
                exitwhen ( iteration < TABLE_STARTED )
            endloop
        endif
    endfunction

    private function Target_Death_Event takes nothing returns nothing
        local unit dyingUnitSelf = DYING_UNIT.self
        local real dyingUnitX = GetUnitX(dyingUnitSelf)
        local real dyingUnitY = GetUnitY(dyingUnitSelf)
        call Target_Death( DYING_UNIT, dyingUnitX, dyingUnitY, GetUnitZ(dyingUnitSelf, dyingUnitX, dyingUnitY) )
        set dyingUnitSelf = null
    endfunction

    private function TargetConditions_Single takes player casterOwner, Unit target returns string
        set TEMP_UNIT_SELF = target.self
        if ( IsUnitAlly( TEMP_UNIT_SELF, casterOwner ) ) then
            return ErrorStrings_NOT_ALLY
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_GROUND ) == false ) then
            return ErrorStrings_ONLY_GROUND
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return ErrorStrings_NOT_STRUCTURE
        endif
        if ( GetUnitInvulnerability( target ) > 0 ) then
            return ErrorStrings_TARGET_IS_INVULNERABLE
        endif
        return null
    endfunction

    private function TargetConditions takes nothing returns boolean
        if (TargetConditions_Single(TEMP_PLAYER, GetUnit(GetFilterUnit())) != null) then
            return false
        endif
        return true
    endfunction

    private function Move takes nothing returns nothing
        local real angleLengthXYZ
        local real angleXY
        local real casterDamage
        local real damage
        local real distanceX
        local real distanceY
        local real distanceZ
        local unit enumUnit
        local real heroDamage
        local real lengthXY
        local timer moveTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(moveTimer, Kataikaze_SCOPE_ID)
        local Unit caster = d.caster
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local real casterZ = GetUnitZ( casterSelf, casterX, casterY )
        local real length = GetUnitSpeedTotal( caster ) * SPEED_FACTOR * UPDATE_TIME
        local real normalDamage
        local boolean reachesTarget
        local Unit target = d.target
        local boolean isTargetNull = ( target == NULL )
        local unit targetSelf
        local real targetX
        local real targetY
        local real targetZ
        set moveTimer = null
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
        set reachesTarget = ( DistanceByCoordinatesWithZ( casterX, casterY, casterZ, targetX, targetY, targetZ ) <= length + HIT_TOLERANCE )
        if ( reachesTarget ) then
            set casterX = targetX
            set casterY = targetY
            set casterZ = targetZ
        else
            set distanceZ = targetZ - casterZ
            set angleLengthXYZ = Atan2( distanceZ, DistanceByCoordinates( casterX, casterY, targetX, targetY ) )
            set distanceX = targetX - casterX
            set distanceY = targetY - casterY
            set angleXY = Atan2( distanceY, distanceX )
            set lengthXY = length * Cos( angleLengthXYZ )
            set casterX = casterX + lengthXY * Cos( angleXY )
            set casterY = casterY + lengthXY * Sin( angleXY )
            set casterZ = casterZ + length * Sin( angleLengthXYZ )
            call SetUnitFacingWJ( casterSelf, angleXY )
        endif
        call SetUnitX( casterSelf, casterX )
        call SetUnitY( casterSelf, casterY )
        call SetUnitZ( casterSelf, casterX, casterY, casterZ )
        if ( reachesTarget ) then
            set casterDamage = GetUnitDamage(caster)
            set heroDamage = casterDamage * DAMAGE_FACTOR
            set normalDamage = casterDamage * DAMAGE_FACTOR
            call KillUnit(casterSelf)
            set TEMP_PLAYER = caster.owner
            call DestroyEffectWJ( AddSpecialEffectWJ( SPECIAL_EFFECT_PATH, casterX, casterY ) )
            call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, casterX, casterY, AREA_RANGE, TARGET_CONDITIONS )
            set enumUnit = FirstOfGroup(ENUM_GROUP)
            if (enumUnit != null) then
                loop
                    call GroupRemoveUnit(ENUM_GROUP, enumUnit)
                    if (IsUnitType(enumUnit, UNIT_TYPE_HERO)) then
                        set damage = heroDamage
                    else
                        set damage = normalDamage
                    endif
                    call UnitDamageUnitEx(caster, GetUnit(enumUnit), damage, null)
                    set enumUnit = FirstOfGroup(ENUM_GROUP)
                    exitwhen (enumUnit == null)
                endloop
            endif
        endif
        set casterSelf = null
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local integer casterId = caster.id
        local Data d = Data.create()
        local timer moveTimer = CreateTimer()
        local integer targetId = target.id
        set d.caster = caster
        set d.moveTimer = moveTimer
        set d.target = target
        call AttachIntegerById( casterId, Kataikaze_SCOPE_ID_BASIC, d )
        //! runtextmacro AddEventById( "casterId", "EVENT_CASTER_DEATH" )
        call AttachInteger( moveTimer, Kataikaze_SCOPE_ID, d )
        call AddIntegerToTableById( targetId, Kataikaze_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, Kataikaze_SCOPE_ID ) == TABLE_STARTED ) then
            //! runtextmacro AddEventById( "targetId", "EVENT_TARGET_DEATH" )
        endif
        call RemoveUnitPathing(caster)
        call AddUnitStun(caster, 5)
        call TimerStart( moveTimer, UPDATE_TIME, true, function Move )
        set moveTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    public function Order takes player casterOwner, Unit target returns string
        return TargetConditions_Single( casterOwner, target )
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( ORDERED_UNIT.owner, TARGET_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 300)

        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_CASTER_DEATH", "UnitDies_EVENT_KEY", "0", "function Caster_Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_TARGET_DEATH", "UnitDies_EVENT_KEY", "0", "function Target_Death_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()