//TESH.scrollpos=159
//TESH.alwaysfold=0
//! runtextmacro Scope("CareBear")
    globals
        public constant integer ITEM_ID = 'I015'
        public constant integer SPELL_ID = 'A07C'

        private constant real ACCELERATION = 200.
        private constant real AREA_RANGE = 350.
        private constant string DUMMY_UNIT_EFFECT_PATH = "Abilities\\Spells\\NightElf\\BattleRoar\\RoarTarget.mdl"
        private constant string DUMMY_UNIT_EFFECT_ATTACHMENT_POINT = "overhead"
        private constant integer DUMMY_UNIT_ID = 'n02T'
        private group ENUM_GROUP
        private constant string SPECIAL_EFFECT_PATH = "Abilities\\Spells\\NightElf\\Taunt\\TauntCaster.mdl"
        private constant real SPEED_START = 150.
        private constant real DURATION_FACTOR = SPEED_START / ACCELERATION
        private constant real STUN_DURATION = 10.
        private constant real STUN_HERO_DURATION = 4.
        private boolexpr TARGET_CONDITIONS
        private constant real UPDATE_TIME = 0.035
        private constant real LENGTH = SPEED_START * UPDATE_TIME
        private constant real SPEED_ADD = ACCELERATION * UPDATE_TIME
        private constant real LENGTH_ADD = SPEED_ADD * UPDATE_TIME
    endglobals

    private struct Data
        Unit caster
        unit dummyUnit
        effect dummyUnitEffect
        timer durationTimer
        real lengthX
        real lengthXAdd
        real lengthY
        real lengthYAdd
        group targetGroup
        real targetX
        real targetY
        timer updateTimer
    endstruct

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( GetUnitMagicImmunity( GetUnit(FILTER_UNIT_SELF) ) > 0 ) then
            return false
        endif
        return true
    endfunction

    private function Ending_RemoveDummyUnit takes nothing returns nothing
        local real duration
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, CareBear_SCOPE_ID)
        local Unit caster = d.caster
        local unit dummyUnit = d.dummyUnit
        local unit enumUnit
        local real targetX = d.targetX
        local real targetY = d.targetY
        call SetUnitAnimationByIndex( dummyUnit, 2 )
        call RemoveUnitTimed( dummyUnit, 3 )
        call FlushAttachedInteger( durationTimer, CareBear_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call DestroyEffectWJ( AddSpecialEffectWJ( SPECIAL_EFFECT_PATH, targetX, targetY ) )
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, targetX, targetY, AREA_RANGE, TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit != null ) then
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                if ( IsUnitType( enumUnit, UNIT_TYPE_HERO ) ) then
                    set duration = STUN_HERO_DURATION
                else
                    set duration = STUN_DURATION
                endif
                call SetUnitStunTimed( GetUnit(enumUnit), 1, duration )
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
    endfunction

    private function Ending takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, CareBear_SCOPE_ID)
        local unit dummyUnit = d.dummyUnit
        local effect dummyUnitEffect = d.dummyUnitEffect
        local real targetX = d.targetX
        local real targetY = d.targetY
        local timer updateTimer = d.updateTimer
        call FlushAttachedInteger( updateTimer, CareBear_SCOPE_ID )
        call DestroyTimerWJ( updateTimer )
        set updateTimer = null
        call SetUnitAnimationByIndex( dummyUnit, 4 )
        call SetUnitXWJ( dummyUnit, targetX )
        call SetUnitYWJ( dummyUnit, targetY )
        call DestroyEffectWJ( dummyUnitEffect )
        set dummyUnitEffect = null
        call TimerStart( durationTimer, 0.8, false, function Ending_RemoveDummyUnit )
        set durationTimer = null
    endfunction

    private function Move takes nothing returns nothing
        local timer updateTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(updateTimer, CareBear_SCOPE_ID)
        local unit dummyUnit = d.dummyUnit
        local real lengthX = d.lengthX + d.lengthXAdd
        local real lengthY = d.lengthY + d.lengthYAdd
        set d.lengthX = lengthX
        set d.lengthY = lengthY
        call SetUnitXWJ( dummyUnit, GetUnitX( dummyUnit ) + lengthX )
        call SetUnitYWJ( dummyUnit, GetUnitY( dummyUnit ) + lengthY )
        set dummyUnit = null
    endfunction

    public function SpellEffect takes Unit caster, real targetX, real targetY returns nothing
        local real angle
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local Data d = Data.create()
        local real distance = DistanceByCoordinates( casterX, casterY, targetX, targetY )
        local timer durationTimer = CreateTimerWJ()
        local unit dummyUnit
        local group targetGroup = CreateGroupWJ()
        local timer updateTimer = CreateTimerWJ()
        if ( distance != 0 ) then
            set angle = Atan2( targetY - casterY, targetX - casterX )
        else
            set angle = GetUnitFacingWJ( casterSelf )
        endif
        set casterSelf = null
        set dummyUnit = CreateUnitWJ( caster.owner, DUMMY_UNIT_ID, casterX, casterY, angle )
        set d.caster = caster
        set d.dummyUnit = dummyUnit
        set d.dummyUnitEffect = AddSpecialEffectTargetWJ( DUMMY_UNIT_EFFECT_PATH, dummyUnit, DUMMY_UNIT_EFFECT_ATTACHMENT_POINT )
        set d.durationTimer = durationTimer
        set d.lengthX = LENGTH * Cos(angle)
        set d.lengthXAdd = LENGTH_ADD * Cos(angle)
        set d.lengthY = LENGTH * Sin(angle)
        set d.lengthYAdd = LENGTH_ADD * Sin(angle)
        set d.targetGroup = CreateGroupWJ()
        set d.targetX = targetX
        set d.targetY = targetY
        set d.updateTimer = updateTimer
        call AttachInteger( durationTimer, CareBear_SCOPE_ID, d )
        call AttachInteger( updateTimer, CareBear_SCOPE_ID, d )
        call SetUnitAnimationByIndex( dummyUnit, 0 )
        set dummyUnit = null
        call TimerStart( updateTimer, UPDATE_TIME, true, function Move )
        set updateTimer = null
        call TimerStart( durationTimer, -DURATION_FACTOR + SquareRoot( DURATION_FACTOR * DURATION_FACTOR + distance / ACCELERATION * 2 ), false, function Ending )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_X, TARGET_Y )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        set ENUM_GROUP = CreateGroupWJ()
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call SetItemTypeGoldCost(d, 150)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 30)
        call SetItemTypeRefreshIntervalStart(d, 120)

        call InitEffectType( DUMMY_UNIT_EFFECT_PATH )
        call InitUnitType( DUMMY_UNIT_ID )
        call InitEffectType( SPECIAL_EFFECT_PATH )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()