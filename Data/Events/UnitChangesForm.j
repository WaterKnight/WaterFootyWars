//TESH.scrollpos=74
//TESH.alwaysfold=0
scope UnitChangesForm
    globals
        public trigger DUMMY_TRIGGER
    endglobals

    private function TriggerEvents_Static takes Unit triggerUnit returns nothing
        call Burrow_FormChange(triggerUnit)

        call Shop_FormChange(triggerUnit, triggerUnit.type.id)
    endfunction

    public function Start takes Unit triggerUnit, UnitType triggerUnitType, UnitType oldTriggerUnitType returns nothing
        local integer heroStatsFactor
        local boolean isTriggerUnitNotIllusion = ( IsUnitIllusionWJ( triggerUnit ) == false )
        local integer iteration
        local integer requiredResearchTypeId
        local integer specificAbility
        local player triggerUnitOwner = triggerUnit.owner
        local unit triggerUnitSelf = triggerUnit.self
        local boolean isTriggerUnitHero = IsUnitType(triggerUnitSelf, UNIT_TYPE_HERO)

        set triggerUnit.type = triggerUnitType

        if ( isTriggerUnitNotIllusion ) then
            call AddUnitArmor( triggerUnit, GetUnitTypeArmor( triggerUnitType ) + GetUnitTypeArmorForPlayer( triggerUnitType, triggerUnitOwner ) - (GetUnitTypeArmor( oldTriggerUnitType ) + GetUnitTypeArmorForPlayer( oldTriggerUnitType, triggerUnitOwner )) )
        endif

        call AddUnitAttackRate( triggerUnit, GetUnitTypeAttackRateForPlayer( triggerUnitType, triggerUnitOwner ) - ( GetUnitTypeAttackRateForPlayer( oldTriggerUnitType, triggerUnitOwner ) ) )

        call SetUnitBlood( triggerUnit, GetUnitTypeBlood(triggerUnitType) )
        call SetUnitBloodExplosion( triggerUnit, GetUnitTypeBloodExplosion(triggerUnitType) )

        call AddUnitCanNotBeRevivedByAmount(triggerUnit, B2I(IsUnitTypeCanNotBeRevived(triggerUnitType)) - B2I(IsUnitTypeCanNotBeRevived(oldTriggerUnitType)))

        call AddUnitCriticalStrike( triggerUnit, GetUnitTypeCriticalStrikeForPlayer( triggerUnitType, triggerUnitOwner ) - GetUnitTypeCriticalStrikeForPlayer( oldTriggerUnitType, triggerUnitOwner ) )

        if ( isTriggerUnitNotIllusion ) then
            call AddUnitDamage( triggerUnit, GetUnitTypeDamage( triggerUnitType ) + GetUnitTypeDamageForPlayer( triggerUnitType, triggerUnitOwner ) - (GetUnitTypeDamage( oldTriggerUnitType ) + GetUnitTypeDamageForPlayer( oldTriggerUnitType, triggerUnitOwner )) )
        endif

        call AddUnitDecayByAmount(triggerUnit, B2I(IsUnitTypeDecay(triggerUnitType)) - B2I(IsUnitTypeDecay(oldTriggerUnitType)))
        call AddUnitDecayTime(triggerUnit, GetUnitTypeDecayTime(triggerUnitType) - GetUnitTypeDecayTime(oldTriggerUnitType))

        call AddUnitImpactZ(triggerUnit, GetUnitTypeImpactZ(triggerUnitType) - GetUnitTypeImpactZ(oldTriggerUnitType))
        call AddUnitOutpactZ(triggerUnit, GetUnitTypeOutpactZ(triggerUnitType) - GetUnitTypeOutpactZ(oldTriggerUnitType))

        if ( isTriggerUnitNotIllusion ) then
            call AddUnitMaxLife( triggerUnit, GetUnitTypeMaxLife( triggerUnitType ) + GetUnitTypeMaxLifeForPlayer( triggerUnitType, triggerUnitOwner ) - (GetUnitTypeMaxLife( oldTriggerUnitType ) + GetUnitTypeMaxLifeForPlayer( oldTriggerUnitType, triggerUnitOwner )) )
            call AddUnitMaxMana( triggerUnit, GetUnitTypeMaxMana( triggerUnitType ) + GetUnitTypeMaxManaForPlayer( triggerUnitType, triggerUnitOwner ) - (GetUnitTypeMaxMana( oldTriggerUnitType ) + GetUnitTypeMaxManaForPlayer( oldTriggerUnitType, triggerUnitOwner )) )

            call AddUnitLifeRegeneration( triggerUnit, GetUnitTypeLifeRegeneration( triggerUnitType ) + GetUnitTypeLifeRegenerationForPlayer( triggerUnitType, triggerUnitOwner ) - (GetUnitTypeLifeRegeneration( oldTriggerUnitType ) + GetUnitTypeLifeRegenerationForPlayer( oldTriggerUnitType, triggerUnitOwner )) )
            call AddUnitManaRegeneration( triggerUnit, GetUnitTypeManaRegeneration( triggerUnitType ) + GetUnitTypeManaRegenerationForPlayer( triggerUnitType, triggerUnitOwner ) - (GetUnitTypeManaRegeneration( oldTriggerUnitType ) + GetUnitTypeManaRegenerationForPlayer( oldTriggerUnitType, triggerUnitOwner )) )
        endif

        call AddUnitSightRange( triggerUnit, GetUnitTypeSightRange(triggerUnitType) - GetUnitTypeSightRange(oldTriggerUnitType) )

        call AddUnitSpeed( triggerUnit, GetUnitTypeSpeed( triggerUnitType ) + GetUnitTypeSpeedForPlayer( triggerUnitType, triggerUnitOwner ) - (GetUnitTypeSpeed( oldTriggerUnitType ) + GetUnitTypeSpeedForPlayer( oldTriggerUnitType, triggerUnitOwner )) )

        if ( isTriggerUnitHero ) then
            set heroStatsFactor = GetHeroLevel( triggerUnitSelf )
            set triggerUnit.level = heroStatsFactor
            set heroStatsFactor = heroStatsFactor - 1
            call SetUnitEP( triggerUnitSelf, GetUnitEP( triggerUnitSelf ) )
            call AddHeroAgility( triggerUnit, triggerUnitType, GetUnitTypeAgility(triggerUnitType) + heroStatsFactor * GetUnitTypeAgilityPerLevel(triggerUnitType) - (GetUnitTypeAgility(oldTriggerUnitType) + heroStatsFactor * GetUnitTypeAgilityPerLevel(oldTriggerUnitType)) )
            call AddHeroIntelligence( triggerUnit, triggerUnitType, GetUnitTypeIntelligence(triggerUnitType) + heroStatsFactor * GetUnitTypeIntelligencePerLevel(triggerUnitType) - (GetUnitTypeIntelligence(oldTriggerUnitType) + heroStatsFactor * GetUnitTypeIntelligencePerLevel(oldTriggerUnitType)) )
            call AddHeroStrength( triggerUnit, triggerUnitType, GetUnitTypeStrength(triggerUnitType) + heroStatsFactor * GetUnitTypeStrengthPerLevel(triggerUnitType) - (GetUnitTypeStrength(oldTriggerUnitType) + heroStatsFactor * GetUnitTypeStrengthPerLevel(oldTriggerUnitType)) )
        endif
        call AddUnitScale(triggerUnit, GetUnitTypeScale(triggerUnitType) - GetUnitTypeScale(oldTriggerUnitType))

        call AddUnitSupplyProduced( triggerUnit, triggerUnitOwner, GetUnitTypeSupplyProduced( triggerUnitType ) - GetUnitTypeSupplyProduced( oldTriggerUnitType ) )
        call AddUnitSupplyUsed( triggerUnit, triggerUnitOwner, GetUnitTypeSupplyUsed( triggerUnitType ) - GetUnitTypeSupplyUsed( oldTriggerUnitType ) )

        call AddUnitVertexColor( triggerUnit, GetUnitTypeVertexColorRed(triggerUnitType) - GetUnitTypeVertexColorRed(oldTriggerUnitType), GetUnitTypeVertexColorGreen(triggerUnitType) - GetUnitTypeVertexColorGreen(oldTriggerUnitType), GetUnitTypeVertexColorBlue(triggerUnitType) - GetUnitTypeVertexColorBlue(oldTriggerUnitType), GetUnitTypeVertexColorAlpha(triggerUnitType) - GetUnitTypeVertexColorAlpha(oldTriggerUnitType), null )

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

        call TriggerEvents_Static(triggerUnit)

        set triggerUnitOwner = null
        set triggerUnitSelf = null
    endfunction

    private function Trig takes nothing returns nothing
        local Unit triggerUnit = TRIGGER_UNIT
        local UnitType triggerUnitType = TRIGGER_UNIT_TYPE
        call Start(triggerUnit, triggerUnitType, triggerUnit.type)
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope