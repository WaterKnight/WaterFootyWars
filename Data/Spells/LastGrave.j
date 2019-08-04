//TESH.scrollpos=364
//TESH.alwaysfold=0
//! runtextmacro Scope("LastGrave")
    globals
        private constant integer ORDER_ID = 852221//OrderId( "deathanddecay" )
        public constant integer SPELL_ID = 'A07A'

        private constant string AREA_EFFECT_PATH = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"
        private real array AREA_RANGE
        private real array BONUS_CRITICAL_STRIKE_DEFENSE
        private real array BONUS_CRITICAL_STRIKE_DEFENSE_PER_AGILITY_POINT
        private integer array DEBRIS_AMOUNT
        private constant string DEBRIS_EFFECT_PATH = "Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl"
        private constant integer DUMMY_UNIT_ID = 'n002'
        private real array DURATION
        private group ENUM_GROUP
        private group ENUM_GROUP2
        private constant real INTERVAL = 1.
        private constant integer LEVELS_AMOUNT = 5
        private real array RELATIVE_DAMAGE_PER_INTERVAL
        private real array RELATIVE_DAMAGE_PER_INTERVAL_PER_INTELLIGENCE_POINT
        private boolexpr TARGET_CONDITIONS
        private constant real UPDATE_TIME = 1.
    endglobals

    private struct Data
        integer abilityLevel
        Unit caster
        real bonusCriticalStrikeDefense
        unit dummyUnit
        timer durationTimer
        timer intervalTimer
        real relativeDamageAmount
        group targetGroup
        real targetX
        real targetY
        timer updateTimer
    endstruct

    //! runtextmacro Scope("Target")
        globals
            private real array Target_DURATION
            private constant string Target_TARGET_EFFECT_PATH = "Abilities\\Spells\\Human\\Banish\\BanishTarget.mdl"
            private constant string Target_TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        endglobals

        private struct Target_Data
            Data d
            effect targetEffect
        endstruct

        public function Target_Ending takes real bonusCriticalStrikeDefense, Target_Data d, Unit target, group targetGroup returns nothing
            local effect targetEffect
            local integer targetId = target.id
            call GroupRemoveUnit( targetGroup, target.self )
            call RemoveIntegerFromTableById( targetId, Target_SCOPE_ID, d )
            if ( CountIntegersInTableById( targetId, Target_SCOPE_ID ) == TABLE_EMPTY ) then
                set targetEffect = d.targetEffect
                //! runtextmacro RemoveEventById( "targetId", "Target_EVENT_DEATH" )
                call DestroyEffectWJ( targetEffect )
            endif
            call d.destroy()
            call AddUnitCriticalStrikeDefense( target, bonusCriticalStrikeDefense )
        endfunction

        public function Target_EndingByEnding takes real bonusCriticalStrikeDefense, Data d, Unit target, group targetGroup returns nothing
            local Target_Data e
            local integer targetId = target.id
            local integer iteration = 0
            loop
                set e = GetIntegerFromTableById( targetId, Target_SCOPE_ID, iteration )
                exitwhen (e.d == d)
                set iteration = iteration + 1
            endloop
            call Target_Ending(bonusCriticalStrikeDefense, e, target, targetGroup)
        endfunction

        public function Target_Death takes Unit target returns nothing
            local Data d
            local Target_Data e
            local integer targetId = target.id
            local integer iteration = CountIntegersInTableById( targetId, Target_SCOPE_ID )
            if (iteration > TABLE_EMPTY) then
                loop
                    set e = GetIntegerFromTableById( targetId, Target_SCOPE_ID, iteration )
                    set d = e.d
                    call Target_Ending( -d.bonusCriticalStrikeDefense, e, target, d.targetGroup )
                    set iteration = iteration - 1
                    exitwhen ( iteration < TABLE_STARTED )
                endloop
            endif
        endfunction

        private function Target_Death_Event takes nothing returns nothing
            call Target_Death( DYING_UNIT )
        endfunction

        public function Target_Start takes real bonusCriticalStrikeDefense, Data d, Unit target returns nothing
            local Target_Data e = Target_Data.create()
            local integer targetId = target.id
            set e.d = d
            call AddIntegerToTableById( targetId, Target_SCOPE_ID, e )
            if ( CountIntegersInTableById( targetId, Target_SCOPE_ID ) == TABLE_STARTED ) then
                set e.targetEffect = AddSpecialEffectTargetWJ( Target_TARGET_EFFECT_PATH, target.self, Target_TARGET_EFFECT_ATTACHMENT_POINT )
                //! runtextmacro AddEventById( "targetId", "Target_EVENT_DEATH" )
            endif
            call AddUnitCriticalStrikeDefense( target, bonusCriticalStrikeDefense )
        endfunction

        public function Target_Init takes nothing returns nothing
            set Target_DURATION[1] = 15
            set Target_DURATION[2] = 15
            set Target_DURATION[3] = 15
            set Target_DURATION[4] = 15
            set Target_DURATION[5] = 15
            //! runtextmacro CreateEvent( "Target_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Target_Death_Event" )
            call InitEffectType( Target_TARGET_EFFECT_PATH )
        endfunction
    //! runtextmacro Endscope()

    private function Ending takes Unit caster, Data d returns nothing
        local integer abilityLevel = d.abilityLevel
        local real areaRange = AREA_RANGE[abilityLevel]
        local real bonusCriticalStrikeDefense = -d.bonusCriticalStrikeDefense
        local integer debrisAmount = DEBRIS_AMOUNT[abilityLevel]
        local unit dummyUnit = d.dummyUnit
        local timer durationTimer = d.durationTimer
        local real effectAngle
        local real effectAngleAdd = 2 * PI / debrisAmount
        local unit enumUnit
        local timer intervalTimer = d.intervalTimer
        local integer iteration = 1
        local real targetX = d.targetX
        local real targetY = d.targetY
        local group targetGroup = d.targetGroup
        local timer updateTimer = d.updateTimer
        call d.destroy()
        call FlushAttachedIntegerById( caster.id, LastGrave_SCOPE_ID )
        loop
            set enumUnit = FirstOfGroup( targetGroup )
            exitwhen ( enumUnit == null )
            call Target_Target_EndingByEnding( bonusCriticalStrikeDefense, d, GetUnit(enumUnit), targetGroup )
        endloop
        loop
            exitwhen ( iteration > debrisAmount )
            set effectAngle = iteration * effectAngleAdd
            call DestroyEffectWJ( AddSpecialEffectWJ( AREA_EFFECT_PATH, targetX + areaRange * Cos( effectAngle ), targetY + areaRange * Sin( effectAngle ) ) )
            set iteration = iteration + 1
        endloop
        call RemoveUnitWJ( dummyUnit )
        set dummyUnit = null
        call FlushAttachedInteger( durationTimer, LastGrave_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call FlushAttachedInteger( intervalTimer, LastGrave_SCOPE_ID )
        call DestroyTimerWJ( intervalTimer )
        set intervalTimer = null
        call DestroyGroupWJ( targetGroup )
        set targetGroup = null
        call FlushAttachedInteger( updateTimer, LastGrave_SCOPE_ID )
        call DestroyTimerWJ( updateTimer )
        set updateTimer = null
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, LastGrave_SCOPE_ID)
        set durationTimer = null
        call StopUnit( d.caster )
    endfunction

    public function EndCast takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, LastGrave_SCOPE_ID)
        if ( d != NULL ) then
            call Ending( caster, d )
        endif
    endfunction

    private function EndCast_Event takes nothing returns nothing
        call EndCast( CASTER )
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
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
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

    private function DealDamage takes nothing returns nothing
        local real effectAngle
        local unit enumUnit
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, LastGrave_SCOPE_ID)
        local integer abilityLevel = d.abilityLevel
        local real areaRange = AREA_RANGE[abilityLevel]
        local Unit caster = d.caster
        local integer debrisAmount = DEBRIS_AMOUNT[abilityLevel]
        local real effectLength = GetRandomReal( areaRange / 2, areaRange )
        local integer iteration = 1
        local real relativeDamageAmount
        local real targetX = d.targetX
        local real targetY = d.targetY
        loop
            exitwhen ( iteration > debrisAmount )
            set effectAngle = GetRandomReal( 0, 2 * PI )
            call DestroyEffectWJ( AddSpecialEffectWJ( DEBRIS_EFFECT_PATH, targetX + effectLength * Cos( effectAngle ), targetY + effectLength * Sin( effectAngle ) ) )
            set iteration = iteration + 1
        endloop
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, targetX, targetY, areaRange, TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit != null ) then
            set relativeDamageAmount = d.relativeDamageAmount
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                call UnitDamageUnitBySpell( caster, GetUnit(enumUnit), GetUnitState( enumUnit, UNIT_STATE_MAX_LIFE ) * relativeDamageAmount )
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
    endfunction

    private function Update takes integer abilityLevel, real areaRange, real bonusCriticalStrikeDefense, Unit caster, Data d, group targetGroup, real targetX, real targetY returns nothing
        local unit enumUnit
        local real enumUnitX
        local real enumUnitY
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, targetX, targetY, areaRange, TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( targetGroup )
        if ( enumUnit != null ) then
            loop
                if ( IsUnitInGroup( enumUnit, ENUM_GROUP ) == false ) then
                    call Target_Target_EndingByEnding( -bonusCriticalStrikeDefense, d, GetUnit(enumUnit), targetGroup )
                else
                    call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                    call GroupRemoveUnit( targetGroup, enumUnit )
                    call GroupAddUnit( ENUM_GROUP2, enumUnit )
                endif
                set enumUnit = FirstOfGroup( targetGroup )
                exitwhen ( enumUnit == null )
            endloop
            set enumUnit = FirstOfGroup( ENUM_GROUP2 )
            loop
                call GroupRemoveUnit( ENUM_GROUP2, enumUnit )
                call GroupAddUnit( targetGroup, enumUnit )
                set enumUnit = FirstOfGroup( ENUM_GROUP2 )
                exitwhen ( enumUnit == null )
            endloop
        endif
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit != null ) then
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                call GroupAddUnit( targetGroup, enumUnit )
                call Target_Target_Start(bonusCriticalStrikeDefense, d, GetUnit(enumUnit))
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
    endfunction

    private function UpdateByTimer takes nothing returns nothing
        local timer updateTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(updateTimer, LastGrave_SCOPE_ID)
        local integer abilityLevel = d.abilityLevel
        set updateTimer = null
        call Update( abilityLevel, AREA_RANGE[abilityLevel], d.bonusCriticalStrikeDefense, d.caster, d, d.targetGroup, d.targetX, d.targetY )
    endfunction

    public function SpellEffect takes Unit caster, real targetX, real targetY returns nothing
        local unit casterSelf = caster.self
        local integer abilityLevel = GetUnitAbilityLevel( casterSelf, SPELL_ID )
        local real areaRange = AREA_RANGE[abilityLevel]
        local real bonusCriticalStrikeDefense = BONUS_CRITICAL_STRIKE_DEFENSE[abilityLevel] + GetHeroAgilityTotal( caster ) * BONUS_CRITICAL_STRIKE_DEFENSE_PER_AGILITY_POINT[abilityLevel]
        local Data d = Data.create()
        local unit dummyUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, DUMMY_UNIT_ID, targetX, targetY, GetUnitFacingWJ( casterSelf ) )
        local real dummyUnitScale = areaRange / 150
        local timer durationTimer = CreateTimerWJ()
        local timer intervalTimer = CreateTimerWJ()
        local group targetGroup = CreateGroupWJ()
        local timer updateTimer = CreateTimerWJ()
        set casterSelf = null
        set d.abilityLevel = abilityLevel
        set d.bonusCriticalStrikeDefense = bonusCriticalStrikeDefense
        set d.caster = caster
        set d.dummyUnit = dummyUnit
        set d.durationTimer = durationTimer
        set d.intervalTimer = intervalTimer
        set d.relativeDamageAmount = RELATIVE_DAMAGE_PER_INTERVAL[abilityLevel] + GetHeroIntelligenceTotal( caster ) * RELATIVE_DAMAGE_PER_INTERVAL_PER_INTELLIGENCE_POINT[abilityLevel]
        set d.targetGroup = targetGroup
        set d.targetX = targetX
        set d.targetY = targetY
        set d.updateTimer = updateTimer
        call AttachIntegerById( caster.id, LastGrave_SCOPE_ID, d )
        call AttachInteger( durationTimer, LastGrave_SCOPE_ID, d )
        call AttachInteger( intervalTimer, LastGrave_SCOPE_ID, d )
        call AttachInteger( updateTimer, LastGrave_SCOPE_ID, d )
        call SetUnitAnimationByIndex( dummyUnit, 6 )
        call SetUnitScale( dummyUnit, dummyUnitScale, dummyUnitScale, dummyUnitScale )
        set dummyUnit = null
        call TimerStart( intervalTimer, INTERVAL, true, function DealDamage )
        set intervalTimer = null
        call TimerStart( updateTimer, UPDATE_TIME, true, function UpdateByTimer )
        set updateTimer = null
        call TimerStart( durationTimer, DURATION[abilityLevel], false, function EndingByTimer )
        set durationTimer = null
        call Update( abilityLevel, areaRange, bonusCriticalStrikeDefense, caster, d, targetGroup, targetX, targetY )
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_X, TARGET_Y )
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = LEVELS_AMOUNT
        set AREA_RANGE[1] = 275
        set AREA_RANGE[2] = 275
        set AREA_RANGE[3] = 275
        set AREA_RANGE[4] = 275
        set AREA_RANGE[5] = 325
        set BONUS_CRITICAL_STRIKE_DEFENSE[1] = -0.2
        set BONUS_CRITICAL_STRIKE_DEFENSE[2] = -0.3
        set BONUS_CRITICAL_STRIKE_DEFENSE[3] = -0.4
        set BONUS_CRITICAL_STRIKE_DEFENSE[4] = -0.5
        set BONUS_CRITICAL_STRIKE_DEFENSE[5] = -0.5
        set BONUS_CRITICAL_STRIKE_DEFENSE_PER_AGILITY_POINT[1] = -0.002
        set BONUS_CRITICAL_STRIKE_DEFENSE_PER_AGILITY_POINT[2] = -0.002
        set BONUS_CRITICAL_STRIKE_DEFENSE_PER_AGILITY_POINT[3] = -0.002
        set BONUS_CRITICAL_STRIKE_DEFENSE_PER_AGILITY_POINT[4] = -0.002
        set BONUS_CRITICAL_STRIKE_DEFENSE_PER_AGILITY_POINT[5] = -0.002
        set DEBRIS_AMOUNT[1] = 5
        set DEBRIS_AMOUNT[2] = 5
        set DEBRIS_AMOUNT[3] = 5
        set DEBRIS_AMOUNT[4] = 5
        set DEBRIS_AMOUNT[5] = 5
        set DURATION[1] = 15
        set DURATION[2] = 15
        set DURATION[3] = 15
        set DURATION[4] = 15
        set DURATION[5] = 15
        set ENUM_GROUP = CreateGroupWJ()
        set ENUM_GROUP2 = CreateGroupWJ()
        set RELATIVE_DAMAGE_PER_INTERVAL[1] = 0.02
        set RELATIVE_DAMAGE_PER_INTERVAL[2] = 0.03
        set RELATIVE_DAMAGE_PER_INTERVAL[3] = 0.04
        set RELATIVE_DAMAGE_PER_INTERVAL[4] = 0.05
        set RELATIVE_DAMAGE_PER_INTERVAL[5] = 0.06
        set RELATIVE_DAMAGE_PER_INTERVAL_PER_INTELLIGENCE_POINT[1] = 0
        set RELATIVE_DAMAGE_PER_INTERVAL_PER_INTELLIGENCE_POINT[2] = 0
        set RELATIVE_DAMAGE_PER_INTERVAL_PER_INTELLIGENCE_POINT[3] = 0
        set RELATIVE_DAMAGE_PER_INTERVAL_PER_INTELLIGENCE_POINT[4] = 0
        set RELATIVE_DAMAGE_PER_INTERVAL_PER_INTELLIGENCE_POINT[5] = 0
        loop
            set RELATIVE_DAMAGE_PER_INTERVAL[iteration] = RELATIVE_DAMAGE_PER_INTERVAL[iteration] * INTERVAL
            set RELATIVE_DAMAGE_PER_INTERVAL_PER_INTELLIGENCE_POINT[iteration] = RELATIVE_DAMAGE_PER_INTERVAL_PER_INTELLIGENCE_POINT[iteration] * INTERVAL
            set iteration = iteration - 1
            exitwhen (iteration < 1)
        endloop
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( DEBRIS_EFFECT_PATH )
        call InitUnitType( DUMMY_UNIT_ID )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ENDCAST", "SPELL_ID", "UnitFinishesCasting_EVENT_KEY", "0", "function EndCast_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call Target_Target_Init()
    endfunction
//! runtextmacro Endscope()