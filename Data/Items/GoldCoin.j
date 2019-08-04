//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("GoldCoin")
    globals
        public constant integer ITEM_ID = 'I00V'

        private constant integer GOLD_AMOUNT_HIGH = 125
        private constant integer GOLD_AMOUNT_LOW = 75
        private constant string SPECIAL_EFFECT_PATH = "Abilities\\Spells\\Items\\ResourceItems\\ResourceEffectTarget.mdl"
    endglobals

    public function PickUp takes item coin, Unit manipulatingUnit returns nothing
        local real coinX = GetItemX( coin )
        local real coinY = GetItemY( coin )
        local real coinZ = GetItemZ( coin, coinX, coinY )
        local texttag dropTextTag
        local integer goldAmount
        local player manipulatingUnitOwner = manipulatingUnit.owner
        local unit manipulatingUnitSelf = manipulatingUnit.self
        local real manipulatingUnitX = GetUnitX(manipulatingUnitSelf)
        local real manipulatingUnitY = GetUnitY(manipulatingUnitSelf)
        local integer salesAbilityLevel = GetUnitAbilityLevel( manipulatingUnit.self, Sales_SPELL_ID )
        set manipulatingUnitSelf = null
        if ( salesAbilityLevel > 0 ) then
            set goldAmount = R2I( GetRandomInt(GOLD_AMOUNT_LOW, GOLD_AMOUNT_HIGH) * ( 1 + Sales_BONUS_GOLD_COIN_RELATIVE[salesAbilityLevel] + GetHeroIntelligenceTotal( manipulatingUnit ) * Sales_BONUS_GOLD_COIN_RELATIVE_PER_INTELLIGENCE_POINT[salesAbilityLevel] ) )
        else
            set goldAmount = GetRandomInt(GOLD_AMOUNT_LOW, GOLD_AMOUNT_HIGH)
        endif
        set dropTextTag = CreateRisingTextTag( "+" + I2S( goldAmount ), 0.024, manipulatingUnitX, manipulatingUnitY, GetUnitZ(manipulatingUnitSelf, manipulatingUnitX, manipulatingUnitY), 80, 255, 204, 0, 255, 0, 3 )
        call SetPlayerState( manipulatingUnitOwner, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState( manipulatingUnitOwner, PLAYER_STATE_RESOURCE_GOLD ) + goldAmount )
        call DestroyEffectWJ( AddSpecialEffectWJ( SPECIAL_EFFECT_PATH, coinX, coinY ) )
        call PlaySoundFromTypeAtPositionForPlayer( RECEIVE_GOLD_SOUND_TYPE, coinX, coinY, coinZ, manipulatingUnitOwner )
        if ( dropTextTag != null ) then
            call LimitTextTagVisibilityToPlayer( dropTextTag, manipulatingUnitOwner )
            set dropTextTag = null
        endif
        set CoinIsPickedUp_AMOUNT = goldAmount
        set TRIGGER_PLAYER = manipulatingUnitOwner
        set manipulatingUnitOwner = null
        call RunTrigger(CoinIsPickedUp_DUMMY_TRIGGER)
    endfunction

    public function Init takes nothing returns nothing
        call InitItemTypeEx( ITEM_ID )
        call InitEffectType( SPECIAL_EFFECT_PATH )
    endfunction
//! runtextmacro Endscope()