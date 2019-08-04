//TESH.scrollpos=249
//TESH.alwaysfold=0
//! runtextmacro Scope("SoulVessel")
    globals
        public constant integer SPELL_ID = 'A06V'

        private constant real BONUS_RELATIVE_DAMAGE_BY_SPELL_PER_VESSEL = 0.1
        private constant real HEIGHT = 15.
        private constant real HEIGHT_WINDOW = 15.
        private constant integer MAX_VESSELS_AMOUNT = 3
        private constant real ANGLE_GAP = 2 * PI / MAX_VESSELS_AMOUNT
        private constant real OFFSET = 125.
        private constant real PERIOD_FACTOR = 0.5
        private constant real RELATIVE_REFRESHED_LIFE_PER_VESSEL = 0.1
        private constant real UPDATE_TIME = 0.035
        private constant real ANGLE_ADD = PI / 4 * UPDATE_TIME
    endglobals

    private struct Data
        real angle
        Unit caster
        timer moveTimer
        Unit array vessels[MAX_VESSELS_AMOUNT]
        integer vesselsAmount
    endstruct

    private function Ending takes Unit caster, Data d returns nothing
        local integer casterId = caster.id
        local timer moveTimer = d.moveTimer
        call d.destroy()
        call FlushAttachedIntegerById( casterId, SoulVessel_SCOPE_ID )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_CAST" )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_CASTER_DEATH" )
        call FlushAttachedInteger( moveTimer, SoulVessel_SCOPE_ID )
        call DestroyTimerWJ( moveTimer )
        set moveTimer = null
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local integer amount
        local unit casterSelf
        local integer count
        local integer iteration
        local Data d = GetAttachedIntegerById(caster.id, SoulVessel_SCOPE_ID)
        local Unit vessel
        local Unit array vessels
        if (d != NULL) then
            set casterSelf = caster.self
            set count = -1
            set iteration = MAX_VESSELS_AMOUNT
            loop
                set vessel = d.vessels[iteration]
                if (vessel != NULL) then
                    set count = count + 1
                    set vessels[count] = vessel
                endif
                set iteration = iteration - 1
                exitwhen (iteration < 0)
            endloop
            set iteration = count
            loop
                call KillUnit(vessels[iteration].self)
                set iteration = iteration - 1
                exitwhen (iteration < 0)
            endloop
            call AddUnitState(casterSelf, UNIT_STATE_LIFE, (count + 1) * RELATIVE_REFRESHED_LIFE_PER_VESSEL * GetUnitState(casterSelf, UNIT_STATE_MAX_LIFE))
            set casterSelf = null
        endif
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Move takes real angle, real casterX, real casterY, Unit vessel returns nothing
        local real newX = casterX + OFFSET * Cos( angle )
        local real newY = casterY + OFFSET * Sin( angle )
        local unit vesselSelf = vessel.self
        call SetUnitFacingWJ( vesselSelf, angle )
        call SetUnitX( vesselSelf, newX )
        call SetUnitY( vesselSelf, newY )
        call SetUnitZ( vesselSelf, newX, newY, HEIGHT + HEIGHT_WINDOW * Sin( PERIOD_FACTOR * angle ) )
        set vesselSelf = null
    endfunction

    //! runtextmacro Scope("Vessel")
        private struct Vessel_Data
            Data d
            integer index
        endstruct

        public function Vessel_RemoveVessel takes Data d, integer index returns nothing
            set d.vessels[index] = NULL
        endfunction

        public function Vessel_Death takes Unit vessel returns nothing
            local Data d
            local Unit caster
            local integer index
            local integer newAmount
            local integer vesselId = vessel.id
            local Vessel_Data e = GetAttachedIntegerById(vesselId, Vessel_SCOPE_ID)
            if ( e != NULL ) then
                set d = e.d
                set caster = d.caster
                set index = e.index
                call e.destroy()
                set newAmount = d.vesselsAmount - 1
                call Vessel_RemoveVessel( d, index )
                call FlushAttachedIntegerById( vesselId, Vessel_SCOPE_ID )
                //! runtextmacro RemoveEventById( "vesselId", "Vessel_EVENT_DEATH" )
                if ( newAmount == 0 ) then
                    call Ending( caster, d )
                else
                    set d.vesselsAmount = newAmount
                endif
                call AddUnitDamageBySpellBonus( caster, -BONUS_RELATIVE_DAMAGE_BY_SPELL_PER_VESSEL )
            endif
        endfunction

        private function Vessel_Death_Event takes nothing returns nothing
            call Vessel_Death( DYING_UNIT )
        endfunction

        public function Vessel_Start takes Unit caster, player casterOwner, Data d, boolean isNew, integer vesselsAmount returns nothing
            local real angle
            local unit casterSelf = caster.self
            local real casterX = GetUnitX( casterSelf )
            local real casterY = GetUnitY( casterSelf )
            local Vessel_Data e = Vessel_Data.create()
            local integer iteration
            local Unit vessel
            local integer vesselId
            set casterSelf = null
            if ( isNew ) then
                set angle = 0
                set iteration = 0
            else
                set angle = d.angle
                set iteration = vesselsAmount - 1
                loop
                    exitwhen (d.vessels[iteration] == NULL)
                    set iteration = iteration - 1
                endloop
            endif
            set angle = angle + iteration * ANGLE_GAP
            set vessel = CreateUnitEx( casterOwner, SOUL_VESSEL_UNIT_ID, 0, 0, angle )
            set vesselId = vessel.id
            set d.vessels[iteration] = vessel
            set d.vesselsAmount = vesselsAmount
            set e.d = d
            set e.index = iteration
            call AttachIntegerById( vesselId, Vessel_SCOPE_ID, e )
            //! runtextmacro AddEventById( "vesselId", "Vessel_EVENT_DEATH" )
            call SetUnitPathing( vessel.self, false )
            call Move( angle, casterX, casterY, vessel )
        endfunction

        public function Vessel_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "Vessel_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Vessel_Death_Event" )
        endfunction
    //! runtextmacro Endscope()

    public function Caster_Death takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, SoulVessel_SCOPE_ID)
        local integer iteration
        local Unit specificVessel
        local Unit array vessels
        local integer vesselsAmount
        if ( d != NULL ) then
            set iteration = 0
            set vesselsAmount = d.vesselsAmount
            loop
                set vessels[iteration] = d.vessels[iteration]
                set iteration = iteration + 1
                exitwhen (iteration >= vesselsAmount)
            endloop
            set iteration = 0
            loop
                set specificVessel = vessels[iteration]
                if (specificVessel != NULL) then
                    call KillUnit( specificVessel.self )
                endif
                set iteration = iteration + 1
                exitwhen ( iteration >= vesselsAmount )
            endloop
        endif
    endfunction

    private function Caster_Death_Event takes nothing returns nothing
        call Caster_Death( DYING_UNIT )
    endfunction

    private function MoveByTimer takes nothing returns nothing
        local timer moveTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(moveTimer, SoulVessel_SCOPE_ID)
        local real angle = d.angle + ANGLE_ADD
        local Unit caster = d.caster
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local integer iteration = MAX_VESSELS_AMOUNT - 1
        local Unit vessel
        set casterSelf = null
        set moveTimer = null
        set d.angle = angle
        loop
            set vessel = d.vessels[iteration]
            if (vessel != NULL) then
                call Move( angle, casterX, casterY, vessel )
            endif
            set iteration = iteration - 1
            exitwhen ( iteration < 0 )
            set angle = angle + ANGLE_GAP
        endloop
    endfunction

    private function TargetConditions takes unit caster, player casterOwner, Unit source returns boolean
        if ( GetUnitAbilityLevel( caster, SPELL_ID ) <= 0 ) then
            return false
        endif
        if ( GetUnitState( caster, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( source.self, casterOwner ) ) then
            return false
        endif
        if ( IsUnitIllusionWJ( source ) ) then
            return false
        endif
        return true
    endfunction

    public function TryGeneratingVessel takes Unit caster, player casterOwner returns nothing
        local integer casterId = caster.id
        local Data d = GetAttachedIntegerById(casterId, SoulVessel_SCOPE_ID)
        local boolean isNew = (d == NULL)
        local timer moveTimer
        local integer vesselsAmount
        if (isNew) then
            set d = Data.create()
            set moveTimer = CreateTimerWJ()
            set vesselsAmount = 1
            set d.caster = caster
            set d.moveTimer = moveTimer
            call AttachIntegerById(casterId, SoulVessel_SCOPE_ID, d)
            //! runtextmacro AddEventById( "casterId", "EVENT_CAST" )
            //! runtextmacro AddEventById( "casterId", "EVENT_CASTER_DEATH" )
            call AttachInteger(moveTimer, SoulVessel_SCOPE_ID, d)
            call TimerStart( moveTimer, UPDATE_TIME, true, function MoveByTimer )
            set moveTimer = null
        else
            set vesselsAmount = d.vesselsAmount + 1
        endif
        if ( vesselsAmount <= MAX_VESSELS_AMOUNT ) then
            set d.vesselsAmount = vesselsAmount
            call AddUnitDamageBySpellBonus( caster, BONUS_RELATIVE_DAMAGE_BY_SPELL_PER_VESSEL )
            call Vessel_Vessel_Start(caster, casterOwner, d, isNew, vesselsAmount)
        endif
    endfunction

    public function Source_Death takes Unit caster, player casterOwner, Unit source returns nothing
        if ( TargetConditions( caster.self, casterOwner, source ) ) then
            call TryGeneratingVessel( caster, casterOwner )
        endif
    endfunction

    private function Source_Death_Event takes nothing returns nothing
        call Source_Death( KILLING_UNIT, KILLING_UNIT.owner, DYING_UNIT )
    endfunction

    public function Learn takes Unit caster returns nothing
        //! runtextmacro AddEventById( "caster.id", "EVENT_SOURCE_DEATH" )
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        //! runtextmacro CreateEvent( "EVENT_CAST", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        //! runtextmacro CreateEvent( "EVENT_CASTER_DEATH", "UnitDies_EVENT_KEY", "0", "function Caster_Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_SOURCE_DEATH", "UnitDies_EVENT_KEY_AS_KILLING_UNIT", "0", "function Source_Death_Event" )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
        call Vessel_Vessel_Init()
    endfunction
//! runtextmacro Endscope()