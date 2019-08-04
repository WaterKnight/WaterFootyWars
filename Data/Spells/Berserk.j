//TESH.scrollpos=104
//TESH.alwaysfold=0
//! runtextmacro Scope("Berserk")
    globals
        private constant integer ORDER_ID = 852100//OrderId( "berserk" )
        public constant integer RESEARCH_ID = 'R017'
        public constant integer SPELL_ID = 'A084'

        private constant string CASTER_EFFECT_PATH = "Abilities\\Spells\\Orc\\TrollBerserk\\HeadhunterWEAPONSLeft.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "hand left"
        private constant string CASTER_EFFECT2_PATH = "Abilities\\Spells\\Orc\\TrollBerserk\\HeadhunterWEAPONSRight.mdl"
        private constant string CASTER_EFFECT2_ATTACHMENT_POINT = "hand right"
        private constant real DAMAGE_FACTOR = 1.5
        private constant real DURATION = 20.
        private constant real RELATIVE_BONUS_ATTACK_RATE = 0.75
    endglobals

    private struct Data
        Unit caster
        effect casterEffect
        effect casterEffect2
        timer durationTimer
    endstruct

    private function Ending takes Unit caster, Data d, timer durationTimer returns nothing
        local effect casterEffect = d.casterEffect
        local effect casterEffect2 = d.casterEffect2
        local integer casterId = caster.id
        call d.destroy()
        call FlushAttachedIntegerById( casterId, Berserk_SCOPE_ID )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DAMAGE" )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DISPEL" )
        call DestroyEffectWJ( casterEffect )
        set casterEffect = null
        call DestroyEffectWJ( casterEffect2 )
        set casterEffect2 = null
        call FlushAttachedInteger( durationTimer, Berserk_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        call AddUnitAttackRate( caster, -RELATIVE_BONUS_ATTACK_RATE )
    endfunction

    public function Dispel takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, Berserk_SCOPE_ID)
        if ( d != NULL ) then
            call Ending( caster, d, d.durationTimer )
        endif
    endfunction

    private function Dispel_Event takes nothing returns nothing
        call Dispel( TRIGGER_UNIT )
    endfunction

    public function Death takes Unit caster returns nothing
        call Dispel( caster )
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, Berserk_SCOPE_ID)
        call Ending( d.caster, d, durationTimer )
        set durationTimer = null
    endfunction

    public function Damage takes Unit caster, real damageAmount returns real
        if ((GetAttachedIntegerById(caster.id, Berserk_SCOPE_ID) != NULL)) then
            return (damageAmount * DAMAGE_FACTOR)
        endif
        return damageAmount
    endfunction

    private function Damage_Event takes nothing returns nothing
        set DAMAGE_AMOUNT = Damage(TRIGGER_UNIT, DAMAGE_AMOUNT)
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local integer casterId = caster.id
        local unit casterSelf = caster.self
        local Data d = GetAttachedIntegerById(casterId, Berserk_SCOPE_ID)
        local timer durationTimer
        local boolean isNew = (d == NULL)
        if ( isNew ) then
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set d.caster = caster
            set d.durationTimer = durationTimer
            call AttachIntegerById(casterId, Berserk_SCOPE_ID, d)
            //! runtextmacro AddEventById( "casterId", "EVENT_DAMAGE" )
            //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
            //! runtextmacro AddEventById( "casterId", "EVENT_DISPEL" )
            call AttachInteger(durationTimer, Berserk_SCOPE_ID, d)
        else
            set durationTimer = d.durationTimer
            call DestroyEffectWJ( d.casterEffect )
            call DestroyEffectWJ( d.casterEffect2 )
        endif
        set d.casterEffect = AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, casterSelf, CASTER_EFFECT_ATTACHMENT_POINT )
        set d.casterEffect2 = AddSpecialEffectTargetWJ( CASTER_EFFECT2_PATH, casterSelf, CASTER_EFFECT2_ATTACHMENT_POINT )
        set casterSelf = null
        if (isNew) then
            call AddUnitAttackRate( caster, RELATIVE_BONUS_ATTACK_RATE )
        endif
        call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 300)

        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_FOR_DAMAGE", "0", "function Damage_Event" )
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_DISPEL", "UnitIsDispelled_EVENT_KEY_POSITIVE", "0", "function Dispel_Event" )
        call InitEffectType( CASTER_EFFECT_PATH )
        call InitEffectType( CASTER_EFFECT2_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()