//TESH.scrollpos=0
//TESH.alwaysfold=0
scope PlayerClicksDialog
    globals
        public trigger DUMMY_TRIGGER
    endglobals

    private function TriggerEvents_Static takes button clickedButton, dialog clickedDialog, player triggerPlayer returns nothing
        call CameraDialog_DialogClick( clickedButton, clickedDialog, triggerPlayer )
    endfunction

    private function Trig takes nothing returns nothing
        local button clickedButton = GetClickedButton()
        local dialog clickedDialog = GetClickedDialog()
        local player triggerPlayer = GetTriggerPlayer()
        call DisplayDialogWJ( clickedDialog, triggerPlayer, false )

        call TriggerEvents_Static(clickedButton, clickedDialog, triggerPlayer)

        set clickedButton = null
        set clickedDialog = null
        set triggerPlayer = null
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope