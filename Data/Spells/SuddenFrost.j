//TESH.scrollpos=99
//TESH.alwaysfold=0
//! runtextmacro Scope("SuddenFrost")
    globals
        public constant integer SPELL_ID = 'A06Q'

        private constant real BONUS_ARMOR = -2.
        private constant real BONUS_HEAL_BY_SPELL = -0.25
        private constant real DURATION = 10.
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Other\\FrostDamage\\FrostDamage.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        private constant string TARGET_EFFECT2_PATH = "Abilities\\Spells\\Items\\AIob\\AIobTarget.mdl"
        private constant string TARGET_EFFECT2_ATTACHMENT_POINT = "head"
    endglobals

    private struct Data
        timer durationTimer
        Unit target
        effect targetEffect
        effect targetEffect2
    endstruct

    private function Ending takes Data d, timer durationTimer, Unit target returns nothing
        local effect targetEffect = d.targetEffect
        local effect targetEffect2 = d.targetEffect2
        local integer targetId = target.id
        call d.destroy()
        call FlushAttachedInteger( durationTimer, SuddenFrost_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        call FlushAttachedIntegerById( targetId, SuddenFrost_SCOPE_ID )
        //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        call DestroyEffectWJ( targetEffect )
        set targetEffect = null
        call DestroyEffectWJ( targetEffect2 )
        set targetEffect2 = null
        call AddUnitArmorBonus( target, -BONUS_ARMOR )
        call AddUnitHealBySpell( target, -BONUS_HEAL_BY_SPELL )
    endfunction

    public function Death takes Unit target returns nothing
        local Data d = GetAttachedIntegerById( target.id, SuddenFrost_SCOPE_ID )
        if ( d != NULL ) then
            call Ending( d, d.durationTimer, target )
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, SuddenFrost_SCOPE_ID)
        call Ending( d, durationTimer, d.target )
        set durationTimer = null
    endfunction

    private function Damage_TargetConditions takes player casterOwner, unit target returns boolean
        if ( IsUnitAlly( target, casterOwner ) ) then
            return false
        endif
        if ( IsUnitType( target, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        return true
    endfunction

    public function Damage takes Unit caster, Unit target returns nothing
        local Data d
        local timer durationTimer
        local integer targetId
        local unit targetSelf = target.self
        if (GetAttachedBooleanById(caster.id, SuddenFrost_SCOPE_ID)) then
            if ( Damage_TargetConditions( caster.owner, targetSelf ) ) then
                set targetId = target.id
                set d = GetAttachedIntegerById( targetId, SuddenFrost_SCOPE_ID )
                if ( d == NULL ) then
                    set d = Data.create()
                    set durationTimer = CreateTimerWJ()
                    set d.durationTimer = durationTimer
                    set d.target = target
                    call AttachInteger( durationTimer, SuddenFrost_SCOPE_ID, d )
                    call AttachIntegerById( targetId, SuddenFrost_SCOPE_ID, d )
                    //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
                    call AddUnitArmorBonus( target, BONUS_ARMOR )
                    call AddUnitHealBySpell( target, BONUS_HEAL_BY_SPELL )
                else
                    set durationTimer = d.durationTimer
                    call DestroyEffectWJ( d.targetEffect )
                    call DestroyEffectWJ( d.targetEffect2 )
                endif
                set d.targetEffect = AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, targetSelf, TARGET_EFFECT_ATTACHMENT_POINT )
                set d.targetEffect2 = AddSpecialEffectTargetWJ( TARGET_EFFECT2_PATH, targetSelf, TARGET_EFFECT2_ATTACHMENT_POINT )
                set targetSelf = null
                call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
                set durationTimer = null
            endif
        endif
    endfunction

    private function Damage_Event takes nothing returns nothing
        call Damage( DAMAGE_SOURCE, TRIGGER_UNIT )
    endfunction

    public function Learn takes Unit caster returns nothing
        local integer casterId = caster.id
        call AttachBooleanById( casterId, SuddenFrost_SCOPE_ID, true )
        //! runtextmacro AddEventById( "casterId", "EVENT_DAMAGE" )
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY_AS_DAMAGE_SOURCE", "0", "function Damage_Event" )
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        call InitEffectType( TARGET_EFFECT_PATH )
        call InitEffectType( TARGET_EFFECT2_PATH )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
    endfunction
//! runtextmacro Endscope()