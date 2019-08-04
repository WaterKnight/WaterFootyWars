//TESH.scrollpos=108
//TESH.alwaysfold=0
//! runtextmacro Scope("HealingWard")
    globals
        public constant integer ITEM_ID = 'I018'
        public constant integer SPELL_ID = 'A07I'

        private constant real AREA_RANGE = 400.
        private constant real DURATION = 30.
        private group ENUM_GROUP
        private constant real INTERVAL = 1.
        private constant real RELATIVE_REFRESHED_LIFE_PER_INTERVAL = 0.04
        private boolexpr TARGET_CONDITIONS
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Other\\ANrm\\ANrmTarget.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        private constant string WARD_EFFECT_PATH = "Abilities\\Spells\\Orc\\CommandAura\\CommandAura.mdl"
        private constant string WARD_EFFECT_ATTACHMENT_POINT = "origin"
    endglobals

    private struct Data
        timer intervalTimer
        Unit ward
        effect wardEffect
    endstruct

    public function Death takes Unit ward returns nothing
        local timer intervalTimer
        local effect wardEffect
        local integer wardId = ward.id
        local Data d = GetAttachedIntegerById( wardId, HealingWard_SCOPE_ID )
        if ( d != NULL ) then
            set intervalTimer = d.intervalTimer
            set wardEffect = d.wardEffect
            call d.destroy()
            call FlushAttachedInteger( intervalTimer, HealingWard_SCOPE_ID )
            call DestroyTimerWJ( intervalTimer )
            set intervalTimer = null
            call FlushAttachedIntegerById( wardId, HealingWard_SCOPE_ID )
            //! runtextmacro RemoveEventById( "wardId", "EVENT_DEATH" )
            call DestroyEffectWJ( wardEffect )
            set wardEffect = null
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitEnemy( FILTER_UNIT_SELF, TEMP_PLAYER ) ) then
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
        return true
    endfunction

    private function Interval takes Unit ward returns nothing
        local unit enumUnit
        local unit wardSelf = ward.self
        set TEMP_PLAYER = ward.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, GetUnitX(wardSelf), GetUnitY(wardSelf), AREA_RANGE, TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit != null ) then
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                call DestroyEffectTimed(AddSpecialEffectTargetWJ(TARGET_EFFECT_PATH, enumUnit, TARGET_EFFECT_ATTACHMENT_POINT), 1)
                call HealUnitBySpell(GetUnit(enumUnit), RELATIVE_REFRESHED_LIFE_PER_INTERVAL * GetUnitState(enumUnit, UNIT_STATE_MAX_LIFE))
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
        set wardSelf = null
    endfunction

    private function IntervalByTimer takes nothing returns nothing
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, HealingWard_SCOPE_ID)
        set intervalTimer = null
        call Interval( d.ward )
    endfunction

    public function SpellEffect takes Unit caster, real targetX, real targetY returns nothing
        local Data d = Data.create()
        local timer intervalTimer = CreateTimerWJ()
        local Unit ward = CreateUnitEx( caster.owner, HEALING_WARD_UNIT_ID, targetX, targetY, STANDARD_ANGLE )
        local integer wardId = ward.id
        local unit wardSelf = ward.self
        set d.intervalTimer = intervalTimer
        set d.ward = ward
        set d.wardEffect = AddSpecialEffectTargetWJ( WARD_EFFECT_PATH, wardSelf, WARD_EFFECT_ATTACHMENT_POINT )
        call AttachInteger( intervalTimer, HealingWard_SCOPE_ID, d )
        call AttachIntegerById( wardId, HealingWard_SCOPE_ID, d )
        //! runtextmacro AddEventById( "wardId", "EVENT_DEATH" )
        call PlaySoundFromTypeOnUnit( HEALING_WARD_SOUND_TYPE, wardSelf )
        call TimerStart( intervalTimer, INTERVAL, true, function IntervalByTimer )
        call Interval( ward )
        call UnitApplyTimedLifeWJ( wardSelf, DURATION )
        set wardSelf = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_X, TARGET_Y )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 400)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 80)
        call SetItemTypeRefreshIntervalStart(d, 300)

        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call InitEffectType( TARGET_EFFECT_PATH )
        call InitEffectType( WARD_EFFECT_PATH )
    endfunction
//! runtextmacro Endscope()