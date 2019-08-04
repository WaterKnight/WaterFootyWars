//TESH.scrollpos=12
//TESH.alwaysfold=0
//! runtextmacro Scope("ExperimentalElixir")
    globals
        public constant integer ITEM_ID = 'I01A'
        public constant integer SPELL_ID = 'A07J'

        private constant integer BONUS_EP = 50
        private constant string CASTER_EFFECT_PATH = "Abilities\\Spells\\Human\\Polymorph\\PolyMorphTarget.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "head"
    endglobals

    public function SpellEffect takes Unit caster returns nothing
        local unit casterSelf = caster.self
        call DestroyEffectWJ( AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, casterSelf, CASTER_EFFECT_ATTACHMENT_POINT ) )
        call AddUnitEP( casterSelf, BONUS_EP )
        set casterSelf = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 500)
        call SetItemTypeMaxCharges(d, 5)
        call SetItemTypeRefreshInterval(d, 30)
        call SetItemTypeRefreshIntervalStart(d, 30)

        call InitEffectType( CASTER_EFFECT_PATH )
        call InitItemType( ITEM_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()