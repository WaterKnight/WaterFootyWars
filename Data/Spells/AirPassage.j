//TESH.scrollpos=5
//TESH.alwaysfold=0
//! runtextmacro Scope("AirPassage")
    globals
        private constant integer ORDER_ID = 852525//OrderId( "blink" )
        public constant integer RESEARCH_ID = 'R01A'
        public constant integer SPELL_ID = 'A08M'

        private constant real DURATION = 2.
    endglobals

    public function EndCast takes Unit caster, real targetX, real targetY returns nothing
        local unit casterSelf = caster.self
        call SetUnitX(casterSelf, targetX)
        call SetUnitY(casterSelf, targetY)
        set casterSelf = null
        call SetUnitStunTimed(caster, 1, DURATION)
    endfunction

    private function EndCast_Event takes nothing returns nothing
        call EndCast( CASTER, TARGET_X, TARGET_Y )
    endfunction

    public function Order takes real targetX, real targetY returns string
        if (IsPointInPlayRegion(targetX, targetY) == false) then
            return ErrorStrings_INVALID_TARGET
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( TARGET_X, TARGET_Y )
    endfunction

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 300)

        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitFinishesCasting_EVENT_KEY", "0", "function EndCast_Event" )
    endfunction
//! runtextmacro Endscope()