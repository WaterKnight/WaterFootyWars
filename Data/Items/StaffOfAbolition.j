//TESH.scrollpos=18
//TESH.alwaysfold=0
//! runtextmacro Scope("StaffOfAbolition")
    globals
        public constant integer ITEM_ID = 'I00F'
        public constant integer SPELL_ID = 'A01J'

        private constant string AREA_EFFECT_PATH = "Abilities\\Spells\\Other\\Silence\\SilenceAreaBirth.mdl"
        private constant real AREA_RANGE = 250.
        private constant real DAMAGE_SUMMON = 200.
        private group ENUM_GROUP
        private boolexpr TARGET_CONDITIONS
    endglobals

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        return true
    endfunction

    public function SpellEffect takes Unit caster, real targetX, real targetY returns nothing
        local Unit enumUnit
        local unit enumUnitSelf
        call DestroyEffectTimed( AddSpecialEffectWJ( AREA_EFFECT_PATH, targetX, targetY ), 2 )
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, targetX, targetY, AREA_RANGE, TARGET_CONDITIONS )
        set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
        if (enumUnitSelf != null) then
            loop
                set enumUnit = GetUnit(enumUnitSelf)
                call GroupRemoveUnit( ENUM_GROUP, enumUnitSelf )
                call DispelUnit( enumUnit, true, true, true )
                if (IsUnitType(enumUnitSelf, UNIT_TYPE_SUMMONED)) then
                    call UnitDamageUnitBySpell( caster, enumUnit, DAMAGE_SUMMON )
                endif
                set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnitSelf == null )
            endloop
        endif
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_X, TARGET_Y )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 200)
        call SetItemTypeMaxCharges(d, 2)
        call SetItemTypeRefreshInterval(d, 30)
        call SetItemTypeRefreshIntervalStart(d, 60)

        set ENUM_GROUP = CreateGroupWJ()
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( AREA_EFFECT_PATH )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()