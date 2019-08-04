//TESH.scrollpos=120
//TESH.alwaysfold=0
//! runtextmacro Scope("LayEgg")
    globals
        public constant integer SPELL_ID = 'A04B'

        private constant real INTERVAL = 5.
    endglobals

    private struct Data
        Unit caster
        timer intervalTimer
    endstruct

    public function Death takes Unit caster returns nothing
        local integer casterId = caster.id
        local Data d = GetAttachedIntegerById(casterId, LayEgg_SCOPE_ID)
        local timer intervalTimer
        if ( d != NULL ) then
            set intervalTimer = d.intervalTimer
            call d.destroy()
            call FlushAttachedIntegerById( casterId, LayEgg_SCOPE_ID )
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
            call FlushAttachedInteger( intervalTimer, LayEgg_SCOPE_ID )
            call DestroyTimerWJ( intervalTimer )
            set intervalTimer = null
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    //! runtextmacro Scope("Egg")
        globals
            private constant real Egg_DURATION = 30.
            private constant real Egg_RELEASE_TIME = 5.
            private constant integer Egg_SPAWNS_AMOUNT = 2
            private integer array Egg_SPAWN_UNIT_IDS
        endglobals

        private struct Egg_Data
            Unit egg
            timer releaseTimer
        endstruct

        private function Egg_Ending takes Egg_Data d, Unit egg returns nothing
            local integer eggId = egg.id
            local timer releaseTimer = d.releaseTimer
            call FlushAttachedIntegerById( eggId, Egg_SCOPE_ID )
            //! runtextmacro RemoveEventById( "eggId", "Egg_EVENT_DEATH" )
            call FlushAttachedInteger( releaseTimer, Egg_SCOPE_ID )
            call DestroyTimerWJ( releaseTimer )
            set releaseTimer = null
        endfunction

        public function Egg_Death takes Unit egg returns nothing
            local Egg_Data d = GetAttachedIntegerById( egg.id, Egg_SCOPE_ID )
            if ( d != NULL ) then
                call Egg_Ending( d, egg )
            endif
        endfunction

        private function Egg_Death_Event takes nothing returns nothing
            call Egg_Death( DYING_UNIT )
        endfunction

        private function Egg_Release takes nothing returns nothing
            local integer iteration = Egg_SPAWNS_AMOUNT
            local timer releaseTimer = GetExpiredTimer()
            local Egg_Data d = GetAttachedInteger(releaseTimer, Egg_SCOPE_ID)
            local Unit egg = d.egg
            local player eggOwner = egg.owner
            local unit eggSelf = egg.self
            local real eggAngle = GetUnitFacingWJ( eggSelf )
            local real eggX = GetUnitX( eggSelf )
            local real eggY = GetUnitY( eggSelf )
            set releaseTimer = null
            call KillUnit( eggSelf )
            set eggSelf = null
            loop
                call UnitApplyTimedLifeWJ( CreateUnitEx( eggOwner, SPIDERLY_UNIT_ID, eggX, eggY, eggAngle ).self, Egg_DURATION )
                set iteration = iteration - 1
                exitwhen ( iteration < 1 )
            endloop
            set eggOwner = null
        endfunction

        public function Egg_Start takes Unit caster returns nothing
            local unit casterSelf = caster.self
            local real casterX = GetUnitX( casterSelf )
            local real casterY = GetUnitY( casterSelf )
            local Egg_Data d = Egg_Data.create()
            local Unit egg = CreateUnitEx( caster.owner, Egg_SPAWN_UNIT_IDS[GetRandomInt(0, 1)], casterX, casterY, GetRandomReal( 0, 2 * PI ) )
            local integer eggId = egg.id
            local timer releaseTimer = CreateTimerWJ()
            set casterSelf = null
            set d.egg = egg
            set d.releaseTimer = releaseTimer
            call AttachIntegerById( eggId, Egg_SCOPE_ID, d )
            //! runtextmacro AddEventById( "eggId", "Egg_EVENT_DEATH" )
            call AttachInteger( releaseTimer, Egg_SCOPE_ID, d )
            call TimerStart(releaseTimer, Egg_RELEASE_TIME, false, function Egg_Release )
            set releaseTimer = null
        endfunction

        public function Egg_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "Egg_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Egg_Death_Event" )
            set Egg_SPAWN_UNIT_IDS[0] = SPIDERLY_EGG_UNIT_ID
            set Egg_SPAWN_UNIT_IDS[1] = SPIDERLY_EGG2_UNIT_ID
        endfunction
    //! runtextmacro Endscope()

    private function Interval takes nothing returns nothing
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, LayEgg_SCOPE_ID)
        call Egg_Egg_Start(d.caster)
        set intervalTimer = null
    endfunction

    public function Learn takes Unit caster returns nothing
        local integer casterId = caster.id
        local Data d = Data.create()
        local timer intervalTimer = CreateTimerWJ()
        set d.caster = caster
        set d.intervalTimer = intervalTimer
        call AttachIntegerById( casterId, LayEgg_SCOPE_ID, d )
        //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
        call AttachInteger( intervalTimer, LayEgg_SCOPE_ID, d )
        call TimerStart( intervalTimer, INTERVAL, true, function Interval )
        set intervalTimer = null
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
        call Egg_Egg_Init()
    endfunction
//! runtextmacro Endscope()