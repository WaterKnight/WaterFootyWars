//TESH.scrollpos=278
//TESH.alwaysfold=0
//! runtextmacro Scope("LightOfPurge")
    globals
        private constant integer ORDER_ID = 852111//OrderId( "purge" )
        public constant integer SPELL_ID = 'A009'

        private real array AREA_RANGE
        private real array DURATION
        private real array DURATION_FACTOR_PER_INTELLIGENCE_POINT
        private constant string EFFECT_LIGHTNING_PATH = "HWPB"
        private group ENUM_GROUP
        private constant integer LEVELS_AMOUNT = 5
        private integer array MAX_LEVEL
        private constant real MAX_RANGE = 1100.
        private real array REFRESHED_LIFE_PER_INTERVAL
        private real array REFRESHED_LIFE_PER_INTERVAL_PER_INTELLIGENCE_POINT
        private constant real SECONDARY_HEALING_FACTOR = 0.75
        private boolexpr TARGET_CONDITIONS
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Undead\\ReplenishHealth\\ReplenishHealthCaster.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        private constant real UPDATE_TIME = 0.1
        private integer array WAVES_AMOUNT
    endglobals

    private struct Data
        integer abilityLevel
        Unit caster
        timer durationTimer
        lightning effectLightning
        sound effectSound
        timer intervalTimer
        real refreshedLifePerInterval
        timer updateTimer
        Unit target
    endstruct

    private function Ending takes Unit caster, Data d returns nothing
        local timer durationTimer = d.durationTimer
        local lightning effectLightning = d.effectLightning
        local sound effectSound = d.effectSound
        local timer intervalTimer = d.intervalTimer
        local Unit target = d.target
        local integer targetId = target.id
        local timer updateTimer = d.updateTimer
        call d.destroy()
        call FlushAttachedIntegerById( caster.id, LightOfPurge_SCOPE_ID_BASIC )
        call FlushAttachedInteger( durationTimer, LightOfPurge_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call DestroyLightningWJ( effectLightning )
        set effectLightning = null
        call KillSound( effectSound, false )
        set effectSound = null
        call FlushAttachedInteger( intervalTimer, LightOfPurge_SCOPE_ID )
        call DestroyTimerWJ( intervalTimer )
        set intervalTimer = null
        call RemoveIntegerFromTableById( targetId, LightOfPurge_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, LightOfPurge_SCOPE_ID ) == TABLE_EMPTY ) then
            //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        endif
        call FlushAttachedInteger( updateTimer, LightOfPurge_SCOPE_ID )
        call DestroyTimerWJ( updateTimer )
        set updateTimer = null
    endfunction

    public function Death takes Unit target returns nothing
        local Data d
        local integer targetId = target.id
        local integer iteration = CountIntegersInTableById( targetId, LightOfPurge_SCOPE_ID )
        if (iteration > TABLE_EMPTY) then
            loop
                set d = GetIntegerFromTableById( targetId, LightOfPurge_SCOPE_ID, iteration )
                call IssueImmediateOrderById( d.caster.self, STOP_ORDER_ID )
                set iteration = iteration - 1
                exitwhen ( iteration < TABLE_STARTED )
            endloop
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    public function EndCast takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, LightOfPurge_SCOPE_ID_BASIC)
        if ( d != NULL ) then
            call Ending( caster, d )
        endif
    endfunction

    private function EndCast_Event takes nothing returns nothing
        call EndCast( CASTER )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, LightOfPurge_SCOPE_ID)
        local Unit caster = d.caster
        local player casterOwner = caster.owner
        local Unit target = d.target
        local unit targetSelf = target.self
        set durationTimer = null
        call IssueImmediateOrderById( caster.self, STOP_ORDER_ID )
        call DispelUnit( target, true, true, true )
        if ( ( IsUnitAlly( targetSelf, casterOwner ) == false ) and ( IsUnitType( targetSelf, UNIT_TYPE_HERO ) == false ) and ( MAX_LEVEL[d.abilityLevel] >= GetUnitSupplyUsed( target ) ) ) then
            if ( IsUnitIllusionWJ( target ) ) then
                call KillUnit( targetSelf )
            else
                call SetUnitOwnerEx( target, casterOwner, true )
            endif
        endif
        set casterOwner = null
        set targetSelf = null
    endfunction

    private function CheckDistance takes nothing returns nothing
        local timer updateTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(updateTimer, LightOfPurge_SCOPE_ID)
        local Unit caster = d.caster
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local Unit target = d.target
        local unit targetSelf = target.self
        local real targetX = GetUnitX( targetSelf )
        local real targetY = GetUnitY( targetSelf )
        set updateTimer = null
        if ( DistanceByCoordinates( casterX, casterY, targetX, targetY ) > MAX_RANGE ) then
            call IssueImmediateOrderById( casterSelf, STOP_ORDER_ID )
        else
            call MoveLightningEx( d.effectLightning, true, casterX, casterY, GetUnitZ(casterSelf, casterX, casterY) + GetUnitImpactZ(caster), targetX, targetY, GetUnitZ(targetSelf, targetX, targetY) + GetUnitImpactZ(target) )
        endif
        set casterSelf = null
        set targetSelf = null
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) == false ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        if ( IsUnitWard( FILTER_UNIT ) ) then
            return false
        endif
        return true
    endfunction

    private function Healing takes nothing returns nothing
        local unit enumUnit
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, LightOfPurge_SCOPE_ID)
        local real refreshedLife = d.refreshedLifePerInterval
        local Unit target = d.target
        local unit targetSelf = target.self
        set intervalTimer = null
        call HealUnitBySpell( target, refreshedLife )
        call DestroyEffectTimed( AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, target.self, TARGET_EFFECT_ATTACHMENT_POINT ), 2 )
        set TEMP_PLAYER = d.caster.owner
        call GroupEnumUnitsInRangeWithCollision(ENUM_GROUP, GetUnitX(targetSelf), GetUnitY(targetSelf), AREA_RANGE[d.abilityLevel], TARGET_CONDITIONS)
        set targetSelf = null
        set enumUnit = FirstOfGroup(ENUM_GROUP)
        if (enumUnit != null) then
            set refreshedLife = refreshedLife * SECONDARY_HEALING_FACTOR
            loop
                call GroupRemoveUnit(ENUM_GROUP, enumUnit)
                call HealUnitBySpell( GetUnit(enumUnit), refreshedLife )
                set enumUnit = FirstOfGroup(ENUM_GROUP)
                exitwhen (enumUnit == null)
            endloop
        endif
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local real casterIntelligence = GetHeroIntelligenceTotal(caster)
        local unit casterSelf = caster.self
        local integer abilityLevel = GetUnitAbilityLevel( casterSelf, SPELL_ID )
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local Data d = Data.create()
        local real duration = Max( 1, DURATION[abilityLevel] * Pow( DURATION_FACTOR_PER_INTELLIGENCE_POINT[abilityLevel], casterIntelligence ) )
        local timer durationTimer = CreateTimerWJ()
        local sound effectSound = CreateSoundFromType( LIGHT_OF_PURGE_LOOP_SOUND_TYPE )
        local timer intervalTimer = CreateTimerWJ()
        local integer targetId = target.id
        local unit targetSelf = target.self
        local real targetX = GetUnitX( targetSelf )
        local real targetY = GetUnitY( targetSelf )
        local timer updateTimer = CreateTimerWJ()
        set d.abilityLevel = abilityLevel
        set d.caster = caster
        set d.durationTimer = durationTimer
        set d.effectLightning = AddLightningWJ( EFFECT_LIGHTNING_PATH, casterX, casterY, GetUnitZ( casterSelf, casterX, casterY ) + GetUnitImpactZ(caster), targetX, targetY, GetUnitZ( targetSelf, targetX, targetY ) + GetUnitImpactZ(target) )
        set casterSelf = null
        set d.effectSound = effectSound
        set d.intervalTimer = intervalTimer
        set d.refreshedLifePerInterval = REFRESHED_LIFE_PER_INTERVAL[abilityLevel] + casterIntelligence * REFRESHED_LIFE_PER_INTERVAL_PER_INTELLIGENCE_POINT[abilityLevel]
        set d.target = target
        set d.updateTimer = updateTimer
        call AttachIntegerById( caster.id, LightOfPurge_SCOPE_ID_BASIC, d )
        call AttachInteger( durationTimer, LightOfPurge_SCOPE_ID, d )
        call AttachInteger( intervalTimer, LightOfPurge_SCOPE_ID, d )
        call AddIntegerToTableById( targetId, LightOfPurge_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, LightOfPurge_SCOPE_ID ) == TABLE_STARTED ) then
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
        endif
        call AttachInteger( updateTimer, LightOfPurge_SCOPE_ID, d )
        call AttachSoundToUnit( effectSound, targetSelf )
        set targetSelf = null
        call StartSound( effectSound )
        set effectSound = null
        call TimerStart( intervalTimer, ( duration - 0.01 ) / WAVES_AMOUNT[abilityLevel], true, function Healing )
        set intervalTimer = null
        call TimerStart( durationTimer, duration, false, function EndingByTimer )
        set durationTimer = null
        call TimerStart( updateTimer, UPDATE_TIME, true, function CheckDistance )
        set updateTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    public function Order takes Unit caster, player casterOwner, Unit target returns string
        local UnitType targetType
        set TEMP_UNIT_SELF = target.self
        if ( IsUnitAlly( TEMP_UNIT_SELF, casterOwner ) == false ) then
            if ( GetUnitSupplyUsed( target ) > MAX_LEVEL[GetUnitAbilityLevel( caster.self, SPELL_ID )] ) then
                return ErrorStrings_TOO_MIGHTY
            endif
            if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_HERO ) ) then
                return ErrorStrings_TOO_MIGHTY
            endif
            set targetType = target.type
            if ( ( IsUnitTypeSpawn(targetType) == false ) and ( targetType.id != RESERVE_UNIT_ID ) ) then
                return ErrorStrings_ONLY_SPAWNS_OR_RESERVE
            endif
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return ErrorStrings_ONLY_ORGANIC
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return ErrorStrings_NOT_STRUCTURE
        endif
        if ( IsUnitWard( target ) ) then
            return ErrorStrings_NOT_WARD
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( ORDERED_UNIT, ORDERED_UNIT.owner, TARGET_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = LEVELS_AMOUNT
        set AREA_RANGE[1] = 150
        set AREA_RANGE[2] = 150
        set AREA_RANGE[3] = 150
        set AREA_RANGE[4] = 150
        set AREA_RANGE[5] = 150
        set DURATION[1] = 5
        set DURATION[2] = 5
        set DURATION[3] = 5
        set DURATION[4] = 5
        set DURATION[5] = 5
        set DURATION_FACTOR_PER_INTELLIGENCE_POINT[1] = 0.99
        set DURATION_FACTOR_PER_INTELLIGENCE_POINT[2] = 0.99
        set DURATION_FACTOR_PER_INTELLIGENCE_POINT[3] = 0.99
        set DURATION_FACTOR_PER_INTELLIGENCE_POINT[4] = 0.99
        set DURATION_FACTOR_PER_INTELLIGENCE_POINT[5] = 0.99
        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        set MAX_LEVEL[1] = 2
        set MAX_LEVEL[2] = 3
        set MAX_LEVEL[3] = 4
        set MAX_LEVEL[4] = 5
        set MAX_LEVEL[5] = 6
        set REFRESHED_LIFE_PER_INTERVAL[1] = 240
        set REFRESHED_LIFE_PER_INTERVAL[2] = 360
        set REFRESHED_LIFE_PER_INTERVAL[3] = 450
        set REFRESHED_LIFE_PER_INTERVAL[4] = 520
        set REFRESHED_LIFE_PER_INTERVAL[5] = 580
        set REFRESHED_LIFE_PER_INTERVAL_PER_INTELLIGENCE_POINT[1] = 0
        set REFRESHED_LIFE_PER_INTERVAL_PER_INTELLIGENCE_POINT[2] = 0
        set REFRESHED_LIFE_PER_INTERVAL_PER_INTELLIGENCE_POINT[3] = 0
        set REFRESHED_LIFE_PER_INTERVAL_PER_INTELLIGENCE_POINT[4] = 0
        set REFRESHED_LIFE_PER_INTERVAL_PER_INTELLIGENCE_POINT[5] = 0
        set TARGET_CONDITIONS = ConditionWJ(function TargetConditions)
        set WAVES_AMOUNT[1] = 10
        set WAVES_AMOUNT[2] = 10
        set WAVES_AMOUNT[3] = 10
        set WAVES_AMOUNT[4] = 10
        set WAVES_AMOUNT[5] = 10
        loop
            set REFRESHED_LIFE_PER_INTERVAL[iteration] = REFRESHED_LIFE_PER_INTERVAL[iteration] / WAVES_AMOUNT[iteration]
            set REFRESHED_LIFE_PER_INTERVAL_PER_INTELLIGENCE_POINT[iteration] = REFRESHED_LIFE_PER_INTERVAL_PER_INTELLIGENCE_POINT[iteration] / WAVES_AMOUNT[iteration]
            set iteration = iteration - 1
            exitwhen (iteration < 1)
        endloop
        call InitEffectType( TARGET_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ENDCAST", "SPELL_ID", "UnitFinishesCasting_EVENT_KEY", "0", "function EndCast_Event" )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()