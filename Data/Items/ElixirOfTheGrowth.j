//TESH.scrollpos=72
//TESH.alwaysfold=0
//! runtextmacro Scope("ElixirOfTheGrowth")
    globals
        public constant integer ITEM_ID = 'I009'
        public constant integer SPELL_ID = 'A01F'

        private constant real BONUS_ATTRIBUTE = 15.
        private constant real BONUS_SCALE = 0.3
        private constant real DURATION = 60.
        private constant real SCALE_TIME = 2.
    endglobals

    private struct Data
        Unit caster
        timer durationTimer
    endstruct

    private function Ending takes Unit caster, Data d, timer durationTimer returns nothing
        local integer casterId = caster.id
        local integer casterType = caster.type
        call FlushAttachedIntegerById( casterId, ElixirOfTheGrowth_SCOPE_ID )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
        call FlushAttachedInteger( durationTimer, ElixirOfTheGrowth_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call AddUnitScaleTimed( caster, -BONUS_SCALE, SCALE_TIME )
        call AddHeroAgilityBonus( caster, casterType, -BONUS_ATTRIBUTE )
        call AddHeroIntelligenceBonus( caster, casterType, -BONUS_ATTRIBUTE )
        call AddHeroStrengthBonus( caster, casterType, -BONUS_ATTRIBUTE )
    endfunction

    public function Death takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById( caster.id, ElixirOfTheGrowth_SCOPE_ID )
        if ( d != NULL ) then
            call Ending( caster, d, d.durationTimer )
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, ElixirOfTheGrowth_SCOPE_ID)
        call Ending( d.caster, d, durationTimer )
        set durationTimer = null
    endfunction

    public function SpellEffect takes Unit caster, real casterX, real casterY, real casterZ returns nothing
        local integer casterId = caster.id
        local UnitType casterType
        local Data d = GetAttachedIntegerById(casterId, ElixirOfTheGrowth_SCOPE_ID)
        local timer durationTimer
        if ( d == NULL ) then
            set casterType = caster.type
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set d.caster = caster
            set d.durationTimer = durationTimer
            call AttachIntegerById( casterId, ElixirOfTheGrowth_SCOPE_ID, d )
            //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
            call AttachInteger( durationTimer, ElixirOfTheGrowth_SCOPE_ID, d )
            call AddHeroAgilityBonus( caster, casterType, BONUS_ATTRIBUTE )
            call AddHeroIntelligenceBonus( caster, casterType, BONUS_ATTRIBUTE )
            call AddHeroStrengthBonus( caster, casterType, BONUS_ATTRIBUTE )
            call AddUnitScaleTimed( caster, BONUS_SCALE, SCALE_TIME )
        else
            set durationTimer = d.durationTimer
        endif
        call PlaySoundFromTypeAtPosition( ELIXIR_OF_THE_GROWTH_SOUND_TYPE, casterX, casterY, casterZ )
        call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        local unit casterSelf = CASTER.self
        local real casterX = GetUnitX(casterSelf)
        local real casterY = GetUnitY(casterSelf)
        call SpellEffect( CASTER, casterX, casterY, GetUnitZ(casterSelf, casterX, casterY) )
        set casterSelf = null
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 150)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 45)
        call SetItemTypeRefreshIntervalStart(d, 100)

        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        call InitAbility(SPELL_ID)
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()