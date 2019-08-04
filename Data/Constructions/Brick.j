//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("Brick")
    globals
        public constant integer INDEX = 2
    endglobals

    public function TerrainChangeEnding takes real x, real y returns nothing
        call SetTerrainPointPathable( x, y, PATHING_TYPE_BUILDABILITY, false )
    endfunction

    public function TerrainChangeStart takes real x, real y returns nothing
        call SetTerrainPointPathable( x, y, PATHING_TYPE_BUILDABILITY, true )
    endfunction

    public function ConstructingFinish takes Unit constructedStructure returns nothing
        local unit constructedStructureSelf
        local real constructedStructureX
        local real constructedStructureY
        if ( constructedStructure.type.id == BRICK_UNIT_ID ) then
            set constructedStructureSelf = constructedStructure.self
            set constructedStructureX = GetUnitX( constructedStructureSelf )
            set constructedStructureY = GetUnitY( constructedStructureSelf )
            set constructedStructureSelf = null
            call RemoveUnitEx( constructedStructure )
            call SetTerrainTypeExWithSize( constructedStructureX, constructedStructureY, GetTerrainTileFromSet(TILESET, INDEX ), 3 )
        endif
    endfunction

    public function Init takes nothing returns nothing
    endfunction
//! runtextmacro Endscope()