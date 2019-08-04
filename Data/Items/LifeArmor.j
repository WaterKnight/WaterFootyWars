//TESH.scrollpos=281
//TESH.alwaysfold=0
//! runtextmacro Scope("LifeArmor")
    globals
        public constant integer ITEM_ID = 'I01S'
        public constant integer SET_ITEM_ID = 'I01Y'

        private constant real AREA_RANGE = 550.
        private constant string CASTER_EFFECT_PATH = "Abilities\\Spells\\Other\\Drain\\DrainCaster.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "origin"
        private group ENUM_GROUP
        private group ENUM_GROUP2
        private boolexpr TARGET_CONDITIONS
        private constant real UPDATE_TIME = 1.
        private constant real REFRESHED_LIFE = 1.25 * UPDATE_TIME
        private constant real REFRESHED_LIFE_HERO = 2. * UPDATE_TIME
        private constant real REFRESHED_RELATIVE_LIFE = 0.005 * UPDATE_TIME
        private constant real REFRESHED_RELATIVE_LIFE_HERO = 0.01 * UPDATE_TIME
    endglobals

    private struct Data
        integer amount
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
            private group Target_ENUM_GROUP
            private constant string Target_TARGET_EFFECT_PATH = "Abilities\\Spells\\Other\\GeneralAuraTarget\\GeneralAuraTarget.mdl"
            private constant string Target_TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        endglobals

        private struct Target_Data
            group casterGroup
            effect targetEffect
        endstruct

        private function Target_Ending takes unit caster, group casterGroup, Target_Data d, Unit target, group targetGroup returns nothing
            local effect targetEffect
            local integer targetId
            call GroupRemoveUnit( casterGroup, caster )
            call GroupRemoveUnit( targetGroup, target.self )
            if (FirstOfGroup(casterGroup) == null) then
                set targetEffect = d.targetEffect
                set targetId = target.id
                call d.destroy()
                call DestroyGroupWJ(casterGroup)
                call FlushAttachedIntegerById( targetId, Target_SCOPE_ID )
                //! runtextmacro RemoveEventById( "targetId", "Target_EVENT_DEATH" )
                call DestroyEffectWJ( targetEffect )
                set targetEffect = null
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

        public function Target_Heal takes unit caster, Unit target returns nothing
            local Target_Data d = GetAttachedIntegerById(target.id, Target_SCOPE_ID)
            local unit targetSelf
            if (FirstOfGroup(d.casterGroup) == caster) then
                set targetSelf = target.self
                if ( IsUnitType( targetSelf, UNIT_TYPE_HERO ) ) then
                    call AddUnitState( targetSelf, UNIT_STATE_LIFE, REFRESHED_RELATIVE_LIFE_HERO * GetUnitState( targetSelf, UNIT_STATE_MAX_LIFE ) + REFRESHED_LIFE_HERO )
                else
                    call AddUnitState( targetSelf, UNIT_STATE_LIFE, REFRESHED_RELATIVE_LIFE * GetUnitState( targetSelf, UNIT_STATE_MAX_LIFE ) + REFRESHED_LIFE )
                endif
                set targetSelf = null
            endif
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
                set d.targetEffect = AddSpecialEffectTargetWJ( Target_TARGET_EFFECT_PATH, target.self, Target_TARGET_EFFECT_ATTACHMENT_POINT )
                call AttachIntegerById(targetId, Target_SCOPE_ID, d)
                //! runtextmacro AddEventById( "targetId", "Target_EVENT_DEATH" )
            else
                set casterGroup = d.casterGroup
            endif
            call GroupAddUnit(casterGroup, caster)
            set casterGroup = null
        endfunction

        public function Target_Init takes nothing returns nothing
            set Target_ENUM_GROUP = CreateGroupWJ()
            //! runtextmacro CreateEvent( "TargeT_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Target_Death_Event" )
            call InitEffectType( Target_TARGET_EFFECT_PATH )
        endfunction
    //! runtextmacro Endscope()

    private function Ending takes Unit caster, Data d, boolean remove returns nothing
        local effect casterEffect = d.casterEffect
        local integer casterId
        local unit casterSelf = caster.self
        local unit enumUnit
        local group targetGroup = d.targetGroup
        local timer updateTimer = d.updateTimer
        call d.destroy()
        if (remove) then
            set casterId = caster.id
            call FlushAttachedIntegerById(casterId, LifeArmor_SCOPE_ID)
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
            //! runtextmacro RemoveEventById( "casterId", "EVENT_REVIVE" )
        endif
        call DestroyEffectWJ( casterEffect )
        set casterEffect = null
        loop
            set enumUnit = FirstOfGroup( targetGroup )
            exitwhen ( enumUnit == null )
            call Target_Target_EndingByEnding( casterSelf, GetUnit(enumUnit), targetGroup )
        endloop
        set casterSelf = null
        if (remove) then
            call DestroyGroupWJ(targetGroup)
            call DestroyTimerWJ(updateTimer)
        else
            call PauseTimer( updateTimer )
        endif
        set targetGroup = null
        set updateTimer = null
    endfunction

    public function Death takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, LifeArmor_SCOPE_ID)
        if ( d != NULL ) then
            call Ending(caster, d, false)
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( TRIGGER_UNIT )
    endfunction

    public function Drop takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, LifeArmor_SCOPE_ID)
        local integer amount = d.amount - 1
        if (amount == 0) then
            call Ending( caster, GetAttachedIntegerById(caster.id, LifeArmor_SCOPE_ID), true )
        else
            set d.amount = amount
        endif
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) >= GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_MAX_LIFE ) ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) == false ) then
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
                call Target_Target_Heal(casterSelf, enumUnit)
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
        local Data d = GetAttachedInteger(updateTimer, LifeArmor_SCOPE_ID)
        set updateTimer = null
        call Update(d.caster, d.targetGroup)
    endfunction

    public function Revive takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, LifeArmor_SCOPE_ID)
        if ( d != NULL ) then
            set d.casterEffect = AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, caster.self, CASTER_EFFECT_ATTACHMENT_POINT )
            call TimerStart( d.updateTimer, UPDATE_TIME, true, function UpdateByTimer )
            call Update( caster, d.targetGroup )
        endif
    endfunction

    private function Revive_Event takes nothing returns nothing
        call Revive( REVIVING_UNIT )
    endfunction

    public function PickUp takes Unit caster returns nothing
        local integer casterId = caster.id
        local Data d = GetAttachedIntegerById(casterId, LifeArmor_SCOPE_ID)
        local group targetGroup
        local timer updateTimer
        if ( d == NULL ) then
            set d = Data.create()
            set targetGroup = CreateGroupWJ()
            set updateTimer = CreateTimerWJ()
            set d.amount = 1
            set d.caster = caster
            set d.casterEffect = AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, caster.self, CASTER_EFFECT_ATTACHMENT_POINT )
            set d.targetGroup = targetGroup
            set d.updateTimer = updateTimer
            call AttachIntegerById(casterId, LifeArmor_SCOPE_ID, d)
            //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
            //! runtextmacro AddEventById( "casterId", "EVENT_REVIVE" )
            call AttachInteger(updateTimer, LifeArmor_SCOPE_ID, d)
            call TimerStart( updateTimer, UPDATE_TIME, true, function UpdateByTimer )
            set updateTimer = null
            call Update(caster, targetGroup)
            set targetGroup = null
        else
            set d.amount = d.amount + 1
        endif
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 1500)

        set d = InitItemTypeEx(SET_ITEM_ID)
        call SetItemTypeGoldCost(d, 1500)
        call SetItemTypeMaxCharges(d, 1)

        call CreateSetSimple2(GoldenRing_ITEM_ID, GoldenRing_ITEM_ID, SET_ITEM_ID, ITEM_ID)

        set ENUM_GROUP = CreateGroupWJ()
        set ENUM_GROUP2 = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_REVIVE", "UnitFinishesReviving_EVENT_KEY", "0", "function Revive_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( CASTER_EFFECT_PATH )
        call Target_Target_Init()
    endfunction
//! runtextmacro Endscope()