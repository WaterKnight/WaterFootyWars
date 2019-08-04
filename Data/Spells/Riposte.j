//TESH.scrollpos=77
//TESH.alwaysfold=0
//! runtextmacro Scope("Riposte")
    globals
        public constant integer SPELL_ID = 'A074'

        private constant real AREA_RANGE = 500.
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

    //! runtextmacro Scope("Target")
        globals
            private constant real Target_REFLECTION_FACTOR = 0.25
            private constant string Target_SPECIAL_EFFECT_PATH = "Abilities\\Spells\\NightElf\\ThornsAura\\ThornsAuraDamage.mdl"
            private constant string Target_SPECIAL_EFFECT_ATTACHMENT_POINT = "head"
            private constant string Target_TARGET_EFFECT_PATH = "Abilities\\Spells\\Other\\GeneralAuraTarget\\GeneralAuraTarget.mdl"
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
            if ( CountIntegersInTableById( targetId, Target_SCOPE_ID ) == TABLE_EMPTY ) then
                //! runtextmacro RemoveEventById( "targetId", "Target_EVENT_DAMAGE" )
                //! runtextmacro RemoveEventById( "targetId", "Target_EVENT_DEATH" )
                call DestroyEffectWJ( targetEffect )
            endif
            set targetEffect = null
            call GroupRemoveUnit( targetGroup, target.self )
        endfunction

        public function Target_EndingByEnding takes Data d, Unit target, group targetGroup returns nothing
            local Target_Data e
            local integer targetId = target.id
            local integer iteration = CountIntegersInTableById( targetId, Target_SCOPE_ID )
            loop
                set e = GetIntegerFromTableById(targetId, Target_SCOPE_ID, iteration)
                exitwhen (e.d == d)
                set iteration = iteration - 1
            endloop
            call Target_Ending( e, target, targetGroup )
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
                    call Target_Ending( e, target, d.targetGroup )
                    set iteration = iteration - 1
                    exitwhen ( iteration < TABLE_STARTED )
                endloop
            endif
        endfunction

        private function Target_Death_Event takes nothing returns nothing
            call Target_Death( DYING_UNIT )
        endfunction

        private function Target_Damage_Conditions takes Unit damageSource, integer damageSourceTypeId, Unit target returns boolean
            if ( CountIntegersInTableById( target.id, Target_SCOPE_ID ) < TABLE_STARTED ) then
                return false
            endif
            set TEMP_UNIT_SELF = damageSource.self
            if ( GetUnitState( TEMP_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
                return false
            endif
            if ( ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_MELEE_ATTACKER ) == false ) and ( IsUnitTypeMelee(damageSource.type) ) ) then
                return false
            endif
            if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
                return false
            endif
            if ( GetUnitInvulnerability( damageSource ) > 0 ) then
                return false
            endif
            if ( IsUnitIllusionWJ( target ) ) then
                return false
            endif
            return true
        endfunction

        public function Target_Damage takes real damageAmount, Unit damageSource, Unit target returns nothing
            local unit damageSourceSelf = damageSource.self
            if ( Target_Damage_Conditions( damageSource, GetUnitTypeId( damageSourceSelf ), target ) ) then
                call DestroyEffectWJ( AddSpecialEffectTargetWJ( Target_SPECIAL_EFFECT_PATH, damageSourceSelf, Target_SPECIAL_EFFECT_ATTACHMENT_POINT ) )
                call UnitDamageUnitEx( target, damageSource, damageAmount * Target_REFLECTION_FACTOR, null )
            endif
            set damageSourceSelf = null
        endfunction

        private function Target_Damage_Event takes nothing returns nothing
            call Target_Damage( DAMAGE_AMOUNT, DAMAGE_SOURCE, TRIGGER_UNIT )
        endfunction

        public function Target_Start takes Data d, Unit target returns nothing
            local Target_Data e = Target_Data.create()
            local integer targetId = target.id
            set e.d = d
            call AddIntegerToTableById( targetId, Target_SCOPE_ID, e )
            if ( CountIntegersInTableById( targetId, Target_SCOPE_ID ) == TABLE_STARTED ) then
                set e.targetEffect = AddSpecialEffectTargetWJ( Target_TARGET_EFFECT_PATH, target.self, Target_TARGET_EFFECT_ATTACHMENT_POINT )
                //! runtextmacro AddEventById( "targetId", "Target_EVENT_DAMAGE" )
                //! runtextmacro AddEventById( "targetId", "Target_EVENT_DEATH" )
            endif
        endfunction

        public function Target_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "Target_EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY", "0", "function Target_Damage_Event" )
            //! runtextmacro CreateEvent( "Target_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Target_Death_Event" )
            call InitEffectType( Target_SPECIAL_EFFECT_PATH )
            call InitEffectType( Target_TARGET_EFFECT_PATH )
        endfunction
    //! runtextmacro Endscope()

    public function Death takes Unit caster returns nothing
        local effect casterEffect
        local integer casterId = caster.id
        local Data d = GetAttachedIntegerById(casterId, Riposte_SCOPE_ID)
        local unit enumUnit
        local group targetGroup
        local timer updateTimer
        if ( d != NULL ) then
            set casterEffect = d.casterEffect
            set targetGroup = d.targetGroup
            set updateTimer = d.updateTimer
            call d.destroy()
            call FlushAttachedIntegerById( casterId, Riposte_SCOPE_ID )
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
            call DestroyEffectWJ( casterEffect )
            set casterEffect = null
            loop
                set enumUnit = FirstOfGroup( targetGroup )
                exitwhen ( enumUnit == null )
                call Target_Target_EndingByEnding( d, GetUnit(enumUnit), targetGroup )
            endloop
            call DestroyGroupWJ( targetGroup )
            set targetGroup = null
            call FlushAttachedInteger( updateTimer, Riposte_SCOPE_ID )
            call DestroyTimerWJ( updateTimer )
            set updateTimer = null
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
                    call Target_Target_EndingByEnding( d, GetUnit(enumUnit), targetGroup )
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
                call Target_Target_Start(d, GetUnit(enumUnit))
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
    endfunction

    private function UpdateByTimer takes nothing returns nothing
        local timer updateTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(updateTimer, Riposte_SCOPE_ID)
        set updateTimer = null
        call Update( d.caster, d, d.targetGroup )
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
        call AttachIntegerById( casterId, Riposte_SCOPE_ID, d )
        //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
        call AttachInteger( updateTimer, Riposte_SCOPE_ID, d )
        call TimerStart( updateTimer, UPDATE_TIME, true, function UpdateByTimer )
        set updateTimer = null
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
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( CASTER_EFFECT_PATH )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
        call Target_Target_Init()
    endfunction
//! runtextmacro Endscope()