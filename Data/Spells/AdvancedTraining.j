//TESH.scrollpos=13
//TESH.alwaysfold=0
//! runtextmacro Scope("AdvancedTraining")
    globals
        public constant integer ACTIVATION_ORDER_ID = 852133//OrderId( "autodispelon" )
        public constant integer DEACTIVATION_ORDER_ID = 852134//OrderId( "autodispeloff" )
        public constant integer SPELL_ID = 'A048'

        public constant integer BONUS_SPAWN_GOLD_COST = 40
        public constant real BONUS_TIME_FACTOR = 0.5
        public constant integer BONUS_TIME_GOLD_COST = 20

        public boolean array ON
        public boolean array USED
    endglobals

    public function Order_Activation takes Unit caster returns nothing
        set caster.automaticAbility = SPELL_ID
    endfunction

    private function Order_Activation_Event takes nothing returns nothing
        call AdvancedTraining_Order_Activation( ORDERED_UNIT )
    endfunction

    public function Order_Deactivation takes Unit caster returns nothing
        set caster.automaticAbility = 0
    endfunction

    private function Order_Deactivation_Event takes nothing returns nothing
        call AdvancedTraining_Order_Deactivation( ORDERED_UNIT )
    endfunction

    public function Learn takes Unit caster, UnitType casterType returns nothing
        if ( casterType.automaticAbility == SPELL_ID ) then
            call IssueImmediateOrderById( caster.self, ACTIVATION_ORDER_ID )
        endif
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER, LEARNER.type )
    endfunction

    public function Init takes nothing returns nothing
        call AddOrderAbility( ACTIVATION_ORDER_ID, SPELL_ID )
        call AddOrderAbility( DEACTIVATION_ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ACTIVATION_ORDER", "GetAbilityOrderId( SPELL_ID, ACTIVATION_ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Activation_Event" )
        //! runtextmacro AddNewEventById( "EVENT_DEACTIVATION_ORDER", "GetAbilityOrderId( SPELL_ID, DEACTIVATION_ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Deactivation_Event" )
        //! runtextmacro CreateDummyEvent( "EVENT_ORDER", "UnitGetsOrder_EVENT_KEY", "0" )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
    endfunction
//! runtextmacro Endscope()