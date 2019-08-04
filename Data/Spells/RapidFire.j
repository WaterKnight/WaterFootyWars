//TESH.scrollpos=126
//TESH.alwaysfold=0
//! runtextmacro Scope("RapidFire")
    globals
        public constant integer SPELL_ID = 'A076'
    endglobals

    //! runtextmacro Scope("Buff")
        globals
            private constant real Buff_BONUS_RELATIVE_ATTACK_RATE = 1.
            private constant string Buff_CASTER_EFFECT_PATH = "Abilities\\Spells\\Orc\\TrollBerserk\\HeadhunterWEAPONSLeft.mdl"
            private constant string Buff_CASTER_EFFECT_ATTACHMENT_POINT = "weapon left"
            private constant string Buff_CASTER_EFFECT2_PATH = "Abilities\\Spells\\Orc\\TrollBerserk\\HeadhunterWEAPONSRight.mdl"
            private constant string Buff_CASTER_EFFECT2_ATTACHMENT_POINT = "weapon right"
            private constant real Buff_DURATION = 5.
        endglobals

        private struct Buff_Data
            Unit caster
            effect casterEffect
            effect casterEffect2
            timer durationTimer
        endstruct

        private function Buff_Ending takes Unit caster, Buff_Data d, timer durationTimer returns nothing
            local effect casterEffect = d.casterEffect
            local effect casterEffect2 = d.casterEffect2
            local integer casterId = caster.id
            call FlushAttachedIntegerById( casterId, Buff_SCOPE_ID )
            //! runtextmacro RemoveEventById( "casterId", "Buff_EVENT_DEATH" )
            call DestroyEffectWJ( casterEffect )
            set casterEffect = null
            call DestroyEffectWJ( casterEffect2 )
            set casterEffect2 = null
            call FlushAttachedInteger( durationTimer, Buff_SCOPE_ID )
            call DestroyTimerWJ( durationTimer )
            call AddUnitAttackRate( caster, -Buff_BONUS_RELATIVE_ATTACK_RATE )
        endfunction

        public function Buff_Death takes Unit caster returns nothing
            local Buff_Data d = GetAttachedIntegerById(caster.id, Buff_SCOPE_ID)
            if (d != NULL) then
                call Buff_Ending(caster, d, d.durationTimer)
            endif
        endfunction

        private function Buff_Death_Event takes nothing returns nothing
            call Buff_Death( DYING_UNIT )
        endfunction

        private function Buff_EndingByTimer takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Buff_Data d = GetAttachedInteger(durationTimer, Buff_SCOPE_ID)
            call Buff_Ending( d.caster, d, durationTimer )
            set durationTimer = null
        endfunction

        public function Buff_Start takes Unit caster returns nothing
            local integer casterId = caster.id
            local unit casterSelf = caster.self
            local Buff_Data d = GetAttachedIntegerById(casterId, Buff_SCOPE_ID)
            local timer durationTimer
            local boolean isNew = (d == NULL)
            if ( isNew ) then
                set d = Buff_Data.create()
                set durationTimer = CreateTimerWJ()
                set d.caster = caster
                set d.durationTimer = durationTimer
                call AttachIntegerById( casterId, Buff_SCOPE_ID, d )
                //! runtextmacro AddEventById( "casterId", "Buff_EVENT_DEATH" )
                call AttachInteger( durationTimer, Buff_SCOPE_ID, d )
            else
                set durationTimer = d.durationTimer
                call DestroyEffectWJ( d.casterEffect )
                call DestroyEffectWJ( d.casterEffect2 )
            endif
            set d.casterEffect = AddSpecialEffectTargetWJ( Buff_CASTER_EFFECT_PATH, casterSelf, Buff_CASTER_EFFECT_ATTACHMENT_POINT )
            set d.casterEffect2 = AddSpecialEffectTargetWJ( Buff_CASTER_EFFECT2_PATH, casterSelf, Buff_CASTER_EFFECT2_ATTACHMENT_POINT )
            set casterSelf = null
            if (isNew) then
                call AddUnitAttackRate( caster, Buff_BONUS_RELATIVE_ATTACK_RATE )
            endif
            call TimerStart( durationTimer, Buff_DURATION, false, function Buff_EndingByTimer )
            set durationTimer = null
        endfunction

        public function Buff_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "Buff_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Buff_Death_Event" )
            call InitEffectType( Buff_CASTER_EFFECT_PATH )
            call InitEffectType( Buff_CASTER_EFFECT2_PATH )
        endfunction
    //! runtextmacro Endscope()

    public function Caster_Death takes Unit caster returns nothing
        local integer casterId
        if (GetUnitAbilityLevel(caster.self, SPELL_ID) > 0) then
            set casterId = caster.id
            //! runtextmacro RemoveEventById( "casterId", "EVENT_CASTER_DEATH" )
            //! runtextmacro RemoveEventById( "casterId", "EVENT_SOURCE_DEATH" )
        endif
    endfunction

    private function Caster_Death_Event takes nothing returns nothing
        call Caster_Death( DYING_UNIT )
    endfunction

    private function Source_Death_Conditions takes unit caster, player casterOwner, Unit source returns boolean
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

    public function Source_Death takes Unit caster, player casterOwner, Unit source returns nothing
        if ( Source_Death_Conditions( caster.self, casterOwner, source ) ) then
            call Buff_Buff_Start(caster)
        endif
    endfunction

    private function Source_Death_Event takes nothing returns nothing
        call Source_Death( KILLING_UNIT, KILLING_UNIT.owner, DYING_UNIT )
    endfunction

    public function Learn takes Unit caster returns nothing
        local integer casterId = caster.id
        //! runtextmacro AddEventById( "casterId", "EVENT_CASTER_DEATH" )
        //! runtextmacro AddEventById( "casterId", "EVENT_SOURCE_DEATH" )
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        //! runtextmacro CreateEvent( "EVENT_CASTER_DEATH", "UnitDies_EVENT_KEY", "0", "function Caster_Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_SOURCE_DEATH", "UnitDies_EVENT_KEY_AS_KILLING_UNIT", "0", "function Source_Death_Event" )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
        call Buff_Buff_Init()
    endfunction
//! runtextmacro Endscope()