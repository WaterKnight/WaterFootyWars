//TESH.scrollpos=64
//TESH.alwaysfold=0
//! runtextmacro Scope("UnitRevaluation")
    globals
        private constant integer SPELL_ID = 'A078'

        private integer array KILLS_NEEDED
    endglobals

    private struct Data
        integer killsAmount
    endstruct

    public function RevaluatingUnit_Death takes Unit revaluatingUnit returns nothing
        local integer revaluatingUnitId = revaluatingUnit.id
        local Data d = GetAttachedIntegerById(revaluatingUnitId, UnitRevaluation_SCOPE_ID)
        if (d != NULL) then
            call d.destroy()
            call FlushAttachedIntegerById(revaluatingUnitId, UnitRevaluation_SCOPE_ID)
            //! runtextmacro RemoveEventById( "revaluatingUnitId", "EVENT_REVALUATION_UNIT_DEATH" )
        endif
    endfunction

    private function RevaluatingUnit_Death_Event takes nothing returns nothing
        call RevaluatingUnit_Death( DYING_UNIT )
    endfunction

    public function Revaluate takes Unit revaluatingUnit, integer level returns nothing
        local Data d = GetAttachedIntegerById(revaluatingUnit.id, UnitRevaluation_SCOPE_ID)
        if (d == NULL) then
            set d.killsAmount = KILLS_NEEDED[level]
        endif
    endfunction

    private function Source_Death_Conditions takes boolean deathCausedByEnemy, boolean isDyingUnitStructure, Unit revaluatingUnit, player revaluatingUnitOwner, UnitType revaluatingUnitType returns boolean
        set TEMP_UNIT_SELF = revaluatingUnit.self
        if ( isDyingUnitStructure ) then
            return false
        endif
        if ( deathCausedByEnemy == false ) then
            return false
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_HERO ) ) then
            return false
        endif
        if (IsUnitIllusionWJ(revaluatingUnit)) then
            return false
        endif
        if ( ( IsUnitTypeSpawn(revaluatingUnitType) == false ) and ( revaluatingUnitType.id != RESERVE_UNIT_ID ) ) then
            return false
        endif
        if ( Experience_DISABLED[GetPlayerTeam(revaluatingUnitOwner)] ) then
            return false
        endif
        return true
    endfunction

    public function Source_Death takes boolean deathCausedByEnemy, player dyingUnitOwner, boolean isDyingUnitStructure, Unit revaluatingUnit, player revaluatingUnitOwner, UnitType revaluatingUnitType returns nothing
        local Data d
        local integer killsAmount
        local integer iteration
        local integer oldLevel
        local integer revaluatingUnitId
        local integer supplyUsed
        if ( Source_Death_Conditions( deathCausedByEnemy, isDyingUnitStructure, revaluatingUnit, revaluatingUnitOwner, revaluatingUnitType ) ) then
            set supplyUsed = GetUnitSupplyUsed( revaluatingUnit )
            if ( supplyUsed > 0 ) then
                set iteration = REVALUATION_LEVELS_AMOUNT
                set revaluatingUnitId = revaluatingUnit.id
                set d = GetAttachedIntegerById(revaluatingUnitId, UnitRevaluation_SCOPE_ID)
                if (d == NULL) then
                    set d = Data.create()
                    set oldLevel = GetUnitRevaluation(revaluatingUnit)
                    if (oldLevel > 0) then
                        set killsAmount = KILLS_NEEDED[iteration] + 1
                    else
                        set killsAmount = 1
                    endif
                    call AttachIntegerById(revaluatingUnitId, UnitRevaluation_SCOPE_ID, d)
                    //! runtextmacro AddEventById( "revaluatingUnitId", "EVENT_REVALUATION_UNIT_DEATH" )
                else
                    set killsAmount = d.killsAmount + 1
                endif
                set d.killsAmount = killsAmount
                loop
                    exitwhen (killsAmount == KILLS_NEEDED[iteration])
                    set iteration = iteration - 1
                    exitwhen (iteration < 1)
                endloop
                if (iteration > 0) then
                    call SetUnitRevaluation(revaluatingUnit, iteration)
                endif
            endif
        endif
    endfunction

    public function Init takes nothing returns nothing
        //! runtextmacro CreateEvent( "EVENT_REVALUATING_UNIT_DEATH", "UnitDies_EVENT_KEY", "0", "function RevaluatingUnit_Death_Event" )
        set KILLS_NEEDED[1] = 2
        set KILLS_NEEDED[2] = 4
        call InitAbility( SPELL_ID )
    endfunction
//! runtextmacro Endscope()