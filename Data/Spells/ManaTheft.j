//TESH.scrollpos=76
//TESH.alwaysfold=0
//! runtextmacro Scope("ManaTheft")
    globals
        private constant integer ORDER_ID = OrderId( "steal" )
        public constant integer SPELL_ID = 'A013'

        private constant string CASTER_EFFECT_PATH = "Abilities\\Spells\\Other\\Drain\\ManaDrainCaster.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "chest"
        private real array DURATION
        private real array STOLEN_MANA_FACTOR
        private real array STOLEN_MANA_FACTOR_PER_INTELLIGENCE_POINT
        private real array STOLEN_MANA_LOWER_CAP
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Other\\Drain\\ManaDrainTarget.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "chest"
    endglobals

    private struct Data
        Unit caster
        timer durationTimer
    endstruct

    private function Ending takes Unit caster, Data d, timer durationTimer returns nothing
        local integer casterId = caster.id
        call d.destroy()
        call FlushAttachedIntegerById(casterId, ManaTheft_SCOPE_ID)
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
        call FlushAttachedInteger(durationTimer, ManaTheft_SCOPE_ID)
        call DestroyTimerWJ( durationTimer )
        call RemoveUnitInvulnerabilityWithEffect( caster )
    endfunction

    public function Death takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById( caster.id, ManaTheft_SCOPE_ID )
        if ( d != NULL ) then
            call Ending( caster, d, d.durationTimer )
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, ManaTheft_SCOPE_ID)
        call Ending( d.caster, d, durationTimer )
        set durationTimer = null
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local integer casterId = caster.id
        local unit casterSelf = caster.self
        local integer abilityLevel = GetUnitAbilityLevel( casterSelf, SPELL_ID )
        local Data d = Data.create()
        local timer durationTimer = CreateTimerWJ()
        local boolean isTargetIllusion = IsUnitIllusionWJ( target )
        local real notStolenMana
        local real stolenMana
        local real stolenManaFactor
        local real stolenManaLowerCap
        local real targetManaFactorized
        local unit targetSelf = target.self
        local real targetMana = GetUnitState( targetSelf, UNIT_STATE_MANA )
        if ( isTargetIllusion ) then
            set stolenMana = 0
        else
            set stolenManaFactor = STOLEN_MANA_FACTOR[abilityLevel] + GetHeroIntelligenceTotal( caster ) * STOLEN_MANA_FACTOR_PER_INTELLIGENCE_POINT[abilityLevel]
            set stolenManaLowerCap = STOLEN_MANA_LOWER_CAP[abilityLevel]
            set targetManaFactorized = targetMana * stolenManaFactor
            if ( targetManaFactorized > stolenManaLowerCap ) then
                set stolenMana = targetManaFactorized
            elseif ( targetMana >= stolenManaLowerCap ) then
                set stolenMana = stolenManaLowerCap
            else
                set stolenMana = targetMana
            endif
        endif
        set notStolenMana = stolenManaLowerCap - stolenMana
        call DestroyEffectTimed( AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, casterSelf, CASTER_EFFECT_ATTACHMENT_POINT ), 2 )
        call DestroyEffectTimed( AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, targetSelf, TARGET_EFFECT_ATTACHMENT_POINT ), 2 )
        set d.caster = caster
        set d.durationTimer = d.durationTimer
        call AttachIntegerById(casterId, ManaTheft_SCOPE_ID, d)
        //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
        call AttachInteger(durationTimer, ManaTheft_SCOPE_ID, d)
        call AddUnitState( casterSelf, UNIT_STATE_MANA, stolenMana )
        set casterSelf = null
        call AddUnitInvulnerabilityWithEffect( caster )
        call TimerStart( durationTimer, DURATION[abilityLevel], false, function EndingByTimer )
        set durationTimer = null
        if ( isTargetIllusion ) then
            call KillUnit( targetSelf )
        else
            call SetUnitState( targetSelf, UNIT_STATE_MANA, targetMana - stolenMana )
        endif
        set targetSelf = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    public function Order takes Unit target returns string
        set TEMP_UNIT_SELF = target.self
        if ( GetUnitState( TEMP_UNIT_SELF, UNIT_STATE_MANA ) <= 0 ) then
            return ErrorStrings_NEEDS_MANA_POOL
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return ErrorStrings_NOT_MECHANICAL
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return ErrorStrings_NOT_STRUCTURE
        endif
        if ( IsUnitWard( target ) ) then
            return ErrorStrings_NOT_WARD
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( TARGET_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        set DURATION[1] = 7
        set DURATION[2] = 12
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        set STOLEN_MANA_FACTOR[1] = 0.5
        set STOLEN_MANA_FACTOR[2] = 0.8
        set STOLEN_MANA_FACTOR_PER_INTELLIGENCE_POINT[1] = 0.005
        set STOLEN_MANA_FACTOR_PER_INTELLIGENCE_POINT[2] = 0.005
        set STOLEN_MANA_LOWER_CAP[1] = 100
        set STOLEN_MANA_LOWER_CAP[2] = 125
        call InitEffectType( CASTER_EFFECT_PATH )
        call InitEffectType( TARGET_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()