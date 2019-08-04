//TESH.scrollpos=18
//TESH.alwaysfold=0
scope UnitFinishesCasting
    globals
        public trigger DUMMY_TRIGGER
    endglobals

    private function TriggerEvents_Dynamic takes Unit caster, integer priority, integer skill, real targetX, real targetY returns nothing
        local integer iteration = CountEventsById( skill, UnitFinishesCasting_EVENT_KEY, priority )
        loop
            exitwhen ( iteration < TABLE_STARTED )
            set CASTER = caster
            set SKILL = skill
            set TARGET_X = targetX
            set TARGET_Y = targetY
            call RunTrigger( GetEventsById(skill, UnitFinishesCasting_EVENT_KEY, priority, iteration ) )
            set iteration = iteration - 1
        endloop
    endfunction

    private function TriggerEvents_Static takes Unit caster, integer priority, integer skill, real targetX, real targetY returns nothing
        local unit casterSelf = caster.self
        if (priority == 0) then
            if (false) then
            endif
            //! runtextmacro AddEventConditionalStaticLine("AirPassage", "EVENT_ENDCAST", "EndCast( caster, targetX, targetY )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Barrage", "EVENT_ENDCAST", "EndCast( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("BondOfSouls", "EVENT_ENDCAST", "EndCast( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Burrow", "EVENT_ENDCAST", "EndCast( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("FieryBoots", "EVENT_ACTIVATION_ENDCAST", "Activation_EndCast( caster )", "skill", "ACTIVATION_SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("FieryBoots", "EVENT_DEACTIVATION_ENDCAST", "Deactivation_EndCast( caster )", "skill", "DEACTIVATION_SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("LastGrave", "EVENT_ENDCAST", "EndCast( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("LifeDrain", "EVENT_ENDCAST", "EndCast( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("LightOfPurge", "EVENT_ENDCAST", "EndCast( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("LittleThunderstorm", "EVENT_ENDCAST", "EndCast( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("MagicalLariat", "EVENT_ENDCAST", "EndCast( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Meditation", "EVENT_ENDCAST", "EndCast( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Payday", "EVENT_ENDCAST", "EndCast( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("RefillMana", "EVENT_ENDCAST", "EndCast( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("SelfHeal", "EVENT_ENDCAST", "EndCast( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Suicide", "EVENT_ENDCAST", "EndCast( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("TownPortal", "EVENT_ENDCAST", "EndCast( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("WonderSeeds", "EVENT_ENDCAST", "EndCast( caster )", "skill", "SPELL_ID")
            if (false) then
            endif
        endif
        set casterSelf = null
    endfunction

    private function TriggerEvents takes Unit caster, integer skill, real targetX, real targetY returns nothing
        local integer iteration = 0

        loop
            call TriggerEvents_Dynamic(caster, iteration, skill, targetX, targetY)
            call TriggerEvents_Static(caster, iteration, skill, targetX, targetY)
            set iteration = iteration + 1
            exitwhen (iteration > 0)
        endloop
    endfunction

    private function Trig takes nothing returns nothing
        local Unit caster = GetUnit(GetSpellAbilityUnit())
        local unit casterSelf = caster.self
        local integer skill = GetSpellAbilityId()
        local real targetX = TARGET_X
        local real targetY = TARGET_Y

        if (GetUnitAbilityLevel(casterSelf, INSTANT_CAST_BUFF_ID) > 0) then
            call UnitRemoveAbility(casterSelf, INSTANT_CAST_BUFF_ID)
        endif
        set casterSelf = null

        call TriggerEvents(caster, skill, targetX, targetY)
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope