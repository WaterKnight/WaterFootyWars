//TESH.scrollpos=5
//TESH.alwaysfold=0
scope UnitFinishesReviving
    globals
        public trigger DUMMY_TRIGGER
        //! runtextmacro CreateEventKey("", "", "true")

        Unit REVIVING_UNIT
    endglobals

    private function TriggerEvents_Dynamic takes integer priority, Unit revivingUnit returns nothing
        local integer iteration = CountEventsById( revivingUnit, UnitFinishesReviving_EVENT_KEY, priority )
        loop
            exitwhen ( iteration < TABLE_STARTED )
            set REVIVING_UNIT = revivingUnit
            call RunTrigger( GetEventsById( revivingUnit, UnitFinishesReviving_EVENT_KEY, priority, iteration ) )
            set iteration = iteration - 1
        endloop
    endfunction

    private function TriggerEvents_Static takes integer priority, Unit revivingUnit, player revivingUnitOwner, integer revivingUnitType returns nothing
        if (priority == 0) then
            //! runtextmacro AddEventStaticLine("LifeArmor", "EVENT_REVIVE", "Revive( revivingUnit )")
            //! runtextmacro AddEventStaticLine("RhythmicDrum", "EVENT_REVIVE", "Revive( revivingUnit )")
            ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //! runtextmacro AddEventStaticLine("ChillyPresence", "EVENT_REVIVE", "Revive( revivingUnit )")
            //! runtextmacro AddEventStaticLine("CourageAndHonor", "EVENT_REVIVE", "Revive( revivingUnit )")
            //! runtextmacro AddEventStaticLine("EnergyGap_Aura_Aura", "EVENT_REVIVE", "Revive( revivingUnit )")
            //! runtextmacro AddEventStaticLine("Libertine", "EVENT_REVIVE", "Revive( revivingUnit )")
            //! runtextmacro AddEventStaticLine("MagicalSuperiority", "EVENT_REVIVE", "Revive( revivingUnit )")
            //! runtextmacro AddEventStaticLine("Sales", "EVENT_REVIVE", "Revive( revivingUnit )")
            //! runtextmacro AddEventStaticLine("UnholyArmor", "EVENT_REVIVE", "Revive( revivingUnit )")
        endif
    endfunction

    private function TriggerEvents takes Unit revivingUnit, player revivingUnitOwner, integer revivingUnitType returns nothing
        local integer iteration = 0

        loop
            call TriggerEvents_Dynamic(iteration, revivingUnit)
            call TriggerEvents_Static(iteration, revivingUnit, revivingUnitOwner, revivingUnitType)
            set iteration = iteration + 1
            exitwhen (iteration > 0)
        endloop
    endfunction

    private function Trig takes nothing returns nothing
        local unit revivingUnitSelf = GetRevivingUnit()
        local Unit revivingUnit = GetUnit(revivingUnitSelf)
        local player revivingUnitOwner = revivingUnit.owner
        local integer revivingUnitTeam = GetPlayerTeam( revivingUnitOwner )
        local UnitType revivingUnitType = revivingUnit.type
        call SetUnitDead(revivingUnit, false)
        call UnitIsActivated_Start( revivingUnit )

        call TriggerEvents(revivingUnit, revivingUnitOwner, revivingUnitType)

        call UnitIsActivated_Start(revivingUnit)

        set revivingUnitOwner = null
        set revivingUnitSelf = null
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope