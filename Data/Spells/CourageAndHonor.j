//TESH.scrollpos=214
//TESH.alwaysfold=0
//! runtextmacro Scope("CourageAndHonor")
    globals
        public constant integer SPELL_ID = 'A06M'

        private constant real AREA_RANGE = 500.
        private constant real BONUS_RELATIVE_ATTACK_RATE = 0.01
        private group ENUM_GROUP
        private group ENUM_GROUP2
        private boolexpr TARGET_CONDITIONS
        private constant real UPDATE_TIME = 1.
    endglobals

    private struct Data
        Unit caster
        group targetGroup
        timer updateTimer
    endstruct

    //! runtextmacro Scope("Target")
        private struct Target_Data
            Data d
        endstruct

        private function Target_Ending takes Unit caster, Target_Data d, Unit target, group targetGroup returns nothing
            local integer targetId = target.id
            call d.destroy()
            call RemoveIntegerFromTableById( targetId, Target_SCOPE_ID, d )
            if ( CountIntegersInTableById( targetId, Target_SCOPE_ID ) == TABLE_EMPTY ) then
                //! runtextmacro RemoveEventById( "targetId", "Target_EVENT_DEATH" )
            endif
            call GroupRemoveUnit( targetGroup, target.self )
            call AddUnitAttackRate( caster, -BONUS_RELATIVE_ATTACK_RATE )
        endfunction

        public function Target_EndingByEnding takes Unit caster, Data d, Unit target, group targetGroup returns nothing
            local Target_Data e
            local integer targetId = target.id
            local integer iteration = CountIntegersInTableById( targetId, Target_SCOPE_ID )
            loop
                set e = GetIntegerFromTableById( targetId, Target_SCOPE_ID, iteration )
                exitwhen (e.d == d)
                set iteration = iteration - 1
            endloop
            call Target_Ending(caster, e, target, targetGroup)
        endfunction

        public function Target_Death takes Unit target returns nothing
            local Data d
            local Target_Data e
            local integer targetId = target.id
            local integer iteration = CountIntegersInTableById( targetId, Target_SCOPE_ID )
            if (iteration > TABLE_EMPTY) then
                loop
                    set e = GetIntegerFromTableById( targetId, Target_SCOPE_ID, iteration )
                    set d = e.d
                    call Target_Ending( d.caster, e, target, d.targetGroup )
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
            call AddIntegerToTableById( targetId, Target_SCOPE_ID, e )
            if ( CountIntegersInTableById( targetId, Target_SCOPE_ID ) == TABLE_STARTED ) then
                //! runtextmacro AddEventById( "targetId", "Target_EVENT_DEATH" )
            endif
        endfunction

        public function Target_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "Target_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Target_Death_Event" )
        endfunction
    //! runtextmacro Endscope()

    public function Death takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, CourageAndHonor_SCOPE_ID)
        local unit enumUnit
        local group targetGroup
        if ( d != NULL ) then
            set targetGroup = d.targetGroup
            loop
                set enumUnit = FirstOfGroup( targetGroup )
                exitwhen ( enumUnit == null )
                call Target_Target_EndingByEnding( caster, d, GetUnit(enumUnit), targetGroup )
            endloop
            set targetGroup = null
            call PauseTimer( d.updateTimer )
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
        if ( IsUnitEnemy( FILTER_UNIT_SELF, TEMP_PLAYER ) == false ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        set FILTER_UNIT = GetUnit(FILTER_UNIT_SELF)
        if ( IsUnitIllusionWJ( FILTER_UNIT ) ) then
            return false
        endif
        if ( IsUnitWard( FILTER_UNIT ) ) then
            return false
        endif
        return true
    endfunction

    private function Update takes Unit caster, Data d, group targetGroup returns nothing
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local unit enumUnit
        local real enumUnitX
        local real enumUnitY
        set casterSelf = null
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, casterX, casterY, AREA_RANGE, TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( targetGroup )
        if ( enumUnit != null ) then
            loop
                if ( IsUnitInGroup( enumUnit, ENUM_GROUP ) == false ) then
                    call Target_Target_EndingByEnding( caster, d, GetUnit(enumUnit), targetGroup )
                else
                    call GroupRemoveUnit( ENUM_GROUP, enumUnit )
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
        if (enumUnit != null) then
            loop
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                call GroupAddUnit( targetGroup, enumUnit )
                call Target_Target_Start(d, GetUnit(enumUnit))
                call AddUnitAttackRate( caster, BONUS_RELATIVE_ATTACK_RATE )
            endloop
        endif
    endfunction

    private function UpdateByTimer takes nothing returns nothing
        local timer updateTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(updateTimer, CourageAndHonor_SCOPE_ID)
        set updateTimer = null
        call Update( d.caster, d, d.targetGroup )
    endfunction

    public function Revive takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, CourageAndHonor_SCOPE_ID)
        if ( d != NULL ) then
            call TimerStart( d.updateTimer, UPDATE_TIME, true, function UpdateByTimer )
            call Update( caster, d, d.targetGroup )
        endif
    endfunction

    private function Revive_Event takes nothing returns nothing
        call Revive( REVIVING_UNIT )
    endfunction

    public function Learn takes Unit caster returns nothing
        local integer casterId = caster.id
        local Data d = GetAttachedIntegerById(casterId, CourageAndHonor_SCOPE_ID)
        local unit enumUnit
        local boolean isNew = ( d == NULL )
        local group targetGroup
        local timer updateTimer
        if ( isNew ) then
            set d = Data.create()
            set targetGroup = CreateGroupWJ()
            set updateTimer = CreateTimerWJ()
            set d.caster = caster
            set d.targetGroup = targetGroup
            set d.updateTimer = updateTimer
            call AttachIntegerById( casterId, CourageAndHonor_SCOPE_ID, d )
            //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
            //! runtextmacro AddEventById( "casterId", "EVENT_REVIVE" )
            call AttachInteger( updateTimer, CourageAndHonor_SCOPE_ID, d )
            call TimerStart( updateTimer, UPDATE_TIME, true, function UpdateByTimer )
            set updateTimer = null
        else
            set targetGroup = d.targetGroup
            set enumUnit = FirstOfGroup( targetGroup )
            if ( enumUnit != null ) then
                loop
                    call GroupRemoveUnit( targetGroup, enumUnit )
                    call Target_Target_EndingByEnding(caster, d, GetUnit(enumUnit), targetGroup)
                    set enumUnit = FirstOfGroup( targetGroup )
                    exitwhen ( enumUnit == null )
                endloop
            endif
        endif
        call Update( caster, d, targetGroup )
        set targetGroup = null
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        set ENUM_GROUP = CreateGroupWJ()
        set ENUM_GROUP2 = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_REVIVE", "UnitFinishesReviving_EVENT_KEY", "0", "function Revive_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
        call Target_Target_Init()
    endfunction
//! runtextmacro Endscope()