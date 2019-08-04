//TESH.scrollpos=12
//TESH.alwaysfold=0
//! runtextmacro Scope("SpiderEgg")
    globals
        public constant integer ITEM_ID = 'I008'
        public constant integer SPELL_ID = 'A01D'

        private constant real DURATION = 80.
        private constant string SPECIAL_EFFECT_PATH = "Abilities\\Spells\\Orc\\FeralSpirit\\feralspirittarget.mdl"
    endglobals

    public function SpellEffect takes Unit caster returns nothing
        local unit casterSelf = caster.self
        local Unit spawn = CreateUnitEx( caster.owner, SPOUT_SPIDER_UNIT_ID, GetUnitX(casterSelf), GetUnitY(casterSelf), GetUnitFacingWJ(casterSelf) )
        local unit spawnSelf = spawn.self
        set casterSelf = null
        call DestroyEffectWJ( AddSpecialEffectWJ( SPECIAL_EFFECT_PATH, GetUnitX(spawnSelf), GetUnitY(spawnSelf) ) )
        call UnitApplyTimedLifeWJ( spawnSelf, DURATION )
        set spawnSelf = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 350)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 50)
        call SetItemTypeRefreshIntervalStart(d, 150)

        call InitEffectType( SPECIAL_EFFECT_PATH )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()