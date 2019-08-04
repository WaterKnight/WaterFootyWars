//TESH.scrollpos=12
//TESH.alwaysfold=0
//! runtextmacro Scope("ChimeraEgg")
    globals
        public constant integer ITEM_ID = 'I00D'
        public constant integer SPELL_ID = 'A01K'

        private constant real DURATION = 120.
        private constant string SPECIAL_EFFECT_PATH = "Abilities\\Spells\\Orc\\FeralSpirit\\feralspirittarget.mdl"
    endglobals

    public function SpellEffect takes Unit caster returns nothing
        local unit casterSelf = caster.self
        local Unit chimera = CreateUnitEx( caster.owner, CHIMERA_UNIT_ID, GetUnitX(casterSelf), GetUnitY(casterSelf), GetUnitFacingWJ(casterSelf) )
        local unit chimeraSelf = chimera.self
        set casterSelf = null
        call DestroyEffectWJ( AddSpecialEffectWJ( SPECIAL_EFFECT_PATH, GetUnitX( chimeraSelf ), GetUnitY(chimeraSelf) ) )
        call UnitApplyTimedLifeWJ( chimeraSelf, DURATION )
        set chimeraSelf = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 300)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 80)
        call SetItemTypeRefreshIntervalStart(d, 200)

        call InitEffectType( SPECIAL_EFFECT_PATH )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()