//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("Music")
    public function Chat takes string chatMessage, player whichPlayer returns nothing
        local string fileName
        set chatMessage = StringCase( chatMessage, false )
        if ( SubString( chatMessage, 0, 3 ) == "-m " ) then
            if ( GetLocalPlayer() == whichPlayer ) then
                set fileName = GetSavedString( SCOPE_PREFIX, SubString( chatMessage, 3, StringLength( chatMessage ) ) )
                if ( fileName != null ) then
                    call DisplayTextTimedWJ("|cff00ff00Now playing " + fileName + "|r.", HINT_TEXT_DURATION, whichPlayer)
                    call PlayMusic( fileName )
                endif
            endif
        endif
    endfunction

    public function InitTitle takes string key, string title returns nothing
        call SaveStringWJ(SCOPE_PREFIX, key, title)
    endfunction

    public function Init takes nothing returns nothing
        call InitTitle( "arthas", "Sound\\Music\\mp3Music\\ArthasTheme.mp3" )
        call InitTitle( "bloodelf", "Sound\\Music\\mp3Music\\BloodElfTheme.mp3" )
        call InitTitle( "comrade", "Sound\\Music\\mp3Music\\Comradeship.mp3" )
        call InitTitle( "confrontation", "Sound\\Music\\mp3Music\\TragicConfrontation.mp3" )
        call InitTitle( "credits", "Sound\\Music\\mp3Music\\Credits.mp3" )
        call InitTitle( "darka", "Sound\\Music\\mp3Music\\DarkAgents.mp3" )
        call InitTitle( "darkv", "Sound\\Music\\mp3Music\\DarkVictory.mp3" )
        call InitTitle( "doom", "Sound\\Music\\mp3Music\\Doom.mp3" )
        call InitTitle( "elf1", "Sound\\Music\\mp3Music\\NightElf1.mp3" )
        call InitTitle( "elf2", "Sound\\Music\\mp3Music\\NightElf2.mp3" )
        call InitTitle( "elf3", "Sound\\Music\\mp3Music\\NightElf3.mp3" )
        call InitTitle( "elfd", "Sound\\Music\\mp3Music\\NightElfDefeat.mp3" )
        call InitTitle( "elfv", "Sound\\Music\\mp3Music\\NightElfVictory.mp3" )
        call InitTitle( "elfx", "Sound\\Music\\mp3Music\\NightElfX1.mp3" )
        call InitTitle( "heroic", "Sound\\Music\\mp3Music\\HeroicVictory.mp3" )
        call InitTitle( "human1", "Sound\\Music\\mp3Music\\Human1.mp3" )
        call InitTitle( "human2", "Sound\\Music\\mp3Music\\Human2.mp3" )
        call InitTitle( "human3", "Sound\\Music\\mp3Music\\Human3.mp3" )
        call InitTitle( "humand", "Sound\\Music\\mp3Music\\HumanDefeat.mp3" )
        call InitTitle( "humanv", "Sound\\Music\\mp3Music\\HumanVictory.mp3" )
        call InitTitle( "humanx", "Sound\\Music\\mp3Music\\HumanX1.mp3" )
        call InitTitle( "illidan", "Sound\\Music\\mp3Music\\IllidansTheme.mp3" )
        call InitTitle( "orc", "Sound\\Music\\mp3Music\\OrcTheme.mp3" )
        call InitTitle( "orc1", "Sound\\Music\\mp3Music\\Orc1.mp3" )
        call InitTitle( "orc2", "Sound\\Music\\mp3Music\\Orc2.mp3" )
        call InitTitle( "orc3", "Sound\\Music\\mp3Music\\Orc3.mp3" )
        call InitTitle( "orcd", "Sound\\Music\\mp3Music\\OrcDefeat.mp3" )
        call InitTitle( "orcv", "Sound\\Music\\mp3Music\\OrcVictory.mp3" )
        call InitTitle( "orcx", "Sound\\Music\\mp3Music\\OrcX1.mp3" )
        call InitTitle( "lich", "Sound\\Music\\mp3Music\\LichKingTheme.mp3" )
        call InitTitle( "main", "Sound\\Music\\mp3Music\\Mainscreen.mp3" )
        call InitTitle( "mistery", "Sound\\Music\\mp3Music\\SadMistery.mp3" )
        call InitTitle( "naga", "Sound\\Music\\mp3Music\\NagaTheme.mp3" )
        call InitTitle( "pursuit", "Sound\\Music\\mp3Music\\PursuitTheme.mp3" )
        call InitTitle( "tension", "Sound\\Music\\mp3Music\\Tension.mp3" )
        call InitTitle( "undead1", "Sound\\Music\\mp3Music\\Undead1.mp3" )
        call InitTitle( "undead2", "Sound\\Music\\mp3Music\\Undead2.mp3" )
        call InitTitle( "undead3", "Sound\\Music\\mp3Music\\Undead3.mp3" )
        call InitTitle( "undeadd", "Sound\\Music\\mp3Music\\UndeadDefeat.mp3" )
        call InitTitle( "undeadv", "Sound\\Music\\mp3Music\\UndeadVictory.mp3" )
        call InitTitle( "undeadx", "Sound\\Music\\mp3Music\\UndeadX1.mp3" )
        call InitTitle( "war2", "Sound\\Music\\mp3Music\\War2IntroMusic.mp3" )
        call InitTitle( "war3x", "Sound\\Music\\mp3Music\\War3XMainScreen.mp3" )
    endfunction
//! runtextmacro Endscope()