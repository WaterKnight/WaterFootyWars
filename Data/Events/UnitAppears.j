//TESH.scrollpos=143
//TESH.alwaysfold=0
scope UnitAppears
    globals
        public trigger DUMMY_TRIGGER
        private constant real STANDARD_HERO_ARMOR_BY_SPELL = 0.15

        public boolean NEXT_IS_ILLUSION = false
    endglobals

    private function TriggerEvents_Static takes boolean isTriggerUnitHero, boolean isTriggerUnitNotIllusion, Unit triggerUnit, player triggerUnitOwner, UnitType triggerUnitType returns nothing
        if (isTriggerUnitHero and isTriggerUnitNotIllusion) then
            call Infoboard_Appearance(triggerUnit, triggerUnitOwner, triggerUnitType)
        endif
        call ShiftInventory_Appearance(triggerUnit)
        call Shop_Appearance(triggerUnit, triggerUnitType.id)
        call Worker_Appearance(triggerUnit, triggerUnitOwner, triggerUnitType)
    endfunction

    private function Trig takes nothing returns nothing
        local integer heroCount
        local integer heroStatsFactor
        local boolean isTriggerUnitNotIllusion
        local integer iteration
        local integer newTimer
        local integer requiredResearchTypeId
        local integer specificAbility
        local integer specificItemTypeId
        local integer specificUnitTypeId
        local Unit triggerUnit = Unit.create()
        local unit triggerUnitSelf = TRIGGER_UNIT_SELF
        local boolean isTriggerUnitHero = IsUnitType( triggerUnitSelf, UNIT_TYPE_HERO )
        local player triggerUnitOwner = GetOwningPlayer(triggerUnitSelf)
        local integer triggerUnitTeam = GetPlayerTeam( triggerUnitOwner )
        local UnitType triggerUnitType = GetUnitType(GetUnitTypeId(triggerUnitSelf))
        local integer automaticAbility = GetUnitTypeAutomaticAbility(triggerUnitType)

        set triggerUnit.id = GetHandleId(triggerUnitSelf)
        set triggerUnit.owner = triggerUnitOwner
        set triggerUnit.self = triggerUnitSelf
        set triggerUnit.type = triggerUnitType
        call AttachInteger(triggerUnitSelf, UNIT_KEY, triggerUnit)

        call UnitAddAbility( triggerUnitSelf, ABILITY_STORAGE_SPELL_ID )
        call UnitAddAbility( triggerUnitSelf, ABILITY_STORAGE2_SPELL_ID)

        if (NEXT_IS_ILLUSION) then
            set NEXT_IS_ILLUSION = false
            set isTriggerUnitNotIllusion = false
        else
            set isTriggerUnitNotIllusion = ( IsUnitIllusionWJ( triggerUnit ) == false )
        endif

        call SetUnitArmor( triggerUnit, GetUnitTypeArmor( triggerUnitType ) + GetUnitTypeArmorForPlayer( triggerUnitType, triggerUnitOwner ) )

        call SetUnitAttackRate(triggerUnit, GetUnitTypeAttackRateForPlayer(triggerUnitType, triggerUnitOwner))

        call SetUnitBlood( triggerUnit, GetUnitTypeBlood(triggerUnitType) )
        call SetUnitBloodExplosion( triggerUnit, GetUnitTypeBloodExplosion(triggerUnitType) )

        call SetUnitCanNotBeRevived(triggerUnit, B2I(IsUnitTypeCanNotBeRevived(triggerUnitType)))

        call SetUnitCriticalStrike( triggerUnit, GetUnitTypeCriticalStrikeForPlayer( triggerUnitType, triggerUnitOwner ) )

        call UnitWakeUp(triggerUnitSelf)
        call SetUnitDamage( triggerUnit, GetUnitTypeDamage( triggerUnitType ) + GetUnitTypeDamageForPlayer( triggerUnitType, triggerUnitOwner ) )

        call SetUnitDecay(triggerUnit, B2I(IsUnitTypeDecay(triggerUnitType)))
        call SetUnitDecayTime(triggerUnit, GetUnitTypeDecayTime(triggerUnitType))

        call SetUnitImpactZ(triggerUnit, GetUnitTypeImpactZ(triggerUnitType))
        call SetUnitOutpactZ(triggerUnit, GetUnitTypeOutpactZ(triggerUnitType))

        call SetUnitMaxLife( triggerUnit, GetUnitTypeMaxLife( triggerUnitType ) + GetUnitTypeMaxLifeForPlayer( triggerUnitType, triggerUnitOwner ) )
        call SetUnitMaxMana( triggerUnit, GetUnitTypeMaxMana( triggerUnitType ) + GetUnitTypeMaxManaForPlayer( triggerUnitType, triggerUnitOwner ) )

        call SetUnitLifeRegeneration( triggerUnit, GetUnitTypeLifeRegeneration( triggerUnitType ) + GetUnitTypeLifeRegenerationForPlayer( triggerUnitType, triggerUnitOwner ) )
        call SetUnitManaRegeneration( triggerUnit, GetUnitTypeManaRegeneration( triggerUnitType ) + GetUnitTypeManaRegenerationForPlayer( triggerUnitType, triggerUnitOwner ) )

        call SetUnitSightRange( triggerUnit, GetUnitTypeSightRange(triggerUnitType) )

        call SetUnitSpeed( triggerUnit, GetUnitTypeSpeed( triggerUnitType ) + GetUnitTypeSpeedForPlayer( triggerUnitType, triggerUnitOwner ) )

        if ( isTriggerUnitHero ) then
            set heroCount = GetPlayerHeroCount(triggerUnitOwner) + 1
            set heroStatsFactor = GetHeroLevel( triggerUnitSelf )
            set triggerUnit.level = heroStatsFactor
            set heroStatsFactor = heroStatsFactor - 1
            call SetUnitEP( triggerUnitSelf, GetUnitEP( triggerUnitSelf ) )
            call SetHeroAgility( triggerUnit, triggerUnitType, GetUnitTypeAgility(triggerUnitType) + heroStatsFactor * GetUnitTypeAgilityPerLevel(triggerUnitType) )
            call SetHeroIntelligence( triggerUnit, triggerUnitType, GetUnitTypeIntelligence(triggerUnitType) + heroStatsFactor * GetUnitTypeIntelligencePerLevel(triggerUnitType) )
            call SetHeroStrength( triggerUnit, triggerUnitType, GetUnitTypeStrength(triggerUnitType) + heroStatsFactor * GetUnitTypeStrengthPerLevel(triggerUnitType) )
            call AddUnitArmorBySpellBonus( triggerUnit, STANDARD_HERO_ARMOR_BY_SPELL )
            call SetUnitState( triggerUnitSelf, UNIT_STATE_MANA, GetUnitMaxMana( triggerUnit ) )
            if (heroCount == 0) then
                call UnitAddItem( triggerUnitSelf, CreateItemEx( TownPortal_ITEM_ID, 0, 0 ).self )
                call UnitAddItem( triggerUnitSelf, CreateItemEx( HealingPotion_ITEM_ID, 0, 0 ).self )
            endif
            call SetPlayerHeroCount(triggerUnitOwner, heroCount)
        else
            call SetUnitState( triggerUnitSelf, UNIT_STATE_MANA, GetUnitTypeStartMana(triggerUnitType) )
        endif
        call SetUnitState( triggerUnitSelf, UNIT_STATE_LIFE, GetUnitMaxLife( triggerUnit ) )

        call SetUnitScaleEx(triggerUnit, GetUnitTypeScale(triggerUnitType))

        call SetUnitSupplyProduced( triggerUnit, triggerUnitOwner, GetUnitTypeSupplyProduced( triggerUnitType ) )
        call SetUnitSupplyUsed( triggerUnit, triggerUnitOwner, GetUnitTypeSupplyUsed( triggerUnitType ) )

        call SetUnitVertexColorEx( triggerUnit, GetUnitTypeVertexColorRed(triggerUnitType), GetUnitTypeVertexColorGreen(triggerUnitType), GetUnitTypeVertexColorBlue(triggerUnitType), GetUnitTypeVertexColorAlpha(triggerUnitType), null )

        call InitUnitZ(triggerUnitSelf)

        if ( IsUnitInGroup( triggerUnitSelf, ALL_GROUP ) == false ) then
            call GroupAddUnit( ALL_GROUP, triggerUnitSelf )
            call TriggerRegisterUnitEvent( UnitAcquiresTarget_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_TARGET_IN_RANGE )
            call TriggerRegisterUnitEvent( UnitAcquiresItem_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_PICKUP_ITEM )
            call TriggerRegisterUnitEvent( UnitBeginsCasting_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_SPELL_CAST )
            call TriggerRegisterUnitEvent( UnitChangesOwner_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_CHANGE_OWNER )
            call TriggerRegisterUnitEvent( UnitChannels_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_SPELL_CHANNEL )
            call TriggerRegisterUnitEvent( UnitDecays_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_DECAY )
            call TriggerRegisterUnitEvent( UnitDies_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_DEATH )
            call TriggerRegisterUnitEvent( UnitDropsItem_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_DROP_ITEM )
            call TriggerRegisterUnitEvent( UnitFinishesCasting_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_SPELL_ENDCAST )
            call TriggerRegisterUnitEvent( UnitGetsOrder_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_ISSUED_ORDER )
            call TriggerRegisterUnitEvent( UnitGetsOrder_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_ISSUED_POINT_ORDER )
            call TriggerRegisterUnitEvent( UnitGetsOrder_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_ISSUED_TARGET_ORDER )
            call TriggerRegisterUnitEvent( UnitIsAttacked_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_ATTACKED )
            call TriggerRegisterUnitStateEvent( UnitIsBeforeDying_DUMMY_TRIGGER, triggerUnitSelf, UNIT_STATE_LIFE, LESS_THAN_OR_EQUAL, LIMIT_OF_DEATH )
            if ( isTriggerUnitHero ) then
                call TriggerRegisterUnitEvent( UnitBecomesRevivable_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_HERO_REVIVABLE )
                call TriggerRegisterUnitEvent( UnitFinishesReviving_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_HERO_REVIVE_FINISH )
                call TriggerRegisterUnitEvent( UnitGainsLevel_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_HERO_LEVEL )
                call TriggerRegisterUnitEvent( UnitLearnsSkill_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_HERO_SKILL )
                call TriggerRegisterUnitEvent( UnitPawnsItem_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_PAWN_ITEM )
            elseif ( IsUnitType( triggerUnitSelf, UNIT_TYPE_STRUCTURE ) ) then
                call TriggerRegisterUnitEvent( UnitBeginsResearching_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_RESEARCH_START )
                call TriggerRegisterUnitEvent( UnitBeginsUpgrading_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_UPGRADE_START )
                call TriggerRegisterUnitEvent( UnitCancelsResearching_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_RESEARCH_CANCEL )
                call TriggerRegisterUnitEvent( UnitCancelsUpgrading_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_UPGRADE_CANCEL )
                call TriggerRegisterUnitEvent( UnitFinishesConstructing_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_CONSTRUCT_FINISH )
                call TriggerRegisterUnitEvent( UnitFinishesResearching_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_RESEARCH_FINISH )
                call TriggerRegisterUnitEvent( UnitFinishesTraining_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_TRAIN_FINISH )
                call TriggerRegisterUnitEvent( UnitFinishesUpgrading_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_UPGRADE_FINISH )
                call TriggerRegisterUnitEvent( UnitSellsItem_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_SELL_ITEM )
                call TriggerRegisterUnitEvent( UnitSellsUnit_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_SELL )
            endif
            call TriggerRegisterUnitEvent( UnitStartsEffectOfAbility_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_SPELL_EFFECT )
            call TriggerRegisterUnitEvent( UnitTakesDamage_DUMMY_TRIGGER, triggerUnitSelf, EVENT_UNIT_DAMAGED )

            call UnitIsActivated_Start( triggerUnit )
        endif

        if ( isTriggerUnitNotIllusion ) then
            set iteration = CountUnitTypeAbilities(triggerUnitType)
            loop
                exitwhen ( iteration < TABLE_STARTED )
                set specificAbility = GetUnitTypeAbility(triggerUnitType, iteration)
                set requiredResearchTypeId = GetAbilityRequiredResearch( specificAbility )
                call UnitAddAbility( triggerUnitSelf, specificAbility )
                if ((requiredResearchTypeId == 0) or (GetPlayerTechCount(triggerUnitOwner, requiredResearchTypeId, true) > 0)) then
                    call UnitLearnsSkill_TriggerEvents( triggerUnit, triggerUnitOwner, triggerUnitType, specificAbility )
                endif
                set iteration = iteration - 1
            endloop
        endif

        if (automaticAbility != 0) then
            call IssueImmediateOrderById(triggerUnitSelf, GetAbilityOrder(automaticAbility, 1))
        endif

        call TriggerEvents_Static(isTriggerUnitHero, isTriggerUnitNotIllusion, triggerUnit, triggerUnitOwner, triggerUnitType)

        set triggerUnitOwner = null
        set triggerUnitSelf = null
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope