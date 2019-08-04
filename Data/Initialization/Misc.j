//TESH.scrollpos=144
//TESH.alwaysfold=0
scope Misc
    struct AllianceMode
    endstruct

    struct ArenaMode
        integer array doodadTypesId[10]
        integer doodadTypesCount
        real fogDensity
        real fogRed
        real fogGreen
        real fogBlue
        integer fogStyle
        real fogZEnd
        real fogZStart
        integer index
        Tileset tileset
        DestructableType tree
        integer waterRed
        integer waterGreen
        integer waterBlue
        integer waterAlpha
    endstruct

    struct GameModeType
        string array labels[5]
        integer labelsCount = -1
        string message
    endstruct

    globals
        GameModeType GAME_MODE_TYPE
        GameModeType array GAME_MODE_TYPES
        integer GAME_MODE_TYPES_COUNT = -1
    endglobals

    private function AddGameModeTypeLabel takes string label returns nothing
        local integer count = GAME_MODE_TYPE.labelsCount + 1
        set GAME_MODE_TYPE.labels[count] = label
        set GAME_MODE_TYPE.labelsCount = count
    endfunction

    private function CreateGameModeType takes string message returns GameModeType
        local GameModeType d = GameModeType.create()
        set d.message = message
        set GAME_MODE_TYPE = d
        set GAME_MODE_TYPES_COUNT = GAME_MODE_TYPES_COUNT + 1
        set GAME_MODE_TYPES[GAME_MODE_TYPES_COUNT] = d
        return d
    endfunction

    globals
        AllianceMode ALLIANCE_MODE_FREE_FOR_ALL
        AllianceMode ALLIANCE_MODE_TOP_AGAINST_BOTTOM
        AllianceMode ALLIANCE_MODE_LEFT_AGAINST_RIGHT
        AllianceMode ALLIANCE_MODE_DIAGONAL
        AllianceMode array ALLIANCE_MODES
        public integer ALLIANCE_MODES_COUNT = -1
        ArenaMode ARENA_MODE_FOREST
        ArenaMode ARENA_MODE_ICE_DESERT
        ArenaMode ARENA_MODE_TROPICS
        ArenaMode ARENA_MODE_BARRENS
        ArenaMode ARENA_MODE_HELL
        ArenaMode array ARENA_MODES
        public integer ARENA_MODES_COUNT = -1
        public integer SAVED_DOODAD_TYPES_COUNT = -1
        public integer array SAVED_DOODAD_TYPES_ID
    endglobals

    function CreateAllianceMode takes string label returns AllianceMode
        local AllianceMode d = AllianceMode.create()
        set ALLIANCE_MODES_COUNT = ALLIANCE_MODES_COUNT + 1
        set ALLIANCE_MODES[ALLIANCE_MODES_COUNT] = d
        call AddGameModeTypeLabel(label)
        return d
    endfunction

    private function CreateArenaMode takes string label returns ArenaMode
        local ArenaMode d = ArenaMode.create()
        set ARENA_MODES_COUNT = ARENA_MODES_COUNT + 1
        set d.index = ARENA_MODES_COUNT
        set ARENA_MODES[ARENA_MODES_COUNT] = d
        //call AddGameModeTypeLabel(label)
        return d
    endfunction

    private function SaveDoodadTypeId takes integer whichDoodadTypeId returns nothing
        set SAVED_DOODAD_TYPES_COUNT = SAVED_DOODAD_TYPES_COUNT + 1
        set SAVED_DOODAD_TYPES_ID[SAVED_DOODAD_TYPES_COUNT] = whichDoodadTypeId
    endfunction

    scope AddTerrainToRegions
        globals
            private rect AddTerrainToRegions_DUMMY_RECT
            private trigger AddTerrainToRegions_DUMMY_TRIGGER
            private integer AddTerrainToRegions_ITERATION = 0
            private real AddTerrainToRegions_X
            private real AddTerrainToRegions_Y
        endglobals

        private function AddTerrainToRegions_Trig takes nothing returns nothing
            local integer iteration = AddTerrainToRegions_ITERATION
            local integer specificTerrainTypeId
            local real x = AddTerrainToRegions_X
            local real y = AddTerrainToRegions_Y
            if ( x <= PLAY_RECT_MAX_X ) then
                set iteration = iteration + 1
                set specificTerrainTypeId = GetTerrainType( x, y )
                if ( specificTerrainTypeId == GetTerrainTileFromSet(TILESET_CITYSCAPE, Grass_INDEX ) ) then
                    call SetRect( AddTerrainToRegions_DUMMY_RECT, x - TERRAIN_POINT_SIZE_HALF, y - TERRAIN_POINT_SIZE_HALF, x + TERRAIN_POINT_SIZE_HALF, y + TERRAIN_POINT_SIZE_HALF )
                    call RegionAddRect( Grass_TARGET_REGION, AddTerrainToRegions_DUMMY_RECT )
                elseif ( specificTerrainTypeId == GetTerrainTileFromSet(TILESET_CITYSCAPE, Marble_INDEX ) ) then
                    call SetRect( AddTerrainToRegions_DUMMY_RECT, x - TERRAIN_POINT_SIZE_HALF, y - TERRAIN_POINT_SIZE_HALF, x + TERRAIN_POINT_SIZE_HALF, y + TERRAIN_POINT_SIZE_HALF )
                    call RegionAddRect( Marble_TARGET_REGION, AddTerrainToRegions_DUMMY_RECT )
                endif
                set x = x + 128
                set AddTerrainToRegions_X = x
                if ( iteration > 24 ) then
                    set iteration = 0
                    set AddTerrainToRegions_ITERATION = iteration
                    call RunTrigger(AddTerrainToRegions_DUMMY_TRIGGER)
                else
                    set AddTerrainToRegions_ITERATION = iteration
                    call AddTerrainToRegions_Trig()
                endif
            elseif ( y <= PLAY_RECT_MAX_Y ) then
                set iteration = iteration + 1
                set x = PLAY_RECT_MIN_X
                set y = y + 128
                set specificTerrainTypeId = GetTerrainType( x, y )
                if ( specificTerrainTypeId == GetTerrainTileFromSet(TILESET_CITYSCAPE, Grass_INDEX ) ) then
                    call SetRect( AddTerrainToRegions_DUMMY_RECT, x - TERRAIN_POINT_SIZE_HALF, y - TERRAIN_POINT_SIZE_HALF, x + TERRAIN_POINT_SIZE_HALF, y + TERRAIN_POINT_SIZE_HALF )
                    call RegionAddRect( Grass_TARGET_REGION, AddTerrainToRegions_DUMMY_RECT )
                elseif ( specificTerrainTypeId == GetTerrainTileFromSet(TILESET_CITYSCAPE, Marble_INDEX ) ) then
                    call SetRect( AddTerrainToRegions_DUMMY_RECT, x - TERRAIN_POINT_SIZE_HALF, y - TERRAIN_POINT_SIZE_HALF, x + TERRAIN_POINT_SIZE_HALF, y + TERRAIN_POINT_SIZE_HALF )
                    call RegionAddRect( Marble_TARGET_REGION, AddTerrainToRegions_DUMMY_RECT )
                endif
                set AddTerrainToRegions_X = x
                set AddTerrainToRegions_Y = y
                if ( iteration > 24 ) then
                    set iteration = 0
                    set AddTerrainToRegions_ITERATION = iteration
                    call RunTrigger(AddTerrainToRegions_DUMMY_TRIGGER)
                else
                    set AddTerrainToRegions_ITERATION = iteration
                    call AddTerrainToRegions_Trig()
                endif
            endif
        endfunction

        public function Start takes nothing returns nothing
            set AddTerrainToRegions_DUMMY_RECT = RectWJ(0, 0, 0, 0)
            set AddTerrainToRegions_DUMMY_TRIGGER = CreateTriggerWJ()
            call AddTriggerCode(AddTerrainToRegions_DUMMY_TRIGGER, function AddTerrainToRegions_Trig)
            set AddTerrainToRegions_X = PLAY_RECT_MIN_X
            set AddTerrainToRegions_Y = PLAY_RECT_MIN_Y
            call RunTrigger(AddTerrainToRegions_DUMMY_TRIGGER)
            call RemoveRectWJ(AddTerrainToRegions_DUMMY_RECT)
            set AddTerrainToRegions_DUMMY_RECT = null
        endfunction
    endscope

    public function Init takes nothing returns nothing
        local ArenaMode d

        call CameraDialog_Init()
        call Creeps_Init()
        call Drop_Init()
        call Experience_Init()
        call GoldTower_Init()
        call Hints_Init()
        call Music_Init()
        call Regeneration_Init()
        call ShopInformation_Init()
        //call SpawnInformation_Init()
        call System_Init()
        call UnitRevaluation_Init()

        call SaveDoodadTypeId('D001')
        call SaveDoodadTypeId('D002')

        //call CreateGameModeType("Select an arena")

        set d = CreateArenaMode("Forest")
        set ARENA_MODE_FOREST = d
        set d.doodadTypesId[0] = 'D003'
        set d.doodadTypesId[1] = 'D004'
        set d.doodadTypesId[2] = 'D005'
        set d.doodadTypesId[3] = 'D00D'
        set d.doodadTypesCount = 3
        set d.fogDensity = 0.5
        set d.fogRed = 0
        set d.fogGreen = 0
        set d.fogBlue = 0
        set d.fogStyle = 0
        set d.fogZEnd = 3000
        set d.fogZStart = 1000
        set d.tileset = TILESET_CITYSCAPE
        set d.tree = GetDestructableType(FOREST_TREE_DESTRUCTABLE_ID)
        set d.waterRed = 255
        set d.waterGreen = 255
        set d.waterBlue = 255
        set d.waterAlpha = 255

        set d = CreateArenaMode("Ice Desert")
        set ARENA_MODE_ICE_DESERT = d
        set d.doodadTypesId[0] = 'D006'
        set d.doodadTypesId[1] = 'D007'
        set d.doodadTypesId[2] = 'D008'
        set d.doodadTypesId[3] = 'D00E'
        set d.doodadTypesCount = 3
        set d.fogDensity = 0.5
        set d.fogRed = 220
        set d.fogGreen = 220
        set d.fogBlue = 250
        set d.fogStyle = 0
        set d.fogZEnd = 3000
        set d.fogZStart = 1500
        set d.tileset = TILESET_NORTHREND
        set d.tree = GetDestructableType(ICE_DESERT_ICICLE_DESTRUCTABLE_ID)
        set d.waterRed = 0
        set d.waterGreen = 255
        set d.waterBlue = 255
        set d.waterAlpha = 255

        set d = CreateArenaMode("Tropics")
        set ARENA_MODE_TROPICS = d
        set d.doodadTypesId[0] = 'D009'
        set d.doodadTypesId[1] = 'D00A'
        set d.doodadTypesId[2] = 'D00B'
        set d.doodadTypesId[3] = 'D00C'
        set d.doodadTypesId[4] = 'D00F'
        set d.doodadTypesId[5] = 'D00G'
        set d.doodadTypesCount = 5
        set d.fogDensity = 0.5
        set d.fogRed = 230
        set d.fogGreen = 230
        set d.fogBlue = 88
        set d.fogStyle = 0
        set d.fogZEnd = 3000
        set d.fogZStart = 1500
        set d.tileset = TILESET_SUNKEN_RUINS
        set d.tree = GetDestructableType(TROPICS_TREE_DESTRUCTABLE_ID)
        set d.waterRed = 0
        set d.waterGreen = 255
        set d.waterBlue = 155
        set d.waterAlpha = 225

        set d = CreateArenaMode("Barrens")
        set ARENA_MODE_BARRENS = d
        set d.doodadTypesId[0] = 'D00P'
        set d.doodadTypesId[1] = 'D00Q'
        set d.doodadTypesId[2] = 'D00R'
        set d.doodadTypesId[3] = 'D00S'
        set d.doodadTypesId[4] = 'D00T'
        set d.doodadTypesId[5] = 'D00U'
        set d.doodadTypesCount = 5
        set d.fogDensity = 0.5
        set d.fogRed = 150
        set d.fogGreen = 150
        set d.fogBlue = 80
        set d.fogStyle = 0
        set d.fogZEnd = 3000
        set d.fogZStart = 1500
        set d.tileset = TILESET_BARRENS
        set d.tree = GetDestructableType(BARRENS_TREE_DESTRUCTABLE_ID)
        set d.waterRed = 200
        set d.waterGreen = 200
        set d.waterBlue = 255
        set d.waterAlpha = 255

        set d = CreateArenaMode("Hell")
        set ARENA_MODE_HELL = d
        set d.doodadTypesId[0] = 'D00H'
        set d.doodadTypesId[1] = 'D00I'
        set d.doodadTypesId[2] = 'D00J'
        set d.doodadTypesId[3] = 'D00K'
        set d.doodadTypesId[4] = 'D00L'
        set d.doodadTypesId[5] = 'D00M'
        set d.doodadTypesId[6] = 'D00N'
        set d.doodadTypesId[7] = 'D00O'
        set d.doodadTypesCount = 7
        set d.fogDensity = 0.5
        set d.fogRed = 220
        set d.fogGreen = 0
        set d.fogBlue = 0
        set d.fogStyle = 0
        set d.fogZEnd = 3000
        set d.fogZStart = 1500
        set d.tileset = TILESET_DUNGEON
        set d.tree = GetDestructableType(HELL_TREE_DESTRUCTABLE_ID)
        set d.waterRed = 255
        set d.waterGreen = 0
        set d.waterBlue = 0
        set d.waterAlpha = 255

        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

        call CreateGameModeType("Choose the alliances")

        set ALLIANCE_MODE_FREE_FOR_ALL = CreateAllianceMode("Free for all")
        set ALLIANCE_MODE_TOP_AGAINST_BOTTOM = CreateAllianceMode("Top against bottom")
        set ALLIANCE_MODE_LEFT_AGAINST_RIGHT = CreateAllianceMode("Left against right")
        set ALLIANCE_MODE_DIAGONAL = CreateAllianceMode("Diagonal")

        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

        //call AddTerrainToRegions_Start()

        call SetFloatGameState( GAME_STATE_TIME_OF_DAY, 6 )
        call SetCameraSmoothingFactor( GetLocalPlayer(), 1.20 )
        call ClearMapMusic()
    endfunction
endscope