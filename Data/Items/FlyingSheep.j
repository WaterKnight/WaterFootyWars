//TESH.scrollpos=196
//TESH.alwaysfold=0
//! runtextmacro Scope("FlyingSheep")
    globals
        public constant integer ITEM_ID = 'I01J'
        public constant integer SPELL_ID = 'A06K'

        private constant real AREA_RANGE = 250.
        private constant real DAMAGE = 150.
        private constant string DUMMY_UNIT_EFFECT_PATH = "Abilities\\Weapons\\DemolisherFireMissile\\DemolisherFireMissile.mdl"
        private constant string DUMMY_UNIT_EFFECT_ATTACHMENT_POINT = "origin"
        private constant integer DUMMY_UNIT_ID = 'h00Y'
        private group ENUM_GROUP
        private boolexpr TARGET_CONDITIONS
        private constant real UPDATE_TIME = 0.035
        private constant real LENGTH = 500 * UPDATE_TIME
    endglobals

    private struct Data
        Unit caster
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

    private function Ending takes Data d, unit dummyUnit, boolean isTargetNotNull, timer moveTimer, Unit target returns nothing
        local integer targetId
        call d.destroy()
        call SetUnitAnimation( dummyUnit, "death" )
        call RemoveUnitTimed( dummyUnit, 2 )
        if ( isTargetNotNull ) then
            set targetId = target.id
            call RemoveIntegerFromTableById( targetId, FlyingSheep_SCOPE_ID, d )
            if ( CountIntegersInTableById( targetId, FlyingSheep_SCOPE_ID ) == TABLE_EMPTY ) then
                //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
            endif
        endif
        call FlushAttachedInteger( moveTimer, FlyingSheep_SCOPE_ID )
        call DestroyTimerWJ( moveTimer )
    endfunction

    private function ResetTarget takes Data d, Unit target, real targetX, real targetY, real targetZ returns nothing
        local integer targetId = target.id
        set d.target = NULL
        call RemoveIntegerFromTableById( targetId, FlyingSheep_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, FlyingSheep_SCOPE_ID ) == TABLE_EMPTY ) then
            //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        endif
        set d.targetX = targetX
        set d.targetY = targetY
        set d.targetZ = targetZ
    endfunction

    public function Death takes Unit target, real targetX, real targetY, real targetZ returns nothing
        local Data d
        local integer targetId = target.id
        local integer iteration = CountIntegersInTableById( targetId, FlyingSheep_SCOPE_ID )
        if ( iteration > TABLE_EMPTY ) then
            loop
                set d = GetIntegerFromTableById( targetId, FlyingSheep_SCOPE_ID, iteration )
                call ResetTarget( d, target, targetX, targetY, targetZ )
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

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) ) then
            return false
        endif
        if (GetUnitInvulnerability(GetUnit(FILTER_UNIT_SELF)) > 0) then
            return false
        endif
        return true
    endfunction

    private function Move takes nothing returns nothing
        local real angleLengthXYZ
        local real angleXY
        local Unit caster
        local real distanceX
        local real distanceY
        local real distanceZ
        local unit enumUnit
        local boolean isTargetNotNull
        local real lengthXY
        local timer moveTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(moveTimer, FlyingSheep_SCOPE_ID)
        local unit dummyUnit = d.dummyUnit
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
            call DestroyEffectWJ(AddSpecialEffectTargetWJ(DUMMY_UNIT_EFFECT_PATH, dummyUnit, DUMMY_UNIT_EFFECT_ATTACHMENT_POINT))
            call Ending( d, dummyUnit, isTargetNotNull, moveTimer, target )
            set TEMP_PLAYER = caster.owner
            call GroupEnumUnitsInRangeWithCollision(ENUM_GROUP, x, y, AREA_RANGE, TARGET_CONDITIONS)
            set enumUnit = FirstOfGroup(ENUM_GROUP)
            if (enumUnit != null) then
                loop
                    call GroupRemoveUnit(ENUM_GROUP, enumUnit)
                    call UnitDamageUnitBySpell( caster, GetUnit(enumUnit), DAMAGE )
                    set enumUnit = FirstOfGroup(ENUM_GROUP)
                    exitwhen (enumUnit == null)
                endloop
            endif
        else
            set d.x = x
            set d.y = y
            set d.z = z
        endif
        set moveTimer = null
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local unit casterSelf = caster.self
        local real casterX = GetUnitX(casterSelf)
        local real casterY = GetUnitY(casterSelf)
        local real casterZ = GetUnitZ( casterSelf, casterX, casterY ) + GetUnitOutpactZ(caster)
        local Data d = Data.create()
        local unit dummyUnit = CreateUnitWJ( caster.owner, DUMMY_UNIT_ID, casterX, casterY, GetUnitFacingWJ( casterSelf ) )
        local timer moveTimer = CreateTimerWJ()
        local integer targetId = target.id
        set casterSelf = null
        set d.caster = caster
        set d.dummyUnit = dummyUnit
        set d.target = target
        set d.x = casterX
        set d.y = casterY
        set d.z = casterZ
        call AttachInteger( moveTimer, FlyingSheep_SCOPE_ID, d )
        call AddIntegerToTableById( targetId, FlyingSheep_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, FlyingSheep_SCOPE_ID ) == TABLE_STARTED ) then
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
        endif
        call SetUnitZ( dummyUnit, casterX, casterY, casterZ )
        call PlaySoundFromTypeOnUnit( FLYING_SHEEP_SOUND_TYPE, dummyUnit )
        set dummyUnit = null
        call TimerStart( moveTimer, UPDATE_TIME, true, function Move )
        set moveTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 200)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 60)
        call SetItemTypeRefreshIntervalStart(d, 200)

        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        set TARGET_CONDITIONS = ConditionWJ(function TargetConditions)
        call InitUnitType( DUMMY_UNIT_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()