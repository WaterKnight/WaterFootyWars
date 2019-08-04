//TESH.scrollpos=139
//TESH.alwaysfold=0
//! runtextmacro Scope("Frenzy")
    globals
        private constant integer ORDER_ID = 852100//OrderId( "berserk" )
        public constant integer SPELL_ID = 'A00G'

        private real array BONUS_SCALE
        private real array BONUS_SPEED_RELATIVE
        private constant string CASTER_EFFECT_PATH = "Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "hand left"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT2 = "hand right"
        private real array DURATION
        private real array DURATION_PER_AGILITY_POINT
        private real array RELATIVE_BONUS_ATTACK_RATE
        private constant real SCALE_TIME = 1.
    endglobals

    private struct Data
        integer abilityLevel
        real bonusSpeed
        Unit caster
        effect casterEffect
        effect casterEffect2
        timer durationTimer
    endstruct

    private function Ending takes Unit caster, Data d, timer durationTimer returns nothing
        local integer abilityLevel = d.abilityLevel
        local real bonusSpeed = -d.bonusSpeed
        local effect casterEffect = d.casterEffect
        local effect casterEffect2 = d.casterEffect2
        local integer casterId = caster.id
        call d.destroy()
        call FlushAttachedIntegerById( casterId, Frenzy_SCOPE_ID )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DISPEL" )
        call DestroyEffectWJ( casterEffect )
        set casterEffect = null
        call DestroyEffectWJ( casterEffect2 )
        set casterEffect2 = null
        call FlushAttachedInteger( durationTimer, Frenzy_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call AddUnitAttackRate( caster, -RELATIVE_BONUS_ATTACK_RATE[abilityLevel] )
        call AddUnitScaleTimed( caster, -BONUS_SCALE[abilityLevel], SCALE_TIME )
        call AddUnitSpeedBonus( caster, bonusSpeed )
    endfunction

    public function Dispel takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, Frenzy_SCOPE_ID)
        if ( d != NULL ) then
            call Ending( caster, d, d.durationTimer )
        endif
    endfunction

    private function Dispel_Event takes nothing returns nothing
        call Dispel( TRIGGER_UNIT )
    endfunction

    public function Death takes Unit caster returns nothing
        call Dispel( caster )
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, Frenzy_SCOPE_ID)
        call Ending( d.caster, d, durationTimer )
        set durationTimer = null
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local integer casterId = caster.id
        local unit casterSelf = caster.self
        local integer abilityLevel = GetUnitAbilityLevel( casterSelf, SPELL_ID )
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local Data d = GetAttachedIntegerById(casterId, Frenzy_SCOPE_ID)
        local timer durationTimer
        local boolean isNew = (d == NULL)
        local real duration = DURATION[abilityLevel] + GetHeroAgilityTotal( caster ) * DURATION_PER_AGILITY_POINT[abilityLevel]
        local real newBonusSpeed = GetUnitSpeed( caster ) * BONUS_SPEED_RELATIVE[abilityLevel]
        local integer oldAbilityLevel
        local real oldBonusSpeed
        if ( isNew ) then
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set d.caster = caster
            set d.durationTimer = durationTimer
            call AttachIntegerById(casterId, Frenzy_SCOPE_ID, d)
            //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
            //! runtextmacro AddEventById( "casterId", "EVENT_DISPEL" )
            call AttachInteger(durationTimer, Frenzy_SCOPE_ID, d)
        else
            set durationTimer = d.durationTimer
            set oldAbilityLevel = d.abilityLevel
            set oldBonusSpeed = d.bonusSpeed
            call DestroyEffectWJ( d.casterEffect )
            call DestroyEffectWJ( d.casterEffect2 )
        endif
        set d.abilityLevel = abilityLevel
        set d.bonusSpeed = newBonusSpeed
        set d.casterEffect = AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, casterSelf, CASTER_EFFECT_ATTACHMENT_POINT )
        set d.casterEffect2 = AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, casterSelf, CASTER_EFFECT_ATTACHMENT_POINT2 )
        if (isNew) then
            call AddUnitAttackRate( caster, RELATIVE_BONUS_ATTACK_RATE[abilityLevel] )
            call AddUnitScaleTimed( caster, BONUS_SCALE[abilityLevel], SCALE_TIME )
            call AddUnitSpeedBonus( caster, newBonusSpeed )
        else
            call AddUnitAttackRate( caster, RELATIVE_BONUS_ATTACK_RATE[abilityLevel] - RELATIVE_BONUS_ATTACK_RATE[oldAbilityLevel] )
            call AddUnitScaleTimed( caster, BONUS_SCALE[abilityLevel] - BONUS_SCALE[oldAbilityLevel], SCALE_TIME )
            call AddUnitSpeedBonus( caster, newBonusSpeed - oldBonusSpeed )
        endif
        call PlaySoundFromTypeAtPosition( FRENZY_SOUND_TYPE, casterX, casterY, GetUnitZ( casterSelf, casterX, casterY ) )
        set casterSelf = null
        if ( duration > TimerGetRemaining( durationTimer ) ) then
            call TimerStart( durationTimer, duration, false, function EndingByTimer )
        endif
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        set BONUS_SCALE[1] = 0.25
        set BONUS_SCALE[2] = 0.25
        set BONUS_SCALE[3] = 0.25
        set BONUS_SCALE[4] = 0.25
        set BONUS_SCALE[5] = 0.25
        set BONUS_SPEED_RELATIVE[1] = 0.2
        set BONUS_SPEED_RELATIVE[2] = 0.26
        set BONUS_SPEED_RELATIVE[3] = 0.3
        set BONUS_SPEED_RELATIVE[4] = 0.34
        set BONUS_SPEED_RELATIVE[5] = 0.37
        set DURATION[1] = 8
        set DURATION[2] = 10
        set DURATION[3] = 12
        set DURATION[4] = 14
        set DURATION[5] = 15
        set DURATION_PER_AGILITY_POINT[1] = 0.1
        set DURATION_PER_AGILITY_POINT[2] = 0.1
        set DURATION_PER_AGILITY_POINT[3] = 0.1
        set DURATION_PER_AGILITY_POINT[4] = 0.1
        set DURATION_PER_AGILITY_POINT[5] = 0.1
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_DISPEL", "UnitIsDispelled_EVENT_KEY_POSITIVE", "0", "function Dispel_Event" )
        set RELATIVE_BONUS_ATTACK_RATE[1] = 0.3
        set RELATIVE_BONUS_ATTACK_RATE[2] = 0.37
        set RELATIVE_BONUS_ATTACK_RATE[3] = 0.43
        set RELATIVE_BONUS_ATTACK_RATE[4] = 0.48
        set RELATIVE_BONUS_ATTACK_RATE[5] = 0.52
        call InitEffectType( CASTER_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()