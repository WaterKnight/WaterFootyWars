//TESH.scrollpos=62
//TESH.alwaysfold=0
//! runtextmacro Scope("Defend")
    globals
        private constant integer ACTIVATION_ORDER_ID = 852055//OrderId( "defend" )
        private constant integer DEACTIVATION_ORDER_ID = 852056//OrderId( "undefend" )
        public constant integer RESEARCH_ID = 'R013'
        public constant integer SPELL_ID = 'A083'

        private constant real BONUS_SPEED = -150.
        private constant string CASTER_EFFECT_PATH = "Abilities\\Spells\\Human\\Defend\\DefendCaster.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "origin"
        private constant real DAMAGE_FACTOR = 0.3
    endglobals

    private struct Data
    endstruct

    private function Ending takes Unit caster, Data d returns nothing
        local integer casterId = caster.id
        call d.destroy()
        call FlushAttachedIntegerById( casterId, Defend_SCOPE_ID )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DAMAGE" )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
        call AddUnitSpeedBonus( caster, -BONUS_SPEED )
    endfunction

    public function Death takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, Defend_SCOPE_ID)
        if ( d != NULL ) then
            call Ending( caster, d )
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    public function Damage takes Unit caster, real damageAmount, Unit damageSource returns real
        if ((GetAttachedIntegerById(caster.id, Defend_SCOPE_ID) != NULL)) then
            if (GetUnitTypeDamageType(damageSource.type) == DMG_TYPE_PIERCE) then
                return (damageAmount * DAMAGE_FACTOR)
            endif
        endif
        return damageAmount
    endfunction

    private function Damage_Event takes nothing returns nothing
        set DAMAGE_AMOUNT = Damage(TRIGGER_UNIT, DAMAGE_AMOUNT, DAMAGE_SOURCE)
    endfunction

    public function Deactivation_OrderExecute takes Unit caster returns nothing
        local integer casterId
        local unit casterSelf = caster.self
        local Data d
        if (IsUnitType(casterSelf, UNIT_TYPE_DEAD) == false) then
            set casterId = caster.id
            set d = GetAttachedIntegerById(casterId, Defend_SCOPE_ID)
            if ( d != NULL ) then
                call DestroyEffectWJ( AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, casterSelf, CASTER_EFFECT_ATTACHMENT_POINT ) )
                call Ending(caster, d)
            endif
        endif
        set casterSelf = null
    endfunction

    private function Deactivation_OrderExecute_Event takes nothing returns nothing
        call Deactivation_OrderExecute( ORDERED_UNIT )
    endfunction

    public function Activation_OrderExecute takes Unit caster returns nothing
        local integer casterId = caster.id
        local Data d = GetAttachedIntegerById(casterId, Defend_SCOPE_ID)
        if ( d == NULL ) then
            set d = Data.create()
            call DestroyEffectWJ( AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, caster.self, CASTER_EFFECT_ATTACHMENT_POINT ) )
            call AttachIntegerById(casterId, Defend_SCOPE_ID, d)
            //! runtextmacro AddEventById( "casterId", "EVENT_DAMAGE" )
            //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
            call AddUnitSpeedBonus( caster, BONUS_SPEED )
        endif
    endfunction

    private function Activation_OrderExecute_Event takes nothing returns nothing
        call Activation_OrderExecute( ORDERED_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 300)

        //! runtextmacro AddNewEventById( "EVENT_ACTIVATION_ORDER_EXECUTE", "GetAbilityOrderId( SPELL_ID, ACTIVATION_ORDER_ID )", "UnitGetsOrder_Executed_Executed_EVENT_KEY", "0", "function Activation_OrderExecute_Event" )
        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_FOR_DAMAGE", "0", "function Damage_Event" )
        //! runtextmacro AddNewEventById( "EVENT_DEACTIVATION_ORDER_EXECUTE", "GetAbilityOrderId( SPELL_ID, DEACTIVATION_ORDER_ID )", "UnitGetsOrder_Executed_Executed_EVENT_KEY", "0", "function Deactivation_OrderExecute_Event" )
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateDummyEvent( "EVENT_ORDER_EXECUTE", "UnitGetsOrder_Executed_Executed_EVENT_KEY", "0" )
        call AddOrderAbility( ACTIVATION_ORDER_ID, SPELL_ID )
        call InitEffectType( CASTER_EFFECT_PATH )
        call AddOrderAbility( DEACTIVATION_ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
    endfunction
//! runtextmacro Endscope()