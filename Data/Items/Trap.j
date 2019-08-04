//TESH.scrollpos=216
//TESH.alwaysfold=0
//! runtextmacro Scope("Trap")
    globals
        public constant integer ITEM_ID = 'I01N'
        public constant integer SPELL_ID = 'A02W'

        private constant real ACTIVATION_RANGE = 250.
        private constant real ACTIVATION_TIME = 5.
        private constant string AREA_EFFECT_PATH = "Abilities\\Spells\\Demon\\DarkPortal\\DarkPortalTarget.mdl"
        private constant real DURATION = 160.
        private constant real EFFECT_RANGE = 500.
        private group ENUM_GROUP
        private constant real INTERVAL = 1.
        private boolexpr TARGET_CONDITIONS
        private constant real TRIGGER_DURATION = 2.
    endglobals

    private struct Data
        timer dummyTimer
        Unit trap
    endstruct

    //! runtextmacro Scope("Slow")
        globals
            private constant real Slow_BONUS_SPEED = -80.
            private constant real Slow_DURATION = 5.
            private constant string Slow_TARGET_EFFECT_PATH = "Abilities\\Spells\\Human\\slow\\slowtarget.mdl"
            private constant string Slow_TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        endglobals

        private struct Slow_Data
            timer durationTimer
            Unit target
            effect targetEffect
        endstruct

        private function Slow_Ending takes Slow_Data d, timer durationTimer, Unit target returns nothing
            local effect targetEffect = d.targetEffect
            local integer targetId = target.id
            call d.destroy()
            call FlushAttachedInteger( durationTimer, Slow_SCOPE_ID )
            call DestroyTimerWJ( durationTimer )
            call FlushAttachedIntegerById( targetId, Slow_SCOPE_ID )
            //! runtextmacro RemoveEventById( "targetId", "Slow_EVENT_DEATH" )
            //! runtextmacro RemoveEventById( "targetId", "Slow_EVENT_DISPEL" )
            call DestroyEffectWJ( targetEffect )
            set targetEffect = null
            call AddUnitSpeedBonus( target, -Slow_BONUS_SPEED )
        endfunction

        public function Slow_Dispel takes Unit target returns nothing
            local Slow_Data d = GetAttachedIntegerById( target.id, Slow_SCOPE_ID )
            if ( d != NULL ) then
                call Slow_Ending( d, d.durationTimer, target )
            endif
        endfunction

        private function Slow_Dispel_Event takes nothing returns nothing
            call Slow_Dispel( TRIGGER_UNIT )
        endfunction

        public function Slow_Death takes Unit target returns nothing
            call Slow_Dispel( target )
        endfunction

        private function Slow_Death_Event takes nothing returns nothing
            call Slow_Death( DYING_UNIT )
        endfunction

        private function Slow_EndingByTimer takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Slow_Data d = GetAttachedInteger( durationTimer, Slow_SCOPE_ID )
            call Slow_Ending( d, durationTimer, d.target )
            set durationTimer = null
        endfunction

        public function Slow_Start takes Unit target returns nothing
            local integer targetId = target.id
            local Slow_Data d = GetAttachedIntegerById( targetId, Slow_SCOPE_ID )
            local timer durationTimer
            if ( d == NULL ) then
                set d = Slow_Data.create()
                set durationTimer = CreateTimerWJ()
                call AttachInteger( durationTimer, Slow_SCOPE_ID, d )
                call AttachIntegerById( targetId, Slow_SCOPE_ID, d )
                //! runtextmacro AddEventById( "targetId", "Slow_EVENT_DEATH" )
                //! runtextmacro AddEventById( "targetId", "Slow_EVENT_DISPEL" )
                call AddUnitSpeedBonus( target, Slow_BONUS_SPEED )
            else
                set durationTimer = d.durationTimer
                call DestroyEffectWJ( d.targetEffect )
            endif
            set d.targetEffect = AddSpecialEffectTargetWJ( Slow_TARGET_EFFECT_PATH, target.self, Slow_TARGET_EFFECT_ATTACHMENT_POINT )
            call TimerStart( durationTimer, Slow_DURATION, false, function Slow_EndingByTimer )
            set durationTimer = null
        endfunction

        public function Slow_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "Slow_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Slow_Death_Event" )
            //! runtextmacro CreateEvent( "Slow_EVENT_DISPEL", "UnitIsDispelled_EVENT_KEY_NEGATIVE", "0", "function Slow_Dispel_Event" )
            call InitEffectType( Slow_TARGET_EFFECT_PATH )
        endfunction
    //! runtextmacro Endscope()

    private function Ending takes Data d, Unit trap returns nothing
        local timer dummyTimer = d.dummyTimer
        call d.destroy()
        call FlushAttachedInteger( dummyTimer, Trap_SCOPE_ID )
        call DestroyTimerWJ( dummyTimer )
        set dummyTimer = null
        call FlushAttachedIntegerById( trap.id, Trap_SCOPE_ID )
    endfunction

    public function Death takes Unit trap returns nothing
        local integer trapId = trap.id
        local Data d = GetAttachedIntegerById( trapId, Trap_SCOPE_ID )
        if ( d != NULL ) then
            call Ending( d, trap )
            //! runtextmacro RemoveEventById( "trapId", "EVENT_DEATH" )
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
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        set FILTER_UNIT = GetUnit(FILTER_UNIT_SELF)
        if ( GetUnitInvulnerability( FILTER_UNIT ) > 0 ) then
            return false
        endif
        if ( GetUnitMagicImmunity( FILTER_UNIT ) > 0 ) then
            return false
        endif
        if ( IsUnitWard( FILTER_UNIT ) ) then
            return false
        endif
        return true
    endfunction

    private function Trigger takes nothing returns nothing
        local unit enumUnit
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, Trap_SCOPE_ID)
        local Unit trap = d.trap
        local unit trapSelf = trap.self
        local real trapX = GetUnitX( trapSelf )
        local real trapY = GetUnitY( trapSelf )
        set intervalTimer = null
        call KillUnit( trapSelf )
        set trapSelf = null
        call DestroyEffectWJ( AddSpecialEffectWJ( AREA_EFFECT_PATH, trapX, trapY ) )
        set TEMP_PLAYER = trap.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, trapX, trapY, EFFECT_RANGE, TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit != null ) then
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                call Slow_Slow_Start( GetUnit(enumUnit) )
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
    endfunction

    private function Interval takes nothing returns nothing
        local unit enumUnit
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, Trap_SCOPE_ID)
        local Unit trap = d.trap
        local unit trapSelf = trap.self
        set TEMP_PLAYER = trap.owner
        call GroupEnumUnitsInRangeWJ( ENUM_GROUP, GetUnitX( trapSelf ), GetUnitY( trapSelf ), ACTIVATION_RANGE, TARGET_CONDITIONS )
        set trapSelf = null
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit != null ) then
            set enumUnit = null
            call RemoveUnitGhost( trap )
            call TimerStart( intervalTimer, TRIGGER_DURATION, false, function Trigger )
        endif
        set intervalTimer = null
    endfunction

    private function Activation takes nothing returns nothing
        local timer activationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger( activationTimer, Trap_SCOPE_ID )
        call AddUnitGhost( d.trap )
        call TimerStart( activationTimer, INTERVAL, true, function Interval )
        set activationTimer = null
    endfunction

    public function SpellEffect takes Unit caster, real targetX, real targetY returns nothing
        local timer activationTimer = CreateTimerWJ()
        local Data d = Data.create()
        local Unit trap = CreateUnitEx( caster.owner, TRAP_BUILT_UP_UNIT_ID, targetX, targetY, STANDARD_ANGLE )
        local integer trapId = trap.id
        local unit trapSelf = trap.self
        set d.dummyTimer = activationTimer
        set d.trap = trap
        call AttachInteger( activationTimer, Trap_SCOPE_ID, d )
        call AttachIntegerById( trapId, Trap_SCOPE_ID, d )
        //! runtextmacro AddEventById( "trapId", "EVENT_DEATH" )
        call SetUnitAnimation(trapSelf, "birth")
        call UnitApplyTimedLifeWJ( trapSelf, DURATION )
        set trapSelf = null
        call TimerStart( activationTimer, ACTIVATION_TIME, false, function Activation )
        set activationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect(CASTER, TARGET_X, TARGET_Y)
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 125)
        call SetItemTypeMaxCharges(d, 2)
        call SetItemTypeRefreshInterval(d, 60)
        call SetItemTypeRefreshIntervalStart(d, 60)

        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( AREA_EFFECT_PATH )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call Slow_Slow_Init()
    endfunction
//! runtextmacro Endscope()