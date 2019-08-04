//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("Clear")
    public function Chat takes string chatMessage, player whichPlayer returns nothing
        set chatMessage = StringCase( chatMessage, false )
        if ( SubString( chatMessage, 0, 6 ) == "-clear" ) then
            call ClearTextMessagesWJ(whichPlayer)
        endif
    endfunction
//! runtextmacro Endscope()