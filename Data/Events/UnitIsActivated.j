//TESH.scrollpos=9
//TESH.alwaysfold=0
scope UnitIsActivated
    globals
        private trigger DUMMY_TRIGGER
    endglobals

    private function TriggerEvents_Dynamic takes integer priority, Unit triggerUnit, integer triggerUnitTeam returns nothing
        local integer triggerUnitId = triggerUnit.id
        local string triggerUnitTeamString = GetTeamString(triggerUnitTeam)
        local integer iteration = CountSavedEvents( triggerUnitTeamString, UnitIsActivated_EVENT_STRING_KEY, priority )
        loop
            exitwhen ( iteration < TABLE_STARTED )
            set TRIGGER_UNIT = triggerUnit
            call RunTrigger( GetSavedEvents( triggerUnitTeamString, UnitIsActivated_EVENT_STRING_KEY, priority, iteration ) )
            set iteration = iteration - 1
        endloop
        set iteration = CountEventsById( triggerUnit, UnitIsActivated_EVENT_KEY, priority )
        loop
            exitwhen ( iteration < TABLE_STARTED )
            set TRIGGER_UNIT = triggerUnit
            call RunTrigger( GetEventsById( triggerUnit, UnitIsActivated_EVENT_KEY, priority, iteration ) )
            set iteration = iteration - 1
        endloop
    endfunction

    private function TriggerEvents_Static takes integer priority, Unit triggerUnit, integer triggerUnitTeam returns nothing
        if (priority == 0) then
            //! runtextmacro AddEventStaticLine("DivineShield", "EVENT_ACTIVATE", "Activate( triggerUnit, triggerUnitTeam )")
            //! runtextmacro AddEventStaticLine("Grass", "EVENT_ACTIVATE", "Activate( triggerUnit )")
            //! runtextmacro AddEventStaticLine("Marble", "EVENT_ACTIVATE", "Activate( triggerUnit )")
        endif
    endfunction

    private function TriggerEvents takes Unit triggerUnit, integer triggerUnitTeam returns nothing
        local integer iteration = 0

        loop
            call TriggerEvents_Dynamic(iteration, triggerUnit, triggerUnitTeam)
            call TriggerEvents_Static(iteration, triggerUnit, triggerUnitTeam)
            set iteration = iteration + 1
            exitwhen (iteration > 0)
        endloop
    endfunction

    public function Start takes Unit triggerUnit returns nothing
        call TriggerEvents(triggerUnit, GetPlayerTeam(triggerUnit.owner))
    endfunction

    private function Trig takes nothing returns nothing
        local Unit triggerUnit = TRIGGER_UNIT

        call Start(triggerUnit)
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope