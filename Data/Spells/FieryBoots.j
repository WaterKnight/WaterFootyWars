//TESH.scrollpos=268
//TESH.alwaysfold=0
//! runtextmacro Scope("FieryBoots")
    globals
        private constant integer ACTIVATION_ORDER_ID = 852129//OrderId("windwalk")
        private constant integer ACTIVATION_SPELL_BOOK_SPELL_ID = 'A03V'
        public constant integer ACTIVATION_SPELL_ID = 'A02X'
        private constant integer DEACTIVATION_SPELL_BOOK_SPELL_ID = 'A03W'
        public constant integer DEACTIVATION_SPELL_ID = 'A015'
        private constant integer DEACTIVATION_ORDER_ID = 852129//OrderId("windwalk")

        private constant real BONUS_SPEED = 500.
        private constant string CASTER_EFFECT_PATH = "Abilities\\Spells\\Items\\AIsp\\SpeedTarget.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "origin"
        private constant real DRAIN_INTERVAL = 0.5
        private real array DRAINED_MANA
        private real array DRAINED_MANA_PER_INTELLIGENCE_POINT
        private constant real FIRE_SPAWN_INTERVAL = 0.15
        private constant integer LEVELS_AMOUNT = 5
        private constant real MANA_PUFFER = 5.
    endglobals

    private struct Data
        integer abilityLevel
        Unit caster
        effect casterEffect
        timer drainTimer
        timer fireTimer
    endstruct

    private function Ending takes Unit caster, Data d returns nothing
        local effect casterEffect = d.casterEffect
        local integer casterId = caster.id
        local unit casterSelf = caster.self
        local integer abilityLevel = GetUnitAbilityLevel( casterSelf, DEACTIVATION_SPELL_ID )
        local timer drainTimer = d.drainTimer
        local timer fireTimer = d.fireTimer
        call FlushAttachedIntegerById( casterId, FieryBoots_SCOPE_ID )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
        call DestroyEffectWJ( casterEffect )
        set casterEffect = null
        call FlushAttachedInteger( drainTimer, FieryBoots_SCOPE_ID )
        call DestroyTimerWJ( drainTimer )
        set drainTimer = null
        call FlushAttachedInteger( fireTimer, FieryBoots_SCOPE_ID )
        call DestroyTimerWJ( fireTimer )
        set fireTimer = null
        call AddUnitPathing( caster )
        call AddUnitSpeedBonus( caster, -BONUS_SPEED )
        call UnitRemoveAbility( casterSelf, ACTIVATION_SPELL_BOOK_SPELL_ID )
        call UnitRemoveAbility( casterSelf, DEACTIVATION_SPELL_ID )
        //call UnitAddAbility( casterSelf, ACTIVATION_SPELL_BOOK_SPELL_ID )
        //call UnitAddAbility(casterSelf, DEACTIVATION_SPELL_ID)
        //call SetUnitAbilityLevel( casterSelf, DEACTIVATION_SPELL_ID, LEVELS_AMOUNT )
        call UnitAddAbility(casterSelf, ACTIVATION_SPELL_ID)
        call SetUnitAbilityLevel( casterSelf, ACTIVATION_SPELL_ID, abilityLevel )
        set casterSelf = null
    endfunction

    public function Deactivation_EndCast takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, FieryBoots_SCOPE_ID)
        call Ending( caster, d )
    endfunction

    private function Deactivation_EndCast_Event takes nothing returns nothing
        call Deactivation_EndCast( CASTER )
    endfunction

    public function Death takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, FieryBoots_SCOPE_ID)
        if ( d != NULL ) then
            call Ending( caster, d )
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByMana takes nothing returns nothing
        local Unit caster = GetUnit(GetTriggerUnit())
        local Data d = GetAttachedIntegerById(caster.id, FieryBoots_SCOPE_ID)
        if (d != NULL) then
            call Ending( caster, d )
        endif
    endfunction

    //! runtextmacro Scope("Fire")
        globals
            private real array Fire_AREA_RANGE
            private real array Fire_DAMAGE_PER_INTERVAL
            private real array Fire_DAMAGE_PER_INTERVAL_PER_AGILITY_POINT
            private constant integer Fire_DUMMY_UNIT_ID = 'n02D'
            private constant real Fire_DURATION = 2.
            private group Fire_ENUM_GROUP
            private constant real Fire_INTERVAL = 0.25
            private boolexpr Fire_TARGET_CONDITIONS
        endglobals

        private struct Fire_Data
            real areaRange
            Unit caster
            real damagePerIntervalAmount
            unit dummyUnit
            sound effectSound
            timer intervalTimer
            real targetX
            real targetY
        endstruct

        private function Fire_Ending takes Fire_Data d, timer durationTimer returns nothing
            local unit dummyUnit = d.dummyUnit
            local sound effectSound = d.effectSound
            local timer intervalTimer = d.intervalTimer
            call d.destroy()
            call SetUnitAnimationByIndex( dummyUnit, 1 )
            call RemoveUnitTimed( dummyUnit, 7.767 )
            set dummyUnit = null
            call FlushAttachedInteger( durationTimer, Fire_SCOPE_ID )
            call DestroyTimerWJ( durationTimer )
            call StopSound( effectSound, true, true )
            set effectSound = null
            call FlushAttachedInteger( intervalTimer, Fire_SCOPE_ID )
            call DestroyTimerWJ( intervalTimer )
            set intervalTimer = null
        endfunction

        private function Fire_EndingByTimer takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Fire_Data d = GetAttachedInteger(durationTimer, Fire_SCOPE_ID)
            call Fire_Ending( d, durationTimer )
            set durationTimer = null
        endfunction

        private function Fire_TargetConditions takes nothing returns boolean
            set FILTER_UNIT_SELF = GetFilterUnit()
            if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
                return false
            endif
            if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) ) then
                return false
            endif
            if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_FLYING ) ) then
                return false
            endif
            if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
                return false
            endif
            if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
                return false
            endif
            set FILTER_UNIT = GetUnit(FILTER_UNIT_SELF)
            if ( GetUnitInvulnerability( FILTER_UNIT ) > 0 ) then
                return false
            endif
            if ( GetUnitMagicImmunity( FILTER_UNIT ) > 0 ) then
                return false
            endif
            return true
        endfunction

        private function Fire_Interval takes real areaRange, Unit caster, Fire_Data d, real targetX, real targetY returns nothing
            local real damageAmount
            local unit enumUnit
            set TEMP_PLAYER = caster.owner
            call GroupEnumUnitsInRangeWithCollision( Fire_ENUM_GROUP, targetX, targetY, areaRange, Fire_TARGET_CONDITIONS )
            set enumUnit = FirstOfGroup( Fire_ENUM_GROUP )
            if ( enumUnit != null ) then
                set damageAmount = d.damagePerIntervalAmount
                loop
                    call GroupRemoveUnit( Fire_ENUM_GROUP, enumUnit )
                    call UnitDamageUnitBySpell( caster, GetUnit(enumUnit), damageAmount * ( 1 - DistanceByCoordinates( GetUnitX( enumUnit ), GetUnitY( enumUnit ), targetX, targetY ) / areaRange ) )
                    set enumUnit = FirstOfGroup( Fire_ENUM_GROUP )
                    exitwhen ( enumUnit == null )
                endloop
            endif
        endfunction

        private function Fire_IntervalByTimer takes nothing returns nothing
            local timer intervalTimer = GetExpiredTimer()
            local Fire_Data d = GetAttachedInteger(intervalTimer, Fire_SCOPE_ID)
            set intervalTimer = null
            call Fire_Interval( d.areaRange, d.caster, d, d.targetX, d.targetY )
        endfunction

        public function Fire_Start takes integer abilityLevel, Unit caster returns nothing
            local unit casterSelf = caster.self
            local Fire_Data d = Fire_Data.create()
            local timer durationTimer = CreateTimerWJ()
            local sound effectSound = CreateSoundFromType( FIERY_BOOTS_FIRE_SOUND_TYPE )
            local unit enumUnit
            local real areaRange = Fire_AREA_RANGE[abilityLevel]
            local real casterX = GetUnitX( casterSelf )
            local real casterY = GetUnitY( casterSelf )
            local unit dummyUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, Fire_DUMMY_UNIT_ID, casterX, casterY, GetRandomReal( 0, 2 * PI ) )
            local timer intervalTimer = CreateTimerWJ()
            set casterSelf = null
            set d.areaRange = areaRange
            set d.caster = caster
            set d.damagePerIntervalAmount = Fire_DAMAGE_PER_INTERVAL[abilityLevel] + GetHeroAgilityTotal( caster ) * Fire_DAMAGE_PER_INTERVAL_PER_AGILITY_POINT[abilityLevel]
            set d.dummyUnit = dummyUnit
            set d.effectSound = effectSound
            set d.intervalTimer = intervalTimer
            set d.targetX = casterX
            set d.targetY = casterY
            call AttachInteger(durationTimer, Fire_SCOPE_ID, d)
            call AttachInteger(intervalTimer, Fire_SCOPE_ID, d)
            call AttachSoundToUnit( effectSound, dummyUnit )
            call StartSound( effectSound )
            set effectSound = null
            call TimerStart( intervalTimer, Fire_INTERVAL, true, function Fire_IntervalByTimer )
            set intervalTimer = null
            call TimerStart( durationTimer, Fire_DURATION, false, function Fire_EndingByTimer )
            set durationTimer = null
            call Fire_Interval( areaRange, caster, d, casterX, casterY )
        endfunction

        public function Fire_Init takes nothing returns nothing
            local integer iteration = LEVELS_AMOUNT
            set Fire_AREA_RANGE[1] = 150
            set Fire_AREA_RANGE[2] = 150
            set Fire_AREA_RANGE[3] = 150
            set Fire_AREA_RANGE[4] = 150
            set Fire_AREA_RANGE[5] = 150
            set Fire_DAMAGE_PER_INTERVAL[1] = 20
            set Fire_DAMAGE_PER_INTERVAL[2] = 27
            set Fire_DAMAGE_PER_INTERVAL[3] = 34
            set Fire_DAMAGE_PER_INTERVAL[4] = 41
            set Fire_DAMAGE_PER_INTERVAL[5] = 48
            set Fire_DAMAGE_PER_INTERVAL_PER_AGILITY_POINT[1] = 0.55
            set Fire_DAMAGE_PER_INTERVAL_PER_AGILITY_POINT[2] = 0.55
            set Fire_DAMAGE_PER_INTERVAL_PER_AGILITY_POINT[3] = 0.55
            set Fire_DAMAGE_PER_INTERVAL_PER_AGILITY_POINT[4] = 0.55
            set Fire_DAMAGE_PER_INTERVAL_PER_AGILITY_POINT[5] = 0.55
            loop
                set Fire_DAMAGE_PER_INTERVAL[iteration] = Fire_DAMAGE_PER_INTERVAL[iteration] * Fire_INTERVAL
                set Fire_DAMAGE_PER_INTERVAL_PER_AGILITY_POINT[iteration] = Fire_DAMAGE_PER_INTERVAL_PER_AGILITY_POINT[iteration] * Fire_INTERVAL
                set iteration = iteration - 1
                exitwhen (iteration < 1)
            endloop
            set Fire_ENUM_GROUP = CreateGroupWJ()
            set Fire_TARGET_CONDITIONS = ConditionWJ( function Fire_TargetConditions )
            call InitUnitType( Fire_DUMMY_UNIT_ID )
        endfunction
    //! runtextmacro Endscope()

    private function CreateFire takes nothing returns nothing
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, FieryBoots_SCOPE_ID)
        set intervalTimer = null
        call Fire_Fire_Start(d.abilityLevel, d.caster)
    endfunction

    private function DrainMana takes nothing returns nothing
        local timer drainTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(drainTimer, FieryBoots_SCOPE_ID)
        local integer abilityLevel = d.abilityLevel
        local Unit caster = d.caster
        set drainTimer = null
        call AddUnitState( caster.self, UNIT_STATE_MANA, Min( -DRAINED_MANA[abilityLevel] - GetHeroIntelligenceTotal( caster ) * DRAINED_MANA_PER_INTELLIGENCE_POINT[abilityLevel], 0 ) )
    endfunction

    public function Activation_EndCast takes Unit caster returns nothing
        local unit casterSelf = caster.self
        local Data d = GetAttachedIntegerById(caster.id, FieryBoots_SCOPE_ID)
        local integer abilityLevel = GetUnitAbilityLevel( casterSelf, ACTIVATION_SPELL_ID )
        //call UnitRemoveAbility( casterSelf, DEACTIVATION_SPELL_BOOK_SPELL_ID )
        call UnitRemoveAbility( casterSelf, ACTIVATION_SPELL_ID )
        call UnitAddAbility( casterSelf, ACTIVATION_SPELL_BOOK_SPELL_ID )
        call UnitAddAbility( casterSelf, ACTIVATION_SPELL_ID )
        call SetUnitAbilityLevel( casterSelf, ACTIVATION_SPELL_ID, LEVELS_AMOUNT )
        call UnitAddAbility( casterSelf, DEACTIVATION_SPELL_ID )
        call SetUnitAbilityLevel( casterSelf, DEACTIVATION_SPELL_ID, abilityLevel )
        if ( GetUnitState( casterSelf, UNIT_STATE_MANA ) < MANA_PUFFER ) then
            call Ending( caster, d )
        endif
        set casterSelf = null
    endfunction

    private function Activation_EndCast_Event takes nothing returns nothing
        call Activation_EndCast( CASTER )
    endfunction

    public function OrderExecute takes Unit caster returns nothing
        local integer abilityLevel
        local integer casterId = caster.id
        local unit casterSelf
        local Data d = GetAttachedIntegerById(casterId, FieryBoots_SCOPE_ID)
        local timer drainTimer
        local timer fireTimer
        if ( d == NULL ) then
            set casterSelf = caster.self
            set abilityLevel = GetUnitAbilityLevel( casterSelf, ACTIVATION_SPELL_ID )
            set d = Data.create()
            set drainTimer = CreateTimerWJ()
            set fireTimer = CreateTimerWJ()
            set d.abilityLevel = abilityLevel
            set d.caster = caster
            set d.casterEffect = AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, casterSelf, CASTER_EFFECT_ATTACHMENT_POINT )
            set casterSelf = null
            set d.drainTimer = drainTimer
            set d.fireTimer = fireTimer
            call AttachIntegerById(casterId, FieryBoots_SCOPE_ID, d)
            //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
            call AttachInteger(drainTimer, FieryBoots_SCOPE_ID, d)
            call AttachInteger(fireTimer, FieryBoots_SCOPE_ID, d)
            call RemoveUnitPathing( caster )
            call AddUnitSpeedBonus( caster, BONUS_SPEED )
            call TimerStart( drainTimer, DRAIN_INTERVAL, true, function DrainMana )
            set drainTimer = null
            call TimerStart( fireTimer, FIRE_SPAWN_INTERVAL, true, function CreateFire )
            set fireTimer = null
        endif
    endfunction

    private function OrderExecute_Event takes nothing returns nothing
        call OrderExecute( ORDERED_UNIT )
    endfunction

    //! runtextmacro Scope("LowManaTrigger")
        public struct LowManaTrigger_Data
            trigger dummyTrigger
        endstruct

        public function Learn takes Unit caster returns nothing
            local integer casterId = caster.id
            local LowManaTrigger_Data d = GetAttachedIntegerById(casterId, LowManaTrigger_SCOPE_ID)
            local trigger dummyTrigger
            if (d == NULL) then
                set d = LowManaTrigger_Data.create()
                set dummyTrigger = CreateTriggerWJ()
                set d.dummyTrigger = dummyTrigger
                call AttachIntegerById(casterId, LowManaTrigger_SCOPE_ID, d)
                call AddTriggerCode( dummyTrigger, function EndingByMana )
                call TriggerRegisterUnitStateEvent( dummyTrigger, caster.self, UNIT_STATE_MANA, LESS_THAN, MANA_PUFFER )
                set dummyTrigger = null
            endif
        endfunction

        private function Learn_Event takes nothing returns nothing
            call Learn(LEARNER)
        endfunction
    //! runtextmacro Endscope()

    private function Init_AddEvents takes nothing returns nothing
        //! runtextmacro AddEventById( "GetAbilityOrderId( ACTIVATION_SPELL_ID, ACTIVATION_ORDER_ID )", "EVENT_ORDER_EXECUTE" )
        //! runtextmacro AddEventById( "GetAbilityOrderId( DEACTIVATION_SPELL_ID, DEACTIVATION_ORDER_ID )", "EVENT_ORDER_EXECUTE" )
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = MAX_PLAYER_INDEX
        local player specificPlayer
        set DRAINED_MANA[1] = 15
        set DRAINED_MANA[2] = 15
        set DRAINED_MANA[3] = 15
        set DRAINED_MANA[4] = 15
        set DRAINED_MANA[5] = 15
        set DRAINED_MANA_PER_INTELLIGENCE_POINT[1] = 0
        set DRAINED_MANA_PER_INTELLIGENCE_POINT[2] = 0
        set DRAINED_MANA_PER_INTELLIGENCE_POINT[3] = 0
        set DRAINED_MANA_PER_INTELLIGENCE_POINT[4] = 0
        set DRAINED_MANA_PER_INTELLIGENCE_POINT[5] = 0
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        call AddOrderAbility( ACTIVATION_ORDER_ID, ACTIVATION_SPELL_ID )
        call InitAbility( ACTIVATION_SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ACTIVATION_ENDCAST", "ACTIVATION_SPELL_ID", "UnitFinishesCasting_EVENT_KEY", "0", "function Activation_EndCast_Event" )
        //! runtextmacro CreateEvent( "EVENT_ORDER_EXECUTE", "UnitGetsOrder_Executed_Executed_EVENT_KEY", "0", "function OrderExecute_Event" )
        call InitAbility( ACTIVATION_SPELL_BOOK_SPELL_ID )
        call InitEffectType( CASTER_EFFECT_PATH )
        call AddOrderAbility( DEACTIVATION_ORDER_ID, DEACTIVATION_SPELL_ID )
        call InitAbility( DEACTIVATION_SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_DEACTIVATION_ENDCAST", "DEACTIVATION_SPELL_ID", "UnitFinishesCasting_EVENT_KEY", "0", "function Deactivation_EndCast_Event" )
        call InitAbility( DEACTIVATION_SPELL_BOOK_SPELL_ID )
        loop
            set specificPlayer = PlayerWJ( iteration )
            call SetPlayerAbilityAvailable( specificPlayer, ACTIVATION_SPELL_BOOK_SPELL_ID, false )
            call SetPlayerAbilityAvailable( specificPlayer, DEACTIVATION_SPELL_BOOK_SPELL_ID, false )
            set iteration = iteration - 1
            exitwhen ( iteration < 0 )
        endloop
        set specificPlayer = null

        call Init_AddEvents()

        call Fire_Fire_Init()
    endfunction
//! runtextmacro Endscope()