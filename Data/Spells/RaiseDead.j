//TESH.scrollpos=126
//TESH.alwaysfold=0
//! runtextmacro Scope("RaiseDead")
    globals
        public constant integer ORDER_ID = 852132//OrderId( "autodispel" )
        public constant integer SPELL_ID = 'A014'

        private constant real AREA_RANGE = 350.
        private constant real DURATION = 30.
        private group ENUM_GROUP
        private constant real RELEASE_TIME = 2.
        private constant integer SPAWNS_AMOUNT = 2
        private constant integer SPAWN_ID = 'u00B'
        private constant string SPECIAL_EFFECT_PATH = "Abilities\\Spells\\Undead\\RaiseSkeletonWarrior\\RaiseSkeleton.mdl"
        private boolexpr TARGET_CONDITIONS
    endglobals

    private struct Data
        timer releaseTimer
        Unit spawn
    endstruct

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) > 0 ) then
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
        if ( GetUnitCanNotBeRevived(GetUnit(FILTER_UNIT_SELF)) > 0 ) then
            return false
        endif
        return true
    endfunction

    private function Release takes nothing returns nothing
        local timer releaseTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(releaseTimer, RaiseDead_SCOPE_ID)
        local Unit spawn = d.spawn
        local unit spawnSelf = spawn.self
        call d.destroy()
        call FlushAttachedInteger( releaseTimer, RaiseDead_SCOPE_ID )
        call DestroyTimerWJ( releaseTimer )
        set releaseTimer = null
        call SetUnitBlendTime( spawnSelf, 0.15 )
        call SetUnitInvulnerable( spawnSelf, false )
        call UnitApplyTimedLifeWJ( spawnSelf, DURATION )
        call SetUnitAnimationByIndex( spawnSelf, 0 )
        set spawnSelf = null
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local player casterOwner
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local Data d
        local unit enumUnit
        local real enumUnitAngle
        local real enumUnitX
        local real enumUnitY
        local integer iteration
        local Unit spawn
        local unit spawnSelf
        local timer releaseTimer
        set casterSelf = null
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, casterX, casterY, AREA_RANGE, TARGET_CONDITIONS )
        set enumUnit = GetNearestUnit( ENUM_GROUP, casterX, casterY )
        if ( enumUnit != null ) then
            set casterOwner = caster.owner
            set enumUnitAngle = GetUnitFacingWJ( enumUnit )
            set enumUnitX = GetUnitX( enumUnit )
            set enumUnitY = GetUnitY( enumUnit )
            set iteration = SPAWNS_AMOUNT
            call RemoveUnitEx( GetUnit(enumUnit) )
            loop
                exitwhen ( iteration < 1 )
                set d = Data.create()
                set spawn = CreateUnitEx( casterOwner, SPAWN_ID, enumUnitX, enumUnitY, enumUnitAngle )
                set spawnSelf = spawn.self
                set releaseTimer = CreateTimerWJ()
                set d.releaseTimer = releaseTimer
                set d.spawn = spawn
                call AttachInteger(releaseTimer, RaiseDead_SCOPE_ID, d)
                call SetUnitInvulnerable( spawnSelf, true )
                call SetUnitBlendTime( spawnSelf, 0 )
                call SetUnitAnimationByIndex( spawnSelf, 9 )
                call DestroyEffectWJ( AddSpecialEffectWJ( SPECIAL_EFFECT_PATH, GetUnitX( spawnSelf ), GetUnitY( spawnSelf ) ) )
                call TimerStart( releaseTimer, RELEASE_TIME, false, function Release )
                set iteration = iteration - 1
            endloop
            set casterOwner = null
            set releaseTimer = null
            set spawnSelf = null
        endif
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Order takes real casterX, real casterY returns string
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, casterX, casterY, AREA_RANGE, TARGET_CONDITIONS )
        if ( FirstOfGroup( ENUM_GROUP ) == null ) then
            return ErrorStrings_NO_CORPSES_FOUND
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        local unit casterSelf = CASTER.self
        set ERROR_MSG = RaiseDead_Order( GetUnitX(casterSelf), GetUnitY(casterSelf) )
        set casterSelf = null
    endfunction

    //! runtextmacro Scope("Automatic")
        globals
            public constant integer Automatic_ACTIVATION_ORDER_ID = 852133//OrderId( "autodispelon" )
            public constant integer Automatic_DEACTIVATION_ORDER_ID = 852134//OrderId( "autodispeloff" )
        endglobals

        public function Automatic_TargetInRange takes Unit caster, player casterOwner returns nothing
            local unit enumUnit
            local unit casterSelf = caster.self
            local real casterX
            local real casterY
            if ( GetUnitAutomaticAbility(caster) == SPELL_ID ) then
                set casterX = GetUnitX( casterSelf )
                set casterY = GetUnitY( casterSelf )
                call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, casterX, casterY, AREA_RANGE, TARGET_CONDITIONS )
                set enumUnit = GetRandomUnit( ENUM_GROUP )
                if ( enumUnit != null ) then
                    call IssueTargetOrderByIdTimed( caster, ORDER_ID, caster, 0 )
                endif
            endif
            set casterSelf = null
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
            call AddOrderAbility( Automatic_ACTIVATION_ORDER_ID, SPELL_ID )
            call AddOrderAbility( Automatic_DEACTIVATION_ORDER_ID, SPELL_ID )
            //! runtextmacro CreateEvent( "Automatic_EVENT_ACQUIRE", "UnitAcquiresTarget_EVENT_KEY", "0", "function Automatic_TargetInRange_Event" )
            //! runtextmacro AddNewEventById( "Automatic_EVENT_ACTIVATION_ORDER", "GetAbilityOrderId( SPELL_ID, Automatic_ACTIVATION_ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Automatic_Activation_Order_Event" )
            //! runtextmacro AddNewEventById( "Automatic_EVENT_DEACTIVATION_ORDER", "GetAbilityOrderId( SPELL_ID, Automatic_DEACTIVATION_ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Automatic_Deactivation_Order_Event" )
        endfunction
    //! runtextmacro Endscope()

    public function Init takes nothing returns nothing
        set ENUM_GROUP = CreateGroupWJ()
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( SPECIAL_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call Automatic_Automatic_Init()
    endfunction
//! runtextmacro Endscope()