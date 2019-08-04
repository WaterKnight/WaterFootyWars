//TESH.scrollpos=213
//TESH.alwaysfold=0
//! runtextmacro Scope("ManaRegenerationAura")
    globals
        public constant integer SPELL_ID = 'A03U'

        private constant real AREA_RANGE = 550
        private group ENUM_GROUP
        private group ENUM_GROUP2
        private constant real UPDATE_TIME = 0.2
        private constant real REFRESHED_MANA = 0.75 * UPDATE_TIME
        private constant real REFRESHED_MANA_HERO = 0.75 * UPDATE_TIME
        private constant real REFRESHED_RELATIVE_MANA = 0.01 * UPDATE_TIME
        private constant real REFRESHED_RELATIVE_MANA_HERO = 0.01 * UPDATE_TIME
        private boolexpr TARGET_CONDITIONS
    endglobals

    private struct Data
        Unit caster
        group targetGroup
        timer updateTimer
    endstruct

    //! runtextmacro Scope("Target")
        globals
            private constant string Target_TARGET_EFFECT_PATH = "Abilities\\Spells\\Other\\ANrl\\ANrlTarget.mdl"
            private constant string Target_TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        endglobals

        private struct Target_Data
            Data d
            effect targetEffect
        endstruct

        private function Target_Ending takes Target_Data d, Unit target, group targetGroup returns nothing
            local effect targetEffect = d.targetEffect
            local integer targetId = target.id
            call d.destroy()
            call RemoveIntegerFromTableById( targetId, Target_SCOPE_ID, d )
            if (CountIntegersInTableById(targetId, Target_SCOPE_ID) == TABLE_EMPTY) then
                //! runtextmacro RemoveEventById( "targetId", "Target_EVENT_DEATH" )
            endif
            call DestroyEffectWJ( targetEffect )
            set targetEffect = null
            call GroupRemoveUnit( targetGroup, target.self )
        endfunction

        public function Target_EndingByEnding takes Data d, Unit target, group targetGroup returns nothing
            local Target_Data e
            local integer iteration = 0
            local integer targetId = target.id
            loop
                set e = GetIntegerFromTableById(targetId, Target_SCOPE_ID, iteration)
                exitwhen (e.d == d)
                set iteration = iteration + 1
            endloop
            call Target_Ending(e, target, targetGroup)
        endfunction

        public function Target_Death takes Unit target returns nothing
            local Target_Data d
            local integer targetId = target.id
            local integer iteration = CountIntegersInTableById( targetId, Target_SCOPE_ID )
            if (iteration > TABLE_EMPTY) then
                loop
                    set d = GetIntegerFromTableById( targetId, Target_SCOPE_ID, iteration )
                    call Target_Ending( d, target, d.d.targetGroup )
                    set iteration = iteration - 1
                    exitwhen ( iteration < TABLE_STARTED )
                endloop
            endif
        endfunction

        private function Target_Death_Event takes nothing returns nothing
            call Target_Death( DYING_UNIT )
        endfunction

        public function Target_Start takes Data d, Unit target returns nothing
            local Target_Data e = Target_Data.create()
            local integer targetId = target.id
            set e.d = d
            set e.targetEffect = AddSpecialEffectTargetWJ( Target_TARGET_EFFECT_PATH, target.self, Target_TARGET_EFFECT_ATTACHMENT_POINT )
            call AddIntegerToTableById( targetId, Target_SCOPE_ID, e )
            if (CountIntegersInTableById(targetId, Target_SCOPE_ID) == TABLE_STARTED) then
                //! runtextmacro AddEventById( "targetId", "Target_EVENT_DEATH" )
            endif
        endfunction

        public function Target_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "Target_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Target_Death_Event" )
            call InitEffectType( Target_TARGET_EFFECT_PATH )
        endfunction
    //! runtextmacro Endscope()

    public function Death takes Unit caster returns nothing
        local integer casterId = caster.id
        local Data d = GetAttachedIntegerById(casterId, ManaRegenerationAura_SCOPE_ID)
        local unit enumUnit
        local group targetGroup
        local timer updateTimer
        if ( d != NULL ) then
            set targetGroup = d.targetGroup
            set updateTimer = d.updateTimer
            call d.destroy()
            call FlushAttachedIntegerById(casterId, ManaRegenerationAura_SCOPE_ID)
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
            loop
                set enumUnit = FirstOfGroup( targetGroup )
                exitwhen ( enumUnit == null )
                call Target_Target_EndingByEnding( d, GetUnit(enumUnit), targetGroup )
            endloop
            call DestroyGroupWJ( targetGroup )
            set targetGroup = null
            call DestroyTimerWJ( updateTimer )
            set updateTimer = null
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( TRIGGER_UNIT )
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        set FILTER_UNIT = GetUnit(FILTER_UNIT_SELF)
        if ( GetPlayerId( FILTER_UNIT.owner ) > 11 ) then
            return false
        endif
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_MANA ) >= GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_MAX_MANA ) ) then
            return false
        endif
        if ( TEMP_BOOLEAN and ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) == false ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        if ( IsUnitWard( FILTER_UNIT ) ) then
            return false
        endif
        return true
    endfunction

    private function Update takes nothing returns nothing
        local unit enumUnit
        local timer updateTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(updateTimer, ManaRegenerationAura_SCOPE_ID)
        local Unit caster = d.caster
        local player casterOwner = caster.owner
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local group targetGroup = d.targetGroup
        set casterSelf = null
        set updateTimer = null
        set TEMP_BOOLEAN = ( GetPlayerId( casterOwner ) <= 11 )
        set TEMP_PLAYER = casterOwner
        set casterOwner = null
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, casterX, casterY, AREA_RANGE, TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( targetGroup )
        if ( enumUnit != null ) then
            loop
                if ( IsUnitInGroup( enumUnit, ENUM_GROUP ) == false ) then
                    call Target_Target_EndingByEnding( d, GetUnit(enumUnit), targetGroup )
                else
                    call GroupRemoveUnit( targetGroup, enumUnit )
                    call GroupAddUnit( ENUM_GROUP2, enumUnit )
                endif
                set enumUnit = FirstOfGroup( targetGroup )
                exitwhen ( enumUnit == null )
            endloop
            set enumUnit = FirstOfGroup( ENUM_GROUP2 )
            loop
                call GroupRemoveUnit( ENUM_GROUP2, enumUnit )
                call GroupAddUnit( targetGroup, enumUnit )
                set enumUnit = FirstOfGroup( ENUM_GROUP2 )
                exitwhen ( enumUnit == null )
            endloop
        endif
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit != null ) then
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                if ( IsUnitInGroup( enumUnit, targetGroup ) == false ) then
                    call GroupAddUnit( targetGroup, enumUnit )
                    call Target_Target_Start(d, GetUnit(enumUnit))
                endif
                if ( IsUnitType( enumUnit, UNIT_TYPE_HERO ) ) then
                    call AddUnitState( enumUnit, UNIT_STATE_MANA, REFRESHED_RELATIVE_MANA_HERO * GetUnitState( enumUnit, UNIT_STATE_MAX_MANA ) + REFRESHED_MANA_HERO )
                else
                    call AddUnitState( enumUnit, UNIT_STATE_MANA, REFRESHED_RELATIVE_MANA * GetUnitState( enumUnit, UNIT_STATE_MAX_MANA ) + REFRESHED_MANA )
                endif
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
        set targetGroup = null
    endfunction

    public function Learn takes Unit caster returns nothing
        local integer casterId = caster.id
        local Data d = GetAttachedIntegerById(casterId, ManaRegenerationAura_SCOPE_ID)
        local timer updateTimer
        if ( d == NULL ) then
            set d = Data.create()
            set updateTimer = CreateTimerWJ()
            set d.caster = caster
            set d.targetGroup = CreateGroupWJ()
            set d.updateTimer = updateTimer
            call AttachIntegerById(casterId, ManaRegenerationAura_SCOPE_ID, d)
            //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
            call AttachInteger(updateTimer, ManaRegenerationAura_SCOPE_ID, d)
            call TimerStart( updateTimer, UPDATE_TIME, true, function Update )
            set updateTimer = null
        endif
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        set ENUM_GROUP = CreateGroupWJ()
        set ENUM_GROUP2 = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
        call Target_Target_Init()
    endfunction
//! runtextmacro Endscope()