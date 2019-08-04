//TESH.scrollpos=132
//TESH.alwaysfold=0
//! runtextmacro Scope("Disarm")
    globals
        public constant integer RESEARCH_ID = 'R019'
        public constant integer SPELL_ID = 'A089'

        private constant real DURATION = 10.
        private constant real RELATIVE_BONUS_DAMAGE = -0.4
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\NightElf\\Barkskin\\BarkSkinTarget.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "hand right"
    endglobals

    private struct Data
        real bonusDamage
        timer durationTimer
        Unit target
        effect targetEffect
    endstruct

    public function DecayEnd takes Unit caster returns nothing
        local integer casterId = caster.id
        if (GetAttachedBooleanById( casterId, Disarm_SCOPE_ID )) then
            call FlushAttachedBooleanById( casterId, Disarm_SCOPE_ID )
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DAMAGE" )
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DECAY_END" )
        endif
    endfunction

    private function DecayEnd_Event takes nothing returns nothing
        call DecayEnd( TRIGGER_UNIT )
    endfunction

    private function Ending takes Data d, timer durationTimer, Unit target returns nothing
        local real bonusDamage = d.bonusDamage
        local effect targetEffect = d.targetEffect
        local integer targetId = target.id
        call d.destroy()
        call FlushAttachedInteger( durationTimer, Disarm_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        call FlushAttachedIntegerById( targetId, Disarm_SCOPE_ID )
        //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        call DestroyEffectWJ( targetEffect )
        set targetEffect = null
        call AddUnitDamageBonus( target, -bonusDamage )
    endfunction

    public function Dispel takes Unit target returns nothing
        local Data d = GetAttachedIntegerById( target.id, Disarm_SCOPE_ID )
        if ( d != NULL ) then
            call Ending( d, d.durationTimer, target )
        endif
    endfunction

    private function Dispel_Event takes nothing returns nothing
        call Dispel( DYING_UNIT )
    endfunction

    public function Death takes Unit target returns nothing
        call Dispel(target)
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, Disarm_SCOPE_ID)
        call Ending( d, durationTimer, d.target )
        set durationTimer = null
    endfunction

    private function Damage_TargetConditions takes Unit caster, player casterOwner, unit target returns boolean
        if ( GetAttachedBooleanById( caster.id, Disarm_SCOPE_ID ) == false ) then
            return false
        endif
        if ( IsUnitAlly( target, casterOwner ) ) then
            return false
        endif
        if ( IsUnitType( target, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        return true
    endfunction

    public function Damage takes Unit caster, Unit target returns nothing
        local real bonusDamage
        local Data d
        local timer durationTimer
        local boolean isNew
        local real oldBonusDamage
        local integer targetId
        local unit targetSelf = target.self
        if ( Damage_TargetConditions( caster, caster.owner, targetSelf ) ) then
            set bonusDamage = RELATIVE_BONUS_DAMAGE * GetUnitDamage(target)
            set targetId = target.id
            set d = GetAttachedIntegerById( targetId, Disarm_SCOPE_ID )
            set isNew = ( d == NULL )
            if ( isNew ) then
                set d = Data.create()
                set durationTimer = CreateTimerWJ()
                set d.bonusDamage = bonusDamage
                set d.durationTimer = durationTimer
                set d.target = target
                call AttachInteger( durationTimer, Disarm_SCOPE_ID, d )
                call AttachIntegerById( targetId, Disarm_SCOPE_ID, d )
                //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
            else
                set durationTimer = d.durationTimer
                call DestroyEffectWJ( d.targetEffect )
            endif
            set d.targetEffect = AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, targetSelf, TARGET_EFFECT_ATTACHMENT_POINT )
            set targetSelf = null
            if (isNew) then
                call AddUnitDamageBonus( target, bonusDamage )
            else
                set oldBonusDamage = d.bonusDamage
                if (bonusDamage != oldBonusDamage) then
                    set d.bonusDamage = bonusDamage
                    call AddUnitDamageBonus( target, bonusDamage - oldBonusDamage )
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
        call AttachBooleanById( casterId, Disarm_SCOPE_ID, true )
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