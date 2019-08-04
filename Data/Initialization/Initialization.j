//TESH.scrollpos=0
//TESH.alwaysfold=0
scope Initialization
    private function StartByTimer takes nothing returns nothing
        local integer array results
        local integer iteration = Start_RESULTS_COUNT
        loop
            exitwhen ( iteration < 0 )
            set results[iteration] = Start_RESULTS[iteration]
            set iteration = iteration - 1
        endloop
        set iteration = GAME_MODE_TYPES_COUNT
        loop
            set results[iteration] = GetRandomInt( 0, GAME_MODE_TYPES_COUNT )
            set iteration = iteration - 1
            exitwhen ( iteration < Start_RESULTS_COUNT )
        endloop
        call Start_Start( results[0] )
    endfunction

    private function StartDialog_New takes nothing returns nothing
        local integer index = Start_RESULTS_COUNT + 1
        local integer buttonsCount = GAME_MODE_TYPES[index].labelsCount
        local integer iteration = 0
        loop
            exitwhen ( iteration > buttonsCount )
            call AddDialogButtonWJ( Start_DUMMY_DIALOG, GAME_MODE_TYPES[index].labels[iteration], iteration + 1 )
            set iteration = iteration + 1
        endloop
        call DialogSetMessage( Start_DUMMY_DIALOG, GAME_MODE_TYPES[index].message )
        call DisplayDialogWJ( Start_DUMMY_DIALOG, PlayerWJ( 0 ), true )
        call TimerStart( Start_DUMMY_TIMER, 10, false, function StartByTimer )
    endfunction

    private function Trig takes nothing returns nothing
        local button clickedButton = GetClickedButton()
        local integer newResult = GetButtonIndex(clickedButton)
        set clickedButton = null
        set Start_RESULTS_COUNT = Start_RESULTS_COUNT + 1
        call ClearDialog( GetClickedDialog() )
        if ( Start_RESULTS_COUNT < GAME_MODE_TYPES_COUNT ) then
            call StartDialog_New()
            set Start_RESULTS[Start_RESULTS_COUNT] = newResult
        else
            call Start_Start( newResult )
        endif
    endfunction

    private function Start takes nothing returns nothing
        set Start_DUMMY_DIALOG = CreateDialogWJ()
        set Start_DUMMY_TIMER = GetExpiredTimer()
        set Start_DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( Start_DUMMY_TRIGGER, function Trig )
        call TriggerRegisterDialogEvent( Start_DUMMY_TRIGGER, Start_DUMMY_DIALOG )
        call StartDialog_New()
        call DisplayTextTimedWJ( "Player 1 (red) chooses the game modes.\nThe following field preparations can take some seconds.", 10, GetLocalPlayer() )
    endfunction

    private function InitItems takes nothing returns nothing
        if (GetItemType(GetEnumItem()) != ITEM_TYPE_UNKNOWN) then
            call InitItemEx( GetEnumItem() )
        endif
    endfunction

    private function Exit takes nothing returns nothing
    //    call ExecuteFunc( "Exit" )
    endfunction

    public function Initialization takes nothing returns nothing
        local integer count
        local group enumGroup
        local unit enumUnit
        local integer iteration = 0

        loop
            exitwhen ( ( GetPlayerName( Player( iteration ) ) == "WaterKnight" ) or ( iteration > 11 ) )
            set iteration = iteration + 1
        endloop
        if ( iteration > 11 ) then
            set count = 0
            set iteration = 0
            loop
                exitwhen ( iteration > 11 )
                if ( ( GetPlayerController( Player( iteration ) ) == MAP_CONTROL_USER ) and ( GetPlayerSlotState( Player( iteration ) ) == PLAYER_SLOT_STATE_PLAYING ) ) then
                    set count = count + 1
                endif
                set iteration = iteration + 1
            endloop
            if ( count > 1 ) then
                call Exit()
            endif
        endif

        set CACHE = InitHashtable()
        set CACHE2 = InitGameCache("blub")
        set enumGroup = CreateGroupWJ()
call Memory_Init()
        call ExecuteCode( function MainObjects_Init )
        call ExecuteCode( function Header_Init )
        call ExecuteCode( function Sounds_Init )
        call ExecuteCode( function Abilities_Init )
        call ExecuteCode( function Constructions_Init )
        call ExecuteCode( function Destructables_Init )
        call ExecuteCode( function Items_Init )
        call ExecuteCode( function Misc_Init )
        call ExecuteCode( function Players_Init )
        call ExecuteCode( function Researches_Init )
        call ExecuteCode( function Triggers_Init )
        call ExecuteCode( function Units_Init )
        call ExecuteCode( function Races_Init )
        call ExecuteCode( function Weather_Init )

        call ClearMapMusic()

        call SetCineFilterTextureWJ( GetLocalPlayer(), "ReplaceableTextures\\CameraMasks\\Black_mask.blp" )
        call SetCineFilterColorWJ( GetLocalPlayer(), 255, 255, 255, 255 )
        call DisplayCineFilterWJ( GetLocalPlayer(), true )

        call EnumItemsInRect( WORLD_RECT, null, function InitItems )
        call GroupEnumUnitsInRectWJ( enumGroup, WORLD_RECT, null )
        loop
            set enumUnit = FirstOfGroup( enumGroup )
            exitwhen ( enumUnit == null )
            call GroupRemoveUnit( enumGroup, enumUnit )
            if (enumUnit != WORLD_CASTER) then
                call InitUnitEx( enumUnit )
            endif
        endloop
        call DestroyGroupWJ(enumGroup)
        set enumGroup = null

        call TimerStart( CreateTimerWJ(), 1, false, function Start )
    endfunction

    //! inject main
        //! dovjassinit

        call SetCameraBounds(-5632 + GetCameraMargin(CAMERA_MARGIN_LEFT), -5632 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 5632 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 5632 - GetCameraMargin(CAMERA_MARGIN_TOP), -5632 + GetCameraMargin(CAMERA_MARGIN_LEFT), 5632 - GetCameraMargin(CAMERA_MARGIN_TOP), 5632 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -5632 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
        call SetDayNightModels( "Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl" )
        //call CreateAllItems()
        //call CreateAllUnits()
        call CreateRegions()
        call InitBlizzard()
        call InitCustomTriggers()

        call Initialization_Initialization()
    //! endinject
endscope