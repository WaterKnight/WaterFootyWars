//TESH.scrollpos=62
//TESH.alwaysfold=0
scope UnitLearnsSkill
    globals
        public trigger DUMMY_TRIGGER

        Unit LEARNER
        integer SKILL
    endglobals

    private function TriggerEvents_Dynamic takes Unit learner, integer priority, integer skill returns nothing
        local integer iteration = CountEventsById( skill, UnitLearnsSkill_EVENT_KEY, priority )
        loop
            exitwhen ( iteration < TABLE_STARTED )
            set LEARNER = learner
            set SKILL = skill
            call RunTrigger( GetEventsById( skill, UnitLearnsSkill_EVENT_KEY, priority, iteration ) )
            set iteration = iteration - 1
        endloop
    endfunction

    public function TriggerEvents_Static takes Unit learner, player learnerOwner, UnitType learnerType, integer priority, integer skill returns nothing
        if (priority == 0) then
            if (false) then
            //! runtextmacro AddEventConditionalStaticLine("AdvancedTraining", "EVENT_LEARN", "Learn( learner, learnerType )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("AttackDerivation", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("AxeMaster", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Bash_OgreBrat_OgreBrat", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Bash_Zombie_Zombie", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("BloodyClaws", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Cannibalism", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("ChillyPresence", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("CourageAndHonor", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("CriticalStrike_Myrmidon_Myrmidon", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("CriticalStrike_TerrorWolf_TerrorWolf", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Disarm", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("DivineArmor", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("EasyPrey", "Arrow_Arrow_EVENT_LEARN", "Arrow_Arrow_Learn( learner )", "skill", "ARROW_SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("EnergyGap_Aura_Aura", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("EnergyGap_Heal_Heal", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Evasion", "EVENT_LEARN", "Learn( learner, skill )", "skill", "BERSERKER_SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Evasion", "EVENT_LEARN", "Learn( learner, skill )", "skill", "RAIDER_SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Evasion", "EVENT_LEARN", "Learn( learner, skill )", "skill", "SILVER_TAIL_SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Feedback", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Fertilizer", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("FreeRoad", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("FuneralFeast", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("GhoulFrenzy", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Immolation", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Invulnerability", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("LayEgg", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Libertine", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("LifeRegenerationAura", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("LifeRegenerationAuraNeutral", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("MagicalSuperiority", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("ManaRegenerationAura", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("ManaRegenerationAuraNeutral", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("MightAura", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("MysticalAttack", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Neutralization", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Pulverize", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Riposte", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Sales", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("SlowPoison", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("StrongArm", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("SuddenFrost", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("SummonFaust_AttackGraphic_AttackGraphic", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("UnholyArmor", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("UtilizationOfRests", "EVENT_LEARN", "Learn( learner )", "skill", "SPELL_ID")
            endif
        endif
    endfunction

    public function TriggerEvents takes Unit learner, player learnerOwner, UnitType learnerType, integer skill returns nothing
        local integer iteration = 0

        loop
            call TriggerEvents_Dynamic(learner, iteration, skill)
            call TriggerEvents_Static(learner, learnerOwner, learnerType, iteration, skill)
            set iteration = iteration + 1
            exitwhen (iteration > 0)
        endloop
    endfunction

    private function Trig takes nothing returns nothing
        local Unit learner = GetUnit(GetLearningUnit())
        local player learnerOwner = learner.owner
        local UnitType learnerType = learner.type
        local integer skill = GetLearnedSkill()
        local integer skillLevel = GetLearnedSkillLevel()

        call TriggerEvents( learner, learnerOwner, learnerType, skill )

        set learnerOwner = null
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope