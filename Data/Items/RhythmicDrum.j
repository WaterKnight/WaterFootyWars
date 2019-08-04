//TESH.scrollpos=118
//TESH.alwaysfold=0
//! runtextmacro Scope("RhythmicDrum")
    globals
        public constant integer ITEM_ID = 'I019'

        private constant real AREA_RANGE = 750.
        private constant real BONUS_CRITICAL_STRIKE = 0.1
        private constant real BONUS_RELATIVE_SPEED = 0.2
        private constant string CASTER_EFFECT_PATH = "Abilities\\Spells\\NightElf\\ThornsAura\\ThornsAura.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "origin"
        private group ENUM_GROUP
        private group ENUM_GROUP2
        private boolexpr TARGET_CONDITIONS
        private constant real UPDATE_TIME = 1.
    endglobals

    private struct Data
        Unit caster
        effect casterEffect
        group targetGroup
        timer updateTimer
    endstruct

    private function GetCasterData takes Unit caster returns Data
        return GetAttachedIntegerById(caster.id, RhythmicDrum_SCOPE_ID)
    endfunction

    //! runtextmacro Scope("Target")
        globals
            private group Target_ENUM_GROUP
            private constant string Target_TARGET_EFFECT_PATH = "Abilities\\Spells\\Other\\GeneralAuraTarget\\GeneralAuraTarget.mdl"
            private constant string Target_TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        endglobals

        private struct Target_Data
            real bonusSpeed
            group casterGroup
            effect targetEffect
        endstruct

        private function Target_Ending takes unit caster, group casterGroup, Target_Data d, Unit target, group targetGroup returns nothing
            local real bonusSpeed
            local effect targetEffect
            local integer targetId
            call GroupRemoveUnit( casterGroup, caster )
            call GroupRemoveUnit( targetGroup, target.self )
            if (FirstOfGroup(casterGroup) == null) then
                set bonusSpeed = -d.bonusSpeed
                set targetEffect = d.targetEffect
                set targetId = target.id
                call d.destroy()
                call DestroyGroupWJ(casterGroup)
                call FlushAttachedIntegerById( targetId, Target_SCOPE_ID )
                //! runtextmacro RemoveEventById( "targetId", "Target_EVENT_DEATH" )
                call DestroyEffectWJ( targetEffect )
                set targetEffect = null
                call AddUnitCriticalStrike( target, -BONUS_CRITICAL_STRIKE )
                call AddUnitSpeedBonus( target, bonusSpeed )
            endif
        endfunction

        public function Target_EndingByDeath takes unit caster, Unit target, group targetGroup returns nothing
            local Target_Data d = GetAttachedIntegerById(target.id, Target_SCOPE_ID)
            call Target_Ending(caster, d.casterGroup, d, target, targetGroup)
        endfunction

        public function Target_EndingByUpdate takes unit caster, Unit target, group targetGroup returns nothing
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

        public function Target_Start takes unit caster, Unit target returns nothing
            local real bonusSpeed = BONUS_RELATIVE_SPEED * GetUnitSpeed( target )
            local group casterGroup
            local integer targetId = target.id
            local Target_Data d = GetAttachedIntegerById(targetId, Target_SCOPE_ID)
            local boolean isNew = (d == NULL)
            if (isNew) then
                set casterGroup = CreateGroupWJ()
                set d = Target_Data.create()
                set d.casterGroup = casterGroup
                set d.targetEffect = AddSpecialEffectTargetWJ( Target_TARGET_EFFECT_PATH, target.self, Target_TARGET_EFFECT_ATTACHMENT_POINT )
                call AttachIntegerById(targetId, Target_SCOPE_ID, d)
                //! runtextmacro AddEventById( "targetId", "Target_EVENT_DEATH" )
            else
                set casterGroup = d.casterGroup
            endif
            set d.bonusSpeed = bonusSpeed
            call GroupAddUnit(casterGroup, caster)
            set casterGroup = null
            if (isNew) then
                call AddUnitCriticalStrike( target, BONUS_CRITICAL_STRIKE )
                call AddUnitSpeedBonus( target, bonusSpeed )
            endif
        endfunction

        public function Target_Init takes nothing returns nothing
            set Target_ENUM_GROUP = CreateGroupWJ()
            //! runtextmacro CreateEvent( "Target_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Target_Death_Event" )
            call InitEffectType( Target_TARGET_EFFECT_PATH )
        endfunction
    //! runtextmacro Endscope()

    public function Ending takes Unit caster, Data d, boolean destroy returns nothing
        local effect casterEffect = d.casterEffect
        local integer casterId
        local unit casterSelf = caster.self
        local unit enumUnit
        local group targetGroup = d.targetGroup
        if (destroy) then
            set casterId = caster.id
            call d.destroy()
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
            //! runtextmacro RemoveEventById( "casterId", "EVENT_REVIVE" )
        endif
        call DestroyEffectWJ( casterEffect )
        set casterEffect = null
        loop
            set enumUnit = FirstOfGroup( targetGroup )
            exitwhen ( enumUnit == null )
            call Target_Target_EndingByDeath( casterSelf, GetUnit(enumUnit), targetGroup )
        endloop
        set casterSelf = null
        if (destroy) then
            call DestroyGroupWJ(targetGroup)
            call PauseTimer( d.updateTimer )
        else
            call DestroyTimerWJ(d.updateTimer)
        endif
        set targetGroup = null
    endfunction

    public function Death takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, RhythmicDrum_SCOPE_ID)
        if ( d != NULL ) then
            call Ending(caster, d, false)
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    public function Drop takes Unit caster returns nothing
        call Ending( caster, GetAttachedIntegerById(caster.id, RhythmicDrum_SCOPE_ID), true )
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitEnemy( FILTER_UNIT_SELF, TEMP_PLAYER ) ) then
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

    private function Update takes Unit caster, Data d, group targetGroup returns nothing
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local unit enumUnit
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, casterX, casterY, AREA_RANGE, TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( targetGroup )
        if ( enumUnit != null ) then
            loop
                if ( IsUnitInGroup( enumUnit, ENUM_GROUP ) == false ) then
                    call Target_Target_EndingByUpdate( casterSelf, GetUnit(enumUnit), targetGroup )
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
        if ( enumUnit != null ) then
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                call GroupAddUnit( targetGroup, enumUnit )
                call Target_Target_Start(casterSelf, GetUnit(enumUnit))
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
        set casterSelf = null
    endfunction

    private function UpdateByTimer takes nothing returns nothing
        local timer updateTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(updateTimer, RhythmicDrum_SCOPE_ID)
        set updateTimer = null
        call Update( d.caster, d, d.targetGroup )
    endfunction

    public function Revive takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, RhythmicDrum_SCOPE_ID)
        if ( d != NULL ) then
            set d.casterEffect = AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, caster.self, CASTER_EFFECT_ATTACHMENT_POINT )
            call TimerStart( d.updateTimer, UPDATE_TIME, true, function UpdateByTimer )
            call Update( caster, d, d.targetGroup )
        endif
    endfunction

    private function Revive_Event takes nothing returns nothing
        call Revive( REVIVING_UNIT )
    endfunction

    public function PickUp takes Unit caster returns nothing
        local integer casterId = caster.id
        local Data d = GetAttachedIntegerById(casterId, RhythmicDrum_SCOPE_ID)
        local boolean isNew = ( d == NULL )
        local group targetGroup
        local timer updateTimer
        if ( isNew ) then
            set d = Data.create()
            set targetGroup = CreateGroupWJ()
            set updateTimer = CreateTimerWJ()
            set d.caster = caster
            set d.casterEffect = AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, caster.self, CASTER_EFFECT_ATTACHMENT_POINT )
            set d.targetGroup = targetGroup
            set d.updateTimer = updateTimer
            call AttachIntegerById(casterId, RhythmicDrum_SCOPE_ID, d)
            //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
            //! runtextmacro AddEventById( "casterId", "EVENT_REVIVE" )
            call AttachInteger(updateTimer, RhythmicDrum_SCOPE_ID, d)
            call TimerStart( updateTimer, UPDATE_TIME, true, function UpdateByTimer )
            set updateTimer = null
        else
            set targetGroup = d.targetGroup
            set updateTimer = d.updateTimer
        endif
        call Update( caster, d, targetGroup )
        set targetGroup = null
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 1500)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 200)
        call SetItemTypeRefreshIntervalStart(d, 400)

        set ENUM_GROUP = CreateGroupWJ()
        set ENUM_GROUP2 = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_REVIVE", "UnitFinishesReviving_EVENT_KEY", "0", "function Revive_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( CASTER_EFFECT_PATH )
        call Target_Target_Init()
    endfunction
//! runtextmacro Endscope()