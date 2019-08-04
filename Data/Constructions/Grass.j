//TESH.scrollpos=108
//TESH.alwaysfold=0
//! runtextmacro Scope("Grass")
    globals
        private trigger DUMMY_TRIGGER
        private group ENUM_GROUP
        private rect ENUM_RECT
        public constant integer INDEX = 5
        private constant real BONUS_RELATIVE_LIFE_REGENERATION = 1.5
        public group TARGET_GROUP
        public region TARGET_REGION
    endglobals

    private function TargetConditions takes Unit checkingUnit returns boolean
        if ( checkingUnit == NULL ) then
            return false
        endif
        set TEMP_UNIT_SELF = checkingUnit.self
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        if ( GetUnitState( TEMP_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        return true
    endfunction

    private function Ending takes Unit whichUnit returns nothing
        local real bonusLifeRegeneration
        local integer whichUnitId
        local unit whichUnitSelf = whichUnit.self
        if ( IsUnitInGroup( whichUnitSelf, TARGET_GROUP ) ) then
            set whichUnitId = whichUnit.id
            set bonusLifeRegeneration = -GetAttachedRealById( whichUnitId, Grass_SCOPE_ID )
            call FlushAttachedRealById(whichUnitId, Grass_SCOPE_ID)
            //! runtextmacro RemoveEventById( "whichUnitId", "EVENT_DEATH" )
            call GroupRemoveUnit( TARGET_GROUP, whichUnitSelf )
            call AddUnitLifeRegenerationBonus( whichUnit, bonusLifeRegeneration )
        endif
        set whichUnitSelf = null
    endfunction

    public function Death takes Unit whichUnit returns nothing
        call Ending(whichUnit)
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death(DYING_UNIT)
    endfunction

    public function TerrainChangeEnding takes real x, real y returns nothing
        local unit enumUnit
        call SetRect( ENUM_RECT, x - TERRAIN_POINT_SIZE_HALF, y - TERRAIN_POINT_SIZE_HALF, x + TERRAIN_POINT_SIZE_HALF, y + TERRAIN_POINT_SIZE_HALF )
        call RegionAddRect( Grass_TARGET_REGION, ENUM_RECT )
        call SetRect( ENUM_RECT, x - (TERRAIN_POINT_SIZE_HALF + CELL_SIZE), y - (TERRAIN_POINT_SIZE_HALF + CELL_SIZE), x + (TERRAIN_POINT_SIZE_HALF + CELL_SIZE), y + (TERRAIN_POINT_SIZE_HALF + CELL_SIZE) )
        call GroupEnumUnitsInRectWJ( ENUM_GROUP, ENUM_RECT, null )
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit != null ) then
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                if ( ( IsUnitInRegion( TARGET_REGION, enumUnit ) == false ) and ( IsUnitInGroup( enumUnit, ENUM_GROUP ) ) ) then
                    call Ending(GetUnit(enumUnit))
                endif
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
    endfunction

    private function Start takes Unit whichUnit returns nothing
        local real bonusLifeRegeneration = GetUnitLifeRegeneration( whichUnit ) * BONUS_RELATIVE_LIFE_REGENERATION
        local integer whichUnitId = whichUnit.id
        call AttachRealById(whichUnitId, Grass_SCOPE_ID, bonusLifeRegeneration)
        //! runtextmacro AddEventById( "whichUnitId", "EVENT_DEATH" )
        call GroupAddUnit( TARGET_GROUP, whichUnit.self )
        call AddUnitLifeRegenerationBonus( whichUnit, bonusLifeRegeneration )
    endfunction

    public function TerrainChangeStart takes real x, real y returns nothing
        local Unit enumUnit
        local unit enumUnitSelf
        call SetRect( ENUM_RECT, x - TERRAIN_POINT_SIZE_HALF, y - TERRAIN_POINT_SIZE_HALF, x + TERRAIN_POINT_SIZE_HALF, y + TERRAIN_POINT_SIZE_HALF )
        call RegionAddRect( Grass_TARGET_REGION, ENUM_RECT )
        call SetRect( ENUM_RECT, x - (TERRAIN_POINT_SIZE_HALF + CELL_SIZE), y - (TERRAIN_POINT_SIZE_HALF + CELL_SIZE), x + (TERRAIN_POINT_SIZE_HALF + CELL_SIZE), y + (TERRAIN_POINT_SIZE_HALF + CELL_SIZE) )
        call GroupEnumUnitsInRectWJ( ENUM_GROUP, ENUM_RECT, null )
        set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
        if ( enumUnitSelf != null ) then
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnitSelf )
                if ( IsUnitInRegion( TARGET_REGION, enumUnitSelf ) and (IsUnitInGroup( enumUnitSelf, ENUM_GROUP ) == false) ) then
                    set enumUnit = GetUnit(enumUnitSelf)
                    if ( TargetConditions( enumUnit ) ) then
                        call Start(enumUnit)
                    endif
                endif
                set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnitSelf == null )
            endloop
        endif
    endfunction

    public function Activate takes Unit whichUnit returns nothing
        if ( IsUnitInRegion( TARGET_REGION, whichUnit.self ) and TargetConditions(whichUnit) ) then
            call Start(whichUnit)
        endif
    endfunction

    function Activate_Event takes nothing returns nothing
        call Activate( TRIGGER_UNIT )
    endfunction

    private function Trig takes nothing returns nothing
        local Unit triggerUnit = GetUnit(GetTriggerUnit())
        if ( TargetConditions( triggerUnit ) ) then
            if ( GetHandleId(GetTriggerEventId()) == 5 ) then
                call Start(triggerUnit)
            else
                call Ending(triggerUnit)
            endif
        endif
    endfunction

    public function ConstructingFinish takes Unit constructedStructure returns nothing
        local unit constructedStructureSelf
        local real constructedStructureX
        local real constructedStructureY
        if ( constructedStructure.type.id == GRASS_UNIT_ID ) then
            set constructedStructureSelf = constructedStructure.self
            set constructedStructureX = GetUnitX( constructedStructureSelf )
            set constructedStructureY = GetUnitY( constructedStructureSelf )
            set constructedStructureSelf = null
            call RemoveUnitEx( constructedStructure )
            call SetTerrainTypeExWithSize( constructedStructureX, constructedStructureY, GetTerrainTileFromSet(TILESET, INDEX ), 3 )
        endif
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        set ENUM_GROUP = CreateGroupWJ()
        set ENUM_RECT = RectWJ(0, 0, 0, 0)
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        set TARGET_GROUP = CreateGroupWJ()
        set TARGET_REGION = CreateRegionWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
        call TriggerRegisterEnterRegion( DUMMY_TRIGGER, TARGET_REGION, null )
        call TriggerRegisterLeaveRegion( DUMMY_TRIGGER, TARGET_REGION, null )
        call AddNewSavedEvent( "MainIntegers", UnitIsActivated_EVENT_STRING_KEY, 0, function Activate_Event )
    endfunction
//! runtextmacro Endscope()