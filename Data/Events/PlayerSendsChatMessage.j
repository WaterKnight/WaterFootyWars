//TESH.scrollpos=0
//TESH.alwaysfold=0
scope PlayerSendsChatMessage
    globals
        private trigger DUMMY_TRIGGER
    endglobals

    private function TriggerEvents_Static takes string chatMessage, player triggerPlayer returns nothing
        call Clear_Chat( chatMessage, triggerPlayer )
        call CameraDialog_Chat( chatMessage, triggerPlayer )
        call CameraSmooth_Chat( chatMessage, triggerPlayer )
        //call DisplayWeather_Chat( chatMessage, triggerPlayer )
        call Hints_Chat( chatMessage, triggerPlayer )
        call Music_Chat( chatMessage, triggerPlayer )
        //call SpawnInformation_Chat( chatMessage, triggerPlayer )
        call SpecialEffects_Chat( chatMessage, triggerPlayer )
        call System_Chat( chatMessage, triggerPlayer )
    endfunction

    private function Trig takes nothing returns nothing
        local string chatMessage = GetEventPlayerChatString()
        local player triggerPlayer = GetTriggerPlayer()

        call TriggerEvents_Static(chatMessage, triggerPlayer)

        set triggerPlayer = null
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = MAX_PLAYER_INDEX
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
        loop
            call TriggerRegisterPlayerChatEvent( DUMMY_TRIGGER, PlayerWJ( iteration ), null, false )
            set iteration = iteration - 1
            exitwhen ( iteration < 0 )
        endloop
    endfunction
endscope