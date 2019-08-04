//TESH.scrollpos=284
//TESH.alwaysfold=0
//! runtextmacro Scope("CripplingWave")
    private struct Data
        Unit caster
        timer delayTimer
        integer jumpsAmount
        Unit target
        group targetGroup
    endstruct

    globals
        private constant integer ORDER_ID = 852189//OrderId( "cripple" )
        public constant integer SPELL_ID = 'A039'

        private constant real AREA_RANGE = 700.
        private trigger CHOOSE_TRIGGER
        private constant real EFFECT_LIGHTNING_DURATION = 0.3
        private constant string EFFECT_LIGHTNING_PATH = "AFOD"
        private group ENUM_GROUP
        private group ENUM_GROUP2
        private group ENUM_GROUP3
        private constant real JUMP_DELAY = 0.175
        private constant integer MAX_TARGETS_AMOUNT = 4
        private boolexpr TARGET_CONDITIONS
        private constant string TARGET_EFFECT_PATH = "CripplingWaveTargetImpact.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "chest"

        private Data chooseTriggerD
        private Unit chooseTriggerSource
    endglobals

    //! runtextmacro Scope("Target")
        globals
            private constant real Target_BONUS_MISS_CHANCE = 0.25
            private constant real Target_DAMAGE_LOSS_FACTOR = 0.4
            private constant real Target_DURATION = 20.
            private constant string Target_TARGET_EFFECT_PATH = "Abilities\\Spells\\Orc\\StasisTrap\\StasisTotemTarget.mdl"
            private constant string Target_TARGET_EFFECT_ATTACHMENT_POINT = "overhead"
        endglobals

        private struct Target_Data
            real bonusDamage
            timer durationTimer
            Unit target
            effect targetEffect
        endstruct

        public function Target_IsNotTarget takes Unit target returns boolean
            return (GetAttachedIntegerById(target.id, Target_SCOPE_ID) == NULL)
        endfunction

        private function Target_Ending takes Target_Data d, timer durationTimer, Unit target returns nothing
            local real bonusDamage = d.bonusDamage
            local effect targetEffect = d.targetEffect
            local integer targetId = target.id
            call d.destroy()
            call FlushAttachedInteger( durationTimer, Target_SCOPE_ID )
            call DestroyTimerWJ( durationTimer )
            call FlushAttachedIntegerById( targetId, Target_SCOPE_ID )
            call DestroyEffectWJ( targetEffect )
            set targetEffect = null
            //! runtextmacro RemoveEventById( "targetId", "Target_EVENT_DEATH" )
            call AddUnitDamageBonus( target, -bonusDamage )
            call AddUnitMissChance( target, -Target_BONUS_MISS_CHANCE )
        endfunction

        public function Target_Death takes Unit target returns nothing
            local Target_Data d = GetAttachedIntegerById(target.id, Target_SCOPE_ID)
            if ( d != NULL ) then
                call Target_Ending( d, d.durationTimer, target )
            endif
        endfunction

        private function Target_Death_Event takes nothing returns nothing
            call Target_Death( DYING_UNIT )
        endfunction

        private function Target_EndingByTimer takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Target_Data d = GetAttachedInteger(durationTimer, Target_SCOPE_ID)
            call Target_Ending( d, durationTimer, d.target )
            set durationTimer = null
        endfunction

        public function Target_Start takes Unit target returns nothing
            local real bonusDamage
            local timer durationTimer
            local integer targetId = target.id
            local Target_Data d = GetAttachedIntegerById( targetId, Target_SCOPE_ID )
            if ( d == NULL ) then
                set bonusDamage = -GetUnitDamage( target ) * Target_DAMAGE_LOSS_FACTOR
                set d = Target_Data.create()
                set durationTimer = CreateTimerWJ()
                set d.bonusDamage = bonusDamage
                set d.durationTimer = durationTimer
                set d.target = target
                call AttachInteger( durationTimer, Target_SCOPE_ID, d )
                call AttachIntegerById( targetId, Target_SCOPE_ID, d )
                //! runtextmacro AddEventById( "targetId", "Target_EVENT_DEATH" )
                call AddUnitDamageBonus( target, bonusDamage )
                call AddUnitMissChance( target, Target_BONUS_MISS_CHANCE )
            else
                set durationTimer = d.durationTimer
            endif
            set d.targetEffect = AddSpecialEffectTargetWJ( Target_TARGET_EFFECT_PATH, target.self, Target_TARGET_EFFECT_ATTACHMENT_POINT )
            call TimerStart( durationTimer, Target_DURATION, false, function Target_EndingByTimer )
            set durationTimer = null
        endfunction

        public function Target_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "Target_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Target_Death_Event" )
            call InitEffectType( TARGET_EFFECT_PATH )
        endfunction
    //! runtextmacro Endscope()

    private function TargetConditions_Single takes player casterOwner, Unit checkingUnit returns boolean
        set TEMP_UNIT_SELF = checkingUnit.self
        if ( GetUnitState( TEMP_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( TEMP_UNIT_SELF, casterOwner ) ) then
            return false
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        if ( GetUnitMagicImmunity( checkingUnit ) > 0 ) then
            return false
        endif
        if ( GetUnitInvulnerability( checkingUnit ) > 0 ) then
            return false
        endif
        if ( IsUnitWard( checkingUnit ) ) then
            return false
        endif
        return true
    endfunction

    private function Ending_Target takes Data d, Unit target returns nothing
        local integer targetId = target.id
        call RemoveIntegerFromTableById(targetId, CripplingWave_SCOPE_ID, d)
        if (CountIntegersInTableById(targetId, CripplingWave_SCOPE_ID) == TABLE_EMPTY) then
            //! runtextmacro RemoveEventById( "targetId", "EVENT_DECAY" )
        endif
    endfunction

    private function Ending takes Unit caster, Data d, timer delayTimer, boolean isTargetNotNull, Unit target, group targetGroup returns nothing
        call d.destroy()
        call RemoveUnitRemainingReference( caster )
        call FlushAttachedInteger( delayTimer, CripplingWave_SCOPE_ID )
        call DestroyTimerWJ( delayTimer )
        if ( isTargetNotNull ) then
            call Ending_Target(d, target)
        endif
        call DestroyGroupWJ( targetGroup )
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( IsUnitInGroup( FILTER_UNIT_SELF, TEMP_GROUP ) ) then
            return false
        endif
        if ( TargetConditions_Single( TEMP_PLAYER, GetUnit(FILTER_UNIT_SELF) ) == false ) then
            return false
        endif
        return true
    endfunction

    private function Impact takes nothing returns nothing
        local timer delayTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(delayTimer, CripplingWave_SCOPE_ID)
        local Unit caster = d.caster
        local integer jumpsAmount
        local Unit target = d.target
        call Ending_Target(d, target)
        if ( target == NULL ) then
            call Ending( caster, d, delayTimer, false, NULL, d.targetGroup )
        else
            call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, target.self, TARGET_EFFECT_ATTACHMENT_POINT ) )
            if ( TargetConditions_Single( caster.owner, target ) ) then
                set jumpsAmount = d.jumpsAmount + 1
                if ( jumpsAmount < MAX_TARGETS_AMOUNT ) then
                    set chooseTriggerD = d
                    set chooseTriggerSource = target
                    set d.jumpsAmount = jumpsAmount
                    call RunTrigger(CHOOSE_TRIGGER)
                else
                    call Ending( caster, d, delayTimer, true, target, d.targetGroup )
                endif
                call Target_Target_Start(target)
            else
                call Ending( caster, d, delayTimer, true, target, d.targetGroup )
            endif
        endif
        set delayTimer = null
    endfunction

    public function Decay takes Unit target returns nothing
        local Data d
        local integer targetId = target.id
        local integer iteration = CountIntegersInTableById(targetId, CripplingWave_SCOPE_ID)
        if ( iteration > TABLE_EMPTY ) then
            loop
                set d = GetIntegerFromTableById(targetId, CripplingWave_SCOPE_ID, iteration)
                call Ending_Target(d, target)
                set d.target = NULL
                set iteration = iteration - 1
                exitwhen (iteration < TABLE_STARTED)
            endloop
        endif
    endfunction

    private function Decay_Event takes nothing returns nothing
        call Decay(TRIGGER_UNIT)
    endfunction

    public function Jump takes Data d, timer delayTimer, Unit source, Unit target, group targetGroup returns nothing
        local integer targetId = target.id
        call DestroyLightningTimedEx( AddLightningBetweenUnits( EFFECT_LIGHTNING_PATH, source, target ), EFFECT_LIGHTNING_DURATION )
        set d.target = target
        call AddIntegerToTableById(targetId, CripplingWave_SCOPE_ID, d)
        if (CountIntegersInTableById(targetId, CripplingWave_SCOPE_ID) == TABLE_STARTED) then
            //! runtextmacro AddEventById( "targetId", "EVENT_DECAY" )
        endif
        call GroupAddUnit( targetGroup, target.self )
        call TimerStart( delayTimer, JUMP_DELAY, false, function Impact )
    endfunction

    private function ChooseTrig takes nothing returns nothing
        local Data d = chooseTriggerD
        local Unit caster = d.caster
        local unit enumUnit
        local Unit source = chooseTriggerSource
        local unit sourceSelf = source.self
        local real sourceX = GetUnitX( sourceSelf )
        local real sourceY = GetUnitY( sourceSelf )
        local group targetGroup = d.targetGroup
        set sourceSelf = null
        set TEMP_GROUP = targetGroup
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, sourceX, sourceY, AREA_RANGE, TARGET_CONDITIONS )
        loop
            set enumUnit = FirstOfGroup( ENUM_GROUP )
            exitwhen ( enumUnit == null )
            call GroupRemoveUnit( ENUM_GROUP, enumUnit )
            if ( Target_Target_IsNotTarget(GetUnit(enumUnit)) ) then
                call GroupAddUnit( ENUM_GROUP2, enumUnit )
            else
                call GroupAddUnit( ENUM_GROUP3, enumUnit )
            endif
        endloop
        set enumUnit = GetNearestUnit( ENUM_GROUP2, sourceX, sourceY )
        if ( enumUnit == null ) then
            set enumUnit = GetNearestUnit( ENUM_GROUP3, sourceX, sourceY )
        else
            call GroupClear( ENUM_GROUP2 )
        endif
        if ( enumUnit == null ) then
            call Ending( caster, d, d.delayTimer, false, GetUnit(enumUnit), targetGroup )
        else
            call GroupClear( ENUM_GROUP3 )
            call Jump( d, d.delayTimer, source, GetUnit(enumUnit), targetGroup )
            set enumUnit = null
        endif
        set targetGroup = null
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local Data d = Data.create()
        local timer delayTimer = CreateTimerWJ()
        local group targetGroup = CreateGroupWJ()
        set d.caster = caster
        set d.delayTimer = delayTimer
        set d.jumpsAmount = 0
        set d.targetGroup = targetGroup
        call AddUnitRemainingReference( caster )
        call AttachInteger( delayTimer, CripplingWave_SCOPE_ID, d )
        call Jump( d, delayTimer, caster, target, targetGroup )
        set delayTimer = null
        set targetGroup = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect(CASTER, TARGET_UNIT)
    endfunction

    public function Order takes player casterOwner, unit target returns string
        if ( IsUnitAlly( target, casterOwner ) ) then
            return ErrorStrings_NOT_ALLY
        endif
        if ( IsUnitType( target, UNIT_TYPE_MECHANICAL ) ) then
            return ErrorStrings_NOT_MECHANICAL
        endif
        if ( IsUnitType( target, UNIT_TYPE_STRUCTURE ) ) then
            return ErrorStrings_NOT_STRUCTURE
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( ORDERED_UNIT.owner, TARGET_UNIT.self )
    endfunction

    public function Init takes nothing returns nothing
        set CHOOSE_TRIGGER = CreateTriggerWJ()
        set ENUM_GROUP = CreateGroupWJ()
        set ENUM_GROUP2 = CreateGroupWJ()
        set ENUM_GROUP3 = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DECAY", "UnitFinishesDecaying_EVENT_KEY", "0", "function Decay_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call AddTriggerCode(CHOOSE_TRIGGER, function ChooseTrig)
        call InitEffectType( TARGET_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call Target_Target_Init()
    endfunction
//! runtextmacro Endscope()