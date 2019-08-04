//TESH.scrollpos=129
//TESH.alwaysfold=0
scope PlayerDies
    globals
        public trigger DUMMY_TRIGGER
        private group ENUM_GROUP
        private boolean GAME_OVER = false
        private constant real GAME_OVER_DELAY = 5.
        private boolexpr TARGET_CONDITIONS
    endglobals

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        set FILTER_UNIT = GetUnit(FILTER_UNIT_SELF)
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( FILTER_UNIT.owner != TEMP_PLAYER ) then
            return false
        endif
        if (FILTER_UNIT.type.id == POISONED_FOUNTAIN_UNIT_ID) then
            return false
        endif
        return true
    endfunction

    private function Pause takes nothing returns nothing
        call PauseGame(true)
    endfunction

    private function Trig takes nothing returns nothing
        local integer alliances
        local integer count
        local integer count2
        local integer distributedGold
        local Unit enumUnit
        local unit enumUnitSelf
        local UnitType enumUnitType
        local boolean isAnyAllianceAlive
        local integer iteration
        local integer iteration2
        local player specificPlayer
        local player whichPlayer = TRIGGER_PLAYER
        local integer whichPlayerAlliance
        local integer whichPlayerTeam
        if ( IsPlayerDead(whichPlayer) == false ) then
            set alliances = CountAlliances()
            set count = 0
            set count2 = 0
            set isAnyAllianceAlive = false
            set iteration = MAX_PLAYER_INDEX
            set whichPlayerAlliance = GetPlayerAllianceWJ( whichPlayer )
            set whichPlayerTeam = GetPlayerTeam( whichPlayer )
            call DisplayTextTimedWJ( GetPlayerColorString(whichPlayer) + GetPlayerName( whichPlayer ) + "|r has been defeated.", 10, GetLocalPlayer() )
            call RemoveTeamPlayersAlive(whichPlayerTeam, whichPlayer)
            call SetPlayerDead(whichPlayer, true)
            loop
                set specificPlayer = PlayerWJ( iteration )
                if ( IsPlayerDead(specificPlayer) == false ) then
                    set isAnyAllianceAlive = true
                    if ( GetPlayerAllianceWJ( specificPlayer ) == whichPlayerAlliance ) then
                        set count = count + 1
                        if ( GetPlayerTeam( specificPlayer ) == whichPlayerTeam ) then
                            set count2 = count2 + 1
                        endif
                        call SetPlayerAlliance( whichPlayer, specificPlayer, ALLIANCE_SHARED_VISION, false )
                        call SetPlayerAlliance( specificPlayer, whichPlayer, ALLIANCE_SHARED_VISION, false )
                    endif
                endif
                set iteration = iteration - 1
                exitwhen ( iteration < 0 )
            endloop
            if ( isAnyAllianceAlive == false ) then
                set GAME_OVER = true
            elseif ( count == 0 ) then
                call DisplayTextTimedWJ( ColorStrings_RED + "Alliance " + I2S( whichPlayerAlliance + 1 ) + " has lost." + ColorStrings_RESET, 10, GetLocalPlayer() )
                set iteration = 0
                loop
                    if ( whichPlayerAlliance != iteration ) then
                        set count = 0
                        set iteration2 = MAX_PLAYER_INDEX
                        loop
                            if ( ( GetPlayerAllianceWJ( PlayerWJ( iteration2 ) ) == iteration ) and ( IsPlayerDead(PlayerWJ(iteration2)) == false ) ) then
                                set count = count + 1
                            endif
                            set iteration2 = iteration2 - 1
                            exitwhen ( iteration2 < 0 )
                        endloop
                        if ( count > 0 ) then
                            set count = 0
                            set iteration2 = MAX_PLAYER_INDEX
                            loop
                                if ( ( GetPlayerAllianceWJ( PlayerWJ( iteration2 ) ) != iteration ) and ( IsPlayerDead(PlayerWJ(iteration2) ) == false ) ) then
                                    set count = count + 1
                                endif
                                set iteration2 = iteration2 - 1
                                exitwhen ( iteration2 < 0 )
                            endloop
                            if ( count == 0 ) then
                                set GAME_OVER = true
                                call DisplayTextTimedWJ( ColorStrings_GREEN + "Alliance " + I2S( iteration + 1 ) + " was victorious." + ColorStrings_RESET, 10, GetLocalPlayer() )
                                set iteration2 = CountAlliancePlayers(iteration)
                                loop
                                    set specificPlayer = GetAlliancePlayer(iteration, iteration2)
                                    set TEMP_PLAYER = specificPlayer
                                    call GroupEnumUnitsInRectWJ( ENUM_GROUP, PLAY_RECT, TARGET_CONDITIONS )
                                    set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
                                    loop
                                        call GroupRemoveUnit(ENUM_GROUP, enumUnitSelf)
                                        call SetUnitAnimation(enumUnitSelf, "victory")
                                        set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
                                        exitwhen (enumUnitSelf == null)
                                    endloop
                                    set iteration2 = iteration2 - 1
                                    exitwhen ( iteration2 < 0 )
                                endloop
                            endif
                        endif
                    endif
                    set iteration = iteration + 1
                    exitwhen ( ( iteration > alliances ) or GAME_OVER )
                endloop
            endif
            if (GAME_OVER) then
                call TimerStart(CreateTimerWJ(), GAME_OVER_DELAY, false, function Pause)
            endif
            set specificPlayer = null
            call SetPlayerRaceWJ(whichPlayer, 0)
            set TEMP_PLAYER = whichPlayer
            call GroupEnumUnitsInRectWJ( ENUM_GROUP, PLAY_RECT, TARGET_CONDITIONS )
            set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
            if (enumUnitSelf != null) then
                loop
                    set enumUnit = GetUnit(enumUnitSelf)
                    set enumUnitType = enumUnit.type
                    call GroupRemoveUnit( ENUM_GROUP, enumUnitSelf )
                    if ( IsUnitTypeAltar(enumUnitType) ) then
                        call Miscellaneous_Altar_Altar_Ending( enumUnit )
                    else
                        if ( IsUnitTypeShared(enumUnitType) and IsUnitType( enumUnitSelf, UNIT_TYPE_STRUCTURE ) ) then
                            call PauseUnit( enumUnitSelf, true )
                        else
                            call UnitRemoveAbility(enumUnitSelf, Reincarnation_SPELL_ID)
                            call KillUnit( enumUnitSelf )
                        endif
                    endif
                    set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
                    exitwhen ( enumUnitSelf == null )
                endloop
            endif
            call FogModifierStart( CreateFogModifierRectWJ( whichPlayer, FOG_OF_WAR_VISIBLE, PLAY_RECT, true, false ) )
            set iteration = CountTeamPlayersAlive(whichPlayerTeam)
            call SetPlayerState( whichPlayer, PLAYER_STATE_RESOURCE_LUMBER, 0 )
            if ( iteration > 0 ) then
                set distributedGold = GetPlayerState( whichPlayer, PLAYER_STATE_RESOURCE_GOLD ) / iteration
                set iteration = iteration - 1
                loop
                    exitwhen ( iteration < 0 )
                    call AddPlayerState( GetTeamPlayersAlive(whichPlayerTeam, iteration), PLAYER_STATE_RESOURCE_GOLD, distributedGold )
                    set iteration = iteration - 1
                endloop
            endif
        endif
        set whichPlayer = null
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        set ENUM_GROUP = CreateGroupWJ()
        set TARGET_CONDITIONS = ConditionWJ(function TargetConditions)
        call AddTriggerCode(DUMMY_TRIGGER, function Trig)
    endfunction
endscope