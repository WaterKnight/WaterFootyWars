//TESH.scrollpos=8
//TESH.alwaysfold=0
//! runtextmacro Scope("Drop")
    globals
        private integer HERO_KILL_MESSAGES_COUNT = -1
        private string array HERO_KILL_MESSAGES_FIRST_PART
        private string array HERO_KILL_MESSAGES_MIDDLE_PART
        private string array HERO_KILL_MESSAGES_LAST_PART
        private boolean array HERO_KILL_MESSAGES_INVERTED
    endglobals

    public function Death takes boolean deathCausedByEnemy, Unit dyingUnit, player dyingUnitOwner, UnitType dyingUnitType, real dyingUnitX, real dyingUnitY, real dyingUnitZ, Unit killingUnit, player killingUnitOwner, integer killingUnitTeam returns nothing
        local integer drop
        local texttag dropTextTag
        local integer iteration
        local integer random
        local player specificPlayer
        if ( deathCausedByEnemy ) then
            set drop = GetAttackDrop( killingUnit, dyingUnit, dyingUnitType )
            if ( IsUnitType(dyingUnit.self, UNIT_TYPE_HERO) ) then
                set random = GetRandomInt( 0, HERO_KILL_MESSAGES_COUNT )
                if (HERO_KILL_MESSAGES_INVERTED[random]) then
                    call DisplayTextTimedWJ( HERO_KILL_MESSAGES_FIRST_PART[random] + GetPlayerColorString( dyingUnitOwner ) + GetPlayerName(dyingUnitOwner) + ColorStrings_RESET + HERO_KILL_MESSAGES_MIDDLE_PART[random] + GetPlayerColorString( killingUnitOwner ) + GetPlayerName(killingUnitOwner) + ColorStrings_RESET + HERO_KILL_MESSAGES_LAST_PART[random], 15, GetLocalPlayer() )
                else
                    call DisplayTextTimedWJ( HERO_KILL_MESSAGES_FIRST_PART[random] + GetPlayerColorString( killingUnitOwner ) + GetPlayerName(killingUnitOwner) + ColorStrings_RESET + HERO_KILL_MESSAGES_MIDDLE_PART[random] + GetPlayerColorString( dyingUnitOwner ) + GetPlayerName(dyingUnitOwner) + ColorStrings_RESET + HERO_KILL_MESSAGES_LAST_PART[random], 15, GetLocalPlayer() )
                endif
            endif
            call SetPlayerState( dyingUnitOwner, PLAYER_STATE_GIVES_BOUNTY, 1 )
            if ( drop == GetUnitDrop( dyingUnit ) ) then
                call Infoboard_Additionboard_Additionboard_Drop(killingUnitOwner, drop)
            else
                set dyingUnitZ = dyingUnitZ + GetUnitOutpactZ( dyingUnit )
                if ( drop > 0 ) then
                    if ( GetUnitAbilityLevel( killingUnit.self, SHARED_CONTROL_SPELL_ID ) > 0 ) then
                        set iteration = CountTeamPlayersAlive(killingUnitTeam)
                        if (iteration > -1) then
                            set drop = drop / (iteration + 1)
                            loop
                                set specificPlayer = GetTeamPlayersAlive(killingUnitTeam, iteration)
                                call AddPlayerState( specificPlayer, PLAYER_STATE_RESOURCE_GOLD, drop )
                                call Infoboard_Additionboard_Additionboard_Drop(specificPlayer, drop)
                                set dropTextTag = CreateRisingTextTag( "+" + I2S( drop ), 0.024, dyingUnitX, dyingUnitY, dyingUnitZ, 80, 255, 204, 0, 255, 0, 3 )
                                if ( dropTextTag != null ) then
                                    call LimitTextTagVisibilityToPlayer( dropTextTag, specificPlayer )
                                    set dropTextTag = null
                                endif
                                set iteration = iteration - 1
                                exitwhen ( iteration < 0 )
                            endloop
                        endif
                    else
                        call AddPlayerState( killingUnitOwner, PLAYER_STATE_RESOURCE_GOLD, drop )
                        call Infoboard_Additionboard_Additionboard_Drop(killingUnitOwner, drop)
                        set dropTextTag = CreateRisingTextTag( "+" + I2S( drop ), 0.024, dyingUnitX, dyingUnitY, dyingUnitZ, 80, 255, 204, 0, 255, 0, 3 )
                        if ( dropTextTag != null ) then
                            call LimitTextTagVisibilityToPlayer( dropTextTag, killingUnitOwner )
                            set dropTextTag = null
                        endif
                    endif
                endif
            endif
        endif
        set specificPlayer = null
    endfunction

    private function AddHeroKillMessage takes string firstPart, string middlePart, string lastPart, boolean inverted returns nothing
        set HERO_KILL_MESSAGES_COUNT = HERO_KILL_MESSAGES_COUNT + 1
        set HERO_KILL_MESSAGES_FIRST_PART[HERO_KILL_MESSAGES_COUNT] = firstPart
        set HERO_KILL_MESSAGES_MIDDLE_PART[HERO_KILL_MESSAGES_COUNT] = middlePart
        set HERO_KILL_MESSAGES_LAST_PART[HERO_KILL_MESSAGES_COUNT] = lastPart
        set HERO_KILL_MESSAGES_INVERTED[HERO_KILL_MESSAGES_COUNT] = inverted
    endfunction

    public function Init takes nothing returns nothing
        call AddHeroKillMessage("", " got smashed by ", "", true)
        call AddHeroKillMessage("", " made ", " kiss the ground.", false)
        call AddHeroKillMessage("", " used falcon punch against ", "", false)
        call AddHeroKillMessage("", " could not read the situation ", " created", true)
        call AddHeroKillMessage("", "'s fate was sealed by ", "", true)
        call AddHeroKillMessage("", " was garbage-collected by ", "", true)
        call AddHeroKillMessage("", " was too imba for ", "", false)
        call AddHeroKillMessage("", " divided ", " by zero", false)
        call AddHeroKillMessage("", " has been squashed to fit into a can because of ", "", true)
        call AddHeroKillMessage("", " now sees ", " from the worm's-eye view", true)
        call AddHeroKillMessage("", " was just too much to begin with for ", "", false)
        call AddHeroKillMessage("", " toasted ", "", false)
    endfunction
//! runtextmacro Endscope()