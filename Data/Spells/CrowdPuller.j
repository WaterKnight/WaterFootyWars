//TESH.scrollpos=332
//TESH.alwaysfold=0
//! runtextmacro Scope("CrowdPuller")
    globals
        private constant integer CROWD_PULLER_ID = 'n02I'
        private constant integer ORDER_ID = 852114//OrderId( "stasistrap" )
        public constant integer SPELL_ID = 'A04C'

        private real array AREA_RANGE
        private real array BONUS_SPEED_RELATIVE
        private real array DRAINED_LIFE_RELATIVE_PER_INTERVAL
        private real array DURATION
        private group ENUM_GROUP
        private group ENUM_GROUP2
        private real array HERO_REFRESHED_MANA_RELATIVE_PER_INTERVAL
        private constant real INTERVAL = 0.25
        private real array LENGTH
        private constant integer LEVELS_AMOUNT = 5
        private real array LIFE_PER_STRENGTH_POINT
        private integer array MAX_TARGETS_AMOUNT
        private real array REFRESHED_MANA_RELATIVE_PER_INTERVAL
        private boolexpr TARGET_CONDITIONS
    endglobals

    private struct Data
        integer abilityLevel
        Unit caster
        group targetGroup
        timer updateTimer
        Unit ward
    endstruct

    //! runtextmacro Scope("Target")
        globals
            private constant string Target_EFFECT_LIGHTNING_PATH = "LEAS"
        endglobals

        private struct Target_Data
            real bonusSpeed
            Data d
            lightning effectLightning
            Unit target
        endstruct

        private function Target_Ending takes Target_Data d, Unit target, group targetGroup returns nothing
            local real bonusSpeed = -d.bonusSpeed
            local lightning effectLightning = d.effectLightning
            local integer targetId = target.id
            call d.destroy()
            call DestroyLightningWJ( effectLightning )
            set effectLightning = null
            call GroupRemoveUnit( targetGroup, target.self )
            call RemoveIntegerFromTableById( targetId, Target_SCOPE_ID, d )
            if ( CountIntegersInTableById( targetId, Target_SCOPE_ID ) == TABLE_EMPTY ) then
                //! runtextmacro RemoveEventById( "targetId", "Target_EVENT_DEATH" )
            endif
            call AddUnitSpeedBonus( target, bonusSpeed )
        endfunction

        public function Target_EndingByEnding takes Data d, Unit target, group targetGroup returns nothing
            local Target_Data e
            local integer targetId = target.id
            local integer iteration = CountIntegersInTableById( targetId, Target_SCOPE_ID )
            loop
                set e = GetIntegerFromTableById(targetId, Target_SCOPE_ID, iteration)
                exitwhen (e.d == d)
                set iteration = iteration - 1
            endloop
            call Target_Ending( e, target, d.targetGroup )
        endfunction

        public function Target_Death takes Unit target returns nothing
            local Data d
            local Target_Data e
            local integer targetId = target.id
            local integer iteration = CountIntegersInTableById( targetId, Target_SCOPE_ID )
            if (iteration > TABLE_EMPTY) then
                loop
                    set e = GetIntegerFromTableById(targetId, Target_SCOPE_ID, iteration)
                    set d = e.d
                    call Target_Ending( e, target, d.targetGroup )
                    set iteration = iteration - 1
                    exitwhen ( iteration < TABLE_STARTED )
                endloop
            endif
        endfunction

        private function Target_Death_Event takes nothing returns nothing
            call Target_Death( DYING_UNIT )
        endfunction

        public function Target_Interval takes Unit caster, Data d, real drainedLifeRelative, real length, real refreshedManaRelativeHero, real refreshedManaRelativeNormal, Unit target, real wardX, real wardY, real wardZ returns nothing
            local Target_Data e
            local real refreshedManaRelative
            local integer targetId = target.id
            local integer iteration = CountIntegersInTableById(targetId, Target_SCOPE_ID)
            local unit targetSelf = target.self
            local real targetX = GetUnitX(targetSelf)
            local real targetY = GetUnitY(targetSelf)
            local real targetZ = GetUnitZ(targetSelf, targetX, targetY)
            local real angle = Atan2( wardY - targetY, wardX - targetX )
            loop
                set e = GetIntegerFromTableById(targetId, Target_SCOPE_ID, iteration)
                exitwhen (e.d == d)
                set iteration = iteration - 1
            endloop
            call MoveLightningEx( e.effectLightning, true, wardX, wardY, wardZ, targetX, targetY, targetZ )
            call SetUnitXYIfNotBlocked( targetSelf, targetX, targetY, targetX + length * Cos( angle ), targetY + length * Sin( angle ) )
            if ( IsUnitType( targetSelf, UNIT_TYPE_HERO ) ) then
                set refreshedManaRelative = refreshedManaRelativeHero
            else
                set refreshedManaRelative = refreshedManaRelativeNormal
            endif
            call AddUnitState( targetSelf, UNIT_STATE_MANA, GetUnitState( targetSelf, UNIT_STATE_MAX_MANA ) * refreshedManaRelative )
            call UnitDamageUnitBySpell( caster, target, GetUnitState( targetSelf, UNIT_STATE_MAX_LIFE ) * drainedLifeRelative )
            set targetSelf = null
        endfunction

        public function Target_Start takes real bonusSpeedRelative, Unit caster, Data d, Unit target, real wardX, real wardY, real wardZ returns nothing
            local real bonusSpeed = GetUnitSpeedTotal( target ) * bonusSpeedRelative
            local Target_Data e = Target_Data.create()
            local integer targetId = target.id
            local unit targetSelf = target.self
            local real targetX = GetUnitX(targetSelf)
            local real targetY = GetUnitY(targetSelf)
            set e.bonusSpeed = bonusSpeed
            set e.d = d
            set e.effectLightning = AddLightningWJ( Target_EFFECT_LIGHTNING_PATH, wardX, wardY, wardZ, targetX, targetY, GetUnitZ(targetSelf, targetX, targetY) + GetUnitImpactZ(target) )
            set targetSelf = null
            call AddIntegerToTableById(targetId, Target_SCOPE_ID, e)
            if ( CountIntegersInTableById( targetId, Target_SCOPE_ID ) == TABLE_STARTED ) then
                //! runtextmacro AddEventById( "targetId", "Target_EVENT_DEATH" )
            endif
            call AddUnitSpeedBonus( target, bonusSpeed )
        endfunction

        public function Target_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "Target_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Target_Death_Event" )
        endfunction
    //! runtextmacro Endscope()

    public function Death takes Unit ward returns nothing
        local unit enumUnit
        local group targetGroup
        local timer updateTimer
        local integer wardId = ward.id
        local Data d = GetAttachedIntegerById(wardId, CrowdPuller_SCOPE_ID)
        if ( d != NULL ) then
            set targetGroup = d.targetGroup
            set updateTimer = d.updateTimer
            call d.destroy()
            call FlushAttachedIntegerById( wardId, CrowdPuller_SCOPE_ID )
            //! runtextmacro RemoveEventById( "wardId", "EVENT_DEATH" )
            loop
                set enumUnit = FirstOfGroup( targetGroup )
                exitwhen ( enumUnit == null )
                call Target_Target_EndingByEnding( d, GetUnit(enumUnit), targetGroup )
            endloop
            call DestroyGroupWJ( targetGroup )
            set targetGroup = null
            call FlushAttachedInteger( updateTimer, CrowdPuller_SCOPE_ID )
            call DestroyTimerWJ( updateTimer )
            set updateTimer = null
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) ) then
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
        if ( IsUnitWard( FILTER_UNIT ) ) then
            return false
        endif
        return true
    endfunction

    private function Update takes integer abilityLevel, Unit caster, Data d, group targetGroup, real wardX, real wardY, real wardZ returns nothing
        local real bonusSpeed
        local real bonusSpeedRelative
        local real drainedLifeRelative
        local unit enumUnit
        local real length
        local real refreshedManaRelative
        local real refreshedManaRelativeHero
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, wardX, wardY, AREA_RANGE[abilityLevel], TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( targetGroup )
        if ( enumUnit != null ) then
            set drainedLifeRelative = DRAINED_LIFE_RELATIVE_PER_INTERVAL[abilityLevel]
            set length = LENGTH[abilityLevel]
            set refreshedManaRelative = REFRESHED_MANA_RELATIVE_PER_INTERVAL[abilityLevel]
            set refreshedManaRelativeHero = HERO_REFRESHED_MANA_RELATIVE_PER_INTERVAL[abilityLevel]
            loop
                if ( IsUnitInGroup( enumUnit, ENUM_GROUP ) == false ) then
                    call Target_Target_EndingByEnding( d, GetUnit(enumUnit), targetGroup)
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
                call Target_Target_Interval( caster, d, drainedLifeRelative, length, refreshedManaRelativeHero, refreshedManaRelative, GetUnit(enumUnit), wardX, wardY, wardZ )
                set enumUnit = FirstOfGroup( ENUM_GROUP2 )
                exitwhen ( enumUnit == null )
            endloop
        endif
        if ( CountUnits( targetGroup ) < MAX_TARGETS_AMOUNT[abilityLevel] ) then
            set enumUnit = FirstOfGroup( ENUM_GROUP )
            if ( enumUnit != null ) then
                set bonusSpeedRelative = BONUS_SPEED_RELATIVE[abilityLevel]
                loop
                    call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                    call GroupAddUnit( targetGroup, enumUnit )
                    call Target_Target_Start(bonusSpeedRelative, caster, d, GetUnit(enumUnit), wardX, wardY, wardZ)
                    set enumUnit = FirstOfGroup( ENUM_GROUP )
                    exitwhen ( enumUnit == null )
                endloop
            endif
        endif
    endfunction

    private function UpdateByTimer takes nothing returns nothing
        local timer updateTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(updateTimer, CrowdPuller_SCOPE_ID)
        local Unit ward = d.ward
        local unit wardSelf = ward.self
        local real wardX = GetUnitX( wardSelf )
        local real wardY = GetUnitY( wardSelf )
        local real wardZ = GetUnitZ( wardSelf, wardX, wardY ) + GetUnitOutpactZ(ward)
        set wardSelf = null
        call Update( d.abilityLevel, d.caster, d, d.targetGroup, wardX, wardY, wardZ )
        set updateTimer = null
    endfunction

    public function SpellEffect takes Unit caster, real targetX, real targetY returns nothing
        local integer abilityLevel = GetUnitAbilityLevel( caster.self, SPELL_ID )
        local Data d = Data.create()
        local group targetGroup = CreateGroupWJ()
        local timer updateTimer = CreateTimerWJ()
        local Unit ward = CreateUnitEx( caster.owner, CROWD_PULLER_UNIT_ID, targetX, targetY, STANDARD_ANGLE )
        local integer wardId = ward.id
        local unit wardSelf = ward.self
        set d.abilityLevel = abilityLevel
        set d.caster = caster
        set d.targetGroup = targetGroup
        set d.updateTimer = updateTimer
        set d.ward = ward
        call AttachInteger( updateTimer, CrowdPuller_SCOPE_ID, d )
        call AttachIntegerById( wardId, CrowdPuller_SCOPE_ID, d )
        //! runtextmacro AddEventById( "wardId", "EVENT_DEATH" )
        call SetUnitAnimationByIndex( wardSelf, 0 )
        call AddUnitMaxLife( ward, GetHeroStrengthTotal( caster ) * LIFE_PER_STRENGTH_POINT[abilityLevel] )
        call TimerStart( updateTimer, INTERVAL, true, function UpdateByTimer )
        set updateTimer = null
        call Update( abilityLevel, caster, d, targetGroup, targetX, targetY, GetUnitZ(wardSelf, targetX, targetY) + GetUnitOutpactZ(ward) )
        set targetGroup = null
        call UnitApplyTimedLifeWJ( wardSelf, DURATION[abilityLevel] )
        set wardSelf = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_X, TARGET_Y )
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = LEVELS_AMOUNT
        set AREA_RANGE[1] = 400
        set AREA_RANGE[2] = 425
        set AREA_RANGE[3] = 450
        set AREA_RANGE[4] = 475
        set AREA_RANGE[5] = 500
        set BONUS_SPEED_RELATIVE[1] = -0.3
        set BONUS_SPEED_RELATIVE[2] = -0.3
        set BONUS_SPEED_RELATIVE[3] = -0.3
        set BONUS_SPEED_RELATIVE[4] = -0.3
        set BONUS_SPEED_RELATIVE[5] = -0.3
        set DRAINED_LIFE_RELATIVE_PER_INTERVAL[1] = 0.02
        set DRAINED_LIFE_RELATIVE_PER_INTERVAL[2] = 0.02
        set DRAINED_LIFE_RELATIVE_PER_INTERVAL[3] = 0.02
        set DRAINED_LIFE_RELATIVE_PER_INTERVAL[4] = 0.02
        set DRAINED_LIFE_RELATIVE_PER_INTERVAL[5] = 0.02
        set DURATION[1] = 15
        set DURATION[2] = 15
        set DURATION[3] = 15
        set DURATION[4] = 15
        set DURATION[5] = 15
        set ENUM_GROUP = CreateGroupWJ()
        set ENUM_GROUP2 = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        set HERO_REFRESHED_MANA_RELATIVE_PER_INTERVAL[1] = -0.02
        set HERO_REFRESHED_MANA_RELATIVE_PER_INTERVAL[2] = -0.02
        set HERO_REFRESHED_MANA_RELATIVE_PER_INTERVAL[3] = -0.03
        set HERO_REFRESHED_MANA_RELATIVE_PER_INTERVAL[4] = -0.04
        set HERO_REFRESHED_MANA_RELATIVE_PER_INTERVAL[5] = -0.04
        set LENGTH[1] = 30
        set LENGTH[2] = 36
        set LENGTH[3] = 42
        set LENGTH[4] = 48
        set LENGTH[5] = 54
        set LIFE_PER_STRENGTH_POINT[1] = 5
        set LIFE_PER_STRENGTH_POINT[2] = 5
        set LIFE_PER_STRENGTH_POINT[3] = 5
        set LIFE_PER_STRENGTH_POINT[4] = 5
        set LIFE_PER_STRENGTH_POINT[5] = 5
        set MAX_TARGETS_AMOUNT[1] = 5
        set MAX_TARGETS_AMOUNT[2] = 6
        set MAX_TARGETS_AMOUNT[3] = 7
        set MAX_TARGETS_AMOUNT[4] = 8
        set MAX_TARGETS_AMOUNT[5] = 9
        set REFRESHED_MANA_RELATIVE_PER_INTERVAL[1] = -0.05
        set REFRESHED_MANA_RELATIVE_PER_INTERVAL[2] = -0.06
        set REFRESHED_MANA_RELATIVE_PER_INTERVAL[3] = -0.07
        set REFRESHED_MANA_RELATIVE_PER_INTERVAL[4] = -0.08
        set REFRESHED_MANA_RELATIVE_PER_INTERVAL[5] = -0.09
        loop
            set DRAINED_LIFE_RELATIVE_PER_INTERVAL[iteration] = DRAINED_LIFE_RELATIVE_PER_INTERVAL[iteration] * INTERVAL
            set HERO_REFRESHED_MANA_RELATIVE_PER_INTERVAL[iteration] = HERO_REFRESHED_MANA_RELATIVE_PER_INTERVAL[iteration] * INTERVAL
            set LENGTH[iteration] = LENGTH[iteration] * INTERVAL
            set REFRESHED_MANA_RELATIVE_PER_INTERVAL[iteration] = REFRESHED_MANA_RELATIVE_PER_INTERVAL[iteration] * INTERVAL
            set iteration = iteration - 1
            exitwhen (iteration < 1)
        endloop
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call Target_Target_Init()
    endfunction
//! runtextmacro Endscope()