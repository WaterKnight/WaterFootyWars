//TESH.scrollpos=84
//TESH.alwaysfold=0
//! runtextmacro Scope("PotionOfTheInconspicuousShape")
    globals
        public constant integer ITEM_ID = 'I006'
        public constant integer SPELL_ID = 'A01A'

        private constant real BONUS_EVADE_CHANCE = 0.5
        private constant string CASTER_EFFECT_PATH = "Abilities\\Spells\\Undead\\Possession\\PossessionTarget.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "overhead"
        private constant real DURATION = 15.
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
        call FlushAttachedIntegerById( casterId, PotionOfTheInconspicuousShape_SCOPE_ID )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DISPEL" )
        call DestroyEffectWJ( casterEffect )
        set casterEffect = null
        call FlushAttachedInteger( durationTimer, PotionOfTheInconspicuousShape_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call AddUnitEvasionChance( caster, -BONUS_EVADE_CHANCE )
    endfunction

    public function Dispel takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, PotionOfTheInconspicuousShape_SCOPE_ID)
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
        local Data d = GetAttachedInteger(durationTimer, PotionOfTheInconspicuousShape_SCOPE_ID)
        call Ending( d.caster, d, durationTimer )
        set durationTimer = null
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local integer casterId = caster.id
        local unit casterSelf = caster.self
        local real casterX = GetUnitX(casterSelf)
        local real casterY = GetUnitY(casterSelf)
        local Data d = GetAttachedIntegerById(casterId, PotionOfTheInconspicuousShape_SCOPE_ID)
        local timer durationTimer
        local boolean isNew = (d == NULL)
        if ( isNew ) then
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set d.caster = caster
            set d.durationTimer = durationTimer
            call AttachIntegerById( casterId, PotionOfTheInconspicuousShape_SCOPE_ID, d )
            //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
            //! runtextmacro AddEventById( "casterId", "EVENT_DISPEL" )
            call AttachInteger( durationTimer, PotionOfTheInconspicuousShape_SCOPE_ID, d )
        else
            set durationTimer = d.durationTimer
            call DestroyEffectWJ( d.casterEffect )
        endif
        set d.casterEffect = AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, casterSelf, CASTER_EFFECT_ATTACHMENT_POINT )
        if (isNew) then
            call AddUnitEvasionChance( caster, BONUS_EVADE_CHANCE )
        endif
        call PlaySoundFromTypeAtPosition( POTION_OF_THE_INCONSPICUOUS_SHAPE_SOUND_TYPE, casterX, casterY, GetUnitZ( casterSelf, casterX, casterY ) )
        set casterSelf = null
        call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 125)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 80)
        call SetItemTypeRefreshIntervalStart(d, 200)

        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_DISPEL", "UnitIsDispelled_EVENT_KEY_POSITIVE", "0", "function Dispel_Event" )
        call InitEffectType( CASTER_EFFECT_PATH )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()