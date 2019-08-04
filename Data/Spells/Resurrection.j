//TESH.scrollpos=157
//TESH.alwaysfold=0
//! runtextmacro Scope("Resurrection")
    globals
        private constant integer ORDER_ID = 852094//OrderId( "resurrection" )
        public constant integer SPELL_ID = 'A00D'

        private real array AREA_RANGE
        private group ENUM_GROUP
        private group ENUM_GROUP2
        private integer array MAX_TARGETS_AMOUNT
        private constant string SPECIAL_EFFECT_PATH = "Abilities\\Spells\\Human\\Resurrect\\ResurrectCaster.mdl"
        private boolexpr TARGET_CONDITIONS
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "origin"
    endglobals

    //! runtextmacro Scope("Cooldown")
        globals
            private real array Cooldown_DURATION
            private real array Cooldown_DURATION_PER_AGILITY_POINT
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
            local player casterOwner = caster.owner
            local unit casterSelf = caster.self
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
            call TimerStart( durationTimer, Cooldown_DURATION[abilityLevel] + GetHeroAgilityTotal( caster ) * Cooldown_DURATION_PER_AGILITY_POINT[abilityLevel] - 0.5, false, function Cooldown_PreEnding )
            set durationTimer = null
        endfunction

        public function Cooldown_Init takes nothing returns nothing
            set Cooldown_DURATION[1] = 120
            set Cooldown_DURATION[2] = 120
            set Cooldown_DURATION_PER_AGILITY_POINT[1] = -0.75
            set Cooldown_DURATION_PER_AGILITY_POINT[2] = -0.75
        endfunction
    //! runtextmacro Endscope()

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) > 0 ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) == false ) then
            return false
        endif
        set FILTER_UNIT = GetUnit(FILTER_UNIT_SELF)
        if ( GetUnitCanNotBeRevived(FILTER_UNIT) > 0 ) then
            return false
        endif
        if ( IsUnitTypeSpawn(FILTER_UNIT.type) == false ) then
            return false
        endif
        return true
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local unit casterSelf = caster.self
        local integer abilityLevel = GetUnitAbilityLevel( casterSelf, SPELL_ID )
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local integer currentLevel
        local Unit enumUnit
        local unit enumUnitSelf
        local integer enumUnitLevel
        local boolean found
        local integer iteration = MAX_TARGETS_AMOUNT[abilityLevel]
        local real newUnitAngle
        local Unit newUnit
        local player newUnitOwner
        local integer newUnitTypeId
        local real newUnitX
        local real newUnitY
        set casterSelf = null
        call DestroyEffect( AddSpecialEffect( SPECIAL_EFFECT_PATH, casterX, casterY ) )
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, casterX, casterY, AREA_RANGE[abilityLevel], TARGET_CONDITIONS )
        loop
            set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
            exitwhen ( enumUnitSelf == null )
            set found = false
            loop
                set enumUnit = GetUnit(enumUnitSelf)
                call GroupRemoveUnit( ENUM_GROUP, enumUnitSelf )
                call GroupAddUnit( ENUM_GROUP2, enumUnitSelf )
                set enumUnitLevel = GetUnitLevelWJ( enumUnit )
                if ( found == false ) then
                    set currentLevel = enumUnitLevel
                    set found = true
                elseif ( enumUnitLevel > currentLevel ) then
                    set currentLevel = enumUnitLevel
                endif
                set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnitSelf == null )
            endloop
            loop
                set enumUnitSelf = FirstOfGroup( ENUM_GROUP2 )
                set enumUnit = GetUnit(enumUnitSelf)
                exitwhen ( enumUnitSelf == null )
                call GroupRemoveUnit( ENUM_GROUP2, enumUnitSelf )
                if ( GetUnitLevelWJ( enumUnit ) == currentLevel ) then
                    set newUnitAngle = GetUnitFacingWJ( enumUnitSelf )
                    set newUnitOwner = enumUnit.owner
                    set newUnitTypeId = GetUnitTypeId( enumUnitSelf )
                    set newUnitX = GetUnitX( enumUnitSelf )
                    set newUnitY = GetUnitY( enumUnitSelf )
                    call RemoveUnitEx( enumUnit )
                    set newUnit = CreateUnitEx( newUnitOwner, newUnitTypeId, newUnitX, newUnitY, newUnitAngle )
                    call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, newUnit.self, TARGET_EFFECT_ATTACHMENT_POINT ) )
                    set iteration = iteration - 1
                else
                    call GroupAddUnit( ENUM_GROUP, enumUnitSelf )
                endif
            endloop
            exitwhen ( iteration < 1 )
        endloop
        set newUnitOwner = null
        call Cooldown_Cooldown_Start(abilityLevel, caster)
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Order takes unit caster, player casterOwner, real casterX, real casterY returns string
        local integer abilityLevel = GetUnitAbilityLevel( caster, SPELL_ID )
        set TEMP_PLAYER = casterOwner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, casterX, casterY, AREA_RANGE[abilityLevel], TARGET_CONDITIONS )
        if ( FirstOfGroup( ENUM_GROUP ) == null ) then
            return ErrorStrings_NO_CORPSES_FOUND
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        local unit casterSelf = ORDERED_UNIT.self
        set ERROR_MSG = Order( casterSelf, ORDERED_UNIT.owner, GetUnitX(casterSelf), GetUnitY(casterSelf) )
        set casterSelf = null
    endfunction

    public function Init takes nothing returns nothing
        set AREA_RANGE[1] = 1000
        set AREA_RANGE[2] = 1000
        set ENUM_GROUP = CreateGroupWJ()
        set ENUM_GROUP2 = CreateGroupWJ()
        set MAX_TARGETS_AMOUNT[1] = 6
        set MAX_TARGETS_AMOUNT[2] = 10
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( SPECIAL_EFFECT_PATH )
        call InitEffectType( TARGET_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call Cooldown_Cooldown_Init()
    endfunction
//! runtextmacro Endscope()