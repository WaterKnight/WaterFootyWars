//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("ExtraGold")
    globals
        public constant integer BONUS_GOLD = 13
        public constant real INTERVAL = 6.
    endglobals

    private function GiveGold takes nothing returns nothing
        local integer iteration = MAX_PLAYER_INDEX
        local player specificPlayer
        loop
            set specificPlayer = PlayerWJ( iteration )
            if (IsPlayerDead(specificPlayer) == false) then
                call AddPlayerState( specificPlayer, PLAYER_STATE_RESOURCE_GOLD, BONUS_GOLD + GoldTower_ExtraGold(GetPlayerTeam( specificPlayer )) )
            endif
            set iteration = iteration - 1
            exitwhen ( iteration < 0 )
        endloop
        set specificPlayer = null
    endfunction

    public function Start takes nothing returns nothing
        call TimerStart( CreateTimerWJ(), INTERVAL, true, function GiveGold )
    endfunction
//! runtextmacro Endscope()