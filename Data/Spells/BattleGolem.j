//TESH.scrollpos=15
//TESH.alwaysfold=0
//! runtextmacro Scope("BattleGolem")
    globals
        private constant integer ORDER_ID = 852658//OrderId( "summonfactory" )
        public constant integer SPELL_ID = 'A032'
    endglobals

    private function Release takes nothing returns nothing
        local integer ReleaseTimer = GetExpiredTimerWJ()
        local integer Golem = GetAttachedInteger( ReleaseTimer, "Golem" )
        call FlushAttachedInteger( ReleaseTimer, "Golem" )
        call DestroyTimerWJ( ReleaseTimer )
        call SetUnitPauseWJ( Golem, false )
        call SetUnitInvulnerabilityWJ( Golem, false )
        call SetUnitBlendTimeWJ( Golem, 0.15 )
        call SetUnitAnimationByIndexWJ( Golem, 0 )
        call UnitApplyTimedLifeWJ( Golem, GetAttachedReal( BattleGolem_Id(), "Duration" ) )
    endfunction

    public function SpellEffect takes integer Caster returns nothing
        local integer AbilityLevel = GetUnitAbilityLevelWJ( Caster, BattleGolem_Id() )
        local real CasterAngle = GetUnitFacingWJ( Caster )
        local real CasterX = GetUnitXWJ( Caster )
        local real CasterY = GetUnitYWJ( Caster )
        local integer Golem = CreateUnitEx( GetOwningPlayerWJ( Caster ), GetAttachedInteger( BattleGolem_Id(), "UnitTypeId" + I2S( AbilityLevel ) ), CasterX, CasterY, CasterAngle )
        local integer ReleaseTimer = CreateTimerWJ()
        call DestroyEffectWJ( AddSpecialEffectWJ( GetAttachedString( BattleGolem_Id(), "GraphicSpecial" ), GetUnitXWJ( Golem ), GetUnitYWJ( Golem ) ) )
        call SetUnitBlendTimeWJ( Golem, 0 )
        call SetUnitAnimationByIndexWJ( Golem, 9 )
        call SetUnitPauseWJ( Golem, true )
        call SetUnitInvulnerabilityWJ( Golem, true )
        call AttachInteger( ReleaseTimer, "Golem", Golem )
        call TimerStartWJ( ReleaseTimer, GetAttachedReal( BattleGolem_Id(), "ReleaseTime" ), false, function BattleGolem_Release )
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call BattleGolem_SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        local string GraphicSpecial = "Abilities\\Spells\\Orc\\FeralSpirit\\feralspirittarget.mdl"
        call AttachReal( BattleGolem_Id(), "Duration", 120 )
        call AttachString( BattleGolem_Id(), "GraphicSpecial", GraphicSpecial )
        call AttachReal( BattleGolem_Id(), "ReleaseTime", 1.634 )
        call AttachInteger( BattleGolem_Id(), "UnitTypeId1", 'n018' )
        call AttachInteger( BattleGolem_Id(), "UnitTypeId2", 'n019' )
        call AttachInteger( BattleGolem_Id(), "UnitTypeId3", 'n01A' )
        call InitEffectType( GraphicSpecial )
        call AddOrderAbility( BattleGolem_OrderId(), BattleGolem_Id() )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()