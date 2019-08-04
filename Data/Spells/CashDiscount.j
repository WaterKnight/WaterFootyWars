//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("CashDiscount")
    globals
        private constant integer ORDER_ID = 852514//OrderId( "phaseshift" )
        public constant integer SPELL_ID = 'A03B'

        private constant real DURATION = 40.
        public constant integer GOLD_COST_PERCENT = 60
        public constant real GOLD_COST_FACTOR = GOLD_COST_PERCENT / 100.

        public boolean array ON
    endglobals

    private struct Data
        integer casterTeam
        timer durationTimer
    endstruct

    private function Ending takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, CashDiscount_SCOPE_ID)
        local integer casterTeam = d.casterTeam
        call d.destroy()
        call FlushAttachedInteger(durationTimer, CashDiscount_SCOPE_ID)
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        set ON[casterTeam] = false
        if ( GetPlayerTeam( GetLocalPlayer() ) == casterTeam ) then
            call DisplayTextTimedWJ( ColorStrings_YELLOW + "'Cash Discount' has expired." + ColorStrings_RESET, 10, GetLocalPlayer() )
        endif
    endfunction

    public function SpellEffect takes player casterOwner returns nothing
        local integer casterTeam = GetPlayerTeam( casterOwner )
        local integer count = Infoboard_COUNT
        local Data d
        local timer durationTimer
        local sound effectSound = CreateSoundFromType( CASH_DISCOUNT_SOUND_TYPE )
        if ( ON[casterTeam] == false ) then
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set ON[casterTeam] = true
            set d.casterTeam = casterTeam
            call AttachInteger( durationTimer, CashDiscount_SCOPE_ID, d )
        else
            set durationTimer = d.durationTimer
        endif
        if ( GetPlayerTeam( GetLocalPlayer() ) == casterTeam ) then
            call DisplayTextTimedWJ( ColorStrings_GREEN + "Someone of your team just activated 'Cash Discount'. All prices are lowered by " + I2S( GOLD_COST_PERCENT ) + " percent.\n(Start: " + GetTimeString( count ) + " End: " + GetTimeString( count + R2I( DURATION ) ) + ")" + ColorStrings_RESET, 10, GetLocalPlayer() )
            call PingMasterWizard( casterTeam )
        endif
        if (GetPlayerTeam(GetLocalPlayer()) != casterTeam) then
            call SetSoundVolume(effectSound, 0)
        endif
        call StartSound( effectSound )
        call KillSound(effectSound, true)
        set effectSound = null
        call TimerStart( durationTimer, DURATION, false, function Ending )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER.owner )
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = GetTeams() - 1
        loop
            set ON[iteration] = false
            set iteration = iteration - 1
            exitwhen (iteration < 0)
        endloop
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()