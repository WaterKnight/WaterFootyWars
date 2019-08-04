//TESH.scrollpos=129
//TESH.alwaysfold=0
//! runtextmacro Scope("VioletDefense")
    globals
        public constant integer ORDER_ID = 852132//OrderId( "autodispel" )
        public constant integer SPELL_ID = 'A07W'

        private constant real BONUS_ARMOR_BY_SPELL = 0.3
        private constant real DURATION = 30.
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
        call FlushAttachedInteger(durationTimer, VioletDefense_SCOPE_ID)
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call FlushAttachedIntegerById(targetId, VioletDefense_SCOPE_ID)
        //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        //! runtextmacro RemoveEventById( "targetId", "EVENT_DISPEL" )
        call AddUnitArmorBySpellBonus( target, -BONUS_ARMOR_BY_SPELL )
        call DestroyEffectWJ( targetEffect )
        set targetEffect = null
    endfunction

    public function Dispel takes Unit target returns nothing
        local Data d = GetAttachedIntegerById(target.id, VioletDefense_SCOPE_ID)
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
        local Data d = GetAttachedInteger(durationTimer, VioletDefense_SCOPE_ID)
        call Ending( d, durationTimer, d.target )
        set durationTimer = null
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local player casterOwner = caster.owner
        local timer durationTimer
        local integer targetId = target.id
        local Data d = GetAttachedIntegerById(targetId, VioletDefense_SCOPE_ID)
        local boolean isNew = ( d == NULL )
        set casterOwner = null
        if ( isNew ) then
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set d.durationTimer = durationTimer
            set d.target = target
            call AttachInteger( durationTimer, VioletDefense_SCOPE_ID, d )
            call AttachIntegerById( targetId, VioletDefense_SCOPE_ID, d )
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
            //! runtextmacro AddEventById( "targetId", "EVENT_DISPEL" )
        else
            set durationTimer = d.durationTimer
            call DestroyEffectWJ( d.targetEffect )
        endif
        set d.targetEffect = AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, target.self, TARGET_EFFECT_ATTACHMENT_POINT )
        if ( isNew ) then
            call AddUnitArmorBySpellBonus( target, BONUS_ARMOR_BY_SPELL )
        endif
        call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    private function TargetConditions_Single_String takes player casterOwner, Unit checkingUnit returns string
        set TEMP_UNIT_SELF = checkingUnit.self
        if ( IsUnitAlly( TEMP_UNIT_SELF, casterOwner ) == false ) then
            return ErrorStrings_ONLY_ALLY
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return ErrorStrings_NOT_STRUCTURE
        endif
        if ( IsUnitWard( checkingUnit ) ) then
            return ErrorStrings_NOT_WARD
        endif
        return null
    endfunction

    public function Order takes Unit caster, Unit target returns string
        return TargetConditions_Single_String( caster.owner, target )
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( ORDERED_UNIT, TARGET_UNIT )
    endfunction

    //! runtextmacro Scope("Automatic")
        globals
            public constant integer Automatic_ACTIVATION_ORDER_ID = 852133//OrderId( "autodispelon" )
            public constant integer Automatic_DEACTIVATION_ORDER_ID = 852134//OrderId( "autodispeloff" )

            private constant real Automatic_AREA_RANGE = 500.
            private group Automatic_ENUM_GROUP
            private boolexpr Automatic_TARGET_CONDITIONS
        endglobals

        private function Automatic_TargetConditions takes nothing returns boolean
            set FILTER_UNIT_SELF = GetFilterUnit()
            if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
                return false
            endif
            set FILTER_UNIT = GetUnit(FILTER_UNIT_SELF)
            if ( TargetConditions_Single_String( TEMP_PLAYER, FILTER_UNIT ) != null ) then
                return false
            endif
            if ( GetAttachedIntegerById( FILTER_UNIT.id, VioletDefense_SCOPE_ID ) != NULL ) then
                return false
            endif
            return true
        endfunction

        public function Automatic_TargetInRange takes Unit caster, player casterOwner returns nothing
            local unit casterSelf
            local unit enumUnit
            if ( GetUnitAutomaticAbility(caster) == SPELL_ID ) then
                set casterSelf = caster.self
                set TEMP_PLAYER = casterOwner
                call GroupEnumUnitsInRangeWithCollision( Automatic_ENUM_GROUP, GetUnitX( casterSelf ), GetUnitY( casterSelf ), Automatic_AREA_RANGE, Automatic_TARGET_CONDITIONS )
                set enumUnit = GetRandomUnit( Automatic_ENUM_GROUP )
                if ( enumUnit != null ) then
                    call IssueTargetOrderByIdTimed( caster, ORDER_ID, GetUnit(enumUnit), 0 )
                    set enumUnit = null
                endif
                set casterSelf = null
            endif
        endfunction

        private function Automatic_TargetInRange_Event takes nothing returns nothing
            call Automatic_TargetInRange( TRIGGER_UNIT, TRIGGER_UNIT.owner )
        endfunction

        public function Automatic_Activation_Order takes Unit caster returns nothing
            //! runtextmacro AddEventById( "caster.id", "Automatic_EVENT_ACQUIRE" )
            call SetUnitAutomaticAbility(caster, SPELL_ID)
        endfunction

        private function Automatic_Activation_Order_Event takes nothing returns nothing
            call Automatic_Activation_Order( ORDERED_UNIT )
        endfunction

        public function Automatic_Deactivation_Order takes Unit caster returns nothing
            //! runtextmacro RemoveEventById( "caster.id", "Automatic_EVENT_ACQUIRE" )
            call SetUnitAutomaticAbility(caster, 0)
        endfunction

        private function Automatic_Deactivation_Order_Event takes nothing returns nothing
            call Automatic_Deactivation_Order( ORDERED_UNIT )
        endfunction

        public function Automatic_Init takes nothing returns nothing
            set Automatic_ENUM_GROUP = CreateGroupWJ()
            set Automatic_TARGET_CONDITIONS = ConditionWJ( function Automatic_TargetConditions )
            call AddOrderAbility( Automatic_ACTIVATION_ORDER_ID, SPELL_ID )
            call AddOrderAbility( Automatic_DEACTIVATION_ORDER_ID, SPELL_ID )
            //! runtextmacro CreateEvent( "Automatic_EVENT_ACQUIRE", "UnitAcquiresTarget_EVENT_KEY", "0", "function Automatic_TargetInRange_Event" )
            //! runtextmacro AddNewEventById( "Automatic_EVENT_ACTIVATION_ORDER", "GetAbilityOrderId( SPELL_ID, Automatic_ACTIVATION_ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Automatic_Activation_Order_Event" )
            //! runtextmacro AddNewEventById( "Automatic_EVENT_DEACTIVATION_ORDER", "GetAbilityOrderId( SPELL_ID, Automatic_DEACTIVATION_ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Automatic_Deactivation_Order_Event" )
        endfunction
    //! runtextmacro Endscope()

    public function Init takes nothing returns nothing
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_DISPEL", "UnitIsDispelled_EVENT_KEY_POSITIVE", "0", "function Dispel_Event" )
        call InitEffectType( TARGET_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call Automatic_Automatic_Init()
    endfunction
//! runtextmacro Endscope()