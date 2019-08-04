//TESH.scrollpos=365
//TESH.alwaysfold=0
//! runtextmacro Scope("DarkCloud")
    globals
        private constant integer ORDER_ID = 852222//OrderId( "deathcoil" )
        public constant integer SPELL_ID = 'A00Q'

        private real array BONUS_MISS_CHANCE
        private real array BONUS_MISS_CHANCE_PER_AGILITY_POINT
        private real array DAMAGE_PER_INTERVAL
        private real array DAMAGE_PER_INTERVAL_PER_STRENGTH_POINT
        private real array DURATION
        private group ENUM_GROUP
        private real array INTERVAL
        private constant integer LEVELS_AMOUNT = 5
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Other\\HowlOfTerror\\HowlTarget.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        private constant string TARGET_EFFECT2_PATH = "Abilities\\Spells\\Other\\Monsoon\\MonsoonRain.mdl"
        private constant string TARGET_EFFECT2_ATTACHMENT_POINT = "origin"
        private integer array WAVES_AMOUNT
    endglobals

    private struct Data
        integer abilityLevel
        real array bonusMissChance[LEVELS_AMOUNT]
        Unit array caster[LEVELS_AMOUNT]
        real array damagePerIntervalAmount[LEVELS_AMOUNT]
        timer array durationTimer[LEVELS_AMOUNT]
        timer intervalTimer
        Unit target
        effect targetEffect
        effect targetEffect2
    endstruct

    private function Ending takes Data d, timer durationTimer, Unit target returns nothing
        local integer abilityLevel = d.abilityLevel
        local real bonusMissChance
        local timer intervalTimer
        local integer iteration = abilityLevel - 1
        local effect targetEffect
        local effect targetEffect2
        local integer targetId
        loop
            exitwhen (durationTimer == d.durationTimer[iteration])
            set iteration = iteration - 1
        endloop
        set d.durationTimer[iteration] = null
        if ( abilityLevel - 1 <= iteration ) then
            set bonusMissChance = d.bonusMissChance[abilityLevel - 1]
            loop
                exitwhen (iteration < 0)
                exitwhen (d.durationTimer[iteration] != null)
                set iteration = iteration - 1
            endloop
            if ( iteration > -1 ) then
                set d.abilityLevel = iteration + 1
                call AddUnitMissChance( target, d.bonusMissChance[iteration] - bonusMissChance )
            else
                set intervalTimer = d.intervalTimer
                set targetEffect = d.targetEffect
                set targetEffect2 = d.targetEffect2
                set targetId = target.id
                call d.destroy()
                call FlushAttachedInteger(intervalTimer, DarkCloud_SCOPE_ID)
                call DestroyTimerWJ(intervalTimer)
                set intervalTimer = null
                call DestroyEffectWJ( targetEffect )
                call DestroyEffectWJ( targetEffect2 )
                set targetEffect = null
                call FlushAttachedIntegerById( targetId, DarkCloud_SCOPE_ID )
                //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
                //! runtextmacro RemoveEventById( "targetId", "EVENT_DISPEL" )
                call AddUnitMissChance( target, -bonusMissChance )
            endif
        endif
        call FlushAttachedInteger( durationTimer, DarkCloud_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
    endfunction

    public function Dispel takes Unit target returns nothing
        local integer abilityLevel
        local Data d = GetAttachedIntegerById(target.id, DarkCloud_SCOPE_ID)
        local timer durationTimer
        local integer iteration
        if (d != NULL) then
            set abilityLevel = d.abilityLevel
            set iteration = 0
            loop
                set durationTimer = d.durationTimer[iteration]
                if ( durationTimer != null ) then
                    call Ending( d, durationTimer, target )
                endif
                set iteration = iteration + 1
                exitwhen ( iteration == abilityLevel )
            endloop
            set durationTimer = null
        endif
    endfunction

    private function Dispel_Event takes nothing returns nothing
        call Dispel( TRIGGER_UNIT )
    endfunction

    public function Death takes Unit target returns nothing
        call Dispel( target )
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, DarkCloud_SCOPE_ID)
        call Ending( d, durationTimer, d.target )
        set durationTimer = null
    endfunction

    //! runtextmacro Scope("Lightning")
        globals
            private real array Lightning_AREA_RANGE
            private constant real Lightning_DELAY = 0.5
            private constant string Lightning_SPECIAL_EFFECT_PATH = "Abilities\\Spells\\Other\\Monsoon\\MonsoonBoltTarget.mdl"
            private constant string Lightning_SPECIAL_EFFECT2_PATH = "Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl"
            private real array Lightning_STUN_AREA_RANGE
            private real array Lightning_STUN_DURATION
            private real array Lightning_STUN_HERO_DURATION
            private boolexpr Lightning_TARGET_CONDITIONS
        endglobals

        private struct Lightning_Data
            integer abilityLevel
            Unit caster
            real damageAmount
            Unit target
            real targetX
            real targetY
        endstruct

        private function Lightning_TargetConditions takes nothing returns boolean
            set FILTER_UNIT_SELF = GetFilterUnit()
            if ( FILTER_UNIT_SELF == TEMP_UNIT_SELF ) then
                return false
            endif
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

        private function Lightning_Ending takes nothing returns nothing
            local real areaRangeStun
            local real duration
            local Unit enumUnit
            local unit enumUnitSelf
            local timer delayTimer = GetExpiredTimer()
            local Lightning_Data d = GetAttachedInteger(delayTimer, Lightning_SCOPE_ID)
            local integer abilityLevel = d.abilityLevel
            local Unit caster = d.caster
            local real damageAmount = d.damageAmount
            local real heroDuration
            local real stunTime
            local Unit target = d.target
            local real targetX = d.targetX
            local real targetY = d.targetY
            call d.destroy()
            call FlushAttachedInteger( delayTimer, Lightning_SCOPE_ID )
            call DestroyTimerWJ( delayTimer )
            set delayTimer = null
            call DestroyEffectWJ( AddSpecialEffectWJ( Lightning_SPECIAL_EFFECT2_PATH, targetX, targetY ) )
            set TEMP_PLAYER = caster.owner
            set TEMP_UNIT_SELF = target.self
            call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, targetX, targetY, Lightning_AREA_RANGE[abilityLevel], Lightning_TARGET_CONDITIONS )
            set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
            if ( enumUnitSelf != null ) then
                set areaRangeStun = Lightning_STUN_AREA_RANGE[abilityLevel]
                set duration = Lightning_STUN_DURATION[abilityLevel]
                set heroDuration = Lightning_STUN_HERO_DURATION[abilityLevel]
                loop
                    set enumUnit = GetUnit(enumUnitSelf)
                    call GroupRemoveUnit( ENUM_GROUP, enumUnitSelf )
                    if ( DistanceByCoordinates( targetX, targetY, GetUnitX( enumUnitSelf ), GetUnitY( enumUnitSelf ) ) <= areaRangeStun ) then
                        if ( IsUnitType( enumUnitSelf, UNIT_TYPE_HERO ) ) then
                            set stunTime = heroDuration
                        else
                            set stunTime = duration
                        endif
                        call SetUnitStunTimed( enumUnit, 1, stunTime )
                    endif
                    call UnitDamageUnitBySpell( caster, enumUnit, damageAmount )
                    set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
                    exitwhen ( enumUnitSelf == null )
                endloop
            endif
        endfunction

        public function Lightning_Start takes integer abilityLevel, Unit caster, real damageAmount, Unit target returns nothing
            local Lightning_Data d = Lightning_Data.create()
            local timer delayTimer = CreateTimerWJ()
            local unit targetSelf = target.self
            local real targetX = GetUnitX( targetSelf )
            local real targetY = GetUnitY( targetSelf )
            set targetSelf = null
            set d.abilityLevel = abilityLevel
            set d.caster = caster
            set d.damageAmount = damageAmount
            set d.target = target
            set d.targetX = targetX
            set d.targetY = targetY
            call AttachInteger( delayTimer, Lightning_SCOPE_ID, d )
            call DestroyEffectWJ( AddSpecialEffectWJ( Lightning_SPECIAL_EFFECT_PATH, targetX, targetY ) )
            call TimerStart( delayTimer, Lightning_DELAY, false, function Lightning_Ending )
            set delayTimer = null
        endfunction

        public function Lightning_Init takes nothing returns nothing
            set Lightning_AREA_RANGE[1] = 350
            set Lightning_AREA_RANGE[2] = 350
            set Lightning_AREA_RANGE[3] = 350
            set Lightning_AREA_RANGE[4] = 350
            set Lightning_AREA_RANGE[5] = 350
            set Lightning_STUN_AREA_RANGE[1] = 100
            set Lightning_STUN_AREA_RANGE[2] = 100
            set Lightning_STUN_AREA_RANGE[3] = 100
            set Lightning_STUN_AREA_RANGE[4] = 100
            set Lightning_STUN_AREA_RANGE[5] = 100
            set Lightning_STUN_DURATION[1] = 0.5
            set Lightning_STUN_DURATION[2] = 0.5
            set Lightning_STUN_DURATION[3] = 0.5
            set Lightning_STUN_DURATION[4] = 0.5
            set Lightning_STUN_DURATION[5] = 0.5
            set Lightning_STUN_HERO_DURATION[1] = 0.5
            set Lightning_STUN_HERO_DURATION[2] = 0.5
            set Lightning_STUN_HERO_DURATION[3] = 0.5
            set Lightning_STUN_HERO_DURATION[4] = 0.5
            set Lightning_STUN_HERO_DURATION[5] = 0.5
            set Lightning_TARGET_CONDITIONS = ConditionWJ( function Lightning_TargetConditions )
            call InitEffectType( Lightning_SPECIAL_EFFECT_PATH )
            call InitEffectType( Lightning_SPECIAL_EFFECT2_PATH )
        endfunction
    //! runtextmacro Endscope()

    private function Interval takes nothing returns nothing
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, DarkCloud_SCOPE_ID)
        local integer abilityLevel = d.abilityLevel
        set intervalTimer = null
        call Lightning_Lightning_Start( abilityLevel, d.caster[abilityLevel - 1], d.damagePerIntervalAmount[abilityLevel - 1], d.target )
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local integer abilityLevel = GetUnitAbilityLevel( caster.self, SPELL_ID )
        local real bonusMissChance = BONUS_MISS_CHANCE[abilityLevel]
        local real damagePerIntervalAmount = DAMAGE_PER_INTERVAL[abilityLevel] + GetHeroStrengthTotal(caster) * DAMAGE_PER_INTERVAL_PER_STRENGTH_POINT[abilityLevel]
        local timer durationTimer
        local timer intervalTimer
        local integer iteration
        local integer oldAbilityLevel
        local real oldBonusMissChance
        local integer targetId = target.id
        local Data d = GetAttachedIntegerById(targetId, DarkCloud_SCOPE_ID)
        local boolean isNew = (d == NULL)
        local unit targetSelf = target.self
        if ( isNew ) then
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set intervalTimer = CreateTimerWJ()
            set iteration = abilityLevel - 1
            set d.abilityLevel = abilityLevel
            set d.intervalTimer = intervalTimer
            set d.target = target
            loop
                if (iteration == abilityLevel - 1) then
                    set d.caster[iteration] = caster
                    set d.durationTimer[iteration] = durationTimer
                else
                    set d.caster[iteration] = NULL
                    set d.durationTimer[iteration] = null
                endif
                set iteration = iteration - 1
                exitwhen (iteration < 0)
            endloop
            call AttachInteger(durationTimer, DarkCloud_SCOPE_ID, d)
            call AttachInteger(intervalTimer, DarkCloud_SCOPE_ID, d)
            call AttachIntegerById(targetId, DarkCloud_SCOPE_ID, d)
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
            //! runtextmacro AddEventById( "targetId", "EVENT_DISPEL" )
        else
            set durationTimer = d.durationTimer[abilityLevel - 1]
            set d.caster[abilityLevel - 1] = caster
            if (durationTimer == null) then
                set durationTimer = CreateTimerWJ()
                set d.durationTimer[abilityLevel - 1] = durationTimer
                call AttachInteger(durationTimer, DarkCloud_SCOPE_ID, d)
            endif
            set oldAbilityLevel = d.abilityLevel
            set oldBonusMissChance = d.bonusMissChance[oldAbilityLevel - 1]
            call DestroyEffectWJ( d.targetEffect )
            call DestroyEffectWJ( d.targetEffect2 )
        endif
        set d.bonusMissChance[abilityLevel - 1] = bonusMissChance
        set d.damagePerIntervalAmount[abilityLevel - 1] = damagePerIntervalAmount
        set d.targetEffect = AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, targetSelf, TARGET_EFFECT_ATTACHMENT_POINT )
        set d.targetEffect2 = AddSpecialEffectTargetWJ( TARGET_EFFECT2_PATH, targetSelf, TARGET_EFFECT2_ATTACHMENT_POINT )
        set targetSelf = null
        if ( isNew ) then
            call AddUnitMissChance( target, bonusMissChance )
            call TimerStart(intervalTimer, INTERVAL[abilityLevel], true, function Interval)
            set intervalTimer = null
        elseif (abilityLevel >= oldAbilityLevel) then
            set d.abilityLevel = abilityLevel
            call AddUnitMissChance( target, bonusMissChance - oldBonusMissChance )
            call TimerStart(d.intervalTimer, INTERVAL[abilityLevel], true, function Interval)
        endif
        call TimerStart( durationTimer, DURATION[abilityLevel], false, function EndingByTimer )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    public function Order takes Unit caster, unit target returns string
        if ( IsUnitType( target, UNIT_TYPE_MECHANICAL ) ) then
            return ErrorStrings_NOT_MECHANICAL
        endif
        if ( IsUnitType( target, UNIT_TYPE_STRUCTURE ) ) then
            return ErrorStrings_NOT_STRUCTURE
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( ORDERED_UNIT, TARGET_UNIT.self )
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = LEVELS_AMOUNT
        set BONUS_MISS_CHANCE[1] = 0.34
        set BONUS_MISS_CHANCE[2] = 0.41
        set BONUS_MISS_CHANCE[3] = 0.48
        set BONUS_MISS_CHANCE[4] = 0.55
        set BONUS_MISS_CHANCE[5] = 0.62
        set BONUS_MISS_CHANCE_PER_AGILITY_POINT[1] = 0.005
        set BONUS_MISS_CHANCE_PER_AGILITY_POINT[2] = 0.005
        set BONUS_MISS_CHANCE_PER_AGILITY_POINT[3] = 0.005
        set BONUS_MISS_CHANCE_PER_AGILITY_POINT[4] = 0.005
        set BONUS_MISS_CHANCE_PER_AGILITY_POINT[5] = 0.005
        set DAMAGE_PER_INTERVAL[1] = 20
        set DAMAGE_PER_INTERVAL[2] = 35
        set DAMAGE_PER_INTERVAL[3] = 50
        set DAMAGE_PER_INTERVAL[4] = 65
        set DAMAGE_PER_INTERVAL[5] = 80
        set DAMAGE_PER_INTERVAL_PER_STRENGTH_POINT[1] = 0.5
        set DAMAGE_PER_INTERVAL_PER_STRENGTH_POINT[2] = 0.5
        set DAMAGE_PER_INTERVAL_PER_STRENGTH_POINT[3] = 0.5
        set DAMAGE_PER_INTERVAL_PER_STRENGTH_POINT[4] = 0.5
        set DAMAGE_PER_INTERVAL_PER_STRENGTH_POINT[5] = 0.5
        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_DISPEL", "UnitIsDispelled_EVENT_KEY_NEGATIVE", "0", "function Dispel_Event" )
        set INTERVAL[1] = 2.25
        set INTERVAL[2] = 2.25
        set INTERVAL[3] = 2.25
        set INTERVAL[4] = 2.25
        set INTERVAL[5] = 2.25
        set WAVES_AMOUNT[1] = 4
        set WAVES_AMOUNT[2] = 5
        set WAVES_AMOUNT[3] = 6
        set WAVES_AMOUNT[4] = 7
        set WAVES_AMOUNT[5] = 8
        loop
            set DURATION[iteration] = WAVES_AMOUNT[iteration] * INTERVAL[iteration]
            set iteration = iteration - 1
            exitwhen (iteration < 1)
        endloop
        call InitEffectType( TARGET_EFFECT_PATH )
        call InitEffectType( TARGET_EFFECT2_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call Lightning_Lightning_Init()
    endfunction
//! runtextmacro Endscope()