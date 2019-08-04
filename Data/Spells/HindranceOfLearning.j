//TESH.scrollpos=36
//TESH.alwaysfold=0
//! runtextmacro Scope("HindranceOfLearning")
    globals
        private constant integer ORDER_ID = 852159//OrderId( "rechargeoff" )
        public constant integer SPELL_ID = 'A02I'

        private constant real DURATION = 30.
        private timer DURATION_TIMER

        private integer CASTER_TEAM
    endglobals

    private function Ending takes nothing returns nothing
        local integer casterTeam = CASTER_TEAM
        local timer durationTimer = GetExpiredTimer()
        local integer iteration = GetTeams() - 1
        set Experience_DISABLED[casterTeam] = false
        loop
            exitwhen ( iteration < 0 )
            if (iteration != casterTeam) then
                set Experience_DISABLED[casterTeam] = false
            endif
            call UnitAddAbility( MASTER_WIZARDS[iteration].self, SPELL_ID )
            set iteration = iteration - 1
        endloop
        call DisplayTextTimedWJ( "'Hindrance of Learning' has vanished: Kills grant experience again.", 10, GetLocalPlayer() )
    endfunction

    public function SpellEffect takes player casterOwner returns nothing
        local integer casterTeam = GetPlayerTeam( casterOwner )
        local integer count = Infoboard_COUNT
        local timer durationTimer = CreateTimerWJ()
        local integer iteration = GetTeams() - 1
        loop
            exitwhen ( iteration < 0 )
            if (iteration != casterTeam) then
                set Experience_DISABLED[casterTeam] = true
            endif
            call UnitRemoveAbility( MASTER_WIZARDS[iteration].self, SPELL_ID )
            set iteration = iteration - 1
        endloop
        set CASTER_TEAM = casterTeam
        call DisplayTextTimedWJ( ColorStrings_RED + "Go and stand in the hall: " + ColorStrings_GOLD + "Team" + I2S( casterTeam + 1 ) + ColorStrings_RESET + " has abrogated the experience gaining via kills for " + I2S( R2I( DURATION ) ) + " seconds.\n(Start: " + GetTimeString( count ) + " End: " + GetTimeString( count + R2I( DURATION ) ) + ")" + ColorStrings_RESET, 10, GetLocalPlayer() )
        call PingMasterWizard( casterTeam )
        call PlaySoundFromType( HINDRANCE_OF_LEARNING_SOUND_TYPE )
        call TimerStart( DURATION_TIMER, DURATION, false, function Ending )
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER.owner )
    endfunction

    public function Init takes nothing returns nothing
        set DURATION_TIMER = CreateTimerWJ()
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()