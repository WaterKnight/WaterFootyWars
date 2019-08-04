//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("CameraDialog")
    globals
        private constant real FADE_TIME = 0.75
        private constant real INTERVAL = 200.
        private constant real LOWER_CAP = 1300.
        private constant real TEXT_TIME = 2.
        private constant real UPPER_CAP = 2200.
    endglobals

    private struct Data
        real currentDistance
        dialog dummyDialog
        timer fadeTimer
        player whichPlayer
    endstruct

    private function Ending takes Data d, dialog dummyDialog, player whichPlayer returns nothing
        call d.destroy()
        call FlushAttachedInteger( dummyDialog, CameraDialog_SCOPE_ID )
        call DestroyDialogWJ( dummyDialog )
        call FlushAttachedInteger( whichPlayer, CameraDialog_SCOPE_ID )
    endfunction

    public function Death takes dialog dyingDialog, player whichPlayer returns nothing
        local Data d = GetAttachedInteger( dyingDialog, CameraDialog_SCOPE_ID )
        if ( d != NULL ) then
            call Ending( d, dyingDialog, whichPlayer )
        endif
    endfunction

    private function ShowDialog takes Data d, player whichPlayer returns nothing
        local real currentDistance = d.currentDistance
        local dialog dummyDialog = d.dummyDialog
        call ClearDialog( dummyDialog )
        if ( currentDistance > LOWER_CAP ) then
            call AddDialogButtonWJ( dummyDialog, "Zoom in", 0 )
        endif
        if ( currentDistance < UPPER_CAP ) then
            call AddDialogButtonWJ( dummyDialog, "Zoom out", 0 )
        endif
        call DisplayTextTimedWJ( ColorStrings_GOLD + "Current Distance: " + R2S(currentDistance) + ColorStrings_RESET, TEXT_TIME, whichPlayer )
        call AddDialogButtonWJ( dummyDialog, "Ready", 0 )
        call SetCameraFieldEx( CAMERA_FIELD_TARGET_DISTANCE, currentDistance, whichPlayer )
        call DisplayDialogWJ( dummyDialog, whichPlayer, true )
        set dummyDialog = null
    endfunction

    private function ShowDialogByTimer takes nothing returns nothing
        local timer fadeTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(fadeTimer, CameraDialog_SCOPE_ID)
        local player whichPlayer = d.whichPlayer
        call FlushAttachedInteger( fadeTimer, CameraDialog_SCOPE_ID )
        call DestroyTimerWJ( fadeTimer )
        set fadeTimer = null
        call ShowDialog( d, whichPlayer )
        set whichPlayer = null
    endfunction

    public function DialogClick takes button clickedButton, dialog dummyDialog, player whichPlayer returns nothing
        local string caption
        local real currentDistance
        local Data d = GetAttachedInteger( dummyDialog, CameraDialog_SCOPE_ID )
        local timer fadeTimer
        if ( d != NULL ) then
            set caption = GetButtonCaption(clickedButton)
            if ( caption == "Ready" ) then
                call Ending( d, dummyDialog, whichPlayer )
            else
                set currentDistance = d.currentDistance
                set fadeTimer = CreateTimerWJ()
                if ( caption == "Zoom in" ) then
                    set currentDistance = Max( currentDistance - INTERVAL, LOWER_CAP )
                else
                    set currentDistance = Min( currentDistance + INTERVAL, UPPER_CAP )
                endif
                set d.currentDistance = currentDistance
                call AttachInteger( fadeTimer, CameraDialog_SCOPE_ID, d )
                call SetCameraFieldAcceleratedTimed( CAMERA_FIELD_TARGET_DISTANCE, currentDistance, 0, false, FADE_TIME, whichPlayer )
                call TimerStart( fadeTimer, FADE_TIME, false, function ShowDialogByTimer )
                set fadeTimer = null
            endif
        endif
    endfunction

    public function Chat takes string chatMessage, player whichPlayer returns nothing
        local Data d
        local dialog dummyDialog
        local real value
        local string valueString
        set chatMessage = StringCase( chatMessage, false )
        if ( SubString(chatMessage, 0, 2) == "-c" ) then
            set d = GetAttachedInteger( whichPlayer, CameraDialog_SCOPE_ID )
            if (d == NULL) then
                set valueString = SubString(chatMessage, 3, StringLength(chatMessage))
                if (valueString == null) then
                    if ( GetDisplayedDialog( whichPlayer ) == null ) then
                        set d = Data.create()
                        set dummyDialog = CreateDialogWJ()
                        set d.currentDistance = GetCameraFieldWJ(CAMERA_FIELD_TARGET_DISTANCE, whichPlayer)
                        set d.dummyDialog = dummyDialog
                        set d.whichPlayer = whichPlayer
                        call AttachInteger( dummyDialog, CameraDialog_SCOPE_ID, d )
                        set dummyDialog = null
                        call AttachInteger( whichPlayer, CameraDialog_SCOPE_ID, d )
                        call ShowDialog( d, whichPlayer )
                    endif
                elseif (SubString(chatMessage, 2, 3) == " ") then
                    set value = S2R(valueString)
                    if ( value == 0 ) then
                        call DisplayTextTimedWJ( ColorStrings_YELLOW + "Value invalid or zero", 0, whichPlayer)
                    elseif ( value < LOWER_CAP ) then
                        call DisplayTextTimedWJ( ColorStrings_YELLOW + "Value out of bounds, set to " + R2S(LOWER_CAP), 0, whichPlayer)
                        call SetCameraFieldValue( CAMERA_FIELD_TARGET_DISTANCE, value, whichPlayer )
                    elseif ( value > UPPER_CAP ) then
                        call DisplayTextTimedWJ( ColorStrings_YELLOW + "Value out of bounds, set to " + R2S(UPPER_CAP), 0, whichPlayer)
                        call SetCameraFieldValue( CAMERA_FIELD_TARGET_DISTANCE, value, whichPlayer )
                    else
                        call SetCameraFieldValue( CAMERA_FIELD_TARGET_DISTANCE, value, whichPlayer )
                    endif
                endif
            endif
        endif
    endfunction

    function RefreshCamera takes nothing returns nothing
        local integer iteration = MAX_PLAYER_INDEX
        local player specificPlayer
        loop
            set specificPlayer = PlayerWJ( iteration )
            if ( GetPlayerSlotState( specificPlayer ) == PLAYER_SLOT_STATE_PLAYING ) then
                call SetCameraFieldWJ( CAMERA_FIELD_TARGET_DISTANCE, GetCameraFieldWJ(CAMERA_FIELD_TARGET_DISTANCE, specificPlayer), 2, specificPlayer )
            endif
            set iteration = iteration - 1
            exitwhen ( iteration < 0 )
        endloop
        set specificPlayer = null
    endfunction

    public function Start takes nothing returns nothing
        call TimerStart( CreateTimerWJ(), 2, true, function RefreshCamera )
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = MAX_PLAYER_INDEX
        loop
            call SetCameraFieldEx(CAMERA_FIELD_TARGET_DISTANCE, STANDARD_CAMERA_TARGET_DISTANCE, PlayerWJ(iteration))
            set iteration = iteration - 1
            exitwhen ( iteration < 0 )
        endloop
    endfunction
//! runtextmacro Endscope()