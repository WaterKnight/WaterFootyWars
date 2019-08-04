//TESH.scrollpos=303
//TESH.alwaysfold=0
//! runtextmacro Scope("NaturalEmbrace")
    globals
        private constant integer ORDER_ID = 852147//OrderId( "entangle" )
        public constant integer SPELL_ID = 'A01P'

        private real array ABSORPTION_FACTOR
        private constant string CASTER_EFFECT_PATH = "Abilities\\Spells\\Human\\Heal\\HealTarget.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "origin"
        private real array DAMAGE_PER_INTERVAL
        private constant real DUMMY_SCALE = 1.
        private constant integer DUMMY_UNIT_ID = 'h00G'
        private real array DURATION
        private real array HERO_DAMAGE_PER_INTERVAL
        private real array HERO_DURATION
        private integer array HERO_WAVES_AMOUNT
        private real array INTERVAL
        private constant integer LEVELS_AMOUNT = 5
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\NightElf\\EntanglingRoots\\EntanglingRootsTarget.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        private constant string TARGET_EFFECT2_PATH = "Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl"
        private constant string TARGET_EFFECT2_ATTACHMENT_POINT = "chest"
        private constant real TELEPORT_THRESHOLD = 500.
        private constant real UPDATE_TIME = 0.25
        private integer array WAVES_AMOUNT
    endglobals

    private struct Data
        integer abilityLevel
        Unit array caster[LEVELS_AMOUNT]
        unit dummyUnit
        timer array durationTimer[LEVELS_AMOUNT]
        timer intervalTimer
        Unit target
        effect targetEffect
        timer updateTimer
        real x
        real y
    endstruct

    private function Interval takes nothing returns nothing
        local integer abilityLevel
        local real absorptionAmount
        local Unit caster
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, NaturalEmbrace_SCOPE_ID)
        local Unit target = d.target
        local unit targetSelf = target.self
        local real targetX = GetUnitX( targetSelf )
        local real targetY = GetUnitY( targetSelf )
        local real x = d.x
        local real y = d.y
        local integer currentOrder = GetUnitCurrentOrder( targetSelf )
        set intervalTimer = null
        if ( ( x != targetX ) or ( y != targetY ) ) then
            set abilityLevel = d.abilityLevel
            set caster = d.caster
            if ( IsUnitType( targetSelf, UNIT_TYPE_HERO ) ) then
                set absorptionAmount = HERO_DAMAGE_PER_INTERVAL[abilityLevel]
            else
                set absorptionAmount = DAMAGE_PER_INTERVAL[abilityLevel]
            endif
            set absorptionAmount = Max(GetUnitState(targetSelf, UNIT_STATE_LIFE), absorptionAmount)
            set d.x = targetX
            set d.y = targetY
            call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT2_PATH, targetSelf, TARGET_EFFECT2_ATTACHMENT_POINT ) )
            call DestroyEffectWJ( AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, targetSelf, CASTER_EFFECT_ATTACHMENT_POINT ) )
            if ( IsUnitIllusionWJ( target ) ) then
                call KillUnit( targetSelf )
            else
                call UnitDamageUnitBySpell( caster, target, absorptionAmount )
                call HealUnitBySpell( caster, absorptionAmount * ABSORPTION_FACTOR[abilityLevel] )
            endif
        endif
        set targetSelf = null
    endfunction

    private function Ending takes Data d, timer durationTimer, Unit target returns nothing
        local integer abilityLevel = d.abilityLevel
        local unit dummyUnit
        local timer intervalTimer
        local integer iteration = abilityLevel - 1
        local effect targetEffect
        local integer targetId
        local timer updateTimer
        loop
            exitwhen (durationTimer == d.durationTimer[iteration])
            set iteration = iteration - 1
        endloop
        set d.durationTimer[iteration] = null
        if ( iteration > abilityLevel ) then
            loop
                exitwhen (iteration < 0)
                exitwhen (d.durationTimer[iteration] != null)
                set iteration = iteration - 1
            endloop
            if ( iteration > -1 ) then
                set d.abilityLevel = iteration + 1
                call TimerStart(d.intervalTimer, INTERVAL[iteration], true, function Interval)
            else
                set dummyUnit = d.dummyUnit
                set intervalTimer = d.intervalTimer
                set targetEffect = d.targetEffect
                set targetId = target.id
                set updateTimer = d.updateTimer
                call d.destroy()
                call RemoveUnitWJ(dummyUnit)
                set dummyUnit = null
                call FlushAttachedInteger(intervalTimer, NaturalEmbrace_SCOPE_ID)
                call DestroyTimerWJ(intervalTimer)
                set intervalTimer = null
                call DestroyEffectWJ( targetEffect )
                set targetEffect = null
                call FlushAttachedInteger(updateTimer, NaturalEmbrace_SCOPE_ID)
                call DestroyTimerWJ(updateTimer)
                set updateTimer = null
                call FlushAttachedIntegerById( targetId, NaturalEmbrace_SCOPE_ID )
                //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
                //! runtextmacro RemoveEventById( "targetId", "EVENT_DISPEL" )
            endif
        endif
        call FlushAttachedInteger( durationTimer, NaturalEmbrace_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
    endfunction

    public function Dispel takes Unit target returns nothing
        local integer abilityLevel
        local Data d = GetAttachedIntegerById(target.id, NaturalEmbrace_SCOPE_ID)
        local timer durationTimer
        local integer iteration
        if (d != NULL) then
            set abilityLevel = d.abilityLevel
            set iteration = 0
            loop
                set durationTimer = d.durationTimer[iteration]
                if ( durationTimer != null ) then
                    call Ending( d, durationTimer, target )
                endif
                set iteration = iteration + 1
                exitwhen ( iteration >= abilityLevel )
            endloop
            set durationTimer = null
        endif
    endfunction

    private function Dispel_Event takes nothing returns nothing
        call Dispel( TRIGGER_UNIT )
    endfunction

    public function Death takes Unit target returns nothing
        call Dispel( target )
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, NaturalEmbrace_SCOPE_ID)
        call Ending( d, durationTimer, d.target )
        set durationTimer = null
    endfunction

    private function Move takes nothing returns nothing
        local timer updateTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(updateTimer, NaturalEmbrace_SCOPE_ID)
        local unit dummyUnit = d.dummyUnit
        local Unit target = d.target
        local unit targetSelf = target.self
        local real targetX = GetUnitX( targetSelf )
        local real targetY = GetUnitY( targetSelf )
        local real x = d.x
        local real y = d.y
        set targetSelf = null
        set updateTimer = null
        if ( ( targetX != x ) or ( targetY != y ) ) then
            set d.x = x
            set d.y = y
            if ( DistanceByCoordinates( x, y, targetX, targetY ) > TELEPORT_THRESHOLD ) then
                call SetUnitX( dummyUnit, targetX )
                call SetUnitY( dummyUnit, targetY )
            else
                call IssuePointOrderById( dummyUnit, MOVE_ORDER_ID, targetX, targetY )
            endif
        endif
        set dummyUnit = null
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local integer abilityLevel = GetUnitAbilityLevel(caster.self, SPELL_ID)
        local unit dummyUnit
        local real duration
        local timer durationTimer
        local timer intervalTimer
        local integer iteration
        local integer oldAbilityLevel
        local integer targetId = target.id
        local Data d = GetAttachedIntegerById(targetId, NaturalEmbrace_SCOPE_ID)
        local boolean isNew = (d == NULL)
        local unit targetSelf = target.self
        local real targetX
        local real targetY
        local timer updateTimer
        if ( isNew ) then
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set intervalTimer = CreateTimerWJ()
            set iteration = LEVELS_AMOUNT - 1
            set targetX = GetUnitX(targetSelf)
            set targetY = GetUnitY(targetSelf)
            set dummyUnit = CreateUnitWJ(NEUTRAL_PASSIVE_PLAYER, DUMMY_UNIT_ID, targetX, targetY, GetUnitFacingWJ(targetSelf))
            set updateTimer = CreateTimerWJ()
            set d.abilityLevel = abilityLevel
            set d.dummyUnit = dummyUnit
            set d.target = target
            set d.x = targetX
            set d.y = targetY
            loop
                if (iteration == abilityLevel) then
                    set d.caster[iteration] = caster
                    set d.durationTimer[iteration] = durationTimer
                else
                    set d.caster[iteration] = NULL
                    set d.durationTimer[iteration] = null
                endif
                set iteration = iteration - 1
                exitwhen (iteration < 0)
            endloop
            call AttachInteger(durationTimer, NaturalEmbrace_SCOPE_ID, d)
            call AttachIntegerById(targetId, NaturalEmbrace_SCOPE_ID, d)
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
            //! runtextmacro AddEventById( "targetId", "EVENT_DISPEL" )
        else
            set durationTimer = d.durationTimer[abilityLevel]
            set d.caster[abilityLevel] = caster
            if (durationTimer == null) then
                set durationTimer = CreateTimerWJ()
                set d.durationTimer[abilityLevel] = durationTimer
                call AttachInteger(durationTimer, NaturalEmbrace_SCOPE_ID, d)
            endif
            set oldAbilityLevel = d.abilityLevel
            call DestroyEffectWJ( d.targetEffect )
        endif
        set d.targetEffect = AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, targetSelf, TARGET_EFFECT_ATTACHMENT_POINT )
        if ( isNew ) then
            call SetUnitScale(dummyUnit, DUMMY_SCALE, DUMMY_SCALE, DUMMY_SCALE)
            set dummyUnit = null
            call TimerStart(intervalTimer, INTERVAL[abilityLevel], true, function Interval)
            set intervalTimer = null
            call TimerStart(updateTimer, UPDATE_TIME, true, function Move)
            set updateTimer = null
        elseif (abilityLevel >= oldAbilityLevel) then
            set d.abilityLevel = abilityLevel
            call TimerStart(d.intervalTimer, INTERVAL[abilityLevel], true, function Interval)
            call TimerStart(d.updateTimer, UPDATE_TIME, true, function Move)
        endif
        if ( IsUnitType( targetSelf, UNIT_TYPE_HERO ) ) then
            set duration = HERO_DURATION[abilityLevel]
        else
            set duration = DURATION[abilityLevel]
        endif
        set targetSelf = null
        call TimerStart( durationTimer, duration, false, function EndingByTimer )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    public function Order takes Unit target returns string
        set TEMP_UNIT_SELF = target.self
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return ErrorStrings_ONLY_ORGANIC
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return ErrorStrings_NOT_STRUCTURE
        endif
        if ( IsUnitWard( target ) ) then
            return ErrorStrings_NOT_WARD
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( TARGET_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = LEVELS_AMOUNT
        set ABSORPTION_FACTOR[1] = 1.5
        set ABSORPTION_FACTOR[2] = 1.5
        set ABSORPTION_FACTOR[3] = 1.5
        set ABSORPTION_FACTOR[4] = 1.5
        set ABSORPTION_FACTOR[5] = 1.5
        set DAMAGE_PER_INTERVAL[1] = 300
        set DAMAGE_PER_INTERVAL[2] = 375
        set DAMAGE_PER_INTERVAL[3] = 450
        set DAMAGE_PER_INTERVAL[4] = 525
        set DAMAGE_PER_INTERVAL[5] = 600
        set DURATION[1] = 12
        set DURATION[2] = 14
        set DURATION[3] = 16
        set DURATION[4] = 18
        set DURATION[5] = 20
        set HERO_DAMAGE_PER_INTERVAL[1] = 150
        set HERO_DAMAGE_PER_INTERVAL[2] = 210
        set HERO_DAMAGE_PER_INTERVAL[3] = 270
        set HERO_DAMAGE_PER_INTERVAL[4] = 330
        set HERO_DAMAGE_PER_INTERVAL[5] = 390
        set HERO_DURATION[1] = 6
        set HERO_DURATION[2] = 8
        set HERO_DURATION[3] = 10
        set HERO_DURATION[4] = 12
        set HERO_DURATION[5] = 14
        set INTERVAL[1] = 0.5
        set INTERVAL[2] = 0.5
        set INTERVAL[3] = 0.5
        set INTERVAL[4] = 0.5
        set INTERVAL[5] = 0.5
        loop
            set WAVES_AMOUNT[iteration] = R2I(DURATION[iteration] / INTERVAL[iteration])
            set DAMAGE_PER_INTERVAL[iteration] = DAMAGE_PER_INTERVAL[iteration] / WAVES_AMOUNT[iteration]
            set HERO_WAVES_AMOUNT[iteration] = R2I(HERO_DURATION[iteration] / INTERVAL[iteration])
            set HERO_DAMAGE_PER_INTERVAL[iteration] = HERO_DAMAGE_PER_INTERVAL[iteration] / HERO_WAVES_AMOUNT[iteration]
            set iteration = iteration - 1
            exitwhen (iteration < 1)
        endloop
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_DISPEL", "UnitIsDispelled_EVENT_KEY_NEGATIVE", "0", "function Dispel_Event" )
        call InitEffectType( CASTER_EFFECT_PATH )
        call InitUnitType( DUMMY_UNIT_ID )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call InitEffectType( TARGET_EFFECT_PATH )
        call InitEffectType( TARGET_EFFECT2_PATH )
    endfunction
//! runtextmacro Endscope()