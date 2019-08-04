//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("FireBurst")
    globals
        private constant integer ORDER_ID = 852540//OrderId( "flamingattack" )
        public constant integer SPELL_ID = 'A004'

        private real array AREA_RANGE
        private real array DAMAGE
        private real array DAMAGE_PER_INTELLIGENCE_POINT
        private constant integer DUMMY_UNIT_ID = 'n004'
        private group ENUM_GROUP
        private real array EXPLOSION_AREA_RANGE
        private real array EXPLOSION_DAMAGE
        private real array EXPLOSION_DAMAGE_PER_STRENGTH_POINT
        private constant real MAX_LENGTH = 700.
        private constant string SPECIAL_EFFECT_PATH = "Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile.mdl"
        private constant string SPECIAL_EFFECT2_PATH = "Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl"
        private constant integer SPECIAL_EFFECTS_AMOUNT = 2
        private constant real SPEED = 1000.
        private constant real DURATION = MAX_LENGTH / SPEED
        private constant real SPECIAL_EFFECT_INTERVAL = DURATION / (SPECIAL_EFFECTS_AMOUNT + 1)
        private boolexpr TARGET_CONDITIONS
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeEmbers.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "head"
        private constant real UPDATE_TIME = 0.035
        private constant real LENGTH = SPEED * UPDATE_TIME
    endglobals

    private struct Data
        integer abilityLevel
        Unit caster
        real damageAmount
        unit dummyUnit
        timer durationTimer
        timer effectTimer
        real explosionDamageAmount
        real lengthX
        real lengthY
        group targetGroup
        timer updateTimer
        real x
        real y
    endstruct

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_FLYING ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        set FILTER_UNIT = GetUnit(FILTER_UNIT_SELF)
        if ( GetUnitInvulnerability( FILTER_UNIT ) > 0 ) then
            return false
        endif
        if ( GetUnitMagicImmunity( FILTER_UNIT ) > 0 ) then
            return false
        endif
        return true
    endfunction

    private function Ending takes Unit caster, Data d, unit dummyUnit, real x, real y, timer durationTimer, group targetGroup, timer updateTimer returns nothing
        local integer abilityLevel = d.abilityLevel
        local timer effectTimer = d.effectTimer
        local unit enumUnit
        local real explosionDamageAmount = d.explosionDamageAmount
        call d.destroy()
        call SetUnitAnimationByIndex( dummyUnit, 9 )
        call RemoveUnitTimed( dummyUnit, 2 )
        call FlushAttachedInteger( durationTimer, FireBurst_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        call FlushAttachedInteger( effectTimer, FireBurst_SCOPE_ID )
        call DestroyTimerWJ( effectTimer )
        set effectTimer = null
        call DestroyGroupWJ( targetGroup )
        call FlushAttachedInteger( updateTimer, FireBurst_SCOPE_ID )
        call DestroyTimerWJ( updateTimer )
        call DestroyEffectWJ( AddSpecialEffectWJ( SPECIAL_EFFECT2_PATH, x, y ) )
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, x, y, EXPLOSION_AREA_RANGE[abilityLevel], TARGET_CONDITIONS )
        loop
            set enumUnit = FirstOfGroup( ENUM_GROUP )
            exitwhen ( enumUnit == null )
            call GroupRemoveUnit( ENUM_GROUP, enumUnit )
            call UnitDamageUnitBySpell( caster, GetUnit(enumUnit), explosionDamageAmount )
        endloop
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, FireBurst_SCOPE_ID)
        call Ending( d.caster, d, d.dummyUnit, d.x, d.y, durationTimer, d.targetGroup, d.updateTimer )
        set durationTimer = null
    endfunction

    private function SpawnEffect takes nothing returns nothing
        local timer effectTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(effectTimer, FireBurst_SCOPE_ID)
        local unit dummyUnit = d.dummyUnit
        set effectTimer = null
        call DestroyEffectWJ( AddSpecialEffectWJ( SPECIAL_EFFECT_PATH, GetUnitX( dummyUnit ), GetUnitY( dummyUnit ) ) )
    endfunction

    private function Move takes nothing returns nothing
        local real damageAmount
        local unit enumUnit
        local timer updateTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(updateTimer, FireBurst_SCOPE_ID)
        local integer abilityLevel = d.abilityLevel
        local Unit caster = d.caster
        local unit dummyUnit = d.dummyUnit
        local real dummyUnitX = GetUnitX(dummyUnit)
        local real dummyUnitY = GetUnitY(dummyUnit)
        local real newX = d.x + d.lengthX
        local real newY = d.y + d.lengthY
        local boolean isEnding = IsTerrainPathable( newX, newY, PATHING_TYPE_WALKABILITY )
        local group targetGroup = d.targetGroup
        if ( isEnding == false ) then
            set d.x = newX
            set d.y = newY
            call SetUnitXWJ( dummyUnit, newX )
            call SetUnitYWJ( dummyUnit, newY )
        endif
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, newX, newY, AREA_RANGE[abilityLevel], TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit != null ) then
            set damageAmount = d.damageAmount
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                if (IsUnitInGroup(enumUnit, targetGroup) == false) then
                    call GroupAddUnit( targetGroup, enumUnit )
                    call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, enumUnit, TARGET_EFFECT_ATTACHMENT_POINT ) )
                    call UnitDamageUnitBySpell( caster, GetUnit(enumUnit), damageAmount )
                endif
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
        if ( isEnding ) then
            call Ending( caster, d, dummyUnit, dummyUnitX, dummyUnitY, d.durationTimer, targetGroup, updateTimer )
        endif
        set dummyUnit = null
        set targetGroup = null
        set updateTimer = null
    endfunction

    public function SpellEffect takes Unit caster, real targetX, real targetY returns nothing
        local real angle
        local unit casterSelf = caster.self
        local integer abilityLevel = GetUnitAbilityLevel( casterSelf, SPELL_ID )
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local Data d = Data.create()
        local timer durationTimer = CreateTimerWJ()
        local timer effectTimer = CreateTimerWJ()
        local timer updateTimer = CreateTimerWJ()
        if ( ( casterX != targetX ) or ( casterY != targetY ) ) then
            set angle = Atan2( targetY - casterY, targetX - casterX )
        else
            set angle = GetUnitFacingWJ( casterSelf )
        endif
        set casterSelf = null
        set d.abilityLevel = abilityLevel
        set d.caster = caster
        set d.damageAmount = DAMAGE[abilityLevel] + GetHeroIntelligenceTotal( caster ) * DAMAGE_PER_INTELLIGENCE_POINT[abilityLevel]
        set d.dummyUnit = CreateUnitWJ( caster.owner, DUMMY_UNIT_ID, casterX, casterY, angle )
        set d.durationTimer = durationTimer
        set d.explosionDamageAmount = EXPLOSION_DAMAGE[abilityLevel] + GetHeroStrengthTotal( caster ) * EXPLOSION_DAMAGE_PER_STRENGTH_POINT[abilityLevel]
        set d.effectTimer = effectTimer
        set d.lengthX = LENGTH * Cos( angle )
        set d.lengthY = LENGTH * Sin( angle )
        set d.targetGroup = CreateGroupWJ()
        set d.updateTimer = updateTimer
        set d.x = casterX
        set d.y = casterY
        call AttachInteger( durationTimer, FireBurst_SCOPE_ID, d )
        call AttachInteger( effectTimer, FireBurst_SCOPE_ID, d )
        call AttachInteger( updateTimer, FireBurst_SCOPE_ID, d )
        call TimerStart( updateTimer, UPDATE_TIME, true, function Move )
        set updateTimer = null
        call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
        set durationTimer = null
        call TimerStart( effectTimer, SPECIAL_EFFECT_INTERVAL, true, function SpawnEffect )
        set effectTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_X, TARGET_Y )
    endfunction

    public function Init takes nothing returns nothing
        set AREA_RANGE[1] = 150
        set AREA_RANGE[2] = 150
        set AREA_RANGE[3] = 150
        set AREA_RANGE[4] = 150
        set AREA_RANGE[5] = 150
        set DAMAGE[1] = 35
        set DAMAGE[2] = 45
        set DAMAGE[3] = 53
        set DAMAGE[4] = 61
        set DAMAGE[5] = 67
        set DAMAGE_PER_INTELLIGENCE_POINT[1] = 1
        set DAMAGE_PER_INTELLIGENCE_POINT[2] = 1
        set DAMAGE_PER_INTELLIGENCE_POINT[3] = 1
        set DAMAGE_PER_INTELLIGENCE_POINT[4] = 1
        set DAMAGE_PER_INTELLIGENCE_POINT[5] = 1
        set EXPLOSION_AREA_RANGE[1] = 250
        set EXPLOSION_AREA_RANGE[2] = 250
        set EXPLOSION_AREA_RANGE[3] = 250
        set EXPLOSION_AREA_RANGE[4] = 250
        set EXPLOSION_AREA_RANGE[5] = 250
        set EXPLOSION_DAMAGE[1] = 50
        set EXPLOSION_DAMAGE[2] = 65
        set EXPLOSION_DAMAGE[3] = 80
        set EXPLOSION_DAMAGE[4] = 90
        set EXPLOSION_DAMAGE[5] = 100
        set EXPLOSION_DAMAGE_PER_STRENGTH_POINT[1] = 2
        set EXPLOSION_DAMAGE_PER_STRENGTH_POINT[2] = 2
        set EXPLOSION_DAMAGE_PER_STRENGTH_POINT[3] = 2
        set EXPLOSION_DAMAGE_PER_STRENGTH_POINT[4] = 2
        set EXPLOSION_DAMAGE_PER_STRENGTH_POINT[5] = 2
        set ENUM_GROUP = CreateGroupWJ()
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitUnitType( DUMMY_UNIT_ID )
        call InitEffectType( SPECIAL_EFFECT_PATH )
        call InitEffectType( SPECIAL_EFFECT2_PATH )
        call InitEffectType( TARGET_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()