//TESH.scrollpos=59
//TESH.alwaysfold=0
//! runtextmacro Scope("Cannibalism")
    globals
        public constant integer RESEARCH_ID = 'A08O'
        public constant integer SPELL_ID = 'A08O'

        private constant real AREA_RANGE = 400.
        private group ENUM_GROUP
        private constant real REFRESHED_LIFE_FACTOR = 10.
        private constant real REFRESHED_LIFE_LOWER_CAP = 50.
        private constant string SPECIAL_EFFECT_PATH = "Abilities\\Spells\\Undead\\DeathPact\\DeathPactTarget.mdl"
        private boolexpr TARGET_CONDITIONS
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Undead\\DeathPact\\DeathPactCaster.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "origin"
    endglobals

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if (IsUnitAlly(FILTER_UNIT_SELF, TEMP_PLAYER) == false) then
            return false
        endif
        if (IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_UNDEAD ) == false) then
            return false
        endif
        return true
    endfunction

    public function Death takes Unit caster, real casterX, real casterY returns nothing
        local integer casterId = caster.id
        local unit enumUnit
        local real refreshedLife
        if ( GetAttachedBooleanById( casterId, Cannibalism_SCOPE_ID ) ) then
            call FlushAttachedBooleanById(casterId, Cannibalism_SCOPE_ID)
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
            set TEMP_PLAYER = caster.owner
            call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, casterX, casterY, AREA_RANGE, TARGET_CONDITIONS )
            set enumUnit = FirstOfGroup(ENUM_GROUP)
            if (enumUnit != null) then
                set refreshedLife = Max(REFRESHED_LIFE_LOWER_CAP, GetUnitArmorTotal( caster ) * REFRESHED_LIFE_FACTOR)
                call DestroyEffectWJ( AddSpecialEffectWJ( SPECIAL_EFFECT_PATH, casterX, casterY ) )
                loop
                    call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                    call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, enumUnit, TARGET_EFFECT_ATTACHMENT_POINT ) )
                    call HealUnitBySpell( GetUnit(enumUnit), refreshedLife )
                    set enumUnit = FirstOfGroup(ENUM_GROUP)
                    exitwhen ( enumUnit == null )
                endloop
            endif
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        local unit dyingUnitSelf = DYING_UNIT.self
        call Death( DYING_UNIT, GetUnitX(dyingUnitSelf), GetUnitY(dyingUnitSelf) )
        set dyingUnitSelf = null
    endfunction

    public function Learn takes Unit caster returns nothing
        local integer casterId = caster.id
        call AttachBooleanById( casterId, Cannibalism_SCOPE_ID, true )
        //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 300)

        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( SPECIAL_EFFECT_PATH )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
    endfunction
//! runtextmacro Endscope()