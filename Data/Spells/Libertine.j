//TESH.scrollpos=70
//TESH.alwaysfold=0
//! runtextmacro Scope("Libertine")
    globals
        public constant integer SPELL_ID = 'A06O'

        private constant real MAX_BONUS_SIGHT_RANGE = 300
        private constant real MAX_BONUS_SPEED = 80
        private constant real PRECISION_FACTOR = 100.
        private constant real UPDATE_TIME = 1.
    endglobals

    private struct Data
        Unit caster
        real lifeFactor
        timer updateTimer
    endstruct

    public function Death takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, Libertine_SCOPE_ID)
        local integer lifeFactor
        local timer updateTimer
        if ( d != NULL ) then
            set lifeFactor = R2I( -d.lifeFactor / PRECISION_FACTOR )
            call PauseTimer( d.updateTimer )
            call AddUnitSightRange( caster, lifeFactor * MAX_BONUS_SIGHT_RANGE )
            call AddUnitSpeed( caster, lifeFactor * MAX_BONUS_SPEED )
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function Update takes nothing returns nothing
        local timer updateTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(updateTimer, Libertine_SCOPE_ID)
        local Unit caster = d.caster
        local unit casterSelf = caster.self
        local integer lifeFactor = R2I( GetUnitState( casterSelf, UNIT_STATE_LIFE ) / GetUnitState( casterSelf, UNIT_STATE_MAX_LIFE ) * PRECISION_FACTOR )
        local integer lifeFactorAdd = R2I( ( lifeFactor - d.lifeFactor ) / PRECISION_FACTOR )
        local real bonusSightRange = lifeFactorAdd * MAX_BONUS_SIGHT_RANGE
        local real bonusSpeed = lifeFactorAdd * MAX_BONUS_SPEED
        set casterSelf = null
        set updateTimer = null
        set d.lifeFactor = lifeFactor
        call AddUnitSightRange( caster, bonusSightRange )
        call AddUnitSpeed( caster, bonusSpeed )
    endfunction

    public function Learn takes Unit caster returns nothing
        local integer casterId = caster.id
        local unit casterSelf = caster.self
        local Data d = Data.create()
        local integer lifeFactor = R2I( R2I( GetUnitState( casterSelf, UNIT_STATE_LIFE ) / GetUnitState( casterSelf, UNIT_STATE_MAX_LIFE ) * PRECISION_FACTOR ) / PRECISION_FACTOR )
        local real bonusSightRange = lifeFactor * MAX_BONUS_SIGHT_RANGE
        local real bonusSpeed = lifeFactor * MAX_BONUS_SPEED
        local timer updateTimer = CreateTimerWJ()
        set casterSelf = null
        set d.caster = caster
        set d.lifeFactor = lifeFactor
        set d.updateTimer = updateTimer
        call AttachIntegerById(casterId, Libertine_SCOPE_ID, d)
        //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
        //! runtextmacro AddEventById( "casterId", "EVENT_REVIVE" )
        call AttachInteger(updateTimer, Libertine_SCOPE_ID, d)
        call AddUnitSightRange( caster, bonusSightRange )
        call AddUnitSpeed( caster, bonusSpeed )
        call TimerStart( updateTimer, UPDATE_TIME, true, function Update )
        set updateTimer = null
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Revive takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, Libertine_SCOPE_ID)
        if ( d != NULL ) then
            call TimerStart(d.updateTimer, UPDATE_TIME, true, function Update)
        endif
    endfunction

    private function Revive_Event takes nothing returns nothing
        call Revive( REVIVING_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_REVIVE", "UnitFinishesReviving_EVENT_KEY", "0", "function Revive_Event" )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
    endfunction
//! runtextmacro Endscope()