//TESH.scrollpos=310
//TESH.alwaysfold=0
//! runtextmacro Scope("Infoboard")
    globals
        constant real MULTIBOARD_GAP_WIDTH = 0.001

        private constant real CHECK_INTERVAL = 0.035
        public integer COUNT = 0
        private constant integer HEAD_ROW = 0
        multiboard INFOBOARD
        private constant integer COLOR_COLUMN = 0
        private constant integer NAME_COLUMN = 1

        private constant real HEROES_COLUMN_WIDTH = 0.04
        private constant integer HEROES_START_GAP = 2
        private constant integer HEROES_LEVEL_COLUMN = 3
        private constant integer HEROES_COLUMN = 4
        private constant integer HEROES_MIDDLE_GAP = 5
        private constant integer HEROES2_LEVEL_COLUMN = 6
        private constant integer HEROES2_COLUMN = 7
        private constant integer HEROES_END_GAP = 8

        private constant integer KILLS_COLUMN = 9
        private constant integer DEATHS_COLUMN = 10

        private integer array DEATHS
        private integer array HERO_DEATHS
        private integer array HERO_KILLS
        private integer array KILLS
        private boolean MULTIBOARD_MINIMIZED
        private integer MULTIBOARD_STAGE
        private integer array PLAYERS_POSITION
        private boolean STARTED = false
    endglobals

    private struct Data
        integer column
    endstruct

    //! runtextmacro Scope("Additionboard")
        globals
            multiboard ADDBOARD
            private constant integer Additionboard_HEAD_ROW = 0
            private constant integer Additionboard_HEAD_ROW2 = 1
            private constant integer Additionboard_NAME_COLUMN = 0
            private constant integer Additionboard_GOLD_EARNED_COLUMN = 1
            private constant integer Additionboard_COINS_COLUMN = 2
            private constant integer Additionboard_ITEMS_PERMANENT_COLUMN = 3
            private constant integer Additionboard_ITEMS_CONSUMABLE_COLUMN = 4
            private constant integer Additionboard_MERCS_COLUMN = 5
            private constant integer Additionboard_RESEARCHES_COLUMN = 6

            private integer array Additionboard_GOLD_EARNED
            private integer array Additionboard_COINS
            private integer array Additionboard_COINS_GOLD
            private integer array Additionboard_ITEMS_PERMANENT
            private integer array Additionboard_ITEMS_CONSUMABLE
            private integer array Additionboard_MERCS
            private integer array Additionboard_RESEARCHES
            private integer array Additionboard_PLAYERS_POSITION
        endglobals

        public function Additionboard_Coin takes player whichPlayer, integer amount returns nothing
            local integer whichPlayerId = GetPlayerId(whichPlayer)
            local integer pos = Additionboard_PLAYERS_POSITION[whichPlayerId]
            if (pos != -1) then
                set Additionboard_COINS[whichPlayerId] = Additionboard_COINS[whichPlayerId] + 1
                set Additionboard_COINS_GOLD[whichPlayerId] = Additionboard_COINS_GOLD[whichPlayerId] + amount
                call SetMultiboardCellValue( ADDBOARD, Additionboard_COINS_COLUMN, pos, I2S(Additionboard_COINS[whichPlayerId]) + " (" + I2S(Additionboard_COINS_GOLD[whichPlayerId]) + ")" )
            endif
        endfunction

        public function Additionboard_Drop takes player whichPlayer, integer amount returns nothing
            local integer whichPlayerId = GetPlayerId(whichPlayer)
            local integer pos = Additionboard_PLAYERS_POSITION[whichPlayerId]
            if (pos != -1) then
                set Additionboard_GOLD_EARNED[whichPlayerId] = Additionboard_GOLD_EARNED[whichPlayerId] + amount
                call SetMultiboardCellValue( ADDBOARD, Additionboard_GOLD_EARNED_COLUMN, pos, I2S(Additionboard_GOLD_EARNED[whichPlayerId]) )
            endif
        endfunction

        public function Additionboard_ResearchFinish takes player whichPlayer returns nothing
            local integer whichPlayerId = GetPlayerId(whichPlayer)
            local integer pos = Additionboard_PLAYERS_POSITION[whichPlayerId]
            if (pos != -1) then
                set Additionboard_RESEARCHES[whichPlayerId] = Additionboard_RESEARCHES[whichPlayerId] + 1
                call SetMultiboardCellValue( ADDBOARD, Additionboard_RESEARCHES_COLUMN, pos, I2S(Additionboard_RESEARCHES[whichPlayerId]) )
            endif
        endfunction

        public function Additionboard_SellItemExecute takes player whichPlayer, item whichItem returns nothing
            local integer whichPlayerId = GetPlayerId(whichPlayer)
            local integer pos = Additionboard_PLAYERS_POSITION[whichPlayerId]
            if (pos != -1) then
                if (GetItemType(whichItem) == ITEM_TYPE_PERMANENT) then
                    set Additionboard_ITEMS_PERMANENT[whichPlayerId] = Additionboard_ITEMS_PERMANENT[whichPlayerId] + 1
                    call SetMultiboardCellValue( ADDBOARD, Additionboard_ITEMS_PERMANENT_COLUMN, pos, I2S(Additionboard_ITEMS_PERMANENT[whichPlayerId]) )
                elseif (GetItemType(whichItem) == ITEM_TYPE_CHARGED) then
                    set Additionboard_ITEMS_CONSUMABLE[whichPlayerId] = Additionboard_ITEMS_CONSUMABLE[whichPlayerId] + 1
                    call SetMultiboardCellValue( ADDBOARD, Additionboard_ITEMS_CONSUMABLE_COLUMN, pos, I2S(Additionboard_ITEMS_CONSUMABLE[whichPlayerId]) )
                endif
            endif
        endfunction

        public function Additionboard_SellUnitExecute takes player whichPlayer returns nothing
            local integer whichPlayerId = GetPlayerId(whichPlayer)
            local integer pos = Additionboard_PLAYERS_POSITION[whichPlayerId]
            if (pos != -1) then
                set Additionboard_MERCS[whichPlayerId] = Additionboard_MERCS[whichPlayerId] + 1
                call SetMultiboardCellValue( ADDBOARD, Additionboard_MERCS_COLUMN, pos, I2S(Additionboard_MERCS[whichPlayerId]) )
            endif
        endfunction

        private function Additionboard_CheckDisplay takes nothing returns nothing
            if (IsMultiboardMinimized(ADDBOARD)) then
                set MULTIBOARD_MINIMIZED = true
            else
                if (MULTIBOARD_MINIMIZED and (MULTIBOARD_STAGE == 1)) then
                    set MULTIBOARD_MINIMIZED = false
                    set MULTIBOARD_STAGE = 0
                    call DisplayMultiboard( ADDBOARD, GetLocalPlayer(), false )
                    call DisplayMultiboard( INFOBOARD, GetLocalPlayer(), true )
                endif
            endif
        endfunction

        public function Additionboard_Start takes nothing returns nothing
            local integer count = 2
            local integer iteration = MAX_PLAYER_INDEX
            local player specificPlayer
            set ADDBOARD = CreateMultiboardWJ()
            call MultiboardSetRowCount( ADDBOARD, 2 )
            call MultiboardSetColumnCount( ADDBOARD, 7 )
            call SetMultiboardCellStyle( ADDBOARD, Additionboard_NAME_COLUMN, Additionboard_HEAD_ROW, true, false )
            call SetMultiboardCellStyle( ADDBOARD, Additionboard_NAME_COLUMN, Additionboard_HEAD_ROW2, true, false )
            call SetMultiboardCellStyle( ADDBOARD, Additionboard_GOLD_EARNED_COLUMN, Additionboard_HEAD_ROW, true, false )
            call SetMultiboardCellStyle( ADDBOARD, Additionboard_GOLD_EARNED_COLUMN, Additionboard_HEAD_ROW2, true, false )
            call SetMultiboardCellStyle( ADDBOARD, Additionboard_COINS_COLUMN, Additionboard_HEAD_ROW, true, false )
            call SetMultiboardCellStyle( ADDBOARD, Additionboard_COINS_COLUMN, Additionboard_HEAD_ROW2, true, false )
            call SetMultiboardCellStyle( ADDBOARD, Additionboard_ITEMS_PERMANENT_COLUMN, Additionboard_HEAD_ROW, true, false )
            call SetMultiboardCellStyle( ADDBOARD, Additionboard_ITEMS_PERMANENT_COLUMN, Additionboard_HEAD_ROW2, true, false )
            call SetMultiboardCellStyle( ADDBOARD, Additionboard_ITEMS_CONSUMABLE_COLUMN, Additionboard_HEAD_ROW, true, false )
            call SetMultiboardCellStyle( ADDBOARD, Additionboard_ITEMS_CONSUMABLE_COLUMN, Additionboard_HEAD_ROW2, true, false )
            call SetMultiboardCellStyle( ADDBOARD, Additionboard_MERCS_COLUMN, Additionboard_HEAD_ROW, true, false )
            call SetMultiboardCellStyle( ADDBOARD, Additionboard_MERCS_COLUMN, Additionboard_HEAD_ROW2, true, false )
            call SetMultiboardCellStyle( ADDBOARD, Additionboard_RESEARCHES_COLUMN, Additionboard_HEAD_ROW, true, false )
            call SetMultiboardCellStyle( ADDBOARD, Additionboard_RESEARCHES_COLUMN, Additionboard_HEAD_ROW2, true, false )
            call SetMultiboardCellValue( ADDBOARD, Additionboard_NAME_COLUMN, Additionboard_HEAD_ROW, "Player" )
            call SetMultiboardCellValue( ADDBOARD, Additionboard_NAME_COLUMN, Additionboard_HEAD_ROW2, "name" )
            call SetMultiboardCellValue( ADDBOARD, Additionboard_GOLD_EARNED_COLUMN, Additionboard_HEAD_ROW, "Gold" )
            call SetMultiboardCellValue( ADDBOARD, Additionboard_GOLD_EARNED_COLUMN, Additionboard_HEAD_ROW2, "earned" )
            call SetMultiboardCellValue( ADDBOARD, Additionboard_COINS_COLUMN, Additionboard_HEAD_ROW, "Coins" )
            call SetMultiboardCellValue( ADDBOARD, Additionboard_COINS_COLUMN, Additionboard_HEAD_ROW2, "collected" )
            call SetMultiboardCellValue( ADDBOARD, Additionboard_ITEMS_PERMANENT_COLUMN, Additionboard_HEAD_ROW, "Items bought" )
            call SetMultiboardCellValue( ADDBOARD, Additionboard_ITEMS_PERMANENT_COLUMN, Additionboard_HEAD_ROW2, "(perm.)" )
            call SetMultiboardCellValue( ADDBOARD, Additionboard_ITEMS_CONSUMABLE_COLUMN, Additionboard_HEAD_ROW, "Items bought" )
            call SetMultiboardCellValue( ADDBOARD, Additionboard_ITEMS_CONSUMABLE_COLUMN, Additionboard_HEAD_ROW2, "(cons.)" )
            call SetMultiboardCellValue( ADDBOARD, Additionboard_MERCS_COLUMN, Additionboard_HEAD_ROW, "Mercs" )
            call SetMultiboardCellValue( ADDBOARD, Additionboard_MERCS_COLUMN, Additionboard_HEAD_ROW2, "hired" )
            call SetMultiboardCellValue( ADDBOARD, Additionboard_RESEARCHES_COLUMN, Additionboard_HEAD_ROW, "Researches" )
            call SetMultiboardCellValue( ADDBOARD, Additionboard_RESEARCHES_COLUMN, Additionboard_HEAD_ROW2, "done" )
            call SetMultiboardCellColor( ADDBOARD, Additionboard_NAME_COLUMN, Additionboard_HEAD_ROW, 255, 204, 51, 255 )
            call SetMultiboardCellColor( ADDBOARD, Additionboard_NAME_COLUMN, Additionboard_HEAD_ROW2, 255, 204, 51, 255 )
            call SetMultiboardCellColor( ADDBOARD, Additionboard_GOLD_EARNED_COLUMN, Additionboard_HEAD_ROW, 255, 204, 51, 255 )
            call SetMultiboardCellColor( ADDBOARD, Additionboard_GOLD_EARNED_COLUMN, Additionboard_HEAD_ROW2, 255, 204, 51, 255 )
            call SetMultiboardCellColor( ADDBOARD, Additionboard_COINS_COLUMN, Additionboard_HEAD_ROW, 255, 204, 51, 255 )
            call SetMultiboardCellColor( ADDBOARD, Additionboard_COINS_COLUMN, Additionboard_HEAD_ROW2, 255, 204, 51, 255 )
            call SetMultiboardCellColor( ADDBOARD, Additionboard_ITEMS_PERMANENT_COLUMN, Additionboard_HEAD_ROW, 255, 204, 51, 255 )
            call SetMultiboardCellColor( ADDBOARD, Additionboard_ITEMS_PERMANENT_COLUMN, Additionboard_HEAD_ROW2, 255, 204, 51, 255 )
            call SetMultiboardCellColor( ADDBOARD, Additionboard_ITEMS_CONSUMABLE_COLUMN, Additionboard_HEAD_ROW, 255, 204, 51, 255 )
            call SetMultiboardCellColor( ADDBOARD, Additionboard_ITEMS_CONSUMABLE_COLUMN, Additionboard_HEAD_ROW2, 255, 204, 51, 255 )
            call SetMultiboardCellColor( ADDBOARD, Additionboard_MERCS_COLUMN, Additionboard_HEAD_ROW, 255, 204, 51, 255 )
            call SetMultiboardCellColor( ADDBOARD, Additionboard_MERCS_COLUMN, Additionboard_HEAD_ROW2, 255, 204, 51, 255 )
            call SetMultiboardCellColor( ADDBOARD, Additionboard_RESEARCHES_COLUMN, Additionboard_HEAD_ROW, 255, 204, 51, 255 )
            call SetMultiboardCellColor( ADDBOARD, Additionboard_RESEARCHES_COLUMN, Additionboard_HEAD_ROW2, 255, 204, 51, 255 )
            loop
                set specificPlayer = PlayerWJ( iteration )
                if ( GetPlayerSlotState( specificPlayer ) == PLAYER_SLOT_STATE_PLAYING ) then
                    set Additionboard_COINS[iteration] = 0
                    set Additionboard_COINS_GOLD[iteration] = 0
                    set Additionboard_GOLD_EARNED[iteration] = 0
                    set Additionboard_ITEMS_PERMANENT[iteration] = 0
                    set Additionboard_ITEMS_CONSUMABLE[iteration] = 0
                    set Additionboard_MERCS[iteration] = 0
                    set Additionboard_RESEARCHES[iteration] = 0
                    set Additionboard_PLAYERS_POSITION[iteration] = count
                    call MultiboardSetRowCount( ADDBOARD, count + 1 )
                    call SetMultiboardCellStyle( ADDBOARD, Additionboard_NAME_COLUMN, count, true, false )
                    call SetMultiboardCellStyle( ADDBOARD, Additionboard_GOLD_EARNED_COLUMN, count, true, false )
                    call SetMultiboardCellStyle( ADDBOARD, Additionboard_COINS_COLUMN, count, true, false )
                    call SetMultiboardCellStyle( ADDBOARD, Additionboard_ITEMS_PERMANENT_COLUMN, count, true, false )
                    call SetMultiboardCellStyle( ADDBOARD, Additionboard_ITEMS_CONSUMABLE_COLUMN, count, true, false )
                    call SetMultiboardCellStyle( ADDBOARD, Additionboard_MERCS_COLUMN, count, true, false )
                    call SetMultiboardCellStyle( ADDBOARD, Additionboard_RESEARCHES_COLUMN, count, true, false )
                    call SetMultiboardCellValue( ADDBOARD, Additionboard_NAME_COLUMN, count, GetPlayerName( specificPlayer ) )
                    call SetMultiboardCellValue( ADDBOARD, Additionboard_GOLD_EARNED_COLUMN, count, I2S(Additionboard_GOLD_EARNED[iteration]) )
                    call SetMultiboardCellValue( ADDBOARD, Additionboard_COINS_COLUMN, count, I2S(Additionboard_COINS[iteration]) + " (" + I2S(Additionboard_COINS_GOLD[iteration]) + ")" )
                    call SetMultiboardCellValue( ADDBOARD, Additionboard_ITEMS_PERMANENT_COLUMN, count, I2S(Additionboard_ITEMS_PERMANENT[iteration]) )
                    call SetMultiboardCellValue( ADDBOARD, Additionboard_ITEMS_CONSUMABLE_COLUMN, count, I2S(Additionboard_ITEMS_CONSUMABLE[iteration]) )
                    call SetMultiboardCellValue( ADDBOARD, Additionboard_MERCS_COLUMN, count, I2S(Additionboard_MERCS[iteration]) )
                    call SetMultiboardCellValue( ADDBOARD, Additionboard_RESEARCHES_COLUMN, count, I2S(Additionboard_RESEARCHES[iteration]) )
                    call SetMultiboardCellColor( ADDBOARD, Additionboard_NAME_COLUMN, count, GetPlayerColorRed(specificPlayer), GetPlayerColorGreen(specificPlayer), GetPlayerColorBlue(specificPlayer), 255 )
                    call SetMultiboardCellColor( ADDBOARD, Additionboard_GOLD_EARNED_COLUMN, count, 255, 255, 255, 255 )
                    call SetMultiboardCellColor( ADDBOARD, Additionboard_COINS_COLUMN, count, 255, 255, 255, 255 )
                    call SetMultiboardCellColor( ADDBOARD, Additionboard_ITEMS_PERMANENT_COLUMN, count, 255, 255, 255, 255 )
                    call SetMultiboardCellColor( ADDBOARD, Additionboard_ITEMS_CONSUMABLE_COLUMN, count, 255, 255, 255, 255 )
                    call SetMultiboardCellColor( ADDBOARD, Additionboard_MERCS_COLUMN, count, 255, 255, 255, 255 )
                    call SetMultiboardCellColor( ADDBOARD, Additionboard_RESEARCHES_COLUMN, count, 255, 255, 255, 255 )
                    set count = count + 1
                else
                    set Additionboard_PLAYERS_POSITION[iteration] = -1
                endif
                set iteration = iteration - 1
                exitwhen ( iteration < 0 )
            endloop
            set Additionboard_PLAYERS_POSITION[PLAYER_NEUTRAL_AGGRESSIVE] = -1
            set Additionboard_PLAYERS_POSITION[PLAYER_NEUTRAL_PASSIVE] = -1
            call SetMultiboardColumnWidth( ADDBOARD, Additionboard_NAME_COLUMN, 0.07 )
            call SetMultiboardColumnWidth( ADDBOARD, Additionboard_GOLD_EARNED_COLUMN, 0.04 )
            call SetMultiboardColumnWidth( ADDBOARD, Additionboard_COINS_COLUMN, 0.06 )
            call SetMultiboardColumnWidth( ADDBOARD, Additionboard_ITEMS_PERMANENT_COLUMN, 0.06 )
            call SetMultiboardColumnWidth( ADDBOARD, Additionboard_ITEMS_CONSUMABLE_COLUMN, 0.06 )
            call SetMultiboardColumnWidth( ADDBOARD, Additionboard_MERCS_COLUMN, 0.05 )
            call SetMultiboardColumnWidth( ADDBOARD, Additionboard_RESEARCHES_COLUMN, 0.05 )
            call MultiboardSetTitleText( ADDBOARD, GetTimeString(COUNT) )
            call TimerStart( CreateTimerWJ(), CHECK_INTERVAL, true, function Additionboard_CheckDisplay )
        endfunction
    //! runtextmacro Endscope()

    private function Kill_Conditions takes boolean deathCausedByEnemy, boolean isDyingUnitStructure, integer killingUnitOwnerId returns boolean
        if (deathCausedByEnemy == false) then
            return false
        endif
        if ( isDyingUnitStructure ) then
            return false
        endif
        if ( PLAYERS_POSITION[killingUnitOwnerId] == -1 ) then
            return false
        endif
        return true
    endfunction

    private function Death_Conditions takes integer dyingUnitOwnerId, boolean isDyingUnitStructure returns boolean
        if ( isDyingUnitStructure ) then
            return false
        endif
        if ( PLAYERS_POSITION[dyingUnitOwnerId] == -1 ) then
            return false
        endif
        return true
    endfunction

    public function Death takes boolean deathCausedByEnemy, Unit dyingUnit, Unit killingUnit returns nothing
        local integer amount
        local integer dyingUnitOwnerId = GetPlayerId(dyingUnit.owner)
        local unit dyingUnitSelf = dyingUnit.self
        local boolean isDyingUnitStructure = IsUnitType(dyingUnitSelf, UNIT_TYPE_STRUCTURE)
        local integer killingUnitOwnerId = GetPlayerId(killingUnit.owner)
        local string text
        if ( Death_Conditions( dyingUnitOwnerId, isDyingUnitStructure ) ) then
            if (IsUnitType(dyingUnitSelf, UNIT_TYPE_HERO)) then
                set amount = HERO_DEATHS[dyingUnitOwnerId] + 1
                set HERO_DEATHS[dyingUnitOwnerId] = amount
                call SetMultiboardCellValue( INFOBOARD, DEATHS_COLUMN, PLAYERS_POSITION[dyingUnitOwnerId], I2S(DEATHS[dyingUnitOwnerId]) + " (" + I2S( amount ) + ")" )
            else
                set amount = DEATHS[dyingUnitOwnerId] + 1
                set DEATHS[dyingUnitOwnerId] = amount
                if (HERO_DEATHS[dyingUnitOwnerId] > 0) then
                    set text = I2S(amount) + " (" + I2S( HERO_DEATHS[dyingUnitOwnerId] ) + ")"
                else
                    set text = I2S(amount)
                endif
                call SetMultiboardCellValue( INFOBOARD, DEATHS_COLUMN, PLAYERS_POSITION[dyingUnitOwnerId], text )
            endif
        endif
        if ( Kill_Conditions( deathCausedByEnemy, isDyingUnitStructure, killingUnitOwnerId ) ) then
            if (IsUnitType(dyingUnitSelf, UNIT_TYPE_HERO)) then
                set amount = HERO_KILLS[killingUnitOwnerId] + 1
                set HERO_KILLS[killingUnitOwnerId] = amount
                call SetMultiboardCellValue( INFOBOARD, KILLS_COLUMN, PLAYERS_POSITION[killingUnitOwnerId], I2S(KILLS[killingUnitOwnerId]) + " (" + I2S( amount ) + ")" )
            else
                set amount = KILLS[killingUnitOwnerId] + 1
                set KILLS[killingUnitOwnerId] = amount
                if (HERO_KILLS[killingUnitOwnerId] > 0) then
                    set text = I2S(amount) + " (" + I2S( HERO_KILLS[killingUnitOwnerId] ) + ")"
                else
                    set text = I2S(amount)
                endif
                call SetMultiboardCellValue( INFOBOARD, KILLS_COLUMN, PLAYERS_POSITION[killingUnitOwnerId], text )
            endif
        endif
        set dyingUnitSelf = null
    endfunction

    public function LevelGain takes integer level, Unit whichUnit, player whichUnitOwner returns nothing
        local Data d = GetAttachedIntegerById(whichUnit.id, Infoboard_SCOPE_ID)
        if (d != NULL) then
            call SetMultiboardCellValue( INFOBOARD, d.column, PLAYERS_POSITION[GetPlayerId(whichUnitOwner)], I2S(level) )
        endif
    endfunction

    public function Appearance takes Unit whichUnit, player whichUnitOwner, UnitType whichUnitType returns nothing
        local integer column = -1
        local integer count = GetPlayerHeroCount(whichUnitOwner)
        local Data d
        local integer levelColumn
        local integer row
        if (STARTED == false) then
            return
        endif
        set row = PLAYERS_POSITION[GetPlayerId(whichUnitOwner)]
        if (count == 0) then
            set column = HEROES_COLUMN
            call SetMultiboardCellWidth( INFOBOARD, HEROES_START_GAP, row, HEROES_COLUMN_WIDTH * 4. / 16 - 3 * MULTIBOARD_GAP_WIDTH / 4 )
            call SetMultiboardCellWidth( INFOBOARD, HEROES_LEVEL_COLUMN, row, HEROES_COLUMN_WIDTH * 3. / 16 - 3 * MULTIBOARD_GAP_WIDTH / 4 )
            call SetMultiboardCellWidth( INFOBOARD, HEROES_COLUMN, row, HEROES_COLUMN_WIDTH / 4 - 3 * MULTIBOARD_GAP_WIDTH / 4 )
            call SetMultiboardCellWidth( INFOBOARD, HEROES_END_GAP, row, HEROES_COLUMN_WIDTH * 5. / 16 - 3 * MULTIBOARD_GAP_WIDTH / 4 )
        elseif (count == 1) then
            set column = HEROES2_COLUMN
            call SetMultiboardCellWidth( INFOBOARD, HEROES_START_GAP, row, HEROES_COLUMN_WIDTH / 16 - MULTIBOARD_GAP_WIDTH / 6 )
            call SetMultiboardCellWidth( INFOBOARD, HEROES_LEVEL_COLUMN, row, HEROES_COLUMN_WIDTH * 3. / 16 - MULTIBOARD_GAP_WIDTH / 6 )
            call SetMultiboardCellWidth( INFOBOARD, HEROES_COLUMN, row, HEROES_COLUMN_WIDTH / 4 - MULTIBOARD_GAP_WIDTH / 6 )
            call SetMultiboardCellWidth( INFOBOARD, HEROES2_LEVEL_COLUMN, row, HEROES_COLUMN_WIDTH * 3. / 16 - MULTIBOARD_GAP_WIDTH / 6 )
            call SetMultiboardCellWidth( INFOBOARD, HEROES2_COLUMN, row, HEROES_COLUMN_WIDTH / 4 - MULTIBOARD_GAP_WIDTH / 6 )
            call SetMultiboardCellWidth( INFOBOARD, HEROES_END_GAP, row, HEROES_COLUMN_WIDTH / 16 - MULTIBOARD_GAP_WIDTH / 6 )
        endif
        if (column != -1) then
            set levelColumn = column - 1
            set d = Data.create()
            set d.column = levelColumn
            call AttachIntegerById(whichUnit.id, Infoboard_SCOPE_ID, d)
            call SetMultiboardCellStyle( INFOBOARD, levelColumn, row, true, false )
            call SetMultiboardCellValue( INFOBOARD, levelColumn, row, I2S(GetHeroLevel(whichUnit.self)) )
            call SetMultiboardCellStyle( INFOBOARD, column, row, false, true )
            call SetMultiboardCellIcon( INFOBOARD, column, row, GetUnitTypeImage(whichUnitType) )
        endif
    endfunction

    private function CheckDisplay takes nothing returns nothing
        if (IsMultiboardMinimized(INFOBOARD) and (MULTIBOARD_STAGE == 0)) then
            set MULTIBOARD_MINIMIZED = false
            set MULTIBOARD_STAGE = 1
            call DisplayMultiboard( INFOBOARD, GetLocalPlayer(), false )
            call DisplayMultiboard( ADDBOARD, GetLocalPlayer(), true )
            call MultiboardMinimize(ADDBOARD, false)
        endif
    endfunction

    private function CountTime takes nothing returns nothing
        set COUNT = COUNT + 1
        if ( COUNT >= 86400 ) then
            call DestroyTimerWJ( GetExpiredTimer() )
        endif
        call MultiboardSetTitleText( INFOBOARD, ">> " + GetTimeString(COUNT) + " <<" )
        call MultiboardSetTitleText( ADDBOARD, ">> " + GetTimeString(COUNT) + " <<" )
    endfunction

    public function Start takes nothing returns nothing
        local integer count = 1
        local integer iteration = MAX_PLAYER_INDEX
        local player specificPlayer
        set INFOBOARD = CreateMultiboardWJ()
        set STARTED = true
        call MultiboardSetRowCount( INFOBOARD, 1 )
        call MultiboardSetColumnCount( INFOBOARD, 11 )
        call SetMultiboardCellStyle( INFOBOARD, COLOR_COLUMN, HEAD_ROW, false, false )
        call SetMultiboardCellStyle( INFOBOARD, NAME_COLUMN, HEAD_ROW, true, false )
        call SetMultiboardCellStyle( INFOBOARD, HEROES_START_GAP, HEAD_ROW, false, false )
        call SetMultiboardCellStyle( INFOBOARD, HEROES_LEVEL_COLUMN, HEAD_ROW, false, false )
        call SetMultiboardCellStyle( INFOBOARD, HEROES_COLUMN, HEAD_ROW, true, false )
        call SetMultiboardCellStyle( INFOBOARD, HEROES_MIDDLE_GAP, HEAD_ROW, false, false )
        call SetMultiboardCellStyle( INFOBOARD, HEROES2_LEVEL_COLUMN, HEAD_ROW, false, false )
        call SetMultiboardCellStyle( INFOBOARD, HEROES2_COLUMN, HEAD_ROW, false, false )
        call SetMultiboardCellStyle( INFOBOARD, HEROES_END_GAP, HEAD_ROW, false, false )
        call SetMultiboardCellStyle( INFOBOARD, KILLS_COLUMN, HEAD_ROW, true, false )
        call SetMultiboardCellStyle( INFOBOARD, DEATHS_COLUMN, HEAD_ROW, true, false )
        call SetMultiboardCellValue( INFOBOARD, NAME_COLUMN, HEAD_ROW, "Player name" )
        call SetMultiboardCellValue( INFOBOARD, HEROES_COLUMN, HEAD_ROW, "Heroes" )
        call SetMultiboardCellValue( INFOBOARD, KILLS_COLUMN, HEAD_ROW, "Kills" )
        call SetMultiboardCellValue( INFOBOARD, DEATHS_COLUMN, HEAD_ROW, "Deaths" )
        call SetMultiboardCellColor( INFOBOARD, NAME_COLUMN, HEAD_ROW, 255, 204, 51, 255 )
        call SetMultiboardCellColor( INFOBOARD, HEROES_COLUMN, HEAD_ROW, 255, 204, 51, 255 )
        call SetMultiboardCellColor( INFOBOARD, KILLS_COLUMN, HEAD_ROW, 255, 204, 51, 255 )
        call SetMultiboardCellColor( INFOBOARD, DEATHS_COLUMN, HEAD_ROW, 255, 204, 51, 255 )
        loop
            set specificPlayer = PlayerWJ( iteration )
            if ( GetPlayerSlotState( specificPlayer ) == PLAYER_SLOT_STATE_PLAYING ) then
                set DEATHS[iteration] = 0
                set HERO_DEATHS[iteration] = 0
                set HERO_KILLS[iteration] = 0
                set KILLS[iteration] = 0
                set PLAYERS_POSITION[iteration] = count
                call MultiboardSetRowCount( INFOBOARD, count + 1 )
                call SetMultiboardCellStyle( INFOBOARD, COLOR_COLUMN, count, false, true )
                call SetMultiboardCellStyle( INFOBOARD, NAME_COLUMN, count, true, false )
                call SetMultiboardCellStyle( INFOBOARD, HEROES_START_GAP, count, false, false )
                call SetMultiboardCellStyle( INFOBOARD, HEROES_LEVEL_COLUMN, count, false, false )
                call SetMultiboardCellStyle( INFOBOARD, HEROES_COLUMN, count, false, false )
                call SetMultiboardCellStyle( INFOBOARD, HEROES_MIDDLE_GAP, count, false, false )
                call SetMultiboardCellStyle( INFOBOARD, HEROES2_LEVEL_COLUMN, count, false, false )
                call SetMultiboardCellStyle( INFOBOARD, HEROES2_COLUMN, count, false, false )
                call SetMultiboardCellStyle( INFOBOARD, HEROES_END_GAP, count, false, false )
                call SetMultiboardCellStyle( INFOBOARD, KILLS_COLUMN, count, true, false )
                call SetMultiboardCellStyle( INFOBOARD, DEATHS_COLUMN, count, true, false )
                call SetMultiboardCellIcon( INFOBOARD, COLOR_COLUMN, count, GetPlayerColorImage(specificPlayer) )
                call SetMultiboardCellValue( INFOBOARD, NAME_COLUMN, count, GetPlayerName( specificPlayer ) )
                call SetMultiboardCellValue( INFOBOARD, KILLS_COLUMN, count, I2S(KILLS[iteration]) )
                call SetMultiboardCellValue( INFOBOARD, DEATHS_COLUMN, count, I2S(DEATHS[iteration]) )
                call SetMultiboardCellColor( INFOBOARD, NAME_COLUMN, count, GetPlayerColorRed(specificPlayer), GetPlayerColorGreen(specificPlayer), GetPlayerColorBlue(specificPlayer), 255 )
                call SetMultiboardCellColor( INFOBOARD, KILLS_COLUMN, count, 255, 255, 255, 255 )
                call SetMultiboardCellColor( INFOBOARD, DEATHS_COLUMN, count, 255, 255, 255, 255 )
                set count = count + 1
            else
                set PLAYERS_POSITION[iteration] = -1
            endif
            set iteration = iteration - 1
            exitwhen ( iteration < 0 )
        endloop
        set MULTIBOARD_MINIMIZED = true
        set MULTIBOARD_STAGE = 1
        set PLAYERS_POSITION[PLAYER_NEUTRAL_AGGRESSIVE] = -1
        set PLAYERS_POSITION[PLAYER_NEUTRAL_PASSIVE] = -1
        call SetMultiboardColumnWidth( INFOBOARD, COLOR_COLUMN, 0.02 )
        call SetMultiboardColumnWidth( INFOBOARD, NAME_COLUMN, 0.07 )
        call SetMultiboardColumnWidth( INFOBOARD, HEROES_START_GAP, MULTIBOARD_GAP_WIDTH )
        call SetMultiboardColumnWidth( INFOBOARD, HEROES_COLUMN, HEROES_COLUMN_WIDTH - 6 * MULTIBOARD_GAP_WIDTH )
        call SetMultiboardColumnWidth( INFOBOARD, HEROES_LEVEL_COLUMN, MULTIBOARD_GAP_WIDTH )
        call SetMultiboardColumnWidth( INFOBOARD, HEROES_MIDDLE_GAP, MULTIBOARD_GAP_WIDTH )
        call SetMultiboardColumnWidth( INFOBOARD, HEROES2_COLUMN, MULTIBOARD_GAP_WIDTH )
        call SetMultiboardColumnWidth( INFOBOARD, HEROES2_LEVEL_COLUMN, MULTIBOARD_GAP_WIDTH )
        call SetMultiboardColumnWidth( INFOBOARD, HEROES_END_GAP, MULTIBOARD_GAP_WIDTH )
        call SetMultiboardColumnWidth( INFOBOARD, KILLS_COLUMN, 0.04 )
        call SetMultiboardColumnWidth( INFOBOARD, DEATHS_COLUMN, 0.04 )
        call MultiboardSetTitleText( INFOBOARD, GetTimeString(COUNT) )
        call DisplayMultiboard( INFOBOARD, GetLocalPlayer(), true )
        call TimerStart( CreateTimerWJ(), 1, true, function CountTime )
        call TimerStart( CreateTimerWJ(), CHECK_INTERVAL, true, function CheckDisplay )
        call Additionboard_Additionboard_Start()
    endfunction
//! runtextmacro Endscope()