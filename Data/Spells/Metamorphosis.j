//TESH.scrollpos=193
//TESH.alwaysfold=0
//! runtextmacro Scope("Metamorphosis")
    globals
        private constant integer ORDER_ID = 852180//OrderId( "metamorphosis" )
        public constant integer SPELL_ID = 'A00Y'

        private real array AREA_RANGE
        private real array BONUS_DAMAGE
        private real array BONUS_SCALE
        private real array BONUS_SPEED
        private constant string CASTER_EFFECT_PATH = "Abilities\\Spells\\Undead\\ThornyShield\\ThornyShieldTargetChestMountLeft.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "chest mount left"
        private constant string CASTER_EFFECT2_PATH = "Abilities\\Spells\\Undead\\ThornyShield\\ThornyShieldTargetChestMountRight.mdl"
        private constant string CASTER_EFFECT2_ATTACHMENT_POINT = "chest mount right"
        private constant string CASTER_EFFECT3_PATH = "Abilities\\Spells\\NightElf\\CorrosiveBreath\\ChimaeraAcidTargetArt.mdl"
        private constant string CASTER_EFFECT3_ATTACHMENT_POINT = "origin"
        private real array DAMAGE_PER_INTERVAL
        private real array DURATION
        private real array DURATION_PER_STRENGTH_POINT
        private group ENUM_GROUP
        private constant real INTERVAL = 1.
        private constant integer LEVELS_AMOUNT = 5
        private real array SCALE_TIME
        private boolexpr TARGET_CONDITIONS
    endglobals

    private struct Data
        integer abilityLevel
        Unit caster
        effect casterEffect
        effect casterEffect2
        effect casterEffect3
        timer durationTimer
        timer intervalTimer
    endstruct

    private function Ending takes Unit caster, Data d, timer durationTimer returns nothing
        local integer abilityLevel = d.abilityLevel
        local effect casterEffect = d.casterEffect
        local effect casterEffect2 = d.casterEffect2
        local effect casterEffect3 = d.casterEffect3
        local integer casterId = caster.id
        local timer intervalTimer = d.intervalTimer
        call d.destroy()
        call FlushAttachedIntegerById( casterId, Metamorphosis_SCOPE_ID )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
        call DestroyEffectWJ(casterEffect)
        set casterEffect = null
        call DestroyEffectWJ(casterEffect2)
        set casterEffect2 = null
        call DestroyEffectWJ(casterEffect3)
        set casterEffect3 = null
        call FlushAttachedInteger( durationTimer, Metamorphosis_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        call FlushAttachedInteger( intervalTimer, Metamorphosis_SCOPE_ID )
        call DestroyTimerWJ( intervalTimer )
        set intervalTimer = null
        call AddUnitDamageBonus( caster, -BONUS_DAMAGE[abilityLevel] )
        call AddUnitSpeedBonus( caster, -BONUS_SPEED[abilityLevel] )
        call AddUnitScaleTimed( caster, -BONUS_SCALE[abilityLevel], SCALE_TIME[abilityLevel] )
    endfunction

    public function Death takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById( caster.id, Metamorphosis_SCOPE_ID )
        if ( d != NULL ) then
            call Ending( caster, d, d.durationTimer )
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, Metamorphosis_SCOPE_ID)
        call Ending( d.caster, d, durationTimer )
        set durationTimer = null
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
        if ( IsUnitWard( FILTER_UNIT ) ) then
            return false
        endif
        return true
    endfunction

    private function DealDamage takes nothing returns nothing
        local real damageAmount
        local unit enumUnit
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, Metamorphosis_SCOPE_ID)
        local integer abilityLevel = d.abilityLevel
        local Unit caster = d.caster
        local unit casterSelf = caster.self
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, GetUnitX(casterSelf), GetUnitY(casterSelf), AREA_RANGE[abilityLevel], TARGET_CONDITIONS )
        set casterSelf = null
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit != null ) then
            set damageAmount = DAMAGE_PER_INTERVAL[abilityLevel]
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                call UnitDamageUnitBySpell( caster, GetUnit(enumUnit), damageAmount )
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local integer casterId = caster.id
        local unit casterSelf = caster.self
        local integer abilityLevel = GetUnitAbilityLevel( casterSelf, SPELL_ID )
        local Data d = GetAttachedIntegerById(casterId, Metamorphosis_SCOPE_ID)
        local real duration = DURATION[abilityLevel] + GetHeroStrengthTotal( caster ) * DURATION_PER_STRENGTH_POINT[abilityLevel]
        local timer durationTimer
        local timer intervalTimer
        local boolean isNew = ( d == NULL )
        local integer oldAbilityLevel
        if ( isNew ) then
            set casterSelf = caster.self
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set intervalTimer = CreateTimerWJ()
            set d.caster = caster
            set d.casterEffect = AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, casterSelf, CASTER_EFFECT_ATTACHMENT_POINT )
            set d.casterEffect2 = AddSpecialEffectTargetWJ( CASTER_EFFECT2_PATH, casterSelf, CASTER_EFFECT2_ATTACHMENT_POINT )
            set d.casterEffect3 = AddSpecialEffectTargetWJ( CASTER_EFFECT3_PATH, casterSelf, CASTER_EFFECT3_ATTACHMENT_POINT )
            set casterSelf = null
            set d.durationTimer = durationTimer
            set d.intervalTimer = intervalTimer
            call AttachIntegerById( casterId, Metamorphosis_SCOPE_ID, d )
            //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
            call AttachInteger( durationTimer, Metamorphosis_SCOPE_ID, d )
            call AttachInteger( intervalTimer, Metamorphosis_SCOPE_ID, d )
        else
            set durationTimer = d.durationTimer
            set oldAbilityLevel = d.abilityLevel
        endif
        set d.abilityLevel = abilityLevel
        if ( isNew ) then
            call AddUnitDamageBonus( caster, BONUS_DAMAGE[abilityLevel] )
            call AddUnitScaleTimed( caster, BONUS_SCALE[abilityLevel], SCALE_TIME[abilityLevel] )
            call AddUnitSpeedBonus( caster, BONUS_SPEED[abilityLevel] )
            call TimerStart( intervalTimer, INTERVAL, true, function DealDamage )
            set intervalTimer = null
        else
            call AddUnitDamageBonus( caster, BONUS_DAMAGE[abilityLevel] - BONUS_DAMAGE[oldAbilityLevel] )
            call AddUnitScaleTimed( caster, BONUS_SCALE[abilityLevel] - BONUS_SCALE[oldAbilityLevel], SCALE_TIME[abilityLevel] - SCALE_TIME[oldAbilityLevel] )
            call AddUnitSpeedBonus( caster, BONUS_SPEED[abilityLevel] - BONUS_SPEED[oldAbilityLevel] )
        endif
        if ( duration > TimerGetRemaining( durationTimer ) ) then
            call TimerStart( durationTimer, duration, false, function EndingByTimer )
        endif
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = LEVELS_AMOUNT
        set AREA_RANGE[1] = 200
        set AREA_RANGE[2] = 200
        set BONUS_DAMAGE[1] = 15
        set BONUS_DAMAGE[2] = 25
        set BONUS_SCALE[1] = 0.2
        set BONUS_SCALE[2] = 0.2
        set BONUS_SPEED[1] = 70
        set BONUS_SPEED[2] = 90
        set DAMAGE_PER_INTERVAL[1] = 35
        set DAMAGE_PER_INTERVAL[2] = 50
        loop
            set DAMAGE_PER_INTERVAL[iteration] = DAMAGE_PER_INTERVAL[iteration] * INTERVAL
            set iteration = iteration - 1
            exitwhen (iteration < 1)
        endloop
        set DURATION[1] = 30
        set DURATION[2] = 30
        set DURATION_PER_STRENGTH_POINT[1] = 0.1
        set DURATION_PER_STRENGTH_POINT[2] = 0.1
        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        set SCALE_TIME[1] = 2
        set SCALE_TIME[2] = 2.25
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( CASTER_EFFECT_PATH )
        call InitEffectType( CASTER_EFFECT2_PATH )
        call InitEffectType( CASTER_EFFECT3_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()