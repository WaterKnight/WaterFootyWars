//TESH.scrollpos=0
//TESH.alwaysfold=0
scope UnitFinishesDecaying
    globals
        public trigger DUMMY_TRIGGER
    endglobals

    scope End
        private function End_TriggerEvents_Dynamic takes integer priority, Unit triggerUnit returns nothing
            local integer triggerUnitId = triggerUnit.id
            local integer iteration = CountEventsById( triggerUnitId, UnitFinishesDecaying_End_End_EVENT_KEY, priority )
            loop
                exitwhen ( iteration < TABLE_STARTED )
                set TRIGGER_UNIT = triggerUnit
                call RunTrigger( GetEventsById( triggerUnitId, UnitFinishesDecaying_End_End_EVENT_KEY, priority, iteration ) )
                set iteration = iteration - 1
            endloop
        endfunction

        private function End_TriggerEvents_Static takes integer priority, Unit triggerUnit returns nothing
            if (priority == 0) then
                //! runtextmacro AddEventStaticLine("IllusionaryStaff", "EVENT_DECAY_END", "DecayEnd( triggerUnit )")
                //! runtextmacro AddEventStaticLine("Lens", "EVENT_DECAY_END", "DecayEnd( triggerUnit )")

                //! runtextmacro AddEventStaticLine("AttackDerivation", "EVENT_DECAY_END", "DecayEnd( triggerUnit )")
                //! runtextmacro AddEventStaticLine("Disarm", "EVENT_DECAY_END", "DecayEnd( triggerUnit )")
                //! runtextmacro AddEventStaticLine("DiversionShot", "EVENT_DECAY_END", "DecayEnd( triggerUnit )")
                //! runtextmacro AddEventStaticLine("Feedback", "EVENT_DECAY_END", "DecayEnd( triggerUnit )")
                //! runtextmacro AddEventStaticLine("LightningAttack", "EVENT_DECAY_END", "DecayEnd( triggerUnit )")
                //! runtextmacro AddEventStaticLine("MysticalAttack", "EVENT_DECAY_END", "DecayEnd( triggerUnit )")
                //! runtextmacro AddEventStaticLine("Neutralization", "EVENT_DECAY_END", "DecayEnd( triggerUnit )")
                //! runtextmacro AddEventStaticLine("Pulverize", "EVENT_DECAY_END", "DecayEnd( triggerUnit )")
                //! runtextmacro AddEventStaticLine("SlowPoison", "EVENT_DECAY_END", "DecayEnd( triggerUnit )")
                //! runtextmacro AddEventStaticLine("StrongArm", "EVENT_DECAY_END", "DecayEnd( triggerUnit )")
            endif
        endfunction

        private function End_TriggerEvents takes Unit triggerUnit returns nothing
            local integer iteration = 0

            loop
                call End_TriggerEvents_Dynamic(iteration, triggerUnit)
                call End_TriggerEvents_Static(iteration, triggerUnit)
                set iteration = iteration + 1
                exitwhen (iteration > 0)
            endloop
        endfunction

        public function End_Start takes Unit triggerUnit returns nothing
            local unit triggerUnitSelf = triggerUnit.self

            call End_TriggerEvents(triggerUnit)

            if ( GetUnitRemainingReferences( triggerUnit ) > 0 ) then
                set triggerUnit.waitsForRemoval = true
            else
                call triggerUnit.destroy()
                call RemoveUnitWJ( triggerUnitSelf )
            endif
            set triggerUnitSelf = null
        endfunction
    endscope

    private function TriggerEvents_Dynamic takes integer priority, Unit triggerUnit returns nothing
        local integer triggerUnitId = triggerUnit.id
        local integer iteration = CountEventsById( triggerUnitId, EVENT_KEY, priority )
        loop
            exitwhen ( iteration < TABLE_STARTED )
            set TRIGGER_UNIT = triggerUnit
            call RunTrigger( GetEventsById( triggerUnitId, EVENT_KEY, priority, iteration ) )
            set iteration = iteration - 1
        endloop
    endfunction

    private function TriggerEvents_Static takes integer priority, Unit triggerUnit returns nothing
        if (priority == 0) then
            //! runtextmacro AddEventStaticLine("FriendshipBracelet", "EVENT_DECAY", "Decay(triggerUnit)")
            //! runtextmacro AddEventStaticLine("Reincarnation", "EVENT_DECAY", "Decay(triggerUnit)")
            ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //! runtextmacro AddEventStaticLine("Unit_RemoveUnit_TimedEx_TimedEx", "EVENT_DECAY", "Decay(triggerUnit)")
            //! runtextmacro AddEventStaticLine("Unit_Scale_Timed_Timed", "EVENT_DECAY", "Decay(triggerUnit)")
            //! runtextmacro AddEventStaticLine("Unit_VertexColor_Timed_Timed", "EVENT_DECAY", "Decay(triggerUnit)")
            ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //! runtextmacro AddEventStaticLine("CripplingWave", "EVENT_DECAY", "Decay(triggerUnit)")
        endif
    endfunction

    private function TriggerEvents takes Unit triggerUnit returns nothing
        local integer iteration = 0

        loop
            call TriggerEvents_Dynamic(iteration, triggerUnit)
            call TriggerEvents_Static(iteration, triggerUnit)
            set iteration = iteration + 1
            exitwhen (iteration > 0)
        endloop
    endfunction

    private function Trig takes nothing returns nothing
        local Unit triggerUnit = TRIGGER_UNIT
        local player triggerUnitOwner = triggerUnit.owner
        local unit triggerUnitSelf = triggerUnit.self

        call GroupRemoveUnit( ALL_GROUP, triggerUnitSelf )

        call ClearUnitRequestQueue(triggerUnit)
        if ( IsUnitType(triggerUnitSelf, UNIT_TYPE_STRUCTURE) ) then
            call SetUnitSupplyProduced( triggerUnit, triggerUnitOwner, 0 )
        endif
        call SetUnitSupplyUsed( triggerUnit, triggerUnitOwner, 0 )

        if (IsUnitDead(triggerUnit) == false) then
            call UnitDies_Decay(triggerUnit, triggerUnitOwner)
        endif

        call TriggerEvents(triggerUnit)

        call End_End_Start(triggerUnit)

        set triggerUnitOwner = null
        set triggerUnitSelf = null
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope