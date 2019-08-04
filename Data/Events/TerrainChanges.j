//TESH.scrollpos=6
//TESH.alwaysfold=0
scope TerrainChanges
    globals
        public trigger DUMMY_TRIGGER

        public integer TRIGGER_TERRAIN_TYPE_ID
        public real X
        public real Y
    endglobals

    private function Start_TriggerEvents_Static takes integer newTerrainTypeId, real x, real y returns nothing
        if (newTerrainTypeId == GetTerrainTileFromSet(TILESET, Brick_INDEX )) then
            call Brick_TerrainChangeStart(x, y)
        elseif (newTerrainTypeId == GetTerrainTileFromSet(TILESET, Grass_INDEX )) then
            call Grass_TerrainChangeStart(x, y)
        elseif (newTerrainTypeId == GetTerrainTileFromSet(TILESET, Marble_INDEX )) then
            call Marble_TerrainChangeStart(x, y)
        endif
    endfunction

    private function Ending_TriggerEvents_Static takes integer oldTerrainTypeId, real x, real y returns nothing
        if (oldTerrainTypeId == GetTerrainTileFromSet(TILESET, Brick_INDEX )) then
            call Brick_TerrainChangeEnding(x, y)
        elseif (oldTerrainTypeId == GetTerrainTileFromSet(TILESET, Grass_INDEX )) then
            call Grass_TerrainChangeEnding(x, y)
        elseif (oldTerrainTypeId == GetTerrainTileFromSet(TILESET, Marble_INDEX )) then
            call Marble_TerrainChangeEnding(x, y)
        endif
    endfunction

    private function Trig takes nothing returns nothing
        local real x = X
        local real y = Y
        local integer newTerrainTypeId = TRIGGER_TERRAIN_TYPE_ID
        local integer oldTerrainTypeId = GetTerrainType( x, y )

        call Ending_TriggerEvents_Static(oldTerrainTypeId, x, y)

        call SetTerrainTypeWJ(x, y, newTerrainTypeId)

        call Start_TriggerEvents_Static(newTerrainTypeId, x, y)
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope