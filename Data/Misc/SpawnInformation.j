//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("SpawnInformation")
    globals
        private constant real TIME = 10.
    endglobals

    public function Chat takes string chatMessage, player whichPlayer returns nothing
        local integer spawnsAmount
        local real spawnTimeBasic
        local real spawnTimeIncrementRelative
        local integer SpawnTimer
        local integer SpawnUnitTypeId
        set chatMessage = StringCase( chatMessage, false )
        if ( chatMessage == "-si" ) then
            set SpawnTimer = GetAttachedInteger( TriggerPlayer, "SpawnTimer" )
            set SpawnUnitTypeId = GetAttachedInteger( SpawnTimer, "UnitTypeId" )
            if ( spawnUnitTypeId == null ) then
                call DisplayTextTimedWJ( "You do not train units at the moment.", TIME, whichPlayer )
            else
                set spawnsAmount = GetAttachedInteger( TriggerPlayer, "SpawnsAmount" )
                set spawnTimeBasic = GetAttachedReal( SpawnUnitTypeId, "SpawnTime" ) + GetAttachedReal( TriggerPlayer, "SpawnTime" + I2S( SpawnUnitTypeId ) )
                set spawnTimeIncrementRelative = spawnsAmount * Spawn_TIME_FACTOR
                call DisplayTextTimedToPlayer( "Currently, you form units of the type " + ColorStrings_GOLD + GetObjectName( spawnUnitTypeId ) + ColorStrings_RESET + " with a spawning time of " + ColorStrings_GOLD + R2S( spawnTimeBasic * ( 1 + spawnTimeIncrementRelative ) ) + ColorStrings_RESET + " (exclusive 'Advanced Training').\nThat value lies " + ColorStrings_GOLD + I2S( R2I( RoundTo( spawnTimeIncrementRelative * 100, 1 ) ) ) + ColorStrings_RESET + " percent over the basic level (" + ColorStrings_GOLD + R2S( spawnTimeBasic ) + ColorStrings_RESET + " (inclusive 'Mass Production' if researched)) since you command " + ColorStrings_GOLD + I2S( spawnsAmount ) + ColorStrings_RESET + " spawn unit(s).", TIME, triggerPlayer )
            endif
        endif
    endfunction
//! runtextmacro Endscope()