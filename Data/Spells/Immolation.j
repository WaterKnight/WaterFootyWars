//TESH.scrollpos=97
//TESH.alwaysfold=0
//! runtextmacro Scope("Immolation")
    globals
        public constant integer SPELL_ID = 'A03S'

        private constant real AREA_RANGE = 250.
        private constant real INTERVAL = 2.
        private constant real DAMAGE_PER_INTERVAL = 15 * INTERVAL
        private group ENUM_GROUP
        private boolexpr TARGET_CONDITIONS
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\NightElf\\Immolation\\ImmolationDamage.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "head"
    endglobals

    private struct Data
        Unit caster
        timer intervalTimer
    endstruct

    public function Death takes Unit caster returns nothing
        local integer casterId = caster.id
        local Data d = GetAttachedIntegerById(casterId, Immolation_SCOPE_ID)
        local timer intervalTimer
        if ( d != NULL ) then
            set intervalTimer = d.intervalTimer
            call FlushAttachedIntegerById( casterId, Immolation_SCOPE_ID )
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
            call FlushAttachedInteger( intervalTimer, Immolation_SCOPE_ID )
            call DestroyTimerWJ( intervalTimer )
            set intervalTimer = null
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) ) then
            return false
        endif
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_FLYING ) != TEMP_BOOLEAN ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        set FILTER_UNIT = GetUnit(FILTER_UNIT_SELF)
        if ( GetUnitInvulnerability( FILTER_UNIT ) > 0 ) then
            return false
        endif
        if ( IsUnitWard( FILTER_UNIT ) ) then
            return false
        endif
        return true
    endfunction

    private function Interval takes nothing returns nothing
        local unit enumUnit
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, Immolation_SCOPE_ID)
        local Unit caster = d.caster
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        set intervalTimer = null
        set TEMP_BOOLEAN = IsUnitType( casterSelf, UNIT_TYPE_FLYING )
        set casterSelf = null
        set TEMP_PLAYER = caster.owner
        set TEMP_UNIT_SELF = casterSelf
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, casterX, casterY, AREA_RANGE, TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit != null ) then
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, enumUnit, TARGET_EFFECT_ATTACHMENT_POINT ) )
                call UnitDamageUnitBySpell( caster, GetUnit(enumUnit), DAMAGE_PER_INTERVAL )
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
    endfunction

    public function Learn takes Unit caster returns nothing
        local integer casterId = caster.id
        local Data d = GetAttachedIntegerById(casterId, Immolation_SCOPE_ID)
        local timer intervalTimer
        if ( d == NULL) then
            set d = Data.create()
            set intervalTimer = CreateTimerWJ()
            set d.caster = caster
            set d.intervalTimer = intervalTimer
            call AttachIntegerById( casterId, Immolation_SCOPE_ID, d )
            //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
            call AttachInteger( intervalTimer, Immolation_SCOPE_ID, d )
            call TimerStart( intervalTimer, INTERVAL, true, function Interval )
            set intervalTimer = null
        endif
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( TARGET_EFFECT_PATH )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
    endfunction
//! runtextmacro Endscope()