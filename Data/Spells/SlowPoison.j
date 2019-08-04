//TESH.scrollpos=154
//TESH.alwaysfold=0
//! runtextmacro Scope("SlowPoison")
    globals
        public constant integer RESEARCH_ID = 'R01L'
        public constant integer SPELL_ID = 'A03O'

        private constant real BONUS_RELATIVE_SPEED = -0.25
        private constant real DURATION = 10.
        private constant real INTERVAL = 1.
        private constant real DAMAGE_PER_INTERVAL = 50 * INTERVAL / DURATION
        private constant real RELATIVE_BONUS_ATTACK_RATE = -0.25
        private constant string TARGET_EFFECT_PATH = "Abilities\\Weapons\\PoisonSting\\PoisonStingTarget.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "origin"
    endglobals

    private struct Data
        real bonusSpeed
        Unit caster
        timer durationTimer
        timer intervalTimer
        Unit target
        effect targetEffect
    endstruct

    public function DecayEnd takes Unit caster returns nothing
        local integer casterId = caster.id
        if (GetAttachedBooleanById(casterId, SlowPoison_SCOPE_ID)) then
            call FlushAttachedBooleanById(casterId, SlowPoison_SCOPE_ID)
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DAMAGE" )
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DECAY_END" )
        endif
    endfunction

    private function DecayEnd_Event takes nothing returns nothing
        call DecayEnd( TRIGGER_UNIT )
    endfunction

    private function Ending takes Data d, timer durationTimer, Unit target returns nothing
        local real bonusSpeed = d.bonusSpeed
        local timer intervalTimer = d.intervalTimer
        local effect targetEffect = d.targetEffect
        local integer targetId = target.id
        call d.destroy()
        call FlushAttachedInteger( durationTimer, SlowPoison_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        call FlushAttachedInteger( intervalTimer, SlowPoison_SCOPE_ID )
        call DestroyTimerWJ( intervalTimer )
        set intervalTimer = null
        call FlushAttachedIntegerById( targetId, SlowPoison_SCOPE_ID )
        //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        call DestroyEffectWJ( targetEffect )
        set targetEffect = null
        call AddUnitAttackRate( target, -RELATIVE_BONUS_ATTACK_RATE )
        call AddUnitSpeedBonus( target, -bonusSpeed )
    endfunction

    public function Death takes Unit target returns nothing
        local Data d = GetAttachedIntegerById( target.id, SlowPoison_SCOPE_ID )
        if ( d != NULL ) then
            call Ending( d, d.durationTimer, target )
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, SlowPoison_SCOPE_ID)
        call Ending( d, durationTimer, d.target )
        set durationTimer = null
    endfunction

    private function Interval takes nothing returns nothing
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, SlowPoison_SCOPE_ID)
        local Unit target = d.target
        set intervalTimer = null
        call UnitDamageUnitEx( d.caster, target, Min( DAMAGE_PER_INTERVAL, GetUnitState( target.self, UNIT_STATE_LIFE ) - LIMIT_OF_IMMORTALS ), null )
    endfunction

    private function Damage_TargetConditions takes Unit caster, player casterOwner, Unit target returns boolean
        if ( GetAttachedBooleanById( caster.id, SlowPoison_SCOPE_ID ) == false ) then
            return false
        endif
        set TEMP_UNIT_SELF = target.self
        if ( IsUnitAlly( TEMP_UNIT_SELF, casterOwner ) ) then
            return false
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        if (GetUnitInvulnerability(target) > 0) then
            return false
        endif
        return true
    endfunction

    public function Damage takes Unit caster, Unit target returns nothing
        local real bonusSpeed
        local Data d
        local timer durationTimer
        local timer intervalTimer
        local boolean isNew
        local real oldBonusSpeed
        local integer targetId
        local unit targetSelf
        if ( Damage_TargetConditions( caster, caster.owner, target ) ) then
            set bonusSpeed = BONUS_RELATIVE_SPEED * GetUnitSpeed(target)
            set targetId = target.id
            set d = GetAttachedIntegerById( targetId, SlowPoison_SCOPE_ID )
            set targetSelf = target.self
            set isNew = ( d == NULL )
            if ( isNew ) then
                set d = Data.create()
                set durationTimer = CreateTimerWJ()
                set intervalTimer = CreateTimerWJ()
                set d.bonusSpeed = bonusSpeed
                set d.durationTimer = durationTimer
                set d.intervalTimer = intervalTimer
                set d.target = target
                call AttachInteger( durationTimer, SlowPoison_SCOPE_ID, d )
                call AttachInteger( intervalTimer, SlowPoison_SCOPE_ID, d )
                call AttachIntegerById( targetId, SlowPoison_SCOPE_ID, d )
                //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
                call TimerStart( intervalTimer, INTERVAL, true, function Interval )
            else
                set durationTimer = d.durationTimer
                call DestroyEffectWJ( d.targetEffect )
            endif
            set d.caster = caster
            set d.targetEffect = AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, targetSelf, TARGET_EFFECT_ATTACHMENT_POINT )
            set targetSelf = null
            if (isNew) then
                call AddUnitAttackRate( target, RELATIVE_BONUS_ATTACK_RATE )
                call AddUnitSpeedBonus( target, bonusSpeed )
            else
                set oldBonusSpeed = d.bonusSpeed
                if (bonusSpeed != oldBonusSpeed) then
                    set d.bonusSpeed = bonusSpeed
                    call AddUnitSpeedBonus( target, bonusSpeed - oldBonusSpeed )
                endif
            endif
            call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
            set durationTimer = null
        endif
    endfunction

    private function Damage_Event takes nothing returns nothing
        call Damage( DAMAGE_SOURCE, TRIGGER_UNIT )
    endfunction

    public function Learn takes Unit caster returns nothing
        local integer casterId = caster.id
        call AttachBooleanById( casterId, SlowPoison_SCOPE_ID, true )
        //! runtextmacro AddEventById( "casterId", "EVENT_DAMAGE" )
        //! runtextmacro AddEventById( "casterId", "EVENT_DECAY_END" )
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 300)

        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY_AS_DAMAGE_SOURCE", "0", "function Damage_Event" )
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_DECAY_END", "UnitFinishesDecaying_End_End_EVENT_KEY", "0", "function DecayEnd_Event" )
        call InitEffectType( TARGET_EFFECT_PATH )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
        call SetAbilityRequiredResearch( SPELL_ID, RESEARCH_ID )
    endfunction
//! runtextmacro Endscope()