//TESH.scrollpos=165
//TESH.alwaysfold=0
//! runtextmacro Scope("MecaPenguin")
    globals
        public constant integer ITEM_ID = 'I005'
        public constant integer SPELL_ID = 'A00E'

        private constant real AREA_RANGE = 250.
        private constant real DAMAGE = 140.
        private group ENUM_GROUP
        private constant real INTERVAL = 1.
        private constant integer MAX_COUNTS_AMOUNT = 3
        private constant real DURATION = MAX_COUNTS_AMOUNT * INTERVAL
        private constant string SPECIAL_EFFECT_PATH = "Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl"
        private constant real SPEED = 160.
        private constant real START_OFFSET = 50.
        private constant real UPDATE_TIME = 0.035
        private constant real LENGTH = SPEED * UPDATE_TIME
        private boolexpr TARGET_CONDITIONS
    endglobals

    private struct Data
        Unit caster
        timer countdownTimer
        integer countsAmount
        timer durationTimer
        real lengthX
        real lengthY
        timer moveTimer
        Unit penguin
    endstruct

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_FLYING ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_HERO ) ) then
            return false
        endif
        if (GetUnitInvulnerability(GetUnit(FILTER_UNIT_SELF)) > 0) then
            return false
        endif
        return true
    endfunction

    private function Ending takes Data d, timer durationTimer, Unit penguin, player protectedPlayer returns nothing
        local timer countdownTimer = d.countdownTimer
        local unit enumUnit
        local Unit caster = d.caster
        local timer moveTimer = d.moveTimer
        local unit penguinSelf = penguin.self
        local real penguinX = GetUnitX( penguinSelf )
        local real penguinY = GetUnitY( penguinSelf )
        set penguinSelf = null
        call d.destroy()
        call FlushAttachedInteger( countdownTimer, MecaPenguin_SCOPE_ID )
        call DestroyTimerWJ( countdownTimer )
        set countdownTimer = null
        call FlushAttachedInteger( durationTimer, MecaPenguin_SCOPE_ID)
        call DestroyTimerWJ( durationTimer )
        call FlushAttachedInteger( moveTimer, MecaPenguin_SCOPE_ID )
        call DestroyTimerWJ( moveTimer )
        set moveTimer = null
        call FlushAttachedIntegerById( penguin.id, MecaPenguin_SCOPE_ID )
        call DestroyEffectWJ( AddSpecialEffectWJ( SPECIAL_EFFECT_PATH, penguinX, penguinY ) )
        call RemoveUnitEx( penguin )
        set TEMP_PLAYER = protectedPlayer
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, penguinX, penguinY, AREA_RANGE, TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit != null ) then
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                call UnitDamageUnitBySpell( caster, GetUnit(enumUnit), DAMAGE )
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, MecaPenguin_SCOPE_ID)
        local Unit penguin = d.penguin
        call Ending( d, durationTimer, penguin, penguin.owner )
        set durationTimer = null
    endfunction

    public function Select takes Unit penguin, player triggerPlayer returns nothing
        local Data d = GetAttachedIntegerById( penguin.id, MecaPenguin_SCOPE_ID )
        if ( d != NULL ) then
            if ( d.caster.owner == triggerPlayer ) then
                call Ending( d, d.durationTimer, penguin, null )
            endif
        endif
    endfunction

    private function Countdown takes nothing returns nothing
        local timer countdownTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(countdownTimer, MecaPenguin_SCOPE_ID)
        local integer countsAmount = d.countsAmount - 1
        local Unit penguin = d.penguin
        local unit penguinSelf = penguin.self
        set countdownTimer = null
        set d.countsAmount = countsAmount
        call CreateRisingTextTag( I2S( countsAmount ), 0.03, GetUnitX(penguinSelf), GetUnitY(penguinSelf), 0, 75, 200, 200, 200, 255, 1, 3 )
        set penguinSelf = null
    endfunction

    private function Move takes nothing returns nothing
        local timer moveTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(moveTimer, MecaPenguin_SCOPE_ID)
        local Unit penguin = d.penguin
        local unit penguinSelf = penguin.self
        local real penguinX = GetUnitX( penguinSelf )
        local real penguinY = GetUnitY( penguinSelf )
        set moveTimer = null
        call SetUnitXYIfNotBlocked( penguinSelf, penguinX, penguinY, penguinX + d.lengthX, penguinY + d.lengthY )
        set penguinSelf = null
    endfunction

    public function SpellEffect takes Unit caster, real targetX, real targetY returns nothing
        local real angle
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local timer countdownTimer = CreateTimerWJ()
        local Data d = Data.create()
        local timer durationTimer = CreateTimerWJ()
        local real lengthX
        local real lengthY
        local timer moveTimer = CreateTimerWJ()
        local real partX
        local real partY
        local Unit penguin
        if ( ( casterX != targetX ) or ( casterY != targetY ) ) then
            set angle = Atan2( targetY - casterY, targetX - casterX )
        else
            set angle = GetUnitFacingWJ( casterSelf )
        endif
        set casterSelf = null
        set partX = Cos( angle )
        set partY = Sin( angle )
        set penguin = CreateUnitEx( NEUTRAL_PASSIVE_PLAYER, MECA_PENGUIN_UNIT_ID, casterX + START_OFFSET * partX, casterY + START_OFFSET * partY, angle )
        set d.caster = caster
        set d.countdownTimer = countdownTimer
        set d.countsAmount = MAX_COUNTS_AMOUNT
        set d.durationTimer = durationTimer
        set d.lengthX = LENGTH * partX
        set d.lengthY = LENGTH * partY
        set d.moveTimer = moveTimer
        set d.penguin = penguin
        call AttachInteger( countdownTimer, MecaPenguin_SCOPE_ID, d )
        call AttachInteger( durationTimer, MecaPenguin_SCOPE_ID, d )
        call AttachInteger( moveTimer, MecaPenguin_SCOPE_ID, d )
        call AttachIntegerById( penguin.id, MecaPenguin_SCOPE_ID, d )
        call SetUnitAnimationByIndex( penguin.self, 4 )
        call TimerStart( moveTimer, UPDATE_TIME, true, function Move )
        set moveTimer = null
        call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
        set durationTimer = null
        call TimerStart( countdownTimer, INTERVAL, true, function Countdown )
        set countdownTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_X, TARGET_Y )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 125)
        call SetItemTypeMaxCharges(d, 2)
        call SetItemTypeRefreshInterval(d, 55)
        call SetItemTypeRefreshIntervalStart(d, 90)
    
        set ENUM_GROUP = CreateGroupWJ()
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( SPECIAL_EFFECT_PATH )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()