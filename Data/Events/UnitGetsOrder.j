//TESH.scrollpos=59
//TESH.alwaysfold=0
scope UnitGetsOrder
    globals
        public trigger DUMMY_TRIGGER

        string ERROR_MSG
        public boolean IGNORE_NEXT = false
        Unit ORDERED_UNIT
        integer TRIGGER_ORDER
    endglobals

    private function GetUnitAbilityFromOrder takes unit orderedUnit, integer whichOrder returns integer
        local integer iteration = CountOrderAbilities(whichOrder)
        local integer specificAbility
        loop
            exitwhen ( iteration < 0 )
            set specificAbility = GetOrderAbility(whichOrder, iteration)
            if ( GetUnitAbilityLevel( orderedUnit, specificAbility ) > 0 ) then
                return specificAbility
            endif
            set iteration = iteration - 1
        endloop
        return 0
    endfunction

    scope Executed
        private function Executed_TriggerEvents_Dynamic takes integer abilityOrderId, Unit orderedUnit, real orderX, real orderY, integer priority, Unit targetUnit, integer triggerOrder returns nothing
            local integer orderedUnitId = orderedUnit.id
            local integer iteration = CountEventsById( abilityOrderId, UnitGetsOrder_Executed_Executed_EVENT_KEY, priority )
            loop
                exitwhen ( iteration < TABLE_STARTED )
                set ORDERED_UNIT = orderedUnit
                set TARGET_UNIT = targetUnit
                set TARGET_X = orderX
                set TARGET_Y = orderY
                call RunTrigger( GetEventsById( abilityOrderId, UnitGetsOrder_Executed_Executed_EVENT_KEY, priority, iteration ) )
                set iteration = iteration - 1
            endloop
            set iteration = CountEventsById( orderedUnitId, UnitGetsOrder_Executed_Executed_EVENT_KEY, priority )
            loop
                exitwhen ( iteration < TABLE_STARTED )
                set ORDERED_UNIT = orderedUnit
                set TARGET_UNIT = targetUnit
                set TARGET_X = orderX
                set TARGET_Y = orderY
                set TRIGGER_ORDER = triggerOrder
                call RunTrigger( GetEventsById( orderedUnitId, UnitGetsOrder_Executed_Executed_EVENT_KEY, priority, iteration ) )
                set iteration = iteration - 1
            endloop
            set iteration = CountEventsById(triggerOrder, UnitGetsOrder_Executed_Executed_EVENT_KEY, priority )
            loop
                exitwhen ( iteration < TABLE_STARTED )
                set ORDERED_UNIT = orderedUnit
                set TARGET_UNIT = targetUnit
                set TARGET_X = orderX
                set TARGET_Y = orderY
                call RunTrigger( GetEventsById( triggerOrder, UnitGetsOrder_Executed_Executed_EVENT_KEY, priority, iteration ) )
                set iteration = iteration - 1
            endloop
        endfunction

        private function Executed_TriggerEvents_Static takes Unit orderedUnit, real orderX, real orderY, integer priority, integer skill, integer triggerOrder returns nothing
            if (priority == 0) then
                //! runtextmacro AddEventStaticLine("Unit_Order_ImmediateTimed_ImmediateTimed", "EVENT_ORDER_EXECUTE", "OrderExecute( orderedUnit )")
                //! runtextmacro AddEventStaticLine("Unit_Order_TargetTimed_TargetTimed", "EVENT_ORDER_EXECUTE", "OrderExecute( orderedUnit )")
                if (false) then
                endif
                //! runtextmacro AddEventConditionalStaticLine("Unit_Stun_Ensnare_Cancel_Cancel", "EVENT_ORDER_EXECUTE", "OrderExecute( orderedUnit )", "triggerOrder", "ORDER_ID")"
                //! runtextmacro AddEventConditionalStaticLine("Unit_Stun_Thunderbolt_Cancel_Cancel", "EVENT_ORDER_EXECUTE", "OrderExecute( orderedUnit )", "triggerOrder", "ORDER_ID")"
                if (false) then
                endif
                ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                //! runtextmacro AddEventStaticLine("CamouflageSuit", "EVENT_ORDER_EXECUTE", "OrderExecute( orderedUnit, triggerOrder )")
                ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                //! runtextmacro AddEventStaticLine("Whirlwind", "EVENT_ORDER_EXECUTE2", "OrderExecute2( orderedUnit )")
                if (false) then
                endif
                //! runtextmacro AddEventStaticConditionLine("Defend", "EVENT_ORDER_EXECUTE", "skill", "SPELL_ID")
                    if (false) then
                    endif
                    //! runtextmacro AddEventConditionalStaticLine("Defend", "EVENT_ACTIVATION_ORDER_EXECUTE", "Activation_OrderExecute( orderedUnit )", "triggerOrder", "ACTIVATION_ORDER_ID")"
                    //! runtextmacro AddEventConditionalStaticLine("Defend", "EVENT_DEACTIVATION_ORDER_EXECUTE", "Deactivation_OrderExecute( orderedUnit )", "triggerOrder", "DEACTIVATION_ORDER_ID")"
                    if (false) then
                    endif
                //! runtextmacro AddEventConditionalStaticLine("FieryBoots", "EVENT_ORDER_EXECUTE", "OrderExecute( orderedUnit )", "skill", "ACTIVATION_SPELL_ID")"
                //! runtextmacro AddEventConditionalStaticLine("Whirlwind", "EVENT_ORDER_EXECUTE", "OrderExecute( orderedUnit )", "skill", "SPELL_ID")"
                if (false) then
                endif
            endif
        endfunction

        private function Executed_TriggerEvents takes integer abilityOrderId, Unit orderedUnit, real orderX, real orderY, integer skill, Unit targetUnit, integer triggerOrder returns nothing
            local integer iteration = 0

            loop
                call Executed_TriggerEvents_Dynamic(abilityOrderId, orderedUnit, orderX, orderY, iteration, targetUnit, triggerOrder)
                call Executed_TriggerEvents_Static(orderedUnit, orderX, orderY, iteration, skill, triggerOrder)
                set iteration = iteration + 1
                exitwhen (iteration > 0)
            endloop
        endfunction

        public function Executed_Start takes integer abilityOrderId, integer goldCost, Unit orderedUnit, player orderedUnitOwner, real orderX, real orderY, integer skill, Unit targetUnit, integer triggerOrder returns nothing
            set orderedUnit.orderTarget = targetUnit.self
            set orderedUnit.orderX = orderX
            set orderedUnit.orderY = orderY
            if (goldCost > 0) then
                call AddPlayerState( orderedUnitOwner, PLAYER_STATE_RESOURCE_GOLD, -goldCost )
            endif

            call Executed_TriggerEvents(abilityOrderId, orderedUnit, orderX, orderY, skill, targetUnit, triggerOrder)
        endfunction
    endscope

    private function TriggerEvents_Dynamic takes integer abilityOrderId, Unit orderedUnit, real orderX, real orderY, integer priority, integer skill, Unit targetUnit, integer triggerOrder returns string
        local string errorMsg = null
        local integer iteration = CountEventsById(abilityOrderId, UnitGetsOrder_EVENT_KEY, priority )
        local integer orderedUnitId = orderedUnit.id
        set ERROR_MSG = null
        loop
            exitwhen ( iteration < TABLE_STARTED )
            set ORDERED_UNIT = orderedUnit
            set TARGET_UNIT = targetUnit
            set TARGET_X = orderX
            set TARGET_Y = orderY
            call RunTrigger( GetEventsById( abilityOrderId, UnitGetsOrder_EVENT_KEY, priority, iteration ) )
            //! runtextmacro StringSetIf("errorMsg", "ERROR_MSG", "errorMsg == null")
            set iteration = iteration - 1
        endloop
        set iteration = CountEventsById(orderedUnitId, UnitGetsOrder_EVENT_KEY, priority )
        loop
            exitwhen ( iteration < TABLE_STARTED )
            set ORDERED_UNIT = orderedUnit
            set TARGET_UNIT = targetUnit
            set TARGET_X = orderX
            set TARGET_Y = orderY
            call RunTrigger( GetEventsById(orderedUnitId, UnitGetsOrder_EVENT_KEY, priority, iteration ) )
            //! runtextmacro StringSetIf("errorMsg", "ERROR_MSG", "errorMsg == null")
            set iteration = iteration - 1
        endloop
        set iteration = CountEventsById(triggerOrder, UnitGetsOrder_EVENT_KEY, priority )
        loop
            exitwhen ( iteration < TABLE_STARTED )
            set ORDERED_UNIT = orderedUnit
            set TARGET_UNIT = targetUnit
            set TARGET_X = orderX
            set TARGET_Y = orderY
            call RunTrigger( GetEventsById( triggerOrder, UnitGetsOrder_EVENT_KEY, priority, iteration ) )
            //! runtextmacro StringSetIf("errorMsg", "ERROR_MSG", "errorMsg == null")
            set iteration = iteration - 1
        endloop
        return errorMsg
    endfunction

    private function TriggerEvents_Static takes Unit orderedUnit, player orderedUnitOwner, real orderX, real orderY, integer priority, integer skill, Unit targetUnit, integer triggerOrder returns string
        local string errorMsg = null
        local unit orderedUnitSelf
        local unit targetUnitSelf
        if (priority == 0) then
            //! runtextmacro AddEventStaticLineSet("errorMsg", "KittyJump", "EVENT_ORDER", "Order2( orderedUnit )")
            if (errorMsg == null) then
                //! runtextmacro AddEventStaticLineSet("errorMsg", "WindBoots", "EVENT_ORDER", "Order( orderedUnit )")
            endif
        endif
        if ( errorMsg == null ) then
            if ( skill != 0 ) then
                set orderedUnitSelf = orderedUnit.self
                set targetUnitSelf = targetUnit.self
                if (priority == 0) then
                    if (false) then
                    endif
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "AcidStrike", "EVENT_ORDER", "Order( orderedUnitOwner, targetUnit )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventStaticConditionLine("AdvancedTraining", "EVENT_ORDER", "skill", "SPELL_ID")
                        if (false) then
                        endif
                        //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "AdvancedTraining", "EVENT_ACTIVATION_ORDER", "Activation_Order( orderedUnitOwner, targetUnit )", "triggerOrder", "ACTIVATION_ORDER_ID")
                        //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "AdvancedTraining", "EVENT_DEACTIVATION_ORDER", "Deactivation_Order( orderedUnitOwner, targetUnit )", "triggerOrder", "DEACTIVATION_ORDER_ID")
                        if (false) then
                        endif
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "AirPassage", "EVENT_ORDER", "Order( orderX, orderY )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "Barrage", "EVENT_ORDER", "Order( orderedUnit, orderX, orderY )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "BondOfSouls", "EVENT_ORDER", "Order( orderedUnit, targetUnit )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventStaticConditionLine("BubbleArmor", "EVENT_ORDER", "skill", "SPELL_ID")
                        if (false) then
                        endif
                        //! runtextmacro AddEventConditionalStaticLine("BubbleArmor", "EVENT_ORDER", "Order( orderedUnitOwner, targetUnit )", "triggerOrder", "ORDER_ID")
                        //! runtextmacro AddEventConditionalStaticLine("BubbleArmor_Automatic_Automatic", "EVENT_ACTIVATION_ORDER", "Activation_Order( orderedUnit )", "triggerOrder", "ACTIVATION_ORDER_ID")
                        //! runtextmacro AddEventConditionalStaticLine("BubbleArmor_Automatic_Automatic", "EVENT_DEACTIVATION_ORDER", "Deactivation_Order( orderedUnit )", "triggerOrder", "DEACTIVATION_ORDER_ID")
                        if (false) then
                        endif
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "ChainLightning", "EVENT_ORDER", "Order( orderedUnitOwner, targetUnit )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "CripplingWave", "EVENT_ORDER", "Order( orderedUnitOwner, targetUnitSelf )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "DarkCloud", "EVENT_ORDER", "Order( orderedUnit, targetUnitSelf )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "Downgrade", "EVENT_ORDER", "Order( orderedUnitOwner, targetUnit )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "EasyPrey", "EVENT_ORDER", "Order( targetUnitSelf )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "EasyPrey", "Arrow_Arrow_EVENT_ORDER", "Arrow_Arrow_Order( targetUnitSelf )", "skill", "ARROW_SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "EmployHenchman", "EVENT_ORDER", "Order( orderedUnitOwner, targetUnit )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "Enchant", "EVENT_ORDER", "Order( orderedUnitOwner, targetUnit )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "EarlyPromotion", "EVENT_ORDER", "Order( orderedUnitOwner, orderX, orderY )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "EsteemInCoins", "EVENT_ORDER", "Order( orderedUnitOwner )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventStaticConditionLine("Fireball", "EVENT_ORDER", "skill", "SPELL_ID")
                        if (false) then
                        endif
                        //! runtextmacro AddEventConditionalStaticLine("Fireball", "EVENT_ORDER", "Order( orderedUnitOwner, targetUnit )", "triggerOrder", "ORDER_ID")
                        //! runtextmacro AddEventConditionalStaticLine("Fireball_Automatic_Automatic", "EVENT_ACTIVATION_ORDER", "Activation_Order( orderedUnit )", "triggerOrder", "ACTIVATION_ORDER_ID")
                        //! runtextmacro AddEventConditionalStaticLine("Fireball_Automatic_Automatic", "EVENT_DEACTIVATION_ORDER", "Deactivation_Order( orderedUnit )", "triggerOrder", "DEACTIVATION_ORDER_ID")
                        if (false) then
                        endif
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "FleshBomb", "EVENT_ORDER", "Order( targetUnit )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "FrostBolt", "EVENT_ORDER", "Order( orderedUnitOwner, targetUnit )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventStaticConditionLine("Fury", "EVENT_ORDER", "skill", "SPELL_ID")
                        if (false) then
                        endif
                        //! runtextmacro AddEventConditionalStaticLine("Fury", "EVENT_ORDER", "Order( orderedUnitOwner, targetUnit )", "triggerOrder", "ORDER_ID")
                        //! runtextmacro AddEventConditionalStaticLine("Fury_Automatic_Automatic", "EVENT_ACTIVATION_ORDER", "Activation_Order( orderedUnit )", "triggerOrder", "ACTIVATION_ORDER_ID")
                        //! runtextmacro AddEventConditionalStaticLine("Fury_Automatic_Automatic", "EVENT_DEACTIVATION_ORDER", "Deactivation_Order( orderedUnit )", "triggerOrder", "DEACTIVATION_ORDER_ID")
                        if (false) then
                        endif
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "HammerThrow", "EVENT_ORDER", "Order( orderedUnitOwner, targetUnit )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "Heal", "EVENT_ORDER", "Order( targetUnit )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "IceBall", "EVENT_ORDER", "Order( targetUnit )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventStaticConditionLine("Inspiration", "EVENT_ORDER", "skill", "SPELL_ID")
                        if (false) then
                        endif
                        //! runtextmacro AddEventConditionalStaticLine("Inspiration", "EVENT_ORDER", "Order( orderedUnit, targetUnit )", "triggerOrder", "ORDER_ID")
                        //! runtextmacro AddEventConditionalStaticLine("Inspiration_Automatic_Automatic", "EVENT_ACTIVATION_ORDER", "Activation_Order( orderedUnit )", "triggerOrder", "ACTIVATION_ORDER_ID")
                        //! runtextmacro AddEventConditionalStaticLine("Inspiration_Automatic_Automatic", "EVENT_DEACTIVATION_ORDER", "Deactivation_Order( orderedUnit )", "triggerOrder", "DEACTIVATION_ORDER_ID")
                        if (false) then
                        endif
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "KidneyShot", "EVENT_ORDER", "Order( orderedUnitOwner, targetUnitSelf )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "KittyJump", "EVENT_ORDER", "Order( GetUnitX(orderedUnitSelf), GetUnitY(orderedUnitSelf), orderX, orderY )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "LifeDrain", "EVENT_ORDER", "Order( targetUnit )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "LightOfPurge", "EVENT_ORDER", "Order( orderedUnit, orderedUnitOwner, targetUnit )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "MagicalLariat", "EVENT_ORDER", "Order( orderedUnit, targetUnit )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "ManaTheft", "EVENT_ORDER", "Order( targetUnit )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "MindBreaker", "EVENT_ORDER", "Order( targetUnitSelf )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "NaturalEmbrace", "EVENT_ORDER", "Order( targetUnit )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "Net", "EVENT_ORDER", "Order( orderedUnitOwner, targetUnit )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventStaticConditionLine("RaiseDead", "EVENT_ORDER", "skill", "SPELL_ID")
                        if (false) then
                        endif
                        //! runtextmacro AddEventConditionalStaticLine("RaiseDead", "EVENT_ORDER", "Order( GetUnitX(orderedUnitSelf), GetUnitY(orderedUnitSelf) )", "triggerOrder", "ORDER_ID")
                        //! runtextmacro AddEventConditionalStaticLine("RaiseDead_Automatic_Automatic", "EVENT_ACTIVATION_ORDER", "Activation_Order( orderedUnit )", "triggerOrder", "ACTIVATION_ORDER_ID")
                        //! runtextmacro AddEventConditionalStaticLine("RaiseDead_Automatic_Automatic", "EVENT_DEACTIVATION_ORDER", "Deactivation_Order( orderedUnit )", "triggerOrder", "DEACTIVATION_ORDER_ID")
                        if (false) then
                        endif
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "RefillMana", "EVENT_ORDER", "Order( orderedUnit, orderedUnitOwner, targetUnit )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "RequestReinforcements", "EVENT_ORDER", "Order( orderedUnit, orderedUnitOwner, orderX, orderY )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "Resurrection", "EVENT_ORDER", "Order( orderedUnitSelf, orderedUnitOwner, GetUnitX(orderedUnitSelf), GetUnitY(orderedUnitSelf) )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "Rust", "EVENT_ORDER", "Order( orderedUnitOwner, targetUnit )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "SilverSpores", "EVENT_ORDER", "Order( orderedUnitOwner, targetUnit )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "SpellDisconnection", "EVENT_ORDER", "Order( orderedUnit, orderedUnitOwner, targetUnit )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventConditionalStaticLineSet("errorMsg", "SummonInfernal", "EVENT_ORDER", "Order( orderX, orderY )", "skill", "SPELL_ID")
                    //! runtextmacro AddEventStaticConditionLine("VioletDefense", "EVENT_ORDER", "skill", "SPELL_ID")
                        if (false) then
                        endif
                        //! runtextmacro AddEventConditionalStaticLine("VioletDefense", "EVENT_ORDER", "Order( orderedUnit, targetUnit )", "triggerOrder", "ORDER_ID")
                        //! runtextmacro AddEventConditionalStaticLine("VioletDefense_Automatic_Automatic", "EVENT_ACTIVATION_ORDER", "Activation_Order( orderedUnitOwner, targetUnit )", "triggerOrder", "ACTIVATION_ORDER_ID")
                        //! runtextmacro AddEventConditionalStaticLine("VioletDefense_Automatic_Automatic", "EVENT_DEACTIVATION_ORDER", "Deactivation_Order( orderedUnitOwner, targetUnit )", "triggerOrder", "DEACTIVATION_ORDER_ID")
                        if (false) then
                        endif
                    endif
                if (false) then
                endif
                set orderedUnitSelf = null
                set targetUnitSelf = null
            endif
        endif
        return errorMsg
    endfunction

    public function TriggerEvents takes integer abilityOrderId, Unit orderedUnit, player orderedUnitOwner, real orderX, real orderY, integer skill, Unit targetUnit, integer triggerOrder returns string
        local string errorMsg = null
        local integer iteration = 0

        loop
            //! runtextmacro StringSetIf("errorMsg", "TriggerEvents_Dynamic(abilityOrderId, orderedUnit, orderX, orderY, iteration, skill, targetUnit, triggerOrder)", "errorMsg == null")
            //! runtextmacro StringSetIf("errorMsg", "TriggerEvents_Static(orderedUnit, orderedUnitOwner, orderX, orderY, iteration, skill, targetUnit, triggerOrder)", "errorMsg == null")
            set iteration = iteration + 1
            exitwhen (iteration > 0)
        endloop

        return errorMsg
    endfunction

    private function Trig_BuyConditions takes integer someObjectId returns boolean
        if (IsItemType( someObjectId ) == false) then
            return false
        endif
        if (IsUnitTypeWJ( someObjectId ) == false) then
            return false
        endif
        if (IsResearchType( someObjectId ) == false) then
            return false
        endif
        return true
    endfunction

    private function Trig takes nothing returns nothing
        local integer abilityOrderId
        local string errorMsg
        local integer goldCost
        local real manaCost
        local Unit orderedUnit
        local unit orderedUnitSelf
        local player orderedUnitOwner
        local real orderX
        local real orderY
        local integer skill
        local Unit targetUnit
        local integer triggerOrder
        if ( IGNORE_NEXT ) then
            set IGNORE_NEXT = false
        else
            set errorMsg = null
            set orderedUnitSelf = GetOrderedUnit()
            set orderedUnit = GetUnit(orderedUnitSelf)
            set orderedUnitOwner = orderedUnit.owner
            set triggerOrder = GetIssuedOrderId()
            if ( Trig_BuyConditions( triggerOrder ) ) then
                set goldCost = GetPlayerGoldCost(GetObjectGoldCost(orderedUnitOwner, triggerOrder), orderedUnitOwner)
                if ( goldCost > 0 ) then
                    if ( GetPlayerState( orderedUnitOwner, PLAYER_STATE_RESOURCE_GOLD ) < goldCost ) then
                        set errorMsg = ErrorStrings_TOO_LESS_GOLD
//                    set PlayerChangesLumberAmount_IGNORE_NEXT = true
                    endif
                endif
            else
                set goldCost = 0
                set orderX = GetOrderPointX()
                set orderY = GetOrderPointY()
                set targetUnit = GetUnit(GetOrderTargetUnit())
                set skill = GetUnitAbilityFromOrder( orderedUnitSelf, triggerOrder )
                set abilityOrderId = GetAbilityOrderId( skill, triggerOrder )

                set errorMsg = TriggerEvents(abilityOrderId, orderedUnit, orderedUnitOwner, orderX, orderY, skill, targetUnit, triggerOrder)
            endif

            if ( errorMsg == null ) then
                call Executed_Executed_Start(abilityOrderId, goldCost, orderedUnit, orderedUnitOwner, orderX, orderY, skill, targetUnit, triggerOrder)
            else
                call StopUnit( orderedUnit )
                if ( IsUnitSelected( orderedUnitSelf, orderedUnitOwner ) ) then
                    call Error( orderedUnitOwner, errorMsg )
                endif
            endif
            set orderedUnitOwner = null
            set orderedUnitSelf = null
        endif
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope