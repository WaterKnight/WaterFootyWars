//TESH.scrollpos=8
//TESH.alwaysfold=0
//! runtextmacro Scope("Race")
    globals
        constant integer MAX_TOWN_HALLS_PER_RACE = 4
    endglobals

    struct Race
        UnitType researchCenter
        UnitType array townHalls[MAX_TOWN_HALLS_PER_RACE]
        integer townHallsCount
    endstruct

    globals
        Race array RACES
        integer RACES_COUNT = -1
    endglobals

    //! textmacro CreateSimpleRaceState takes structMember, name, type
        function GetRace$name$ takes Race whichRace returns $type$
            return whichRace.$structMember$
        endfunction

        function SetRace$name$ takes Race whichRace, $type$ amount returns nothing
            set whichRace.$structMember$ = amount
        endfunction
    //! endtextmacro

    //! runtextmacro CreateSimpleRaceState("researchCenter", "ResearchCenter", "integer")

    //! runtextmacro Scope("TownHall")
        function CountRaceTownHalls takes Race whichRace returns integer
            return whichRace.townHallsCount
        endfunction

        function GetRaceTownHall takes Race whichRace, integer index returns UnitType
            return whichRace.townHalls[index]
        endfunction

        function SetRaceTownHall takes Race whichRace, integer index, UnitType townHall returns nothing
            set whichRace.townHalls[index] = townHall
            set whichRace.townHallsCount = whichRace.townHallsCount + 1
        endfunction
    //! runtextmacro Endscope()

    function CreateRace takes nothing returns Race
        local Race d = Race.create()
        set RACES_COUNT = RACES_COUNT + 1
        //set d = RACES_COUNT + 1
        set d.townHallsCount = -1
        set RACES[RACES_COUNT] = d
        return d
    endfunction
//! runtextmacro Endscope()