//TESH.scrollpos=122
//TESH.alwaysfold=0
//! runtextmacro Scope("EmployHenchman")
    globals
        private constant integer ORDER_ID = 852072//OrderId( "militia" )
        public constant integer SPELL_ID = 'A06Z'

        private constant real BONUS_RELATIVE_ATTACK_RATE = 0.1
        private constant real DURATION = 30.
        private constant real RELATIVE_RESTORED_LIFE = 0.5
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Other\\Silence\\SilenceTarget.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "overhead"
    endglobals

    private struct Data
        timer durationTimer
        Unit target
        effect targetEffect
    endstruct

    //! runtextmacro Scope("Cooldown")
        globals
            private constant real Cooldown_DURATION = 30.
            private constant real Cooldown_DURATION_PER_INTELLIGENCE_POINT = -0.2
        endglobals

        private struct Cooldown_Data
            Unit caster
        endstruct

        private function Cooldown_Ending takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Cooldown_Data d = GetAttachedInteger(durationTimer, Cooldown_SCOPE_ID)
            local Unit caster = d.caster
            local player casterOwner = caster.owner
            local unit casterSelf = caster.self
            call d.destroy()
            call DestroyTimerWJ( durationTimer )
            set durationTimer = null
            if ( IsUnitSelected( casterSelf, casterOwner ) ) then
                call PlaySoundFromTypeForPlayer( COOLDOWN_SOUND_TYPE, casterOwner )
            endif
            set casterOwner = null
            call UnitAddAbility(casterSelf, SPELL_ID)
            set casterSelf = null
        endfunction

        private function Cooldown_PreEnding takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Cooldown_Data d = GetAttachedInteger(durationTimer, Cooldown_SCOPE_ID)
            local Unit caster = d.caster
            local unit casterSelf = caster.self
            call UnitRemoveAbility( casterSelf, SPELL_ID )
            set casterSelf = null
            call TimerStart( durationTimer, 0.5, false, function Cooldown_Ending )
            set durationTimer = null
        endfunction

        public function Cooldown_Start takes Unit caster returns nothing
            local timer durationTimer = CreateTimerWJ()
            local Cooldown_Data d = Cooldown_Data.create()
            set d.caster = caster
            call AttachInteger( durationTimer, Cooldown_SCOPE_ID, d )
            call TimerStart( durationTimer, Cooldown_DURATION + GetHeroIntelligenceTotal( caster ) * Cooldown_DURATION_PER_INTELLIGENCE_POINT - 0.5, false, function Cooldown_PreEnding )
            set durationTimer = null
        endfunction
    //! runtextmacro Endscope()

    private function Ending takes Data d, timer durationTimer, Unit target returns nothing
        local effect targetEffect = d.targetEffect
        local integer targetId = target.id
        call d.destroy()
        call FlushAttachedInteger( durationTimer, EmployHenchman_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        call FlushAttachedIntegerById( targetId, EmployHenchman_SCOPE_ID )
        //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        call DestroyEffectWJ( targetEffect )
        set targetEffect = null
        call SetUnitRevaluation(target, 0)
    endfunction

    public function Death takes Unit target returns nothing
        local Data d = GetAttachedIntegerById( target.id, EmployHenchman_SCOPE_ID )
        if ( d != NULL ) then
            call Ending( d, d.durationTimer, target )
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, EmployHenchman_SCOPE_ID)
        call Ending( d, durationTimer, d.target )
        set durationTimer = null
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local timer durationTimer
        local integer targetId = target.id
        local Data d = GetAttachedIntegerById(targetId, EmployHenchman_SCOPE_ID)
        local boolean isNew = ( d == NULL )
        local unit targetSelf = target.self
        if ( isNew ) then
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set d.durationTimer = durationTimer
            set d.target = target
            call AttachInteger( durationTimer, EmployHenchman_SCOPE_ID, d )
            call AttachIntegerById( targetId, EmployHenchman_SCOPE_ID, d )
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
        else
            set durationTimer = d.durationTimer
            call DestroyEffectWJ( d.targetEffect )
        endif
        set d.targetEffect = AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, targetSelf, TARGET_EFFECT_ATTACHMENT_POINT )
        if ( isNew ) then
            call AddUnitAttackRate( target, BONUS_RELATIVE_ATTACK_RATE )
            call SetUnitRevaluation(target, 2)
        endif
        call HealUnitBySpell( target, GetUnitState( targetSelf, UNIT_STATE_MAX_LIFE ) * RELATIVE_RESTORED_LIFE )
        set targetSelf = null
        call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
        set durationTimer = null
        call Cooldown_Cooldown_Start(caster)
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    public function Order takes player casterOwner, Unit target returns string
        local UnitType targetType
        if ( IsUnitAlly( target.self, casterOwner ) == false ) then
            return ErrorStrings_ONLY_ALLY
        endif
        set targetType = target.type
        if ( ( IsUnitTypeSpawn(targetType) == false ) and ( targetType.id != RESERVE_UNIT_ID ) ) then
            return ErrorStrings_ONLY_SPAWNS_OR_RESERVE
        endif
        if ( IsUnitIllusionWJ( target ) ) then
            return ErrorStrings_NOT_ILLUSION
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( ORDERED_UNIT.owner, TARGET_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        call InitEffectType( TARGET_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()