//TESH.scrollpos=129
//TESH.alwaysfold=0
scope Players
    globals
        real array ALTAR_X
        real array ALTAR_Y
        real array START_POSITION_X
        real array START_POSITION_Y
    endglobals

    private function StartPosition takes integer reducedPlayerId, integer whichPlayerId, integer whichTeam returns nothing
        local integer startPosition = GetPlayerStartLocation(PlayerWJ(reducedPlayerId))
        local real differenceX = GetStartLocationX(startPosition) - CENTER_X
        local real differenceY = GetStartLocationY(startPosition) - CENTER_Y
        local real difference = SquareRoot(differenceX * differenceX + differenceY * differenceY)
        local real angle = Atan2( differenceY, differenceX ) + whichTeam * PI / 2
        set START_POSITION_X[whichPlayerId] = CENTER_X + difference * Cos(angle)
        set START_POSITION_Y[whichPlayerId] = CENTER_Y + difference * Sin(angle)
    endfunction

    private function Altar takes integer reducedPlayerId, integer whichPlayerId, integer whichTeam returns nothing
        local rect altarRect = ALTAR_RECTS[reducedPlayerId]
        local real differenceX = GetRectCenterX( altarRect ) - CENTER_X
        local real differenceY = GetRectCenterY( altarRect ) - CENTER_Y
        local real difference = SquareRoot(differenceX * differenceX + differenceY * differenceY)
        local real angle = Atan2( differenceY, differenceX ) + whichTeam * PI / 2
        set ALTAR_X[whichPlayerId] = CENTER_X + difference * Cos(angle)
        set ALTAR_Y[whichPlayerId] = CENTER_Y + difference * Sin(angle)
    endfunction

    public function Init takes nothing returns nothing
        local integer specificTeam = 3
        local player specificPlayer
        local integer specificPlayerId = 0
        local integer specificPlayerOffset
        call SetTeams(4)
        loop
            set specificPlayerOffset = MAX_PLAYERS_PER_TEAM - 1
            loop
                set specificPlayerId = specificTeam * MAX_PLAYERS_PER_TEAM + specificPlayerOffset
                set specificPlayer = PlayerWJ( specificPlayerId )
                call SetPlayerTeam(specificPlayer, specificTeam)
                call AddTeamPlayers(specificTeam, specificPlayer)
                if ( GetPlayerSlotState( specificPlayer ) == PLAYER_SLOT_STATE_PLAYING ) then
                    call Altar(specificPlayerOffset, specificPlayerId, specificTeam)
                    call StartPosition(specificPlayerOffset, specificPlayerId, specificTeam)
                endif
                set specificPlayerOffset = specificPlayerOffset - 1
                exitwhen ( specificPlayerOffset < 0 )
            endloop
            set specificTeam = specificTeam - 1
            exitwhen ( specificTeam < 0 )
        endloop
        set specificPlayerId = MAX_PLAYER_INDEX
        loop
            set specificPlayer = PlayerWJ( specificPlayerId )
            if ( GetPlayerSlotState( specificPlayer ) == PLAYER_SLOT_STATE_PLAYING ) then
                call AddTeamPlayersAlive(GetPlayerTeam(specificPlayer), specificPlayer)
                call SetPlayerDead(specificPlayer, false)
                call SetCameraBoundsToRectWJ(CAMERA_BOUNDS_RECT, specificPlayer)
            else
                call SetPlayerDead(specificPlayer, true)
            endif
            call SetPlayerHeroCount(specificPlayer, -1)
            call SetPlayerRaceWJ(specificPlayer, NULL)
            call SetPlayerAbilityAvailable( specificPlayer, ABILITY_STORAGE_SPELL_ID, false )
            call SetPlayerAbilityAvailable( specificPlayer, ABILITY_STORAGE2_SPELL_ID, false )
            call SetPlayerState( specificPlayer, PLAYER_STATE_GIVES_BOUNTY, 1 )
            set specificPlayerId = specificPlayerId - 1
            exitwhen ( specificPlayerId < 0 )
        endloop
        set specificPlayerId = MAX_NEUTRAL_PLAYER_INDEX
        loop
            set specificPlayer = PlayerWJ( specificPlayerId )
            call SetPlayerColorImage(specificPlayer, "ReplaceableTextures\\TeamColor\\TeamColor" + StringIf("0", specificPlayerId < 10) + I2S(specificPlayerId) + ".blp" )
            set specificPlayerId = specificPlayerId - 1
            exitwhen ( specificPlayerId < 0 )
        endloop
        call SetPlayerAbilityAvailable( NEUTRAL_PASSIVE_PLAYER, ABILITY_STORAGE_SPELL_ID, false )
        call SetPlayerAbilityAvailable( NEUTRAL_PASSIVE_PLAYER, ABILITY_STORAGE2_SPELL_ID, false )
        set specificPlayer = PlayerWJ( 0 )
        call SetPlayerColorString(specificPlayer, "|cffff0000")
        call SetPlayerColorRed(specificPlayer, 255)
        call SetPlayerColorGreen(specificPlayer, 0)
        call SetPlayerColorBlue(specificPlayer, 0)

        set specificPlayer = PlayerWJ( 1 )
        call SetPlayerColorString(specificPlayer, "|cff0000ff" )
        call SetPlayerColorRed(specificPlayer, 0 )
        call SetPlayerColorGreen(specificPlayer, 0 )
        call SetPlayerColorBlue(specificPlayer, 255 )

        set specificPlayer = PlayerWJ( 2 )
        call SetPlayerColorString(specificPlayer, "|cff18e7bd" )
        call SetPlayerColorRed(specificPlayer, 24 )
        call SetPlayerColorGreen(specificPlayer, 231 )
        call SetPlayerColorBlue(specificPlayer, 189 )

        set specificPlayer = PlayerWJ( 3 )
        call SetPlayerColorString(specificPlayer, "|cff520084" )
        call SetPlayerColorRed(specificPlayer, 82 )
        call SetPlayerColorGreen(specificPlayer, 0 )
        call SetPlayerColorBlue(specificPlayer, 132 )

        set specificPlayer = PlayerWJ( 4 )
        call SetPlayerColorString(specificPlayer, "|cffffff00" )
        call SetPlayerColorRed(specificPlayer, 255 )
        call SetPlayerColorGreen(specificPlayer, 255 )
        call SetPlayerColorBlue(specificPlayer, 0 )

        set specificPlayer = PlayerWJ( 5 )
        call SetPlayerColorString(specificPlayer, "|cffff8a08" )
        call SetPlayerColorRed(specificPlayer, 255 )
        call SetPlayerColorGreen(specificPlayer, 138 )
        call SetPlayerColorBlue(specificPlayer, 8 )

        set specificPlayer = PlayerWJ( 6 )
        call SetPlayerColorString(specificPlayer, "|cff18be00" )
        call SetPlayerColorRed(specificPlayer, 24 )
        call SetPlayerColorGreen(specificPlayer, 190 )
        call SetPlayerColorBlue(specificPlayer, 0 )

        set specificPlayer = PlayerWJ( 7 )
        call SetPlayerColorString(specificPlayer, "|cffe759ad" )
        call SetPlayerColorRed(specificPlayer, 231 )
        call SetPlayerColorGreen(specificPlayer, 89 )
        call SetPlayerColorBlue(specificPlayer, 173 )

        set specificPlayer = PlayerWJ( 8 )
        call SetPlayerColorString(specificPlayer, "|cff949694" )
        call SetPlayerColorRed(specificPlayer, 148 )
        call SetPlayerColorGreen(specificPlayer, 150 )
        call SetPlayerColorBlue(specificPlayer, 148 )

        set specificPlayer = PlayerWJ( 9 )
        call SetPlayerColorString(specificPlayer, "|cff7bbef7" )
        call SetPlayerColorRed(specificPlayer, 123 )
        call SetPlayerColorGreen(specificPlayer, 190 )
        call SetPlayerColorBlue(specificPlayer, 247 )

        set specificPlayer = PlayerWJ( 10 )
        call SetPlayerColorString(specificPlayer, "|cff086142" )
        call SetPlayerColorRed(specificPlayer, 8 )
        call SetPlayerColorGreen(specificPlayer, 97 )
        call SetPlayerColorBlue(specificPlayer, 66 )

        set specificPlayer = PlayerWJ( 11 )
        call SetPlayerColorString(specificPlayer, "|cff4a2800" )
        call SetPlayerColorRed(specificPlayer, 74 )
        call SetPlayerColorGreen(specificPlayer, 40 )
        call SetPlayerColorBlue(specificPlayer, 0 )

        set specificPlayer = PlayerWJ( PLAYER_NEUTRAL_AGGRESSIVE )
        call SetPlayerColorString(specificPlayer, "|cff000000" )
        call SetPlayerColorRed(specificPlayer, 0 )
        call SetPlayerColorGreen(specificPlayer, 0 )
        call SetPlayerColorBlue(specificPlayer, 0 )
        call SetPlayerName(PlayerWJ( PLAYER_NEUTRAL_AGGRESSIVE ), "|cff007f46Cre|cff6432aaepy |cff8c323cPlay|cff788c28er")

        set specificPlayer = PlayerWJ( PLAYER_NEUTRAL_PASSIVE )
        call SetPlayerColorString(specificPlayer, "|cff000000" )
        call SetPlayerColorRed(specificPlayer, 0 )
        call SetPlayerColorGreen(specificPlayer, 0 )
        call SetPlayerColorBlue(specificPlayer, 0 )
        set specificPlayer = null
        call SetPlayerName(PlayerWJ( PLAYER_NEUTRAL_PASSIVE ), "Neutral Player")
    endfunction
endscope