//TESH.scrollpos=141
//TESH.alwaysfold=0
//! runtextmacro Scope("DivineShield")
    globals
        private constant integer ORDER_ID = 852090//OrderId( "divineshield" )
        public constant integer SPELL_ID = 'A03A'

        private constant real DURATION = 10.
        private group ENUM_GROUP
        private boolexpr TARGET_CONDITIONS
    endglobals

    private struct Data
        integer casterTeam
        timer durationTimer
        group targetGroup
    endstruct

    //! runtextmacro Scope("Target")
        private struct Target_Data
            Data d
        endstruct

        private function Target_Ending takes Target_Data d, Unit target, group targetGroup returns nothing
            local integer targetId = target.id
            call d.destroy()
            call FlushAttachedIntegerById(targetId, Target_SCOPE_ID)
            //! runtextmacro RemoveEventById( "targetId", "Target_EVENT_DEATH" )
            call GroupRemoveUnit( targetGroup, target.self )
            call RemoveUnitInvulnerabilityWithEffect( target )
        endfunction

        public function Target_EndingByEnding takes Unit target, group targetGroup returns nothing
            call Target_Ending(GetAttachedIntegerById(target.id, Target_SCOPE_ID), target, targetGroup)
        endfunction

        public function Target_Death takes Unit target returns nothing
            local Data d
            local Target_Data e = GetAttachedIntegerById(target.id, Target_SCOPE_ID)
            if ( e != NULL ) then
                set d = e.d
                call Target_Ending( e, target, d.targetGroup )
            endif
        endfunction

        private function Target_Death_Event takes nothing returns nothing
            call Target_Death( TRIGGER_UNIT )
        endfunction

        public function Target_Start takes Data d, Unit target, group targetGroup returns nothing
            local Target_Data e = Target_Data.create()
            local integer targetId = target.id
            call GroupAddUnit( targetGroup, target.self )
            set e.d = d
            call AttachIntegerById(targetId, Target_SCOPE_ID, e)
            //! runtextmacro AddEventById( "targetId", "Target_EVENT_DEATH" )
            call AddUnitInvulnerabilityWithEffect( target )
        endfunction

        public function Target_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "Target_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Target_Death_Event" )
        endfunction
    //! runtextmacro Endscope()

    private function Ending takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, DivineShield_SCOPE_ID)
        local integer casterTeam = d.casterTeam
        local string casterTeamString = GetTeamString(casterTeam)
        local unit enumUnit
        local group targetGroup = d.targetGroup
        call d.destroy()
        call FlushSavedInteger( casterTeamString, SCOPE_PREFIX )
        call FlushAttachedInteger( durationTimer, DivineShield_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        //! runtextmacro RemoveSavedEvent( "casterTeamString", "EVENT_ACTIVATE" )
        loop
            set enumUnit = FirstOfGroup( targetGroup )
            exitwhen ( enumUnit == null )
            call Target_Target_EndingByEnding( GetUnit(enumUnit), targetGroup )
        endloop
        call DestroyGroupWJ( targetGroup )
        set targetGroup = null
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetPlayerTeam( GetUnit( FILTER_UNIT_SELF ).owner ) != TEMP_INTEGER ) then
            return false
        endif
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_HERO ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        return true
    endfunction

    public function Activate takes Unit target, integer targetTeam returns nothing
        local Data d = GetSavedInteger(GetTeamString(targetTeam), SCOPE_PREFIX)
        local group targetGroup
        if ( d != NULL ) then
            call Target_Target_Start(d, target, d.targetGroup)
        endif
    endfunction

    private function Activate_Event takes nothing returns nothing
        call Activate( TRIGGER_UNIT, GetPlayerTeam(TRIGGER_UNIT.owner) )
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local integer casterTeam = GetPlayerTeam( caster.owner )
        local string casterTeamString = GetTeamString(casterTeam)
        local Data d = GetSavedInteger(casterTeamString, SCOPE_PREFIX)
        local timer durationTimer
        local unit enumUnit
        local group targetGroup
        if ( d == NULL ) then
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set targetGroup = CreateGroupWJ()
            set d.casterTeam = casterTeam
            set d.durationTimer = durationTimer
            set d.targetGroup = targetGroup
            call SaveIntegerWJ( casterTeamString, SCOPE_PREFIX, d )
            //! runtextmacro AddSavedEvent( "casterTeamString", "EVENT_ACTIVATE" )
            call AttachInteger(durationTimer, DivineShield_SCOPE_ID, d)
            set TEMP_INTEGER = casterTeam
            call GroupEnumUnitsInRectWithCollision( ENUM_GROUP, PLAY_RECT, TARGET_CONDITIONS )
            set enumUnit = FirstOfGroup( ENUM_GROUP )
            if ( enumUnit != null ) then
                loop
                    call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                    call Target_Target_Start(d, GetUnit(enumUnit), targetGroup)
                    set enumUnit = FirstOfGroup( ENUM_GROUP )
                    exitwhen ( enumUnit == null )
                endloop
            endif
        else
            set durationTimer = d.durationTimer
        endif
        call PingMasterWizard( casterTeam )
        call TimerStart( durationTimer, DURATION, false, function Ending )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateSavedEvent( "EVENT_ACTIVATE", "UnitIsActivated_EVENT_STRING_KEY", "0", "function Activate_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call Target_Target_Init()
    endfunction
//! runtextmacro Endscope()