//TESH.scrollpos=173
//TESH.alwaysfold=0
//! runtextmacro Scope("FleshBomb")
    globals
        private constant integer ORDER_ID = 852223//OrderId( "deathpact" )
        public constant integer SPELL_ID = 'A00W'

        private real array AREA_RANGE
        private real array AREA_RANGE_PER_AGILITY_POINT
        private real array DAMAGE_HIGH_FACTOR
        private real array DAMAGE_LOW_FACTOR
        private constant real DURATION = 3.
        private group ENUM_GROUP
        private constant real INTERVAL_START = 0.5
        private constant real INTERVAL_END = 0.1
        private constant string SPECIAL_EFFECT_PATH = "Abilities\\Weapons\\Mortar\\MortarMissile.mdl"
        private boolexpr TARGET_CONDITIONS
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Other\\Incinerate\\IncinerateBuff.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "chest"
    endglobals

    private struct Data
        integer abilityLevel
        real areaRange
        Unit caster
        timer durationTimer
        timer effectTimer
        Unit target
        effect targetEffect
    endstruct

    private function Ending takes Data d, timer durationTimer, Unit target returns nothing
        local timer effectTimer = d.effectTimer
        local effect targetEffect = d.targetEffect
        local integer targetId = target.id
        call d.destroy()
        call FlushAttachedInteger( durationTimer, FleshBomb_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        call FlushAttachedInteger( effectTimer, FleshBomb_SCOPE_ID )
        call DestroyTimerWJ( effectTimer )
        set effectTimer = null
        call FlushAttachedIntegerById( targetId, FleshBomb_SCOPE_ID )
        //! runtextmacro RemoveEventById( "targetId", "EVENT_DISPEL" )
        call DestroyEffectWJ( targetEffect )
        set targetEffect = null
        call AddUnitVertexColorTimed( target, 40, 255, 255, 0, null, DURATION )
    endfunction

    public function Dispel takes Unit target returns nothing
        local Data d = GetAttachedIntegerById(target.id, FleshBomb_SCOPE_ID)
        if ( d != NULL ) then
            call Ending(d, d.durationTimer, target)
        endif
    endfunction

    private function Dispel_Event takes nothing returns nothing
        call Dispel( TRIGGER_UNIT )
    endfunction

    public function BeforeDying takes Unit target returns nothing
        call Dispel( target )
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_FLYING ) ) then
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

    private function EndingByTimer takes nothing returns nothing
        local real damageHighFactor
        local real damageLowFactor
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger( durationTimer, FleshBomb_SCOPE_ID )
        local integer abilityLevel = d.abilityLevel
        local real areaRange = d.areaRange
        local Unit caster = d.caster
        local unit enumUnit
        local real enumUnitX
        local real enumUnitY
        local Unit target = d.target
        local unit targetSelf = target.self
        local real targetLifeMax = GetUnitState( targetSelf, UNIT_STATE_MAX_LIFE )
        local real targetX = GetUnitX( targetSelf )
        local real targetY = GetUnitY( targetSelf )
        call Ending( d, durationTimer, target )
        set durationTimer = null
        call DestroyEffectWJ( AddSpecialEffectWJ( SPECIAL_EFFECT_PATH, targetX, targetY ) )
        call AddUnitDecay(target)
        call SetUnitDecayTime(target, 0)
        call AddUnitExplode( target )
        call KillUnit( targetSelf )
        set targetSelf = null
        set TEMP_PLAYER = target.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, targetX, targetY, areaRange, TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit != null ) then
            set damageHighFactor = DAMAGE_HIGH_FACTOR[abilityLevel]
            set damageLowFactor = DAMAGE_LOW_FACTOR[abilityLevel]
            loop
                set enumUnitX = GetUnitX( enumUnit )
                set enumUnitY = GetUnitY( enumUnit )
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                call UnitDamageUnitEx( caster, GetUnit(enumUnit), ( damageLowFactor + ( damageHighFactor - damageLowFactor ) / areaRange * ( areaRange - DistanceByCoordinates( enumUnitX, enumUnitY, targetX, targetY ) ) ) * targetLifeMax, null )
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
    endfunction

    private function Graphic takes nothing returns nothing
        local timer effectTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger( effectTimer, FleshBomb_SCOPE_ID )
        local integer abilityLevel = d.abilityLevel
        local Unit target = d.target
        call TimerStart( effectTimer, INTERVAL_END + TimerGetRemaining( d.durationTimer ) / DURATION * ( INTERVAL_START - INTERVAL_END ), false, function Graphic )
        set effectTimer = null
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local integer abilityLevel
        local real areaRange
        local timer durationTimer
        local timer effectTimer
        local integer targetId = target.id
        local Data d = GetAttachedIntegerById(targetId, FleshBomb_SCOPE_ID)
        if (d != NULL) then
            return
        endif
        set abilityLevel = GetUnitAbilityLevel( caster.self, SPELL_ID )
        set areaRange = AREA_RANGE[abilityLevel] + GetHeroAgilityTotal( caster ) * AREA_RANGE_PER_AGILITY_POINT[abilityLevel]
        set d = Data.create()
        set durationTimer = CreateTimerWJ()
        set effectTimer = CreateTimerWJ()
        set d.abilityLevel = abilityLevel
        set d.areaRange = areaRange
        set d.caster = caster
        set d.durationTimer = durationTimer
        set d.effectTimer = effectTimer
        set d.target = target
        set d.targetEffect = AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, target.self, TARGET_EFFECT_ATTACHMENT_POINT )
        call AttachInteger( durationTimer, FleshBomb_SCOPE_ID, d )
        call AttachInteger( effectTimer, FleshBomb_SCOPE_ID, d )
        call AttachIntegerById( targetId, FleshBomb_SCOPE_ID, d )
        //! runtextmacro AddEventById( "targetId", "EVENT_DISPEL" )
        call AddUnitVertexColorTimed( target, -40, -255, -255, 0, null, DURATION )
        call TimerStart( effectTimer, INTERVAL_START, false, function Graphic )
        set effectTimer = null
        call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    public function Order takes Unit target returns string
        set TEMP_UNIT_SELF = target.self
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return ErrorStrings_NOT_MECHANICAL
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return ErrorStrings_NOT_STRUCTURE
        endif
        if ( IsUnitIllusionWJ( target ) ) then
            return ErrorStrings_NOT_ILLUSION
        endif
        if ( GetUnitMagicImmunity( target ) > 0 ) then
            return ErrorStrings_TARGET_IS_MAGIC_IMMUNE
        endif
        if ( IsUnitWard( target ) ) then
            return ErrorStrings_NOT_WARD
        endif
        if ( GetAttachedIntegerById( target.id, FleshBomb_SCOPE_ID ) != NULL ) then
            return ErrorStrings_ALREADY_BOMB
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( TARGET_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        set AREA_RANGE[1] = 260
        set AREA_RANGE[2] = 270
        set AREA_RANGE[3] = 280
        set AREA_RANGE[4] = 290
        set AREA_RANGE[5] = 300
        set AREA_RANGE_PER_AGILITY_POINT[1] = 2
        set AREA_RANGE_PER_AGILITY_POINT[2] = 2
        set AREA_RANGE_PER_AGILITY_POINT[3] = 2
        set AREA_RANGE_PER_AGILITY_POINT[4] = 2
        set AREA_RANGE_PER_AGILITY_POINT[5] = 2
        set DAMAGE_HIGH_FACTOR[1] = 0.4
        set DAMAGE_HIGH_FACTOR[2] = 0.45
        set DAMAGE_HIGH_FACTOR[3] = 0.5
        set DAMAGE_HIGH_FACTOR[4] = 0.55
        set DAMAGE_HIGH_FACTOR[5] = 0.6
        set DAMAGE_LOW_FACTOR[1] = 0.2
        set DAMAGE_LOW_FACTOR[2] = 0.25
        set DAMAGE_LOW_FACTOR[3] = 0.3
        set DAMAGE_LOW_FACTOR[4] = 0.35
        set DAMAGE_LOW_FACTOR[5] = 0.4
        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DISPEL", "UnitIsDispelled_EVENT_KEY_POSITIVE", "0", "function Dispel_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( SPECIAL_EFFECT_PATH )
        call InitEffectType( TARGET_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()