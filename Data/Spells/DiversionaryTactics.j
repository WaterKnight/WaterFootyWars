//TESH.scrollpos=57
//TESH.alwaysfold=0
//! runtextmacro Scope("DiversionaryTactics")
    globals
        private constant integer ORDER_ID = 852662//OrderId( "acidbomb" )
        public constant integer SPELL_ID = 'A02C'

        private constant real AREA_RANGE = 700.
        private group ENUM_GROUP
        private integer HINTS_AMOUNT = 0
        private string array HINTS
        private boolexpr TARGET_CONDITIONS
    endglobals

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        set FILTER_UNIT = GetUnit(FILTER_UNIT_SELF)
        if ( IsUnitChanneling( FILTER_UNIT ) ) then
            return false
        endif
        if ( IsUnitEnemy( FILTER_UNIT_SELF, TEMP_PLAYER ) == false ) then
            return false
        endif
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitIllusionWJ( FILTER_UNIT ) ) then
            return false
        endif
        return true
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local real casterZ = GetUnitZ( casterSelf, casterX, casterY )
        local unit enumUnit
        call CreateRisingTextTag( HINTS[GetRandomInt(0, HINTS_AMOUNT - 1)], 0.026, casterX, casterY, casterZ + 175, 60, 255, 255, 255, 255, 1.5, 3 )
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, casterX, casterY, AREA_RANGE, TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if (enumUnit != null) then
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                call IssueTargetOrderById( enumUnit, ATTACK_ORDER_ID, casterSelf )
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
        set casterSelf = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    private function InitHint takes string text returns nothing
        set HINTS[HINTS_AMOUNT] = text
        set HINTS_AMOUNT = HINTS_AMOUNT + 1
    endfunction

    public function Init takes nothing returns nothing
        set ENUM_GROUP = CreateGroupWJ()
        call InitHint( "I love you!" )
        call InitHint( "Baka!" )
        call InitHint( "I have eaten all of your cookies!" )
        call InitHint( "Losers!" )
        call InitHint( "All signs point to me!" )
        call InitHint( "Come to mama!" )
        call InitHint( "Meet your maker!" )
        call InitHint( "!!! (need more content) !!!" )
        call InitHint( "Look in front of you, a one-headed monkey!" )
        call InitHint( "You cannot even do a kickflip!" )
        call InitHint( "How many of you are needed to change a bulb?!" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()