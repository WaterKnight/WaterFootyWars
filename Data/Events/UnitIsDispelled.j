//TESH.scrollpos=0
//TESH.alwaysfold=0
scope UnitIsDispelled
    globals
        public trigger DUMMY_TRIGGER
        private constant string TRIGGER_UNIT_EFFECT_PATH = "Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl"
        private constant string TRIGGER_UNIT_EFFECT_ATTACHMENT_POINT = "origin"

        public boolean NEGATIVE_BUFFS
        public boolean POSITIVE_BUFFS
        public boolean SHOW_GRAPHICS
    endglobals

    private function TriggerEvents_Dynamic takes boolean negativeBuffs, boolean positiveBuffs, integer priority, Unit triggerUnit returns nothing
        local integer iteration
        local integer triggerUnitId = triggerUnit.id
        if ( negativeBuffs ) then
            set iteration = CountEventsById(triggerUnitId, UnitIsDispelled_EVENT_KEY_NEGATIVE, priority )
            loop
                exitwhen ( iteration < TABLE_STARTED )
                set TRIGGER_UNIT = triggerUnit
                call RunTrigger( GetEventsById(triggerUnitId, UnitIsDispelled_EVENT_KEY_NEGATIVE, priority, iteration ) )
                set iteration = iteration - 1
            endloop
        endif
        if ( positiveBuffs ) then
            set iteration = CountEventsById(triggerUnitId, UnitIsDispelled_EVENT_KEY_POSITIVE, priority )
            loop
                exitwhen ( iteration < TABLE_STARTED )
                set TRIGGER_UNIT = triggerUnit
                call RunTrigger( GetEventsById( triggerUnitId, UnitIsDispelled_EVENT_KEY_POSITIVE, priority, iteration ) )
                set iteration = iteration - 1
            endloop
        endif
    endfunction

    private function TriggerEvents_Static takes boolean negativeBuffs, boolean positiveBuffs, integer priority, Unit triggerUnit returns nothing
        if ( negativeBuffs ) then
            if (priority == 0) then
                //! runtextmacro AddEventStaticLine("AdvertisingGift_Target_Target", "EVENT_DISPEL", "Dispel( triggerUnit )")
                //! runtextmacro AddEventStaticLine("CurseOfTheBloodline", "EVENT_DISPEL", "Dispel( triggerUnit )")
                //! runtextmacro AddEventStaticLine("DarkCloud", "EVENT_DISPEL", "Dispel( triggerUnit )")
                //! runtextmacro AddEventStaticLine("Disarm", "EVENT_DISPEL", "Dispel( triggerUnit )")
                //! runtextmacro AddEventStaticLine("DreadCall", "EVENT_DISPEL", "Dispel( triggerUnit )")
                //! runtextmacro AddEventStaticLine("EasyPrey", "EVENT_DISPEL", "Dispel( triggerUnit )")
                //! runtextmacro AddEventStaticLine("IceBall_Buff_Buff", "EVENT_DISPEL", "Dispel( triggerUnit )")
                //! runtextmacro AddEventStaticLine("NaturalEmbrace", "EVENT_DISPEL", "Dispel( triggerUnit )")
                //! runtextmacro AddEventStaticLine("Rust", "EVENT_DISPEL", "Dispel( triggerUnit )")
            endif
        endif
        if ( positiveBuffs ) then
            if (priority == 0) then
                //! runtextmacro AddEventStaticLine("Berserk", "EVENT_DISPEL", "Dispel( triggerUnit )")
                //! runtextmacro AddEventStaticLine("BubbleArmor", "EVENT_DISPEL", "Dispel( triggerUnit )")
                ////! runtextmacro AddEventStaticLine("Enchant", "EVENT_DISPEL", "Dispel( triggerUnit )")
                //! runtextmacro AddEventStaticLine("FeelingOfSecurity", "EVENT_DISPEL", "Dispel( triggerUnit )")
                //! runtextmacro AddEventStaticLine("FleshBomb", "EVENT_DISPEL", "Dispel( triggerUnit )")
                //! runtextmacro AddEventStaticLine("Frenzy", "EVENT_DISPEL", "Dispel( triggerUnit )")
                //! runtextmacro AddEventStaticLine("Fury", "EVENT_DISPEL", "Dispel( triggerUnit )")
                //! runtextmacro AddEventStaticLine("GhoulFrenzy", "EVENT_DISPEL", "Dispel( triggerUnit )")
                //! runtextmacro AddEventStaticLine("HealingPotionBloodOrange", "EVENT_DISPEL", "Dispel( triggerUnit )")
                //! runtextmacro AddEventStaticLine("Inspiration", "EVENT_DISPEL", "Dispel( triggerUnit )")
                //! runtextmacro AddEventStaticLine("PotionOfTheInconspicuousShape", "EVENT_DISPEL", "Dispel( triggerUnit )")
                //! runtextmacro AddEventStaticLine("ScrollOfRage", "EVENT_DISPEL", "Dispel( triggerUnit )")
                //! runtextmacro AddEventStaticLine("SilverSpores", "EVENT_DISPEL", "Dispel( triggerUnit )")
                //! runtextmacro AddEventStaticLine("Stability", "EVENT_DISPEL", "Dispel( triggerUnit )")
                //! runtextmacro AddEventStaticLine("ThermalFissure_Target_Target", "EVENT_DISPEL", "Dispel( triggerUnit )")
                //! runtextmacro AddEventStaticLine("VioletDefense", "EVENT_DISPEL", "Dispel( triggerUnit )")
                ////! runtextmacro AddEventStaticLine("VividStrikes", "EVENT_DISPEL", "Dispel( triggerUnit )")
                //! runtextmacro AddEventStaticLine("WhipLash", "EVENT_DISPEL", "Dispel( triggerUnit )")
            endif
        endif
    endfunction

    private function TriggerEvents takes boolean negativeBuffs, boolean positiveBuffs, Unit triggerUnit returns nothing
        local integer iteration = 0

        loop
            call TriggerEvents_Dynamic(negativeBuffs, positiveBuffs, iteration, triggerUnit)
            call TriggerEvents_Static(negativeBuffs, positiveBuffs, iteration, triggerUnit)
            set iteration = iteration + 1
            exitwhen (iteration>  0)
        endloop
    endfunction

    private function Trig takes nothing returns nothing
        local boolean negativeBuffs = NEGATIVE_BUFFS
        local boolean positiveBuffs = POSITIVE_BUFFS
        local boolean showGraphics = SHOW_GRAPHICS
        local Unit triggerUnit = TRIGGER_UNIT
        if (showGraphics) then
            call DestroyEffectWJ( AddSpecialEffectTargetWJ( TRIGGER_UNIT_EFFECT_PATH, triggerUnit.self, TRIGGER_UNIT_EFFECT_ATTACHMENT_POINT ) )
        endif

        call TriggerEvents(negativeBuffs, positiveBuffs, triggerUnit)
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope