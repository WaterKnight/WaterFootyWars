//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("MasterWizard")
    globals
        public constant real BONUS_MANA_PER_KILL = 10.
        Unit array MASTER_WIZARDS
    endglobals

    private struct MasterWizard_Data
        player array playersSelecting[MAX_PLAYERS_AMOUNT]
        integer playersSelectingCount
        force ship
        integer team
        boolean used
    endstruct

    public function Death takes Unit killingUnit, player killingUnitOwner returns nothing
        local integer killingUnitTeam
        local texttag newTextTag
        local Unit wizard
        local unit wizardSelf
        local real wizardX
        local real wizardY
        if (killingUnit != null) then
            if (GetPlayerId(killingUnitOwner) <= MAX_PLAYER_INDEX) then
                if (IsUnitType(killingUnit.self, UNIT_TYPE_SUMMONED) == false) then
                    set killingUnitTeam = GetPlayerTeam( killingUnitOwner )
                    set wizard = MASTER_WIZARDS[killingUnitTeam]
                    set wizardSelf = wizard.self
                    set wizardX = GetUnitX(wizardSelf)
                    set wizardY = GetUnitY(wizardSelf)
                    set newTextTag = CreateRisingTextTag( "+" + I2S( R2I( BONUS_MANA_PER_KILL ) ), 0.024, wizardX, wizardY, GetUnitZ( wizardSelf, wizardX, wizardY ) + GetUnitOutpactZ(wizard), 80, 0, 0, 255, 255, 0, 3 )
                    if ( newTextTag != null ) then
                        call LimitTextTagVisibilityToTeam( newTextTag, killingUnitTeam )
                    endif
                    set newTextTag = null
                    call AddUnitState( wizardSelf, UNIT_STATE_MANA, BONUS_MANA_PER_KILL )
                    set wizardSelf = null
                endif
            endif
        endif
    endfunction

    public function Deselect takes player whichPlayer, Unit wizard returns nothing
        local MasterWizard_Data d
        local integer iteration
        local integer playersSelectingCount
        local force ship
        if ( wizard.type.id == MASTER_WIZARD_UNIT_ID ) then
            set d = GetAttachedIntegerById(wizard.id, MasterWizard_SCOPE_ID)
            if ( GetPlayerTeam( whichPlayer ) == d.team ) then
                set playersSelectingCount = d.playersSelectingCount
                set iteration = playersSelectingCount
                if ( whichPlayer == d.playersSelecting[0] ) then
                    if ( playersSelectingCount == 0 ) then
                        call SetUnitColor( wizard.self, NEUTRAL_PASSIVE_PLAYER_COLOR )
                    else
                        call SetUnitOwnerEx( wizard, d.playersSelecting[1], true )
                    endif
                endif
                loop
                    exitwhen (d.playersSelecting[iteration] == whichPlayer)
                    set iteration = iteration - 1
                endloop
                set d.playersSelecting[iteration] = d.playersSelecting[playersSelectingCount]
                set d.playersSelectingCount = playersSelectingCount - 1
                call ForceRemovePlayer(d.ship, whichPlayer)
            endif
        endif
    endfunction

    public function Select takes player whichPlayer, Unit wizard returns nothing
        local MasterWizard_Data d
        local integer playersSelectingCount
        local force ship
        if ( wizard.type.id == MASTER_WIZARD_UNIT_ID ) then
            set d = GetAttachedIntegerById(wizard.id, MasterWizard_SCOPE_ID)
            if ( GetPlayerTeam( whichPlayer ) == d.team ) then
                set ship = d.ship
                if ( IsPlayerInForce(whichPlayer, ship) == false ) then
                    set playersSelectingCount = d.playersSelectingCount + 1
                    if ( playersSelectingCount == 0 ) then
                        call SetUnitOwnerEx( wizard, whichPlayer, true )
                    endif
                    set d.playersSelecting[playersSelectingCount] = whichPlayer
                    set d.playersSelectingCount = playersSelectingCount
                    call ForceAddPlayer(ship, whichPlayer)
                endif
                set ship = null
            endif
        endif
    endfunction

    public function Start takes integer team, Unit wizard returns nothing
        local MasterWizard_Data d = MasterWizard_Data.create()
        set d.playersSelectingCount = -1
        set d.ship = CreateForce()
        set d.team = team
        set MASTER_WIZARDS[team] = wizard
        call AttachIntegerById(wizard.id, MasterWizard_SCOPE_ID, d)
        call SetUnitColor( wizard.self, NEUTRAL_PASSIVE_PLAYER_COLOR )
        call AddUnitAllSight( wizard )
    endfunction
//! runtextmacro Endscope()