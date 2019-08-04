//TESH.scrollpos=0
//TESH.alwaysfold=0
scope PlayersDialogIsKilled
    globals
        player TRIGGER_PLAYER
    endglobals

    private function TriggerEvents_Static takes dialog triggerDialog, player triggerPlayer returns nothing
        call CameraDialog_Death( triggerDialog, triggerPlayer )
    endfunction

    private function Trig takes nothing returns nothing
        local player triggerPlayer = TRIGGER_PLAYER
        local dialog triggerDialog = GetDisplayedDialog( triggerPlayer )
        if ( triggerDialog != null ) then
            call TriggerEvents_Static(triggerDialog, triggerPlayer)

            set triggerDialog = null
        endif
        set triggerPlayer = null
    endfunction
endscope