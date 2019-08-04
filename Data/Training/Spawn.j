//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("Spawn")
    public function Death takes player spawnOwner, UnitType spawnType returns nothing
        local Unit rax
        if ( IsUnitTypeSpawn(spawnType) ) then
            set rax = GetPlayerTownHall(spawnOwner)
            if (rax != NULL) then
                call Miscellaneous_Spawn_Spawn_StartByDeath( rax, spawnOwner )
            endif
        endif
    endfunction

    public function FinishTraining takes Unit rax, unit spawn, player spawnOwner, UnitType spawnType, integer spawnTypeId returns nothing
        if ( IsUnitTypeSpawn(spawnType) ) then
            call RemoveUnitWJ( spawn )
            call Miscellaneous_Spawn_Spawn_Start( rax, spawnTypeId, spawnOwner )
        endif
    endfunction
//! runtextmacro Endscope()