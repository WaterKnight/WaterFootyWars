//TESH.scrollpos=197
//TESH.alwaysfold=0
//! runtextmacro Scope("ThermalFissure")
    globals
        private constant integer ORDER_ID = 852121//OrderId( "earthquake" )
        public constant integer SPELL_ID = 'A06X'

        private constant real AREA_RANGE = 500.
        private constant string AREA_EFFECT_PATH = "Abilities\\Spells\\Orc\\EarthQuake\\EarthQuakeTarget.mdl"
        private group ENUM_GROUP
        private constant real DELAY = 2.
        private boolexpr TARGET_CONDITIONS
    endglobals

    private struct Data
        effect areaEffect
        Unit caster
        real targetX
        real targetY
    endstruct

    //! runtextmacro Scope("Target")
        globals
            private constant real Target_DURATION = 13.
            private constant real Target_INTERVAL = 1.
            private constant integer Target_WAVES_AMOUNT = R2I(Target_DURATION / Target_INTERVAL)
            private constant real Target_RELATIVE_RESTORED_LIFE_PER_INTERVAL = 0.5 / Target_WAVES_AMOUNT
            private constant real Target_RELATIVE_RESTORED_MANA_PER_INTERVAL = 0.5 / Target_WAVES_AMOUNT
            private constant string Target_TARGET_EFFECT_PATH = "Abilities\\Spells\\Other\\ANrm\\ANrmTarget.mdl"
            private constant string Target_TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        endglobals

        private struct Target_Data
            timer durationTimer
            timer intervalTimer
            Unit target
            effect targetEffect
        endstruct

        private function Target_Ending takes Target_Data d, timer durationTimer, Unit target returns nothing
            local timer intervalTimer = d.intervalTimer
            local effect targetEffect = d.targetEffect
            local integer targetId = target.id
            call DestroyTimerWJ( durationTimer )
            call FlushAttachedInteger( intervalTimer, Target_SCOPE_ID )
            call DestroyTimerWJ( intervalTimer )
            set intervalTimer = null
            call FlushAttachedIntegerById( targetId, Target_SCOPE_ID )
            //! runtextmacro RemoveEventById( "targetId", "Target_EVENT_DAMAGE" )
            //! runtextmacro RemoveEventById( "targetId", "Target_EVENT_DEATH" )
            //! runtextmacro RemoveEventById( "targetId", "Target_EVENT_DISPEL" )
            call DestroyEffectWJ( targetEffect )
            set targetEffect = null
        endfunction

        public function Target_Dispel takes Unit target returns nothing
            local Target_Data d = GetAttachedIntegerById(target.id, Target_SCOPE_ID)
            if ( d != NULL ) then
                call Target_Ending( d, d.durationTimer, target )
            endif
        endfunction

        private function Target_Dispel_Event takes nothing returns nothing
            call Target_Dispel( TRIGGER_UNIT )
        endfunction

        public function Target_Damage takes Unit target returns nothing
            call Target_Dispel( target )
        endfunction

        private function Target_Damage_Event takes nothing returns nothing
            call Target_Damage( TRIGGER_UNIT )
        endfunction

        public function Target_Death takes Unit target returns nothing
            call Target_Dispel( target )
        endfunction

        private function Target_Death_Event takes nothing returns nothing
            call Target_Death( TRIGGER_UNIT )
        endfunction

        private function Target_EndingByTimer takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Target_Data d = GetAttachedInteger(durationTimer, Target_SCOPE_ID)
            call Target_Ending( d, durationTimer, d.target )
            set durationTimer = null
        endfunction

        private function Target_IntervalByTimer takes nothing returns nothing
            local timer intervalTimer = GetExpiredTimer()
            local Target_Data d = GetAttachedInteger(intervalTimer, Target_SCOPE_ID)
            local Unit target = d.target
            local unit targetSelf = target.self
            set intervalTimer = null
            call HealUnitBySpell( target, Target_RELATIVE_RESTORED_LIFE_PER_INTERVAL * GetUnitState( targetSelf, UNIT_STATE_MAX_LIFE ) )
            call AddUnitState( targetSelf, UNIT_STATE_MANA, Target_RELATIVE_RESTORED_MANA_PER_INTERVAL * GetUnitState(targetSelf, UNIT_STATE_MAX_MANA) )
            set targetSelf = null
        endfunction

        public function Target_Start takes Unit target returns nothing
            local timer durationTimer
            local timer intervalTimer
            local integer targetId = target.id
            local Target_Data d = GetAttachedIntegerById(targetId, Target_SCOPE_ID)
            if ( d == NULL ) then
                set d = Target_Data.create()
                set durationTimer = CreateTimerWJ()
                set intervalTimer = CreateTimerWJ()
                set d.durationTimer = durationTimer
                set d.intervalTimer = intervalTimer
                set d.target = target
                call AttachInteger( durationTimer, Target_SCOPE_ID, d )
                call AttachInteger( intervalTimer, Target_SCOPE_ID, d )
                call AttachIntegerById( targetId, Target_SCOPE_ID, d )
                //! runtextmacro AddEventById( "targetId", "Target_EVENT_DAMAGE" )
                //! runtextmacro AddEventById( "targetId", "Target_EVENT_DEATH" )
                //! runtextmacro AddEventById( "targetId", "Target_EVENT_DISPEL" )
            else
                set durationTimer = d.durationTimer
                set intervalTimer = d.intervalTimer
                call DestroyEffectWJ( d.targetEffect )
            endif
            set d.targetEffect = AddSpecialEffectTargetWJ( Target_TARGET_EFFECT_PATH, target.self, Target_TARGET_EFFECT_ATTACHMENT_POINT )
            call TimerStart( intervalTimer, Target_INTERVAL, true, function Target_IntervalByTimer )
            set intervalTimer = null
            call TimerStart( durationTimer, Target_DURATION, false, function Target_EndingByTimer )
            set durationTimer = null
        endfunction

        public function Target_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "Target_EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY", "0", "function Target_Damage_Event" )
            //! runtextmacro CreateEvent( "Target_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Target_Death_Event" )
            //! runtextmacro CreateEvent( "Target_EVENT_DISPEL", "UnitDies_EVENT_KEY", "0", "function Target_Dispel_Event" )
            call InitEffectType( Target_TARGET_EFFECT_PATH )
        endfunction
    //! runtextmacro Endscope()

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) == false ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_FLYING ) ) then
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
        if ( IsUnitWard( GetUnit(FILTER_UNIT_SELF) ) ) then
            return false
        endif
        return true
    endfunction

    private function StartByTimer takes nothing returns nothing
        local timer delayTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(delayTimer, ThermalFissure_SCOPE_ID)
        local effect areaEffect = d.areaEffect
        local Unit caster = d.caster
        local unit enumUnit
        local real targetX = d.targetX
        local real targetY = d.targetY
        call d.destroy()
        call DestroyEffectWJ( areaEffect )
        set areaEffect = null
        call FlushAttachedInteger( delayTimer, ThermalFissure_SCOPE_ID )
        call DestroyTimerWJ( delayTimer )
        set delayTimer = null
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, targetX, targetY, AREA_RANGE, TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit != null ) then
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                call Target_Target_Start(GetUnit(enumUnit))
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local unit casterSelf = caster.self
        local Data d = Data.create()
        local timer delayTimer = CreateTimerWJ()
        local real targetX = GetUnitX( casterSelf )
        local real targetY = GetUnitY( casterSelf )
        set casterSelf = null
        set d.areaEffect = AddSpecialEffectWJ( AREA_EFFECT_PATH, targetX, targetY )
        set d.caster = caster
        set d.targetX = targetX
        set d.targetY = targetY
        call AttachInteger( delayTimer, ThermalFissure_SCOPE_ID, d )
        call TimerStart( delayTimer, DELAY, false, function StartByTimer )
        set delayTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        set ENUM_GROUP = CreateGroupWJ()
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( AREA_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call Target_Target_Init()
    endfunction
//! runtextmacro Endscope()