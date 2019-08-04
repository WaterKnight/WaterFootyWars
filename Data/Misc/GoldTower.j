//TESH.scrollpos=138
//TESH.alwaysfold=0
//! runtextmacro Scope("GoldTower")
    globals
        private constant integer BONUS_GOLD = 3
        private constant real RELEASE_TIME = 75.
        private timer RELEASE_TIMER
        private constant real TIME_SCALE = 60 / RELEASE_TIME
        private Unit array TOWERS
        private integer TOWERS_COUNT
    endglobals

    private struct Data
        Unit tower
        real x
        real y
    endstruct

    public function Death takes boolean deathCausedByEnemy, Unit tower, Unit killingUnit returns nothing
        local integer towerId = tower.id
        local Data d = GetAttachedIntegerById( towerId, GoldTower_SCOPE_ID )
        local player killingUnitOwner
        local integer killingUnitTeam
        local player towerOwner
        local integer towerTeam
        if ( d != NULL ) then
            set killingUnitOwner = killingUnit.owner
            set killingUnitTeam = GetPlayerTeam(killingUnitOwner)
            set towerOwner = tower.owner
            set towerTeam = GetPlayerTeam(towerOwner)
            call FlushAttachedIntegerById( towerId, GoldTower_SCOPE_ID )
            if ( towerOwner != NEUTRAL_AGGRESSIVE_PLAYER ) then
                call RemoveSavedIntegerFromTable( SCOPE_PREFIX, I2S(towerTeam), d )
            endif
            if ( deathCausedByEnemy and ( killingUnitOwner != NEUTRAL_AGGRESSIVE_PLAYER ) ) then
                set towerOwner = GetTeamPlayers(killingUnitTeam, 0)
            else
                set towerOwner = NEUTRAL_AGGRESSIVE_PLAYER
            endif
            set killingUnitOwner = null
            //! runtextmacro RemoveEventById( "towerId", "EVENT_DEATH" )
            set tower = CreateUnitEx( towerOwner, GOLD_TOWER_UNIT_ID, d.x, d.y, STANDARD_ANGLE )
            set towerOwner = null
            set towerId = tower.id
            set d.tower = tower
            if ( deathCausedByEnemy ) then
                call AddSavedIntegerToTable( SCOPE_PREFIX, I2S(killingUnitTeam), tower )
            endif
            call AttachIntegerById( towerId, GoldTower_SCOPE_ID, d )
            //! runtextmacro AddEventById( "towerId", "EVENT_DEATH" )
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( IsUnitEnemy(KILLING_UNIT.self, DYING_UNIT.owner), DYING_UNIT, KILLING_UNIT )
    endfunction

    public function ExtraGold takes integer whichTeam returns integer
        local Data d
        local texttag dropTextTag
        local integer iteration = CountSavedIntegersInTable( SCOPE_PREFIX, I2S(whichTeam) ) - 1
        local integer bonusGold = ( iteration + 1 ) * BONUS_GOLD
        local Unit tower
        local unit towerSelf
        local real x
        local real y
        loop
            exitwhen ( iteration < 0 )
            set d = GetSavedIntegerFromTable( SCOPE_PREFIX, I2S(whichTeam), iteration )
            set tower = d.tower
            set towerSelf = tower.self
            set x = d.x
            set y = d.y
            set dropTextTag = CreateRisingTextTag( "+" + I2S( BONUS_GOLD ), 0.023, x, y, GetUnitZ( towerSelf, x, y ) + GetUnitOutpactZ(tower), 80, 255, 204, 0, 255, 0, 3 )
            if ( dropTextTag != null ) then
                call LimitTextTagVisibilityToTeam( dropTextTag, whichTeam )
            endif
            set iteration = iteration - 1
        endloop
        set dropTextTag = null
        set towerSelf = null
        return bonusGold
    endfunction

    //! runtextmacro Scope("Release")
        public function Release_Ending takes nothing returns nothing
            local integer iteration = TOWERS_COUNT
            local integer iteration2
            local real sightRange = GetUnitTypeSightRange( GetUnitType(GOLD_TOWER_UNIT_ID) ) - 65
            local Unit tower
            local unit towerSelf
            call DestroyTimerWJ( RELEASE_TIMER )
            set RELEASE_TIMER = null
            loop
                set iteration2 = MAX_PLAYER_INDEX
                set tower = TOWERS[iteration]
                set towerSelf = tower.self
                call SetUnitInvulnerable( towerSelf, false )
                call SetUnitTimeScale( towerSelf, 1 )
                call SetUnitAnimationByIndex( towerSelf, 1 )
                call AddUnitSightRange( tower, sightRange )
                loop
                    call UnitShareVision( towerSelf, PlayerWJ( iteration2 ), false )
                    set iteration2 = iteration2 + 1
                    exitwhen ( iteration2 < 0 )
                endloop
                set iteration = iteration - 1
                exitwhen ( iteration < 0 )
            endloop
            set towerSelf = null
            call DisplayTextTimedWJ( ColorStrings_GOLD + "The Gold Towers are set up on their positions now. Occupied towers grant an extra income.", 30, GetLocalPlayer() )
        endfunction

        public function Release_Start takes real sightRange, Unit tower returns nothing
            local integer iteration = MAX_PLAYER_INDEX
            local unit towerSelf = tower.self
            call SetUnitInvulnerable( towerSelf, true )
            call AddUnitSightRange( tower, sightRange )
            loop
                call UnitShareVision( towerSelf, PlayerWJ( iteration ), true )
                set iteration = iteration - 1
                exitwhen ( iteration < 0 )
            endloop
            call SetUnitAnimationByIndex( towerSelf, 0 )
            call SetUnitTimeScale( towerSelf, TIME_SCALE )
            set towerSelf = null
        endfunction
    //! runtextmacro Endscope()

    private function StartTower takes real sightRange, real x, real y returns nothing
        local Data d
        local Unit tower
        local integer towerId
        set tower = CreateUnitEx( NEUTRAL_AGGRESSIVE_PLAYER, GOLD_TOWER_UNIT_ID, x, y, STANDARD_ANGLE )
        set towerId = tower.id
        set d.tower = tower
        set d.x = x
        set d.y = y
        set TOWERS_COUNT = TOWERS_COUNT + 1
        set TOWERS[TOWERS_COUNT] = tower
        call AttachIntegerById( towerId, GoldTower_SCOPE_ID, d )
        //! runtextmacro AddEventById( "towerId", "EVENT_DEATH" )
        call Release_Release_Start(sightRange, tower)
    endfunction

    public function Start takes nothing returns nothing
        local real angle
        local real centerTower2Angle
        local real difference2
        local real differenceX = GetRectCenterX( gg_rct_GoldTower ) - CENTER_X
        local real differenceY = GetRectCenterY( gg_rct_GoldTower ) - CENTER_Y
        local real difference = SquareRoot( differenceX * differenceX + differenceY * differenceY )
        local real centerTowerAngle = Atan2( differenceY, differenceX )
        local integer iteration = 0
        local real sightRange = -(GetUnitTypeSightRange( GetUnitType(GOLD_TOWER_UNIT_ID) ) - 65)
        local real x
        local real y
        set differenceX = GetRectCenterX( gg_rct_GoldTower2 ) - CENTER_X
        set differenceY = GetRectCenterY( gg_rct_GoldTower2 ) - CENTER_Y
        set centerTower2Angle = Atan2( differenceY, differenceX )
        set difference2 = SquareRoot( differenceX * differenceX + differenceY * differenceY )
        loop
            set angle = centerTowerAngle + iteration * PI / 2
            call StartTower(sightRange, CENTER_X + difference * Cos( angle ), CENTER_Y + difference * Sin( angle ))
            set angle = centerTower2Angle + iteration * PI / 2
            call StartTower(sightRange, CENTER_X + difference2 * Cos( angle ), CENTER_Y + difference2 * Sin( angle ))
            set iteration = iteration + 1
            exitwhen ( iteration > 3 )
        endloop
        call TimerStart( RELEASE_TIMER, RELEASE_TIME, false, function Release_Release_Ending )
    endfunction

    public function Init takes nothing returns nothing
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "1", "function Death_Event" )
        set RELEASE_TIMER = CreateTimerWJ()
    endfunction
//! runtextmacro Endscope()