//TESH.scrollpos=0
//TESH.alwaysfold=0
scope CoinIsPickedUp
    globals
        public trigger DUMMY_TRIGGER

        public integer AMOUNT
    endglobals

    private function TriggerEvents takes player triggerPlayer, integer amount returns nothing
        call Infoboard_Additionboard_Additionboard_Coin(triggerPlayer, amount)
    endfunction

    private function Trig takes nothing returns nothing
        call TriggerEvents(TRIGGER_PLAYER, AMOUNT)
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope