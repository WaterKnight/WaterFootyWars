//TESH.scrollpos=15
//TESH.alwaysfold=0
//! runtextmacro Scope("AcidStrike")
    globals
        private constant integer ORDER_ID = 852527//OrderId( "shadowstrike" )
        public constant integer SPELL_ID = 'A00V'

        private real array BONUS_ARMOR
        private real array BONUS_SPEED
        private real array DAMAGE
        private real array DAMAGE_PER_INTERVAL
        private real array DAMAGE_PER_INTERVAL_PER_INTELLIGENCE_POINT
        private real array DURATION
        private real array HERO_DURATION
        private real array INTERVAL
        private constant integer LEVELS_AMOUNT = 5
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\NightElf\\shadowstrike\\shadowstrike.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "overhead"
        private constant string TARGET_EFFECT2_PATH = "Objects\\Spawnmodels\\Undead\\UndeadBlood\\UndeadBloodCryptFiend.mdl"
        private constant string TARGET_EFFECT2_ATTACHMENT_POINT = "origin"
    endglobals

    private struct Data
        integer abilityLevel
        real array bonusSpeed[LEVELS_AMOUNT]
        Unit array caster[LEVELS_AMOUNT]
        real array damageAmount[LEVELS_AMOUNT]
        timer array durationTimer[LEVELS_AMOUNT]
        timer intervalTimer
        Unit target
        effect targetEffect
    endstruct

    private function Interval takes nothing returns nothing
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, AcidStrike_SCOPE_ID)
        local integer abilityLevel = d.abilityLevel
        local real damageAmount = d.damageAmount[abilityLevel - 1]
        local Unit target = d.target
        local unit targetSelf = target.self
        local real targetX = GetUnitX(targetSelf)
        local real targetY = GetUnitY(targetSelf)
        set intervalTimer = null
        call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT2_PATH, targetSelf, TARGET_EFFECT2_ATTACHMENT_POINT ) )
        call CreateRisingTextTag( I2S( R2I( damageAmount ) ), 0.023, GetUnitX( targetSelf ), GetUnitY( targetSelf ), GetUnitZ( targetSelf, targetX, targetY ) + GetUnitOutpactZ(target), 80, 200, 0, 155, 255, 1, 4 )
        set targetSelf = null
        call UnitDamageUnitBySpell( d.caster[abilityLevel - 1], target, damageAmount )
    endfunction

    private function Ending takes Data d, timer durationTimer, Unit target returns nothing
        local integer abilityLevel = d.abilityLevel
        local real bonusSpeed
        local timer intervalTimer
        local integer iteration = abilityLevel - 1
        local effect targetEffect
        local integer targetId
        loop
            exitwhen (durationTimer == d.durationTimer[iteration])
            set iteration = iteration - 1
        endloop
        set d.durationTimer[iteration] = null
        if ( abilityLevel - 1 <= iteration ) then
            set bonusSpeed = d.bonusSpeed[abilityLevel - 1]
            loop
                exitwhen (iteration < 0)
                exitwhen (d.durationTimer[iteration] != null)
                set iteration = iteration - 1
            endloop
            if ( iteration > -1 ) then
                set d.abilityLevel = iteration + 1
                call AddUnitArmorBonus( target, BONUS_ARMOR[iteration] - BONUS_ARMOR[abilityLevel] )
                call AddUnitSpeedBonus( target, BONUS_SPEED[iteration] - BONUS_SPEED[abilityLevel] )
                call TimerStart(d.intervalTimer, INTERVAL[iteration], true, function Interval)
            else
                set intervalTimer = d.intervalTimer
                set targetEffect = d.targetEffect
                set targetId = target.id
                call d.destroy()
                call DestroyTimerWJ(intervalTimer)
                set intervalTimer = null
                call DestroyEffectWJ( targetEffect )
                set targetEffect = null
                call FlushAttachedIntegerById( targetId, AcidStrike_SCOPE_ID )
                //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
                call AddUnitArmorBonus( target, -BONUS_ARMOR[abilityLevel] )
                call AddUnitSpeedBonus( target, -BONUS_SPEED[abilityLevel] )
            endif
        endif
        call FlushAttachedInteger( durationTimer, AcidStrike_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
    endfunction

    public function Death takes Unit target returns nothing
        local integer abilityLevel
        local Data d = GetAttachedIntegerById(target.id, AcidStrike_SCOPE_ID)
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
                exitwhen ( iteration >= abilityLevel )
            endloop
            set durationTimer = null
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, AcidStrike_SCOPE_ID)
        call Ending( d, durationTimer, d.target )
        set durationTimer = null
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local unit casterSelf = caster.self
        local integer abilityLevel = GetUnitAbilityLevel(casterSelf, SPELL_ID)
        local real damageAmount = DAMAGE[abilityLevel]
        local real duration
        local timer durationTimer
        local timer intervalTimer
        local integer iteration
        local integer oldAbilityLevel
        local real oldBonusSpeed
        local integer targetId = target.id
        local Data d = GetAttachedIntegerById(targetId, AcidStrike_SCOPE_ID)
        local boolean isNew = (d == NULL)
        local unit targetSelf = target.self
        local real targetX = GetUnitX( targetSelf )
        local real targetY = GetUnitY( targetSelf )
        set casterSelf = null
        if ( isNew ) then
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set intervalTimer = CreateTimerWJ()
            set iteration = LEVELS_AMOUNT - 1
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
            call AttachInteger(durationTimer, AcidStrike_SCOPE_ID, d)
            call AttachInteger(intervalTimer, AcidStrike_SCOPE_ID, d)
            call AttachIntegerById(targetId, AcidStrike_SCOPE_ID, d)
        else
            set durationTimer = d.durationTimer[abilityLevel - 1]
            set d.caster[abilityLevel - 1] = caster
            if (durationTimer == null) then
                set durationTimer = CreateTimerWJ()
                set d.durationTimer[abilityLevel - 1] = durationTimer
                call AttachInteger(durationTimer, AcidStrike_SCOPE_ID, d)
            endif
            set oldAbilityLevel = d.abilityLevel
            set oldBonusSpeed = d.bonusSpeed[oldAbilityLevel - 1]
            call DestroyEffectWJ( d.targetEffect )
        endif
        set d.damageAmount[abilityLevel - 1] = DAMAGE_PER_INTERVAL[abilityLevel] + GetHeroIntelligence(caster) * DAMAGE_PER_INTERVAL_PER_INTELLIGENCE_POINT[abilityLevel]
        set d.targetEffect = AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, targetSelf, TARGET_EFFECT_ATTACHMENT_POINT )
        if ( isNew ) then
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
            call AddUnitArmorBonus( target, BONUS_ARMOR[abilityLevel] )
            call AddUnitSpeedBonus( target, BONUS_SPEED[abilityLevel] )
            call TimerStart(intervalTimer, INTERVAL[abilityLevel], true, function Interval)
        elseif (abilityLevel > oldAbilityLevel) then
            set d.abilityLevel = abilityLevel
            call AddUnitArmorBonus( target, BONUS_ARMOR[abilityLevel] - BONUS_ARMOR[oldAbilityLevel] )
            call AddUnitSpeedBonus( target, BONUS_SPEED[abilityLevel] - BONUS_SPEED[oldAbilityLevel] )
        endif
        if ( IsUnitType( targetSelf, UNIT_TYPE_HERO ) ) then
            set duration = HERO_DURATION[abilityLevel]
        else
            set duration = DURATION[abilityLevel]
        endif
        call PlaySoundFromTypeOnUnit( ACID_STRIKE_SOUND_TYPE, targetSelf )
        call TimerStart( durationTimer, duration, false, function EndingByTimer )
        set durationTimer = null
        call CreateRisingTextTag( I2S( R2I( damageAmount ) ), 0.025, targetX, targetY, GetUnitZ( targetSelf, targetX, targetY ) + GetUnitOutpactZ(target), 80, 200, 0, 155, 255, 1, 4 )
        set targetSelf = null
        call UnitDamageUnitBySpell( caster, target, damageAmount )
    endfunction


    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    public function Order takes player casterOwner, Unit target returns string
        set TEMP_UNIT_SELF = target.self
        if ( IsUnitAlly( TEMP_UNIT_SELF, casterOwner ) ) then
            return ErrorStrings_NOT_ALLY
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return ErrorStrings_NOT_MECHANICAL
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return ErrorStrings_NOT_STRUCTURE
        endif
        if ( GetUnitMagicImmunity(target) > 0 ) then
            return ErrorStrings_TARGET_IS_MAGIC_IMMUNE
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( ORDERED_UNIT.owner, TARGET_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        set BONUS_ARMOR[1] = -4
        set BONUS_ARMOR[2] = -5
        set BONUS_ARMOR[3] = -7
        set BONUS_ARMOR[4] = -7
        set BONUS_ARMOR[5] = -8
        set BONUS_SPEED[1] = -60
        set BONUS_SPEED[2] = -70
        set BONUS_SPEED[3] = -80
        set BONUS_SPEED[4] = -90
        set BONUS_SPEED[5] = -100
        set DAMAGE[1] = 50
        set DAMAGE[2] = 60
        set DAMAGE[3] = 70
        set DAMAGE[4] = 80
        set DAMAGE[5] = 90
        set DAMAGE_PER_INTERVAL[1] = 11
        set DAMAGE_PER_INTERVAL[2] = 14
        set DAMAGE_PER_INTERVAL[3] = 17
        set DAMAGE_PER_INTERVAL[4] = 20
        set DAMAGE_PER_INTERVAL[5] = 23
        set DAMAGE_PER_INTERVAL_PER_INTELLIGENCE_POINT[1] = 0.08
        set DAMAGE_PER_INTERVAL_PER_INTELLIGENCE_POINT[2] = 0.08
        set DAMAGE_PER_INTERVAL_PER_INTELLIGENCE_POINT[3] = 0.08
        set DAMAGE_PER_INTERVAL_PER_INTELLIGENCE_POINT[4] = 0.08
        set DAMAGE_PER_INTERVAL_PER_INTELLIGENCE_POINT[5] = 0.08
        set DURATION[1] = 8
        set DURATION[2] = 8
        set DURATION[3] = 9
        set DURATION[4] = 10
        set DURATION[5] = 11
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        set HERO_DURATION[1] = 4
        set HERO_DURATION[2] = 4
        set HERO_DURATION[3] = 5
        set HERO_DURATION[4] = 6
        set HERO_DURATION[5] = 6
        set INTERVAL[1] = 0.5
        set INTERVAL[2] = 0.5
        set INTERVAL[3] = 0.5
        set INTERVAL[4] = 0.5
        set INTERVAL[5] = 0.5
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call InitEffectType( TARGET_EFFECT_PATH )
        call InitEffectType( TARGET_EFFECT2_PATH )
    endfunction
//! runtextmacro Endscope()