//TESH.scrollpos=914
//TESH.alwaysfold=0
scope Start
    globals
        AllianceMode ALLIANCE_MODE
        ArenaMode ARENA_MODE
        public dialog DUMMY_DIALOG
        public timer DUMMY_TIMER
        public trigger DUMMY_TRIGGER
        Unit array GOBLIN_SHOPS
        public integer array RESULTS
        public integer RESULTS_COUNT = -1
        Unit array SHREDDERS
        real array SHREDDERS_X
        real array SHREDDERS_Y
        private constant integer START_GOLD = 500
        Tileset TILESET
        Unit array WORKSHOPS
    endglobals

    private function CommandList takes nothing returns nothing
        call DestroyTimerWJ( GetExpiredTimer() )
        call DisplayTextTimedWJ( "Command list:\n\n-c: show camera dialog (-c value)\n-cs x: set camera smoothing factor to x\n-m x: change background music to x\n-hints: toggle hints on/off\n-sfx: future special effects on/off\n-system: system messages on/off\n\nFor more information see \"Information (F9)\" under \"Commands\"", 30, GetLocalPlayer() )
    endfunction

    scope PlayerGifts
        private function PlayerGifts_BaseSight takes integer period, player whichPlayer returns nothing
            //! runtextmacro RotateRectAroundCenter("BASE_RECT", "PI / 2")
            call FogModifierStart(CreateFogModifierRectWJ( whichPlayer, FOG_OF_WAR_VISIBLE, dummyRect, false, false ))
            call RemoveRectWJ(dummyRect)
            set dummyRect = null
        endfunction

        private function PlayerGifts_PoolSight_Child takes integer period, player whichPlayer returns nothing
            //! runtextmacro RotateRectAroundCenter("POOL_RECT", "PI / 2")
            call FogModifierStart(CreateFogModifierRectWJ( whichPlayer, FOG_OF_WAR_VISIBLE, dummyRect, false, false ))
            call RemoveRectWJ(dummyRect)
            set dummyRect = null
        endfunction

        private function PlayerGifts_PoolSight takes player whichPlayer returns nothing
            local integer iteration = 3
            loop
                call PlayerGifts_PoolSight_Child(iteration, whichPlayer)
                set iteration = iteration - 1
                exitwhen (iteration < 0)
            endloop
        endfunction

        private function PlayerGifts_Trig takes nothing returns nothing
            local real angle
            local integer brickTerrainTypeId = GetTerrainTileFromSet(TILESET, Brick_INDEX)
            local real centerTowerAngle
            local real centerTower2Angle
            local integer count
            local real differenceX
            local real differenceY
            local real difference1
            local real difference2
            local integer iteration
            local integer iteration2
            local real newX
            local real newY
            local player specificPlayer
            local integer specificPlayerId
            local integer specificPlayerTeam
            set iteration = MAX_PLAYER_INDEX
            if ( ALLIANCE_MODE == ALLIANCE_MODE_FREE_FOR_ALL ) then
                loop
                    set specificPlayer = PlayerWJ( iteration )
                    call AddPlayerToAlliance( specificPlayer, GetPlayerTeam( specificPlayer ) )
                    set iteration = iteration - 1
                    exitwhen ( iteration < 0 )
                endloop
            elseif ( ALLIANCE_MODE == ALLIANCE_MODE_TOP_AGAINST_BOTTOM ) then
                loop
                    set specificPlayer = PlayerWJ( iteration )
                    set specificPlayerTeam = GetPlayerTeam( specificPlayer )
                    if ( ( specificPlayerTeam == 0 ) or ( specificPlayerTeam == 3 ) ) then
                        call AddPlayerToAlliance( specificPlayer, 0 )
                    else
                        call AddPlayerToAlliance( specificPlayer, 1 )
                    endif
                    set iteration = iteration - 1
                    exitwhen ( iteration < 0 )
                endloop
            elseif ( ALLIANCE_MODE == ALLIANCE_MODE_LEFT_AGAINST_RIGHT ) then
                loop
                    set specificPlayer = PlayerWJ( iteration )
                    set specificPlayerTeam = GetPlayerTeam( specificPlayer )
                    if ( ( specificPlayerTeam == 0 ) or ( specificPlayerTeam == 1 ) ) then
                        call AddPlayerToAlliance( specificPlayer, 0 )
                    else
                        call AddPlayerToAlliance( specificPlayer, 1 )
                    endif
                    set iteration = iteration - 1
                    exitwhen ( iteration < 0 )
                endloop
            elseif ( ALLIANCE_MODE == ALLIANCE_MODE_DIAGONAL ) then
                loop
                    set specificPlayer = PlayerWJ( iteration )
                    set specificPlayerTeam = GetPlayerTeam( specificPlayer )
                    if ( ( specificPlayerTeam == 0 ) or ( specificPlayerTeam == 2 ) ) then
                        call AddPlayerToAlliance( specificPlayer, 0 )
                    else
                        call AddPlayerToAlliance( specificPlayer, 1 )
                    endif
                    set iteration = iteration - 1
                    exitwhen ( iteration < 0 )
                endloop
            endif
            set specificPlayer = null

            set differenceX = GetRectCenterX( TOWER_RECT ) - CENTER_X
            set differenceY = GetRectCenterY( TOWER_RECT ) - CENTER_Y
            set centerTowerAngle = Atan2( differenceY, differenceX )
            set difference1 = SquareRoot( differenceX * differenceX + differenceY * differenceY )
            set differenceX = GetRectCenterX( TOWER2_RECT ) - CENTER_X
            set differenceY = GetRectCenterY( TOWER2_RECT ) - CENTER_Y
            set centerTower2Angle = Atan2( differenceY, differenceX )
            set difference2 = SquareRoot( differenceX * differenceX + differenceY * differenceY )
            set iteration = GetTeams() - 1
            loop
                set count = 0
                set iteration2 = CountTeamPlayers(iteration)
                loop
                    exitwhen ( iteration2 < 0 )
                    set specificPlayer = GetTeamPlayers(iteration, iteration2)
                    if ( IsPlayerDead( specificPlayer ) == false ) then
                        set count = count + 1
                        set specificPlayerId = GetPlayerId(specificPlayer)
                        call SetPlayerTownHall( specificPlayer, CreateUnitEx( specificPlayer, FLAG_UNIT_ID, START_POSITION_X[specificPlayerId], START_POSITION_Y[specificPlayerId], STANDARD_ANGLE ) )
                        call FogModifierStart(CreateFogModifierRectWJ( specificPlayer, FOG_OF_WAR_VISIBLE, CENTER_RECT, false, false ))
                        call PlayerGifts_BaseSight(iteration, specificPlayer)
                    endif
                    set iteration2 = iteration2 - 1
                endloop
                if ( count > 0 ) then
                    set angle = centerTowerAngle + iteration * PI / 2
                    set newX = CENTER_X + difference1 * Cos( angle )
                    set newY = CENTER_Y + difference1 * Sin( angle )
                    set specificPlayer = GetTeamPlayers(iteration, MAX_PLAYERS_PER_TEAM - 1)
                    call SetTerrainTypeEx( newX, newY, brickTerrainTypeId )
                    call SetTerrainTypeEx( newX, newY, brickTerrainTypeId )
                    call SetTerrainTypeEx( newX, newY, brickTerrainTypeId )
                    call SetTerrainTypeEx( newX, newY, brickTerrainTypeId )
                    call CreateUnitEx( specificPlayer, MYSTICAL_TOWER_UNIT_ID, newX, newY, STANDARD_ANGLE )
                    set angle = centerTower2Angle + iteration * PI / 2
                    set newX = CENTER_X + difference2 * Cos( angle )
                    set newY = CENTER_Y + difference2 * Sin( angle )
                    call SetTerrainTypeEx( newX, newY, brickTerrainTypeId )
                    call SetTerrainTypeEx( newX, newY, brickTerrainTypeId )
                    call SetTerrainTypeEx( newX, newY, brickTerrainTypeId )
                    call SetTerrainTypeEx( newX, newY, brickTerrainTypeId )
                    call CreateUnitEx( GetTeamPlayers(iteration, 0), MYSTICAL_TOWER_UNIT_ID, newX, newY, STANDARD_ANGLE )
                endif
                set iteration = iteration - 1
                exitwhen ( iteration < 0 )
            endloop

            set iteration = MAX_PLAYER_INDEX
            loop
                set specificPlayer = PlayerWJ(iteration)
                if (IsPlayerDead(specificPlayer) == false) then
                    call SetPlayerState(specificPlayer, PLAYER_STATE_RESOURCE_GOLD, START_GOLD)
                    call PlayerGifts_PoolSight(specificPlayer)
                endif
                set iteration = iteration - 1
                exitwhen (iteration < 0)
            endloop
        //    call GoldTower_Create()
        endfunction

        public function PlayerGifts_Start takes nothing returns nothing
            call ExecuteCode(function PlayerGifts_Trig)
        endfunction
    endscope

    scope PlaceDoodads
        globals
            private trigger PlaceDoodads_DUMMY_TRIGGER
            private integer PlaceDoodads_ITERATION = -1
            private real PlaceDoodads_X
            private real PlaceDoodads_Y
        endglobals

        private function PlaceDoodads_Hell takes nothing returns nothing
            local real angle
            local integer iteration = PlaceDoodads_ITERATION
            local real length
            local unit newUnit
            local integer random
            local integer specificTerrainTypeId = GetTerrainTileFromSet(TILESET, Grass_INDEX )
            local real x = PlaceDoodads_X
            local real y = PlaceDoodads_Y
            if ( x <= PLAY_RECT_MAX_X ) then
                set iteration = iteration + 1
                if ( ( GetTerrainType( x, y ) == specificTerrainTypeId ) and ( IsTerrainPathable( x, y, PATHING_TYPE_WALKABILITY ) == false ) and IsTerrainPathable( x, y, PATHING_TYPE_FLOATABILITY ) ) then
                    set random = GetRandomInt( 1, 10 )
                    if ( random > 7 ) then
                        set angle = GetRandomReal( 0, 2 * PI )
                        set length = GetRandomReal( 0, CELL_SIZE )
                        if ( random == 10 ) then
                            set random = 'n025'
                        elseif ( random == 9 ) then
                            set random = 'n024'
                        else
                            set random = 'n013'
                        endif
                        set newUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, random, x + length * Cos( angle ), y + length * Sin( angle ), GetRandomReal( 0, 2 * PI ) )
                        call SetUnitScale( newUnit, GetRandomReal( 0.8, 1 ), GetRandomReal( 0.8, 1 ), GetRandomReal( 0.8, 1 ) )
                        call SetUnitVertexColor( newUnit, GetRandomInt( 200, 255 ), GetRandomInt( 200, 255 ), GetRandomInt( 200, 255 ), 255 )
                    endif
                    set newUnit = null
                endif
                set x = x + 128
                set PlaceDoodads_X = x
                if ( iteration > 24 ) then
                    set iteration = 0
                    set PlaceDoodads_ITERATION = iteration
                    call RunTrigger(PlaceDoodads_DUMMY_TRIGGER)
                else
                    set PlaceDoodads_ITERATION = iteration
                    call PlaceDoodads_Hell()
                endif
            elseif ( y <= PLAY_RECT_MAX_Y ) then
                set iteration = iteration + 1
                set x = PLAY_RECT_MIN_X
                set y = y + 128
                if ( ( GetTerrainType( x, y ) == specificTerrainTypeId ) and ( IsTerrainPathable( x, y, PATHING_TYPE_WALKABILITY ) == false ) and IsTerrainPathable( x, y, PATHING_TYPE_FLOATABILITY ) ) then
                    set random = GetRandomInt( 1, 10 )
                    if ( random > 7 ) then
                        set angle = GetRandomReal( 0, 2 * PI )
                        set length = GetRandomReal( 0, CELL_SIZE )
                        if ( random == 10 ) then
                            set random = 'n025'
                        elseif ( random == 9 ) then
                            set random = 'n024'
                        else
                            set random = 'n013'
                        endif
                        set newUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, random, x + length * Cos( angle ), y + length * Sin( angle ), GetRandomReal( 0, 2 * PI ) )
                        call SetUnitScale( newUnit, GetRandomReal( 0.8, 1 ), GetRandomReal( 0.8, 1 ), GetRandomReal( 0.8, 1 ) )
                        call SetUnitVertexColor( newUnit, GetRandomInt( 0, 255 ), GetRandomInt( 200, 255 ), GetRandomInt( 0, 255 ), 255 )
                    endif
                    set newUnit = null
                endif
                set PlaceDoodads_X = x
                set PlaceDoodads_Y = y
                if ( iteration > 24 ) then
                    set iteration = 0
                    set PlaceDoodads_ITERATION = iteration
                    call RunTrigger(PlaceDoodads_DUMMY_TRIGGER)
                else
                    set PlaceDoodads_ITERATION = iteration
                    call PlaceDoodads_Hell()
                endif
            endif
        endfunction

        private function PlaceDoodads_Barrens takes nothing returns nothing
            local real angle
            local integer iteration = PlaceDoodads_ITERATION
            local real length
            local unit newUnit
            local integer random
            local integer specificTerrainTypeId = GetTerrainTileFromSet(TILESET, Grass_INDEX )
            local real x = PlaceDoodads_X
            local real y = PlaceDoodads_Y
            if ( x <= PLAY_RECT_MAX_X ) then
                set iteration = iteration + 1
                if ( ( GetTerrainType( x, y ) == specificTerrainTypeId ) and ( IsTerrainPathable( x, y, PATHING_TYPE_WALKABILITY ) == false ) and IsTerrainPathable( x, y, PATHING_TYPE_FLOATABILITY ) ) then
                    set random = GetRandomInt( 1, 10 )
                    if ( random > 7 ) then
                        set angle = GetRandomReal( 0, 2 * PI )
                        set length = GetRandomReal( 0, 32 )
                        if ( random == 10 ) then
                            set random = 'n025'
                        elseif ( random == 9 ) then
                            set random = 'n024'
                        else
                            set random = 'n013'
                        endif
                        set newUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, random, x + length * Cos( angle ), y + length * Sin( angle ), GetRandomReal( 0, 2 * PI ) )
                        call SetUnitScale( newUnit, GetRandomReal( 0.8, 1 ), GetRandomReal( 0.8, 1 ), GetRandomReal( 0.8, 1 ) )
                        call SetUnitVertexColor( newUnit, GetRandomInt( 200, 255 ), GetRandomInt( 200, 255 ), GetRandomInt( 200, 255 ), 255 )
                    endif
                    set newUnit = null
                endif
                set x = x + 128
                set PlaceDoodads_X = x
                if ( iteration > 24 ) then
                    set iteration = 0
                    set PlaceDoodads_ITERATION = iteration
                    call RunTrigger(PlaceDoodads_DUMMY_TRIGGER)
                else
                    set PlaceDoodads_ITERATION = iteration
                    call PlaceDoodads_Barrens()
                endif
            elseif ( y <= PLAY_RECT_MAX_Y ) then
                set iteration = iteration + 1
                set x = PLAY_RECT_MIN_X
                set y = y + 128
                if ( ( GetTerrainType( x, y ) == specificTerrainTypeId ) and ( IsTerrainPathable( x, y, PATHING_TYPE_WALKABILITY ) == false ) and IsTerrainPathable( x, y, PATHING_TYPE_FLOATABILITY ) ) then
                    set random = GetRandomInt( 1, 10 )
                    if ( random > 7 ) then
                        set angle = GetRandomReal( 0, 2 * PI )
                        set length = GetRandomReal( 0, 32 )
                        if ( random == 10 ) then
                            set random = 'n025'
                        elseif ( random == 9 ) then
                            set random = 'n024'
                        else
                            set random = 'n013'
                        endif
                        set newUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, random, x + length * Cos( angle ), y + length * Sin( angle ), GetRandomReal( 0, 2 * PI ) )
                        call SetUnitScale( newUnit, GetRandomReal( 0.8, 1 ), GetRandomReal( 0.8, 1 ), GetRandomReal( 0.8, 1 ) )
                        call SetUnitVertexColor( newUnit, GetRandomInt( 0, 255 ), GetRandomInt( 200, 255 ), GetRandomInt( 0, 255 ), 255 )
                    endif
                    set newUnit = null
                endif
                set PlaceDoodads_X = x
                set PlaceDoodads_Y = y
                if ( iteration > 24 ) then
                    set iteration = 0
                    set PlaceDoodads_ITERATION = iteration
                    call RunTrigger(PlaceDoodads_DUMMY_TRIGGER)
                else
                    set PlaceDoodads_ITERATION = iteration
                    call PlaceDoodads_Barrens()
                endif
            endif
        endfunction

        private function PlaceDoodads_Tropics takes nothing returns nothing
            local real angle
            local integer iteration = PlaceDoodads_ITERATION
            local real length
            local unit newUnit
            local integer random
            local integer specificTerrainTypeId = GetTerrainTileFromSet(TILESET, Grass_INDEX )
            local real x = PlaceDoodads_X
            local real y = PlaceDoodads_Y
            if ( x <= PLAY_RECT_MAX_X ) then
                set iteration = iteration + 1
                if ( ( GetTerrainType( x, y ) == specificTerrainTypeId ) and ( IsTerrainPathable( x, y, PATHING_TYPE_WALKABILITY ) == false ) and IsTerrainPathable( x, y, PATHING_TYPE_FLOATABILITY ) ) then
                    set random = GetRandomInt( 1, 10 )
                    if ( random > 6 ) then
                        set angle = GetRandomReal( 0, 2 * PI )
                        set length = GetRandomReal( 0, 32 )
                        if ( random == 10 ) then
                            set random = 'n01C'
                        elseif ( random == 9 ) then
                            set random = 'n01D'
                        elseif ( random == 8 ) then
                            set random = 'n01E'
                        else
                            set random = 'n01F'
                        endif
                        set newUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, random, x + length * Cos( angle ), y + length * Sin( angle ), GetRandomReal( 0, 2 * PI ) )
                        call SetUnitScale( newUnit, GetRandomReal( 0.8, 1 ), GetRandomReal( 0.8, 1 ), GetRandomReal( 0.8, 1 ) )
                        call SetUnitVertexColor( newUnit, GetRandomInt( 200, 255 ), GetRandomInt( 200, 255 ), GetRandomInt( 200, 255 ), 255 )
                    endif
                    set newUnit = null
                endif
                set x = x + 128
                set PlaceDoodads_X = x
                if ( iteration > 24 ) then
                    set iteration = 0
                    set PlaceDoodads_ITERATION = iteration
                    call RunTrigger(PlaceDoodads_DUMMY_TRIGGER)
                else
                    set PlaceDoodads_ITERATION = iteration
                    call PlaceDoodads_Tropics()
                endif
            elseif ( y <= PLAY_RECT_MAX_Y ) then
                set iteration = iteration + 1
                set x = PLAY_RECT_MIN_X
                set y = y + 128
                if ( ( GetTerrainType( x, y ) == specificTerrainTypeId ) and ( IsTerrainPathable( x, y, PATHING_TYPE_WALKABILITY ) == false ) and IsTerrainPathable( x, y, PATHING_TYPE_FLOATABILITY ) ) then
                    set random = GetRandomInt( 1, 10 )
                    if ( random > 6 ) then
                        set angle = GetRandomReal( 0, 2 * PI )
                        set length = GetRandomReal( 0, 32 )
                        if ( random == 10 ) then
                            set random = 'n01C'
                        elseif ( random == 9 ) then
                            set random = 'n01D'
                        elseif ( random == 8 ) then
                            set random = 'n01E'
                        else
                            set random = 'n01F'
                        endif
                        set newUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, random, x + length * Cos( angle ), y + length * Sin( angle ), GetRandomReal( 0, 2 * PI ) )
                        call SetUnitScale( newUnit, GetRandomReal( 0.8, 1 ), GetRandomReal( 0.8, 1 ), GetRandomReal( 0.8, 1 ) )
                        call SetUnitVertexColor( newUnit, GetRandomInt( 0, 255 ), GetRandomInt( 200, 255 ), GetRandomInt( 0, 255 ), 255 )
                    endif
                    set newUnit = null
                endif
                set PlaceDoodads_X = x
                set PlaceDoodads_Y = y
                if ( iteration > 24 ) then
                    set iteration = 0
                    set PlaceDoodads_ITERATION = iteration
                    call RunTrigger(PlaceDoodads_DUMMY_TRIGGER)
                else
                    set PlaceDoodads_ITERATION = iteration
                    call PlaceDoodads_Tropics()
                endif
            endif
        endfunction

        private function PlaceDoodads_IceDesert takes nothing returns nothing
            local real angle
            local integer iteration = PlaceDoodads_ITERATION
            local real length
            local unit newUnit
            local integer random
            local integer specificTerrainTypeId = GetTerrainTileFromSet(TILESET, Grass_INDEX )
            local real x = PlaceDoodads_X
            local real y = PlaceDoodads_Y
            if ( x <= PLAY_RECT_MAX_X ) then
                set iteration = iteration + 1
                if ( ( GetTerrainType( x, y ) == specificTerrainTypeId ) and ( IsTerrainPathable( x, y, PATHING_TYPE_WALKABILITY ) == false ) and IsTerrainPathable( x, y, PATHING_TYPE_FLOATABILITY ) ) then
                    set random = GetRandomInt( 1, 10 )
                    if ( random > 7 ) then
                        set angle = GetRandomReal( 0, 2 * PI )
                        set length = GetRandomReal( 0, 32 )
                        if ( random > 9 ) then
                            set random = 'n01H'
                        elseif ( random > 8 ) then
                            set random = 'n01I'
                        else
                            set random = 'n01J'
                        endif
                        set newUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, random, x + length * Cos( angle ), y + length * Sin( angle ), GetRandomReal( 0, 2 * PI ) )
                        call SetUnitScale( newUnit, GetRandomReal( 0.3, 0.5 ), GetRandomReal( 0.3, 0.5 ), GetRandomReal( 0.3, 0.5 ) )
                        call SetUnitVertexColor( newUnit, GetRandomInt( 200, 255 ), GetRandomInt( 200, 255 ), GetRandomInt( 200, 255 ), 255 )
                    endif
                    set newUnit = null
                endif
                set x = x + 128
                set PlaceDoodads_X = x
                if ( iteration > 24 ) then
                    set iteration = 0
                    set PlaceDoodads_ITERATION = iteration
                    call RunTrigger(PlaceDoodads_DUMMY_TRIGGER)
                else
                    set PlaceDoodads_ITERATION = iteration
                    call PlaceDoodads_IceDesert()
                endif
            elseif ( y <= PLAY_RECT_MAX_Y ) then
                set iteration = iteration + 1
                set x = PLAY_RECT_MIN_X
                set y = y + 128
                if ( ( GetTerrainType( x, y ) == specificTerrainTypeId ) and ( IsTerrainPathable( x, y, PATHING_TYPE_WALKABILITY ) == false ) and IsTerrainPathable( x, y, PATHING_TYPE_FLOATABILITY ) ) then
                    set random = GetRandomInt( 1, 10 )
                    if ( random > 7 ) then
                        set angle = GetRandomReal( 0, 2 * PI )
                        set length = GetRandomReal( 0, 32 )
                        if ( random > 9 ) then
                            set random = 'n01H'
                        elseif ( random > 8 ) then
                            set random = 'n01I'
                        else
                            set random = 'n01J'
                        endif
                        set newUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, random, x + length * Cos( angle ), y + length * Sin( angle ), GetRandomReal( 0, 2 * PI ) )
                        call SetUnitScale( newUnit, GetRandomReal( 0.3, 0.5 ), GetRandomReal( 0.3, 0.5 ), GetRandomReal( 0.3, 0.5 ) )
                        call SetUnitVertexColor( newUnit, GetRandomInt( 0, 255 ), GetRandomInt( 200, 255 ), GetRandomInt( 0, 255 ), 255 )
                    endif
                    set newUnit = null
                endif
                set PlaceDoodads_X = x
                set PlaceDoodads_Y = y
                if ( iteration > 24 ) then
                    set iteration = 0
                    set PlaceDoodads_ITERATION = iteration
                    call RunTrigger(PlaceDoodads_DUMMY_TRIGGER)
                else
                    set PlaceDoodads_ITERATION = iteration
                    call PlaceDoodads_IceDesert()
                endif
            endif
        endfunction

        private function PlaceDoodads_Forest takes nothing returns nothing
            local real angle
            local integer iteration = PlaceDoodads_ITERATION
            local real length
            local unit newUnit
            local integer random
            local integer specificTerrainTypeId = GetTerrainTileFromSet(TILESET, Grass_INDEX )
            local real x = PlaceDoodads_X
            local real y = PlaceDoodads_Y
            if ( x <= PLAY_RECT_MAX_X ) then
                set iteration = iteration + 1
                if ( ( GetTerrainType( x, y ) == specificTerrainTypeId ) and ( IsTerrainPathable( x, y, PATHING_TYPE_WALKABILITY ) == false ) and IsTerrainPathable( x, y, PATHING_TYPE_FLOATABILITY ) ) then
                    set random = GetRandomInt( 1, 10 )
                    if ( random > 7 ) then
                        set angle = GetRandomReal( 0, 2 * PI )
                        set length = GetRandomReal( 0, 32 )
                        if ( random == 10 ) then
                            set random = 'n00B'
                        elseif ( random == 9 ) then
                            set random = 'n00C'
                        else
                            set random = 'n00D'
                        endif
                        set newUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, random, x + length * Cos( angle ), y + length * Sin( angle ), GetRandomReal( 0, 2 * PI ) )
                        call SetUnitScale( newUnit, GetRandomReal( 0.8, 1 ), GetRandomReal( 0.8, 1 ), GetRandomReal( 0.8, 1 ) )
                        call SetUnitVertexColor( newUnit, GetRandomInt( 200, 255 ), GetRandomInt( 200, 255 ), GetRandomInt( 200, 255 ), 255 )
                    endif
                    set random = GetRandomInt( 1, 20 )
                    if ( random > 16 ) then
                        set angle = GetRandomReal( 0, 2 * PI )
                        set length = GetRandomReal( 0, 32 )
                        if ( random == 17 ) then
                            set random = 'n00X'
                        elseif ( random == 18 ) then
                            set random = 'n00Y'
                        else
                            set random = 'n00W'
                        endif
                        set newUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, random, x + length * Cos( angle ), y + length * Sin( angle ), GetRandomReal( 0, 2 * PI ) )
                        call SetUnitScale( newUnit, GetRandomReal( 0.8, 1 ), GetRandomReal( 0.8, 1 ), GetRandomReal( 0.8, 1 ) )
                        call SetUnitVertexColor( newUnit, GetRandomInt( 200, 255 ), GetRandomInt( 200, 255 ), GetRandomInt( 200, 255 ), 225 )
                    endif
                    set newUnit = null
                endif
                set x = x + 128
                set PlaceDoodads_X = x
                if ( iteration > 24 ) then
                    set iteration = 0
                    set PlaceDoodads_ITERATION = iteration
                    call RunTrigger(PlaceDoodads_DUMMY_TRIGGER)
                else
                    set PlaceDoodads_ITERATION = iteration
                    call PlaceDoodads_Forest()
                endif
            elseif ( y <= PLAY_RECT_MAX_Y ) then
                set iteration = iteration + 1
                set x = PLAY_RECT_MIN_X
                set y = y + 128
                if ( ( GetTerrainType( x, y ) == specificTerrainTypeId ) and ( IsTerrainPathable( x, y, PATHING_TYPE_WALKABILITY ) == false ) and IsTerrainPathable( x, y, PATHING_TYPE_FLOATABILITY ) ) then
                    set random = GetRandomInt( 1, 10 )
                    if ( random > 7 ) then
                        set angle = GetRandomReal( 0, 2 * PI )
                        set length = GetRandomReal( 0, CELL_SIZE )
                        if ( random == 10 ) then
                            set random = 'n00B'
                        elseif ( random == 9 ) then
                            set random = 'n00C'
                        else
                            set random = 'n00D'
                        endif
                        set newUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, random, x + length * Cos( angle ), y + length * Sin( angle ), GetRandomReal( 0, 2 * PI ) )
                        call SetUnitScale( newUnit, GetRandomReal( 0.8, 1 ), GetRandomReal( 0.8, 1 ), GetRandomReal( 0.8, 1 ) )
                        call SetUnitVertexColor( newUnit, GetRandomInt( 0, 255 ), GetRandomInt( 200, 255 ), GetRandomInt( 0, 255 ), 255 )
                    endif
                    set random = GetRandomInt( 1, 20 )
                    if ( random > 16 ) then
                        set angle = GetRandomReal( 0, 2 * PI )
                        set length = GetRandomReal( 0, CELL_SIZE )
                        if ( random == 17 ) then
                            set random = 'n00X'
                        elseif ( random == 18 ) then
                            set random = 'n00Y'
                        else
                            set random = 'n00W'
                        endif
                        set newUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, random, x + length * Cos( angle ), y + length * Sin( angle ), GetRandomReal( 0, 2 * PI ) )
                        call SetUnitScale( newUnit, GetRandomReal( 0.8, 1 ), GetRandomReal( 0.8, 1 ), GetRandomReal( 0.8, 1 ) )
                        call SetUnitVertexColor( newUnit, GetRandomInt( 200, 255 ), GetRandomInt( 200, 255 ), GetRandomInt( 200, 255 ), 225 )
                    endif
                    set newUnit = null
                endif
                set PlaceDoodads_X = x
                set PlaceDoodads_Y = y
                if ( iteration > 24 ) then
                    set iteration = 0
                    set PlaceDoodads_ITERATION = iteration
                    call RunTrigger(PlaceDoodads_DUMMY_TRIGGER)
                else
                    set PlaceDoodads_ITERATION = iteration
                    call PlaceDoodads_Forest()
                endif
            endif
        endfunction

        public function PlaceDoodads_Start takes nothing returns nothing
            local integer iteration = ARENA_MODE.doodadTypesCount
            set PlaceDoodads_DUMMY_TRIGGER = CreateTriggerWJ()
            set PlaceDoodads_X = PLAY_RECT_MIN_X
            set PlaceDoodads_Y = PLAY_RECT_MIN_Y
            if ( ARENA_MODE == ARENA_MODE_FOREST ) then
                call AddTriggerCode(PlaceDoodads_DUMMY_TRIGGER, function PlaceDoodads_Forest)
            elseif ( ARENA_MODE == ARENA_MODE_ICE_DESERT ) then
                call AddTriggerCode(PlaceDoodads_DUMMY_TRIGGER, function PlaceDoodads_IceDesert)
            elseif ( ARENA_MODE == ARENA_MODE_TROPICS ) then
                call AddTriggerCode(PlaceDoodads_DUMMY_TRIGGER, function PlaceDoodads_Tropics)
            elseif ( ARENA_MODE == ARENA_MODE_BARRENS ) then
                //call AddTriggerCode(PlaceDoodads_DUMMY_TRIGGER, function PlaceDoodads_Barrens)
            elseif ( ARENA_MODE == ARENA_MODE_HELL ) then
                call AddTriggerCode(PlaceDoodads_DUMMY_TRIGGER, function PlaceDoodads_Hell)
            endif
            call RunTrigger(PlaceDoodads_DUMMY_TRIGGER)
            call SetDoodadAnimationRect( PLAY_RECT, -1, "hide", false )
            call SetDoodadAnimationRect( PLAY_RECT, -1, "soundoff", false )
            call SetTerrainFogEx( ARENA_MODE.fogStyle, ARENA_MODE.fogZStart, ARENA_MODE.fogZEnd, ARENA_MODE.fogDensity, ARENA_MODE.fogRed, ARENA_MODE.fogGreen, ARENA_MODE.fogBlue )
            call SetWaterBaseColor( ARENA_MODE.waterRed, ARENA_MODE.waterGreen, ARENA_MODE.waterBlue, ARENA_MODE.waterAlpha )
            loop
                exitwhen ( iteration < 0 )
                call SetDoodadAnimationRect( PLAY_RECT, ARENA_MODE.doodadTypesId[iteration], "show", false )
                set iteration = iteration - 1
            endloop
            set iteration = Misc_SAVED_DOODAD_TYPES_COUNT
            loop
                exitwhen ( iteration < 0 )
                call SetDoodadAnimationRect( PLAY_RECT, Misc_SAVED_DOODAD_TYPES_ID[iteration], "show", false )
                set iteration = iteration - 1
            endloop
        endfunction
    endscope

    scope PlaceDestructables
        private function Trig takes nothing returns nothing
            local BlockerPos d
            local TreePos e
            local integer iteration = BLOCKER_POSES_COUNT
            local integer iteration2
            local integer iteration3
            local DestructableType tree = ARENA_MODE.tree
            local real treeScale = tree.scale
            local integer treeId = tree.id
            local integer treeVariationsCount = tree.variationsCount
            local real x
            local real y
            loop
                set iteration2 = -1
                set d = BLOCKER_POSES[iteration]
                set x = CENTER_X - d.x
                set y = CENTER_Y - d.y
                loop
                    set iteration3 = iteration2
                    loop
                        call DestructableDies_RegisterDestructable(CreateDestructableWJ( BLOCKER_DESTRUCTABLE_ID, iteration2 * x, iteration3 * y, 0, 1, 0 ))
                        set iteration3 = -iteration3
                        exitwhen ( iteration3 == iteration2 )
                    endloop
                    set iteration2 = -iteration2
                    exitwhen ( iteration2 == -1 )
                endloop
                set iteration = iteration - 1
                exitwhen ( iteration < 0 )
            endloop
            set iteration = TREE_POSES_COUNT
            loop
                set iteration2 = -1
                set e = TREE_POSES[iteration]
                set x = CENTER_X - e.x
                set y = CENTER_Y - e.y
                loop
                    set iteration3 = iteration2
                    loop
                        call DestructableDies_RegisterDestructable(CreateDestructableWJ( treeId, iteration2 * x, iteration3 * y, GetRandomReal( 0, 2 * PI ), treeScale, GetRandomInt( 0, treeVariationsCount ) ))
                        set iteration3 = -iteration3
                        exitwhen ( iteration3 == iteration2 )
                    endloop
                    set iteration2 = -iteration2
                    exitwhen ( iteration2 == -1 )
                endloop
                set iteration = iteration - 1
                exitwhen ( iteration < 0 )
            endloop
        endfunction

        public function PlaceDestructables_Start takes nothing returns nothing
            call ExecuteCode(function Trig)
        endfunction
    endscope

    scope PlaceNeutralBuildings
        private function PlaceNeutralBuildings_GoblinShop takes integer period returns nothing
            //! runtextmacro RotateAroundCenter("GOBLIN_SHOP_RECT", "PI / 2")
            local Unit newUnit
            set newUnit = CreateUnitEx( PlayerWJ( period * MAX_PLAYERS_PER_TEAM ), GOBLIN_SHOP_UNIT_ID, x, y, STANDARD_ANGLE )
            set GOBLIN_SHOPS[period] = newUnit
            call AddUnitTeamSight( newUnit )
        endfunction

        private function PlaceNeutralBuildings_Market takes integer period returns nothing
            //! runtextmacro RotateAroundCenter("MARKET_RECT", "PI / 2")
            local Unit newUnit
            call AddSpecialEffectTargetWJ( "Objects\\InventoryItems\\PotofGold\\PotofGold.mdl", CreateUnitEx( NEUTRAL_PASSIVE_PLAYER, MARKET_UNIT_ID, x, y, STANDARD_ANGLE ).self, "overhead" )
        endfunction

        private function PlaceNeutralBuildings_MercenaryCamp takes integer period returns nothing
            //! runtextmacro RotateAroundCenter("MERCENARY_CAMP_RECT", "PI / 2")
            local Unit newUnit
            call AddSpecialEffectTargetWJ( "Objects\\InventoryItems\\PotofGold\\PotofGold.mdl", CreateUnitEx( NEUTRAL_PASSIVE_PLAYER, MERCENARY_CAMP_UNIT_ID, x, y, STANDARD_ANGLE ).self, "overhead" )
        endfunction

        private function PlaceNeutralBuildings_MasterWizard takes integer period returns nothing
            //! runtextmacro RotateAroundCenter("MASTER_WIZARD_RECT", "PI / 2")
            local Unit newUnit
            call MasterWizard_Start( period, CreateUnitEx( PlayerWJ( period * MAX_PLAYERS_PER_TEAM ), MASTER_WIZARD_UNIT_ID, x, y, STANDARD_ANGLE ) )
        endfunction

        private function PlaceNeutralBuildings_SecondhandDealer takes integer period returns nothing
            //! runtextmacro RotateAroundCenter("SECONDHAND_DEALER_RECT", "PI / 2")
            local Unit newUnit
            call CreateUnitEx(NEUTRAL_PASSIVE_PLAYER, SECONDHAND_DEALER_UNIT_ID, x, y, STANDARD_ANGLE)
        endfunction

        private function PlaceNeutralBuildings_Shredder takes integer period returns nothing
            //! runtextmacro RotateAroundCenter("UNIT_SHREDDER_RECT", "PI / 2")
            local Unit newUnit
            set newUnit = CreateUnitEx( PlayerWJ( period * MAX_PLAYERS_PER_TEAM ), UNIT_SHREDDER_UNIT_ID, x, y, STANDARD_ANGLE )
            set SHREDDERS[period] = newUnit
            set SHREDDERS_X[period] = x
            set SHREDDERS_Y[period] = y
            call AddUnitTeamSight( newUnit )
        endfunction

        private function PlaceNeutralBuildings_Workshop takes integer period returns nothing
            //! runtextmacro RotateAroundCenter("WORKSHOP_RECT", "PI / 2")
            local Unit newUnit
            set newUnit = CreateUnitEx( PlayerWJ( period * MAX_PLAYERS_PER_TEAM ), WORKSHOP_UNIT_ID, x, y, STANDARD_ANGLE )
            set WORKSHOPS[period] = newUnit
            call AddUnitTeamSight( newUnit )
        endfunction

        private function PlaceNeutralBuildings_Trig takes nothing returns nothing
            local integer iteration = GetTeams() - 1
            set FOUNTAIN = CreateUnitEx( NEUTRAL_PASSIVE_PLAYER, FOUNTAIN_UNIT_ID, CENTER_X, CENTER_Y, STANDARD_ANGLE )
            loop
                call PlaceNeutralBuildings_GoblinShop(iteration)
                call PlaceNeutralBuildings_MasterWizard(iteration)
                if (ModulateReal(iteration, 2) == 0) then
                    call PlaceNeutralBuildings_Market(iteration)
                    call PlaceNeutralBuildings_MercenaryCamp(iteration)
                endif
                call PlaceNeutralBuildings_SecondhandDealer(iteration)
                call PlaceNeutralBuildings_Shredder(iteration)
                call PlaceNeutralBuildings_Workshop(iteration)
                set iteration = iteration - 1
                exitwhen (iteration < 0)
            endloop
        endfunction

        public function PlaceNeutralBuildings_Start takes nothing returns nothing
            call ExecuteCode(function PlaceNeutralBuildings_Trig)
        endfunction
    endscope

    //! runtextmacro Scope("PlaceTerrain")
        globals
            private trigger PlaceTerrain_DUMMY_TRIGGER
            private integer PlaceTerrain_ITERATION = 0
            private real PlaceTerrain_X
            private real PlaceTerrain_Y
        endglobals

        private function PlaceTerrain_Trig takes nothing returns nothing
            local integer iteration = PlaceTerrain_ITERATION
            local real x = PlaceTerrain_X
            local real y = PlaceTerrain_Y
            if ( x <= PLAY_RECT_MAX_X ) then
                set iteration = iteration + 1
                call SetTerrainTypeWJ( x, y, GetAttachedIntegerById( GetTerrainType( x, y ), PlaceTerrain_SCOPE_ID ) )
                set x = x + 128
                set PlaceTerrain_X = x
                if ( iteration > 24 ) then
                    set iteration = 0
                    set PlaceTerrain_ITERATION = iteration
                    call RunTrigger(PlaceTerrain_DUMMY_TRIGGER)
                else
                    set PlaceTerrain_ITERATION = iteration
                    call PlaceTerrain_Trig()
                endif
            elseif ( y <= PLAY_RECT_MAX_Y ) then
                set iteration = iteration + 1
                set x = PLAY_RECT_MIN_X
                set y = y + 128
                call SetTerrainTypeWJ( x, y, GetAttachedIntegerById( GetTerrainType( x, y ), PlaceTerrain_SCOPE_ID ) )
                set PlaceTerrain_X = x
                set PlaceTerrain_Y = y
                if ( iteration > 24 ) then
                    set iteration = 0
                    set PlaceTerrain_ITERATION = iteration
                    call RunTrigger(PlaceTerrain_DUMMY_TRIGGER)
                else
                    set PlaceTerrain_ITERATION = iteration
                    call PlaceTerrain_Trig()
                endif
            endif
        endfunction

        public function PlaceTerrain_Start takes nothing returns nothing
            local integer oldTilesetTilesCount = CountTerrainTilesInSet( TILESET_CITYSCAPE )
            local integer iteration = oldTilesetTilesCount
            set PlaceTerrain_DUMMY_TRIGGER = CreateTrigger()
            set TILESET = ARENA_MODE.tileset
            loop
                exitwhen ( iteration < 0 )
                call AttachIntegerById( GetTerrainTileFromSet( TILESET_CITYSCAPE, iteration ), PlaceTerrain_SCOPE_ID, GetTerrainTileFromSet( TILESET, iteration ) )
                set iteration = iteration - 1
            endloop
            set PlaceTerrain_X = PLAY_RECT_MIN_X
            set PlaceTerrain_Y = PLAY_RECT_MIN_Y
            call AddTriggerCode(PlaceTerrain_DUMMY_TRIGGER, function PlaceTerrain_Trig)
            call RunTrigger(PlaceTerrain_DUMMY_TRIGGER)
            set iteration = oldTilesetTilesCount
            loop
                exitwhen ( iteration < 0 )
                call FlushAttachedIntegerById( GetTerrainTileFromSet( TILESET_CITYSCAPE, iteration ), PlaceTerrain_SCOPE_ID )
                set iteration = iteration - 1
            endloop
        endfunction
    //! runtextmacro Endscope()

    scope SetPathing
        globals
            private trigger SetPathing_DUMMY_TRIGGER
            private integer SetPathing_ITERATION = 0
            private real SetPathing_X
            private real SetPathing_Y
        endglobals

        private function SetPathing_Trig takes nothing returns nothing
            local integer brickTerrainTypeId = GetTerrainTileFromSet(TILESET, Brick_INDEX)
            local integer iteration = SetPathing_ITERATION
            local real x = SetPathing_X
            local real y = SetPathing_Y
            if ( x <= INNER_PLAY_RECT_MAX_X ) then
                set iteration = iteration + 1
                if ( GetTerrainType( x, y ) == brickTerrainTypeId ) then
                    call SetTerrainPointPathable( x, y, PATHING_TYPE_BUILDABILITY, true )
                else
        //            call SetTerrainPointPathable( x, y, PATHING_TYPE_BUILDABILITY, false )
                endif
                if ( GetTerrainCliffLevel( x, y ) == STANDARD_CLIFF_LEVEL ) then
                    //call SetTerrainPointPathable( x, y, PATHING_TYPE_FLYABILITY, true )
                else
                    if (IsPointInRect(x, y, CENTER_RECT) == false) then
                        //call SetTerrainPointPathable( x, y, PATHING_TYPE_FLOATABILITY, false )
                        call SetTerrainPointPathable( x, y, PATHING_TYPE_FLYABILITY, false )
                        //call SetTerrainPointPathable( x, y, PATHING_TYPE_WALKABILITY, false )
                    endif
                endif
                set x = x + 128
                set SetPathing_X = x
                if ( iteration > 24 ) then
                    set iteration = 0
                    set SetPathing_ITERATION = iteration
                    call RunTrigger( SetPathing_DUMMY_TRIGGER )
                else
                    set SetPathing_ITERATION = iteration
                    call SetPathing_Trig()
                endif
            elseif ( y <= INNER_PLAY_RECT_MAX_Y ) then
                set iteration = iteration + 1
                set x = INNER_PLAY_RECT_MIN_X
                set y = y + 128
                if ( GetTerrainType( x, y ) == brickTerrainTypeId ) then
                    call SetTerrainPointPathable( x, y, PATHING_TYPE_BUILDABILITY, true )
                else
        //            call SetTerrainPointPathable( x, y, PATHING_TYPE_BUILDABILITY, false )
                endif
                if ( GetTerrainCliffLevel( x, y ) == STANDARD_CLIFF_LEVEL ) then
                    //call SetTerrainPointPathable( x, y, PATHING_TYPE_FLYABILITY, true )
                else
                    if (IsPointInRect(x, y, CENTER_RECT) == false) then
                        //call SetTerrainPointPathable( x, y, PATHING_TYPE_FLOATABILITY, false )
                        call SetTerrainPointPathable( x, y, PATHING_TYPE_FLYABILITY, false )
                        //call SetTerrainPointPathable( x, y, PATHING_TYPE_WALKABILITY, false )
                    endif
                endif
                set SetPathing_X = x
                set SetPathing_Y = y
                if ( iteration > 24 ) then
                    set iteration = 0
                    set SetPathing_ITERATION = iteration
                    call RunTrigger( SetPathing_DUMMY_TRIGGER )
                else
                    set SetPathing_ITERATION = iteration
                    call SetPathing_Trig()
                endif
            endif
        endfunction

        public function SetPathing_Start takes nothing returns nothing
            set SetPathing_DUMMY_TRIGGER = CreateTriggerWJ()
            call AddTriggerCode(SetPathing_DUMMY_TRIGGER, function SetPathing_Trig)
            set SetPathing_X = INNER_PLAY_RECT_MIN_X
            set SetPathing_Y = INNER_PLAY_RECT_MIN_Y
            call RunTrigger(SetPathing_DUMMY_TRIGGER)
        endfunction
    endscope

    public function Start takes integer allianceModeIndex returns nothing
        local integer iteration
        call DestroyDialogWJ( DUMMY_DIALOG )
        call DestroyTimerWJ( DUMMY_TIMER )

        call ExecuteCode( function Sound_Start )

        call PlaySoundFromTypeAcrossRect( WATER_SOUND_TYPE, InitRect( gg_rct_WaterSound1 ), 0 )
        call PlaySoundFromTypeAcrossRect( WATER_SOUND_TYPE, InitRect( gg_rct_WaterSound2 ), 0 )
        call PlaySoundFromTypeAcrossRect( WATER_SOUND_TYPE, InitRect( gg_rct_WaterSound3 ), 0 )
        call PlaySoundFromTypeAcrossRect( WATER_SOUND_TYPE, InitRect( gg_rct_WaterSound4 ), 0 )
        call PlaySoundFromTypeAcrossRect( WATER2_SOUND_TYPE, gg_rct_WaterSound1, 0 )
        call PlaySoundFromTypeAcrossRect( WATER2_SOUND_TYPE, gg_rct_WaterSound2, 0 )
        call PlaySoundFromTypeAcrossRect( WATER2_SOUND_TYPE, gg_rct_WaterSound3, 0 )
        call PlaySoundFromTypeAcrossRect( WATER2_SOUND_TYPE, gg_rct_WaterSound4, 0 )
        call PlayMusic( "Sound\\Music\\mp3Music\\Doom.mp3" )

        set ALLIANCE_MODE = ALLIANCE_MODES[allianceModeIndex]
        set ARENA_MODE = ARENA_MODE_FOREST//ARENA_MODES[arenaModeIndex]

        //if ( ARENA_MODE == ARENA_MODE_FOREST ) then
            set TILESET = TILESET_CITYSCAPE
        //else
            call PlaceTerrain_PlaceTerrain_Start()
        //endif
        call PlaceNeutralBuildings_PlaceNeutralBuildings_Start()
        call PlaceDestructables_PlaceDestructables_Start()
        //call PlaceDoodads_PlaceDoodads_Start()
        call PlayerGifts_PlayerGifts_Start()
        call SetPathing_SetPathing_Start()

    //    call FogMaskEnable( false )
        set iteration = MAX_PLAYER_INDEX
        loop
            call SetFogStateRect( PlayerWJ( iteration ), FOG_OF_WAR_FOGGED, UNMASKED_RECT, true )
            set iteration = iteration - 1
            exitwhen ( iteration < 0 )
        endloop
        call FogEnable( false )
        call FogEnable( true )
        call SetFloatGameState( GAME_STATE_TIME_OF_DAY, 12 )
        call SuspendTimeOfDay( true )

        call DisplayCineFilterWJ( GetLocalPlayer(), false )
        call BuildHouse_BuildHouse()
        //call StartWeather_Start()

        call CameraDialog_Start()
        call Creeps_Start()
        call ExtraGold_Start()
        call Infoboard_Start()
        call Infocard_Start()
        call Hints_Start()
        call Regeneration_Start()
        call TimeOfDay_Start()
        call TimerStart( CreateTimerWJ(), 20, false, function CommandList )
    endfunction
endscope