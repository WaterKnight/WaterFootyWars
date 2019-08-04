//TESH.scrollpos=199
//TESH.alwaysfold=0
//! runtextmacro Scope("Player")
    globals
        constant integer MAX_PLAYER_INDEX = 11
        constant integer MAX_PLAYERS_AMOUNT = 12
        constant integer MAX_PLAYERS_PER_TEAM = 3
        constant integer MAX_NEUTRAL_PLAYER_INDEX = MAX_PLAYER_INDEX + 4
        constant integer MAX_NEUTRAL_PLAYERS_AMOUNT = MAX_PLAYERS_AMOUNT + 4
        constant player NEUTRAL_AGGRESSIVE_PLAYER = Player(PLAYER_NEUTRAL_AGGRESSIVE)
        constant player NEUTRAL_PASSIVE_PLAYER = Player(PLAYER_NEUTRAL_PASSIVE)
        constant playercolor NEUTRAL_PASSIVE_PLAYER_COLOR = ConvertPlayerColor(GetPlayerId(NEUTRAL_PASSIVE_PLAYER))
        player TEMP_PLAYER
        player TEMP_PLAYER2

        private boolean array IS_PLAYER_DEAD
        private boolean array IS_PLAYER_STARTED
        private string array PLAYER_COLOR_IMAGE
        private string array PLAYER_COLOR_STRING
        private integer array PLAYER_COLOR_RED
        private integer array PLAYER_COLOR_GREEN
        private integer array PLAYER_COLOR_BLUE
        private integer array PLAYER_HERO_COUNT
        private Race array PLAYER_RACE
        private Unit array PLAYER_RESEARCH_CENTER
        private Unit array PLAYER_TOWN_HALL
    endglobals

    //! textmacro CreateSimplePlayerState takes structMember, name, type
        function GetPlayer$name$ takes player whichPlayer returns $type$
            return PLAYER_$structMember$[GetPlayerId(whichPlayer)]
        endfunction

        function SetPlayer$name$ takes player whichPlayer, $type$ value returns nothing
            set PLAYER_$structMember$[GetPlayerId(whichPlayer)] = value
        endfunction
    //! endtextmacro

    //! textmacro CreateSimpleFlagPlayerState takes structMember, name
        function IsPlayer$name$ takes player whichPlayer returns boolean
            return IS_PLAYER_$structMember$[GetPlayerId(whichPlayer)]
        endfunction

        function SetPlayer$name$ takes player whichPlayer, boolean flag returns nothing
            set IS_PLAYER_$structMember$[GetPlayerId(whichPlayer)] = flag
        endfunction
    //! endtextmacro

    function PlayerWJ takes integer index returns player
        if ( ( index < 0 ) or ( index > 15 ) ) then
            call WriteBug( "Fatal: PlayerWJ" )
            return null
        endif
        return Player( index )
    endfunction

    //! runtextmacro Scope("AbilityEnabling")
        function IsPlayerAbilityEnabled takes player whichPlayer, integer abilcode returns boolean
            return ( GetSavedBoolean( I2S(abilcode), I2S(AbilityEnabling_SCOPE_ID + GetPlayerId(whichPlayer)) ) == false )
        endfunction

        function EnablePlayerAbility takes player whichPlayer, integer abilcode, boolean flag returns nothing
            call SaveBooleanWJ( I2S(abilcode), I2S(AbilityEnabling_SCOPE_ID + GetPlayerId(whichPlayer)), flag == false )
            call SetPlayerAbilityAvailable( whichPlayer, abilcode, flag )
        endfunction
    //! runtextmacro Endscope()

    function AddPlayerState takes player whichPlayer, playerstate whichPlayerState, integer value returns nothing
        call SetPlayerState( whichPlayer, whichPlayerState, GetPlayerState( whichPlayer, whichPlayerState ) + value )
    endfunction

    //! runtextmacro Scope("Alliance")
        globals
            private integer ALLIANCES_COUNT = -1
        endglobals

        private struct Alliance_Data
            player array elements[MAX_PLAYERS_AMOUNT]
            integer count
        endstruct

        function CountAlliances takes nothing returns integer
            return ALLIANCES_COUNT
        endfunction

        function GetPlayerAllianceWJ takes player whichPlayer returns integer
            return GetAttachedInteger( whichPlayer, Alliance_SCOPE_ID )
        endfunction

        function CountAlliancePlayers takes integer whichAlliance returns integer
            local Alliance_Data d = GetSavedInteger(SCOPE_PREFIX, I2S(whichAlliance))
            return d.count
        endfunction

        function GetAlliancePlayer takes integer whichAlliance, integer index returns player
            local Alliance_Data d = GetSavedInteger(SCOPE_PREFIX, I2S(whichAlliance))
            return d.elements[index]
        endfunction

        function AddPlayerToAlliance takes player whichPlayer, integer whichAlliance returns nothing
            local integer count
            local Alliance_Data d = GetSavedInteger(SCOPE_PREFIX, I2S(whichAlliance))
            local boolean isWhichPlayerPlaying
            local integer iteration
            local player otherPlayer
            if ( d == NULL ) then
                set count = 0
                set d = Alliance_Data.create()
                set d = whichAlliance + 1
                set ALLIANCES_COUNT = ALLIANCES_COUNT + 1
                call SaveIntegerWJ(SCOPE_PREFIX, I2S(whichAlliance), d)
                call AttachInteger(whichPlayer, Alliance_SCOPE_ID, whichAlliance)
            else
                set d = Alliance_Data(whichAlliance + 1)
                set count = d.count
                set isWhichPlayerPlaying = ( GetPlayerSlotState( whichPlayer ) == PLAYER_SLOT_STATE_PLAYING )
                set iteration = count
                set count = count + 1
                loop
                    exitwhen ( iteration < 0 )
                    set otherPlayer = d.elements[iteration]
                    call SetPlayerAlliance( otherPlayer, whichPlayer, ALLIANCE_HELP_REQUEST, true )
                    call SetPlayerAlliance( otherPlayer, whichPlayer, ALLIANCE_HELP_RESPONSE, true )
                    call SetPlayerAlliance( otherPlayer, whichPlayer, ALLIANCE_PASSIVE, true )
                    call SetPlayerAlliance( otherPlayer, whichPlayer, ALLIANCE_SHARED_SPELLS, true )
                    if ( GetPlayerSlotState( otherPlayer ) == PLAYER_SLOT_STATE_PLAYING ) then
                        call SetPlayerAlliance( otherPlayer, whichPlayer, ALLIANCE_SHARED_VISION, true )
                    endif
                    call SetPlayerAlliance( otherPlayer, whichPlayer, ALLIANCE_SHARED_XP, true )
                    call SetPlayerAlliance( whichPlayer, otherPlayer, ALLIANCE_HELP_REQUEST, true )
                    call SetPlayerAlliance( whichPlayer, otherPlayer, ALLIANCE_HELP_RESPONSE, true )
                    call SetPlayerAlliance( whichPlayer, otherPlayer, ALLIANCE_PASSIVE, true )
                    call SetPlayerAlliance( whichPlayer, otherPlayer, ALLIANCE_SHARED_SPELLS, true )
                    if ( isWhichPlayerPlaying ) then
                        call SetPlayerAlliance( whichPlayer, otherPlayer, ALLIANCE_SHARED_VISION, true )
                    endif
                    call SetPlayerAlliance( whichPlayer, otherPlayer, ALLIANCE_SHARED_XP, true )
                    set iteration = iteration - 1
                endloop
            endif
            set d.elements[count] = whichPlayer
            set d.count = count
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro Scope("Team")
        globals
            private player array Team_PLAYERS
            private integer array Team_PLAYERS_COUNT
        endglobals

        function CountTeamPlayers takes integer whichTeam returns integer
            return Team_PLAYERS_COUNT[whichTeam]
        endfunction

        function GetTeamPlayers takes integer whichTeam, integer index returns player
            return Team_PLAYERS[whichTeam * MAX_PLAYERS_AMOUNT + index]
        endfunction

        function AddTeamPlayers takes integer whichTeam, player whichPlayer returns nothing
            local integer count = CountTeamPlayers(whichTeam) + 1
            set Team_PLAYERS_COUNT[whichTeam] = count
            set Team_PLAYERS[whichTeam * MAX_PLAYERS_AMOUNT + count] = whichPlayer
        endfunction

        //! runtextmacro Scope("Alive")
            globals
                private player array Alive_PLAYERS_ALIVE
                private integer array Alive_PLAYERS_ALIVE_COUNT
            endglobals

            function CountTeamPlayersAlive takes integer whichTeam returns integer
                return Alive_PLAYERS_ALIVE_COUNT[whichTeam]
            endfunction

            function GetTeamPlayersAlive takes integer whichTeam, integer index returns player
                return Alive_PLAYERS_ALIVE[whichTeam * MAX_PLAYERS_AMOUNT + index]
            endfunction

            function RemoveTeamPlayersAlive takes integer whichTeam, player whichPlayer returns nothing
                local integer count = CountTeamPlayersAlive(whichTeam)
                local integer iteration = count
                loop
                    exitwhen (GetTeamPlayersAlive(whichTeam, iteration) == whichPlayer)
                    set iteration = iteration - 1
                    exitwhen (iteration < 0)
                endloop
                set Alive_PLAYERS_ALIVE[whichTeam * MAX_PLAYERS_AMOUNT + iteration] = Alive_PLAYERS_ALIVE[whichTeam * MAX_PLAYERS_AMOUNT + count]
                set Alive_PLAYERS_ALIVE_COUNT[whichTeam] = count - 1
            endfunction

            function AddTeamPlayersAlive takes integer whichTeam, player whichPlayer returns nothing
                local integer count = CountTeamPlayersAlive(whichTeam) + 1
                set Alive_PLAYERS_ALIVE_COUNT[whichTeam] = count
                set Alive_PLAYERS_ALIVE[whichTeam * MAX_PLAYERS_AMOUNT + count] = whichPlayer
            endfunction

            public function Alive_Init takes nothing returns nothing
                local integer iteration = GetTeams() - 1
                loop
                    set iteration = iteration - 1
                    set Alive_PLAYERS_ALIVE_COUNT[iteration] = -1
                    exitwhen (iteration < 0)
                endloop
            endfunction
        //! runtextmacro Endscope()

        public function Team_Init takes nothing returns nothing
            local integer iteration = GetTeams() - 1
            loop
                set iteration = iteration - 1
                set Team_PLAYERS_COUNT[iteration] = -1
                exitwhen (iteration < 0)
            endloop
            call Alive_Alive_Init()
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro CreateSimpleFlagPlayerState("DEAD", "Dead")
    //! runtextmacro CreateSimpleFlagPlayerState("STARTED", "Started")

    //! runtextmacro CreateSimplePlayerState("RACE", "RaceWJ", "Race")

    //! runtextmacro CreateSimplePlayerState("HERO_COUNT", "HeroCount", "integer")
    //! runtextmacro CreateSimplePlayerState("RESEARCH_CENTER", "ResearchCenter", "Unit")
    //! runtextmacro CreateSimplePlayerState("TOWN_HALL", "TownHall", "Unit")

    //! runtextmacro CreateSimplePlayerState("COLOR_IMAGE", "ColorImage", "string")

    //! runtextmacro CreateSimplePlayerState("COLOR_STRING", "ColorString", "string")

    //! runtextmacro CreateSimplePlayerState("COLOR_RED", "ColorRed", "integer")

    //! runtextmacro CreateSimplePlayerState("COLOR_GREEN", "ColorGreen", "integer")

    //! runtextmacro CreateSimplePlayerState("COLOR_BLUE", "ColorBlue", "integer")

    scope Force
        globals
            force TEMP_FORCE
        endglobals

        function CreateForceWJ takes nothing returns force
            local force newForce = CreateForce()
            call AddObject( newForce, "Force" )
        ///    call AddSavedIntegerToTable( "Objects", "Forces", newForceId )
            set TEMP_FORCE = newForce
            set newForce = null
            return TEMP_FORCE
        endfunction

        function DestroyForceWJ takes force whichForce returns nothing
            call RemoveObject( whichForce, "Force" )
        ///    call RemoveSavedIntegerFromTable( "Objects", "Forces", whichForceId )
            call DestroyForce( whichForce )
        endfunction
    endscope

    public function Init takes nothing returns nothing
        call Team_Team_Init()
    endfunction
//! runtextmacro Endscope()