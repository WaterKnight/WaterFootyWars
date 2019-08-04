//TESH.scrollpos=58
//TESH.alwaysfold=0
//! runtextmacro Scope("Pulverize")
    globals
        public constant integer DUMMY_SPELL_ID = 'A07X'
        public constant integer SPELL_ID = 'A07Y'

        private constant real AREA_RANGE = 250.
        private constant real CHANCE = 0.3
        private constant real DAMAGE_FACTOR = 0.8
        private group ENUM_GROUP
        private boolexpr TARGET_CONDITIONS
    endglobals

    public function DecayEnd takes Unit caster returns nothing
        local integer casterId
        if (GetUnitAbilityLevel(caster.self, SPELL_ID) > 0) then
            set casterId = caster.id
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DAMAGE" )
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DECAY_END" )
        endif
    endfunction

    private function DecayEnd_Event takes nothing returns nothing
        call DecayEnd( TRIGGER_UNIT )
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if (IsUnitAlly(FILTER_UNIT_SELF, TEMP_PLAYER)) then
            return false
        endif
        if (FILTER_UNIT_SELF == TEMP_UNIT_SELF) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_FLYING ) != TEMP_BOOLEAN ) then
            return false
        endif
        if (GetUnitInvulnerability(GetUnit(FILTER_UNIT_SELF)) > 0) then
            return false
        endif
        return true
    endfunction

    public function Damage takes Unit caster, real damageAmount, Unit target returns nothing
        local unit casterSelf = caster.self
        local unit enumUnit
        if ( GetUnitAbilityLevel( casterSelf, DUMMY_SPELL_ID ) > 0 ) then
            set TEMP_BOOLEAN = IsUnitType( casterSelf, UNIT_TYPE_FLYING )
            set TEMP_PLAYER = caster.owner
            set TEMP_UNIT_SELF = target.self
            call GroupEnumUnitsInRange(ENUM_GROUP, GetUnitX(casterSelf), GetUnitY(casterSelf), AREA_RANGE, TARGET_CONDITIONS)
            set enumUnit = FirstOfGroup(ENUM_GROUP)
            if (enumUnit != null) then
                loop
                    call GroupRemoveUnit(ENUM_GROUP, enumUnit)
                    call UnitDamageUnitEx(caster, GetUnit(enumUnit), GetUnitDamageTotal(caster) * DAMAGE_FACTOR, null)
                    set enumUnit = FirstOfGroup(ENUM_GROUP)
                    exitwhen (enumUnit == null)
                endloop
            endif
        endif
        set casterSelf = null
    endfunction

    private function Damage_Event takes nothing returns nothing
        call Damage( DAMAGE_SOURCE, DAMAGE_AMOUNT, TRIGGER_UNIT )
    endfunction

    public function TargetInRange takes Unit caster returns nothing
        local unit casterSelf = caster.self
        if (GetUnitAbilityLevel(casterSelf, SPELL_ID) > 0) then
            if (GetRandomReal(0.01, 1) < CHANCE) then
                call UnitAddAbility(casterSelf, DUMMY_SPELL_ID)
            else
                call UnitRemoveAbility(casterSelf, DUMMY_SPELL_ID)
            endif
        endif
        set casterSelf = null
    endfunction

    private function TargetInRange_Event takes nothing returns nothing
        call TargetInRange( TRIGGER_UNIT )
    endfunction

    public function Learn takes Unit caster returns nothing
        local integer casterId = caster.id
        //! runtextmacro AddEventById( "casterId", "EVENT_DAMAGE" )
        //! runtextmacro AddEventById( "casterId", "EVENT_DECAY_END" )
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_ACQUIRE", "UnitAcquiresTarget_EVENT_KEY", "0", "function TargetInRange_Event" )
        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY_FOR_UNBLOCKABLE_AS_DAMAGE_SOURCE", "0", "function Damage_Event" )
        //! runtextmacro CreateEvent( "EVENT_DECAY_END", "UnitFinishesDecaying_End_End_EVENT_KEY", "0", "function DecayEnd_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
    endfunction
//! runtextmacro Endscope()