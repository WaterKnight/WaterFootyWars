//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("SpecialEffects")
    public function Chat takes string chatMessage, player whichPlayer returns nothing
        set chatMessage = StringCase( chatMessage, false )
        if ( chatMessage == "-sfx" ) then
            if ( IsPlayerInForce( whichPlayer, Effect_SHIP ) ) then
                call DisplayTextTimedWJ("|cff00ff00Effect creation is enabled again.|r", HINT_TEXT_DURATION, whichPlayer)
                call ForceRemovePlayer( Effect_SHIP, whichPlayer )
            else
                call DisplayTextTimedWJ("|cffff0000No more coded effects are created for you.|r", HINT_TEXT_DURATION, whichPlayer)
                call ForceAddPlayer( Effect_SHIP, whichPlayer )
            endif
        endif
    endfunction
//! runtextmacro Endscope()