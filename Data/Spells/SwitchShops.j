//TESH.scrollpos=18
//TESH.alwaysfold=0
//! runtextmacro Scope("SwitchShops")
    globals
        private constant integer ORDER_ID = 854299//OrderId( "spiritlink" )
        public constant integer SPELL_ID = 'A07T'

        private constant string SPECIAL_EFFECT_PATH = "Abilities\\Spells\\Demon\\DarkPortal\\DarkPortalTarget.mdl"
    endglobals

    public function SpellEffect takes player casterOwner returns nothing
        local integer casterTeam = GetPlayerTeam(casterOwner)
        local unit goblinShopSelf = GOBLIN_SHOPS[casterTeam].self
        local real goblinShopX = GetUnitX(goblinShopSelf)
        local real goblinShopY = GetUnitY(goblinShopSelf)
        local Unit shredder = SHREDDERS[casterTeam]
        local real shredderX = SHREDDERS_X[casterTeam]
        local real shredderY = SHREDDERS_Y[casterTeam]
        local unit workshopSelf = WORKSHOPS[casterTeam].self
        local real workshopX = GetUnitX(workshopSelf)
        local real workshopY = GetUnitY(workshopSelf)
        call DestroyEffectWJ(AddSpecialEffectWJ(SPECIAL_EFFECT_PATH, workshopX, workshopY))
        call SetUnitPosition(goblinShopSelf, workshopX, workshopY)
        set goblinShopSelf = null
        call DestroyEffectWJ(AddSpecialEffectWJ(SPECIAL_EFFECT_PATH, goblinShopX, goblinShopY))
        call SetUnitPosition(workshopSelf, goblinShopX, goblinShopY)
        set workshopSelf = null

        set SHREDDERS_X[casterTeam] = goblinShopX
        set SHREDDERS_Y[casterTeam] = goblinShopY
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER.owner )
    endfunction

    public function Init takes nothing returns nothing
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()