//TESH.scrollpos=0
//TESH.alwaysfold=0
scope UnitAcquiresTarget
    globals
        public trigger DUMMY_TRIGGER
    endglobals

    private function TriggerEvents_Dynamic takes integer priority, Unit triggerUnit returns nothing
        local integer triggerUnitId = triggerUnit.id
        local integer iteration = CountEventsById(triggerUnitId, UnitAcquiresTarget_EVENT_KEY, priority )
        loop
            exitwhen ( iteration < TABLE_STARTED )
            set TRIGGER_UNIT = triggerUnit
            call RunTrigger( GetEventsById(triggerUnitId, UnitAcquiresTarget_EVENT_KEY, priority, iteration ) )
            set iteration = iteration - 1
        endloop
    endfunction

    private function TriggerEvents_Static takes integer priority, Unit triggerUnit, player triggerUnitOwner returns nothing
        if (priority == 0) then
            //! runtextmacro AddEventStaticLine("BubbleArmor_Automatic_Automatic", "EVENT_ACQUIRE", "TargetInRange( triggerUnit, triggerUnitOwner )")
            //! runtextmacro AddEventStaticLine("Fireball_Automatic_Automatic", "EVENT_ACQUIRE", "TargetInRange( triggerUnit, triggerUnitOwner )")
            //! runtextmacro AddEventStaticLine("Fury_Automatic_Automatic", "EVENT_ACQUIRE", "TargetInRange( triggerUnit, triggerUnitOwner )")
            //! runtextmacro AddEventStaticLine("Inspiration_Automatic_Automatic", "EVENT_ACQUIRE", "TargetInRange( triggerUnit, triggerUnitOwner )")
            //! runtextmacro AddEventStaticLine("Pulverize", "EVENT_ACQUIRE", "TargetInRange( triggerUnit )")
            //! runtextmacro AddEventStaticLine("RaiseDead_Automatic_Automatic", "EVENT_ACQUIRE", "TargetInRange( triggerUnit, triggerUnitOwner )")
            //! runtextmacro AddEventStaticLine("VioletDefense_Automatic_Automatic", "EVENT_ACQUIRE", "TargetInRange( triggerUnit, triggerUnitOwner )")
        endif
    endfunction

    private function TriggerEvents takes Unit triggerUnit, player triggerUnitOwner returns nothing
        local integer iteration = 0

        loop
            call TriggerEvents_Dynamic(iteration, triggerUnit)
            call TriggerEvents_Static(iteration, triggerUnit, triggerUnitOwner)
            set iteration = iteration + 1
            exitwhen (iteration>  0)
        endloop
    endfunction

    private function Trig takes nothing returns nothing
        local unit targetSelf = GetEventTargetUnit()
        local Unit target = GetUnit(targetSelf)
        local Unit triggerUnit = GetUnit(GetTriggerUnit())
        local player triggerUnitOwner = triggerUnit.owner
        local unit triggerUnitSelf
        if ( IsUnitEnemy( targetSelf, triggerUnitOwner ) ) then
            set triggerUnitSelf = triggerUnit.self
            if (GetUnitCurrentOrder(triggerUnitSelf) == 0) then
                call IssueTargetOrderById(triggerUnitSelf, ATTACK_ORDER_ID, targetSelf)
            endif
            set triggerUnitSelf = null

            call TriggerEvents(triggerUnit, triggerUnitOwner)

        endif
        set targetSelf = null
        set triggerUnitOwner = null
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope