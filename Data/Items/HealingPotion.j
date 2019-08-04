//TESH.scrollpos=8
//TESH.alwaysfold=0
//! runtextmacro Scope("HealingPotion")
    globals
        public constant integer ITEM_ID = 'I00U'
        public constant integer SPELL_ID = 'A02E'

        private constant real REFRESHED_LIFE = 350.
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Human\\Heal\\HealTarget.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "origin"
    endglobals

    public function SpellEffect takes Unit caster returns nothing
        call DestroyEffectTimed( AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, caster.self, TARGET_EFFECT_ATTACHMENT_POINT ), 2 )
        call HealUnitBySpell( caster, REFRESHED_LIFE )
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 175)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 60)
        call SetItemTypeRefreshIntervalStart(d, 60)

        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call InitEffectType( TARGET_EFFECT_PATH )
    endfunction
//! runtextmacro Endscope()