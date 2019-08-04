//TESH.scrollpos=0
//TESH.alwaysfold=0
scope PlayerDeselectsUnit
    globals
        private trigger DUMMY_TRIGGER
    endglobals

    private function TriggerEvents_Static takes player triggerPlayer, Unit triggerUnit returns nothing
        local unit triggerUnitSelf = triggerUnit.self
        call MasterWizard_Deselect( triggerPlayer, triggerUnit )
        //call TownHall_Deselect(triggerPlayer, triggerUnit)

        call Miscellaneous_Altar_Altar_Deselect( triggerPlayer, triggerUnit )
        call Miscellaneous_SelectionGroup_SelectionGroup_Deselect( triggerPlayer, triggerUnitSelf )
        set triggerUnitSelf = null
    endfunction

    private function Trig takes nothing returns nothing
        local player triggerPlayer = GetTriggerPlayer()
        local integer triggerPlayerId = GetPlayerId(triggerPlayer)
        local Unit triggerUnit = GetUnit(GetTriggerUnit())

        call TriggerEvents_Static(triggerPlayer, triggerUnit)

        set triggerPlayer = null
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = MAX_PLAYER_INDEX
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
        loop
            call TriggerRegisterPlayerUnitEvent( DUMMY_TRIGGER, PlayerWJ( iteration ), EVENT_PLAYER_UNIT_DESELECTED, null )
            set iteration = iteration - 1
            exitwhen ( iteration < 0 )
        endloop
    endfunction
endscope