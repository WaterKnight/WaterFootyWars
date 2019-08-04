//TESH.scrollpos=248
//TESH.alwaysfold=0
//! runtextmacro Scope("UnholyArmor")
    globals
        public constant integer SPELL_ID = 'A06R'

        private constant real AREA_RANGE = 500.
        private constant real BONUS_RELATIVE_STUN_DURATION = -0.3
        private constant string CASTER_EFFECT_PATH = "Abilities\\Spells\\Items\\OrbDarkness\\OrbDarkness.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "chest"
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
        return GetAttachedIntegerById(caster.id, UnholyArmor_SCOPE_ID)
    endfunction

    //! runtextmacro Scope("Target")
        globals
            private constant real Target_BONUS_RELATIVE_SIGHT_RANGE = -0.25
            private constant string Target_TARGET_EFFECT_PATH = "Abilities\\Spells\\Undead\\CarrionSwarm\\CarrionSwarmDamage.mdl"
            private constant string Target_TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        endglobals

        private struct Target_Data
            real bonusSightRange
            group casterGroup
            effect targetEffect
        endstruct

        private function Target_Ending takes Unit caster, group casterGroup, Target_Data d, Unit target, group targetGroup returns nothing
            local real bonusSightRange
            local effect targetEffect
            local integer targetId
            call GroupRemoveUnit( casterGroup, caster.self )
            call GroupRemoveUnit( targetGroup, target.self )
            if ( FirstOfGroup(casterGroup) == null ) then
                set bonusSightRange = d.bonusSightRange
                set targetEffect = d.targetEffect
                set targetId = target.id
                call d.destroy()
                call DestroyGroupWJ(casterGroup)
                call FlushAttachedIntegerById( targetId, Target_SCOPE_ID )
                //! runtextmacro RemoveEventById( "targetId", "Target_EVENT_DEATH" )
                call DestroyEffectWJ( targetEffect )
                set targetEffect = null
                call AddUnitSightRange( target, -bonusSightRange )
            endif
            set casterGroup = null
        endfunction

        public function Target_EndingByDeath takes Unit caster, Unit target, group targetGroup returns nothing
            local Target_Data d = GetAttachedIntegerById(target.id, Target_SCOPE_ID)
            call Target_Ending(caster, d.casterGroup, d, target, targetGroup)
        endfunction

        public function Target_EndingByUpdate takes Unit caster, Unit target, group targetGroup returns nothing
            local Target_Data d = GetAttachedIntegerById(target.id, Target_SCOPE_ID)
            call Target_Ending(caster, d.casterGroup, d, target, targetGroup)
        endfunction

        public function Target_Death takes Unit target returns nothing
            local Unit caster
            local group casterGroup
            local Data d
            local Target_Data e = GetAttachedIntegerById(target.id, Target_SCOPE_ID)
            local integer iteration
            if (e != NULL) then
                set casterGroup = e.casterGroup
                set iteration = CountUnits( casterGroup )
                if (iteration > 0) then
                    loop
                        set caster = GetUnit(FirstOfGroup(casterGroup))
                        set d = GetCasterData(caster)
                        call Target_Ending( caster, casterGroup, e, target, d.targetGroup )
                        set iteration = iteration - 1
                        exitwhen ( iteration < 1 )
                    endloop
                endif
                set casterGroup = null
            endif
        endfunction

        private function Target_Death_Event takes nothing returns nothing
            call Target_Death( DYING_UNIT )
        endfunction

        public function Target_Start takes Unit caster, Unit target returns nothing
            local real bonusSightRange = GetUnitSightRange( target ) * Target_BONUS_RELATIVE_SIGHT_RANGE
            local group casterGroup
            local real oldBonusSightRange
            local integer targetId = target.id
            local Target_Data d = GetAttachedIntegerById(targetId, Target_SCOPE_ID)
            local boolean isNew = (d == NULL)
            if (isNew) then
                set casterGroup = CreateGroupWJ()
                set d = Target_Data.create()
                set d.bonusSightRange = bonusSightRange
                set d.casterGroup = casterGroup
                set d.targetEffect = AddSpecialEffectTargetWJ( Target_TARGET_EFFECT_PATH, target.self, Target_TARGET_EFFECT_ATTACHMENT_POINT )
                call AttachIntegerById(targetId, Target_SCOPE_ID, d)
                //! runtextmacro AddEventById( "targetId", "Target_EVENT_DEATH" )
            else
                set casterGroup = d.casterGroup
                set oldBonusSightRange = d.bonusSightRange
                set d.bonusSightRange = bonusSightRange
            endif
            call GroupAddUnit(casterGroup, caster.self)
            set casterGroup = null
            if (isNew) then
                call AddUnitSightRange( target, bonusSightRange )
            else
                call AddUnitSightRange( target, bonusSightRange - oldBonusSightRange )
            endif
        endfunction

        public function Target_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "Target_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Target_Death_Event" )
            call InitEffectType( Target_TARGET_EFFECT_PATH )
        endfunction
    //! runtextmacro Endscope()

    public function Death takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, UnholyArmor_SCOPE_ID)
        local unit enumUnit
        local group targetGroup
        if ( d != NULL ) then
            set targetGroup = d.targetGroup
            call DestroyEffectWJ( d.casterEffect )
            loop
                set enumUnit = FirstOfGroup( targetGroup )
                exitwhen ( enumUnit == null )
                call Target_Target_EndingByDeath( caster, GetUnit(enumUnit), targetGroup )
            endloop
            set targetGroup = null
            call PauseTimer( d.updateTimer )
            call AddUnitStunDurationRelativeBonus( caster, -BONUS_RELATIVE_STUN_DURATION )
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
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        if ( GetUnitMagicImmunity( GetUnit(FILTER_UNIT_SELF) ) > 0 ) then
            return false
        endif
        return true
    endfunction

    private function Update takes Unit caster, group targetGroup returns nothing
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local unit enumUnit
        set casterSelf = null
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, casterX, casterY, AREA_RANGE, TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( targetGroup )
        if ( enumUnit != null ) then
            loop
                if ( IsUnitInGroup( enumUnit, ENUM_GROUP ) == false ) then
                    call Target_Target_EndingByUpdate( caster, GetUnit(enumUnit), targetGroup )
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
                call Target_Target_Start(caster, GetUnit(enumUnit))
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
    endfunction

    private function UpdateByTimer takes nothing returns nothing
        local timer updateTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(updateTimer, UnholyArmor_SCOPE_ID)
        set updateTimer = null
        call Update( d.caster, d.targetGroup )
    endfunction

    public function Revive takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, UnholyArmor_SCOPE_ID)
        if ( d != NULL ) then
            set d.casterEffect = AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, caster.self, CASTER_EFFECT_ATTACHMENT_POINT )
            call AddUnitStunDurationRelativeBonus( caster, BONUS_RELATIVE_STUN_DURATION )
            call TimerStart( d.updateTimer, UPDATE_TIME, true, function UpdateByTimer )
            call Update( caster, d.targetGroup )
        endif
    endfunction

    private function Revive_Event takes nothing returns nothing
        call Revive( REVIVING_UNIT )
    endfunction

    public function Learn takes Unit caster returns nothing
        local integer casterId = caster.id
        local Data d = Data.create()
        local group targetGroup = CreateGroupWJ()
        local timer updateTimer = CreateTimerWJ()
        set d.caster = caster
        set d.casterEffect = AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, caster.self, CASTER_EFFECT_ATTACHMENT_POINT )
        set d.targetGroup = targetGroup
        set d.updateTimer = updateTimer
        call AttachIntegerById( casterId, UnholyArmor_SCOPE_ID, d )
        //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
        //! runtextmacro AddEventById( "casterId", "EVENT_REVIVE" )
        call AttachInteger( updateTimer, UnholyArmor_SCOPE_ID, d )
        call AddUnitStunDurationRelativeBonus( caster, BONUS_RELATIVE_STUN_DURATION )
        call TimerStart( updateTimer, UPDATE_TIME, true, function UpdateByTimer )
        set updateTimer = null
        call Update( caster, targetGroup )
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
        call InitEffectType( CASTER_EFFECT_PATH )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
        call Target_Target_Init()
    endfunction
//! runtextmacro Endscope()