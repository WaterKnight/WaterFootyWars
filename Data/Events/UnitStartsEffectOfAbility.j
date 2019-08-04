//TESH.scrollpos=137
//TESH.alwaysfold=0
scope UnitStartsEffectOfAbility
    globals
        public trigger DUMMY_TRIGGER
    endglobals

    private function TriggerEvents_Dynamic takes Unit caster, integer priority, integer skill, Unit targetUnit, real targetX, real targetY returns nothing
        local integer iteration = CountEventsById( skill, UnitStartsEffectOfAbility_EVENT_KEY, priority )
        loop
            exitwhen ( iteration < TABLE_STARTED )
            set CASTER = caster
            set TARGET_UNIT = targetUnit
            set TARGET_X = targetX
            set TARGET_Y = targetY
            call RunTrigger( GetEventsById( skill, UnitStartsEffectOfAbility_EVENT_KEY, priority, iteration ) )
            set iteration = iteration - 1
        endloop
    endfunction

    private function TriggerEvents_Static takes Unit caster, real casterX, real casterY, real casterZ, integer priority, integer skill, Unit targetUnit, real targetX, real targetY returns nothing
        if (priority == 0) then
            if (false) then
            endif
            //! runtextmacro AddEventConditionalStaticLine("AcidStrike", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("AdvertisingGift", "EVENT_CAST", "SpellEffect( caster, targetX, targetY )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Barrage", "EVENT_CAST", "SpellEffect( caster, targetX, targetY )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Berserk", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("BondOfSouls", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("BubbleArmor", "EVENT_CAST", "SpellEffect( targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Burrow", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("CamouflageSuit", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("CareBear", "EVENT_CAST", "SpellEffect( caster, targetX, targetY )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("CashDiscount", "EVENT_CAST", "SpellEffect( caster.owner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("ChainLightning", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("ChimeraEgg", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("ChooseHero", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("ChooseRandomHero", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("ChooseRandomHeroFromSelection", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("CripplingWave", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("CrowdPuller", "EVENT_CAST", "SpellEffect( caster, targetX, targetY )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("CurseOfTheBloodline", "EVENT_CAST", "SpellEffect( caster, targetX, targetY )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("DarkCloud", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("DiversionaryTactics", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("DivineShield", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Downgrade", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("EarlyPromotion", "EVENT_CAST", "SpellEffect( caster, targetX, targetY )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("EasyPrey", "EVENT_CAST", "SpellEffect( GetUnitAbilityLevel( caster.self, EasyPrey_SPELL_ID ), caster, EasyPrey_SPELL_ID, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("ElectroNet", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("ElixirOfTheGrowth", "EVENT_CAST", "SpellEffect( caster, casterX, casterY, casterZ )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Enchant", "EVENT_CAST", "SpellEffect( target )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("ExperimentalElixir", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("FeelingOfSecurity", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("FeelingOfSecurity", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "UPGRADED_SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Fireball", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("FireBurst", "EVENT_CAST", "SpellEffect( caster, targetX, targetY )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("FleshBomb", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("FlyingSheep", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Frenzy", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("FrostBolt", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("FrostNova", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Fury", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("GhostTakeOver", "EVENT_CAST", "SpellEffect( caster, targetX, targetY )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("HammerThrow", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Harmagedon", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Harmagedon2", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Heal", "EVENT_CAST", "SpellEffect( targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("HealingPotion", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("HealingPotionBloodOrange", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("HealingWard", "EVENT_CAST", "SpellEffect( caster, targetX, targetY )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("HeartOfTheHards", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("HindranceOfLearning", "EVENT_CAST", "SpellEffect( caster.owner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Hurricane", "EVENT_CAST", "SpellEffect( caster, targetX, targetY )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("IceBall", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("IllusionaryStaff", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Inspiration", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Kataikaze", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("KidneyShot", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("KittyJump", "EVENT_CAST", "SpellEffect( caster, targetX, targetY )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("LastGrave", "EVENT_CAST", "SpellEffect( caster, targetX, targetY )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Lens", "EVENT_CAST", "SpellEffect( targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("LifeDrain", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("LightOfPurge", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("LittleThunderstorm", "EVENT_CAST", "SpellEffect( caster, targetX, targetY )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("MagicalLariat", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("ManaTheft", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("MecaPenguin", "EVENT_CAST", "SpellEffect( caster, targetXm targetY )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Meditation", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Metamorphosis", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("MightyHammer", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("MindBreaker", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("NaturalEmbrace", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Net", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Nethermask_Use_Use", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("NextHero", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Payday", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("PoisonFountain", "EVENT_CAST", "SpellEffect( caster.owner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("PotionOfTheInconspicuousShape", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("PreviousHero", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("RaiseDead", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("RefillMana", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("RegenerationPotion", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("RequestReinforcements", "EVENT_CAST", "SpellEffect( caster, targetX, targetY )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Resurrection", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Rust", "EVENT_CAST", "SpellEffect( targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("ScrollOfRage", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("SelfHeal", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("ShiftInventory", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("ShiftInventory_Off_Off", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("ShockWave", "EVENT_CAST", "SpellEffect( caster, targetX, targetY )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("SilverSpores", "EVENT_CAST", "SpellEffect( targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Slam", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("SpellDisconnection", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("SpiderEgg", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("StaffOfAbolition", "EVENT_CAST", "SpellEffect( caster, targetX, targetY )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Stability", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Suicide", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("SummonFaust", "EVENT_CAST", "SpellEffect( caster.owner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("SummonInfernal", "EVENT_CAST", "SpellEffect( caster, targetX, targetY )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("SummonPeq", "EVENT_CAST", "SpellEffect( caster.owner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("SummonPeqqiBeast", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("SwitchShops", "EVENT_CAST", "SpellEffect( caster.owner )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("ThermalFissure", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("ToadReflection", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("Trap", "EVENT_CAST", "SpellEffect( caster, targetX, targetY )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("VioletDefense", "EVENT_CAST", "SpellEffect( caster, targetUnit )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("VividStrikes", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("VolatileManaPotion", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("WhipLash", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("WindBoots", "EVENT_CAST", "SpellEffect( caster, targetX, targetY )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("CamouflageSuit", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            //! runtextmacro AddEventConditionalStaticLine("CamouflageSuit", "EVENT_CAST", "SpellEffect( caster )", "skill", "SPELL_ID")
            if (false) then
            endif

            //! runtextmacro AddEventStaticLine("SoulVessel", "EVENT_CAST", "SpellEffect( caster )")
        endif
    endfunction

    private function TriggerEvents takes Unit caster, real casterX, real casterY, real casterZ, integer skill, Unit targetUnit, real targetX, real targetY returns nothing
        local integer iteration = 0

        loop
            call TriggerEvents_Dynamic(caster, iteration, skill, targetUnit, targetX, targetY)
            call TriggerEvents_Static(caster, casterX, casterY, casterZ, iteration, skill, targetUnit, targetX, targetY)
            set iteration = iteration + 1
            exitwhen (iteration > 0)
        endloop
    endfunction

    private function Trig takes nothing returns nothing
        local unit casterSelf = GetSpellAbilityUnit()
        local Unit caster = GetUnit(casterSelf)
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local real casterZ = GetUnitZ( casterSelf, casterX, casterY ) + GetUnitOutpactZ(caster)
        local boolean isCasterHero = IsUnitType( casterSelf, UNIT_TYPE_HERO )
        local integer skill = GetSpellAbilityId()
        local Unit targetUnit = GetUnit(GetSpellTargetUnit())
        local location targetLocation = GetSpellTargetLocWJ()
        local real targetX
        local real targetY
        if ( targetLocation != null ) then
            set targetX = GetLocationX( targetLocation )
            set targetY = GetLocationY( targetLocation )
            call RemoveLocationWJ( targetLocation )
            set targetLocation = null
        else
            set targetX = 0
            set targetY = 0
        endif

        call TriggerEvents(caster, casterX, casterY, casterZ, skill, targetUnit, targetX, targetY)

        if ( targetUnit != null ) then
            if ( IsUnitAlly( casterSelf, targetUnit.owner ) == false ) then
                set UnitTakesDamage_NEXT_DAMAGE_IS_SPELL = true
            endif
        endif
        set casterSelf = null
        if ( isCasterHero and (skill != ShiftInventory_SPELL_ID) and (skill != ShiftInventory_Off_Off_SPELL_ID) ) then
            call CreateRisingTextTag( GetObjectName( skill ), 0.023, casterX, casterY, casterZ, 80, 255, 0, 255, 255, 1, 4 )
        endif
        set TARGET_X = targetX
        set TARGET_Y = targetY
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope