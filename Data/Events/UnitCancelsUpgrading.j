//TESH.scrollpos=1
//TESH.alwaysfold=0
scope UnitCancelsUpgrading
    globals
        public trigger DUMMY_TRIGGER
        public boolean IGNORE_NEXT = false
        private constant real GOLD_RESTORATION_FACTOR = 1.
    endglobals

    private function TriggerEvents_Static takes integer goldCost, Unit triggerUnit, UnitType triggerUnitType returns nothing
        //call TownHall_UpgradeCancel( goldCost, triggerUnit, triggerUnitType )
    endfunction

    private function Trig takes nothing returns nothing
        local integer goldCost
        local Unit triggerUnit
        local player triggerUnitOwner
        local UnitType triggerUnitType
        if ( IGNORE_NEXT ) then
            set IGNORE_NEXT = false
        else
            set triggerUnit = GetUnit(GetTriggerUnit())
            set goldCost = GetUnitCurrentUpgradeGoldCost(triggerUnit)
            set triggerUnitOwner = triggerUnit.owner
            set triggerUnitType = triggerUnit.type
            call AddPlayerState( triggerUnitOwner, PLAYER_STATE_RESOURCE_GOLD, R2I( goldCost * GOLD_RESTORATION_FACTOR ) )
            call AddUnitGoldSpentInUpgrades(triggerUnit, -goldCost)
            call Upgrade_Remove( triggerUnit )
            call SetUnitScaleWJ( triggerUnit.self, GetUnitScale( triggerUnit ) )

            call TriggerEvents_Static(goldCost, triggerUnit, triggerUnitType)

            set triggerUnitOwner = null
        endif
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope