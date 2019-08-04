//TESH.scrollpos=129
//TESH.alwaysfold=0
//! runtextmacro Scope("GhostTakeOver")
    globals
        private constant integer ORDER_ID = 852581//OrderId( "charm" )
        public constant integer SPELL_ID = 'A00S'

        private real array AREA_RANGE
        private real array DURATION
        private group ENUM_GROUP
        private boolexpr TARGET_CONDITIONS
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Undead\\Possession\\PossessionMissile.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "origin"
    endglobals

    //! runtextmacro Scope("Cooldown")
        globals
            private real array Cooldown_DURATION
            private real array Cooldown_DURATION_PER_INTELLIGENCE_POINT
        endglobals

        private struct Cooldown_Data
            integer abilityLevel
            Unit caster
        endstruct

        private function Cooldown_Ending takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Cooldown_Data d = GetAttachedInteger(durationTimer, Cooldown_SCOPE_ID)
            local integer abilityLevel = d.abilityLevel
            local Unit caster = d.caster
            local unit casterSelf = caster.self
            local player casterOwner = caster.owner
            call d.destroy()
            call DestroyTimerWJ( durationTimer )
            set durationTimer = null
            if ( IsUnitSelected( casterSelf, casterOwner ) ) then
                call PlaySoundFromTypeForPlayer( COOLDOWN_SOUND_TYPE, casterOwner )
            endif
            set casterOwner = null
            call UnitAddAbility(casterSelf, SPELL_ID)
            call SetUnitAbilityLevel( casterSelf, SPELL_ID, abilityLevel )
            set casterSelf = null
        endfunction

        private function Cooldown_PreEnding takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Cooldown_Data d = GetAttachedInteger(durationTimer, Cooldown_SCOPE_ID)
            local Unit caster = d.caster
            local unit casterSelf = caster.self
            local integer abilityLevel = GetUnitAbilityLevel( casterSelf, SPELL_ID )
            set d.abilityLevel = abilityLevel
            call UnitRemoveAbility( casterSelf, SPELL_ID )
            set casterSelf = null
            call TimerStart( durationTimer, 0.5, false, function Cooldown_Ending )
            set durationTimer = null
        endfunction

        public function Cooldown_Start takes integer abilityLevel, Unit caster returns nothing
            local timer durationTimer = CreateTimerWJ()
            local Cooldown_Data d = Cooldown_Data.create()
            set d.caster = caster
            call AttachInteger( durationTimer, Cooldown_SCOPE_ID, d )
            call TimerStart( durationTimer, Cooldown_DURATION[abilityLevel] + GetHeroIntelligenceTotal( caster ) * Cooldown_DURATION_PER_INTELLIGENCE_POINT[abilityLevel] - 0.5, false, function Cooldown_PreEnding )
            set durationTimer = null
        endfunction

        public function Cooldown_Init takes nothing returns nothing
            set Cooldown_DURATION[1] = 100
            set Cooldown_DURATION[2] = 80
            set Cooldown_DURATION_PER_INTELLIGENCE_POINT[1] = -0.75
            set Cooldown_DURATION_PER_INTELLIGENCE_POINT[2] = -0.75
        endfunction
    //! runtextmacro Endscope()

    private function TargetConditions takes nothing returns boolean
        local UnitType filterUnitType
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) ) then
            return false
        endif
        set FILTER_UNIT = GetUnit(FILTER_UNIT_SELF)
        if ( GetUnitInvulnerability( FILTER_UNIT ) > 0 ) then
            return false
        endif
        if ( GetUnitMagicImmunity( FILTER_UNIT ) > 0 ) then
            return false
        endif
        if ( GetUnitRevaluation(FILTER_UNIT) > 1 ) then
            return false
        endif
        if ( IsUnitWard( FILTER_UNIT ) ) then
            return false
        endif
        set filterUnitType = FILTER_UNIT.type
        if ( IsUnitTypeCaster(filterUnitType) ) then
            return false
        endif
        if ( IsUnitTypeSpawn(filterUnitType) == false ) then
            return false
        endif
        return true
    endfunction

    public function SpellEffect takes Unit caster, real targetX, real targetY returns nothing
        local integer abilityLevel = GetUnitAbilityLevel( caster.self, SPELL_ID )
        local player casterOwner = caster.owner
        local real duration
        local Unit enumUnit
        local unit enumUnitSelf
        set TEMP_PLAYER = casterOwner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, targetX, targetY, AREA_RANGE[abilityLevel], TARGET_CONDITIONS )
        set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
        if ( enumUnitSelf != null ) then
            set duration = DURATION[abilityLevel]
            loop
                set enumUnit = GetUnit(enumUnitSelf)
                call GroupRemoveUnit( ENUM_GROUP, enumUnitSelf )
                call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, enumUnitSelf, TARGET_EFFECT_ATTACHMENT_POINT ) )
                if ( IsUnitIllusionWJ( enumUnit ) ) then
                    call KillUnit( enumUnitSelf )
                else
                    call SetUnitOwnerEx( enumUnit, casterOwner, true )
                    call UnitApplyTimedLifeWJ( enumUnitSelf, duration )
                endif
                set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnitSelf == null )
            endloop
        endif
        call Cooldown_Cooldown_Start(abilityLevel, caster)
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_X, TARGET_Y )
    endfunction

    public function Init takes nothing returns nothing
        set AREA_RANGE[1] = 200
        set AREA_RANGE[2] = 200
        set DURATION[1] = 20
        set DURATION[2] = 30
        set ENUM_GROUP = CreateGroupWJ()
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( TARGET_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call Cooldown_Cooldown_Init()
    endfunction
//! runtextmacro Endscope()