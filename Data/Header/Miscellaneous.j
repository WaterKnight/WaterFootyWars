//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("Miscellaneous")
    function ClearSelectionWJ takes player whichPlayer returns nothing
        if ( GetLocalPlayer() == whichPlayer ) then
            call ClearSelection()
        endif
    endfunction

    function SelectUnitWJ takes unit whichUnit, boolean flag, player whichPlayer returns nothing
        if ( GetLocalPlayer() == whichPlayer ) then
            call SelectUnit( whichUnit, flag )
        endif
    endfunction

    function ClearTextMessagesWJ takes player whichPlayer returns nothing
        if ( GetLocalPlayer() == whichPlayer ) then
            call ClearTextMessages()
        endif
    endfunction

    //! runtextmacro Scope("Terrain")
        globals
            constant real CELL_SIZE = 32
            constant real TERRAIN_POINT_SIZE = CELL_SIZE * 4
            constant real TERRAIN_POINT_SIZE_HALF = TERRAIN_POINT_SIZE / 2
            Tileset TILESET_CITYSCAPE
            Tileset TILESET_NORTHREND
            Tileset TILESET_SUNKEN_RUINS
            Tileset TILESET_BARRENS
            Tileset TILESET_DUNGEON

            private constant integer Terrain_MAX_TILES_PER_SET = 12
            private integer array Terrain_TILES
            private integer array Terrain_TILES_COUNT
        endglobals

        struct Tileset
            integer count
            integer array whichTypesId[Terrain_MAX_TILES_PER_SET]
        endstruct

        function SetTerrainPointPathable takes real x, real y, pathingtype whichPathingType, boolean flag returns nothing
            local real xend = x + CELL_SIZE
            local real yend = y + CELL_SIZE
            local real xstart = x - CELL_SIZE * 2
            set y = y - CELL_SIZE * 2
            loop
                exitwhen ( y > yend )
                set x = xstart
                loop
                    exitwhen ( x > xend )
                    call SetTerrainPathable( x, y, whichPathingType, flag )
                    set x = x + CELL_SIZE
                endloop
                set y = y + CELL_SIZE
            endloop
        endfunction

        function SetTerrainTypeWJ takes real x, real y, integer whichTerrainTypeId returns nothing
            call SetTerrainType( x, y, whichTerrainTypeId, 0, 1, 0 )
        endfunction

        //! runtextmacro Scope("SetTerrainTypeEx")
            function SetTerrainTypeEx takes real x, real y, integer whichTerrainTypeId returns nothing
                set x = RoundTo( x, 128 )
                set y = RoundTo( y, 128 )
                set TerrainChanges_TRIGGER_TERRAIN_TYPE_ID = whichTerrainTypeId
                set TerrainChanges_X = x
                set TerrainChanges_Y = y
                call RunTrigger(TerrainChanges_DUMMY_TRIGGER)
            endfunction

            function SetTerrainTypeExWithSize takes real x, real y, integer whichTerrainType, integer size returns nothing
                local real xend = x + R2I( size / 2 ) * 128
                local real xstart = xend - size * 128
                local real yend
                set y = y - R2I( size / 2 ) * 128
                set yend = y + size * 128
                loop
                    exitwhen ( y > yend )
                    set x = xstart
                    loop
                        exitwhen ( x > xend )
                        call SetTerrainTypeEx( x, y, whichTerrainType )
                        set x = x + 128
                    endloop
                    set y = y + 128
                endloop
            endfunction
        //! runtextmacro Endscope()

        function CountTerrainTilesInSet takes Tileset tileset returns integer
            return tileset.count
        endfunction

        function GetTerrainTileFromSet takes Tileset tileset, integer index returns integer
            return tileset.whichTypesId[index]
        endfunction

        private function Terrain_AddTileToSet takes Tileset tileset, integer whichTerrainTypeId returns nothing
            local integer count = tileset.count + 1
            set tileset.whichTypesId[count] = whichTerrainTypeId
            set tileset.count = count
        endfunction

        private function Terrain_InitTileset takes nothing returns Tileset
            local Tileset d = Tileset.create()
            set d.count = -1
            return d
        endfunction

        public function Terrain_Init takes nothing returns nothing
            local Tileset d = Terrain_InitTileset()

            set TILESET_CITYSCAPE = d
            call Terrain_AddTileToSet( d, 'Ydrt' )
            call Terrain_AddTileToSet( d, 'Ydtr' )
            call Terrain_AddTileToSet( d, 'Ybtl' )
            call Terrain_AddTileToSet( d, 'Ysqd' )
            call Terrain_AddTileToSet( d, 'Yrtl' )
            call Terrain_AddTileToSet( d, 'Ygsb' )

            set d = Terrain_InitTileset()
            set TILESET_NORTHREND = d
            call Terrain_AddTileToSet( d, 'Ndrt' )
            call Terrain_AddTileToSet( d, 'Ndrd' )
            call Terrain_AddTileToSet( d, 'Ibsq' )
            call Terrain_AddTileToSet( d, 'Irbk' )
            call Terrain_AddTileToSet( d, 'Irbk' )
            call Terrain_AddTileToSet( d, 'Nsnw' )

            set d = Terrain_InitTileset()
            set TILESET_SUNKEN_RUINS = d
            call Terrain_AddTileToSet( d, 'Zdrt' )
            call Terrain_AddTileToSet( d, 'Zdtr' )
            call Terrain_AddTileToSet( d, 'Zbks' )
            call Terrain_AddTileToSet( d, 'Zbkl' )
            call Terrain_AddTileToSet( d, 'Ztil' )
            call Terrain_AddTileToSet( d, 'Zgrs' )

            set d = Terrain_InitTileset()
            set TILESET_BARRENS = d
            call Terrain_AddTileToSet( d, 'Bdrt' )
            call Terrain_AddTileToSet( d, 'Bdrh' )
            call Terrain_AddTileToSet( d, 'Bdrr' )
            call Terrain_AddTileToSet( d, 'Bdsd' )
            call Terrain_AddTileToSet( d, 'Bflr' )
            call Terrain_AddTileToSet( d, 'Bgrr' )

            set d = Terrain_InitTileset()
            set TILESET_DUNGEON = d
            call Terrain_AddTileToSet( d, 'Ddrt' )
            call Terrain_AddTileToSet( d, 'Ddkr' )
            call Terrain_AddTileToSet( d, 'Dbrk' )
            call Terrain_AddTileToSet( d, 'Drds' )
            call Terrain_AddTileToSet( d, 'Dlvc' )
            call Terrain_AddTileToSet( d, 'Dlav' )
        endfunction
    //! runtextmacro Endscope()

    function CountUnitDispelableBuffs takes Unit whichUnit, boolean positiveBuffs, boolean negativeBuffs returns integer
        local integer result = 0
        local integer whichUnitId = whichUnit.id
        if ( positiveBuffs ) then
            set result = result + CountIntegersInTableById(whichUnitId, UnitIsDispelled_EVENT_KEY_POSITIVE) - TABLE_EMPTY
        endif
        if ( negativeBuffs ) then
            set result = result + CountIntegersInTableById(whichUnitId, UnitIsDispelled_EVENT_KEY_NEGATIVE) - TABLE_EMPTY
        endif
        return result
    endfunction

    function DisplayTextTimedWJ takes string text, real time, player whichPlayer returns nothing
        if ( GetLocalPlayer() == whichPlayer ) then
            call DisplayTimedTextToPlayer( whichPlayer, 0, 0, time, text )
        endif
    endfunction

    //! runtextmacro Scope("DisplayTextTimed")
        private struct DisplayTextTimed_Data
            real duration
            timer durationTimer
            timer intervalTimer
            integer position
            player whichPlayer
            string text
        endstruct

        private function Ending takes DisplayTextTimed_Data d, timer durationTimer, player whichPlayer returns nothing
            local timer intervalTimer = d.intervalTimer
            call FlushAttachedInteger( durationTimer, DisplayTextTimed_SCOPE_ID )
            call DestroyTimerWJ( durationTimer )
            call FlushAttachedInteger( intervalTimer, DisplayTextTimed_SCOPE_ID )
            call DestroyTimerWJ( intervalTimer )
            set intervalTimer = null
            call FlushAttachedInteger( whichPlayer, DisplayTextTimed_SCOPE_ID )
        endfunction

        private function EndingByTimer takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local DisplayTextTimed_Data d = GetAttachedInteger(durationTimer, DisplayTextTimed_SCOPE_ID)
            call Ending( d, durationTimer, d.whichPlayer )
            set durationTimer = null
        endfunction

        public function Abort takes player whichPlayer returns nothing
            local DisplayTextTimed_Data d = GetAttachedInteger( whichPlayer, DisplayTextTimed_SCOPE_ID )
            if ( d != NULL ) then
                call Ending( d, d.durationTimer, whichPlayer )
            endif
            call ClearTextMessagesWJ( whichPlayer )
        endfunction

        private function NextCharacter takes nothing returns nothing
            local timer intervalTimer = GetExpiredTimer()
            local DisplayTextTimed_Data d = GetAttachedInteger( intervalTimer, DisplayTextTimed_SCOPE_ID )
            local integer position = d.position + 1
            local string text = d.text
            local player whichPlayer = d.whichPlayer
            set intervalTimer = null
            if ( SubString( text, position, position + ColorStrings_START_LENGTH ) == ColorStrings_START ) then
                set position = position + ColorStrings_START_LENGTH + ColorStrings_BODY_LENGTH
            elseif ( SubString( text, position, position + ColorStrings_RESET_LENGTH ) == ColorStrings_RESET ) then
                set position = position + ColorStrings_RESET_LENGTH
            endif
            call ClearTextMessagesWJ( whichPlayer )
            call DisplayTextTimedWJ( SubString( text, 0, position + 1 ), d.duration, whichPlayer )
            set whichPlayer = null
            set d.position = position
        endfunction

        function DisplayTextTimed takes string text, real time, real duration, player whichPlayer returns nothing
            local DisplayTextTimed_Data d
            local timer durationTimer
            local timer intervalTimer
            local integer iteration
            local integer length
            call ClearTextMessagesWJ( whichPlayer )
            if ( text != "" ) then
                set iteration = 0
                set length = StringLength( text )
                loop
                    exitwhen ( iteration >= length )
                    if ( SubString( text, iteration, iteration + ColorStrings_START_LENGTH ) == ColorStrings_START ) then
                        set length = length - ColorStrings_START_LENGTH - ColorStrings_BODY_LENGTH
                    elseif ( SubString( text, iteration, iteration + ColorStrings_RESET_LENGTH ) == ColorStrings_RESET ) then
                        set length = length - ColorStrings_RESET_LENGTH
                    endif
                    set iteration = iteration + 1
                endloop
                if ( length > 0 ) then
                    set d = GetAttachedInteger( whichPlayer, DisplayTextTimed_SCOPE_ID )
                    if ( d == NULL ) then
                        set d = DisplayTextTimed_Data.create()
                        set durationTimer = CreateTimerWJ()
                        set intervalTimer = CreateTimerWJ()
                        set d.durationTimer = durationTimer
                        set d.intervalTimer = intervalTimer
                        set d.whichPlayer = whichPlayer
                        call AttachInteger( durationTimer, DisplayTextTimed_SCOPE_ID, d )
                        call AttachInteger( intervalTimer, DisplayTextTimed_SCOPE_ID, d )
                        call AttachInteger( whichPlayer, DisplayTextTimed_SCOPE_ID, d )
                    else
                        set durationTimer = d.durationTimer
                        set intervalTimer = d.intervalTimer
                    endif
                    set d.duration = duration
                    set d.position = -1
                    set d.text = text
                    call TimerStart( intervalTimer, time / length, true, function NextCharacter )
                    set intervalTimer = null
                    call TimerStart( durationTimer, time, false, function EndingByTimer )
                    set durationTimer = null
                endif
            endif
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro Scope("Altar")
        globals
            private constant real Altar_HEIGHT = 150.
            private constant real Altar_SLOPE_ANGLE = 30 * DEG_TO_RAD
        endglobals

        //! runtextmacro Scope("Selection")
            globals
                private constant integer Selection_MAX_TYPES = 12
            endglobals

            public struct Selection_Data
                integer count = -1
                string array description[Selection_MAX_TYPES]
                integer array dummyUnitTypesId[Selection_MAX_TYPES]
                integer array whichUnitTypesId[Selection_MAX_TYPES]
            endstruct

            globals
                public Selection_Data array Selection_SELECTIONS
                public integer Selection_SELECTIONS_COUNT = -1
            endglobals

            public function Selection_GetAltarSelection takes integer altarTypeId returns Selection_Data
                return GetAttachedIntegerById(altarTypeId, Selection_SCOPE_ID)
            endfunction

            private function Selection_InitHero takes Selection_Data d, string name, string description, integer dummyUnitTypeId, integer whichUnitTypeId returns nothing
                local integer count = d.count + 1
                set d.count = count
                set d.description[count] = ColorStrings_GOLD + name + ":" + ColorStrings_RESET + " " + description
                set d.dummyUnitTypesId[count] = dummyUnitTypeId
                set d.whichUnitTypesId[count] = whichUnitTypeId
                call InitUnitType(dummyUnitTypeId)
            endfunction

            private function CreateSelection takes nothing returns Selection_Data
                local Selection_Data d = Selection_Data.create()
                set Selection_SELECTIONS_COUNT = Selection_SELECTIONS_COUNT + 1
                set Selection_SELECTIONS[Selection_SELECTIONS_COUNT] = d
                return d
            endfunction

            public function Selection_Init takes nothing returns nothing
                local Selection_Data d = CreateSelection()

                call Selection_InitHero(d, "Witch", "Mighty sorceress that importunes her enemies with a large spectrum of magical abilities.", 'H002', WITCH_UNIT_ID)
                call Selection_InitHero(d, "Paladin", "Devoted servant of light that particularly excels through his supporting skills.", 'H00L', PALADIN_UNIT_ID)
                call Selection_InitHero(d, "Berserker", "Great axe warrior and feared hunter of the Arathi. His eagerness in fight equals that of the Paladin and his brute strength is unmatched.", 'O00C', BERSERKER_UNIT_ID)
                call Selection_InitHero(d, "Medicine Man", "Shaman that is close to the natural forces and spirits and who conjures them in battles for assistance.", 'O00D', MEDICINE_MAN_UNIT_ID)
                call Selection_InitHero(d, "Dark Knight", "Obscure warrior with likewise gloomy abilities. Some people think of him as an emo - but he actually listens to pop.", 'U00C', DARK_KNIGHT_UNIT_ID)
                call Selection_InitHero(d, "Lich", "A frigid harbinger of death which nourishes from the lifeblood of the mortals - and strawberry juice.", 'U00D', LICH_UNIT_ID)
                //call Selection_InitHero(d, "Botanist", "Studied gardener from Eden, whose plants Pflanzen back him out of thankfulness for his daily care.", 'E00D', BOTANIST_UNIT_ID)
                call Selection_InitHero(d, "Headhuntress", "Excellent archer, that rides on a white tiger. Driven by greed, she does everything for the right sum of gold.", 'E00E', HEADHUNTRESS_UNIT_ID)
                //call Selection_InitHero(d, "Fanatical Mechanician", "He is an expert on the field of engineering. But since - due of his exaggerated ambitions for weapon systems - he was declared as certifiably insane, his diploma is just a forgery.", 'N017', FANATICAL_MECHANIC_UNIT_ID)
                call Selection_InitHero(d, "Travelling Trader", "A goblin and his ogreish brother, that take a trip around the world to obtain the best profit - and someone who could remove the glue which keeps them together.", 'N012', TRAVELLING_TRADER_UNIT_ID)
                call AttachIntegerById(ALTAR_UNIT_ID, Selection_SCOPE_ID, d)
            endfunction
        //! runtextmacro Endscope()

        private struct Altar_Data
            Unit altar
            real angle
            real length
            unit array dummyUnits[12]
            integer dummyUnitsCount
            boolean isSelected
            Selection_Selection_Data selection
            integer unitIndex
        endstruct

        private function Altar_UpdateHeroes takes Unit altar, player altarOwner, Altar_Data d returns nothing
            local playercolor altarColor = GetPlayerColor(altarOwner)
            local unit altarSelf = altar.self
            local real altarX = GetUnitX( altarSelf )
            local real altarY = GetUnitY( altarSelf )
            local Selection_Selection_Data currentSelection = d.selection
            local unit currentUnit
            local real length = d.length
            local real newX
            local real newY
            local real slopeAngle
            local real sourceZ = GetUnitZ( altarSelf, altarX, altarY ) + Altar_HEIGHT
            local integer unitIndex = d.unitIndex
            local integer unitTypesInSelectionCount = currentSelection.count
            local real angleAdd = -2 * PI / (unitTypesInSelectionCount + 1)
            local real angle = d.angle + angleAdd
            local integer iteration = unitTypesInSelectionCount
            local real xPart
            local real yPart
            set altarSelf = null
            loop
                set xPart = Cos( angle )
                set yPart = Sin( angle )
                set slopeAngle = xPart / ( Absolute( xPart ) + Absolute( yPart ) ) * Altar_SLOPE_ANGLE
                set currentUnit = d.dummyUnits[iteration]
                set newX = altarX + length * xPart * Cos( slopeAngle )
                set newY = altarY + length * yPart
                call SetUnitX( currentUnit, newX )
                call SetUnitY( currentUnit, newY )
                call SetUnitZ( currentUnit, newX, newY, sourceZ + length * Sin( slopeAngle ) )
                call SetUnitFacingWJ( currentUnit, angle )
                if ( iteration == unitIndex ) then
                    call SetUnitColor( currentUnit, altarColor )
                    call SetUnitScale( currentUnit, 0.95, 0.95, 0.95 )
                    if (GetLocalPlayer() == altarOwner) then
                        call SetUnitVertexColor( currentUnit, 255, 255, 255, 255 )
                    endif
                else
                    call SetUnitColor( currentUnit, NEUTRAL_PASSIVE_PLAYER_COLOR )
                    call SetUnitScale( currentUnit, 0.85, 0.85, 0.85 )
                    if (GetLocalPlayer() == altarOwner) then
                        call SetUnitVertexColor( currentUnit, 255, 255, 255, 127 )
                    endif
                endif
                set iteration = iteration - 1
                exitwhen ( iteration < 0 )
                set angle = angle + angleAdd
            endloop
            set altarColor = null
            set altarOwner = null
            set currentUnit = null
        endfunction

        private function Altar_UpdateDescription takes Unit altar, player altarOwner, Selection_Selection_Data d, integer unitIndex returns nothing
            call DisplayTextTimed( d.description[unitIndex], 5, 60, altarOwner )
        endfunction

        //! runtextmacro Scope("SetUnitIndex")
            globals
                private constant real SetUnitIndex_DURATION = 1.
                private constant real SetUnitIndex_START_ANGLE = 1.5 * PI
                private constant real SetUnitIndex_UPDATE_TIME = 0.01
                private constant integer SetUnitIndex_WAVES_AMOUNT = R2I(SetUnitIndex_DURATION / SetUnitIndex_UPDATE_TIME)
            endglobals

            private struct SetUnitIndex_Data
                real angleAdd
                real angleAddAdd
                Altar_Data d
                timer durationTimer
                real remainingAngle
                timer updateTimer
            endstruct

            private function SetUnitIndex_Ending takes Unit altar, Altar_Data d, SetUnitIndex_Data e, timer durationTimer returns nothing
                local player altarOwner
                local real angle
                local Selection_Selection_Data currentSelection = d.selection
                local UnitType currentUnitType
                local boolean isAltarSelected = d.isSelected
                local integer iteration = 0
                local integer unitIndex = d.unitIndex
                local integer currentUnitTypeId = currentSelection.whichUnitTypesId[unitIndex]
                local integer unitTypesInSelectionCount = currentSelection.count
                local timer updateTimer = e.updateTimer
                call e.destroy()
                call FlushAttachedIntegerById( altar.id, SetUnitIndex_SCOPE_ID )
                call FlushAttachedInteger( durationTimer, SetUnitIndex_SCOPE_ID )
                call DestroyTimerWJ( durationTimer )
                call FlushAttachedInteger( updateTimer, SetUnitIndex_SCOPE_ID )
                call DestroyTimerWJ( updateTimer )
                set updateTimer = null
                set d.angle = SetUnitIndex_START_ANGLE - unitIndex * ( 2 * PI / (unitTypesInSelectionCount + 1) )
                if ( isAltarSelected ) then
                    set altarOwner = altar.owner
                    set currentUnitType = GetUnitType(currentUnitTypeId)
                    call Altar_UpdateHeroes( altar, altarOwner, d )
                    call PlaySoundFromTypeForPlayer( GetUnitTypePissedSound(currentUnitType, GetRandomInt(0, CountUnitTypePissedSounds(currentUnitType))), altarOwner )
                endif
            endfunction

            public function SetUnitIndex_EndingByRemove takes Unit altar, Altar_Data d returns nothing
                local SetUnitIndex_Data e = GetAttachedIntegerById(altar.id, SetUnitIndex_SCOPE_ID)
                if (e != NULL) then
                    call SetUnitIndex_Ending(altar, d, e, e.durationTimer)
                endif
            endfunction

            private function SetUnitIndex_EndingByTimer takes nothing returns nothing
                local timer durationTimer = GetExpiredTimer()
                local SetUnitIndex_Data e = GetAttachedInteger(durationTimer, SetUnitIndex_SCOPE_ID)
                local Altar_Data d = e.d
                call SetUnitIndex_Ending( d.altar, d, e, durationTimer )
                set durationTimer = null
            endfunction

            private function SetUnitIndex_Update takes nothing returns nothing
                local integer currentUnit
                local integer iteration = 0
                local timer updateTimer = GetExpiredTimer()
                local SetUnitIndex_Data e = GetAttachedInteger(updateTimer, SetUnitIndex_SCOPE_ID)
                local Altar_Data d = e.d
                local Unit altar = d.altar
                local real angleAdd = e.angleAdd + e.angleAddAdd
                local real currentAngle = d.angle + angleAdd
                local real remainingAngle = e.remainingAngle - angleAdd
                set updateTimer = null
                set d.angle = currentAngle
                set e.angleAdd = angleAdd
                set e.remainingAngle = remainingAngle
                call Altar_UpdateHeroes( altar, altar.owner, d )
            endfunction

            public function SetUnitIndex_Start takes Unit altar, player altarOwner, Altar_Data d, integer unitIndex, boolean turnsLeft returns nothing
                local integer altarId = altar.id
                local real angleAdd
                local real angleDifference2
                local real currentAngle
                local Selection_Selection_Data currentSelection = d.selection
                local SetUnitIndex_Data e = GetAttachedIntegerById(altarId, SetUnitIndex_SCOPE_ID)
                local timer durationTimer
                local integer oldUnitIndex
                local integer unitTypesInSelectionCount = currentSelection.count
                local real angleDifference = 2 * PI / (unitTypesInSelectionCount + 1)
                local timer updateTimer
                set oldUnitIndex = d.unitIndex
                if ( e == NULL ) then
                    set currentAngle = SetUnitIndex_START_ANGLE - oldUnitIndex * angleDifference
                    set e = SetUnitIndex_Data.create()
                    set durationTimer = CreateTimerWJ()
                    set updateTimer = CreateTimerWJ()
                    set d.angle = currentAngle
                    set e.durationTimer = durationTimer
                    set e.updateTimer = updateTimer
                    call AttachIntegerById( altarId, SetUnitIndex_SCOPE_ID, e )
                    call AttachInteger( durationTimer, SetUnitIndex_SCOPE_ID, e )
                    call AttachInteger( updateTimer, SetUnitIndex_SCOPE_ID, e )
                else
                    set durationTimer = e.durationTimer
                    set updateTimer = e.updateTimer
                endif

                set angleDifference2 = ( oldUnitIndex - unitIndex ) * angleDifference
                if ( turnsLeft ) then
                    if ( angleDifference2 < 0 ) then
                        set angleDifference2 = angleDifference2 + 2 * PI
                    endif
                else
                    if ( angleDifference2 > 0 ) then
                        set angleDifference2 = angleDifference2 - 2 * PI
                    endif
                endif
                set angleDifference2 = e.remainingAngle + angleDifference2
                set angleAdd = 2 * angleDifference2 / SetUnitIndex_WAVES_AMOUNT

                set d.unitIndex = unitIndex
                set e.d = d
                set e.angleAdd = angleAdd
                set e.angleAddAdd = -angleAdd / SetUnitIndex_WAVES_AMOUNT
                set e.remainingAngle = angleDifference2

                call Altar_UpdateDescription( altar, altarOwner, currentSelection, unitIndex )
                call Altar_UpdateHeroes( altar, altarOwner, d )

                call TimerStart( updateTimer, SetUnitIndex_UPDATE_TIME, true, function SetUnitIndex_Update )
                set updateTimer = null
                call TimerStart( durationTimer, SetUnitIndex_DURATION, false, function SetUnitIndex_EndingByTimer )
                set durationTimer = null
            endfunction
        //! runtextmacro Endscope()

        //! runtextmacro Scope("ShowHeroes")
            globals
                private constant real ShowHeroes_DURATION = 1.
                private constant real ShowHeroes_UPDATE_TIME = 0.01
                private constant real ShowHeroes_LENGTH_ADD_START = 500 * ShowHeroes_UPDATE_TIME
                private constant real ShowHeroes_LENGTH_ADD_ADD = -ShowHeroes_LENGTH_ADD_START / (ShowHeroes_DURATION / ShowHeroes_UPDATE_TIME)
            endglobals

            private struct ShowHeroes_Data
                Altar_Data d
                real lengthAdd
                timer durationTimer
                timer updateTimer
            endstruct

            private function ShowHeroes_Ending takes Unit altar, ShowHeroes_Data d, timer durationTimer returns nothing
                local timer updateTimer = d.updateTimer
                call d.destroy()
                call FlushAttachedIntegerById( altar.id, ShowHeroes_SCOPE_ID )
                call FlushAttachedInteger( durationTimer, ShowHeroes_SCOPE_ID )
                call DestroyTimerWJ( durationTimer )
                call FlushAttachedInteger( updateTimer, ShowHeroes_SCOPE_ID )
                call DestroyTimerWJ( updateTimer )
                set updateTimer = null
            endfunction

            public function ShowHeroes_EndingByRemove takes Unit altar returns nothing
                local ShowHeroes_Data d = GetAttachedIntegerById(altar.id, ShowHeroes_SCOPE_ID)
                if (d != NULL) then
                    call ShowHeroes_Ending(altar, d, d.durationTimer)
                endif
            endfunction

            private function ShowHeroes_EndingByTimer takes nothing returns nothing
                local timer durationTimer = GetExpiredTimer()
                local ShowHeroes_Data e = GetAttachedInteger(durationTimer, ShowHeroes_SCOPE_ID)
                local Altar_Data d = e.d
                call ShowHeroes_Ending( d.altar, e, durationTimer )
                set durationTimer = null
            endfunction

            private function ShowHeroes_Update takes nothing returns nothing
                local timer updateTimer = GetExpiredTimer()
                local ShowHeroes_Data e = GetAttachedInteger(updateTimer, ShowHeroes_SCOPE_ID)
                local Altar_Data d = e.d
                local Unit altar = d.altar
                local real lengthAdd = e.lengthAdd + ShowHeroes_LENGTH_ADD_ADD
                local real length = d.length + lengthAdd
                set updateTimer = null
                set d.length = length
                set e.lengthAdd = lengthAdd
                call Altar_UpdateHeroes( altar, altar.owner, d )
            endfunction

            public function ShowHeroes_Start takes Unit altar, Altar_Data d, boolean flag returns nothing
                local integer altarId = altar.id
                local player altarOwner = altar.owner
                local Selection_Selection_Data currentSelection = d.selection
                local timer durationTimer
                local ShowHeroes_Data e = GetAttachedIntegerById(altarId, ShowHeroes_SCOPE_ID)
                local integer unitTypesInSelectionCount = currentSelection.count
                local integer iteration = unitTypesInSelectionCount
                local timer updateTimer
                set d.length = 0
                set d.isSelected = flag
                if ( flag ) then
                    loop
                        call SetUnitOwner( d.dummyUnits[iteration], altarOwner, false )
                        set iteration = iteration - 1
                        exitwhen ( iteration < 0 )
                    endloop
                    call Altar_UpdateHeroes( altar, altarOwner, d )
                    if ( e == NULL ) then
                        set e = ShowHeroes_Data.create()
                        set durationTimer = CreateTimerWJ()
                        set updateTimer = CreateTimerWJ()
                        set e.d = d
                        set e.durationTimer = durationTimer
                        set e.updateTimer = updateTimer
                        call AttachIntegerById( altarId, ShowHeroes_SCOPE_ID, e )
                        call AttachInteger( durationTimer, ShowHeroes_SCOPE_ID, e )
                        call AttachInteger( updateTimer, ShowHeroes_SCOPE_ID, e )
                    else
                        set durationTimer = e.durationTimer
                        set updateTimer = e.updateTimer
                    endif
                    set e.lengthAdd = ShowHeroes_LENGTH_ADD_START

                    call Altar_UpdateDescription( altar, altarOwner, d, d.unitIndex )

                    call TimerStart( updateTimer, ShowHeroes_UPDATE_TIME, true, function ShowHeroes_Update )
                    set updateTimer = null
                    call TimerStart( durationTimer, ShowHeroes_DURATION, false, function ShowHeroes_EndingByTimer )
                    set durationTimer = null
                else
                    loop
                        call SetUnitOwner( d.dummyUnits[iteration], NEUTRAL_PASSIVE_PLAYER, false )
                        set iteration = iteration - 1
                        exitwhen ( iteration < 0 )
                    endloop
                    call DisplayTextTimed_Abort( altarOwner )
                    if ( e != NULL ) then
                        call ShowHeroes_Ending( altar, e, e.durationTimer )
                    endif
                endif
                set altarOwner = null
            endfunction
        //! runtextmacro Endscope()

        public function Altar_Ending takes Unit altar returns nothing
            local integer altarId = altar.id
            local player altarOwner
            local Altar_Data d = GetAttachedIntegerById(altarId, Altar_SCOPE_ID)
            local unit array dummyUnits
            local integer dummyUnitsCount = d.dummyUnitsCount
            local boolean isSelected = d.isSelected
            local integer iteration = dummyUnitsCount
            loop
                set dummyUnits[iteration] = d.dummyUnits[iteration]
                set iteration = iteration - 1
                exitwhen ( iteration < 0 )
            endloop
            loop
                set iteration = iteration + 1
                call ShowUnit(dummyUnits[iteration], true)
                call RemoveUnitWJ( dummyUnits[iteration] )
                set dummyUnits[iteration] = null
                exitwhen ( iteration == dummyUnitsCount )
            endloop
            call SetUnitIndex_SetUnitIndex_EndingByRemove( altar, d )
            call ShowHeroes_ShowHeroes_EndingByRemove( altar )

            if ( isSelected ) then
                set altarOwner = altar.owner
                call DisplayTextTimed_Abort( altarOwner )
                call SetCameraBoundsToRectWJ(CAMERA_BOUNDS_RECT, altarOwner)
                set altarOwner = null
            endif
            call d.destroy()
            call FlushAttachedIntegerById( altarId, Altar_SCOPE_ID )
            call RemoveUnitEx( altar )
        endfunction

        public function Altar_Deselect takes player triggerPlayer, Unit altar returns nothing
            local Altar_Data d = GetAttachedIntegerById(altar.id, Altar_SCOPE_ID)
            if ( d != NULL ) then
                if ( triggerPlayer == altar.owner ) then
                    call ShowHeroes_ShowHeroes_Start( altar, d, false )
                endif
            endif
        endfunction

        public function Altar_Select takes player triggerPlayer, Unit altar returns nothing
            local Altar_Data d = GetAttachedIntegerById(altar.id, Altar_SCOPE_ID)
            if ( d != NULL ) then
                if ( triggerPlayer == altar.owner ) then
                    call ShowHeroes_ShowHeroes_Start( altar, d, true )
                endif
            endif
        endfunction

        public function Altar_ChooseHero takes Unit caster, player owner, real x, real y returns Unit
            local Altar_Data d = GetAttachedIntegerById(caster.id, Altar_SCOPE_ID)
            return CreateUnitEx( owner, Selection_Selection_GetAltarSelection(caster.type.id).whichUnitTypesId[d.unitIndex], x, y, STANDARD_ANGLE )
        endfunction

        public function Altar_ChooseRandomHero takes player owner, real x, real y returns Unit
            local Selection_Selection_Data selection = Selection_Selection_SELECTIONS[GetRandomInt(0, Selection_Selection_SELECTIONS_COUNT)]
            return CreateUnitEx( owner, selection.whichUnitTypesId[GetRandomInt(0, selection.count)], x, y, STANDARD_ANGLE )
        endfunction

        public function Altar_ChooseRandomHeroFromSelection takes Unit caster, player owner, real x, real y returns Unit
            local Selection_Selection_Data selection = Selection_Selection_GetAltarSelection(caster.type.id)
            return CreateUnitEx( owner, selection.whichUnitTypesId[GetRandomInt(0, selection.count)], x, y, STANDARD_ANGLE )
        endfunction

        public function Altar_NextHero takes Unit caster returns nothing
            local Altar_Data d = GetAttachedIntegerById(caster.id, Altar_SCOPE_ID)
            local integer unitIndex = d.unitIndex
            if ( unitIndex == d.selection.count ) then
                set unitIndex = 0
            else
                set unitIndex = unitIndex + 1
            endif
            call SetUnitIndex_SetUnitIndex_Start( caster, caster.owner, d, unitIndex, false )
        endfunction

        public function Altar_PreviousHero takes Unit caster returns nothing
            local Altar_Data d = GetAttachedIntegerById(caster.id, Altar_SCOPE_ID)
            local integer unitIndex = d.unitIndex
            if ( unitIndex == 0 ) then
                set unitIndex = d.selection.count
            else
                set unitIndex = unitIndex - 1
            endif
            call SetUnitIndex_SetUnitIndex_Start( caster, caster.owner, d, unitIndex, true )
        endfunction

        private function Altar_Start takes Unit altar, player altarOwner, real altarX, real altarY returns nothing
            local integer altarId = altar.id
            local unit altarSelf = altar.self
            local real altarZ = GetUnitZ( altarSelf, altarX, altarY ) + Altar_HEIGHT
            local Selection_Selection_Data currentSelection = Selection_Selection_GetAltarSelection(GetUnitTypeId(altarSelf))
            local unit currentUnit
            local Altar_Data d = GetAttachedIntegerById(altarId, Altar_SCOPE_ID)
            local integer iteration
            local integer unitTypesInSelectionCount = currentSelection.count
            if (d == NULL) then
                set d = Altar_Data.create()
                set d.altar = altar
                call AttachIntegerById(altarId, Altar_SCOPE_ID, d)
            else
                set iteration = d.dummyUnitsCount
                loop
                    set currentUnit = d.dummyUnits[iteration]
                    call ShowUnit(currentUnit, true)
                    call RemoveUnitWJ( currentUnit )
                    set iteration = iteration - 1
                    exitwhen ( iteration < 0 )
                endloop
            endif
            set iteration = unitTypesInSelectionCount
            set d.dummyUnitsCount = unitTypesInSelectionCount
            set d.selection = currentSelection
            set d.unitIndex = 0
            call UnitAddAbility( altarSelf, ChooseRandomHero_SPELL_ID )
            call UnitAddAbility( altarSelf, ChooseHero_SPELL_ID )
            call UnitAddAbility( altarSelf, ChooseRandomHeroFromSelection_SPELL_ID )
            call UnitAddAbility( altarSelf, PreviousHero_SPELL_ID )
            call UnitAddAbility( altarSelf, NextHero_SPELL_ID )
            set altarSelf = null
            loop
                set currentUnit = CreateUnitWJ( altarOwner, currentSelection.dummyUnitTypesId[iteration], altarX, altarY, altarZ )
                set d.dummyUnits[iteration] = currentUnit
                if (GetLocalPlayer() != altarOwner) then
                    call ShowUnit(currentUnit, false)
                endif
                call UnitAddAbility(currentUnit, INVISIBILITY_SPELL_ID)
                call AddUnitLocust( currentUnit )
                call RemoveUnitMoveability( currentUnit )
                call SetUnitPathing( currentUnit, false )
                if ( GetLocalPlayer() == altarOwner ) then
                    call SetUnitVertexColor( currentUnit, 255, 255, 255, 127 )
                else
                    call SetUnitVertexColor( currentUnit, 0, 0, 0, 0 )
                endif
                call InitUnitZ(currentUnit)
                set iteration = iteration - 1
                exitwhen ( iteration < 0 )
            endloop
            call SetUnitIndex_SetUnitIndex_Start( altar, altarOwner, d, GetRandomInt( 0, unitTypesInSelectionCount ), false )
            //call ShowHeroes_ShowHeroes_Start( altar, d, true )
        endfunction

        public function Altar_UpgradeFinish takes Unit altar, player altarOwner, integer altarTypeId, real altarX, real altarY returns nothing
            if ( GetAttachedBooleanById( altarTypeId, Altar_SCOPE_ID ) ) then
                call Altar_Start(altar, altarOwner, altarX, altarY)
            endif
        endfunction

        function CreateAltar takes player altarOwner returns Unit
            local integer altarOwnerId = GetPlayerId(altarOwner)
            local real x = ALTAR_X[altarOwnerId]
            local real y = ALTAR_Y[altarOwnerId]
            local Unit altar = CreateUnitEx( altarOwner, ALTAR_UNIT_ID, x, y, STANDARD_ANGLE )
            local unit altarSelf = altar.self
            call SetCameraBoundsToPointWJ(x, y, altarOwner)
            call SetUnitPathing( altarSelf, false )
            call UnitAddAbility( altarSelf, INVISIBILITY_SPELL_ID )
            call Altar_Start( altar, altarOwner, x, y )
            call ClearSelectionWJ( altarOwner )
            call SelectUnitWJ( altarSelf, true, altarOwner )
            set altarSelf = null
            call PanCameraTimedWJ( altarOwner, x, y, 2 )
            return altar
        endfunction

        public function Altar_Init takes nothing returns nothing
            call AttachBooleanById(ALTAR_UNIT_ID, Altar_SCOPE_ID, true)
            call Selection_Selection_Init()
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro Scope("Spawn")
        private struct Spawn_Data
            boolean advancedTrainingUsed
            Unit rax
            timer spawnTimer
            UnitType spawnType
            player whichPlayer
        endstruct

        //! runtextmacro CreateSimpleUnitTypeState("spawnBonus", "SpawnBonus", "integer")

        //! runtextmacro CreateSimpleUnitTypeState("spawnStage", "SpawnStage", "integer")

        //! runtextmacro CreateSimpleUnitTypeState("spawnTime", "SpawnTime", "real")
        //! runtextmacro CreateSimpleUnitTypeStateForPlayer("spawnTime", "SpawnTime", "real")

        //! runtextmacro CreateSimpleUnitTypeState("spawnTypeId", "SpawnTypeId", "integer")

        ////////////////////////////////////////////////////////////////////////////////////////////////

        public function Spawn_Destroy takes Unit rax returns nothing
            local integer raxId = rax.id
            local Spawn_Data d = GetAttachedIntegerById(raxId, Spawn_SCOPE_ID)
            local timer spawnTimer
            if ( d != NULL ) then
                set spawnTimer = d.spawnTimer
                call d.destroy()
                call FlushAttachedIntegerById(raxId, Spawn_SCOPE_ID)
                call FlushAttachedInteger( spawnTimer, Spawn_SCOPE_ID )
                call DestroyTimerWJ(spawnTimer)
                set spawnTimer = null
            endif
        endfunction

        private function Spawn_Interval takes Spawn_Data d, Unit rax, UnitType spawnType, player whichPlayer, integer whichPlayerId returns nothing
            local Unit newUnit
            local unit newUnitSelf
            local location rallyPoint
            local unit rallyUnitSelf
            local unit raxSelf = rax.self
            local UnitType raxType
            local integer spawnAmount
            local integer spawnTypeId = spawnType.id
            local integer iteration = 1 + GetUnitTypeSpawnBonus( spawnType )
            local integer whichPlayerGold
            local real x = GetUnitX(raxSelf)
            local real y = GetUnitY(raxSelf)
            loop 
                exitwhen (GetPlayerState( whichPlayer, PLAYER_STATE_RESOURCE_FOOD_USED ) + GetUnitTypeSupplyUsed( spawnType ) > GetPlayerState( whichPlayer, PLAYER_STATE_RESOURCE_FOOD_CAP ))
                set newUnit = CreateUnitEx( whichPlayer, spawnTypeId, x, y, STANDARD_ANGLE )
                set newUnitSelf = newUnit.self
                set rallyUnitSelf = GetUnitRallyUnit( raxSelf )
                if ( rallyUnitSelf == null ) then
                    set rallyPoint = GetUnitRallyPoint( raxSelf )
                    call IssuePointOrderById( newUnitSelf, ATTACK_ORDER_ID, GetLocationX( rallyPoint ), GetLocationY( rallyPoint ) )
                    call RemoveLocationWJ( rallyPoint )
                elseif ( rallyUnitSelf != raxSelf ) then
                    call IssueTargetOrderById( newUnitSelf, PATROL_ORDER_ID, rallyUnitSelf )
                endif
                set iteration = iteration - 1
                exitwhen ( iteration < 1 )
            endloop
            if ( d.advancedTrainingUsed ) then
                if ( iteration > 0 ) then
                    call AddPlayerState( whichPlayer, PLAYER_STATE_RESOURCE_GOLD, iteration / spawnAmount * AdvancedTraining_BONUS_TIME_GOLD_COST )
                endif
            endif
            if (rax.automaticAbility == AdvancedTraining_SPELL_ID) then
                set whichPlayerGold = GetPlayerState(whichPlayer, PLAYER_STATE_RESOURCE_GOLD)
                if ( (whichPlayerGold >= AdvancedTraining_BONUS_SPAWN_GOLD_COST) and (iteration == 0) ) then
                    set raxType = rax.type
                    set spawnAmount = 1 + GetUnitTypeSpawnBonus( spawnType )
                    set spawnTypeId = GetUnitTypeSpawnTypeId(GetRaceTownHall(GetUnitTypeRace(raxType), GetRandomInt(0, GetUnitTypeSpawnStage(raxType))))
                    set spawnType = GetUnitType(spawnTypeId)
                    set iteration = spawnAmount
                    loop
                        exitwhen (GetPlayerState( whichPlayer, PLAYER_STATE_RESOURCE_FOOD_USED ) + GetUnitTypeSupplyUsed( spawnType ) > GetPlayerState( whichPlayer, PLAYER_STATE_RESOURCE_FOOD_CAP ))
                        set newUnit = CreateUnitEx( whichPlayer, spawnTypeId, x, y, STANDARD_ANGLE )
                        set newUnitSelf = newUnit.self
                        set rallyUnitSelf = GetUnitRallyUnit( raxSelf )
                        if ( rallyUnitSelf == null ) then
                            set rallyPoint = GetUnitRallyPoint( raxSelf )
                            call IssuePointOrderById( newUnitSelf, ATTACK_ORDER_ID, GetLocationX( rallyPoint ), GetLocationY( rallyPoint ) )
                            call RemoveLocationWJ( rallyPoint )
                        elseif ( rallyUnitSelf != raxSelf ) then
                            call IssueTargetOrderById( newUnitSelf, PATROL_ORDER_ID, rallyUnitSelf )
                        endif
                        set iteration = iteration - 1
                        exitwhen (iteration < 1)
                    endloop
                    if (iteration != spawnAmount) then
                        call SetPlayerState( whichPlayer, PLAYER_STATE_RESOURCE_GOLD, whichPlayerGold - (1 - iteration / spawnAmount) * R2I(AdvancedTraining_BONUS_SPAWN_GOLD_COST) )
                    endif
                endif
            endif
            set newUnitSelf = null
            set rallyPoint = null
            set rallyUnitSelf = null
            set raxSelf = null
        endfunction

        private function Spawn_IntervalByTimer takes nothing returns nothing
            local timer spawnTimer = GetExpiredTimer()
            local Spawn_Data d = GetAttachedInteger(spawnTimer, Spawn_SCOPE_ID)
            local Unit rax = d.rax
            local UnitType spawnType = d.spawnType
            local player whichPlayer = d.whichPlayer
            local real spawnTime = GetUnitTypeSpawnTime( spawnType ) + GetUnitTypeSpawnTimeForPlayer(spawnType, whichPlayer)
            local integer whichPlayerGold
            local integer whichPlayerId = GetPlayerId(whichPlayer)
            call Spawn_Interval(d, rax, spawnType, whichPlayer, whichPlayerId)
            if ( rax.automaticAbility == AdvancedTraining_SPELL_ID ) then
                set whichPlayerGold = GetPlayerState( whichPlayer, PLAYER_STATE_RESOURCE_GOLD )
                if ( whichPlayerGold < AdvancedTraining_BONUS_TIME_GOLD_COST ) then
                    set d.advancedTrainingUsed = false
                else
                    set spawnTime = spawnTime * ( 1 - AdvancedTraining_BONUS_TIME_FACTOR )
                    set d.advancedTrainingUsed = true
                    call SetPlayerState( whichPlayer, PLAYER_STATE_RESOURCE_GOLD, whichPlayerGold - AdvancedTraining_BONUS_TIME_GOLD_COST )
                endif
            else
                set d.advancedTrainingUsed = false
            endif
            set whichPlayer = null
            call TimerStart( spawnTimer, spawnTime, false, function Spawn_IntervalByTimer )
            set spawnTimer = null
        endfunction

        public function Spawn_Start takes Unit rax, integer spawnTypeId, player whichPlayer returns nothing
            local integer raxId = rax.id
            local Spawn_Data d = GetAttachedIntegerById(raxId, Spawn_SCOPE_ID)
            local timer spawnTimer
            local UnitType spawnType = GetUnitType(spawnTypeId)
            if ( d == NULL ) then
                set d = Spawn_Data.create()
                set spawnTimer = CreateTimerWJ()
                set d.rax = rax
                set d.spawnTimer = spawnTimer
                set d.whichPlayer = whichPlayer
                call AttachIntegerById(raxId, Spawn_SCOPE_ID, d)
                call AttachInteger( spawnTimer, Spawn_SCOPE_ID, d )
            else
                set spawnTimer = d.spawnTimer
            endif
            set d.spawnType = spawnType
            call TimerStart( spawnTimer, GetUnitTypeSpawnTime( spawnType ) + GetUnitTypeSpawnTimeForPlayer(spawnType, whichPlayer), false, function Spawn_IntervalByTimer )
            set spawnTimer = null
        endfunction

        public function Spawn_StartByDeath takes Unit rax, player whichPlayer returns nothing
            local Spawn_Data d = GetAttachedIntegerById(rax.id, Spawn_SCOPE_ID)
            local UnitType spawnType = GetUnitType(GetUnitTypeSpawnTypeId(rax))
            local real spawnTime = GetUnitTypeSpawnTime( spawnType ) + GetUnitTypeSpawnTimeForPlayer(spawnType, whichPlayer)
            local timer spawnTimer
            if ( d != NULL ) then
                set spawnTimer = d.spawnTimer
            endif
            if (spawnTime > TimerGetRemaining(spawnTimer)) then
                call TimerStart( spawnTimer, spawnTime, false, function Spawn_IntervalByTimer )
            endif
            set spawnTimer = null
        endfunction
    //! runtextmacro Endscope()

    function Error takes player whichPlayer, string text returns nothing
        call PlaySoundFromTypeForPlayer( ERROR_SOUND_TYPE, whichPlayer )
        call DisplayTextTimedWJ( ColorStrings_GOLD + text + ColorStrings_RESET, 2, whichPlayer )
    endfunction

    function EndDialog takes player whichPlayer returns nothing
        local dialog endDialog = CreateDialogWJ()
        call DialogSetMessage( endDialog, "Muchos arigatou pour playing" )
        call AddDialogQuitButtonWJ( endDialog, false, "Ride into the sunset", 0 )
    //    call DisplayDialogWJ( endDialog, whichPlayer, true )
        set endDialog = null
    endfunction

    function SetCineFilterTextureWJ takes player whichPlayer, string whichPath returns nothing
        if ( GetLocalPlayer() == whichPlayer ) then
            call SetCineFilterTexture( whichPath )
        endif
    endfunction

    function SetCineFilterBlendModeWJ takes player whichPlayer, blendmode whichBlendMode returns nothing
        if ( GetLocalPlayer() == whichPlayer ) then
            call SetCineFilterBlendMode( whichBlendMode )
        endif
    endfunction

    function SetCineFilterTexMapFlagsWJ takes player whichPlayer, texmapflags whichTexMapFlags returns nothing
        if ( GetLocalPlayer() == whichPlayer ) then
            call SetCineFilterTexMapFlags( whichTexMapFlags )
        endif
    endfunction

    function SetCineFilterUVWJ takes player whichPlayer, real minU, real minV, real maxU, real maxV returns nothing
        if ( GetLocalPlayer() == whichPlayer ) then
            call SetCineFilterEndUV( minU, minV, maxU, maxV )
        endif
    endfunction

    function SetCineFilterColorWJ takes player whichPlayer, real red, real green, real blue, real alpha returns nothing
        if ( GetLocalPlayer() == whichPlayer ) then
            call SetCineFilterEndColor( R2I( red ), R2I( green ), R2I( blue ), R2I( alpha ) )
        endif
    endfunction

    function DisplayCineFilterWJ takes player whichPlayer, boolean flag returns nothing
        if ( GetLocalPlayer() == whichPlayer ) then
            call DisplayCineFilter( flag )
        endif
    endfunction

    function KillPlayer takes player whichPlayer returns nothing
        set TRIGGER_PLAYER = whichPlayer
        call RunTrigger( PlayerDies_DUMMY_TRIGGER )
    endfunction

    function ClearMapMusicWJ takes player whichPlayer returns nothing
        if ( GetLocalPlayer() == whichPlayer ) then
            call ClearMapMusic()
        endif
    endfunction

    function SetWaterColorWJ takes player whichPlayer, integer red, integer green, integer blue, integer alpha returns nothing
        if (GetLocalPlayer() == whichPlayer) then
            call SetWaterBaseColor( red, green, blue, alpha )
        endif
    endfunction

    function SetTerrainFogWJ takes player whichPlayer, integer style, real zstart, real zend, real density, real red, real green, real blue returns nothing
        if (GetLocalPlayer() == whichPlayer) then
            call SetTerrainFogEx( style, zstart, zend, density, red, green, blue )
        endif
    endfunction

    //! runtextmacro Scope("AddOrderAbility")
        function GetAbilityOrder takes integer whichAbility, integer index returns integer
            return GetIntegerFromTableById(whichAbility, AddOrderAbility_SCOPE_ID, index)
        endfunction

        function CountOrderAbilities takes integer whichOrder returns integer
            return CountIntegersInTableById(whichOrder, AddOrderAbility_SCOPE_ID)
        endfunction

        function GetOrderAbility takes integer whichOrder, integer index returns integer
            return GetIntegerFromTableById(whichOrder, AddOrderAbility_SCOPE_ID, index)
        endfunction

        function AddOrderAbility takes integer whichOrder, integer whichAbility returns nothing
            call AddIntegerToTableById( whichAbility, AddOrderAbility_SCOPE_ID, whichOrder )
            call AddIntegerToTableById( whichOrder, AddOrderAbility_SCOPE_ID, whichAbility )
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro Scope("Research")
        globals
            key RESEARCH_TYPE_KEY
        endglobals

        struct ResearchType
            integer array goldCost[12]
            integer id
        endstruct

        function GetResearchTypeGoldCost takes ResearchType whichResearchType, integer level returns integer
            return whichResearchType.goldCost[level]
        endfunction

        function SetResearchTypeGoldCost takes ResearchType whichResearchType, integer level, integer goldCost returns nothing
            set whichResearchType.goldCost[level] = goldCost
        endfunction

        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

        function CountResearchTypeIdUnitTypes takes integer whichResearchTypeId returns integer
            return CountIntegersInTableById(whichResearchTypeId, Research_SCOPE_ID)
        endfunction

        function GetResearchTypeIdUnitType takes integer whichResearchTypeId, integer index returns UnitType
            return GetIntegerFromTableById(whichResearchTypeId, Research_SCOPE_ID, index)
        endfunction

        function IsUnitTypeUsingResearchTypeId takes UnitType whichUnitType, integer whichResearchTypeId returns boolean
            return GetSavedBoolean(I2S(whichUnitType.id), SCOPE_PREFIX + I2S(whichResearchTypeId))
        endfunction

        function AddUnitTypeResearchTypeId takes UnitType whichUnitType, integer whichResearchTypeId returns nothing
            call AddIntegerToTableById( whichResearchTypeId, Research_SCOPE_ID, whichUnitType )
            call SaveBooleanWJ( I2S(whichUnitType.id), SCOPE_PREFIX + I2S(whichResearchTypeId), true )
        endfunction

        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

        function GetResearchType takes integer whichResearchTypeId returns ResearchType
            return GetAttachedIntegerById( whichResearchTypeId, RESEARCH_TYPE_KEY )
        endfunction

        function IsResearchType takes integer whichResearchTypeId returns boolean
            return (GetResearchType(whichResearchTypeId) != NULL)
        endfunction

        function InitResearchType takes integer whichResearchTypeId returns ResearchType
            local ResearchType d = ResearchType.create()
            set d.id = whichResearchTypeId
            call AttachIntegerById( whichResearchTypeId, RESEARCH_TYPE_KEY, d )
            //call SetPlayerTechResearched( NEUTRAL_PASSIVE_PLAYER, whichResearchTypeId, 1 )
            return d
        endfunction
    //! runtextmacro Endscope()

    function PingMasterWizard takes integer whichTeam returns nothing
        local Unit wizard = MASTER_WIZARDS[whichTeam]
        local unit wizardSelf = wizard.self
        call PingMinimapEx( GetUnitX( wizardSelf ), GetUnitY( wizardSelf ), 5, 0, 0, 255, false )
        set wizardSelf = null
    endfunction

    //! runtextmacro Scope("SelectionGroup")
        globals
            private group SelectionGroup_ENUM_GROUP
            private group array SelectionGroup_SHIP
        endglobals

        function CreateSelectionGroup takes player whichPlayer returns group
            local group newGroup = CreateGroupWJ()
            local group sourceGroup = SelectionGroup_SHIP[GetPlayerId(whichPlayer)]
            local unit enumUnit = FirstOfGroup( sourceGroup )
            if ( enumUnit != null ) then
                loop
                    call GroupRemoveUnit( sourceGroup, enumUnit )
                    call GroupAddUnit( SelectionGroup_ENUM_GROUP, enumUnit )
                    call GroupAddUnit( newGroup, enumUnit )
                    set enumUnit = FirstOfGroup( sourceGroup )
                    exitwhen ( enumUnit == null )
                endloop
                set enumUnit = FirstOfGroup( SelectionGroup_ENUM_GROUP )
                loop
                    call GroupRemoveUnit( SelectionGroup_ENUM_GROUP, enumUnit )
                    call GroupAddUnit( sourceGroup, enumUnit )
                    set enumUnit = FirstOfGroup( SelectionGroup_ENUM_GROUP )
                    exitwhen ( enumUnit == null )
                endloop
            endif
            set sourceGroup = null
            set TEMP_GROUP = newGroup
            set newGroup = null
            return TEMP_GROUP
        endfunction

        public function SelectionGroup_Deselect takes player whichPlayer, unit whichUnit returns nothing
            call GroupRemoveUnit(SelectionGroup_SHIP[GetPlayerId(whichPlayer)], whichUnit)
        endfunction

        public function SelectionGroup_Select takes player whichPlayer, unit whichUnit returns nothing
            call GroupAddUnit(SelectionGroup_SHIP[GetPlayerId(whichPlayer)], whichUnit)
        endfunction

        public function SelectionGroup_Init takes nothing returns nothing
            local integer iteration = MAX_PLAYER_INDEX
            set SelectionGroup_ENUM_GROUP = CreateGroupWJ()
            loop
                set SelectionGroup_SHIP[iteration] = CreateGroupWJ()
                set iteration = iteration - 1
                exitwhen (iteration < 0)
            endloop
        endfunction
    //! runtextmacro Endscope()

    function AddUnitTeamSight takes Unit whichUnit returns nothing
        local real sightRange = GetUnitSightRange( whichUnit )
        local unit whichUnitSelf = whichUnit.self
        local integer whichUnitTeam = GetPlayerTeam( whichUnit.owner )
        local integer iteration = CountTeamPlayersAlive(whichUnitTeam)
        local real x = GetUnitX( whichUnitSelf )
        local real y = GetUnitY( whichUnitSelf )
        set whichUnitSelf = null
        loop
            exitwhen ( iteration < 0 )
            call FogModifierStart(CreateFogModifierCircleWJ( GetTeamPlayersAlive(whichUnitTeam, iteration), FOG_OF_WAR_VISIBLE, x, y, sightRange, false, false ))
            set iteration = iteration - 1
        endloop
    endfunction

    function AddUnitAllSight takes Unit whichUnit returns nothing
        local integer iteration = MAX_PLAYER_INDEX
        local real sightRange = GetUnitSightRange( whichUnit )
        local player specificPlayer
        local unit whichUnitSelf = whichUnit.self
        local real x = GetUnitX( whichUnitSelf )
        local real y = GetUnitY( whichUnitSelf )
        set whichUnitSelf = null
        loop
            set specificPlayer = PlayerWJ(iteration)
            if (IsPlayerDead(specificPlayer) == false) then
                call FogModifierStart(CreateFogModifierCircleWJ( specificPlayer, FOG_OF_WAR_VISIBLE, x, y, sightRange, false, false ))
            endif
            set iteration = iteration - 1
            exitwhen ( iteration < 0 )
        endloop
        set specificPlayer = null
    endfunction

    function GetTimeString takes integer count returns string
        local integer devidedCount
        local integer iteration
        local string result
        if ( count >= 86400 ) then
            return "--- Water's Footman Wars ---"
        endif
        set iteration = 1
        set result = ""
        loop
            exitwhen ( iteration > 3 )
            if ( iteration != 1 ) then
                set result = ":" + result
            endif
            set devidedCount = ( count - ( count / PowI( 60, iteration ) ) * PowI( 60, iteration ) ) / PowI( 60, iteration - 1 )
            if ( devidedCount < 10 ) then
                set result = "0" + I2S( devidedCount ) + result
            else
                set result = I2S( devidedCount ) + result
            endif
            set iteration = iteration + 1
        endloop
        return result
    endfunction

    function GetPlayerGoldCost takes integer goldCost, player whichPlayer returns integer
        if (whichPlayer != null) then
            if ( CashDiscount_ON[GetPlayerTeam( whichPlayer )] ) then
                return R2I( goldCost * CashDiscount_GOLD_COST_FACTOR )
            endif
        endif
        return goldCost
    endfunction

    function GetObjectGoldCost takes player sourceOwner, integer someObjectId returns integer
        local ItemType someItemType = GetItemTypeWJ(someObjectId)
        local UnitType someUnitType
        local ResearchType someResearchType
        if (someItemType != NULL) then
            return GetItemTypeGoldCost(someItemType)
        endif
        set someUnitType = GetUnitType(someObjectId)
        if (someUnitType != NULL) then
            return GetUnitTypeGoldCost(someUnitType)
        endif
        set someResearchType = GetResearchType(someObjectId)
        if (someResearchType != NULL) then
            return GetResearchTypeGoldCost(someResearchType, GetPlayerTechCount(sourceOwner, someObjectId, true) + 1)
        endif
        return 0
    endfunction

    function StringIf takes string s, boolean b returns string
        if (b) then
            return s
        endif
        return null
    endfunction

    function StringIfElse takes string s, string s2, boolean b returns string
        if (b) then
            return s
        endif
        return s2
    endfunction

    //! textmacro StringSetIf takes variable, setValue, flag
        if ($flag$) then
            set $variable$ = $setValue$
        endif
    //! endtextmacro

    //! runtextmacro Scope("AbilityRequiredResearch")
        function CountRequiredResearchAbilities takes integer whichResearchTypeId returns integer
            return CountIntegersInTableById( whichResearchTypeId, AbilityRequiredResearch_SCOPE_ID )
        endfunction

        function GetRequiredResearchAbility takes integer whichResearchTypeId, integer index returns integer
            return GetIntegerFromTableById( whichResearchTypeId, AbilityRequiredResearch_SCOPE_ID, index )
        endfunction

        function GetAbilityRequiredResearch takes integer whichAbility returns integer
            return GetAttachedIntegerById( whichAbility, AbilityRequiredResearch_SCOPE_ID )
        endfunction

        function SetAbilityRequiredResearch takes integer whichAbility, integer whichResearchTypeId returns nothing
            call AttachIntegerById( whichAbility, AbilityRequiredResearch_SCOPE_ID, whichResearchTypeId )
            call AddIntegerToTableById( whichResearchTypeId, AbilityRequiredResearch_SCOPE_ID, whichAbility )
        endfunction
    //! runtextmacro Endscope()

    function IsPointInPlayRegion takes real targetX, real targetY returns boolean
        if (GetTerrainCliffLevel( targetX, targetY ) != STANDARD_CLIFF_LEVEL) then
            if (IsPointInRect(targetX, targetY, CENTER_RECT) == false) then
                return false
            endif
        endif
        return true
    endfunction

    public function Init takes nothing returns nothing
        call Altar_Altar_Init()
        call SelectionGroup_SelectionGroup_Init()
        call Terrain_Terrain_Init()
    endfunction
//! runtextmacro Endscope()