//TESH.scrollpos=222
//TESH.alwaysfold=0
//! runtextmacro Scope("LifeDrain")
    globals
        private constant integer ORDER_ID = 852487//OrderId( "drain" )
        public constant integer SPELL_ID = 'A00Z'

        private real array ABSORPTION_FACTOR
        private constant string CASTER_EFFECT_PATH = "Abilities\\Spells\\Other\\Drain\\DrainCaster.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "origin"
        private real array DRAINED_LIFE_PER_INTERVAL
        private real array DRAINED_LIFE_PER_INTERVAL_PER_STRENGTH_POINT
        private real array DURATION
        private constant string EFFECT_LIGHTNING_PATH = "DRAL"
        private constant real INTERVAL = 0.5
        private constant integer LEVELS_AMOUNT = 5
        private real array MAX_RANGE
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Other\\Drain\\DrainTarget.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        private constant real UPDATE_TIME = 0.1
        private real array WAVES_AMOUNT
    endglobals

    private struct Data
        integer abilityLevel
        Unit caster
        effect casterEffect
        timer distanceTimer
        real drainedLifePerInterval
        timer durationTimer
        lightning effectLightning
        sound effectSound
        timer intervalTimer
        Unit target
        effect targetEffect
    endstruct

    private function Ending takes Unit caster, Data d returns nothing
        local effect casterEffect = d.casterEffect
        local timer distanceTimer = d.distanceTimer
        local timer durationTimer = d.durationTimer
        local lightning effectLightning = d.effectLightning
        local sound effectSound = d.effectSound
        local timer intervalTimer = d.intervalTimer
        local Unit target = d.target
        local effect targetEffect = d.targetEffect
        local integer targetId = target.id
        call d.destroy()
        call FlushAttachedIntegerById(caster.id, LifeDrain_SCOPE_ID_BASIC)
        call DestroyEffectWJ( casterEffect )
        set casterEffect = null
        call FlushAttachedInteger(distanceTimer, LifeDrain_SCOPE_ID)
        call DestroyTimerWJ( distanceTimer )
        set distanceTimer = null
        call FlushAttachedInteger(durationTimer, LifeDrain_SCOPE_ID)
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call DestroyLightningWJ( effectLightning )
        set effectLightning = null
        call FlushAttachedInteger(intervalTimer, LifeDrain_SCOPE_ID)
        call DestroyTimerWJ( intervalTimer )
        set intervalTimer = null
        call KillSound( effectSound, false )
        set effectSound = null
        call RemoveIntegerFromTableById( targetId, LifeDrain_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, LifeDrain_SCOPE_ID ) == TABLE_EMPTY ) then
            //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        endif
        call DestroyEffectWJ( targetEffect )
        set targetEffect = null
    endfunction

    public function Death takes Unit target returns nothing
        local Data d
        local integer targetId = target.id
        local integer iteration = CountIntegersInTableById( targetId, LifeDrain_SCOPE_ID )
        if (iteration > TABLE_EMPTY) then
            loop
                set d = GetIntegerFromTableById( targetId, LifeDrain_SCOPE_ID, iteration )
                call IssueImmediateOrderById( d.caster.self, STOP_ORDER_ID )
                set iteration = iteration - 1
                exitwhen ( iteration < TABLE_STARTED )
            endloop
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    public function EndCast takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, LifeDrain_SCOPE_ID_BASIC)
        if ( d != NULL ) then
            call Ending( caster, d )
        endif
    endfunction

    private function EndCast_Event takes nothing returns nothing
        call EndCast( CASTER )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, LifeDrain_SCOPE_ID)
        set durationTimer = null
        call IssueImmediateOrderById( d.caster.self, STOP_ORDER_ID )
    endfunction

    private function Drain takes nothing returns nothing
        local Unit caster
        local real drainedLife
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, LifeDrain_SCOPE_ID)
        local integer abilityLevel = d.abilityLevel
        local Unit target = d.target
        local unit targetSelf = target.self
        set intervalTimer = null
        if ( IsUnitIllusionWJ( target ) ) then
            call KillUnit( targetSelf )
        else
            set caster = d.caster
            set drainedLife = d.drainedLifePerInterval
            call HealUnitBySpell( caster, Min( GetUnitState( targetSelf, UNIT_STATE_LIFE ), drainedLife ) * ABSORPTION_FACTOR[abilityLevel] )
            call UnitDamageUnitBySpell( caster, target, drainedLife )
        endif
        set targetSelf = null
    endfunction

    private function CheckDistance takes nothing returns nothing
        local real casterImpactZ
        local timer distanceTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(distanceTimer, LifeDrain_SCOPE_ID)
        local integer abilityLevel = d.abilityLevel
        local Unit caster = d.caster
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local lightning effectLightning = d.effectLightning
        local Unit target = d.target
        local unit targetSelf = target.self
        local real targetX = GetUnitX( targetSelf )
        local real targetY = GetUnitY( targetSelf )
        set distanceTimer = null
        if ( DistanceByCoordinates( casterX, casterY, targetX, targetY ) > MAX_RANGE[abilityLevel] ) then
            call IssueImmediateOrderById( casterSelf, STOP_ORDER_ID )
        else
            call MoveLightningEx( effectLightning, true, casterX, casterY, GetUnitZ( casterSelf, casterX, casterY ) + GetUnitOutpactZ(caster), targetX, targetY, GetUnitZ( targetSelf, targetX, targetY ) + GetUnitImpactZ(target) )
        endif
        set casterSelf = null
        set effectLightning = null
        set targetSelf = null
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local unit casterSelf = caster.self
        local integer abilityLevel = GetUnitAbilityLevel( casterSelf, SPELL_ID )
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local Data d = Data.create()
        local timer distanceTimer = CreateTimerWJ()
        local timer durationTimer = CreateTimerWJ()
        local sound effectSound = CreateSoundFromType( LIFE_DRAIN_LOOP_SOUND_TYPE )
        local timer intervalTimer = CreateTimerWJ()
        local integer targetId = target.id
        local unit targetSelf = target.self
        local real targetX = GetUnitX( targetSelf )
        local real targetY = GetUnitY( targetSelf )
        set d.abilityLevel = abilityLevel
        set d.caster = caster
        set d.casterEffect = AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, casterSelf, CASTER_EFFECT_ATTACHMENT_POINT )
        set d.distanceTimer = distanceTimer
        set d.drainedLifePerInterval = DRAINED_LIFE_PER_INTERVAL[abilityLevel] + GetHeroStrengthTotal( caster ) * DRAINED_LIFE_PER_INTERVAL_PER_STRENGTH_POINT[abilityLevel]
        set d.durationTimer = durationTimer
        set d.effectLightning = AddLightningWJ( EFFECT_LIGHTNING_PATH, casterX, casterY, GetUnitZ( casterSelf, casterX, casterY ) + GetUnitOutpactZ(caster), targetX, targetY, GetUnitZ( targetSelf, targetX, targetY ) + GetUnitImpactZ(target) )
        set casterSelf = null
        set d.effectSound = effectSound
        set d.intervalTimer = intervalTimer
        set d.target = target
        set d.targetEffect = AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, targetSelf, TARGET_EFFECT_ATTACHMENT_POINT )
        call AttachIntegerById( caster.id, LifeDrain_SCOPE_ID_BASIC, d )
        call AttachInteger( distanceTimer, LifeDrain_SCOPE_ID, d )
        call AttachInteger( durationTimer, LifeDrain_SCOPE_ID, d )
        call AttachInteger( intervalTimer, LifeDrain_SCOPE_ID, d )
        call AddIntegerToTableById( targetId, LifeDrain_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, LifeDrain_SCOPE_ID ) == TABLE_STARTED ) then
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
        endif
        call AttachSoundToUnit( effectSound, targetSelf )
        set targetSelf = null
        call StartSound( effectSound )
        set effectSound = null
        call TimerStart( distanceTimer, UPDATE_TIME, true, function CheckDistance )
        set distanceTimer = null
        call TimerStart( intervalTimer, INTERVAL, true, function Drain )
        set intervalTimer = null
        call TimerStart( durationTimer, DURATION[abilityLevel], false, function EndingByTimer )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    public function Order takes Unit target returns string
        if ( GetUnitMagicImmunity( target ) > 0 ) then
            return ErrorStrings_TARGET_IS_MAGIC_IMMUNE
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
        set ABSORPTION_FACTOR[1] = 1.3
        set ABSORPTION_FACTOR[2] = 1.3
        set ABSORPTION_FACTOR[3] = 1.3
        set ABSORPTION_FACTOR[4] = 1.3
        set ABSORPTION_FACTOR[5] = 1.3
        set DRAINED_LIFE_PER_INTERVAL[1] = 210
        set DRAINED_LIFE_PER_INTERVAL[2] = 325
        set DRAINED_LIFE_PER_INTERVAL[3] = 440
        set DRAINED_LIFE_PER_INTERVAL[4] = 555
        set DRAINED_LIFE_PER_INTERVAL[5] = 670
        set DRAINED_LIFE_PER_INTERVAL_PER_STRENGTH_POINT[1] = 4.25
        set DRAINED_LIFE_PER_INTERVAL_PER_STRENGTH_POINT[2] = 4.25
        set DRAINED_LIFE_PER_INTERVAL_PER_STRENGTH_POINT[3] = 4.25
        set DRAINED_LIFE_PER_INTERVAL_PER_STRENGTH_POINT[4] = 4.25
        set DRAINED_LIFE_PER_INTERVAL_PER_STRENGTH_POINT[5] = 4.25
        set DURATION[1] = 6
        set DURATION[2] = 6
        set DURATION[3] = 5.5
        set DURATION[4] = 5.5
        set DURATION[5] = 5
        loop
            set WAVES_AMOUNT[iteration] = R2I( DURATION[iteration] / INTERVAL )
            set DRAINED_LIFE_PER_INTERVAL[iteration] = DRAINED_LIFE_PER_INTERVAL[iteration] / WAVES_AMOUNT[iteration]
            set DRAINED_LIFE_PER_INTERVAL_PER_STRENGTH_POINT[iteration] = DRAINED_LIFE_PER_INTERVAL_PER_STRENGTH_POINT[iteration] / WAVES_AMOUNT[iteration]
            set iteration = iteration - 1
            exitwhen (iteration < 1)
        endloop
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        set MAX_RANGE[1] = 1000
        set MAX_RANGE[2] = 1000
        set MAX_RANGE[3] = 1000
        set MAX_RANGE[4] = 1000
        set MAX_RANGE[5] = 1000
        call InitEffectType( CASTER_EFFECT_PATH )
        call InitEffectType( TARGET_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ENDCAST", "SPELL_ID", "UnitFinishesCasting_EVENT_KEY", "0", "function EndCast_Event" )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()