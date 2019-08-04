//TESH.scrollpos=276
//TESH.alwaysfold=0
//! runtextmacro Scope("Lens")
    globals
        public constant integer ITEM_ID = 'I02B'
        public constant integer SPELL_ID = 'A08F'

        private constant real AREA_RANGE = 325.
        private constant string CASTER_EFFECT_PATH = "Objects\\InventoryItems\\Rune\\Rune.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "overhead"
        private constant real DURATION = 10.
        private group ENUM_GROUP
        private group ENUM_GROUP2
        private boolexpr TARGET_CONDITIONS
        private constant real UPDATE_TIME = 1.
    endglobals

    private struct Data
        timer durationTimer
        Unit caster
        effect casterEffect
        group targetGroup
        timer updateTimer
    endstruct

    private function GetCasterData takes Unit caster returns Data
        return caster.id
    endfunction

    //! runtextmacro Scope("Target")
        globals
            private constant real Target_DAMAGE_FACTOR = 0.25
            private group Target_ENUM_GROUP
        endglobals

        private struct Target_Data
            group casterGroup
        endstruct

        private function Target_Ending takes unit caster, group casterGroup, Target_Data d, Unit target, group targetGroup returns nothing
            local integer targetId
            call GroupRemoveUnit( casterGroup, caster )
            call GroupRemoveUnit( targetGroup, target.self )
            if (FirstOfGroup(casterGroup) == null) then
                set targetId = target.id
                call d.destroy()
                call DestroyGroupWJ(casterGroup)
                call FlushAttachedIntegerById( targetId, Target_SCOPE_ID )
                //! runtextmacro RemoveEventById( "targetId", "Target_EVENT_DEATH" )
                call RemoveUnitAnyDamageEvents(target)
            endif
        endfunction

        public function Target_EndingByEnding takes unit caster, Unit target, group targetGroup returns nothing
            local Target_Data d = GetAttachedIntegerById(target.id, Target_SCOPE_ID)
            call Target_Ending(caster, d.casterGroup, d, target, targetGroup)
        endfunction

        public function Target_Death takes Unit target returns nothing
            local Unit caster
            local unit casterSelf
            local Target_Data d = GetAttachedIntegerById(target.id, Target_SCOPE_ID)
            local group casterGroup = d.casterGroup
            local integer iteration = CountUnits(casterGroup)
            if (iteration > 0) then
                loop
                    set casterSelf = FirstOfGroup(casterGroup)
                    set caster = GetUnit(casterSelf)
                    call Target_Ending( casterSelf, casterGroup, d, target, GetCasterData(caster).targetGroup )
                    set iteration = iteration - 1
                    exitwhen (iteration < 1)
                endloop
            endif
            set casterGroup = null
            set casterSelf = null
        endfunction

        private function Target_Death_Event takes nothing returns nothing
            call Target_Death( DYING_UNIT )
        endfunction

        public function Target_AnyDamage takes real damageAmount, Unit damageSource, Unit target returns real
            local unit caster
            local Target_Data d = GetAttachedIntegerById(target.id, Target_SCOPE_ID)
            if (d != NULL) then
                set caster = FirstOfGroup(d.casterGroup)
                if (IsUnitType(caster, UNIT_TYPE_DEAD) == false) then
                    call UnitDamageUnitEx( damageSource, GetUnit(caster), Target_DAMAGE_FACTOR * damageAmount, null )
                endif
                set caster = null
                return 0.
            endif
            return damageAmount
        endfunction

        public function Target_Start takes unit caster, Unit target returns nothing
            local group casterGroup
            local integer targetId = target.id
            local Target_Data d = GetAttachedIntegerById(targetId, Target_SCOPE_ID)
            local boolean isNew = (d == NULL)
            if (isNew) then
                set casterGroup = CreateGroupWJ()
                set d = Target_Data.create()
                set d.casterGroup = casterGroup
                call AttachIntegerById(targetId, Target_SCOPE_ID, d)
                //! runtextmacro AddEventById( "targetId", "Target_EVENT_DEATH" )
                call AddUnitAnyDamageEvents(target)
            else
                set casterGroup = d.casterGroup
            endif
            call GroupAddUnit(casterGroup, caster)
            set casterGroup = null
        endfunction

        public function Target_Init takes nothing returns nothing
            set Target_ENUM_GROUP = CreateGroupWJ()
            //! runtextmacro CreateEvent( "Target_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Target_Death_Event" )
        endfunction
    //! runtextmacro Endscope()

    private function Ending takes Data d, timer durationTimer returns nothing
        local Unit caster = d.caster
        local effect casterEffect = d.casterEffect
        local integer casterId = caster.id
        local unit casterSelf = caster.self
        local unit enumUnit
        local group targetGroup = d.targetGroup
        local timer updateTimer = d.updateTimer
        call d.destroy()
        call FlushAttachedIntegerById(casterId, Lens_SCOPE_ID)
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DECAY_END" )
        call DestroyEffectWJ( casterEffect )
        set casterEffect = null
        call DestroyTimerWJ( durationTimer )
        loop
            set enumUnit = FirstOfGroup( targetGroup )
            exitwhen ( enumUnit == null )
            call Target_Target_EndingByEnding( casterSelf, GetUnit(enumUnit), targetGroup )
        endloop
        set casterSelf = null
        call DestroyGroupWJ(targetGroup)
        set targetGroup = null
        call DestroyTimerWJ(updateTimer)
        set updateTimer = null
    endfunction

    private function Death_Ending takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, Lens_SCOPE_ID)
        call Ending(d, durationTimer)
        set durationTimer = null
    endfunction

    public function Death takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, Lens_SCOPE_ID)
        if ( d != NULL ) then
            call TimerStart(d.durationTimer, 0, false, function Death_Ending)
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( TRIGGER_UNIT )
    endfunction

    public function DecayEnd takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, Lens_SCOPE_ID)
        if ( d != NULL ) then
            call Ending(d, d.durationTimer)
        endif
    endfunction

    private function DecayEnd_Event takes nothing returns nothing
        call DecayEnd( TRIGGER_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, Lens_SCOPE_ID)
        call Ending(d, durationTimer)
        set durationTimer = null
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if (GetAttachedIntegerById(GetUnit(FILTER_UNIT_SELF).id, Lens_SCOPE_ID) != NULL) then
            return false
        endif
        return true
    endfunction

    private function Update takes Unit caster, group targetGroup returns nothing
        local Unit enumUnit
        local unit enumUnitSelf
        local player casterOwner = caster.owner
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        set TEMP_PLAYER = casterOwner
        set casterOwner = null
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, casterX, casterY, AREA_RANGE, TARGET_CONDITIONS )
        set enumUnitSelf = FirstOfGroup( targetGroup )
        if ( enumUnitSelf != null ) then
            loop
                if ( IsUnitInGroup( enumUnitSelf, ENUM_GROUP ) == false ) then
                    call Target_Target_EndingByEnding( casterSelf, GetUnit(enumUnitSelf), targetGroup )
                else
                    call GroupRemoveUnit( targetGroup, enumUnitSelf )
                    call GroupAddUnit( ENUM_GROUP2, enumUnitSelf )
                endif
                set enumUnitSelf = FirstOfGroup( targetGroup )
                exitwhen ( enumUnitSelf == null )
            endloop
            set enumUnitSelf = FirstOfGroup( ENUM_GROUP2 )
            loop
                call GroupRemoveUnit( ENUM_GROUP2, enumUnitSelf )
                call GroupAddUnit( targetGroup, enumUnitSelf )
                set enumUnitSelf = FirstOfGroup( ENUM_GROUP2 )
                exitwhen ( enumUnitSelf == null )
            endloop
        endif
        set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
        if ( enumUnitSelf != null ) then
            loop
                set enumUnit = GetUnit(enumUnitSelf)
                call GroupRemoveUnit( ENUM_GROUP, enumUnitSelf )
                if ( IsUnitInGroup( enumUnitSelf, targetGroup ) == false ) then
                    call GroupAddUnit( targetGroup, enumUnitSelf )
                    call Target_Target_Start(casterSelf, enumUnit)
                endif
                set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnitSelf == null )
            endloop
            set enumUnitSelf = null
        endif
        set casterSelf = null
        set targetGroup = null
    endfunction

    private function UpdateByTimer takes nothing returns nothing
        local timer updateTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(updateTimer, Lens_SCOPE_ID)
        set updateTimer = null
        call Update(d.caster, d.targetGroup)
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local integer casterId = caster.id
        local Data d = GetAttachedIntegerById(casterId, Lens_SCOPE_ID)
        local timer durationTimer
        local group targetGroup
        local timer updateTimer
        if ( d == NULL ) then
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set targetGroup = CreateGroupWJ()
            set updateTimer = CreateTimerWJ()
            set d.caster = caster
            set d.casterEffect = AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, caster.self, CASTER_EFFECT_ATTACHMENT_POINT )
            set d.durationTimer = durationTimer
            set d.targetGroup = targetGroup
            set d.updateTimer = updateTimer
            call AttachIntegerById(casterId, Lens_SCOPE_ID, d)
            //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
            //! runtextmacro AddEventById( "casterId", "EVENT_DECAY_END" )
            call AttachInteger(durationTimer, Lens_SCOPE_ID, d)
            call AttachInteger(updateTimer, Lens_SCOPE_ID, d)
            call TimerStart( updateTimer, UPDATE_TIME, true, function UpdateByTimer )
            set updateTimer = null
            call Update(caster, targetGroup)
            set targetGroup = null
            call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
            set durationTimer = null
        endif
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( TARGET_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 90)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 60)
        call SetItemTypeRefreshIntervalStart(d, 60)

        set ENUM_GROUP = CreateGroupWJ()
        set ENUM_GROUP2 = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_DECAY_END", "UnitFinishesDecaying_End_End_EVENT_KEY", "0", "function DecayEnd_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( CASTER_EFFECT_PATH )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call Target_Target_Init()
    endfunction
//! runtextmacro Endscope()