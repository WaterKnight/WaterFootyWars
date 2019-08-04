//TESH.scrollpos=125
//TESH.alwaysfold=0
//! runtextmacro Scope("DreadCall")
    globals
        private constant integer ORDER_ID = 852105//OrderId( "evileye" )
        public constant integer SPELL_ID = 'A075'

        private constant real AREA_RANGE = 300.
        private constant string AREA_EFFECT_PATH = "Abilities\\Spells\\Other\\HowlOfTerror\\HowlCaster.mdl"
        private constant real DURATION = 8.
        private group ENUM_GROUP
        private constant real HERO_DURATION = 5.
        private boolexpr TARGET_CONDITIONS
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Other\\HowlOfTerror\\HowlTarget.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "origin"
    endglobals

    private struct Data
        timer durationTimer
        Unit target
        effect targetEffect
    endstruct

    private function Ending takes Data d, timer durationTimer, Unit target returns nothing
        local effect targetEffect = d.targetEffect
        local integer targetId = target.id
        call d.destroy()
        call FlushAttachedInteger( durationTimer, DreadCall_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        call FlushAttachedIntegerById( targetId, DreadCall_SCOPE_ID )
        //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        //! runtextmacro RemoveEventById( "targetId", "EVENT_DISPEL" )
        call DestroyEffectWJ( targetEffect )
        set targetEffect = null
        call RemoveUnitAttackSilence( target )
    endfunction

    public function Dispel takes Unit target returns nothing
        local Data d = GetAttachedIntegerById(target.id, DreadCall_SCOPE_ID)
        if ( d != NULL ) then
            call Ending( d, d.durationTimer, target )
        endif
    endfunction

    private function Dispel_Event takes nothing returns nothing
        call Dispel( TRIGGER_UNIT )
    endfunction

    public function Death takes Unit target returns nothing
        call Dispel( target )
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, DreadCall_SCOPE_ID)
        call Ending( d, durationTimer, d.target )
        set durationTimer = null
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        set FILTER_UNIT = GetUnit( FILTER_UNIT_SELF )
        if ( IsUnitIllusionWJ( FILTER_UNIT ) ) then
            return false
        endif
        if ( GetUnitMagicImmunity( FILTER_UNIT ) > 0 ) then
            return false
        endif
        return true
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local Data d
        local real duration
        local timer durationTimer
        local Unit enumUnit
        local integer enumUnitId
        local unit enumUnitSelf
        set casterSelf = null
        call DestroyEffectWJ( AddSpecialEffectWJ( AREA_EFFECT_PATH, casterX, casterY ) )
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, casterX, casterY, AREA_RANGE, TARGET_CONDITIONS )
        set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
        if ( enumUnitSelf != null ) then
            loop
                set enumUnit = GetUnit(enumUnitSelf)
                set enumUnitId = enumUnit.id
                call GroupRemoveUnit( ENUM_GROUP, enumUnitSelf )
                set d = GetAttachedIntegerById( enumUnitId, DreadCall_SCOPE_ID )
                if ( d == NULL ) then
                    set d = Data.create()
                    set durationTimer = CreateTimerWJ()
                    set d.durationTimer = durationTimer
                    set d.target = enumUnit
                    call AttachInteger( durationTimer, DreadCall_SCOPE_ID, d )
                    call AttachIntegerById( enumUnitId, DreadCall_SCOPE_ID, d )
                    //! runtextmacro AddEventById( "enumUnitId", "EVENT_DEATH" )
                    //! runtextmacro AddEventById( "enumUnitId", "EVENT_DISPEL" )
                    call AddUnitAttackSilence( enumUnit )
                else
                    set durationTimer = d.durationTimer
                    call DestroyEffectWJ( d.targetEffect )
                endif
                set d.targetEffect = AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, enumUnitSelf, TARGET_EFFECT_ATTACHMENT_POINT )
                if ( IsUnitType( enumUnitSelf, UNIT_TYPE_HERO ) ) then
                    set duration = HERO_DURATION
                else
                    set duration = DURATION
                endif
                call TimerStart( durationTimer, duration, false, function EndingByTimer )
                set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnitSelf == null )
            endloop
            set durationTimer = null
        endif
    endfunction

    public function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_DISPEL", "UnitIsDispelled_EVENT_KEY_NEGATIVE", "0", "function Dispel_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( AREA_EFFECT_PATH )
        call InitEffectType( TARGET_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function DreadCall_SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()