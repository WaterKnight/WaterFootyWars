//TESH.scrollpos=32
//TESH.alwaysfold=0
//! runtextmacro Scope("EsteemInCoins")
    globals
        private constant integer ORDER_ID = 852233//OrderId( "gold2lumber" )
        public constant integer SPELL_ID = 'A070'

        private constant string CASTER_EFFECT_PATH = "Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "origin"
        private constant integer GOLD_COST = 300
        private constant real RESTORED_MANA = 200.
        private constant string SPECIAL_EFFECT_PATH = "Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl"
        private constant string SPECIAL_EFFECT_ATTACHMENT_POINT = "origin"
    endglobals

    private function Conditions takes integer resultGold returns string
        if ( resultGold < 0 ) then
            return ErrorStrings_TOO_LESS_GOLD
        endif
        return null
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local player casterOwner = caster.owner
        local integer casterTeam
        local texttag newTextTag
        local integer resultGold = GetPlayerState( casterOwner, PLAYER_STATE_RESOURCE_GOLD ) - GOLD_COST
        local Unit wizard
        local unit wizardSelf
        local real wizardX
        local real wizardY
        if ( Conditions( resultGold ) == null ) then
            set casterTeam = GetPlayerTeam( casterOwner )
            set wizard = MASTER_WIZARDS[casterTeam]
            set wizardSelf = wizard.self
            set wizardX = GetUnitX(wizardSelf)
            set wizardY = GetUnitY(wizardSelf)
            call DestroyEffectWJ( AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, caster.self, CASTER_EFFECT_ATTACHMENT_POINT ) )
            call DestroyEffectWJ( AddSpecialEffectTargetWJ( SPECIAL_EFFECT_PATH, wizardSelf, SPECIAL_EFFECT_ATTACHMENT_POINT ) )
            call SetPlayerState( casterOwner, PLAYER_STATE_RESOURCE_GOLD, resultGold )
            set newTextTag = CreateRisingTextTag( "+" + I2S( R2I( RESTORED_MANA ) ), 0.024, wizardX, wizardY, GetUnitZ( wizardSelf, wizardX, wizardY ) + GetUnitOutpactZ(wizard), 80, 0, 0, 255, 255, 0, 3 )
            if ( newTextTag != null ) then
                call LimitTextTagVisibilityToTeam( newTextTag, casterTeam )
            endif
            set newTextTag = null
            call AddUnitState( wizardSelf, UNIT_STATE_MANA, RESTORED_MANA )
            set wizardSelf = null
        endif
        set casterOwner = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Order takes player casterOwner returns string
        return Conditions( GetPlayerState( casterOwner, PLAYER_STATE_RESOURCE_GOLD ) - GOLD_COST )
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( ORDERED_UNIT.owner )
    endfunction

    public function Init takes nothing returns nothing
        call InitEffectType( CASTER_EFFECT_PATH )
        call InitEffectType( SPECIAL_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()