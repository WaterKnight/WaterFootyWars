//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("Runes")
    globals
        public constant integer LIFE_RUNE_ITEM_ID = 'I012'
        public constant integer MANA_RUNE_ITEM_ID = 'I013'
        public constant integer SHIELD_RUNE_ITEM_ID = 'I01B'

        private constant string AREA_EFFECT_PATH = "RunesSpecial.mdl"
        private constant real AREA_RANGE = 600.
        private constant integer DUMMY_UNIT_ID = 'n02E'
        private group ENUM_GROUP
        private constant real FADE_TIME = 0.75
        private constant real LIFE_RELATIVE_REFRESHED_LIFE = 0.2
        private constant real LIFE_HERO_RELATIVE_REFRESHED_LIFE = 0.1
        private constant string LIFE_TARGET_EFFECT_PATH = "Abilities\\Spells\\Items\\AIhe\\AIheTarget.mdl"
        private constant string LIFE_TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        private constant real MANA_RELATIVE_REFRESHED_MANA = 0.2
        private constant real MANA_HERO_RELATIVE_REFRESHED_MANA = 0.2
        private constant string MANA_TARGET_EFFECT_PATH = "Abilities\\Spells\\Items\\AIma\\AImaTarget.mdl"
        private constant string MANA_TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        public integer array RUNES
        public integer RUNES_COUNT = -1
        private constant real SHIELD_DURATION = 5
        private constant real SHIELD_HERO_DURATION = 2.5
        private boolexpr TARGET_CONDITIONS
    endglobals

    private struct Data
        unit dummyUnit
    endstruct

    private function Ending takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, Runes_SCOPE_ID)
        local unit dummyUnit = d.dummyUnit
        call DestroyDummyScale( dummyUnit )
        call DestroyDummyVertexColor( dummyUnit )
        call RemoveUnitWJ( dummyUnit )
        set dummyUnit = null
        call FlushAttachedInteger( durationTimer, Runes_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) == false ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        return true
    endfunction

    public function PickUp takes Unit caster, item rune, integer runeTypeId returns nothing
        local Data d = Data.create()
        local timer durationTimer = CreateTimerWJ()
        local unit enumUnit
        local real runeX = GetItemX( rune )
        local real runeY = GetItemY( rune )
        local unit dummyUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, DUMMY_UNIT_ID, runeX, runeY, GetRandomReal( 0, 2 * PI ) )
        local real runeZ = GetItemZ( rune, runeX, runeY )
        local real runeVertexColorRed
        local real runeVertexColorGreen
        local real runeVertexColorBlue
        if ( runeTypeId == LIFE_RUNE_ITEM_ID ) then
            set runeVertexColorRed = 255
            set runeVertexColorGreen = 255
            set runeVertexColorBlue = 0
        elseif ( runeTypeId == MANA_RUNE_ITEM_ID ) then
            set runeVertexColorRed = 0
            set runeVertexColorGreen = 255
            set runeVertexColorBlue = 255
        else
            set runeVertexColorRed = 255
            set runeVertexColorGreen = 0
            set runeVertexColorBlue = 255
        endif
        call DestroyEffectWJ( AddSpecialEffectWJ( AREA_EFFECT_PATH, runeX, runeY ) )
        call PlaySoundFromTypeAtPosition( REFRESH_SOUND_TYPE, runeX, runeY, runeZ )
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, runeX, runeY, AREA_RANGE, TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit != null ) then
            if ( runeTypeId == LIFE_RUNE_ITEM_ID ) then
                loop
                    call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                    call DestroyEffectTimed( AddSpecialEffectTargetWJ( LIFE_TARGET_EFFECT_PATH, enumUnit, LIFE_TARGET_EFFECT_ATTACHMENT_POINT ), 2 )
                    if ( IsUnitType( enumUnit, UNIT_TYPE_HERO ) ) then
                        call HealUnitBySpell( GetUnit(enumUnit), GetUnitState( enumUnit, UNIT_STATE_MAX_LIFE ) * LIFE_HERO_RELATIVE_REFRESHED_LIFE )
                    else
                        call HealUnitBySpell( GetUnit(enumUnit), GetUnitState( enumUnit, UNIT_STATE_MAX_LIFE ) * LIFE_RELATIVE_REFRESHED_LIFE )
                    endif
                    set enumUnit = FirstOfGroup( ENUM_GROUP )
                    exitwhen ( enumUnit == null )
                endloop
            elseif ( runeTypeId == MANA_RUNE_ITEM_ID ) then
                loop
                    call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                    call DestroyEffectWJ( AddSpecialEffectTargetWJ( MANA_TARGET_EFFECT_PATH, enumUnit, MANA_TARGET_EFFECT_ATTACHMENT_POINT ) )
                    if ( IsUnitType( enumUnit, UNIT_TYPE_HERO ) ) then
                        call AddUnitState( enumUnit, UNIT_STATE_MANA, GetUnitState( enumUnit, UNIT_STATE_MAX_MANA ) * MANA_HERO_RELATIVE_REFRESHED_MANA )
                    else
                        call AddUnitState( enumUnit, UNIT_STATE_MANA, GetUnitState( enumUnit, UNIT_STATE_MAX_MANA ) * MANA_RELATIVE_REFRESHED_MANA )
                    endif
                    set enumUnit = FirstOfGroup( ENUM_GROUP )
                    exitwhen ( enumUnit == null )
                endloop
            else
                loop
                    call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                    if ( IsUnitType( enumUnit, UNIT_TYPE_HERO ) ) then
                        call SetUnitInvulnerabilityTimed( GetUnit(enumUnit), SHIELD_HERO_DURATION )
                    else
                        call SetUnitInvulnerabilityTimed( GetUnit(enumUnit), SHIELD_DURATION )
                    endif
                    set enumUnit = FirstOfGroup( ENUM_GROUP )
                    exitwhen ( enumUnit == null )
                endloop
            endif
        endif
        set d.dummyUnit = dummyUnit
        call AttachInteger( durationTimer, Runes_SCOPE_ID, d )
        call SetUnitAnimationByIndex( dummyUnit, 3 )
        call InitDummyScale( dummyUnit, 1 )
        call AddDummyScaleTimed(dummyUnit, 4, FADE_TIME)
        call InitDummyVertexColor( dummyUnit, runeVertexColorRed, runeVertexColorGreen, runeVertexColorBlue, 255 )
        call AddDummyVertexColorTimed( dummyUnit, 0, 0, 0, -255, FADE_TIME )
        call TimerStart( durationTimer, FADE_TIME, false, function Ending )
        set durationTimer = null
    endfunction

    public function PickUp_Conditions takes integer runeTypeId returns boolean
        return ((runeTypeId == LIFE_RUNE_ITEM_ID) or (runeTypeId == MANA_RUNE_ITEM_ID) or (runeTypeId == SHIELD_RUNE_ITEM_ID))
    endfunction

    private function AddRune takes integer whichRune returns nothing
        set RUNES_COUNT = RUNES_COUNT + 1
        set RUNES[RUNES_COUNT] = whichRune
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d
        set ENUM_GROUP = CreateGroupWJ()
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( AREA_EFFECT_PATH )

        set d = InitItemTypeEx(LIFE_RUNE_ITEM_ID)
        call SetItemTypeGoldCost(d, 50)
        call SetItemTypeMaxCharges(d, 4)
        call SetItemTypeRefreshInterval(d, 30)
        call SetItemTypeRefreshIntervalStart(d, 90)
        call AddRune( LIFE_RUNE_ITEM_ID )

        call InitEffectType( LIFE_TARGET_EFFECT_PATH )

        set d = InitItemTypeEx(MANA_RUNE_ITEM_ID)
        call SetItemTypeGoldCost(d, 50)
        call SetItemTypeMaxCharges(d, 3)
        call SetItemTypeRefreshInterval(d, 20)
        call SetItemTypeRefreshIntervalStart(d, 70)
        call AddRune( MANA_RUNE_ITEM_ID )

        call InitEffectType( MANA_TARGET_EFFECT_PATH )

        call InitItemTypeEx(SHIELD_RUNE_ITEM_ID)
        call AddRune( SHIELD_RUNE_ITEM_ID )
    endfunction
//! runtextmacro Endscope()