//TESH.scrollpos=0
//TESH.alwaysfold=0
scope UnitBeginsUpgrading
    globals
        public trigger DUMMY_TRIGGER
    endglobals

    private function TriggerEvents_Static takes integer goldCost, Unit triggerUnit, player triggerUnitOwner, UnitType triggerUnitType returns nothing
        //call TownHall_UpgradeStart( goldCost, triggerUnit, triggerUnitType )
    endfunction

    private function Trig takes nothing returns nothing
        local string errorMsg = null
        local unit triggerUnitSelf = GetTriggerUnit()
        local Unit triggerUnit = GetUnit(triggerUnitSelf)
        local player triggerUnitOwner = triggerUnit.owner
        local UnitType triggerUnitType = GetUnitType(GetUnitTypeId(triggerUnitSelf))
        local integer goldCost = GetPlayerGoldCost(GetUnitTypeGoldCost( triggerUnitType ), triggerUnitOwner)
        if ( goldCost > GetPlayerState( triggerUnitOwner, PLAYER_STATE_RESOURCE_GOLD ) ) then
            set errorMsg = ErrorStrings_TOO_LESS_GOLD
        endif
        if ( errorMsg == null ) then
            call AddPlayerState( triggerUnitOwner, PLAYER_STATE_RESOURCE_GOLD, -goldCost )
            if ( IsUnitTypeUpgradesInstantly(triggerUnitType) ) then
                call UnitSetUpgradeProgress( triggerUnitSelf, 100 )
            else
                call Upgrade_Start(triggerUnit, goldCost)
            endif
            call AddUnitGoldSpentInUpgrades(triggerUnit, goldCost)

            call TriggerEvents_Static(goldCost, triggerUnit, triggerUnitOwner, triggerUnitType)
        else
            set UnitCancelsUpgrading_IGNORE_NEXT = true
            call StopUnit( triggerUnit )
            call Error( triggerUnitOwner, errorMsg )
        endif
        set triggerUnitOwner = null
        set triggerUnitSelf = null
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope