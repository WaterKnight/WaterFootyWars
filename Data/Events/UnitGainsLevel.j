//TESH.scrollpos=3
//TESH.alwaysfold=0
scope UnitGainsLevel
    globals
        public trigger DUMMY_TRIGGER
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Other\\Levelup\\LevelupCaster.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "origin"
    endglobals

    private function TriggerEvents_Static takes Unit leveler, player levelerOwner, integer newLevel returns nothing
        call EnergyGap_Aura_Aura_LevelGain_Before( leveler )

        call Infoboard_LevelGain( newLevel, leveler, levelerOwner )
    endfunction

    private function Trig takes nothing returns nothing
        local unit levelerSelf = GetLevelingUnit()
        local Unit leveler = GetUnit(levelerSelf)
        local UnitType levelerType = leveler.type
        local integer newLevel = GetHeroLevel( levelerSelf )
        local integer levelsRaisedAmount = newLevel - leveler.level
        if ( IsUnitIllusionWJ( leveler ) == false ) then
            call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, levelerSelf, TARGET_EFFECT_ATTACHMENT_POINT ) )
        endif
        set levelerSelf = null
        set leveler.level = newLevel

        call TriggerEvents_Static(leveler, leveler.owner, newLevel)

        call AddHeroAgility( leveler, levelerType, levelsRaisedAmount * GetUnitTypeAgilityPerLevel(levelerType) )
        call AddHeroIntelligence( leveler, levelerType, levelsRaisedAmount * GetUnitTypeIntelligencePerLevel(levelerType) )
        call AddHeroStrength( leveler, levelerType, levelsRaisedAmount * GetUnitTypeStrengthPerLevel(levelerType) )
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope