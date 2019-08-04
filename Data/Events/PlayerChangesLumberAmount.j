//TESH.scrollpos=6
//TESH.alwaysfold=0
scope PlayerChangesLumberAmount
    globals
        public constant integer AMOUNT = 99999
        private trigger DUMMY_TRIGGER

        public boolean IGNORE_NEXT = false
    endglobals

    private function Trig takes nothing returns nothing
        local integer iteration = 0
        local player specificPlayer
        local player triggerPlayer = GetTriggerPlayer()
        if ( IGNORE_NEXT ) then
            set IGNORE_NEXT = false
        else
            if ( GetPlayerState( triggerPlayer, PLAYER_STATE_RESOURCE_LUMBER ) > AMOUNT ) then
                set iteration = MAX_PLAYER_INDEX
                loop
                    set specificPlayer = PlayerWJ(iteration)
                    if (IsPlayerDead(specificPlayer) == false) then
                        exitwhen ( ( GetPlayerState( specificPlayer, PLAYER_STATE_RESOURCE_LUMBER ) != AMOUNT ) and ( specificPlayer != triggerPlayer ) )
                    endif
                    set iteration = iteration - 1
                    exitwhen ( iteration < 0 )
                endloop
                set specificPlayer = null
                if ( iteration < 0 ) then
                    call AddPlayerState( triggerPlayer, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState( triggerPlayer, PLAYER_STATE_RESOURCE_LUMBER ) - AMOUNT )
                endif
            endif
        endif
        call SetPlayerState( triggerPlayer, PLAYER_STATE_RESOURCE_LUMBER, AMOUNT )
        set triggerPlayer = null
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = MAX_PLAYER_INDEX
        local player specificPlayer
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
        loop
            set specificPlayer = PlayerWJ(iteration)
            call SetPlayerState(specificPlayer, PLAYER_STATE_RESOURCE_LUMBER, AMOUNT)
            call TriggerRegisterPlayerStateEvent( DUMMY_TRIGGER, specificPlayer, PLAYER_STATE_RESOURCE_LUMBER, NOT_EQUAL, AMOUNT )
            set iteration = iteration - 1
            exitwhen ( iteration < 0 )
        endloop
        set specificPlayer = null
    endfunction
endscope