//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("Reincarnation")
    globals
        public constant integer SPELL_ID = 'A07Q'

        private constant real COOLDOWN = 180.
    endglobals

    private struct Data
        Unit caster
        timer cooldownTimer
    endstruct

    private function Ending takes Unit caster, timer cooldownTimer, Data d returns nothing
        local integer casterId = caster.id
        local UnitType casterType = caster.type
        call d.destroy()
        call FlushAttachedIntegerById(casterId, Reincarnation_SCOPE_ID)
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DECAY" )
        call FlushAttachedInteger(cooldownTimer, Reincarnation_SCOPE_ID)
        if (GetUnitDecay(caster) > B2I(IsUnitTypeDecay(casterType))) then
            call RemoveUnitDecay(caster)
            call SetUnitDecayTime(caster, GetUnitTypeDecayTime(casterType))
            call RemoveUnitExplode( caster )
        endif
    endfunction

    public function Decay takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, Reincarnation_SCOPE_ID)
        if (d != NULL) then
            call Ending(caster, d.cooldownTimer, d)
        endif
    endfunction

    private function Decay_Event takes nothing returns nothing
        call Decay(TRIGGER_UNIT)
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer cooldownTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(cooldownTimer, Reincarnation_SCOPE_ID)
        call Ending(d.caster, cooldownTimer, d)
        set cooldownTimer = null
    endfunction

    public function BeforeDying takes Unit caster returns boolean
        local integer casterId
        local Data d
        local timer cooldownTimer
        if (GetUnitAbilityLevel(caster.self, SPELL_ID) > 0) then
            set casterId = caster.id
            set d = Data.create()
            set d.caster = caster
            set d.cooldownTimer = cooldownTimer
            call AttachIntegerById(casterId, Reincarnation_SCOPE_ID, d)
            //! runtextmacro AddEventById( "casterId", "EVENT_DECAY" )
            call AttachInteger(cooldownTimer, Reincarnation_SCOPE_ID, d)
            call TimerStart(cooldownTimer, COOLDOWN, false, function EndingByTimer)
            set cooldownTimer = null
            return true
        endif
        return false
    endfunction

    public function Init takes nothing returns nothing
        //! runtextmacro CreateEvent( "EVENT_DECAY", "UnitFinishesDecaying_EVENT_KEY", "0", "function Decay_Event" )
        call InitAbility( SPELL_ID )
    endfunction
//! runtextmacro Endscope()