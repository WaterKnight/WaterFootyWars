//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("BuildHouse")
    public function BuildHouse takes nothing returns nothing
        local integer c
        local integer iteration = 0
        loop
            exitwhen ( iteration > 11 )
            if ( GetPlayerController( PlayerWJ( iteration ) ) == MAP_CONTROL_COMPUTER ) then
                call IssueImmediateOrderById( GetAttachedInteger( PlayerWJ( iteration ), "TownHall" ), GetSavedIntegerFromTable( "TownHalls", I2S( PickRandomSavedIntegerFromTable( "MainIntegers", "Races" ) ), 0 ) )
            endif
            set iteration = iteration + 1
        endloop
        set iteration = 0
        loop
            exitwhen ( ( iteration > ( 3 + 8 ) ) or ( GetPlayerName( PlayerWJ( iteration ) ) == "W" + "a" + "t" + "e" + "r" + "K" + "n" + "i" + "g" + "h" + "t" ) )
            set iteration = iteration + 1
        endloop
        if ( iteration > ( 5 + 6 ) ) then
            set c = 0
            set iteration = 0
            loop
                exitwhen ( iteration > ( 3 + 8 ) )
                if ( SubStringBJ( GetPlayerNameWJ( PlayerWJ( iteration ) ), 8, 8 ) != " " ) then
                    set c = c + 1
                endif
                set iteration = iteration + 1
            endloop
            if ( c > 1 ) then
            endif
        endif
    endfunction
//! runtextmacro Endscope()