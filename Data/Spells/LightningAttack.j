//TESH.scrollpos=212
//TESH.alwaysfold=0
//! runtextmacro Scope("LightningAttack")
    private struct Data
        Unit caster
        real damageAmount
        timer delayTimer
        integer jumpsAmount
        Unit target
        group targetGroup
    endstruct

    globals
        public constant integer SPELL_ID = 'A03Y'

        private constant real AREA_RANGE = 500.
        private constant real CHANCE = 0.1
        private trigger CHOOSE_TRIGGER
        private constant real DAMAGE_REDUCTION_PER_JUMP_FACTOR = 0.15
        private constant real DURATION = 1.
        private constant real EFFECT_LIGHTNING_DURATION = 0.35
        private constant string EFFECT_LIGHTNING_PATH = "CLPB"
        private constant string EFFECT_LIGHTNING2_PATH = "CLSB"
        private group ENUM_GROUP
        private constant real JUMP_DELAY = 0.2
        private constant integer MAX_TARGETS_AMOUNT = 5
        private boolexpr TARGET_CONDITIONS
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Items\\AIlb\\AIlbSpecialArt.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "chest"

        private Data chooseTriggerD
        private Unit chooseTriggerSource
    endglobals

    public function DecayEnd takes Unit caster returns nothing
        local integer casterId = caster.id
        if (GetAttachedBooleanById(casterId, LightningAttack_SCOPE_ID)) then
            call FlushAttachedBooleanById(casterId, LightningAttack_SCOPE_ID)
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DAMAGE" )
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DECAY_END" )
        endif
    endfunction

    private function DecayEnd_Event takes nothing returns nothing
        call DecayEnd(DYING_UNIT)
    endfunction

    private function Ending_Target takes Data d, Unit target returns nothing
        local integer targetId = target.id
        call RemoveIntegerFromTableById(targetId, LightningAttack_SCOPE_ID, d)
        if (CountIntegersInTableById(targetId, LightningAttack_SCOPE_ID) == TABLE_EMPTY) then
            //! runtextmacro RemoveEventById( "targetId", "EVENT_DECAY" )
        endif
    endfunction

    private function Ending takes Unit caster, Data d, timer delayTimer, boolean isTargetNotNull, Unit target, group targetGroup returns nothing
        call d.destroy()
        call RemoveUnitRemainingReference( caster )
        call FlushAttachedInteger( delayTimer, LightningAttack_SCOPE_ID )
        call DestroyTimerWJ( delayTimer )
        if ( isTargetNotNull ) then
            call Ending_Target(d, target)
        endif
        call DestroyGroupWJ( targetGroup )
    endfunction

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
        if ( GetUnitInvulnerability( checkingUnit ) > 0 ) then
            return false
        endif
        if ( GetUnitMagicImmunity( checkingUnit ) > 0 ) then
            return false
        endif
        if ( IsUnitWard( checkingUnit ) ) then
            return false
        endif
        return true
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
        local Data d = GetAttachedInteger(delayTimer, LightningAttack_SCOPE_ID)
        local Unit caster = d.caster
        local real damageAmount = d.damageAmount
        local integer jumpsAmount
        local Unit target = d.target
        call Ending_Target(d, target)
        if ( target == null ) then
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
                call UnitDamageUnitEx( caster, target, damageAmount * GetAttackMultiplier(DMG_TYPE_NORMAL, GetUnitTypeArmorType(target.type)) * ( 1 - ( jumpsAmount - 1 ) * DAMAGE_REDUCTION_PER_JUMP_FACTOR ), null )
            else
                call Ending( caster, d, delayTimer, true, target, d.targetGroup )
            endif
        endif
        set delayTimer = null
    endfunction

    public function Decay takes Unit target returns nothing
        local Data d
        local integer targetId = target.id
        local integer iteration = CountIntegersInTableById(targetId, LightningAttack_SCOPE_ID)
        if ( iteration > TABLE_EMPTY ) then
            loop
                set d = GetIntegerFromTableById(targetId, LightningAttack_SCOPE_ID, iteration)
                set d.target = NULL
                call Ending_Target(d, target)
                set iteration = iteration - 1
                exitwhen (iteration < TABLE_STARTED)
            endloop
        endif
    endfunction

    private function Decay_Event takes nothing returns nothing
        call Decay(TRIGGER_UNIT)
    endfunction

    public function Jump takes Data d, timer delayTimer, Unit source, Unit target, group targetGroup, string whichLightningTypeId returns nothing
        local integer targetId = target.id
        call DestroyLightningTimed( AddLightningBetweenUnits( whichLightningTypeId, source, target ), EFFECT_LIGHTNING_DURATION )
        set d.target = target
        call AddIntegerToTableById(targetId, LightningAttack_SCOPE_ID, d)
        if (CountIntegersInTableById(targetId, LightningAttack_SCOPE_ID) == TABLE_STARTED) then
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
        set enumUnit = GetNearestUnit( ENUM_GROUP, sourceX, sourceY )
        if ( enumUnit == null ) then
            call Ending( caster, d, d.delayTimer, false, GetUnit(enumUnit), targetGroup )
        else
            call Jump( d, d.delayTimer, source, GetUnit(enumUnit), targetGroup, EFFECT_LIGHTNING2_PATH )
            set enumUnit = null
        endif
        set targetGroup = null
    endfunction

    public function Damage takes Unit caster, Unit target returns nothing
        local Data d
        local timer delayTimer
        local group targetGroup
        if ( GetUnitAbilityLevel(caster.self, SPELL_ID) > 0 ) then
            set d = Data.create()
            set delayTimer = CreateTimerWJ()
            set targetGroup = CreateGroupWJ()
            set d.caster = caster
            set d.damageAmount = GetUnitDamage(caster)
            set d.delayTimer = delayTimer
            set d.jumpsAmount = 0
            set d.targetGroup = targetGroup
            call AddUnitRemainingReference( caster )
            call AttachInteger( delayTimer, LightningAttack_SCOPE_ID, d )
            call Jump( d, delayTimer, caster, target, targetGroup, EFFECT_LIGHTNING_PATH )
            set delayTimer = null
            set targetGroup = null
        endif
    endfunction

    private function Damage_Event takes nothing returns nothing
        call Damage(DAMAGE_SOURCE, TRIGGER_UNIT)
    endfunction

    public function Learn takes Unit caster returns nothing
        local integer casterId = caster.id
        call AttachBooleanById(casterId, LightningAttack_SCOPE_ID, true)
        //! runtextmacro AddEventById( "casterId", "EVENT_DAMAGE" )
        //! runtextmacro AddEventById( "casterId", "EVENT_DECAY_END" )
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        set CHOOSE_TRIGGER = CreateTriggerWJ()
        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY_AS_DAMAGE_SOURCE", "0", "function Damage_Event" )
        //! runtextmacro CreateEvent( "EVENT_DECAY", "UnitFinishesDecaying_EVENT_KEY", "0", "function Decay_Event" )
        //! runtextmacro CreateEvent( "EVENT_DECAY_END", "UnitFinishesDecaying_End_End_EVENT_KEY", "0", "function DecayEnd_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call AddTriggerCode(CHOOSE_TRIGGER, function ChooseTrig)
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
        call InitEffectType( TARGET_EFFECT_PATH )
    endfunction
//! runtextmacro Endscope()