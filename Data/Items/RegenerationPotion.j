//TESH.scrollpos=12
//TESH.alwaysfold=0
//! runtextmacro Scope("RegenerationPotion")
    globals
        public constant integer ITEM_ID = 'I011'
        public constant integer SPELL_ID = 'A045'

        private constant real REFRESHED_LIFE = 185.
        private constant real REFRESHED_MANA = 185.
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Items\\AIre\\AIreTarget.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "origin"
    endglobals

    public function SpellEffect takes Unit caster returns nothing
        local unit casterSelf = caster.self
        call DestroyEffectTimed( AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, casterSelf, TARGET_EFFECT_ATTACHMENT_POINT ), 2 )
        call HealUnitBySpell( caster, REFRESHED_LIFE )
        call AddUnitState( casterSelf, UNIT_STATE_MANA, REFRESHED_MANA )
        set casterSelf = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 150)
        call SetItemTypeMaxCharges(d, 3)
        call SetItemTypeRefreshInterval(d, 30)
        call SetItemTypeRefreshIntervalStart(d, 60)

        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call InitEffectType( TARGET_EFFECT_PATH )
    endfunction
//! runtextmacro Endscope()