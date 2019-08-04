//TESH.scrollpos=89
//TESH.alwaysfold=0
//! runtextmacro Scope("ToadReflection")
    globals
        private constant integer ORDER_ID = 852123//OrderId( "mirrorimage" )
        public constant integer RESEARCH_ID = 'R01J'
        public constant integer SPELL_ID = 'A08L'

        private constant string CASTER_EFFECT_PATH = "Abilities\\Spells\\Orc\\MirrorImage\\MirrorImageCaster.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "overhead"
        private constant real DELAY = 1.
        private constant real DURATION = 25.
        private constant real OFFSET = 65.
    endglobals

    private struct Data
        Unit caster
        effect casterEffect
        timer durationTimer
    endstruct

    private function Ending takes Unit caster, Data d, timer durationTimer returns nothing
        local effect casterEffect = d.casterEffect
        local integer casterId = caster.id
        call d.destroy()
        call FlushAttachedIntegerById( casterId, ToadReflection_SCOPE_ID )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
        call DestroyEffectWJ( casterEffect )
        set casterEffect = null
        call FlushAttachedInteger( durationTimer, ToadReflection_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call RemoveUnitInvulnerability( caster )
        call RemoveUnitStun( caster, 5 )
    endfunction

    public function Death takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, ToadReflection_SCOPE_ID)
        if ( d != NULL ) then
            call Ending( caster, d, d.durationTimer )
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, ToadReflection_SCOPE_ID)
        local Unit caster = d.caster
        local unit casterSelf = caster.self
        local real angle = GetUnitFacingWJ( casterSelf ) + PI / 2
        local real casterX = GetUnitX(casterSelf)
        local real casterY = GetUnitY(casterSelf)
        local Unit illusion = CreateIllusion( caster, caster.owner )
        local unit illusionSelf = illusion.self
        local integer random = 1 - GetRandomInt(0, 1) * 2
        local real offsetX = random * OFFSET * Cos(angle)
        local real offsetY = random * OFFSET * Sin(angle)
        call Ending( caster, d, durationTimer )
        set durationTimer = null
        call SetUnitPosition(casterSelf, casterX + offsetX, casterY + offsetY)
        set casterSelf = null
        call AddUnitArmorRelativeBonus( illusion, -1 )
        call UnitApplyTimedLifeWJ( illusionSelf, DURATION )
        call SetUnitPosition(illusionSelf, casterX - offsetX, casterY - offsetY)
        set illusionSelf = null
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local integer casterId = caster.id
        local unit casterSelf = caster.self
        local Data d = GetAttachedIntegerById(casterId, ToadReflection_SCOPE_ID)
        local timer durationTimer
        local boolean isNew = (d == NULL)
        if ( isNew ) then
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set d.caster = caster
            set d.durationTimer = durationTimer
            call AttachIntegerById(casterId, ToadReflection_SCOPE_ID, d)
            //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
            call AttachInteger(durationTimer, ToadReflection_SCOPE_ID, d)
        else
            set durationTimer = d.durationTimer
            call DestroyEffectWJ( d.casterEffect )
        endif
        set d.casterEffect = AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, casterSelf, CASTER_EFFECT_ATTACHMENT_POINT )
        set casterSelf = null
        if (isNew) then
            call AddUnitInvulnerability( caster )
            call AddUnitStun( caster, 5 )
        endif
        call TimerStart( durationTimer, DELAY, false, function EndingByTimer )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 300)

        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        call InitEffectType( CASTER_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()