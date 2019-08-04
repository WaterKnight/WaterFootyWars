//TESH.scrollpos=133
//TESH.alwaysfold=0
//! runtextmacro Scope("WonderSeeds")
    globals
        private constant integer ORDER_ID = 852176//OrderId( "forceofnature" )
        public constant integer SPELL_ID = 'A01Q'

        private real array DURATION
        private real array INTERVAL
        private constant integer LEVELS_AMOUNT = 5
        private integer array SUMMONS_AMOUNT
    endglobals

    private struct Data
        integer abilityLevel
        Unit caster
        timer durationTimer
        timer intervalTimer
        real targetX
        real targetY
    endstruct

    private function Ending takes Unit caster, Data d returns nothing
        local timer durationTimer = d.durationTimer
        local timer intervalTimer = d.intervalTimer
        call FlushAttachedIntegerById( caster.id, WonderSeeds_SCOPE_ID )
        call FlushAttachedInteger( durationTimer, WonderSeeds_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call FlushAttachedInteger( intervalTimer, WonderSeeds_SCOPE_ID )
        call DestroyTimerWJ( intervalTimer )
        set intervalTimer = null
    endfunction

    public function EndCast takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById( caster.id, WonderSeeds_SCOPE_ID )
        if ( d != NULL ) then
            call Ending( caster, d )
        endif
    endfunction

    private function EndCast_Event takes nothing returns nothing
        call EndCast( CASTER )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, WonderSeeds_SCOPE_ID)
        set durationTimer = null
        call IssueImmediateOrderById( d.caster.self, STOP_ORDER_ID )
    endfunction

    //! runtextmacro Scope("Release")
        globals
            private real array Release_DURATION
            private constant real Release_RELEASE_TIME = 1.2
        endglobals

        private struct Release_Data
            integer abilityLevel
            Unit spawn
        endstruct

        private function Release_Ending takes nothing returns nothing
            local timer releaseTimer = GetExpiredTimer()
            local Release_Data d = GetAttachedInteger(releaseTimer, Release_SCOPE_ID)
            local integer abilityLevel = d.abilityLevel
            local Unit spawn = d.spawn
            local unit spawnSelf = spawn.self
            call d.destroy()
            call FlushAttachedInteger( releaseTimer, Release_SCOPE_ID )
            call DestroyTimerWJ( releaseTimer )
            set releaseTimer = null
            call SetUnitBlendTime( spawnSelf, 0.15 )
            call SetUnitAnimationByIndex( spawnSelf, 1 )
            call PauseUnit( spawnSelf, false )
            call SetUnitInvulnerable( spawnSelf, false )
            call UnitApplyTimedLifeWJ( spawnSelf, Release_DURATION[abilityLevel] )
            set spawnSelf = null
        endfunction

        public function Release_Start takes integer abilityLevel, Unit caster, real x, real y returns nothing
            local Release_Data d = Release_Data.create()
            local timer releaseTimer = CreateTimerWJ()
            local Unit spawn = CreateUnitEx( caster.owner, TREANT_UNIT_ID, x, y, STANDARD_ANGLE )
            local unit spawnSelf = spawn.self
            set d.abilityLevel = abilityLevel
            set d.spawn = spawn
            call AttachInteger(releaseTimer, Release_SCOPE_ID, d)
            call SetUnitBlendTime( spawnSelf, 0 )
            call SetUnitAnimationByIndex( spawnSelf, 7 )
            call PauseUnit( spawnSelf, true )
            call SetUnitInvulnerable( spawnSelf, true )
            set spawnSelf = null
            call TimerStart( releaseTimer, Release_RELEASE_TIME, false, function Release_Ending )
            set releaseTimer = null
        endfunction

        public function Release_Init takes nothing returns nothing
            set Release_DURATION[1] = 30
            set Release_DURATION[2] = 30
            set Release_DURATION[3] = 30
            set Release_DURATION[4] = 30
            set Release_DURATION[5] = 30
        endfunction
    //! runtextmacro Endscope()

    private function Interval takes nothing returns nothing
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, WonderSeeds_SCOPE_ID)
        set intervalTimer = null
        call Release_Release_Start(d.abilityLevel, d.caster, d.targetX, d.targetY)
    endfunction

    public function BeginCast takes Unit caster, real targetX, real targetY returns nothing
        local integer abilityLevel = GetUnitAbilityLevel( caster.self, SPELL_ID )
        local Data d = Data.create()
        local timer durationTimer = CreateTimerWJ()
        local timer intervalTimer = CreateTimerWJ()
        set d.abilityLevel = abilityLevel
        set d.caster = caster
        set d.durationTimer = durationTimer
        set d.intervalTimer = intervalTimer
        set d.targetX = targetX
        set d.targetY = targetY
        call AttachIntegerById( caster.id, WonderSeeds_SCOPE_ID, d )
        call AttachInteger( durationTimer, WonderSeeds_SCOPE_ID, d )
        call AttachInteger( intervalTimer, WonderSeeds_SCOPE_ID, d )
        call TimerStart( intervalTimer, INTERVAL[abilityLevel], true, function Interval )
        set intervalTimer = null
        call TimerStart( durationTimer, DURATION[abilityLevel], false, function EndingByTimer )
        set durationTimer = null
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = LEVELS_AMOUNT
        set INTERVAL[1] = 0.75
        set INTERVAL[2] = 0.75
        set INTERVAL[3] = 0.75
        set INTERVAL[4] = 0.75
        set INTERVAL[5] = 0.75
        set SUMMONS_AMOUNT[1] = 5
        set SUMMONS_AMOUNT[2] = 8
        set SUMMONS_AMOUNT[3] = 11
        set SUMMONS_AMOUNT[4] = 14
        set SUMMONS_AMOUNT[5] = 17
        loop
            set DURATION[iteration] = SUMMONS_AMOUNT[iteration] * INTERVAL[iteration]
            set iteration = iteration - 1
            exitwhen (iteration < 0)
        endloop
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ENDCAST", "SPELL_ID", "UnitFinishesCasting_EVENT_KEY", "0", "function EndCast_Event" )
        call Release_Release_Init()
    endfunction
//! runtextmacro Endscope()