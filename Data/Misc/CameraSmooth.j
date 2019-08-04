//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("CameraSmooth")
    public function Chat takes string chatMessage, player whichPlayer returns nothing
        set chatMessage = StringCase( chatMessage, false )
        if ( SubString( chatMessage, 0, 4 ) == "-cs " ) then
            call DisplayTextTimedWJ("|cff00ff00Camera smoothing factor successfully set.|r", HINT_TEXT_DURATION, whichPlayer)
            call SetCameraSmoothingFactor( GetLocalPlayer(), S2R( SubString( chatMessage, 4, StringLength( chatMessage ) ) ) )
        endif
    endfunction
//! runtextmacro Endscope()