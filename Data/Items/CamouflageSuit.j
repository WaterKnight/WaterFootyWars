//TESH.scrollpos=130
//TESH.alwaysfold=0
//! runtextmacro Scope("CamouflageSuit")
    globals
        public constant integer ITEM_ID = 'I02C'
        public constant integer SPELL_ID = 'A08I'

        private constant string AREA_EFFECT_PATH = "Abilities\\Spells\\Other\\Silence\\SilenceAreaBirth.mdl"
        private constant real AREA_RANGE = 500.
        private constant real DURATION = 15.
        private group ENUM_GROUP
        private boolexpr TARGET_CONDITIONS
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\NightElf\\FaerieDragonInvis\\FaerieDragon_Invis.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "chest"
    endglobals

    private struct Data
        timer durationTimer
        Unit target
    endstruct

    private function Ending takes Data d, timer durationTimer, Unit target returns nothing
        local integer targetId = target.id
        call d.destroy()
        call FlushAttachedInteger( durationTimer, CamouflageSuit_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        call FlushAttachedIntegerById( targetId, CamouflageSuit_SCOPE_ID )
        //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        //! runtextmacro RemoveEventById( "targetId", "EVENT_ORDER_EXECUTE" )
        call RemoveUnitInvisibility( target )
    endfunction

    public function Death takes Unit target returns nothing
        local Data d = GetAttachedIntegerById(target.id, CamouflageSuit_SCOPE_ID)
        if (d != NULL) then
            call Ending(d, d.durationTimer, target)
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, CamouflageSuit_SCOPE_ID)
        call Ending( d, durationTimer, d.target )
        set durationTimer = null
    endfunction

    public function OrderExecute takes Unit target, integer triggerOrder returns nothing
        local Data d = GetAttachedIntegerById(target.id, CamouflageSuit_SCOPE_ID)
        if (d != NULL) then
            if ((triggerOrder != STOP_ORDER_ID) and (triggerOrder != HOLD_POSITION_ORDER_ID)) then
                call Ending(d, d.durationTimer, target)
            endif
        endif
    endfunction

    private function OrderExecute_Event takes nothing returns nothing
        call OrderExecute( ORDERED_UNIT, TRIGGER_ORDER )
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) == false ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_HERO ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        return true
    endfunction

    private function StartTarget takes Unit target returns nothing
        local timer durationTimer
        local integer targetId = target.id
        local Data d = GetAttachedIntegerById( targetId, CamouflageSuit_SCOPE_ID )
        local boolean isNew = (d == NULL)
        local unit targetSelf = target.self
        call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, target.self, TARGET_EFFECT_ATTACHMENT_POINT ) )
        if ( isNew ) then
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set d.durationTimer = durationTimer
            set d.target = target
            call AttachInteger( durationTimer, CamouflageSuit_SCOPE_ID, d )
            call AttachIntegerById( targetId, CamouflageSuit_SCOPE_ID, d )
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
            //! runtextmacro AddEventById( "targetId", "EVENT_ORDER_EXECUTE" )
        else
            set durationTimer = d.durationTimer
        endif
        if ( isNew ) then
            call AddUnitInvisibility( target )
        endif
        call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
        set durationTimer = null

        if ( GetUnitCurrentOrder( targetSelf ) == ATTACK_ORDER_ID ) then
            call IssueImmediateOrderById(targetSelf, STOP_ORDER_ID)
        endif
        set targetSelf = null
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local unit enumUnit
        set casterSelf = null
        call DestroyEffectWJ( AddSpecialEffectWJ( AREA_EFFECT_PATH, casterX, casterY ) )
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, casterX, casterY, AREA_RANGE, TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if (enumUnit != null) then
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                call StartTarget(GetUnit(enumUnit))
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 400)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 100)
        call SetItemTypeRefreshIntervalStart(d, 100)

        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_ORDER_EXECUTE", "UnitGetsOrder_Executed_Executed_EVENT_KEY", "0", "function OrderExecute_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( AREA_EFFECT_PATH )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call InitEffectType( TARGET_EFFECT_PATH )
    endfunction
//! runtextmacro Endscope()